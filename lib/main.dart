import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/account_screen.dart';
import './widgets/bottom_tab.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../provider/notify_favourite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp();

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'progress_bar',
        channelName: 'Progress bar notifications',
        channelDescription: 'Notifications with a progress bar layout',
        defaultColor: Color.fromRGBO(47, 54, 64, 1),
        ledColor: Colors.white,
        onlyAlertOnce: true)
  ]);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => NotifyFavourite()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Graphico',
        theme: ThemeData(
          primaryColor: Colors.white, //52, 34, 46, 1
          accentColor: Color.fromRGBO(47, 54, 64, 1),
          primaryColorLight: Colors.grey[200],

          // primaryColorBrightness: Brightness.light,
          fontFamily: 'OpenSans',

          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Color.fromRGBO(47, 54, 64, 1)),
            textTheme: TextTheme(
              headline6: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Color.fromRGBO(47, 54, 64, 1),
              ),
            ),
          ),
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot) {
              if (userSnapshot.hasData)
                return BottomTab();
              else
                return AccountScreen();
            }),
      );
    });
  }
}
