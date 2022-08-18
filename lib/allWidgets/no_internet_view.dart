import 'package:flutter/material.dart';
import 'package:tradz/allConstants/Colors/ConstantColors.dart';
class NoInternetView extends StatelessWidget {
  final String noInternetMessage;
  final bool isInternet;
  const NoInternetView({Key? key,required this.noInternetMessage,required this.isInternet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Visibility(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize:MainAxisSize.min,
                  children: <Widget>[
                    // new Image.asset(
                    //   'assets/images/ic_error.png',
                    //   height: 50.0,
                    //   width: 50.0,
                    // ),
                    Icon(Icons.error_outline,color: ConstantColors.primaryColor,size: MediaQuery.of(context).size.height*0.10,),
                    Text(
                      noInternetMessage,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              elevation: 8.0,
            ),
            visible: isInternet,
          ),
        )
      ],
    );
  }
}
