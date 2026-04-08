import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  // 1. Метод для разової перевірки прямо зараз (використаємо при логіні)
  static Future<bool> get isConnected async {
    return await InternetConnection().hasInternetAccess;
  }

  // 2. Потік (Stream) для постійного відслідковування (використаємо на головному екрані)
  static Stream<InternetStatus> get onStatusChange {
    return InternetConnection().onStatusChange;
  }
}
