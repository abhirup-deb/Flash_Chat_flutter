import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({this.clr,this.txt,@required this.onPressed});

  final Color clr;
  final Function onPressed;
  final String txt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: clr,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(txt),
        ),
      ),
    );
  }
}
