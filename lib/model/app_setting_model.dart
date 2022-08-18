import 'package:flutter/material.dart';
class AppSettingModel
{
  final bool status;
  final AppSettings settings;

  AppSettingModel({required this.status,required this.settings});

  factory AppSettingModel.fromJson(Map<String, dynamic> parsedJson)
  {
    return AppSettingModel(
        status: parsedJson['status']??false,
        settings: AppSettings.fromJson(parsedJson['settings'])
    );
  }
}
class AppSettings {
  final List<ReportRadioMessage> report_radio_message;
  final List<SliderMinMax> slider_min_max;
  final List<AddImages> add_images;


  AppSettings({required this.report_radio_message,required this.slider_min_max,required this.add_images});

  factory AppSettings.fromJson(Map<String, dynamic> parsedJson)
  {
    var sliderlist=parsedJson['slider_min_max'] as List;
    List<SliderMinMax> sliderMinMaxList=sliderlist.map((i) => SliderMinMax.fromJson(i)).toList();
    var list=parsedJson['report_radio_message'] as List;
    List<ReportRadioMessage> reportRadioList=list.map((i) => ReportRadioMessage.fromJson(i)).toList();
    var addImages=parsedJson['add_images'] as List;
    List<AddImages> addImagesList=addImages.map((i) => AddImages.fromJson(i)).toList();
    return AppSettings(
        report_radio_message: reportRadioList,
        slider_min_max: sliderMinMaxList,
        add_images: addImagesList
    );
  }
}

class AddImages
{
  final String value;

  AddImages({required this.value});

  factory AddImages.fromJson(Map<String, dynamic> parsedjson)
  {
    return AddImages(value: parsedjson['value']);
  }
}

class ReportRadioMessage {
  final int id;
  final String message;
  final String value;
  ReportRadioMessage({required this.id,required this.message,required this.value});

  factory ReportRadioMessage.fromJson(Map<String, dynamic> parsedJson)
  {
    return ReportRadioMessage(
      id:parsedJson['id'] as int,
        message: parsedJson['message']??'',
      value: parsedJson['value']??''
    );
  }
}
class SliderMinMax
{
  final String value;

  SliderMinMax({required this.value});

  factory SliderMinMax.fromJson(Map<String, dynamic> parsedJson)
  {
    return SliderMinMax(
        value: parsedJson['value']
    );
  }
}