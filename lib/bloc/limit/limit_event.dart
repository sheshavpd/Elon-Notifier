part of 'limit_bloc.dart';

abstract class LimitEvent extends Equatable {
  const LimitEvent();
  @override
  List<Object> get props => null;
}

class LimitStateBoot extends LimitEvent {
  @override
  String toString() =>
      'LimitStateBoot';
}

class LimitAlarmsReload extends LimitEvent {
  final String alarmsListJson;

  LimitAlarmsReload(this.alarmsListJson);
  @override
  String toString() =>
      'LimitAlarmsReload';
  @override
  List<Object> get props => [alarmsListJson];
}

class LoadCoinInfo extends LimitEvent {
  @override
  String toString() =>
      'LoadCoinInfo';
}

class AddNewLimit extends LimitEvent {
  final LimitAlarm limitAlarm;

  AddNewLimit(this.limitAlarm);
  @override
  String toString() =>
      'AddNewLimit';
  @override
  List<Object> get props => [limitAlarm];
}

class RemoveLimitAlarm extends LimitEvent {
  final LimitAlarm limitAlarm;

  RemoveLimitAlarm(this.limitAlarm);
  @override
  String toString() =>
      'RemoveLimitAlarm';
  @override
  List<Object> get props => [limitAlarm];
}