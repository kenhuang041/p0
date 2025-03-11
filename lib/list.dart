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

class ListState extends State<ListPage> with SingleTickerProviderStateMixin{
  GlobalKey<TimeState> timePageKey = GlobalKey<TimeState>();
  final List<Item> items = [Item(time: '0:00:03',isWork: true,dtime: Duration(seconds: 3) ),Item(time: '0:00:02',isWork: false,dtime: Duration(seconds: 2) )];
  List<int> totoal = [0,0];
  late AnimationController controller;
  double _angle = 0.0;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    );
    controller.addListener(() {
      setState(() {
        _angle = (controller.value * 30) * (math.pi / 180);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTime();
    });
  }

  void showListPage() {
    showModalBottomSheet(
        isScrollControlled: true, //?
        //showDragHandle: true,
        context: context,
        builder: (context) => StatefulBuilder( //不影響父元件的情況下更新表單狀態
          builder: (context,setModalState) => Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7, //顯示高度
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding( //拖動欄位
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
                    OutlinedButton(
                      onPressed: () async {
                        //Duration nowTime = await _AddListItem();
                        //print(nowTime.inSeconds);
                        Duration nowTime = Duration(seconds: 5);
                        if(items[items.length-1]?.isWork == true) nowTime = Duration(seconds: 2);

                        items.add(Item(
                            time: '${nowTime.inHours.toString()}:${(nowTime.inMinutes % 60).toString().padLeft(2,'0')}:${(nowTime.inSeconds % 60).toString().padLeft(2,'0')}',
                            isWork: items[items.length-1]?.isWork == false,
                            dtime: nowTime,
                        ));
                        selected = (selected == 1) ? 0 : 1;
                        setModalState(() {});

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

                    /* OutlinedButton(
                      onPressed: () {

                      },
                      style: OutlinedButton.styleFrom(
                          fixedSize: Size(171, 30),
                          side: BorderSide(width: 2.0,), //!
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )
                      ),
                      child: Icon(Icons.delete_outline,size: 28,color: Colors.black,),
                    ), */
                  ],
                ),

                SizedBox(height: 5,),
                Expanded(
                    child: ReorderableListView(
                      onReorder: (int oldIndex,int newIndex) {
                        setModalState(() { //更新表單
                          if(newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          var tmp = items.removeAt(oldIndex);
                          items.insert(newIndex, tmp);
                        });
                        //UpdateTime();
                        //widget.onTimerUpdate?.call(n)
                        setState(() {}); //更新主頁面
                        _updateTime();
                      },
                      children: [
                        for (int i=0; i<items.length; i++)
                          Container(
                            key: ValueKey(i),
                            padding: EdgeInsets.only(bottom: 5),
                            child: Card(
                              //color: items[i].isWork ? Colors.blue[100] : Colors.red[100],
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
                                trailing: IconButton(
                                    onPressed: () async {
                                      if(items.length > 1) items.removeAt(i);
                                      setModalState(() {});
                                      _updateTime();
                                    },
                                    icon: Icon(Icons.delete_outline)
                                ),
                                //Icon(Icons.timer_outlined)
                                onTap: () async {
                                  //print("${items[i].time} + ${items[i].dtime} + ${items[i].isWork}");
                                  await _UpdateListItem(items[i],i);
                                  setModalState(() {});
                                  _updateTime();
                                  setState(() {});
                                },
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

    controller.reverse();
  }

  Future<Duration> _UpdateListItem(Item item,int j) async {
    Duration time = Duration(seconds: 60);

    Duration result = await showDialog(
        context: context,
        builder: (context) =>
          StatefulBuilder(
            builder: (context,setDialogState) =>
                AlertDialog(
                  title: Text('倒數計時時間:'),
                  content: Container(
                    // 設置容器的寬度來適應對話框
                    width: double.maxFinite,
                    // 使用 ConstrainedBox 來設置合理的高度約束
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
                    TextButton(
                        onPressed: () {
                          items[j].time = '${item.dtime.inHours.toString()}:${(item.dtime.inMinutes % 60).toString().padLeft(2,'0')}:${(item.dtime.inSeconds % 60).toString().padLeft(2,'0')}';
                          items[j].dtime = item.dtime;
                          items[j].isWork = item.isWork;

                          /*time: '${nowTime.inHours.toString()}:${(nowTime.inMinutes % 60).toString().padLeft(2,'0')}:${(nowTime.inSeconds % 60).toString().padLeft(2,'0')}',
                            isWork: selected == 1,
                            dtime: nowTime,*/
                          Navigator.of(context).pop(time);
                        },
                        child: Text('yes')
                    )
                  ],
                )
          )
    );

    return result;
  }

  Future<Duration> ListFirstItem() async {
    print(items[0].dtime.inSeconds.toString());
    return items[0].dtime;
  }

  void _updateTime() {
    if(timePageKey.currentState != null) {
      try {
        if(!timePageKey.currentState!.controller.isAnimating) {
          timePageKey.currentState!.controller.addListener(() {
            if(timePageKey.currentState!.controller.value == 1) {
              if(items[0].isWork) {
                //print("${totoal[0]}   ${items[0].dtime.inSeconds.toInt()}");
                total().tl[0] += items[0].dtime.inSeconds.toDouble();
                //print("${totoal[0]}   ${items[0].dtime.inSeconds.toInt()}");
              }
              else {
                total().tl[1] += items[0].dtime.inSeconds.toDouble();
              }

              if(items.length > 1) items.removeAt(0);
              timePageKey.currentState!.controller.value = 0;
              _updateTime();

              //print("${total().tl[0]} ++ ${total().tl[1]}");
              //timePageKey.currentState!.controller.reset();
              timePageKey.currentState!.setState(() {});
            }
          });

          timePageKey.currentState!.controller.duration = items.isNotEmpty ? items[0].dtime : Duration(seconds: 2287);
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

  List listtotalTime() {
    return totoal;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        Expanded(
          child: Stack(
            children: [
              TimePage(key: timePageKey,),
              Container(
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

        GestureDetector(
          onTap: () async {
            //await controller.forward();
            showListPage();
          },
          onVerticalDragUpdate: (details) {
            //controller.forward();
            showListPage();
          },

          child: Container( //展開表單欄位
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
  String time;
  Duration dtime;
  bool isWork;

  Item({required this.time,required this.isWork,required this.dtime});
}

class total {
  static final total _instance = total._internal();
  factory total() => _instance;
  List<double> tl = [0.0,0.0];

  total._internal();
}