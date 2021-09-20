part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => null;
}

class AppStarted extends HomeEvent {

  @override
  String toString() =>
      'AppStarted';
}


class ElonConfigChanged extends HomeEvent {
  final String customElonFilters;
  final bool mediaAlarm;

  ElonConfigChanged({this.customElonFilters, this.mediaAlarm});

  @override
  List<Object> get props => [customElonFilters, this.mediaAlarm];

  @override
  String toString() =>
      'ElonConfigChanged';
}
