part of 'limit_bloc.dart';

abstract class LimitState extends Equatable {
  const LimitState();
}

class LimitInitial extends LimitState {
  final Map<String, String> coinIcons;
  final Map<String, double> coinValues;
  final List<LimitAlarm> alarms;

  LimitInitial({this.coinIcons = const {}, this.coinValues = const {}, this.alarms = const []});

  LimitInitial copyWith(
      {Map<String, String> coinIcons, Map<String, double> coinValues, List<
          LimitAlarm> alarms}) {
    return LimitInitial(coinIcons: coinIcons ?? this.coinIcons,
        coinValues: coinValues ?? this.coinValues,
        alarms: alarms ?? this.alarms);
  }

  @override
  List<Object> get props => [coinIcons, this.coinValues, this.alarms];
}

class LimitLoadingCurrencies extends LimitInitial {
  LimitLoadingCurrencies(Map<String, String> coinIcons,
      Map<String, double> coinValues, List<LimitAlarm> alarms)
      : super(coinIcons: coinIcons, coinValues: coinValues, alarms: alarms);

  static fromInitialState(LimitInitial limitInitial) {
    return LimitLoadingCurrencies(
        limitInitial.coinIcons, limitInitial.coinValues, limitInitial.alarms);
  }
}


class LimitLoadingError extends LimitInitial {
  LimitLoadingError(Map<String, String> coinIcons,
      Map<String, double> coinValues, List<LimitAlarm> alarms)
      : super(coinIcons: coinIcons, coinValues: coinValues, alarms: alarms);

  static fromInitialState(LimitInitial limitInitial) {
    return LimitLoadingError(
        limitInitial.coinIcons, limitInitial.coinValues, limitInitial.alarms);
  }
}