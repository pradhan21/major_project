import 'dart:convert';
import 'package:advisor_ui/core/route/app_route_name.dart';
import 'package:advisor_ui/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:advisor_ui/pages/root_app.dart';
import 'package:flutter/material.dart';
import 'package:advisor_ui/core/component/dialog/loading_dialog.dart';
import 'package:advisor_ui/core/theme/app_color.dart';
import 'package:rive/rive.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSigningUp = false; // track whether to login or signin.
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  // final List<User> _users = [];

  /// input form controller
  FocusNode emailFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();

  FocusNode passwordFocusNode = FocusNode();
  TextEditingController passwordController = TextEditingController();

  FocusNode fnameFocusNode = FocusNode();
  TextEditingController fnameController = TextEditingController();

  FocusNode lnameFocusNode = FocusNode();
  TextEditingController lnameController = TextEditingController();

  FocusNode usernameFocusNode = FocusNode();
  TextEditingController usernameController = TextEditingController();

  FocusNode contactFocusNode = FocusNode();
  TextEditingController contactController = TextEditingController();

  FocusNode dobFocusNode = FocusNode();
  TextEditingController dobController = TextEditingController();

  FocusNode confirmpasswordFocusNode = FocusNode();
  TextEditingController confirmpasswordController = TextEditingController();

  /// rive controller and input
  StateMachineController? controller;

  SMIInput<bool>? isChecking;
  SMIInput<double>? numLook;
  SMIInput<bool>? isHandsUp;

  SMIInput<bool>? trigSuccess;
  SMIInput<bool>? trigFail;

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(emailFocus);
    passwordFocusNode.addListener(passwordFocus);
    contactFocusNode.addListener(contactFocus);
    _googleSignIn.signInSilently();
    dobFocusNode.addListener(dobFocus);
    fnameFocusNode.addListener(fnameFocus);
    lnameFocusNode.addListener(lnameFocus);
    usernameFocusNode.addListener(usernameFocus);
    confirmpasswordFocusNode.addListener(confirmFocus);
    dobController.text = "";
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(emailFocus);
    fnameFocusNode.removeListener(fnameFocus);
    lnameFocusNode.removeListener(lnameFocus);
    usernameFocusNode.removeListener(usernameFocus);
    passwordFocusNode.removeListener(passwordFocus);
    contactFocusNode.removeListener(contactFocus);
    confirmpasswordFocusNode.removeListener(confirmFocus);
    dobFocusNode.removeListener(dobFocus);
    super.dispose();
  }

  void emailFocus() {
    isChecking?.change(emailFocusNode.hasFocus);
  }

  void passwordFocus() {
    isHandsUp?.change(passwordFocusNode.hasFocus);
  }

  void contactFocus() {
    isChecking?.change(contactFocusNode.hasFocus);
  }

  void lnameFocus() {
    isChecking?.change(lnameFocusNode.hasFocus);
  }

  void fnameFocus() {
    isChecking?.change(fnameFocusNode.hasFocus);
  }

  void usernameFocus() {
    isChecking?.change(usernameFocusNode.hasFocus);
  }

  void dobFocus() {
    isChecking?.change(dobFocusNode.hasFocus);
  }

  void confirmFocus() {
    isHandsUp?.change(dobFocusNode.hasFocus);
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Use the GoogleAuth credentials to authenticate with your backend server
      // and perform any necessary operations.
      // String accessToken = googleAuth.accessToken!;
      // String idToken = googleAuth.idToken!;

      // TODO: Implement your logic here for successful sign-in.
    } catch (error) {
      // Handle sign-in errors
      print('Sign-In Error: $error');
    }
  }

  // void Signup() {
  //   final String username = emailController.text;
  //   final String password = passwordController.text;
  //   int contact = int.tryParse(contactController.text) ?? 0;

  //   // Create a new user and add it to the list
  //   final User newUser = User(username: username, password: password, contact: contact);
  //   _users.add(newUser);

  //   // Clear the text fields

  //   setState(() {
  //     _isSigningUp = false;
  //   });

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Success'),
  //         content: const Text('Signup successful!'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void Signup() async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmpassword = confirmpasswordController.text;
    final String dob = dobController.text;
    final String fname = fnameController.text;
    final String lname = lnameController.text;
    final String username = usernameController.text;
    int contact = int.tryParse(contactController.text) ?? 0;
    print(email);
    print(password);
    print(confirmpassword);
    print(dob);
    print(fname);
    print(lname);
    print(username);
    print(contact);
    print(isChecked ? 'True' : 'false');
    // Create a new user and add it to the list
    // final User newUser = User(email:email,username: username, password: password, contact: contact);
    // _users.add(newUser);

    // Clear the text fields
    // emailController.clear();
    // passwordController.clear();
    // contactController.clear();

    // Make an HTTP request to the backend server
    // final url = 'http://127.0.0.1:8000/api/user/register/';
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/user/register/'),
      body: <String, String>{
        'email': email,
        'username': username,
        'fName': fname,
        'lName': lname,
        'date_of_birth': dob,
        'tc': isChecked
            ? 'True'
            : 'false', // Conditionally set the value based on isChecked
        'phone': contact.toString(), // Convert the int value to a String,
        'password': password,
        'password2': confirmpassword,
      },
    );

    if (response.statusCode == 201) {
      final responseBody = response.body;
      print(responseBody);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Signup successful!'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Error at creating user. Please go through the details again.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                   _isSigningUp = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      print('Request failed with status: ${response.statusCode}');
      final responseBody = response.body;
      print(responseBody);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Signup failed. Please try again.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, AppRouteName.home);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

