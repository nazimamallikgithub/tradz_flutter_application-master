import 'package:flutter/material.dart';
class ViewProvider extends ChangeNotifier
{
  bool isChangeApplied=false;
  late bool _isGridView;
  bool get changeApplied
  {
    if(isChangeApplied)
      {
        return true;
      }
    else{
      return false;
    }
  }

  changeView(bool value) async{
    isChangeApplied=value;
    notifyListeners();
  }



  bool get changeViewApplied
  {
    if(_isGridView)
    {
      return true;
    }
    else{
      return false;
    }
  }
  changeGridView(bool value) async{
    _isGridView=value;
    notifyListeners();
  }


  // bool checkView()
  // {
  //   isGridView=!isGridView;
  //   notifyListeners();
  //   return isGridView;
  // }
}