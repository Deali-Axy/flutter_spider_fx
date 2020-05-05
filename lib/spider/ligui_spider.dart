import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spider_fx/framework/index.dart';

class Album {
  final String num;
  final String title;
  final String pageUrl;
  final DateTime dateTime;
  List<String> imagesUrl;

  Album({this.num, this.title, this.pageUrl, this.dateTime, this.imagesUrl});

  factory Album.fromJson(Map<String, dynamic> map) => Album(
        num: map['num'],
        title: map['title'],
        pageUrl: map['pageUrl'],
        dateTime: DateTime.parse(map['dateTime']),
        imagesUrl: [],
      );

  Map<String, dynamic> toJson() => {
        'num': num,
        'title': title,
        'pageUrl': pageUrl,
        'dateTime': dateTime.toString(),
      };

  String toJsonStr() => jsonEncode(toJson());

  @override
  String toString() => toJson().toString();

  Album dump() {
    print(toString());
    return this;
  }
}

class LiGuiSpider extends SpiderTask {
  LiGuiSpider(BuildContext context, {void callback()}) : super(context, 'LiGuiSpider', callback: callback);

  /// 爬取网站上的所有相册
  Future<List<Map<String, String>>> getAlbums() async {
    var document = await CatHttp.getDocument('https://www.meitulu.com/t/ligui/',encoding: 'gb2312');
    var data = <Map<String, String>>[];

    var ul = document.querySelectorAll('ul.img li');
    for (var li in ul) {
      var link = li.querySelector('a').attributes['href'];
      var title = li.querySelector('img').attributes['alt'];
      var item = {'title': title, 'link': link};
      data.add(item);

      print(item);
    }

    return data;
  }

  @override
  start() {
    getAlbums();
    return super.start();
  }
}


