import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class NotifyFavourite with ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
