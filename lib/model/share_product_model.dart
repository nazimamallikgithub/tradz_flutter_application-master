class ShareProductModel
{
  final bool status;
  final String message;
  final String image_path;

  ShareProductModel({required this.status,required  this.message,required  this.image_path});

  factory ShareProductModel.fromJson(Map<String,dynamic> parsedJson)
  {
    return ShareProductModel(
        status: parsedJson['status']??false,
        message: parsedJson['message']??'',
        image_path: parsedJson['image_path']??''
    );
  }
}