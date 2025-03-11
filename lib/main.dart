import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:p0/list.dart';
import 'package:p0/sheet.dart';

void main() {
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack, overlays: []);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int current = 0;
  var items = [ListPage(),MyChart()];
  Key chartKey = UniqueKey();
  //final GlobalKey<MyChartState> chartKey = GlobalKey<MyChartState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 50,),
            Container(
              width: 100,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.black12,width: 2),
                borderRadius: BorderRadius.circular(10)
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    child: Icon(CupertinoIcons.clock,color: current == 0 ? Colors.black : Colors.black38,),
                    onTap: () {
                      setState(() {
                        current = 0;
                      });
                    },
                  ),
                  SizedBox(width: 10,),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.black12,
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                    child: Icon(CupertinoIcons.chart_bar_circle,color: current == 1 ? Colors.black : Colors.black38,),
                    onTap: () {
                      setState(() {
                        if(current != 1) {
                          chartKey = UniqueKey();
                        }
                        current = 1;
                        /*WidgetsBinding.instance.addTimingsCallback((_) {
                          if(chartKey.currentState != null) {
                            chartKey.currentState!.updateItems();
                          }
                        });*/
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: current,
                children: [
                  items[0],
                  // 使用键控制重建
                  KeyedSubtree(
                    key: chartKey,
                    child: MyChart(),
                  )
                ],
              ),
            )
          ]
      ),
    );
  }
}
