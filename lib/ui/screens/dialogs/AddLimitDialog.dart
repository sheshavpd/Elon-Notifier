import 'package:cached_network_image/cached_network_image.dart';
import 'package:elon_notifier/bloc/limit/limit_bloc.dart';
import 'package:elon_notifier/models/LimitAlarm.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class AddLimitDialog extends StatefulWidget {
  @override
  _AddLimitDialogState createState() => _AddLimitDialogState();
}

class _AddLimitDialogState extends State<AddLimitDialog> {
  TextEditingController _controller;
  LimitBloc _limitBloc;
  String _selectedSymbol;
  double _currentCurrenctVal = -1;

  @override
  void initState() {
    super.initState();
    _limitBloc = BlocProvider.of<LimitBloc>(context)..add(LoadCoinInfo());
    _controller = TextEditingController();
  }

  _currencyChanged(String symbol) {
    final curState = _limitBloc.state as LimitInitial;
    final curValue = curState.coinValues[symbol] ?? -1;
    setState(() {
      _currentCurrenctVal = curValue;
      _selectedSymbol = symbol;
    });
  }

  bool _addAlarm() {
    if (_selectedSymbol == null || _selectedSymbol.isEmpty) {
      return false;
    }
    try {
      final limitPrice = double.parse(_controller.text);
      if (limitPrice.isNaN) {
        return false;
      }
      _limitBloc.add(AddNewLimit(LimitAlarm(
          symbol: _selectedSymbol,
          enabled: true,
          limit: limitPrice,
          lowerLimit: limitPrice < _currentCurrenctVal)));
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  List<DropdownMenuItem<String>> _getDropDownItems(LimitInitial state) {
    return state.coinIcons.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: entry.value,
              width: 30,
              placeholder: (context, url) => SizedBox(),
              errorWidget: (context, url, error) => Icon(Icons.circle),
            ),
            SizedBox(
              width: 10,
            ),
            Text(entry.key.toUpperCase())
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0,
      backgroundColor: AppColors.secondaryBgColor,
      child: Container(
        padding: EdgeInsets.only(left: 15, bottom: 15, right: 15),
        child: _contentBox(context),
      ),
    );
  }

  Widget _cancelBtn() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text("Cancel"),
    );
  }

  Widget _okBtn() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text("OK"),
    );
  }

  _contentBox(BuildContext context) {
    return BlocBuilder<LimitBloc, LimitState>(
      builder: (context, state) {
        if (state is LimitLoadingCurrencies) {
          return Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Loading currency prices..", textAlign: TextAlign.center,)
              ],
            ),
          );
        }
        if (state is LimitLoadingError) {
          return Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error loading currency prices. Check your network and try again."),
                SizedBox(height: 10),
                _okBtn()
              ],
            ),
          );
        }
        final curState = state as LimitInitial;
        if (curState.coinIcons.length == 0) {
          return Container(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Some error occured. Please report this to the developer."),
                SizedBox(height: 10),
                _okBtn()
              ],
            ),
          );
        }

        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black.withOpacity(0.3)),
                child: Column(
                  children: [
                    SearchableDropdown.single(
                        items: _getDropDownItems(curState),
                        value: _selectedSymbol,
                        hint: "Select coin",
                        searchHint: null,
                        onChanged: _currencyChanged,
                        dialogBox: true,
                        isExpanded: true),
                    _currentCurrenctVal == -1
                        ? SizedBox()
                        : Container(
                            child: Text(
                                "Price: " + _currentCurrenctVal.toString(),
                                style:
                                    TextStyle(color: AppColors.primaryColor)),
                          )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  labelText: 'Limit Price',
                  hintStyle: TextStyle(fontSize: 12),
                  hintText: 'Enter price to trigger the alarm',
                ),
                maxLines: 1,
                controller: _controller,
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        _cancelBtn(),
                  ElevatedButton(
                    onPressed: () {
                      if(_addAlarm())
                        Navigator.pop(context);
                    },
                    child: Text("Add Alarm"),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
