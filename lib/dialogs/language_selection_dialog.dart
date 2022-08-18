import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradz/allConstants/Strings/Strings.dart';
import 'package:tradz/allWidgets/helper_widget.dart';
import 'package:translator/translator.dart';
class languageSelectionDialog extends StatefulWidget {
  const languageSelectionDialog({Key? key}) : super(key: key);

  @override
  State<languageSelectionDialog> createState() => _languageSelectionDialogState();
}

class _languageSelectionDialogState extends State<languageSelectionDialog> {
  final translator = GoogleTranslator();
  String title=Strings.languageDialogTitle;
  String ok="OK";
  String cancel="CANCEL";
  String returnValue="";
  ScrollController _controller = ScrollController();
  int value = 0;
  List<Map> selectionList = [
    {'language': Strings.english,'locale':'en'},
    {'language': Strings.hindi,'locale':'hi'},
    {'language': Strings.bengali,'locale':'bn'},
    {'language': Strings.telugu,'locale':'te'},
    {'language': Strings.tamil,'locale':'ta'},
    {'language': Strings.marathi,'locale':'mr'},
    {'language': Strings.gujarati,'locale':'gu'},
    {'language': Strings.urdu,'locale':'ur'},
    {'language': Strings.kannada,'locale':'kn'},
    {'language': Strings.odia,'locale':'or'},

  ];

  @override
  void initState() {
    checkSelectedLanguage();
    super.initState();
  }

  void checkSelectedLanguage() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    String? locale=prefs.getString(Strings.selectedLanguage);
    if(locale!=null)
      {
        if(locale=='en')
          {
           setState(() {
             value=0;
             title=Strings.languageDialogTitle;
             ok="OK";
             cancel="CANCEL";
           });
          }
        else
          {
            if(locale=='hi')
              {
                setState(() {
                  value=1;
                  selectionList = [
                    {'language': 'अंग्रेज़ी','locale':'en'},
                    {'language': 'हिन्दी','locale':'hi'},
                    {'language': 'बंगाली','locale':'bn'},
                    {'language': 'तेलुगू','locale':'te'},
                  ];
                });
              }else if(locale=='bn')
            {
              setState(() {
                value=2;
                selectionList = [
                  {'language': 'ইংরেজি','locale':'en'},
                  {'language': 'হিন্দি','locale':'hi'},
                  {'language': 'বাংলা','locale':'bn'},
                  {'language': 'তেলুগু','locale':'te'},
                ];
              });
            }else if(locale=='te')
              {
                setState(() {
                  value=3;
                  selectionList = [
                    {'language': 'ఆంగ్ల','locale':'en'},
                    {'language': 'హిందీ','locale':'hi'},
                    {'language': 'బెంగాలీ','locale':'bn'},
                    {'language': 'তతెలుగు','locale':'te'},
                  ];
                });
              }
          translator.translate(title,to: locale).then((value) {
            setState(() {
              title=value.toString();
            });
          });
          translator.translate(ok,to: locale).then((value) {
            setState(() {
              ok=value.toString();
            });
          });
          translator.translate(cancel,to: locale).then((value) {
            setState(() {
              cancel=value.toString();
            });
          });
        }
      }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 40, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                addVerticalSpace(5.0),
                ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    controller: _controller,
                    scrollDirection: Axis.vertical,
                    itemCount: selectionList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final model = selectionList[index];
                      return RadioListTile(
                        value: index,
                        groupValue: value,
                        onChanged: (int? val) {
                          setState(() {
                            value = val!;
                            // reportID = model.id;
                            // reportMessage = model.message;
                            if (kDebugMode) {
                              print(
                                  "the index is ${model['language']} \n the message is ${model['locale']}");
                            }
                            returnValue=model['locale'];
                          });
                        },
                        title: Text(model['language']),
                      );
                    }),
                addVerticalSpace(20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(returnValue);
                      },
                      child: Text(
                        ok,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    addHorizontalSpace(10.0),
                    ElevatedButton(
                      onPressed: () {
                       // getCallProductReporting();
                        Navigator.of(context).pop("");
                      },
                      child:Text(
                        cancel,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }


}
