import 'package:elon_notifier/bloc/home/home_bloc.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'dialogs/ElonConfigDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ElonAlarmConfig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      if (state is HomeInitial) {
        return SizedBox();
      }
      HomeLoaded curState = state as HomeLoaded;
      return Container(
        alignment: Alignment.topCenter,
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        top: 20, bottom: 10, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade500,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Raises Alarm when any of the below conditions match.",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darken(
                                  Colors.red.shade500, 0.3),),
                          ),
                        ),

                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FlutterSwitch(
                              width: 55.0,
                              height: 25.0,
                              value: curState.mediaAlarm,
                              activeColor: AppColors.secondaryColor,
                              onToggle: (val) {
                                BlocProvider.of<HomeBloc>(context)
                                    .add(ElonConfigChanged(mediaAlarm: val));
                              },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Tweet contains an image/video.",
                              style: TextStyle(fontSize: 12),)
                          ],
                        ),

                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: _TagsView(
                              tags: curState.defaultElonFilters,
                              title: "Tweet matches default filters below"),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: _TagsView(
                              tags: curState.customElonFilters,
                              title: "Tweet matches custom filters below",
                              onTap: () {
                                showDialog(context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext dialogCtx) {
                                      return BlocProvider.value(
                                        value: BlocProvider.of<HomeBloc>(
                                            context),
                                        child: ElonConfigDialog(),
                                      );
                                    }
                                );
                              }
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Beta v1.1", style: TextStyle(fontSize: 12,
                              color: Colors.white.withOpacity(0.5)),),
                          SizedBox(width: 5,),
                          Icon(FontAwesomeIcons.solidCircle, size: 7, color: Colors.white.withOpacity(0.5),),
                          TextButton(onPressed: () async {
                            if (await canLaunch(
                                "https://www.instagram.com/the_dark_boffin/"))
                              await launch(
                                  "https://www.instagram.com/the_dark_boffin/");
                          },
                            child: Text("@the_dark_boffin", style: TextStyle(fontSize: 12)),
                          )

                        ],
                      )
                  )),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}



class _TagsView extends StatelessWidget {
  final String tags;
  final String title;
  final Function onTap;

  const _TagsView({Key key, this.tags, this.title, this.onTap})
      : super(key: key);

  List<String> getTags() {
    return tags.split(",");
  }


  Widget _noTagsWidget() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(30),
      child: Text("No filters defined.\nTap to add your filters.",
        style: TextStyle(fontSize: 13), textAlign: TextAlign.center,),
    );
  }

  Widget _tagsView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.secondaryBgColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 7,
                spreadRadius: 3,
                offset: Offset(2, 2)
            )
          ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              color: Colors.black.withOpacity(0.3),
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primary)),
            ),
            tags
                .trim()
                .length == 0 ? _noTagsWidget() : Container(
              padding: EdgeInsets.all(5),
              child: Wrap(
                children: [
                  for (String tag in getTags())
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                        ),
                        padding: EdgeInsets.only(
                            top: 5, bottom: 5, left: 10, right: 10),
                        margin: EdgeInsets.all(5),
                        child: Text(
                          tag,
                          style: TextStyle(fontSize: 12),
                        ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return _tagsView(context);
    }
    return InkWell(
      onTap: onTap,
      child: _tagsView(context),
    );
  }
}
