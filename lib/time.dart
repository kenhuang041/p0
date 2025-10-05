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
  //AccelerometerEvent? _previousEvent;
  late AnimationController controller; //
  Color clock_color = Colors.red;
  Duration d = Duration(seconds: 60);
  bool isReset = false;
  double progress = 0.0;

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
    Duration count = controller.duration! * ((controller.value-1).abs()); //依照當前進度推測當前時間 (duration不變，但value會)
    return controller.isDismissed || controller.value == 1//判斷是否被創建，保證未開始計時時顯示的時間正確
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
                    color: clock_color, //進度條顏色c
                  ),
                ),

                AnimatedBuilder(
                  animation: controller,
                  builder: (context,animation) {
                    double angle = controller.value * 6.28;
                    return Transform.rotate(
                        angle: angle,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 8,
                              height: 8,
                              child: CircleAvatar(
                                radius: 90,
                                backgroundColor: clock_color,
                              ),
                            ),

                            Container(
                              width: 3,
                              height: 70,
                              color: clock_color,
                            ),
                            SizedBox(width: 3,height: 235,)
                          ],
                        ),
                    );
                  }
                ),

                GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10,),
                      AnimatedBuilder( //動畫監聽器
                        animation: controller, //綁定controller
                        builder: (context,anination) =>
                            Text(countText,style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
                      ),
                      Text(clock_color == Colors.red ? "工作中" : "休息中",style: TextStyle(fontSize: 20,color: clock_color,fontWeight: FontWeight.bold),)
                    ],
                  )
                ),
              ],
            )
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: [
              GestureDetector(
                onTap: () {
                  isPause.value = true;
                  setState(() {
                    isReset = true;
                  });
                  controller.reset();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.stop,size: 30,color: Colors.white,),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(90)
                  ),
                ),
              ),

              SizedBox(width: 20,),

              GestureDetector(
                onTap: () {
                  if(controller.isAnimating) {
                    controller.stop(); //計時暫停
                    isPause.value = true;
                  }
                  else {
                    controller.forward( //倒數計時，由1遞減至0
                        from: controller.value == 1 ? 0 : controller.value //讓動畫從指定from開始
                    );
                    isPause.value = false;
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  child: ValueListenableBuilder(
                      valueListenable: isPause,
                      builder: (context,value,child) =>
                      value ? Icon(Icons.play_arrow,size: 30,color: Colors.white,) : Icon(Icons.pause,size: 30,color: Colors.white,)
                  ),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(90)
                  ),
                ),
              ),
              SizedBox(width: 50,)
              /*GestureDetector(

                  child: Container(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.skip_next_rounded,size: 32,color: Colors.white,),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(90)
                    ),
                  ),
                )*/
            ],
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}

