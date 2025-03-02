import 'package:flutter/material.dart';
import 'package:p0/list.dart';
import 'package:p0/time.dart';

void main() {
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
  //

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  static List<String> items = List.generate(20, (int i) => '$i');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: TimePage(),
      ),
    );
  }



}
