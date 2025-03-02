import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  @override
  ListState createState() => ListState();
}

class ListState extends State<ListPage>{
  final List<String> items = List.generate(8, (int i) => '$i');

  void showListPage() {
    showModalBottomSheet(
        isScrollControlled: true,
        //showDragHandle: true,
        context: context,
        builder: (context) => StatefulBuilder( //不影響父元件的情況下更新表單狀態
          builder: (context,setModalState) => Container(
            padding: EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
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
                      onPressed: () {

                      },
                      style: OutlinedButton.styleFrom(
                        fixedSize: Size(171, 30),
                        side: BorderSide(width: 2.0,),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        )
                      ),
                      child: Icon(Icons.add,size: 28,color: Colors.black,),
                    ),

                    SizedBox(width: 10,),

                    OutlinedButton(
                      onPressed: () {

                      },
                      style: OutlinedButton.styleFrom(
                          fixedSize: Size(171, 30),
                          side: BorderSide(width: 2.0,),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )
                      ),
                      child: Icon(Icons.delete_outline,size: 28,color: Colors.black,),
                    ),
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
                        setState(() {}); //更新主頁面
                      },
                      children: [
                        for (String item in items)
                          ListTile(
                            key: ValueKey(item),
                            title: Text('Item$item'),
                            leading: Icon(Icons.satellite_outlined),
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


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.keyboard_arrow_up,size: 26,),
      )
    );
  }
}