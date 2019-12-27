import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/page/feed/feedPage.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key,this.profileId}) : super(key: key);
  final String profileId;
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PageController _pageController;
  int pageIndex = 0;
  bool isMyProfile = false;
  @override
  void initState() {
    _pageController = PageController();
    var authstate = Provider.of<AuthState>(context,listen:false);
    authstate.getProfileUser(userProfileId: widget.profileId);
     isMyProfile =  widget.profileId == null || widget.profileId  == authstate.userId ;
    super.initState();
  }
  Widget _body(){
    var state = Provider.of<AppState>(context);
    return Container(
      child: PageView(
        controller: _pageController,
        // scrollDirection: Axis.vertical,
        physics:PageScrollPhysics(),
        dragStartBehavior: DragStartBehavior.start,
        onPageChanged: (index){
          pageIndex = index;
          state.setpageIndex = index;
        },
        children: <Widget>[
          FeedPage(),
         
        ],
      )
    );
  }
   Widget _listRow(FeedModel model){
    var state = Provider.of<AuthState>(context,);
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
          ),
          child: customListTile(
            context,
            onTap: (){
               Navigator.of(context).pushNamed('/FeedPostDetail/'+model.key);
            },
            leading: customImage(context, model.profilePic),
            title: Row(
              children: <Widget>[
                customText(model.name,style: titleStyle),
                SizedBox(width: 10,),
                customText('- ${getChatTime(model.createdAt)}',style: subtitleStyle)
              ],
            ),
            subtitle: UrlText(text:model.description),
          )
        ),
        _imageFeed(model.imagePath,model.key),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          SizedBox(width: 80,),
            IconButton(
                onPressed: (){
                  Navigator.of(context).pushNamed('/FeedPostReplyPage/'+model.key);
                },
                icon:  Icon(Icons.message,color :  Colors.black38,),
              ),
            customText(model.commentCount.toString()),
            SizedBox(width: 20,),
           IconButton(
                onPressed:(){addLikeToPost(model.key);},
                icon:  Icon( model.likeList.any((x)=>x.userId == state.userId) ? Icons.favorite : Icons.favorite_border,color: model.likeList.any((x)=>x.userId == state.userId) ? Colors.red : Colors.black38),
              ),
          customText(model.likeCount.toString()),
          ],
        ),
        Divider()
      ],
    );
  }
   Widget _imageFeed(String _image,String key){
     return _image == null ? Container() :
     customInkWell(
       context: context,
       onPressed: (){ 
         var state = Provider.of<FeedState>(context,listen: false);
          state.getpostDetailFromDatabase(key);
          Navigator.pushNamed(context, '/ImageViewPge');
        //  Navigator.of(context).pushNamed('/FeedPostDetail/'+key);
         },
       child:Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 10),
          child:Container(
          height: 190,
          width: fullWidth(context) *.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            image:DecorationImage(image: customAdvanceNetworkImage(_image),fit:BoxFit.cover)
          ),
          // child: Image.file(_image),
        )
      )
     );
      
   }
  void addLikeToPost(String postId){
      var state = Provider.of<FeedState>(context,);
      var authState = Provider.of<AuthState>(context,);
      state.addLikeToPost(postId, authState.userId);
  }
  @override
  Widget build(BuildContext context) {
   var state = Provider.of<FeedState>(context,);
   var authstate = Provider.of<AuthState>(context,);
   List<FeedModel> list;
   String id = widget.profileId ?? authstate.userId;
   if(state.feedlist != null || state.feedlist.length > 0 ){
       list = state.feedlist.where((x)=>x.userId == id).toList();
   }
    return Scaffold(
     body: authstate.profileUserModel == null ? loader() :
     CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 180,
             elevation: 0,
             iconTheme: IconThemeData(color: Colors.white),
             backgroundColor: Colors.transparent,
             actions: <Widget>[
                PopupMenuButton<Choice>(
                  onSelected: (d){},
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Text(choice.title),
                      );
                    }).toList();
                  },
                ),
             ],
             flexibleSpace: FlexibleSpaceBar(
                background:Stack(
                  children: <Widget>[
                    Container(height:30, color:Colors.black),
                   Padding(
                     padding:EdgeInsets.only(top:30),
                     child: customNetworkImage('https://pbs.twimg.com/profile_banners/457684585/1510495215/1500x500',fit:BoxFit.fill),
                   ),
                   Container(
                     alignment:Alignment.bottomLeft,
                     child:Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: <Widget>[
                       Container(
                         padding: EdgeInsets.symmetric(horizontal: 10),
                         decoration: BoxDecoration(
                           border:Border.all(color: Colors.white,width: 5),
                          shape: BoxShape.circle
                         ),
                         child: customImage(context, authstate.profileUserModel.photoUrl,height: 80,)
                       ),
                       Container(
                        margin: EdgeInsets.only(top:60,right:30),
                        child: Row(children: <Widget>[
                            isMyProfile ? Container(height: 40,) :
                            InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              onTap:(){
                                  if(!isMyProfile){
                                    Navigator.pushNamed(context, '/ChatScreenPage');
                                  }
                                },
                                child:Container(
                                  // margin: EdgeInsets.only(right: 20),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                    border:Border.all(color:isMyProfile ?  Colors.black87.withAlpha(180) : Colors.blue ,width: 1),
                                    shape: BoxShape.circle
                                  ),
                                  child: Icon(Icons.mail_outline,color: Colors.blue,size: 15,),
                                ),
                             ),
                            SizedBox(width: 20,),
                            InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              onTap:(){
                                  if(isMyProfile){
                                    Navigator.pushNamed(context, '/EditProfile');
                                  }
                                },
                              child: Container(
                                 padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                 decoration: BoxDecoration(
                                 border:Border.all(color:isMyProfile ?  Colors.black87.withAlpha(180) : Colors.blue ,width: 1),
                                 borderRadius: BorderRadius.circular(20)
                               ),
                               child: Text(isMyProfile ? 'Edit Profile' : 'Follow',style:TextStyle(color:isMyProfile ? Colors.black87.withAlpha(180): Colors.blue ,fontSize: 17, fontWeight: FontWeight.bold))
                             ),
                              ),
                          ],)
                      )
                    ],)
                  )
              ],)
             )
         ),
         SliverList(
           delegate: SliverChildListDelegate([
                SizedBox(height:10),
                 Padding(
                   padding:EdgeInsets.symmetric(horizontal: 10,),
                   child:customText(authstate.profileUserModel.displayName,style:titleStyle),
                 ),
                 Padding(
                   padding:EdgeInsets.symmetric(horizontal: 9),
                   child:customText('${authstate.profileUserModel.userName}',style:subtitleStyle.copyWith(fontSize: 13)),
                 ),
                  Padding(
                   padding:EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                   child:customText(authstate.profileUserModel.bio,),
                 ),
                  Padding(
                   padding:EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                   child:Row(
                     children: <Widget>[
                       Icon(Icons.location_city,size: 14,color: Colors.black54),
                       SizedBox(width: 10,),
                       customText(authstate.profileUserModel.location,style:TextStyle(color: Colors.black54)),
                     ],
                   )
                 ),
                 Padding(
                   padding:EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                   child:Row(
                     children: <Widget>[
                       Icon(Icons.calendar_today,size: 14,color: Colors.black54),
                       SizedBox(width: 10,),
                       customText(getdob(authstate.profileUserModel.dob),style:TextStyle(color: Colors.black54)),
                     ],
                   )
                 ),
                  Container(
                    alignment: Alignment.center,
                    child:Row(
                      children: <Widget>[
                      SizedBox(width: 10,height: 30,),
                      customText('${authstate.profileUserModel.followers} ',style:TextStyle(fontWeight: FontWeight.bold,fontSize:17)),
                      customText('Followers',style:TextStyle(color: Colors.black54,fontSize:17)),
                      SizedBox(width: 40,),
                      customText('${authstate.profileUserModel.following} ',style:TextStyle(fontWeight: FontWeight.bold,fontSize:17)),
                      customText('Following',style:TextStyle(color: Colors.black54,fontSize:17)),
                    ],)
                  ),
                 Divider()
             ]),
         ),
         SliverList(
           delegate: SliverChildListDelegate(
             list == null || list.length < 1? 
             [ Container(child:Center(
                child: Text('No post created yet',style: subtitleStyle,),
             ))]
             :list.map((x)=> _listRow(x)).toList()
           ),)
        ])
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Share', icon: Icons.directions_car),
  const Choice(title: 'Draft', icon: Icons.directions_bike),
  const Choice(title: 'View Lists', icon: Icons.directions_boat),
  const Choice(title: 'View Moments', icon: Icons.directions_bus),
  const Choice(title: 'QR code', icon: Icons.directions_railway),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}