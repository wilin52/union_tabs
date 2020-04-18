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
  List<String> tabsText = ["一", "二"];
  List<String> secondTabsText = ["one", "two", "three", "four", "five"];
  TabController _controller;
  TabController _childController;

  @override
  void initState() {
    _controller = TabController(length: tabsText.length, vsync: this);
    _childController =
        TabController(length: secondTabsText.length, vsync: this);
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
        body: UnionOuterTabBarView(
          controller: _controller,
          children: _createTabContent(),
        ));
  }

  List<Widget> _createTabContent() {
    List<Widget> tabContent = List();
    tabContent.add(Center(child: Text(tabsText[0])));
    final child = Column(
      children: <Widget>[
        TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black45,
            controller: _childController,
            tabs: secondTabsText.map((it) => Tab(text: it)).toList()),
        Expanded(
          child: UnionInnerTabBarView(
              controller: _childController,
              children:
                  secondTabsText.map((it) => Center(child: Text(it))).toList()),
        )
      ],
    );
    tabContent.add(child);
    return tabContent;
  }

  @override
  void dispose() {
    _controller.dispose();
    _childController.dispose();
    super.dispose();
  }
}
