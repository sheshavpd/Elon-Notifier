import 'dart:convert';

import 'package:elon_notifier/common/AppChannels.dart';
import 'package:elon_notifier/models/TweetAlarm.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TweetAlarmScreen extends StatefulWidget {
  final TweetAlarm tweetAlarm;

  TweetAlarmScreen(String tweetAlarmJson)
      : tweetAlarm = TweetAlarm.fromJSON(json.decode(tweetAlarmJson)) {}

  @override
  _TweetAlarmScreenState createState() => _TweetAlarmScreenState();
}

class _TweetAlarmScreenState extends State<TweetAlarmScreen> {
  Future<void> _stopAlarm() async {
    try {
      await AppChannels.getInstance().commonChannel.invokeMethod('stopAlarm');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Widget _tweetLayout() {
    if (widget.tweetAlarm.text.trim().isEmpty) {
      return SizedBox();
    }
    return Container(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 7,
                      spreadRadius: 3,
                      offset: Offset(2,2)
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
                color: AppColors.secondaryBgColor),
            child: Text(widget.tweetAlarm.text, textAlign: TextAlign.start,),
          ),
          Positioned(
            top: -5,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgColor,
              ),
              padding: EdgeInsets.all(10),
              child: Icon(
                FontAwesomeIcons.twitter,
                color: AppColors.primaryColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        color: AppColors.bgColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.notifications_active,
              size: 64,
              color: AppColors.secondaryColor,
            ),
            Text(
              "Elon Tweet Alarm",
              style: TextStyle(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            _tweetLayout(),
            SizedBox(height: 20),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.black.withOpacity(0.2)),
                  child: Text(widget.tweetAlarm.matchReason,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style:
                      ElevatedButton.styleFrom(primary: Colors.orange.shade600),
                  icon: Icon(Icons.notifications_off),
                  onPressed: () {
                    _stopAlarm();
                  },
                  label: Text("Silence"),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.open_in_new),
                  onPressed: () async {
                    _stopAlarm();
                    if (await canLaunch(widget.tweetAlarm.url))
                      await launch(widget.tweetAlarm.url);
                    Navigator.pop(context);
                  },
                  label: Text("Open Tweet"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  dispose() {
    _stopAlarm();
    super.dispose();
  }
}
