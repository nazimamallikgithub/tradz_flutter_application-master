import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allWidgets/avatar_image_view.dart';
class AvatarImageScreen extends StatefulWidget
{
  const AvatarImageScreen({Key? key}) : super(key: key);

  @override
  State<AvatarImageScreen> createState() => _AvatarImageScreenState();
}

class _AvatarImageScreenState extends State<AvatarImageScreen> {
  String avatarScreenTitle='';
  List<Map> users = [
    {'image': 'assets/images/avatar_icon_one.png'},
    {'image': 'assets/images/avatar_icon_two.png'},
    {'image': 'assets/images/avatar_icon_three.png'},
    {'image': 'assets/images/avatar_icon_four.png'},
    {'image': 'assets/images/avatar_icon_five.png'},
    {'image': 'assets/images/avatar_icon_six.png'},
    {'image': 'assets/images/avatar_icon_seven.png'},
    {'image': 'assets/images/avatar_icon_eight.png'},
    {'image': 'assets/images/avatar_icon_nine.png'},
    {'image': 'assets/images/avatar_icon_ten.png'},
    {'image': 'assets/images/avatar_icon_eleven.png'},
    {'image': 'assets/images/avatar_icon_twelve.png'},
    {'image': 'assets/images/avatar_icon_thirteen.png'},
    {'image': 'assets/images/avatar_icon_fourteen.png'},
    {'image': 'assets/images/avatar_icon_fifteen.png'},
    {'image': 'assets/images/avatar_icon_sixteen.png'},
    {'image': 'assets/images/avatar_icon_seventeen.png'},
    {'image': 'assets/images/avatar_icon_eighteen.png'},
  ];

  @override
  void initState() {
    checkSelectedLanguage();
    super.initState();
  }

  void checkSelectedLanguage()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='hi')
          {
            if(!mounted)return;
            setState(() {
              avatarScreenTitle=Strings.avatarScreenTitle_hi;
            });
          }
        else if(locale=='bn')
          {
            if(!mounted)return;
            setState(() {
              avatarScreenTitle=Strings.avatarScreenTitle_bn;
            });
          }
        else if(locale=='te')
          {
            if(!mounted)return;
            setState(() {
              avatarScreenTitle=Strings.avatarScreenTitle_te;
            });
          }
        else{
          if(!mounted)return;
          setState(() {
            avatarScreenTitle=Strings.avatarScreenTitle;
          });
        }
      }else{
      if(!mounted)return;
      setState(() {
        avatarScreenTitle=Strings.avatarScreenTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(avatarScreenTitle),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(8.0),
      scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: users.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.7,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
              itemBuilder:(BuildContext context, int index) {
                final item = users[index];
                return AvatarImageView(
                  assetImage: item['image'],
                  voidCallBack: ()
                  {
                    Navigator.of(context).pop(item['image']);
                  },
                );
              }
          )
        ],
      ),
    );
  }
}
