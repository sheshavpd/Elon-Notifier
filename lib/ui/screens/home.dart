import 'dart:convert';

import 'package:elon_notifier/bloc/home/home_bloc.dart';
import 'package:elon_notifier/bloc/limit/limit_bloc.dart';
import 'package:elon_notifier/common/AppChannels.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:elon_notifier/ui/screens/ElonAlarmConfig.dart';
import 'package:elon_notifier/ui/screens/LimitAlarmsList.dart';
import 'package:elon_notifier/ui/screens/dialogs/AskDrawPermission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../AppConstants.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppChannels.getInstance().commonChannel.invokeMethod("checkAlarmStart");
    checkDrawPermission();
    AppChannels.getInstance()
        .commonChannel
        .setMethodCallHandler(_handleInvocation);
  }

  Future<dynamic> _handleInvocation(call) {
    switch (call.method) {
      case CommonChannelMethods.DRAW_GRANTED:
        {
          _drawGranted();
          break;
        }
      case CommonChannelMethods.GOTO_ROUTE:
        {
          _changeRoute(call.arguments);
          break;
        }
    }
  }

  void _drawGranted() {
    /*setState(() {
      _text = "draw permission granted";
    });*/
  }

  void _changeRoute(Map routeArgs) {
    Navigator.pushNamed(context, routeArgs["route"], arguments: routeArgs["content"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: AppColors.bgColor,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(
              lazy: false,
              create: (BuildContext context) => HomeBloc()..add(AppStarted()),
            ),
            BlocProvider<LimitBloc>(
              lazy: false,
              create: (BuildContext context) => LimitBloc()..add(LimitStateBoot()),
            ),
          ],
          child: _HomeBody(),
        ),
      ),
    );
    ;
  }

  void _showDrawPermissionDialog() {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogCtx) {
          return AskDrawPermissionDialog();
        }
    );
  }

  void checkDrawPermission() async{
    final drawGranted = await AppChannels.getInstance().commonChannel.invokeMethod("checkDrawPermission");
    if(!drawGranted) {
      _showDrawPermissionDialog();
    }
  }
}

class _HomeBody extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, top: MediaQuery.of(context).padding.top + 10),
            child: _TitleBar(),
          ),
          SizedBox(
            height: 20,
          ),

          Expanded(child: _TabBar(children: [
            ElonAlarmConfig(),
            LimitAlarmsList()

          ],))
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset("assets/images/logo_min.png", width: 40),
        Text(
          "Crypto Assist",
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
        )
      ],
    );
  }
}

class _TabBar extends StatefulWidget {

  final List<Widget> children;

  const _TabBar({Key key, this.children}) : super(key: key);
  @override
  __TabBarState createState() => __TabBarState();
}

class __TabBarState extends State<_TabBar> with TickerProviderStateMixin {
  int _index = 0;
  AnimationController _controller;
  Animation<double> _animation;

  __TabBarState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  int _getIndex() {
    return _index;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.forward();
  }

  void _onTabChange(tabIndex) {
    setState(() {
      _index = tabIndex;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryBgColor,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 7,
                spreadRadius: 3
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Tab(
                  selected: _index == 0,
                  index: 0,
                  text: "Elon Alarm",
                  iconData: FontAwesomeIcons.twitter,
                  onTap: _onTabChange,
                ),
                _Tab(
                    selected: _index == 1,
                    index: 1,
                    text: "Limit Alarm",
                    iconData: FontAwesomeIcons.chartLine,
                    onTap: _onTabChange),
              ],
            ),
          ),
        ),
        Expanded(child: Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            )

          ),
          margin: EdgeInsets.only(top: 20),
          child: FadeTransition(
            opacity: _animation,
            child: widget.children[_index],
          ),
        ))

      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final bool selected;
  final int index;
  final String text;
  final Function onTap;
  final IconData iconData;

  const _Tab(
      {Key key,
      @required this.selected,
      @required this.text,
      @required this.onTap,
      @required this.iconData,
      this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.black.withAlpha(70) : Colors.transparent,
        ),
        padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            ClipRRect(
              child: AnimatedContainer(
                width: selected ? 30 : 0,
                duration: Duration(milliseconds: 150),
                child: Icon(
                  iconData,
                  color: selected
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(text)
          ],
        ),
      ),
      onTap: () {
        onTap(index);
      },
    );
  }
}
