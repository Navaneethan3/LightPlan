import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lighthouse_planner/tree_handler.dart';
import 'package:provider/provider.dart';

class TreeTimer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TreeTimerStateful();
  }
}

class _TreeTimerStateful extends State<TreeTimer> {
  TreeHandler treeHandler;
  Stream<Duration> remainingTime;
  Timer timer;

  void startCountdown() {
    int countDownTime;
    if (treeHandler.currentTask == null) {
      countDownTime = DateTime(DateTime.now().year, 12, 31, 23, 59, 59).millisecondsSinceEpoch;
    } else {
      countDownTime = treeHandler.currentTask.endDate;
    }

    // ignore: close_sinks
    var controller = StreamController<Duration>();
    if(timer != null) timer.cancel();

    int now = DateTime.now().millisecondsSinceEpoch;
    controller.add(Duration(milliseconds: countDownTime - now));

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      int now = DateTime.now().millisecondsSinceEpoch;
      controller.add(Duration(milliseconds: countDownTime - now));
    });
    this.remainingTime = controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    this.treeHandler = context.watch<TreeHandler>();
    this.startCountdown();

    return Center(
      child: StreamBuilder(
        stream: this.remainingTime,
        builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return dateWidgetBuilder(snapshot.data);
        },
      ),
    );
  }

  Widget dateWidgetBuilder(Duration durationLeft) {
    if (durationLeft.isNegative) {
      return Text("Overdue with ${durationLeft.inDays.abs()} days... Try until you make it!");
    }
    String dateString = formatToDate(durationLeft);
    return Container(
      child: Text(
        dateString,
        style: TextStyle(
            letterSpacing: 3.0,
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'digital-7'),
      ),
      padding: EdgeInsets.all(10),
    );
  }

  String formatToDate(Duration duration) {
    String days = (duration.inDays).toString().padLeft(2, '0');
    String hours = (duration.inHours % 24).toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$days:$hours:$minutes:$seconds';
  }
}
