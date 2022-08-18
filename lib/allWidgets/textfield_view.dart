import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
class TextFieldView extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final bool boolValue,isPrefixText,isSuffixIcon;
  final int maxLinesValue;
  final String hintText;

  const TextFieldView({Key? key,
    required this.controller,
    required this.validator,
    required this.hintText,
    required this.keyboardType,required this.boolValue, required this.maxLinesValue, required this.isPrefixText,required this.isSuffixIcon}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
          keyboardType: keyboardType,
          inputFormatters: isPrefixText?<TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ]:null,
          controller: controller,
          enabled: boolValue,
          maxLines: maxLinesValue,
          maxLength: maxLinesValue==6?250:null,
         maxLengthEnforcement: maxLinesValue==6?MaxLengthEnforcement.enforced:null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(8),
            fillColor: Colors.white,
            hintText: hintText.isNotEmpty?hintText:null,
            prefixText: isPrefixText?Strings.currency_rupee:null,
            suffixIcon: isSuffixIcon?const Icon(Icons.location_on_sharp):null,
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Colors.grey, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: validator),
    );
  }
}