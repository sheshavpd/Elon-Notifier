import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationRepository {
  SharedPreferences _pref;
  static ConfigurationRepository _instance;
  ConfigurationRepository._() { }
  static ConfigurationRepository getInstance() => _instance ??= ConfigurationRepository._();


  PublishSubject<String> _alarmsCFGPublisher = PublishSubject();

  Future<SharedPreferences> get _appPrefs async {
    if (_pref != null) return _pref;
    return _pref = await SharedPreferences.getInstance();
  }

  Future<String> getDefaultElonFilters() async {
    if ((await _appPrefs).containsKey("defaultElonFilters"))
      return (await _appPrefs).getString("defaultElonFilters");
    return "";
  }

  Future<String> getCustomElonFilters() async {
    if ((await _appPrefs).containsKey("customElonFilters"))
      return (await _appPrefs).getString("customElonFilters");
    return "";
  }

  Future<void> saveElonConfig(String filterString, bool mediaAlarm) async {
    (await _appPrefs).setString("customElonFilters", filterString);
    (await _appPrefs).setBool("mediaAlarm", mediaAlarm);
  }

  Future<bool> isMediaAlarmEnabled() async {
    if ((await _appPrefs).containsKey("mediaAlarm"))
      return (await _appPrefs).getBool("mediaAlarm");
    return true;
  }

  Future<void> saveAlarms(String alarmsList) async {
    (await _appPrefs).setString("limitAlarms", alarmsList);
  }

  void checkAlarmsListChanges() async {
    //Reload Shared preferences. Usually shared preferences' cache is invalidated by setter methods.
    // Native Changes doesn't invalidate the cache.
    await (await _appPrefs).reload();
    final alarmsJsonStr = (await getAlarmsList()) ?? "[]";
    _alarmsCFGPublisher.add(alarmsJsonStr);
  }

  Stream<String> alarmListChangePub() {
    return _alarmsCFGPublisher.distinct();
  }

  Future<String> getAlarmsList() async {
    if ((await _appPrefs).containsKey("limitAlarms"))
      return (await _appPrefs).getString("limitAlarms");
    return null;
  }

  Future<void> saveCoinInfo(String iconInfoMap) async {
    (await _appPrefs).setString("coinIcons", iconInfoMap);
  }

  Future<String> getCoinInfo() async {
    if ((await _appPrefs).containsKey("coinIcons"))
      return (await _appPrefs).getString("coinIcons");
    return null;
  }
}
