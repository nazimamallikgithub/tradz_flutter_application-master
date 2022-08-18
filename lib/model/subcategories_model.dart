import 'package:tradz/model/categories_model.dart';

class SubCategoriesModel
{
  List<SubCategoriesTradz> sub_categories;

  SubCategoriesModel({required this.sub_categories});
  factory SubCategoriesModel.fromJson(Map<String, dynamic> parsedJSon)
  {
    var list=parsedJSon['sub_categories'] as List;
    List<SubCategoriesTradz> subCategoriesList=list.map((i) => SubCategoriesTradz.fromJson(i)).toList();
    return SubCategoriesModel(
        sub_categories: subCategoriesList
    );
  }
}

class SubCategoriesTradz
{
  int id;
  int category_id;
  String text;
  String icon_path;
  String image_blob;
  String created_at;
  String updated_at;

  SubCategoriesTradz(
      {required this.id,required this.category_id,required this.text,required this.created_at,required this.updated_at,required this.icon_path,required this.image_blob});

  factory SubCategoriesTradz.fromJson(Map<String, dynamic> parsedJSon)
  {
    return SubCategoriesTradz(
        id: parsedJSon['id'] as int,
        category_id: parsedJSon['category_id'],
        text: parsedJSon['text']??'',
        icon_path: parsedJSon['icon_path']??'',
        image_blob: parsedJSon['image_blob']??'',
        created_at: parsedJSon['created_at']??'',
        updated_at: parsedJSon['updated_at']??''
    );
  }
}