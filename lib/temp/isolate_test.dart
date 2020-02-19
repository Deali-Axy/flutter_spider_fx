import 'dart:async';
import 'dart:isolate';

main(List<String> args) {
  start();

  print("start");
}

Isolate isolate;

int i = 1;

void start() async {
  //接收消息的主Isolate的端口
  final receive = ReceivePort();

  isolate = await Isolate.spawn(runTimer, receive.sendPort);

  receive.listen((data) {
    print("Reveive : $data ; i :$i");
  });
}

void runTimer(SendPort port) {
  int counter = 0;
  Timer.periodic(const Duration(seconds: 1), (_) {
    counter++;
    i++;
    final msg = "nitification $counter";
    print("Send :$msg ;i :$i");
    port.send(msg);
  });
}
