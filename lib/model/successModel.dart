import 'package:flutter/material.dart';
class SuccessModel
{
  final bool status;
  final String message;

  SuccessModel({required this.status,required this.message});

  factory SuccessModel.fromJson(Map<String, dynamic>parsedJson)
  {
    return SuccessModel(
        status: parsedJson['status']??false,
        message: parsedJson['message']??''
    );
  }
}