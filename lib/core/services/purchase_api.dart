import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseApi {
  static const _apiKey = '';

  static Future init() async {
    await Purchases.configure(PurchasesConfiguration(_apiKey));
    await Purchases.setLogLevel(LogLevel.debug);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}