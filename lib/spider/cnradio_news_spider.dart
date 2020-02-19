import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_spider_fx/framework/index.dart';

class CNRadioNewsSpider extends SpiderTask {
  var url = 'http://news.cnr.cn/';

  CNRadioNewsSpider(BuildContext context) : super(context, 'CNRadioNewsSpider');

  @override
  start() async {
    super.start();
    var dom = await CatHttp.getDocument(url, encoding: 'gb2312');
    var links = dom.querySelectorAll('.contentPanel .lh30 a');
    logging.info('hello');
    links.forEach((link) {
      logging.debug(link.attributes['href']);
      logging.info(link.text);
    });
  }
}
