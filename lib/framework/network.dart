import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

abstract class CatHttp {
  // 构造请求头
  static var header = {
    'user-agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36',
  };

  static Map<String, dynamic> imageHeader(String referer) {
    return {
//    ':authority': 'i5.mmzztt.com',
//    ':path': '/2018/08/17a02.jpg',
//    ':scheme': 'https',
      'accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      'accept-encoding': 'gzip, deflate, br',
      'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
      'cache-control': 'no-cache',
      'dnt': '1',
      'pragma': 'no-cache',
      'referer': referer,
      'sec-fetch-dest': 'image',
      'sec-fetch-mode': 'no-cors',
      'sec-fetch-site': 'cross-site',
    };
  }

  /// 下载网页
  static Future<String> downloadHtmlAsync(String url) async {
    try {
      var response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        return response.body;
      }
      return '<html lang="zh-cn">error! status:${response.statusCode}</html>';
    } catch (e) {
      print('下载网页出错，等待10秒。$e');
      sleep(Duration(seconds: 10));
      return downloadHtmlAsync(url);
    }
  }

  /// 获取解析的html文档对象
  static Future<Document> getDocument(String url, {String encoding = 'utf-8'}) async {
    var html = await downloadHtmlAsync(url);
    var dom = parse(html, encoding: encoding);
    return dom;
  }

  /// 下载图片
  static Future<List<int>> downloadImage(String imageUrl, {String referer = ''}) async {
    var response = await Dio().get(imageUrl, options: Options(responseType: ResponseType.bytes, headers: imageHeader(referer)));
    if (response.data is List<int>) {
      return response.data;
    } else {
      print('出错了，等待10秒。');
      sleep(Duration(seconds: 10));
      return downloadImage(imageUrl, referer: referer);
    }
  }
}
