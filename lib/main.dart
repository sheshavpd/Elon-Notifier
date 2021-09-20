import 'package:bloc/bloc.dart';
import 'package:elon_notifier/common/AppChannels.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:elon_notifier/ui/screens/LimitAlarmScreen.dart';
import 'package:elon_notifier/ui/screens/TweetAlarmScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AppConstants.dart';
import 'common/app_logger.dart';
import 'ui/screens/home.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    alog.d(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    alog.e(error);
  }
}

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(AppRoot());
}

class AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Assist',
      theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.dark(
              secondary: AppColors.secondaryColor,
              primary: AppColors.primaryColor)),
      initialRoute: Routes.HOME,
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case Routes.TWEET_ALARM:
            return NoAnimPageRoute(builder: (_) => TweetAlarmScreen(routeSettings.arguments));
            break;
          case Routes.LIMIT_ALARM:
            return NoAnimPageRoute(builder: (_) => LimitAlarmScreen(routeSettings.arguments));
            break;
          case Routes.HOME:
            return NoAnimPageRoute(builder: (_) => Home());
            break;
          default:
            return NoAnimPageRoute(builder: (_) => Home());
            break;
        }
      },
    );
  }
}


class NoAnimPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimPageRoute({@required WidgetBuilder builder}) : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // TODO: implement buildTransitions
    return child;
  }
}
