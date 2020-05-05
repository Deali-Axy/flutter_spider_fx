import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_spider_fx/framework/index.dart';
import 'package:path_provider/path_provider.dart' show getExternalStorageDirectory;
import 'package:html/parser.dart' show parse;

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

class MzituSpider extends SpiderTask {
  var baseUrl = 'https://www.mzitu.com/';
  var allUrl = 'https://www.mzitu.com/all/';
  String libDir;

  var existedList = [];

  MzituSpider(BuildContext context, {void callback()}) : super(context, 'MzituSpider', callback: callback);

  @override
  init() async {
    var jsonObj = jsonDecode(await DefaultAssetBundle.of(context).loadString("assets/mzitu/existed_list.json"));
    existedList = jsonObj['items'];
//    if (config.containsKey('existedList')) {
//      List<String> tempList = config.get('existedList');
//      existedList.addAll(tempList);
//    } else {
//      config.set('existedList', <String>[]);
//    }
    libDir = path.join(Persistence.externalStorageDirectory, name);
    logging.info('获取到根目录：$libDir');
  }

  /// 爬取网站上的所有相册
  Future<List<Album>> getAlbums() async {
    var document = await CatHttp.getDocument(allUrl);
    var archives = document.querySelectorAll('.archives');
    var data = <Album>[];
    for (var i = 0; i < archives.length - 1; i++) {
      var archive = archives[i];
      var year = (2020 - i).toString();
      for (var li in archive.querySelectorAll('li')) {
        var month = li.querySelector('.month > em').text.replaceFirst('月', '');
        for (var link in li.querySelectorAll('.url > a')) {
          data.add(Album(
            num: link.attributes['href'].replaceFirst(baseUrl, ''),
            title: link.text,
            pageUrl: link.attributes['href'],
            dateTime: DateTime.parse('$year-$month-01 12:23'),
            imagesUrl: [],
          ).dump());
        }
      }
    }
    return data;
  }

  /// 爬取相册内的图片
  Future<List<String>> getAlbumImages(Album album) async {
    if (existedList.contains(album.num) || Persistence.exists(path.join(libDir, album.num))) return [];
    var document = await CatHttp.getDocument(album.pageUrl);
    var pageNavi = document.querySelector('.pagenavi');
    // 提取总页数
    var total = int.parse(pageNavi.children[pageNavi.children.length - 2].text);
    for (var i = 1; i <= total; i++) {
      var pageUrl = i > 1 ? '${album.pageUrl}/$i' : album.pageUrl;
      logging.debug('Crawl $pageUrl');
      document = await CatHttp.getDocument(pageUrl);
      var image = document.querySelector('.main-image p a img');
      var imageUrl = image.attributes['src'];
      album.imagesUrl.add(imageUrl);
      sleep(Duration(seconds: 4));
      downloadImage(album, pageUrl, imageUrl);
    }
    existedList.add(album.num);
//    List<String> confList = config.get('existedList');
//    confList.add(album.num);
    return album.imagesUrl;
  }

  void downloadImage(Album album, String pageUrl, String imageUrl) async {
    var imageData = await CatHttp.downloadImage(imageUrl, referer: pageUrl);
    var filename = path.basename(imageUrl);
    var fileDir = path.join(libDir, album.num);
    if (!Persistence.exists(fileDir)) Directory(fileDir).createSync(recursive: true);
    var filepath = path.join(libDir, album.num, filename);
    if (Persistence.exists(filepath)) return;
    logging.debug('Write $filename');
    try {
      File(filepath).writeAsBytesSync(imageData);
    } catch (e) {
      logging.debug('出错了，等待10秒。$e');
      sleep(Duration(seconds: 10));
      downloadImage(album, pageUrl, imageUrl);
    }
  }

  Future<List<Album>> getAlbumsFromAsset() async {
    var albums = <Album>[];
    var jsonStr = await DefaultAssetBundle.of(context).loadString("assets/mzitu/albums.json");
    var jsonObj = json.decode(jsonStr);
    for (var item in jsonObj) {
      albums.add(Album.fromJson(item));
    }

    return albums;
  }

  @override
  start() async {
    super.start();
    var albums = await getAlbums();

    for (var album in albums) {
      await getAlbumImages(album);
    }
  }
}
