import 'package:elon_notifier/common/pretty_print.dart';
import 'package:flutter/foundation.dart';

import 'package:equatable/equatable.dart';

class LimitAlarm extends Equatable {
  final String symbol;
  final double limit;
  final bool lowerLimit;
  final bool enabled;

  LimitAlarm(
      {@required this.symbol, @required this.limit, @required this.lowerLimit, @required this.enabled});

  static LimitAlarm fromJSON(Map pJsonMap) {
    return LimitAlarm(
        symbol: pJsonMap['symbol'],
        limit: pJsonMap['limit'],
        enabled: pJsonMap['enabled'],
        lowerLimit: pJsonMap['lowerLimit']);
  }

  LimitAlarm copyWith({String symbol, String limit, String lowerLimit}) {
    return LimitAlarm(
        symbol: symbol ?? this.symbol,
        limit: limit ?? this.limit,
        enabled: enabled ?? this.enabled,
        lowerLimit: lowerLimit ?? this.lowerLimit);
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'limit': limit,
    'lowerLimit': lowerLimit,
    'enabled': enabled,
  };

  @override
  // TODO: implement props
  List<Object> get props => [this.symbol, this.limit, this.lowerLimit, this.enabled];

  @override
  String toString() {
    return prettyPrint({
      'symbol': this.symbol,
      'limit': this.limit,
      'lowerLimit': this.lowerLimit,
      'enabled': this.enabled
    });
  }
}
