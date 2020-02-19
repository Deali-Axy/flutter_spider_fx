import 'package:flutter/material.dart';
import 'package:flutter_spider_fx/framework/index.dart';

class TaskDetailsPage extends StatefulWidget {
  final SpiderTask task;

  TaskDetailsPage(this.task);

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  outputRefresh() => setState(() {});

  start() => widget.task.start();

  stop() => widget.task.stop();

  pause() => widget.task.pause();

  resume() => widget.task.resume();

  @override
  void initState() {
    super.initState();
    widget.task.logging.callback = outputRefresh;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        actions: <Widget>[IconButton(icon: Icon(Icons.clear_all), onPressed: () => setState(() => widget.task.logging.logs.clear()))],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              OutlineButton.icon(onPressed: widget.task.state == TaskState.stop ? start : null, icon: Icon(Icons.play_arrow, color: Colors.green), label: Text('开始')),
              SizedBox(width: 10),
              if (widget.task.state == TaskState.pause) OutlineButton.icon(onPressed: resume, icon: Icon(Icons.play_arrow, color: Colors.cyan), label: Text('继续')),
              if (widget.task.state == TaskState.running) OutlineButton.icon(onPressed: pause, icon: Icon(Icons.pause, color: Colors.orange), label: Text('暂停')),
              SizedBox(width: 10),
              OutlineButton.icon(onPressed: widget.task.state != TaskState.stop ? stop : null, icon: Icon(Icons.stop, color: Colors.red), label: Text('停止')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    var logs = widget.task.logging?.logs?.reversed ?? [];

    Widget body = Center(child: Text('暂无日志', style: TextStyle(fontSize: 20)));

    if (logs.length > 0) {
      body = ListView(
        reverse: true,
        children: <Widget>[
          for (var log in logs) _buildLog(log),
        ],
      );
    }

    return Container(
      margin: EdgeInsets.all(8),
      child: body,
    );
  }

  Widget _buildLog(Log log) {
    var date = '${log.dateTime.year}-${log.dateTime.month}-${log.dateTime.day} ${log.dateTime.hour}:${log.dateTime.minute}:${log.dateTime.second}';
    var content = '$date ${log.tag} ${log.content}';

    switch (log.level) {
      case LogLevel.verbose:
        return Text(content, style: TextStyle(color: Colors.purple, fontSize: 14));
      case LogLevel.debug:
        return Text(content, style: TextStyle(color: Colors.blueGrey, fontSize: 16));
      case LogLevel.info:
        return Text(content, style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w400));
      case LogLevel.warning:
        return Text(content, style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.w500));
      case LogLevel.error:
        return Text(content, style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold));
    }
  }
}
