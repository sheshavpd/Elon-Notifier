import 'package:elon_notifier/common/AppChannels.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:flutter/material.dart';


class AskDrawPermissionDialog extends StatelessWidget {

  void _askPermission() {
    AppChannels.getInstance().commonChannel.invokeMethod("askDrawPermission");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0,
      backgroundColor: AppColors.secondaryBgColor,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text("For proper functioning of the app, please provide permission to display over other apps."),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MaterialButton(
                textColor: Colors.red,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  _askPermission();
                  Navigator.pop(context);
                },
                child: Text("Okay"),
              )
            ],
          )
        ],
      ),
    );
  }
}
