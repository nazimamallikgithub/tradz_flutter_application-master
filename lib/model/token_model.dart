import 'package:flutter/material.dart';
class TokenModel
{
  final String status;
  final String message;
  final String? token;

  TokenModel( { required this.status,required  this.message,required this.token });

  factory TokenModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return TokenModel(
      status: parsedJson['status']??'',
        message: parsedJson['message']??'',
        token: parsedJson['token']??''
    );
  }
}