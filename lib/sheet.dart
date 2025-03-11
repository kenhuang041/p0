import 'package:flutter/material.dart';
import 'package:p0/list.dart';

class MyChart extends StatefulWidget {

  @override
  MyChartState createState() => MyChartState();
}

class MyChartState extends State<MyChart> with SingleTickerProviderStateMixin {
  //計算每個項目所占的弧度
  late AnimationController _controller;
  late Animation<double> _animation;

  List<double> items = [1.0,1.0];
  List<double> nowTimes = [0.0,0.0];
  double t = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut
    );
    _animation.addListener(() {
      setState(() {});
    });
    //List<double> arc = [];
    /*for(int i=0; i<2; i++) {
      if(i == 0) {
        arc.add((items[i] * -360) * (3.14159 / 180));
      }
      else {
        arc.add((arc[i-1] + (items[i] * -360) * (3.14159 / 180)));
      }

      CurvedAnimation curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      );

      _controller.addListener(() {
        arc[i] =_controller.value;
        setState(() {});
      });

      _controller.forward();
    } */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateItems();
      _controller.forward(from: 0.0);
    });
    print("123");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateItems() {
    if(!mounted) return; //防止widget已銷毀時調用setSat

    setState(() {
      try {
        List tmp = total().tl;
        if(tmp != null) {
          nowTimes[0] = tmp[0];
          nowTimes[1] = tmp[1];

          items[0] = tmp[0];
          items[1] = tmp[1];
          t = (items[0]+items[1]);

          items[0] = items[0].isNaN ? 0.7 : items[0] /= t;
          items[1] = items[1].isNaN ? 0.3 : items[1] /= t;
        }
        else {
          items[0] = 0.5;
          items[1] = 0.5;
        }

        if(_controller.status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
      } catch (e) {

        print(e);
      }
      //print("$t DD");
      //print("${items[0]} ${items[1]}");
      //print("${total().tl[0]} ${total().tl[1]}");
    });
  }

  Widget TextPaint(String str,Color c,int size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size.toDouble(),
          height: size.toDouble(),
          color: c,
        ),
        SizedBox(width: size/3,),
        Text("$str",style: TextStyle(fontSize: (size+1).toDouble()),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(height: 100,),
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: PieChartPainter(
                values: items,
                colors: [Colors.red, Colors.green],
                animationValue: _controller.value
              ),
            ),
          ),

          SizedBox(height: 60,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextPaint("工作時間",Colors.red,12),
              SizedBox(width: 30,),
              TextPaint("休息時間",Colors.green,12),
            ],
          ),

          SizedBox(height: 30,),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 180,
            padding: const EdgeInsets.only(top: 10,left: 12),
            decoration: BoxDecoration(
              color: Color(0xB000000),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextPaint("你一共工作了${nowTimes[0].isNaN ? 0 : nowTimes[0].toInt()}秒鐘, 挺好的", Colors.red, 13),
                SizedBox(height: 5,),
                TextPaint("你一共休息了${nowTimes[1].isNaN ? 0 : nowTimes[1].toInt()}秒鐘, 休息太久了 ==", Colors.green, 13),
              ],
            ),
          )
        ],
      )
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double animationValue;

  PieChartPainter({
    required this.values,
    required this.colors,
    this.animationValue = 1.0
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60.0;

    double startAngle = -90 * (3.14 / 180); // 起始角度（從頂部開始）

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] * -360) * (3.14 / 180) * animationValue; // 百分比轉成弧度
      paint.color = colors[i];

      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle, // 轉成弧度
        sweepAngle, // 轉成弧度
        false, //中間會不會多一條槓?
        paint,
      );

      startAngle += sweepAngle; // 更新下一個圓弧的開始角度
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.animationValue != animationValue;
  }
}