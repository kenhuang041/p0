import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p0/list.dart';

class TimePage extends StatefulWidget {
  @override
  TimeState createState() => TimeState();
}

class TimeState extends State<TimePage> with SingleTickerProviderStateMixin{
  ValueNotifier<bool> isPause = ValueNotifier(true);
  late AnimationController controller;
  bool isReset = false;
  double progress = 1.0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 67),
    );

    controller.addListener(() {
      if(controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      }
      else {
        isPause.value = true;
        setState(() {
          if(isReset) {
            isReset = false;
            progress = 1.0;
          } else {
            progress = 0.0;
          }
        });
      }
    });
  }

  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
      ? "${controller.duration!.inHours.toString()}:${(controller.duration!.inMinutes % 60).toString().padLeft(2,'0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2,'0')}"
      : "${count.inHours.toString()}:${(count.inMinutes % 60).toString().padLeft(2,'0')}:${(count.inSeconds % 60).toString().padLeft(2,'0')}";
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 280,
                  width: 280,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    value: progress,
                    strokeAlign: 6,
                    color: Colors.blue,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        showDragHandle: true,
                        scrollControlDisabledMaxHeightRatio: 0.33,
                        context: context,
                        builder: (context) =>
                          CupertinoTimerPicker(
                              onTimerDurationChanged: (value) {
                                setState(() {
                                  controller.duration = value;
                                });
                              }
                          )
                    );
                  },
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context,anination) =>
                        Text(countText,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            )
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: [
              IconButton(
                  onPressed: () {
                    if(controller.isAnimating) {
                      controller.stop();
                      isPause.value = true;
                    }
                    else {
                      controller.reverse(
                        from: controller.value == 0 ? 1 : controller.value
                      );
                      isPause.value = false;
                    }
                  },
                  icon: ValueListenableBuilder(
                      valueListenable: isPause,
                      builder: (context,value,child) =>
                          value ? Icon(Icons.play_circle,size: 36,) : Icon(Icons.pause_circle,size: 36,)
                  )
              ),

              IconButton(
                  onPressed: () {
                    isPause.value = true;
                    setState(() {
                      isReset = true;
                    });

                    controller.reset();
                  },
                  icon: Icon(Icons.stop_circle,size: 36,)
              )
            ],
          ),

          ListPage(),
        ],
      ),
    );
  }

}