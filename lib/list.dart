import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p0/time.dart';

class ListPage extends StatefulWidget {
  //final Function(Duration)? onTimerUpdate;
  //const ListPage({Key? key, this.onTimerUpdate}) : super(key: key);

  @override
  ListState createState() => ListState();
}

class ListState extends State<ListPage>{
  GlobalKey<TimeState> timePageKey = GlobalKey<TimeState>();
  final List<Item> items = List.generate(1, (int i) => Item(time: '0:25:00',isWork: true,dtime: Duration(seconds: 1500) ));
  int selected = 0;

  void showListPage() {
    showModalBottomSheet(
        isScrollControlled: true, //?
        //showDragHandle: true,
        context: context,
        builder: (context) => StatefulBuilder( //不影響父元件的情況下更新表單狀態
          builder: (context,setModalState) => Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.5, //顯示高度
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
                        Duration nowTime = await _AddListItem();
                        //print(nowTime.inSeconds);
                        items.add(Item(
                            time: '${nowTime.inHours.toString()}:${(nowTime.inMinutes % 60).toString().padLeft(2,'0')}:${(nowTime.inSeconds % 60).toString().padLeft(2,'0')}',
                            isWork: selected == 0,
                            dtime: nowTime,
                        ));
                        setModalState(() {});

                        _updateTime();
                      },
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size(368, 30),
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
                              color: items[i].isWork ? Colors.blue[100] : Colors.red[100],
                              elevation: 0,

                              child: ListTile(
                                title: Text('${items[i].time}',style: TextStyle(fontSize: 22,),),
                                subtitle: Text((items[i].isWork ? '工作時間...' : '休息時間!'),style: TextStyle(fontSize: 12),),
                                leading: items[i].isWork ? Icon(Icons.work_outline) : Icon(Icons.videogame_asset),
                                trailing: IconButton(
                                    onPressed: () {
                                      items.removeAt(i);
                                      setModalState(() {});
                                      _updateTime();
                                    },
                                    icon: Icon(Icons.delete_outline)
                                ),
                                //Icon(Icons.timer_outlined)
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

  Future<Duration> _AddListItem() async {
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
                            initialTimerDuration: time,
                            onTimerDurationChanged: (value) {
                              setDialogState(() {
                                time = value;
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
                              selected: selected == 0,
                              selectedColor: Colors.blue[100],
                              onSelected: (value) {
                                setDialogState(() {
                                  selected = 0;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90),
                              ),
                              avatar: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                //radius: 200,
                                maxRadius: 100,
                                minRadius: 80,
                              ),

                            ),

                            SizedBox(width: 10,),

                            ChoiceChip(
                              label: Text('休息'),
                              selected: selected == 1,
                              selectedColor: Colors.red[100],
                              onSelected: (value) {
                                setDialogState(() {
                                  selected = 1;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(90),
                              ),
                              avatar: CircleAvatar(
                                backgroundColor: Colors.red[100],
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
                          Navigator.of(context).pop(time);
                          //return ;
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
          timePageKey.currentState!.controller.duration = items.isNotEmpty ? items[0].dtime : Duration(seconds: 2287);
          timePageKey.currentState!.controller.reset();

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
          child: TimePage(key: timePageKey,)
        ),

        GestureDetector(
          onTap: () {
            showListPage();
          },
          onVerticalDragUpdate: (details) {
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
            child: Icon(Icons.keyboard_arrow_up,size: 22,),
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