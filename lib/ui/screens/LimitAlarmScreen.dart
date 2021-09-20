import 'dart:convert';

import 'package:elon_notifier/common/AppChannels.dart';
import 'package:elon_notifier/models/LimitAlarm.dart';
import 'package:elon_notifier/repositories/ConfigurationRepository.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LimitAlarmScreen extends StatefulWidget {
  final LimitAlarm limitAlarm;

  LimitAlarmScreen(String limitAlarmJson)
      : limitAlarm = LimitAlarm.fromJSON(json.decode(limitAlarmJson)) {
    ConfigurationRepository.getInstance().checkAlarmsListChanges();
  }

  @override
  _LimitAlarmScreenState createState() => _LimitAlarmScreenState();
}

class _LimitAlarmScreenState extends State<LimitAlarmScreen> {
  Future<void> _stopAlarm() async {
    try {
      await AppChannels.getInstance().commonChannel.invokeMethod('stopAlarm');
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Widget _limitBreachLayout() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black.withOpacity(0.2)),
            child: Text(
              widget.limitAlarm.symbol.toUpperCase(),
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(widget.limitAlarm.lowerLimit ? " went below " : " went above "),
          SizedBox(
            height: 5,
          ),
          Text(
            widget.limitAlarm.limit.toString(),
            style: TextStyle(color: AppColors.primaryColor, fontSize: 20),
          ),
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
              "Limit Breach Alarm",
              style: TextStyle(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            _limitBreachLayout(),
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
                    await LaunchApp.openApp(
                        androidPackageName: 'com.coinswitch.kuber',
                        openStore: false);
                    Navigator.pop(context);
                  },
                  label: Text("Open Coinswitch"),
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
