import 'package:flutter/material.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
class AppBarView extends StatelessWidget implements PreferredSizeWidget
{
  final String titleText;
  final bool isAppBackBtnVisible;
  const AppBarView({Key? key, required this.titleText, required this.isAppBackBtnVisible}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return AppBar(
      titleSpacing: 0.0,  //exclude extra space between title and back arrow Icon
      title: isAppBackBtnVisible?Text(titleText):Text("  $titleText"),
      centerTitle: false,
      automaticallyImplyLeading: isAppBackBtnVisible,
    );
  }

  static final _appBar = AppBar();
  @override
  Size get preferredSize => _appBar.preferredSize;
}