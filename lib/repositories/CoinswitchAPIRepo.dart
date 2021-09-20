import 'dart:convert';
import 'dart:io';

import 'package:elon_notifier/AppConstants.dart';
import 'package:http/http.dart' as http;

class CoinswitchAPIRepo {
  static CoinswitchAPIRepo _instance;


  CoinswitchAPIRepo._(){}


  Future<List> getCoinInfo() async{
    final response = await http.get(Uri.https(COINSWITCH_BASE_URL, 'api/v1/coins'));
    if (response.statusCode == HttpStatus.ok) {
      final coinsList = json.decode(response.body) as List;
      final Map<String, String> coinIconsMap = {};
      final Map<String, double> coinValueMap = {};
      coinsList.forEach((coinInfo) {
        coinIconsMap[coinInfo["symbol"]] = coinInfo["logo"];
        coinValueMap[coinInfo["symbol"]] = coinInfo["cmc_coin"]["rate_inr"];
      });
      return [coinIconsMap, coinValueMap];
    } else {
      throw Exception(
          'Something went wrong. Please try again later.');
    }
  }


  static CoinswitchAPIRepo getInstance() => _instance ??= CoinswitchAPIRepo._();
}