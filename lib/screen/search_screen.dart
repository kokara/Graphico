import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import '../widgets/search_image.dart';
import '../widgets/search_video.dart';
import '../models/hide_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  HideNavbar hiding;
  SearchScreen(this.hiding);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with WidgetsBindingObserver {
  ValueNotifier<bool> _isImage = ValueNotifier(true);

  void selectedItem(BuildContext ctx, item) {
    if (item == 0) {
      if (_isImage.value) return;

      _isImage.value = true;
    } else {
      if (!_isImage.value) return;

      _isImage.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance!.window.viewInsets.bottom;
    if (value == 0) {
      inputFocusNode.unfocus();
    }
  }

  // ValueNotifier<String> _submitted = ValueNotifier("");
  String _query = "";
  final _key = GlobalKey();
  final FocusNode inputFocusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    inputFocusNode.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _query.length == 0
              ? Container()
              : _isImage.value == true
                  ? SearchImage(_query, UniqueKey(), widget.hiding)
                  : SearchVideo(_query, UniqueKey(), widget.hiding),
          Positioned(
            top: 40,
            width: 100.w,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ValueListenableBuilder(
                  valueListenable: widget.hiding.visible,
                  builder: (context, bool value, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Theme.of(context).primaryColorLight,
                      ),
                      alignment: Alignment.center,
                      height: value ? 58 : 0.0,
                      child: Wrap(
                        children: [
                          Opacity(
                            opacity: value ? 1 : 0.0,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Theme(
                                    data: ThemeData.from(
                                      colorScheme: ColorScheme.fromSwatch(
                                          primarySwatch: Colors.grey,
                                          accentColor:
                                              Color.fromRGBO(47, 54, 64, 1)),
                                    ),
                                    child: TextField(
                                      cursorColor:
                                          Theme.of(context).accentColor,
                                      focusNode: inputFocusNode,
                                      key: _key,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (value) {
                                        setState(() {
                                          _query = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.search_rounded,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: _isImage,
                                    builder: (context, value, _) {
                                      return value == true
                                          ? Icon(
                                              Icons.image_rounded,
                                            )
                                          : Icon(
                                              Icons.videocam_rounded,
                                            );
                                    }),
                                PopupMenuButton(
                                    icon:
                                        Icon(Icons.keyboard_arrow_down_rounded),
                                    onSelected: (item) =>
                                        selectedItem(context, item),
                                    itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 0,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.image_rounded,
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  'Images',
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat'),
                                                )
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 1,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.videocam_rounded,
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  'Videos',
                                                  style: TextStyle(
                                                      fontFamily: 'Montserrat'),
                                                )
                                              ],
                                            ),
                                          ),
                                        ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          )
        ],
      ),
    );
    /*FloatingSearchBar(
        controller: controller,
        backdropColor: Colors.white,
        body: _query.length == 0
            ? Container()
            : Container(height: 600, child: call()),
        builder: (context, _) {
          return Container();
        },
        title: Icon(Icons.search_rounded),
        padding: EdgeInsets.only(left: 10),
        actions: [
          ValueListenableBuilder(
              valueListenable: _isImage,
              builder: (context, value, _) {
                return value == true
                    ? Icon(
                        Icons.image_rounded,
                      )
                    : Icon(
                        Icons.videocam_rounded,
                      );
              }),
          PopupMenuButton(
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              onSelected: (item) => selectedItem(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.image_rounded,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            'Images',
                            style: TextStyle(fontFamily: 'Montserrat'),
                          )
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.videocam_rounded,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            'Videos',
                            style: TextStyle(fontFamily: 'Montserrat'),
                          )
                        ],
                      ),
                    )
                  ]),
        ],
        leadingActions: [
          FloatingSearchBarAction.searchToClear(
            showIfClosed: false,
          ),
        ],
        transitionDuration: Duration(milliseconds: 0),
        onSubmitted: (query) {
          setState(() {
            _query = query;
          });
        },
        closeOnBackdropTap: false,
        /*body: _query.length == 0
            ? Container()
            : Container(height: 100, child: call()),*/
      ),*/
  }
}
