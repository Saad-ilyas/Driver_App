import 'package:flutter/material.dart';


class Customdialog{
static Widget showdialog(){
  return CircularProgressIndicator(
     color: Colors.black,
     // size: 50,

   );
}
  void showInSnackBar(String value,BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar( SnackBar(
        content:  Text(value)
    ));
  }
  static void showDialogBox(BuildContext context){
    showDialog(
         barrierDismissible: false,
         context: context, builder: (_){

       return WillPopScope(
           onWillPop: ()=>Future.value(false),
         child: AlertDialog(
           //alignment: Alignment.center,
           insetPadding: EdgeInsets.zero,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
           title: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               CircularProgressIndicator(color: Colors.black,),
               SizedBox(height: 10,),
               Center(child: Text( "Please wait...")),
             ],
           ),

         ),
       );
     });
     }
  static void closeDialog(BuildContext context)
  {
    Navigator.pop(context);
  }
static void showBox(BuildContext context,
    String message
    ){
  showDialog(
      barrierDismissible: false,
      context: context, builder: (_){

    return AlertDialog(

      content: Text( message),
      //alignment: Alignment.center,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text( "Message"),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child: Text("ok"),)

      ],


    );
  });
}

}