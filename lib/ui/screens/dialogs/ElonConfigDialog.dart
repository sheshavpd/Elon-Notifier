import 'package:elon_notifier/bloc/home/home_bloc.dart';
import 'package:elon_notifier/styles/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ElonConfigDialog extends StatefulWidget {
  const ElonConfigDialog({Key key}) : super(key: key);

  @override
  _ElonConfigDialogState createState() => _ElonConfigDialogState();
}

class _ElonConfigDialogState extends State<ElonConfigDialog> {
  TextEditingController _controller;
  HomeBloc _homeBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
    _controller = TextEditingController();
    _controller.text = (_homeBloc.state as HomeLoaded).customElonFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0,
      backgroundColor: AppColors.secondaryColor,
      child: contentBox(context),
    );
  }

  void _save() {
    String filters = _controller.text
        .split(",")
        .map((e) => e.trim())
        .map((e) => e.toLowerCase())
        .join(",");
    _homeBloc.add(ElonConfigChanged(customElonFilters: filters));
  }

  contentBox(context) {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              fillColor: Colors.black.withOpacity(0.3),
              filled: true,
              labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.black.withOpacity(0.2))),
                border: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.black.withOpacity(0.2))),
                hintText: 'Enter filters seperated by comma.',),
            maxLines: 4,
            controller: _controller,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(5)),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                  alignment: Alignment.center,
                  child: Text(
                    "Hint",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.4)),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.orange.shade300,
                    padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
                    child: Text(
                      "abc - contains 'abc'\n"
                      "[xyz] - whole word 'xyz'.",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.4)),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  _save();
                  Navigator.pop(context);
                },
                child: Text("Save"),
              )
            ],
          )
        ],
      ),
    );
  }
}
