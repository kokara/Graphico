import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/search_screen.dart';
import '../screen/profile_screen.dart';
import '../models/hide_nav_bar.dart';

class BottomTab extends StatefulWidget {
  @override
  _BottomTabState createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  int _currentIndex = 0;
  List<Widget> screenList = [
    HomeScreen(),
    SearchScreen(hiding),
    ProfileScreen(),
  ];
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  static HideNavbar hiding = HideNavbar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screenList,
      ),
      bottomNavigationBar: ValueListenableBuilder(
          valueListenable: hiding.visible,
          builder: (context, bool value, child) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: value ? kBottomNavigationBarHeight : 0.0,
              child: Wrap(
                children: [
                  BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    onTap: onTabTapped,
                    currentIndex: _currentIndex,
                    backgroundColor: Theme.of(context).primaryColor,
                    unselectedItemColor: Color.fromRGBO(131, 149, 167, 1),
                    selectedItemColor: Theme.of(context).accentColor,
                    unselectedLabelStyle: TextStyle(fontFamily: 'Montserrat'),
                    selectedLabelStyle: TextStyle(fontFamily: 'Montserrat'),

                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: new Icon(
                          Icons.search_rounded,
                        ),
                        label: 'Search',
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
                    //type: BottomNavigationBarType.shifting,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
