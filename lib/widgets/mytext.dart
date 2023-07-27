import 'package:flutter/material.dart';
class MyText extends StatelessWidget {
  String text;
  Color? textcolor;
  double? fontSize;
  FontWeight? fontWeight;

  MyText({Key? key,required this.text,this.textcolor,this.fontSize,this.fontWeight,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,style: TextStyle(color:textcolor??Colors.white ,fontSize: fontSize,
        fontWeight: fontWeight,
        overflow: TextOverflow.visible,
        fontFamily: 'UthmanTN',
        decoration:TextDecoration.none ),overflow: TextOverflow.visible,softWrap: true,
    textAlign: TextAlign.center,);
  }
}
