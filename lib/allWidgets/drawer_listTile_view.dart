import 'package:flutter/material.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
class DrawerListTileView extends StatelessWidget {
  final String itemName;
  final VoidCallback voidCallback;
  const DrawerListTileView({Key? key, required this.itemName, required this.voidCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ListTile(
      leading: const Icon(
        Icons.person,
        color: Colors.black54,
      ),
      title: Text(
        itemName,
        textDirection: TextDirection.rtl,
      ),
      onTap: voidCallback,
    );
  }
}
