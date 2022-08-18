import 'package:flutter/material.dart';
class ReportProductResponseModel
{
  final bool status;
  final String message;

  ReportProductResponseModel({required this.status, required this.message});

  factory ReportProductResponseModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return ReportProductResponseModel(
      status: parsedJson['status'],
      message: parsedJson['message']??''
    );
  }
}