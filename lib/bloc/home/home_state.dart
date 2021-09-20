part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoaded extends HomeState {
  final String defaultElonFilters;
  final String customElonFilters;
  final bool mediaAlarm;

  HomeLoaded(this.defaultElonFilters, this.customElonFilters, this.mediaAlarm);

  HomeLoaded copyWith({String defaultElonFilters, String customElonFilters, bool mediaAlarm}) {
    return HomeLoaded(defaultElonFilters ?? this.defaultElonFilters,
        customElonFilters ?? this.customElonFilters,
        mediaAlarm ?? this.mediaAlarm
    );
  }

  @override
  List<Object> get props => [this.defaultElonFilters, this.customElonFilters, this.mediaAlarm];
}
