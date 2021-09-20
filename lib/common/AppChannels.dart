import 'package:flutter/services.dart';

import '../AppConstants.dart';

class AppChannels {
  MethodChannel _commonChannel;
  static AppChannels _instance;


  AppChannels._() {
    _commonChannel = const MethodChannel(PlatformChannelNames.COMMON_CHANNEL);
  }

  get commonChannel => _commonChannel;

  static AppChannels getInstance() => _instance ??= AppChannels._();
}