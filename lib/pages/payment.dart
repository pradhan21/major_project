import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'webviewpay.dart';

//import .env file

class CardFromScreen extends StatefulWidget {
  final String secretKey =
      "sk_test_51NNPZVGvjAuWKVBtAKWOAfUdZE7Kh4ea7uhW4NDHp4yD0CvXAv2aEpZBqdxxzMoCjhW9M1T61wgCwpLBDEVST43N00l02uKVyl";
  final String stripePublishableKey =
      "pk_test_51NNPZVGvjAuWKVBt4nen9FtK5T1s1ZaqxJ2OsvMgUGXa1mPRq3bTkEOOtKJIgB3cSyo24Rt7vHQf9OAYahskBM3s00xktbReww";
  @override
  State<CardFromScreen> createState() => _CardFromScreenState();
}

class _CardFromScreenState extends State<CardFromScreen> {
  //   WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey = stripePublishableKey;
  Map<String, dynamic>? paymentIntent;
  // String stripePublishableKey = stripePublishableKey;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credit Card Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text(
            //   "card Form",
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            // const SizedBox(height: 20),
            // CardFormField(
            //   controller: CardFormEditController(),
            // ),
            const Icon(
              Icons.credit_card,
              size: 100,
              color: Colors.amber,
            ),
            ElevatedButton(
              child: const Text("Buy Now"),
              onPressed: () async {
                await makePayment();
              },
            ),
          ],
        ),
      ),
    );
  }

  // //! -----  step 1 Creating payment intent

  // Future<void> payment() async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': 139900,
  //       'currency': 'NPR',
  //       // 'payment_method_types': '[card]',
  //     };
  //     var response = await http.post(
  //       Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //       headers: {
  //         'Authorization':
  //             'Bearer sk_test_51NNPZVGvjAuWKVBtf51J08oYFXLQpqtnJXQFY2DYegcjKlYOxx43QWzYq4KN9V21S02bbg8pfLqi2zOOXxnvitRb00Hh19IW46',
  //         'Content-Type': 'application/x-www-form-urlencoded'
  //       },
  //     );

  //     paymentIntent = json.decode(response.body);
  //   } catch (error) {
  //     throw Exception(error);
  //   }

  //   //! ---- step 2 Intitilizing payment sheet
  //   await Stripe.instance
  //       .initPaymentSheet(
  //         paymentSheetParameters: SetupPaymentSheetParameters(
  //           paymentIntentClientSecret: paymentIntent!['client_secret'],
  //           // applePay: true,
  //           // googlePay: true,
  //           style: ThemeMode.dark,
  //           merchantDisplayName: 'Nischal',
  //         ),
  //       )
  //       .then((value) => {});

  //   //! ----- step 3 Displaying payment sheet
  //   try {
  //     await Stripe.instance.presentPaymentSheet().then((value) => {
  //           print('Payment successful'),
  //         });
  //   } catch (e) {
  //     throw Exception(e);
  //   }
  // }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('139900', 'NPR');

      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "NP", currencyCode: "NPR", testEnv: true);
      // var apay = PaymentSheetApplePay(
      //   merchantCountryCode: "NP",
      // );

      //* --------- STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret:
                paymentIntent!['client_secret'], //from payment intent response
            style: ThemeMode.dark,
            merchantDisplayName: 'Nischal',
            googlePay: gpay,
            // applePay: apay,
          ))
          .then((value) {});

      //* -----------STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      print(err);
      throw Exception(err);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print("Payment Successfully");
      });
    } catch (e) {
      print('$e');
      // throw Exception(e);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    // var response_12 = await http.get(
    //   Uri.parse('http://localhost:8000/'),
    // );
    // print(response_12.body);
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      // Map<String, dynamic> body1 = {};

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${widget.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
