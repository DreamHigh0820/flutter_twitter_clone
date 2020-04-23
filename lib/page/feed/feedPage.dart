import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/tweet/tweet.dart';
import 'package:flutter_twitter_clone/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/CreateFeedPage/tweet');
      },
      child: customIcon(
        context,
        icon: AppIcon.fabTweet,
        istwitterIcon: true,
        iconColor: Theme.of(context).colorScheme.onPrimary,
        size: 25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingActionButton(context),
      backgroundColor: TwitterColor.mystic,
      body: SafeArea(
        child: Container(
          height: fullHeight(context),
          width: fullWidth(context),
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              var state = Provider.of<FeedState>(context, listen: false);
              state.getDataFromDatabase();
              return Future.value(true);
            },
            child: _FeedPageBody(
              refreshIndicatorKey: refreshIndicatorKey,
              scaffoldKey: scaffoldKey,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedPageBody extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  const _FeedPageBody({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);
  Widget _getUserAvatar(BuildContext context) {
    var authState = Provider.of<AuthState>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: customInkWell(
        context: context,
        onPressed: () {
          scaffoldKey.currentState.openDrawer();
        },
        child:
            customImage(context, authState.userModel?.profilePic, height: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    var authstate = Provider.of<AuthState>(context);
    List<FeedModel> list;
    if (!state.isBusy && state.feedlist != null && state.feedlist.isNotEmpty) {
      list = state.feedlist.where((x) {
        if (x.user.userId == authstate.userId ||
            (authstate.userModel?.followingList != null &&
                authstate.userModel.followingList.contains(x.user.userId))) {
          return true;
        } else {
          return false;
        }
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          elevation: 0,
          leading: _getUserAvatar(context),
          title: customTitleText('Home'),
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          backgroundColor: Theme.of(context).appBarTheme.color,
          bottom: PreferredSize(
            child: Container(
              color: Colors.grey.shade200,
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(0.0),
          ),
        ),
        state.isBusy && list == null
            ? SliverToBoxAdapter(
                child: Container(
                  height: fullHeight(context) - 135,
                  child: CustomScreenLoader(
                    height: double.infinity,
                    width: fullWidth(context),
                    backgroundColor: Colors.white,
                  ),
                ),
              )
            : !state.isBusy && list == null
                ? SliverToBoxAdapter(
                    child: EmptyList(
                    'No Tweet added yet',
                    subTitle:
                        'When new Tweet added, they\'ll show up here \n Tap tweet button to add new',
                  ))
                : SliverList(
                    delegate: SliverChildListDelegate(
                      list.map(
                        (model) {
                          return Container(
                            color: Colors.white,
                            child: Tweet(
                              model: model,
                              trailing: TweetBottomSheet().tweetOptionIcon(
                                  context, model, TweetType.Tweet),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  )
      ],
    );
  }
}
