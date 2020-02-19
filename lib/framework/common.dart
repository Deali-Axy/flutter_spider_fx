import 'package:flutter_spider_fx/framework/index.dart';

abstract class SpiderFramework {
  static Future init() async {
    await Persistence.init();
  }
}
