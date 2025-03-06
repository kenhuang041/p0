import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p0/list.dart';

class TimePage extends StatefulWidget {
  const TimePage({Key? key}) : super(key: key);

  @override
  TimeState createState() => TimeState();
}

class TimeState extends State<TimePage> with SingleTickerProviderStateMixin{
  GlobalKey<ListState> listPageKey = GlobalKey<ListState>();
  ValueNotifier<bool> isPause = ValueNotifier(true);
  late AnimationController controller; //
  Duration d = Duration(seconds: 60);
  bool isReset = false;
  double progress = 1.0;

  @override
  void initState() {
    super.initState();
    //ListPage(key: listPageKey);

    //Duration? firstItemTime = listPageKey.currentState?.ListFirstItem();
    /*  print("First item time: $firstItemTime");*/

    controller = AnimationController( //初始化
      vsync: this, //讓動畫只在螢幕可見時運行
      duration: d,
    );

    //controller.duration 是時長
    //controller.value 範圍0~1 當前進度
    controller.addListener(() {
      if(controller.isAnimating) { //正在倒數
        setState(() {
          progress = controller.value; //更新進度條
        });
      }
      else {
        isPause.value = true;
        setState(() {
          /*if(isReset) {
            isReset = false;
            progress = 1.0;
          } else {
            progress = 0.0;
          }*/
          progress = 0.0;
        });
      }
    });

    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTimerFromList();
    });*/
  }

  /* Future<void> _updateTimerFromList() async {
    if (listPageKey.currentState != null) {
      try {
        Duration firstItemTime = await listPageKey.currentState!.ListFirstItem();
        //print("獲取到的時間: ${firstItemTime.inSeconds}秒");

        if (mounted) {
          setState(() {
            controller.duration = firstItemTime;
            controller.reset();
          });
        }
      } catch (e) {
        print("無法獲取第一個項目的時間: $e");
      }
    } else {
      print("listPageKey.currentState 為 null");
    }
  } */

  String get countText {
    Duration count = controller.duration! * controller.value; //依照當前進度推測當前時間 (duration不變，但value會)
    return controller.isDismissed //判斷是否被創建，保證未開始計時時顯示的時間正確
      ? "${controller.duration!.inHours.toString()}:${(controller.duration!.inMinutes % 60).toString().padLeft(2,'0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2,'0')}"
      : "${count.inHours.toString()}:${(count.inMinutes % 60).toString().padLeft(2,'0')}:${(count.inSeconds % 60).toString().padLeft(2,'0')}";
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose(); //銷毀 省空間
  }

  void updateTimer(Duration newDuration) {
    controller.duration = newDuration;
    controller.reset();
    setState(() {});
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
                  child: CircularProgressIndicator( //圓形進度條
                    backgroundColor: Colors.grey[300], //進度條背景色
                    value: progress, //當前進度
                    strokeAlign: 6, //粗細
                    color: Colors.blue, //進度條顏色
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    showModalBottomSheet( //調整當前時間
                        showDragHandle: true, //拖動欄
                        scrollControlDisabledMaxHeightRatio: 0.33, //0~1 顯示高度
                        context: context,
                        builder: (context) =>
                          CupertinoTimerPicker(
                              onTimerDurationChanged: (value) {
                                setState(() {
                                  controller.duration = value; //更新當前時間
                                });
                              }
                          )
                    );
                  },
                  child: AnimatedBuilder( //動畫監聽器
                    animation: controller, //綁定controller
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
                      controller.stop(); //計時暫停
                      isPause.value = true;
                    }
                    else {
                      controller.reverse( //倒數計時，由1遞減至0
                        from: controller.value == 0 ? 1 : controller.value //讓動畫從指定from開始
                      );
                      isPause.value = false;
                    }
                  },
                  icon: ValueListenableBuilder(
                      valueListenable: isPause,
                      builder: (context,value,child) =>
                          value ? Icon(Icons.play_circle,size: 42,) : Icon(Icons.pause_circle,size: 36,)
                  )
              ),

              IconButton(
                  onPressed: () {
                    isPause.value = true;
                    setState(() {
                      isReset = true;
                    });

                    controller.reset(); //重製時間
                  },
                  icon: Icon(Icons.stop_circle,size: 42,)
              )
            ],
          ),

          //ListPage(key: listPageKey,),
        ],
      ),
    );
  }
}