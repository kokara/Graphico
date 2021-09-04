import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 122,
        child: Column(
          children: [
            Container(
              height: 70,
              child: Image.asset("assets/fonts/sad.png"),
            ),
            SizedBox(
              height: 25,
            ),
            AutoSizeText(
              'Something went wrong!',
              style: TextStyle(fontSize: 19),
              minFontSize: 18,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
