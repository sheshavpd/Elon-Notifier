import 'package:elon_notifier/common/pretty_print.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

class TweetAlarm extends Equatable {
  final String text;
  final String matchReason;
  final bool containsMedia;
  final String url;
  final String id;


  TweetAlarm( {@required this.id, @required  this.containsMedia, @required this.text, @required this.matchReason, @required this.url});

  static TweetAlarm fromJSON(Map pJsonMap) {
    return TweetAlarm(
        text: pJsonMap['text'],
        matchReason: pJsonMap['matchReason'],
        containsMedia: pJsonMap['containsMedia'],
        url: pJsonMap['url'],
        id: pJsonMap['id']
    );
  }

  /*TweetAlarm copyWith({String text, String matchReason, String url}) {
    return TweetAlarm(
        text: text ?? this.text,
        matchReason: matchReason ?? this.matchReason,
        url: url ?? this.url);
  }*/

  @override
  // TODO: implement props
  List<Object> get props => [this.id, this.text, this.matchReason, this.url, this.containsMedia];

  @override
  String toString() {
    return prettyPrint({
      'id': this.id,
      'text': this.text,
      'matchReason': this.matchReason,
      'url': this.url,
      'containsMedia': this.containsMedia
    });
  }
}