//  Future<void> login() async {
//     emailFocusNode.unfocus();
//     passwordFocusNode.unfocus();

//    final String username = emailController.text;
//     final String password = passwordController.text;

//     showLoadingDialog(context);
//     await Future.delayed(
//       const Duration(milliseconds: 2000),
//     );
//     if (mounted) Navigator.pop(context);

//     // Find the user in the list based on the username
//     User? user;
//     try {
//       user = _users.firstWhere((user) => user.username == username);
//       if (username == user.username && password == user.password) {
//       trigSuccess?.change(true);
//     Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => RootApp()),
//         );

//     } else {
//       trigFail?.change(true);
//     }
//     } catch (e) {
//       user = null;
//     }

//   }

  Future<void> login() async {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();

    final String username = emailController.text;
    final String password = passwordController.text;

    showLoadingDialog(context);
    await Future.delayed(
      const Duration(milliseconds: 100),
    );
    if (mounted) Navigator.pop(context);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/user/login/'),
        body: <String, String>{
          'email': username,
          'password': password,
        },
      );
      print(username);
      print(password);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final accessToken = responseData['token']['access'];
        // final refreshToken = token['refresh'];
        // print(refreshToken);
        if (accessToken != null) {
          navigateToRootApp(accessToken);
        } else {
          // Handle the case when refreshToken is null
          // For example, show an error message or navigate to a different page
          print('Refresh token is null');
        }
        navigateToRootApp(accessToken!);
      } else if (response.statusCode == 404) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Email or password is not valid'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        trigFail?.change(true);
        // Handle other status codes or errors
      }
    } catch (error) {
      // Handle network or connection errors
      print('Error: $error');
    }
  }

  void navigateToRootApp(String accessToken) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => RootApp(accessToken: accessToken)),
      );
    });
  }

  bool isChecked = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    print("Build Called Again");
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 233, 227, 227),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Image.asset(
                "assets/output-onlinepngtools.png", height: 200,
                fit: BoxFit.fill,// This will make the image fit within the container
              ),
            // Container(
            //   height: 110,
            //   width: 170,
            //   padding: const EdgeInsets.only(left:8),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     shape: BoxShape.circle,
            //   ),
            //   child: Image.asset(
            //     "assets/output-onlinepngtools.png",
            //     fit: BoxFit.fill,// This will make the image fit within the container
            //   ),
            // ),
            const SizedBox(height: 10),
            Text(
              "Wallet Wizard",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 200,
              width: 350,
              child: RiveAnimation.asset(
                "assets/3645-7621-remix-of-login-machine.riv",
                fit: BoxFit.fitHeight,
                stateMachines: const ["Login Machine"],
                onInit: (artboard) {
                  controller = StateMachineController.fromArtboard(
                    artboard,

                    /// from rive, you can see it in rive editor
                    "Login Machine",
                  );
                  if (controller == null) return;

                  artboard.addController(controller!);
                  isChecking = controller?.findInput("isChecking");
                  numLook = controller?.findInput("numLook");
                  isHandsUp = controller?.findInput("isHandsUp");
                  trigSuccess = controller?.findInput("trigSuccess");
                  trigFail = controller?.findInput("trigFail");
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      focusNode: emailFocusNode,
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Email",
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (value) {
                        numLook?.change(value.length.toDouble());
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        TextField(
                          focusNode: passwordFocusNode,
                          controller: passwordController,
                          obscureText: !showPassword,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                          onChanged: (value) {},
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: showPassword,
                              onChanged: (value) {
                                setState(() {
                                  showPassword = value!;
                                });
                              },
                            ),
                            Text('Show Password'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Visibility(
                    visible: _isSigningUp,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                focusNode: confirmpasswordFocusNode,
                                controller: confirmpasswordController,
                                obscureText: !showConfirmPassword,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Confirm Password",
                                ),
                                style: Theme.of(context).textTheme.bodyMedium,
                                onChanged: (value) {},
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: showConfirmPassword,
                                    onChanged: (value) {
                                      showConfirmPassword = value!;
                                      setState(() {});
                                    },
                                  ),
                                  Text('Show Password'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                focusNode: fnameFocusNode,
                                controller: fnameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "First Name",
                                ),
                                // obscureText: true,
                                style: Theme.of(context).textTheme.bodyMedium,
                                onChanged: (value) {
                                  numLook?.change(value.length.toDouble());
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                focusNode: lnameFocusNode,
                                controller: lnameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Last Name",
                                ),
                                // obscureText: true,
                                style: Theme.of(context).textTheme.bodyMedium,
                                onChanged: (value) {
                                  numLook?.change(value.length.toDouble());
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                focusNode: usernameFocusNode,
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Username",
                                ),
                                // obscureText: true,
                                style: Theme.of(context).textTheme.bodyMedium,
                                onChanged: (value) {
                                  numLook?.change(value.length.toDouble());
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                keyboardType: TextInputType.number,
                                focusNode: contactFocusNode,
                                controller: contactController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Contact",
                                ),
                                // obscureText: true,
                                style: Theme.of(context).textTheme.bodyMedium,
                                onChanged: (value) {
                                  numLook?.change(value.length.toDouble());
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        //dob,
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(children: [
                            TextField(
                              focusNode: dobFocusNode,
                              controller: dobController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Select Date Of Birth",
                              ),
                              readOnly: true,
                              style: Theme.of(context).textTheme.bodyMedium,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1950),
                                    lastDate: DateTime(2100));
                                if (pickedDate != null) {
                                  print(
                                      pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                  print(
                                      formattedDate); //formatted date output using intl package =>  2021-03-16
                                  setState(() {
                                    dobController.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                } else {}
                              },
                            ),
                          ]),
                        ),
                        SizedBox(height: 10),
                        //dob,
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 8,
                          ),
                          child: Column(children: [
                            CheckboxListTile(
                              title: Text(
                                "I Agree With All Terms And Conditions",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 13,
                                    color: blue),
                              ),
                              checkColor: Colors.white,
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ]
                              //  username ,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isSigningUp ? Signup : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(_isSigningUp ? 'Signup' : 'Login'),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 200,
                      height: 64,
                      child: TextButton(
                        onPressed: () {
                          Navigator.restorablePushNamed(
                              context, AppRouteName.reset);
                        },
                        child: Text("Recover Password"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 64,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSigningUp = !_isSigningUp;
                        });
                      },
                      child: Text(_isSigningUp
                          ? 'Already have an account? HomeScreen'
                          : 'Don\'t have an account? Signup'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Visibility(
                      visible: _isSigningUp,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 64,
                        child: TextButton(
                          onPressed: signInWithGoogle,
                          child: Text('Sign in with Google'),
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class User {
  final String username;
  final String password;
  final int contact;
  User({required this.username, required this.password, required this.contact});
}
