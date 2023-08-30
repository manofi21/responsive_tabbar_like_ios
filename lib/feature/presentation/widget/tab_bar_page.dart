// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:reusable_widget_tabbar_best_practice/core/widget/master_tabbar.dart';

import '../../../core/model/master_tabbar_page_model.dart';

  // active button's foreground color
  const foregroundOn = Colors.white;
  const foregroundOff = Colors.black;

  // active button's background color
  const backgroundOn = Colors.blue;
  final backgroundOff = Colors.grey[300];

class TabBarPage extends StatefulWidget {
  final List<MasterTabbarPageModel> listWidget;
  const TabBarPage({
    Key? key,
    required this.listWidget,
  }) : super(key: key);

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;

  /// Controller animation
  late AnimationController _animationControllerOn;
  late AnimationController _animationControllerOff;

  late Animation<Color?> _colorTweenBackgroundOn;
  late Animation<Color?> _colorTweenBackgroundOff;

  late Animation<Color?> _colorTweenForegroundOn;
  late Animation<Color?> _colorTweenForegroundOff;


  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: widget.listWidget.length);
    _scrollController = ScrollController();

    _animationControllerOff = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 75));
    _animationControllerOff.value = 1.0;
    _colorTweenBackgroundOff =
        ColorTween(begin: backgroundOn, end: backgroundOff)
            .animate(_animationControllerOff);
    _colorTweenForegroundOff =
        ColorTween(begin: foregroundOn, end: foregroundOff)
            .animate(_animationControllerOff);

    _animationControllerOn = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _animationControllerOn.value = 1.0;
    _colorTweenBackgroundOn =
        ColorTween(begin: backgroundOff, end: backgroundOn)
            .animate(_animationControllerOn);
    _colorTweenForegroundOn =
        ColorTween(begin: foregroundOff, end: foregroundOn)
            .animate(_animationControllerOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MasterTabbar(
        tabController: _tabController,
        scrollController: _scrollController,
        animationControllerOff: _animationControllerOff,
        animationControllerOn: _animationControllerOn,
        colorTweenBackgroundOff: _colorTweenBackgroundOff,
        colorTweenBackgroundOn: _colorTweenBackgroundOn,
        colorTweenForegroundOff: _colorTweenForegroundOff,
        colorTweenForegroundOn: _colorTweenForegroundOn,
        listWidget: widget.listWidget,
      ),
    );
  }
}
