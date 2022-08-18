import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allWidgets/CircularProgressScreen.dart';
import 'package:tradz/allWidgets/appbar_view.dart';
import 'package:tradz/allWidgets/text_button_view.dart';
import 'package:tradz/api/api_methods.dart';
import 'package:tradz/model/categories_model.dart';
import 'package:tradz/model/subcategories_model.dart';
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({Key? key}) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  bool _isProgressBar = false;
  bool _isSubCategoryButtonEnabled=true;
  bool _isCategoryListViewActive=true;
  ScrollController _controller= ScrollController();
  late CategoriesModel categoriesModel;
  List<Categories> tradzCategory = [];
  List<SubCategoriesTradz> tradzSubCategory = [];
  late SubCategoriesModel subCategoriesModel;
  static int _len = 10;
  List<int> selectedCategory=[];
  List<int> selectedSubCategories=[];
  late List<bool> _isCategoryValueChecked,_isSubCategoryValueChecked;

  @override
  void initState() {
    _isCategoryValueChecked=List<bool>.filled(tradzCategory.length, false);
    _isSubCategoryValueChecked=List<bool>.filled(tradzSubCategory.length, false);
    getCallCategories();
    super.initState();
  }

  void getCallCategories() async {
    tradzCategory.clear();
    setState(() {
      _isProgressBar = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(Strings.google_token);
    if (kDebugMode) {
      print("token value is $token");
    }
    try {
      API.getCategories(token).then((response) {
        int statusCode = response.statusCode;
        if (kDebugMode) {
          print("the response is ${response.body}");
        }
        if (statusCode == 200) {
          categoriesModel =
              CategoriesModel.fromJson(json.decode(response.body));
          tradzCategory.addAll(categoriesModel.categories);
          setState(() {
            _isCategoryValueChecked=List<bool>.filled(tradzCategory.length, false);
            _isProgressBar = false;
          });
        } else {
          setState(() {
            _isProgressBar = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isProgressBar = false;
      });
      if (kDebugMode) {
        print("Exception in getCategories is $e");
      }
    }
  }

  void getCallSubCategories(int? value, int i) async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(Strings.google_token);
      API.getSubCategories(token, value.toString()).then((response) {
        int statusCode = response.statusCode;
        print("response of subcat is ${response.body}");
        if (statusCode == 200|| statusCode==201) {
          setState(() {
            subCategoriesModel =
                SubCategoriesModel.fromJson(json.decode(response.body));
            tradzSubCategory.addAll(subCategoriesModel.sub_categories);
            _isSubCategoryValueChecked=List<bool>.filled(tradzSubCategory.length, false);
            if(i==selectedCategory.length-1)  //check if forloop end thereafter progressbar set false;
            {
              setState(() {
                _isProgressBar=false;
              });
            }
          });
        }
        else{
          setState(() {
            _isProgressBar = true;
          });
        }
      });
    }
    catch(e)
    {
      if (kDebugMode) {
        print('exception is $e');
      }
      setState(() {
        _isProgressBar = true;
      });
    }
  }

  void getCallExtractCategoriesID() async{

    for(int i=0;i<selectedCategory.length;i++)
      {
        setState(() {
          _isProgressBar=true;
        });
        getCallSubCategories(selectedCategory[i],i);
        print("The value of i is $i");
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(isAppBackBtnVisible: true, titleText: Strings.searchFilter,),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                  child: Container(
                    color: Colors.white24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButtonView(text: Strings.category,
                            voidCallback: (){
                          setState(() {
                            _isCategoryListViewActive=true;
                          });
                            }
                        ),
                        TextButtonView(text: Strings.subCategory,
                            voidCallback: (){
                              setState(() {
                                _isCategoryListViewActive=false;
                              });
                              if(selectedCategory.isNotEmpty && _isSubCategoryButtonEnabled)
                                {
                                  if(!mounted)return;
                                  setState(() {
                                    _isSubCategoryButtonEnabled=false;
                                  });
                                  getCallExtractCategoriesID();
                                }

                            }
                        ),
                      ],
                    ),
                  )
              ),
              Expanded(
                flex: 2,
                  child:
                  _isCategoryListViewActive?
                  ListView.builder(
                      padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      itemCount:tradzCategory.isNotEmpty?tradzCategory.length:0,
                      itemBuilder: (BuildContext context, int index)
                      {
                        final model=tradzCategory[index];
                        return CheckboxListTile(
                            title: Text(model.text),
                            secondary: model.image_blob.isNotEmpty?Image.memory(base64Decode(model.image_blob)):null,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _isCategoryValueChecked[index],
                           activeColor: ConstantColors.primaryColor,
                            checkColor: Colors.white,
                            onChanged: (bool? value)
                            {
                              if (kDebugMode) {
                                print("check bool value is $value\n the id of category ${model.text} is ${model.id}");
                              }
                              setState(() {
                                _isCategoryValueChecked[index]=value!;
                                if(value)
                                  {
                                    selectedCategory.add(model.id);
                                    setState(()
                                    {
                                      tradzSubCategory.clear();
                                      selectedSubCategories.clear();
                                      _isSubCategoryButtonEnabled=true;  //At first _isSubCategoryButtonEnabled always true but after that   SubCategoryAPI call enabled only when this bool value true and it is true only if selectedCategroy array updated.
                                    });
                                    if (kDebugMode) {
                                      print("selected category after addition  is $selectedCategory \n the length is ${selectedCategory.length}");
                                    }
                                  }
                                else
                                  {
                                  selectedCategory.removeWhere((item) => item== model.id);
                                  setState(()
                                  {
                                    tradzSubCategory.clear();
                                    selectedSubCategories.clear();
                                    _isSubCategoryButtonEnabled=true;  //At first _isSubCategoryButtonEnabled always true but after that   SubCategoryAPI call enabled only when this bool value true and it is true only if selectedCategroy array updated.
                                  });
                                  print("selected category after subtraction is $selectedCategory");
                                }
                              });
                            }
                        );
                      }
                  )
                      :
                  ListView.builder(
                      padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      itemCount:tradzSubCategory.isNotEmpty?tradzSubCategory.length:0,
                      itemBuilder: (BuildContext context, int index)
                      {
                        final model=tradzSubCategory[index];
                        return CheckboxListTile(
                            title: Text(model.text),
                            secondary: model.image_blob.isNotEmpty?Image.memory(base64Decode(model.image_blob)):null,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: _isSubCategoryValueChecked[index],
                            activeColor: ConstantColors.primaryColor,
                            checkColor: Colors.white,
                            onChanged: (bool? value)
                            {
                              if (kDebugMode) {
                                print("check bool value is $value\n the id of category ${model.text} is ${model.id}");
                              }
                              setState(() {
                                _isSubCategoryValueChecked[index]=value!;
                                if(value)
                                {
                                  selectedSubCategories.add(model.id);
                                  print("selectedSubCategories after addition  is $selectedSubCategories");
                                }
                                else{
                                  selectedSubCategories.removeWhere((item) => item== model.id);
                                  print("selected category after subtraction is $selectedSubCategories");
                                }
                              });
                            }
                        );
                      }
                  )
              )
            ],
          ),
          Visibility(
            child: const CircularProgressScreen(),
            visible: _isProgressBar,
          )
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: ()
        {
          String value="$selectedCategory|$selectedSubCategories";
          Navigator.of(context).pop(value);
        },
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        child: Text(Strings.apply),
      ),
    );
  }
}
