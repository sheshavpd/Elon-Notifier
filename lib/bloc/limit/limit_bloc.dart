import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:elon_notifier/common/AppChannels.dart';
import 'package:elon_notifier/models/LimitAlarm.dart';
import 'package:elon_notifier/repositories/CoinswitchAPIRepo.dart';
import 'package:elon_notifier/repositories/ConfigurationRepository.dart';
import 'package:equatable/equatable.dart';

part 'limit_event.dart';

part 'limit_state.dart';

class LimitBloc extends Bloc<LimitEvent, LimitState> {
  CoinswitchAPIRepo _coinswitchAPIRepo = CoinswitchAPIRepo.getInstance();
  StreamSubscription<String> _alarmConfigSub;
  ConfigurationRepository _configurationRepository =
      ConfigurationRepository.getInstance();

  LimitBloc() : super(LimitInitial()) {
    _alarmConfigSub =
        _configurationRepository.alarmListChangePub().listen((alarmCfgJson) {
            add(LimitAlarmsReload(alarmCfgJson));
    });
  }

  @override
  Future<void> close() {
    _alarmConfigSub.cancel();
    return super.close();
  }

  @override
  Stream<LimitState> mapEventToState(
    LimitEvent event,
  ) async* {
    if (event is LimitStateBoot) {
      final coinIconsStr = await _configurationRepository.getCoinInfo() ?? "{}";
      final curState = state as LimitInitial;
      final alarmsListJson =
          await _configurationRepository.getAlarmsList() ?? "[]";
      final alarmsList = (json.decode(alarmsListJson) as List)
          .map((e) => LimitAlarm.fromJSON(e))
          .toList();
      yield curState.copyWith(
          coinIcons: (json.decode(coinIconsStr) as Map<String, dynamic>)
              .cast<String, String>(),
          alarms: alarmsList);
    }

    if (event is LimitAlarmsReload) {
      final alarmsList = (json.decode(event.alarmsListJson) as List)
          .map((e) => LimitAlarm.fromJSON(e))
          .toList();
      final curState = state as LimitInitial;
      yield curState.copyWith(alarms: alarmsList);
    }

    if (event is LoadCoinInfo) {
      yield LimitLoadingCurrencies.fromInitialState(state);
      try {
        List coinInfo = await _coinswitchAPIRepo.getCoinInfo();
        final curState = state as LimitInitial;
        yield curState.copyWith(
            coinIcons: coinInfo[0], coinValues: coinInfo[1]);
        _configurationRepository.saveCoinInfo(json.encode(coinInfo[0]));
      } catch (e) {
        print(e);
        yield LimitLoadingError.fromInitialState(state);
      }
    }

    if (event is AddNewLimit) {
      final curState = state as LimitInitial;
      final newAlarms = List<LimitAlarm>.from(curState.alarms)
        ..add(event.limitAlarm);
      _configurationRepository.saveAlarms(json.encode(newAlarms));
      yield curState.copyWith(alarms: newAlarms);

      AppChannels.getInstance()
          .commonChannel
          .invokeMethod("reloadAlarmConfigs");
    }

    if (event is RemoveLimitAlarm) {
      final curState = state as LimitInitial;
      final newAlarms = List<LimitAlarm>.from(curState.alarms)
        ..remove(event.limitAlarm);
      _configurationRepository.saveAlarms(json.encode(newAlarms));
      yield curState.copyWith(alarms: newAlarms);
      AppChannels.getInstance()
          .commonChannel
          .invokeMethod("reloadAlarmConfigs");
    }
  }
}
