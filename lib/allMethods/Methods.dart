import 'dart:io';

import 'package:tradz/app_screens/product_details_screen.dart';
import 'package:flutter/material.dart';
class Methods
{
  static void getCallNavigation(ProductDetailsScreen productDetailsScreen) {
    
  }

  static void getCallSnackBar(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
     return false;
    }
  }


  
}