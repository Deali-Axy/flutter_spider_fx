import 'dart:io';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_spider_fx/framework/index.dart';

class TestSpider extends SpiderTask {
  TestSpider(BuildContext context) : super(context, 'TestSpider');

  mainLoop() async {
    if (state == TaskState.running) {
      for (var i = 0; i < 10; i++) {
        logging.verbose('Spider start verbose');
//      sleep(Duration(seconds: 1));
        logging.debug('Spider start');
//      sleep(Duration(seconds: 1));
        logging.info('spider log info');
//      sleep(Duration(seconds: 1));
        logging.warning('spider log info');
//      sleep(Duration(seconds: 1));
        logging.error('spider log info');
      }
    }
  }

  @override
  start() {
    super.start();
    mainLoop();
  }
}
