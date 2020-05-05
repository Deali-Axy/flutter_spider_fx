import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spider_fx/framework/index.dart';
import 'package:flutter_spider_fx/route/task_details.dart';
import 'package:flutter_spider_fx/spider/cnradio_news_spider.dart';
import 'package:flutter_spider_fx/spider/ithome_spider.dart';
import 'package:flutter_spider_fx/spider/ligui_spider.dart';
import 'package:flutter_spider_fx/spider/mzitu_spider.dart';
import 'package:flutter_spider_fx/spider/test_spider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Item {
  int index;
  String title;
  bool isExpanded;
  SpiderTask task;

  Item({this.index, this.title, this.isExpanded, this.task});
}

class _MyHomePageState extends State<MyHomePage> {
  var _tasks = <SpiderTask>[];
  var _items = <Item>[];

  @override
  void initState() {
    super.initState();
    PermissionHandler().requestPermissions(<PermissionGroup>[PermissionGroup.storage]);
    // 记住 initState 里面没有context的！
    print('init state');

    _tasks.add(MzituSpider(context));
    _tasks.add(TestSpider(context));
    _tasks.add(ItHomeSpider(context));
    _tasks.add(CNRadioNewsSpider(context));
    for (var task in _tasks) {
      _items.add(Item(index: _items.length + 1, title: task.name, task: task, isExpanded: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('简单爬虫框架'),
        actions: <Widget>[
          FlatButton(
            child: Row(children: <Widget>[Icon(Icons.add, color: Colors.white), Text('新任务', style: TextStyle(color: Colors.white))]),
            onPressed: () => BotToast.showText(text: '请在代码里面添加任务~\n谢谢 Thanks♪(･ω･)ﾉ'),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ListView(
        children: <Widget>[
          ExpansionPanelList(
            animationDuration: Duration(milliseconds: 700),
            expansionCallback: (int index, bool isExpanded) => setState(() => _items[index].isExpanded = !isExpanded),
            children: _items
                .map(
                  (item) => ExpansionPanel(
                    headerBuilder: (context, isExpanded) => ListTile(
                      leading: Icon(Icons.android),
                      title: Text('${item.index}. ${item.title}', style: TextStyle(fontWeight: item.isExpanded ? FontWeight.bold : FontWeight.normal)),
                    ),
                    body: Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('Item')),
                                    DataColumn(label: Text('Value')),
                                  ],
                                  rows: [
                                    DataRow(cells: [
                                      DataCell(Text('任务状态')),
                                      DataCell(Text(item.task.state.toString())),
                                    ]),
                                    DataRow(cells: [
                                      DataCell(Text('日志数量')),
                                      DataCell(Text(item.task.logging.logs.length.toString())),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.desktop_windows, color: Colors.blue),
                              padding: EdgeInsets.all(0),
                              tooltip: '任务详情',
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskDetailsPage(item.task))),
                            ),
                            IconButton(
                              icon: Icon(Icons.play_arrow, color: item.task.state == TaskState.stop ? Colors.green : Colors.grey),
                              padding: EdgeInsets.all(0),
                              onPressed: item.task.state == TaskState.stop ? () => setState(() => item.task.start()) : null,
                            ),
                            if (item.task.state == TaskState.running)
                              IconButton(
                                icon: Icon(Icons.pause, color: Colors.orange),
                                padding: EdgeInsets.all(0),
                                tooltip: '暂停任务',
                                onPressed: () => setState(() => item.task.pause()),
                              ),
                            if (item.task.state == TaskState.pause)
                              IconButton(
                                icon: Icon(Icons.play_circle_outline, color: Colors.orange),
                                padding: EdgeInsets.all(0),
                                tooltip: '继续任务',
                                onPressed: () => setState(() => item.task.resume()),
                              ),
                            IconButton(
                              icon: Icon(Icons.stop, color: item.task.state != TaskState.stop ? Colors.red : Colors.grey),
                              padding: EdgeInsets.all(0),
                              tooltip: '停止任务',
                              onPressed: item.task.state != TaskState.stop ? () => setState(() => item.task.stop()) : null,
                            ),
                            IconButton(icon: Icon(Icons.restore, color: Colors.cyan), padding: EdgeInsets.all(0), onPressed: () => BotToast.showText(text: '请在详情页面操作！')),
                            IconButton(icon: Icon(Icons.star, color: Colors.pink[400]), padding: EdgeInsets.all(0), onPressed: () => BotToast.showText(text: '请在详情页面操作！')),
                          ], mainAxisAlignment: MainAxisAlignment.end),
                        ],
                      ),
                    ),
                    isExpanded: item.isExpanded,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList() {
    return <Widget>[
      _buildTaskItem(1, 'it home articles list'),
      _buildTaskItem(2, 'cnblogs articles list'),
    ];
  }

  Widget _buildTaskItem(int index, String name) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(index.toString()),
          SizedBox(width: 10),
          Expanded(child: Text(name)),
          Icon(Icons.play_arrow, color: Colors.blue),
          Icon(Icons.pause, color: Colors.red[400]),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          OutlineButton(
              child: Text('启动全部'),
              onPressed: () async {
                print(Persistence.externalStorageDirectory);
                print(Persistence.applicationDocumentsDirectory);
                print(Persistence.applicationSupportDirectory);
                print(Persistence.temporaryDirectory);
              }),
          SizedBox(width: 10),
          OutlineButton(child: Text('暂停全部'), onPressed: () {}),
        ],
      ),
    );
  }
}
