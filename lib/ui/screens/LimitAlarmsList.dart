import 'package:cached_network_image/cached_network_image.dart';
import 'package:elon_notifier/bloc/limit/limit_bloc.dart';
import 'package:elon_notifier/models/LimitAlarm.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:elon_notifier/ui/screens/dialogs/AddLimitDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LimitAlarmsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LimitBloc, LimitState>(
      builder: (context, state) {
        final curState = state as LimitInitial;
        return Container(
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            children: [
              curState.alarms.length == 0
                  ? Container(
                      alignment: Alignment.center,
                      child: Text(
                        "No alarms exist.\nAdd now :)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withOpacity(0.4)),
                      ))
                  : _LimitAlarmsListView(),
              Positioned(
                right: 15,
                bottom: 15,
                child: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext dialogCtx) {
                          return BlocProvider.value(
                              value: BlocProvider.of<LimitBloc>(context),
                              child: AddLimitDialog());
                        });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Icon(
                      Icons.add,
                      size: 35,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient
                    ),
                  )
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _LimitAlarmsListView extends StatelessWidget {
  Widget _getListItem(
      LimitAlarm alarm, BuildContext context, LimitInitial state) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.secondaryBgColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 7,
                spreadRadius: 3,
                offset: Offset(2, 2))
          ]),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 10,
              children: [
                Container(
                  padding:
                      EdgeInsets.only(left: 5, right: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CachedNetworkImage(
                        imageUrl: state.coinIcons[alarm.symbol] ?? "",
                        width: 30,
                        placeholder: (context, url) => SizedBox(),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.circle),
                      ),
                      SizedBox(width: 5,),
                      Text(
                        alarm.symbol.toUpperCase(),
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(alarm.lowerLimit ? "goes below" : "goes above"),
                Text(
                  " ${alarm.limit}",
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(onPressed: () {
            BlocProvider.of<LimitBloc>(context).add(RemoveLimitAlarm(alarm));
          }, icon: Icon(FontAwesomeIcons.trash, color: AppColors.secondaryColor,)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LimitBloc, LimitState>(
      builder: (context, state) {
        final curState = state as LimitInitial;
        return Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: ListView.builder(
            padding: EdgeInsets.only(top: 5),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(top: 15),
                child: _getListItem(
                    curState.alarms[curState.alarms.length - index - 1],
                    context,
                    state),
              );
            },
            itemCount: curState.alarms.length,
          ),
        );
      },
    );
  }
}
