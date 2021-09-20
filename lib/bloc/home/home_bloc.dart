import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:elon_notifier/repositories/ConfigurationRepository.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  ConfigurationRepository _configurationRepository = ConfigurationRepository.getInstance();
  HomeBloc() : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if(event is AppStarted) {
      String defaultElonFilters = await _configurationRepository.getDefaultElonFilters();
      String customElonFilters = await _configurationRepository.getCustomElonFilters();
      bool mediaAlarm = await _configurationRepository.isMediaAlarmEnabled();
      yield HomeLoaded(defaultElonFilters, customElonFilters, mediaAlarm);
    }
    else if(event is ElonConfigChanged) {
      HomeLoaded curState = state as HomeLoaded;
      HomeLoaded newState = curState.copyWith(customElonFilters: event.customElonFilters, mediaAlarm: event.mediaAlarm);
      yield newState;
      await _configurationRepository.saveElonConfig(newState.customElonFilters, newState.mediaAlarm);
    }
    // TODO: implement mapEventToState
  }
}
