import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p0/time.dart';
import 'dart:math' as math;

class ListPage extends StatefulWidget {
  //final Function(Duration)? onTimerUpdate;
  List tl = [0,0];

  ListPage({super.key});
  //const ListPage({Key? key, this.onTimerUpdate}) : super(key: key);

  @override
  ListState createState() => ListState();
}

class ListState extends State<ListPage> with TickerProviderStateMixin {
  GlobalKey<TimeState> timePageKey = GlobalKey<TimeState>();
  final List<Item> items = [Item(time: '0:00:03',isWork: true,dtime: Duration(seconds: 3),),Item(time: '0:00:02',isWork: false,dtime: Duration(seconds: 2),)];
  List<int> totoal = [0,0];
  final List<AnimationController> controllers = [];
  double _angle = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTime();
    });

    for (var i = 0; i < items.length; i++) {
      controllers.add(_createController());
    }
  }

  AnimationController _createController() {
    return AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    )..forward();
  }


  //顯示決定工作時間的列表
  void showListPage() {
    showModalBottomSheet( //顯示底部欄位
        isScrollControlled: true,
        //showDragHandle: true,
        context: context,
        builder: (context) => StatefulBuilder( //不影響父元件的情況下更新表單狀態
          builder: (context,setModalState) => Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7, //顯示高度 手機高度 * 0.7
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding( // 自定義showDragHandle
                  padding: EdgeInsets.only(bottom: 10),
                  child: Container(
                    height: 5,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    OutlinedButton( //新增項目按鈕
                      onPressed: () async {
                        //Duration nowTime = await _AddListItem();
                        //print(nowTime.inSeconds);
                        Duration nowTime = Duration(seconds: 5);
                        if(items[items.length-1]!.isWork == true) nowTime = Duration(seconds: 2); //休息時間判斷

                        items.add(Item(
                            time: '${nowTime.inHours.toString()}:${(nowTime.inMinutes % 60).toString().padLeft(2,'0')}:${(nowTime.inSeconds % 60).toString().padLeft(2,'0')}',
                            isWork: !items[items.length-1]!.isWork,
                            dtime: nowTime,
                        ));

                        controllers.add(_createController());
                        setModalState(() {}); //更新StatefulBuilder

                        _updateTime();
                      },
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width*0.9, 30),
                        side: BorderSide(width: 2.3,), //!
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        )
                      ),
                      child: Icon(Icons.add,size: 32,color: Colors.black,),
                    ),
                  ],
                ),

                SizedBox(height: 5,),
                /**
                 * 尚未實現項目的新增及刪除動畫
                 */
                Expanded(
                    child: ReorderableListView( //可拖動項目的表單
                      onReorder: (int oldIndex,int newIndex) {
                        setModalState(() {
                          if(newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          var tmp = items.removeAt(oldIndex);
                          var controller = controllers.removeAt(oldIndex);

                          items.insert(newIndex, tmp);
                          controllers.insert(newIndex, controller);
                        });

                        setState(() {});
                        _updateTime();
                      },
                      children: [
                        for (int i=0; i<items.length; i++)
                          SlideTransition(
                            key: ValueKey(i),
                            //opacity: controllers[i],
                            //sizeFactor: controllers[i],
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0), // 初始位置 (右側外部)
                              end: Offset.zero, // 終點位置 (正常位置)
                            ).animate(
                              //CurvedAnimation(
                                  /*parent:*/ controllers[i],
                                  //curve: Curves.bounceOut
                              //)
                            ),

                            child: Container(
                              padding: EdgeInsets.only(bottom: 5),
                              /**
                               * 點擊項目後方按鈕可刪除此項目
                               * 點擊項目則觸發修改項目頁面
                               */
                              child: Card( //項目樣式
                                elevation: 2,

                                child: ListTile(
                                  title: Text('${items[i].time}',style: TextStyle(fontSize: 22,),),
                                  subtitle: Text((items[i].isWork ? '工作時間...' : '休息時間!'),style: TextStyle(fontSize: 12),),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    child: items[i].isWork ? Icon(Icons.work,color: Colors.white) : Icon(Icons.videogame_asset,color: Colors.white,),
                                    decoration: BoxDecoration(
                                      color: items[i].isWork ? Colors.red : Colors.green,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  trailing: IconButton( //刪除項目
                                      onPressed: () async {
                                        controllers[i].reverse().then((_) {
                                          setModalState(() {
                                            if(items.length > 1) items.removeAt(i);
                                            controllers.removeAt(i);
                                          });
                                        });

                                        _updateTime();
                                      },
                                      icon: Icon(Icons.delete_outline)
                                  ),
                                  onTap: () async { //發修改項目頁面
                                    await _UpdateListItem(items[i],i);
                                    setModalState(() {});
                                    _updateTime();
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          )
                      ],
                    )
                  )
              ],
            ),
          ),
        )
    );
  }

  /// 修改項目的dialog
  Future<void> _UpdateListItem(Item item,int j) async {
    await showDialog(
        context: context,
        builder: (context) =>
          StatefulBuilder(
            builder: (context,setDialogState) =>
                AlertDialog(
                  title: Text('倒數計時時間:'),
                  content: Container(
                    // 設置容器的寬度來適應對話框
                    width: double.maxFinite,
                    // 用 ConstrainedBox 約束高度
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.2,
                          ),
                          child: CupertinoTimerPicker(
                            mode: CupertinoTimerPickerMode.hms,
                            initialTimerDuration: item.dtime,

                            onTimerDurationChanged: (value) {
                              setDialogState(() {
                                item.dtime = value;
                              });
                            },
                          ),
                        ),

                        SizedBox(height: 10,),

                        /// 選擇工作時間還是休息時間
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ChoiceChip(
                              label: Text('工作'),
                              selected: item.isWork,
                              selectedColor: Colors.red[200],
                              onSelected: (value) {
                                setDialogState(() {
                                  item.isWork = true;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90),
                              ),
                              avatar: CircleAvatar(
                                backgroundColor: Colors.red[200],
                                //radius: 200,
                                maxRadius: 100,
                                minRadius: 80,
                              ),

                            ),

                            SizedBox(width: 10,),

                            ChoiceChip(
                              label: Text('休息'),
                              selected: !item.isWork,
                              selectedColor: Colors.green[200],
                              onSelected: (value) {
                                setDialogState(() {
                                  item.isWork = false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90),
                              ),
                              avatar: CircleAvatar(
                                backgroundColor: Colors.green[200],
                                //radius: 200,
                                maxRadius: 100,
                                minRadius: 80,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  actions: [
                    TextButton( //直接修改items項目
                        onPressed: () {
                          items[j].time = '${item.dtime.inHours.toString()}:${(item.dtime.inMinutes % 60).toString().padLeft(2,'0')}:${(item.dtime.inSeconds % 60).toString().padLeft(2,'0')}';
                          items[j].dtime = item.dtime;
                          items[j].isWork = item.isWork;

                          /*time: '${nowTime.inHours.toString()}:${(nowTime.inMinutes % 60).toString().padLeft(2,'0')}:${(nowTime.inSeconds % 60).toString().padLeft(2,'0')}',
                            isWork: selected == 1,
                            dtime: nowTime,*/
                          Navigator.of(context).pop(); //離開dialog，並回傳
                        },
                        child: Text('yes')
                    )
                  ],
                )
          )
    );
  }

  ///若項目有更變，則呼叫此函式更新 TimePage 顯示的時間
  void _updateTime() {
    if(timePageKey.currentState != null) {
      try {
        if(!timePageKey.currentState!.controller.isAnimating) {
          timePageKey.currentState!.controller.addListener(() {
            if(timePageKey.currentState!.controller.value == 1) { ///倒數結束，需刪除當前項目並前進至下一個項目
              if(items[0].isWork) {
                total().tl[0] += items[0].dtime.inSeconds.toDouble();
              }
              else {
                total().tl[1] += items[0].dtime.inSeconds.toDouble();
              }

              if(items.length > 1) items.removeAt(0);
              timePageKey.currentState!.controller.value = 0;
              _updateTime();

              timePageKey.currentState!.setState(() {});
            }
          });

          timePageKey.currentState!.controller.duration = items.isNotEmpty ? items[0].dtime : Duration(seconds: 0);
          timePageKey.currentState!.controller.reset();
          timePageKey.currentState!.controller.value = 0;
          timePageKey.currentState!.clock_color = items[0].isWork ? Colors.red : Colors.green;
          timePageKey.currentState!.setState(() {});
        }
      } catch(e) {
        print("error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        Expanded(
          child: Stack(
            children: [
              TimePage(key: timePageKey,), //時鐘頁面
              Container( //按鈕，點擊後刪除當前項目，直接前往下一個項目
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.29,bottom: 9.8),
                child: GestureDetector(
                  onTap: () {
                    print(widget.tl[0]);
                    if(items.length > 1) items.removeAt(0);
                    _updateTime();
                    setState(() {});
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.skip_next_rounded,size: 32,color: Colors.white,),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(90)
                    ),
                  ),
                )
              )
            ],
          )
        ),

        GestureDetector( //上滑or點按開啟列表頁面
          onTap: () async {
            showListPage();
          },
          onVerticalDragUpdate: (details) {
            showListPage();
          },

          child: Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
            padding: EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Color(0xF000000),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Transform.rotate(
              alignment: Alignment.center,
              angle: _angle,
              child: Align(
                alignment: Alignment(0,0), // 圖示保持在中間
                child: Icon(Icons.keyboard_arrow_up, size: 22),
              ),
            )


          )
        ),

        SizedBox(height: 5,)
      ],
    );
  }
}

class Item {
  String time; //顯示的時間
  Duration dtime; //時間
  bool isWork; //工作狀態or休息狀態

  Item({required this.time,required this.isWork,required this.dtime});
}

///統計工作和休息時間 (單例模式)
class total {
  static final total _instance = total._internal();
  factory total() => _instance;
  List<double> tl = [0.0,0.0];

  total._internal();
}