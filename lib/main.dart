import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razor_pay_application/RazorpayOrderResponse.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Razorpay? razorpay;
  TextEditingController amount = TextEditingController();
  @override
  void initState() {
    razorpay = Razorpay();
    razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlepaymentsuccess);
    razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, handlepaymenterror);
    razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, handleexternalWallet);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    hintText: "Amount"),
              ),
            ),
            ElevatedButton.icon(
                onPressed: () => createOrder(),
                icon: Icon(Icons.arrow_forward_sharp),
                label: Text("PAY"))
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void handlepaymentsuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: 'Payment Successful');
  }

  void handlepaymenterror(PaymentFailureResponse response) async {
    Fluttertoast.showToast(msg: 'Payment failed');
  }

  void handleexternalWallet(ExternalWalletResponse response) async {
    Fluttertoast.showToast(msg: 'Payment Successfully');
  }

  Future<dynamic> createOrder() async {
    var mapHeader = <String, String>{};
    mapHeader['Authorization'] =
        "Basic cnpwX3Rlc3RfU2RHQmFoV3RsS1dNd2I6Mlh2WElOSDlMcG9xTHdyU3F5cDFzam5y";
    mapHeader['Accept'] = "application/json";
    mapHeader['Content-Type'] = "application/x-www-form-urlencoded";
    var map = <String, String>{};
    setState(() {
      map['amount'] = "${(num.parse(amount.text) * 100)}";
    });
    map['currency'] = "INR";
    map['receipt'] = "receipt1";
    print("map $map");
    var response = await http.post(Uri.https('api.razorpay.com', '/v1/orders'),
        headers: mapHeader, body: map);
    print('........' + response.body);
    if (response.statusCode == 200) {
      RazorpayOrderResponse data =
          RazorpayOrderResponse.fromJson(json.decode(response.body));
      openCheckout(data);
    }
  }

  void openCheckout(RazorpayOrderResponse data) async {
    var options = {
      'key': 'rzp_test_mudBilFYdfEbzh',
      'amount':"${num.parse(amount.text)*100}",
      'name' : 'Razorpay Test',
      'description' : '',
      'order_id':'${data.id}',
    };

    try{
      razorpay?.open(options);
    }catch(e){
      debugPrint('Error : $e');
    }
  }
}
