import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripePayment {
  Future<bool> makePayment(String amount) async {
    Map<String, dynamic>? paymentIntent;

    var result = false;
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      var gpay = PaymentSheetGooglePay(
          merchantCountryCode: "US", currencyCode: "USD", testEnv: true);

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret:
                  paymentIntent!['client_secret'], //Gotten from payment intent
              style: ThemeMode.light,
              merchantDisplayName: 'Justin',
              // applePay: PaymentSheetApplePay(merchantCountryCode: "+92"),

              googlePay: gpay));

      //STEP 3: Display Payment sheet
      result = await displayPaymentSheet();

      return result;
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<bool> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print("Payment Successfully");
      });
      return true;
    } catch (e) {
      print('$e');
      return false;
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51MPPCnGWLLYsWJjCMVl1kXWO8TypMfpU3x86X9dNwQ6C8LKNawda8jdcP3qsR9R2uGhWnXynZ2remaPKqBywxDTj00KjZAj0SC',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}
