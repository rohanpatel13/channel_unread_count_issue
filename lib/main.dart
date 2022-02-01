import 'dart:convert';
import 'dart:io';
import 'package:channel_unread_count_issue/channel_list_view.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'models/sign_up_otp_verification_response.dart';
import 'models/sign_up_with_phone_number_response.dart';

void main() {
  runApp(const MyApp());
}

String CONTENT_TYPE = "Content-Type";
String HEADER_TYPE = "application/json";
String USER_AGENT = "user-agent";
String CHALLENGE_NAME = "challengeName";
String CHALLENGE_PARAMETER_USERNAME = "challengeParameterUsername";
String SESSION = "session";
String VERIFICATION_CODE = "verificationCode";
String COGNITO_USERNAME = "cognitoUsername";
String USER_UID = "userUid";
final client = StreamChatClient(
  '53uhmg4kwgef',
  logLevel: Level.OFF,
);


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context,child)=>StreamChat(client: client, child: child),
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Total channel unread count demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool isApiCalling = false;
  String userAgent = "";
  String baseUrl = "https://api-sandbox.dayodating.com/v1/";
  String auth = "auth";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Stack(
            children: [
              Visibility(
                visible: !isApiCalling,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                        onPressed: () {
                          signUpWithPhoneNumber(phoneNumber: "+919265050161");
                        },
                        color: Colors.grey,
                        child: const Text("Sign in with Person 1")),
                    const SizedBox(height: 20,),
                    MaterialButton(
                        onPressed: () {
                          signUpWithPhoneNumber(phoneNumber: "+919265050163");
                        },
                        color: Colors.grey,
                        child: const Text("Sign in with Person 2"))
                  ],
                ),
                replacement: Center(
                  child: Column(
                    children: const [
                      Text("It takes some time"),
                      SizedBox(height: 20,),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              )
            ],
          )
      ),
    );
  }

  // user agent
  Future<String> getUserAgent() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    String packageName = packageInfo.packageName;

    try {
      if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var release = androidInfo.version.release;
        var model = androidInfo.model;
        print(
            "user-agent-----> $packageName/android/$release/$model/$appVersion");
        return "$packageName/android/$release/$model/$appVersion";
      } else if (Platform.isIOS) {
        var iosInfo = await DeviceInfoPlugin().iosInfo;
        var version = iosInfo.systemVersion;
        var model = iosInfo.model;
        print("user-agent-----> $packageName/ios/$version/$model/$appVersion");
        return "$packageName/ios/$version/$model/$appVersion";
      }
    } catch (error) {
      return "";
    }

    return "";
  }

  // sign up
  signUpWithPhoneNumber({required String phoneNumber}) async {
    setState(() {
      isApiCalling = true;
    });
    String postPhoneVerificationURL = baseUrl + auth + "/phone-check";

    userAgent = await getUserAgent();
    try {
      Map<String, String> headers = {
        CONTENT_TYPE: HEADER_TYPE,
        USER_AGENT: userAgent
      };
      Map data = {"phoneNumber": phoneNumber};
      String body = json.encode(data);
      http.Response response =
      await http.post(Uri.parse(Uri.encodeFull(postPhoneVerificationURL)),
          headers: headers, body: body);

      // printLog(response.body);
      if (response.statusCode != 200) {
        print(response.body);
        setState(() {
          isApiCalling = false;
        });
      } else {
        SignUpWithPhoneNumberResponse res = SignUpWithPhoneNumberResponse
            .fromJson(json.decode(response.body));

        signUpOtpVerification(signUpWithPhoneNumberResponse: res,phoneNumber: phoneNumber);

      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
      });
      print(e.toString());
    }
  }

  // Sign Up otp verification
  signUpOtpVerification({
    required SignUpWithPhoneNumberResponse signUpWithPhoneNumberResponse,
    required String phoneNumber,
    }) async {
    String postOTPVerificationURL = baseUrl + auth + "/phone-verify";
    try {
      Map<String, String> headers = {
        CONTENT_TYPE: HEADER_TYPE,
        USER_AGENT: userAgent
      };
      Map<String, dynamic> data = {
        COGNITO_USERNAME: signUpWithPhoneNumberResponse.data.userName,
        VERIFICATION_CODE: signUpWithPhoneNumberResponse.data.secretLoginCode,
        CHALLENGE_NAME: signUpWithPhoneNumberResponse.data.challengeName,
        SESSION: signUpWithPhoneNumberResponse.data.session,
        USER_UID: signUpWithPhoneNumberResponse.data.userUid
      };
      String body = json.encode(data);
      http.Response response =
      await http.post(
          Uri.parse(Uri.encodeFull(postOTPVerificationURL)), headers: headers,
          body: body);

      if (response != null) {
        if (response.statusCode != 200) {
          setState(() {
            isApiCalling = false;
          });
          print(response.body);
        }
        else {
          SignUpOtpVerificationResponse res =  SignUpOtpVerificationResponse.fromJson(json.decode(response.body));

          // stream chat connect user
          await client.connectUser(
            User(id: signUpWithPhoneNumberResponse.data.userUid!,name: res.data.userName),
            res.data.streamToken!,
          );
          setState(() {
            isApiCalling = false;
          });
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>  ChannelView(res: signUpWithPhoneNumberResponse,)), (route) => false);
        }
      }
    } catch (e) {
      setState(() {
        isApiCalling = false;
      });
      print(e.toString());
    }
  }

}
