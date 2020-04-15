import 'package:flutter/material.dart';
import 'package:union_tabs/union_tabs.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<String> tabsText = ["一", "二", "三", "四", "五"];
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: tabsText.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
              controller: _controller,
              tabs: tabsText.map((it) => Tab(text: it)).toList()),
        ),
        body: TabBarView(
          controller: _controller,
          children: tabsText.map((it) => Center(child: Text(it))).toList(),
        ));
  }
}
