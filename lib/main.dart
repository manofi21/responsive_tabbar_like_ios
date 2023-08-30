import 'package:flutter/material.dart';
import 'package:reusable_widget_tabbar_best_practice/core/model/master_tabbar_page_model.dart';

import 'feature/presentation/widget/tab_bar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _icons =  [
    Icons.star,
    Icons.whatshot,
    Icons.call,
    Icons.contacts,
    Icons.email,
    Icons.donut_large
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: TabBarPage(
        listWidget: _icons.map((e) => MasterTabbarPageModel(icon: e, page: Icon(e))).toList(),
      ),
    );
  }
}
