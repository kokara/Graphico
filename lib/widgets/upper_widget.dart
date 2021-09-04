import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/image.dart' as img;
import 'package:url_launcher/url_launcher.dart';
import '../models/http_exception.dart';
import 'package:flutter/services.dart';

class UpperWidget extends StatelessWidget {
  String photographerName;
  String photographerUrl;
  String itemUrl;
  UpperWidget(
      {required this.photographerName,
      required this.photographerUrl,
      required this.itemUrl});
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw HttpException("Can't launch url");
    }
  }

  Future<void> _copyToClipboard(BuildContext ctx) async {
    await Clipboard.setData(ClipboardData(text: itemUrl));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text("Link Copied"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 16,
          bottom: 12,
        ),
        child: Row(
          children: [
            Material(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(
                Radius.circular(50),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    await _launchURL(photographerUrl);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Can't launch url!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 12, right: 12, bottom: 6, top: 6),
                  child: Text(
                    photographerName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: Container()),
            PopupMenuButton(
              onSelected: (value) async {
                if (value == 1) {
                  try {
                    await _launchURL(itemUrl);
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Can't launch url!"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else
                  await _copyToClipboard(context);
              },
              child: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text("Copy link"),
                    value: 0,
                  ),
                  PopupMenuItem(
                    child: Text("Open in browser"),
                    value: 1,
                  ),
                ];
              },
            ),
          ],
        ));
  }
}
