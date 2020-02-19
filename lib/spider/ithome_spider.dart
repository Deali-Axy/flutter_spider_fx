import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_spider_fx/framework/index.dart';

class ItHomeSpider extends SpiderTask {
  var url = 'https://www.ithome.com/';

  ItHomeSpider(BuildContext context) : super(context, 'IT Home Spider');

  @override
  start() async {
    super.start();
    logging.debug('你倒是显示出来啊！');
    var dom = await CatHttp.getDocument(url);
    var links = dom.querySelectorAll(".hot-list ul li a");
    links.forEach((links) {
      logging.verbose(links.attributes['href']);
      logging.debug(links.text);
    });
  }
}
