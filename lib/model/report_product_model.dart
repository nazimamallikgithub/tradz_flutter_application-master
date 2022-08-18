import 'package:flutter/material.dart';
class ReportProductModel
{
  final int product_id;
  final int radio_message_id;
  final String reason;

  ReportProductModel({required this.product_id,required this.reason,required this.radio_message_id});

  factory ReportProductModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return ReportProductModel(
        product_id: parsedJson['product_id'] as int,
        reason: parsedJson['reason']??'',
        radio_message_id:parsedJson['radio_message_id'] as int
    );
  }

  Map toMap()
  {
    var map=<String,dynamic>{};
    map['product_id']=product_id.toString();
    map['reason']=reason;
    map['radio_message_id']=radio_message_id.toString();
    return map;
  }
}