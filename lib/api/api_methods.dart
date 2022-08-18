import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tradz/allConstants/Constant/Constant.dart';
import 'package:tradz/api/http_parameter.dart';
import 'package:tradz/config/config.dart';
import 'package:http/http.dart' as http;

class API {

  //POST API Calls
  static Future postUserProfile(Map map) async {
    var url = Constant.baseurl + HttpParams.API_USER;
    print("the url of postUSer is " + url.toString());
    return await http.post(Uri.parse(url), body: map);
  }

  static Future UpdateUserProfile(Map map, String? token) async {
    var url = Constant.baseurl + HttpParams.API_UPDATE_USER_PROFILE;
    return await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data'
    }, body: map);
  }

  static Future addProduct(Map map, String? token) async
  {
    var url = Constant.baseurl + HttpParams.API_ADD_PRODUCT;
    return await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    }, body: map);
  }

  static Future getCallBlockUser(Map map,String? token) async{
    var url = Constant.baseurl + HttpParams.API_USER_BLOCK;
    return await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    }, body: map);
  }

  static Future getSearchedItem(String? token, Map map, int page) async {
    var url = Constant.baseurl + HttpParams.API_SEARCH +
        HttpParams.API_PAGE_NO + page.toString();
    if (kDebugMode) {
      print("The url is $url and text is $map");
    }
    return await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    }, body: map);
  }

  static Future postFirstLike(Map map, String? token) async
  {
    var url = Constant.baseurl + HttpParams.API_firstLike;
    return await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    }, body: map);
  }

  static Future postUnlike(Map map, String? token) async {
    var url = Constant.baseurl + HttpParams.API_UNLIKE;
    return await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }, body: map);
  }

  static Future postReportUserProduct(Map map, String? token) async
  {
    var url = Constant.baseurl + HttpParams.API_REPORT_PRODUCT;
    return await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }, body: map);
  }

  static Future postCreateChatAPICall(Map map, String? token) async
  {
    var url = Constant.baseurl + HttpParams.API_CREATE_CHAT;
    return await http.post(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }, body: map);
  }


  //Get API Call's

  static Future getCallActiveChat(String? token) async{
    var url = Constant.baseurl + HttpParams.API_GET_ACTIVE_CHAT;
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getCallUnBlockUser(String? token, String userID) async{
    var url = Constant.baseurl + HttpParams.API_USER_UNBLOCK+userID.toString();
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getUserProfile(String? token) async {
    var url = Constant.baseurl + HttpParams.API_GET_USER_PROFILE;
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }
  static Future getCategories(String? token) async {
    var url = Constant.baseurl + HttpParams.API_CATEGORIES;
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getSubCategories(String? token, String? cat_id) async {
    var url = Constant.baseurl + HttpParams.API_SUBCATEGORIES + cat_id!;
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getUserProduct(int page, String? token) async
  {
    var url = Constant.baseurl + HttpParams.API_GET_USER_PRODUCT +
        HttpParams.API_PAGE_NO + page.toString();
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getUserProductDetails(String? token,int productID) async
  {
    var url = Constant.baseurl + HttpParams.API_PRODUCT_DETAILS+productID.toString();
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getUserProductTraded(String? token,int productID) async
  {
    var url = Constant.baseurl + HttpParams.API_USER_PRODUCT_TRADED+productID.toString();
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getUserProductUnTraded(String? token,int productID) async
  {
    var url = Constant.baseurl + HttpParams.API_USER_PRODUCT_UNTRADED+productID.toString();
    return await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
    });
  }

  static Future getMarketPlaceProduct(String? token, int page) async {
    var url = Constant.baseurl + HttpParams.API_GET_MARKETPLACE_ITEMS +
        HttpParams.API_PAGE_NO + page.toString();
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getUserLikedProduct(String? token, int page) async {
    var url = Constant.baseurl + HttpParams.API_USER_LIKED_PRODUCT +
        HttpParams.API_PAGE_NO + page.toString();
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCALLNOTIFICATIONS(String? token, int page) async {
    var url = Constant.baseurl + HttpParams.API_GET_NOTIFICATION +
        HttpParams.API_PAGE_NO + page.toString();
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCALLNOTIFICATIONUSER(String? token, int userID,
      int page) async {
    var url = Constant.baseurl + HttpParams.API_GET_NOTIFICATION_USER +
        userID.toString() + HttpParams.API_PAGE_NO + page.toString();
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCallDistanceAPI(String? token,
      String selectableDropDownValue, String sliderValue) async {
    var url = Constant.baseurl + HttpParams.API_GET_UPDATE_DISTANCE +
        sliderValue + "/" + selectableDropDownValue;
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCallGOInvisible(String? token) async {
    var url = Constant.baseurl + HttpParams.API_GO_INVISIBLE;
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCallGOVisible(String? token) async {
    var url = Constant.baseurl + HttpParams.API_GO_VISIBLE;
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCallDeActivateAccount(String? token) async {
    var url = Constant.baseurl + HttpParams.API_DACTIVATE_ACCOUNT;
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCallDeleteProduct(String? token,int productID) async
  {
    var url = Constant.baseurl + HttpParams.API_DELETE_PRODUCT+productID.toString();
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCallProductShare(String? token,int productID) async
  {
    var url = Constant.baseurl + HttpParams.API_SHARE_PRODUCT+productID.toString();
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }

  static Future getCallAppSetting(String? token) async
  {
    var url = Constant.baseurl + HttpParams.API_APP_SETTINGS;
    return await http.get(Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        }
    );
  }


}
