import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../widgets/progress_dialog.dart';
import 'car_info_screen.dart';
import 'login_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late bool _passwordVisible;
  @override
  void initState() {
    _passwordVisible = false;
  }
  TextEditingController nametextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController agetextEditingController = TextEditingController();
  TextEditingController gendertextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  TextEditingController confirmpasswordtextEditingController =
      TextEditingController();
  TextEditingController phonenumbercontroller = TextEditingController();
  TextEditingController cartypecontroller = TextEditingController();
  TextEditingController carnumbertextcontroller = TextEditingController();
  TextEditingController carcolortextEditingController = TextEditingController();
  TextEditingController carmodeltextEditingController = TextEditingController();
  validateForm() {
    if (nametextEditingController.text.length < 5) {
      Fluttertoast.showToast(msg: "Name must be atleast 5 Characters.");
    } else if (!emailtextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email address is not Valid.");
    } else if (agetextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Age is required.");
    } else if (passwordtextEditingController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be atleast 6 Characters.");
    } else if (confirmpasswordtextEditingController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password donot match.");
    } else if (passwordtextEditingController.text !=
        confirmpasswordtextEditingController.text) {
      Fluttertoast.showToast(msg: "Password donot match.");
    } else if (phonenumbercontroller.text.length < 11) {
      Fluttertoast.showToast(msg: "Wrong phone number.");
    } else {
      savedriverinfonow();
    }
  }

  savedriverinfonow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(
            message: "Processing! Please Wait",
          );
        });
    final User? firebaseuser = (await fAuth
            .createUserWithEmailAndPassword(
      email: emailtextEditingController.text.trim(),
      password: passwordtextEditingController.text.trim(),
    )
            .catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error" + msg.toString());
    }))
        .user;
    if (firebaseuser != null) {
      Map drivermap = {
        "id": firebaseuser.uid,
        "name": nametextEditingController.text.trim(),
        "email": emailtextEditingController.text.trim(),
        "age": agetextEditingController.text.trim(),
        "password": passwordtextEditingController.text.trim(),
        "gender": gendertextEditingController.text,
        "phone": phonenumbercontroller.text.trim(),
      };
      DatabaseReference driversRef =
          FirebaseDatabase.instance.ref().child("Driver");
      driversRef.child(firebaseuser.uid).set(drivermap);

      currentFirebaseUser = firebaseuser;
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has been created");

      Navigator.push(
          context, MaterialPageRoute(builder: (c) => CarInfoScreen()));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been created");
    }
  }
  String dropdownvalue = 'Male';

  // List of items in our dropdown menu
  var items = [
    'Male',
    'Female',
  ];
  void gotologinpage() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => Login()));
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueGrey[900],
          elevation: 0,
          bottom: TabBar(
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(5), // Creates border
                color:
                    Colors.blueGrey[700]), //Change background color from here
            tabs: [
              Tab(
                text: 'Sign up as a driver',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
// signup as driver module
            //upload picture
            ListView(
              padding: EdgeInsets.all(20),
              children: <Widget>[
                CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: Colors.blueGrey[700],
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Upload Picture',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //Name
                    Container(
                      width: 350,
                      height: 40,
                      child: TextField(
                        controller: nametextEditingController,
                        decoration: InputDecoration(
                          hintText: 'Name*',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.black54,
                            size: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    //Age
                    Container(
                      width: 350,
                      height: 40,
                      child: TextField(
                        controller: agetextEditingController,
                        decoration: InputDecoration(
                          hintText: 'Age*',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          prefixIcon: Icon(
                            Icons.add,
                            color: Colors.black54,
                            size: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    //Phone Number
                    Container(
                      width: 350,
                      height: 40,
                      child: TextField(
                        controller: phonenumbercontroller,
                        decoration: InputDecoration(
                          hintText: 'Phone Number*',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          prefixIcon: Icon(
                            Icons.phone_android,
                            color: Colors.black54,
                            size: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    //email
                    Container(
                      width: 350,
                      height: 40,
                      child: TextField(
                        controller: emailtextEditingController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.black54,
                            size: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    //password
                    Container(
                      width: 350,
                      height: 40,
                      child: TextField(
                        controller: passwordtextEditingController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password*',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              // Update the state i.e. google the state of passwordVisible variable
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.password_outlined,
                            color: Colors.black54,
                            size: 18,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    //confirmpassword
                    Container(
                      width: 350,
                      height: 40,
                      child: TextField(
                        controller: confirmpasswordtextEditingController,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password*',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              // Update the state i.e. toogle the state of passwordVisible variable
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.password_outlined,
                            color: Colors.black54,
                            size: 18,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blueGrey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.cyan,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    //Gender
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Gender*',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          DropdownButton(
                            dropdownColor: Colors.blueGrey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            // Initial Value
                            value: dropdownvalue,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                            // Down Arrow Icon
                            icon: const Icon(Icons.keyboard_arrow_down),
                            // Array list of items
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            // After selecting the desired option,it will
                            // change button value to selected value
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownvalue = newValue!;
                                gendertextEditingController.text =
                                    dropdownvalue;
                                // newvalue convert into gender controller and store in database
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 70.0),
                        child: GestureDetector(
                          onTap: validateForm,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[800],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already registered! ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: gotologinpage,
                              child: Text(
                                'Login now',
                                style: TextStyle(
                                  color: Colors.deepOrange[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
