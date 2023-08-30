// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import '../constant/constant.dart';
import '../model/master_tabbar_page_model.dart';

/// Current Condition of Widget:
/// 1. onPressed : Disable
/// 2. Icon color : Disable
/// 3. TextButton.styleFrom backgroundColor : Disable

class MasterTabbar extends StatefulWidget {
  final TabController tabController;
  final ScrollController scrollController;

  final AnimationController animationControllerOn;
  final AnimationController animationControllerOff;

  final Animation<Color?> colorTweenBackgroundOn;
  final Animation<Color?> colorTweenBackgroundOff;

  final Animation<Color?> colorTweenForegroundOn;
  final Animation<Color?> colorTweenForegroundOff;

  final List<MasterTabbarPageModel> listWidget;
  const MasterTabbar({
    Key? key,
    required this.tabController,
    required this.scrollController,
    required this.animationControllerOn,
    required this.animationControllerOff,
    required this.colorTweenBackgroundOn,
    required this.colorTweenBackgroundOff,
    required this.colorTweenForegroundOn,
    required this.colorTweenForegroundOff,
    required this.listWidget,
  }) : super(key: key);

  @override
  State<MasterTabbar> createState() => _MasterTabbarState();
}

class _MasterTabbarState extends State<MasterTabbar> {
  var _keys = <GlobalKey>[];

  bool _buttonTap = false;
  int _currentIndex = 0;
  int _prevControllerIndex = 0;
  double _aniValue = 0.0;
  double _prevAniValue = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _keys = List.generate(widget.listWidget.length,
        ((index) => GlobalKey(debugLabel: "Widget $index")));

    // Listen all function in here
    widget.tabController.addListener(_handleTabChange);
    widget.tabController.animation?.addListener(_handleTabAnimation);
  }

  // 1. Adding kondition for change TabBarView after click Text Button as TabBar
  // runs when the displayed tab changes
  void _handleTabChange() {
    final tabIndex = widget.tabController.index;
    if (_buttonTap) _setCurrentIndex(tabIndex);

    if ((tabIndex == _prevControllerIndex) || (tabIndex == _aniValue.round())) {
      _buttonTap = false;
    }

    _prevControllerIndex = tabIndex;
  }

  void _setCurrentIndex(int index) {
    if (index != _currentIndex) {
      setState(
        () {
          _currentIndex = index;
        },
      );

      _triggerAnimation();

      _scrollTo(index);
    }
  }

  // 2.a Adding animation tabbar color
  void _triggerAnimation() {
    // reset the animations so they're ready to go
    widget.animationControllerOn.reset();
    widget.animationControllerOff.reset();

    // run the animations!
    widget.animationControllerOn.forward();
    widget.animationControllerOff.forward();
  }

  Color? _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      return widget.colorTweenBackgroundOn.value;
    } else if (index == _prevControllerIndex) {
      return widget.colorTweenBackgroundOff.value;
    } else {
      return backgroundOff;
    }
  }

  Color? _getForegroundColor(int index) {
    if (index == _currentIndex) {
      return widget.colorTweenForegroundOn.value;
    } else if (index == _prevControllerIndex) {
      return widget.colorTweenForegroundOff.value;
    } else {
      return foregroundOff;
    }
  }

  // 2.b Linking TabBarView with Text Button
  // runs during the switching tabs animation
  void _handleTabAnimation() {
    _aniValue = widget.tabController.animation?.value ?? _aniValue;

    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      _setCurrentIndex(_aniValue.round());
    }

    _prevAniValue = _aniValue;
  }

  // 3. Adding the scroll responsive
  void _scrollTo(int index) {
    // get the screen width. This is used to check if we have an element off screen
    double screenWidth = MediaQuery.of(context).size.width;

    // get the button we want to scroll to
    var renderBox = _keys[index].currentContext?.findRenderObject();
    if (renderBox is! RenderBox) {
      return;
    }

    double size = renderBox.size.width;

    double position = renderBox.localToGlobal(Offset.zero).dx;

    // this is how much the button is away from the center of the screen and how much we must scroll to get it into place
    double offset = (position + size / 2) - screenWidth / 2;

    // if the button is to the left of the middle
    if (offset < 0) {
      renderBox = _keys[0].currentContext?.findRenderObject();
      if (renderBox is! RenderBox) {
        return;
      }
      // get the position of the first button of the TabBar
      position = renderBox.localToGlobal(Offset.zero).dx;

      // if the offset pulls the first button away from the left side, we limit that movement so the first button is stuck to the left side
      if (position > offset) offset = position;
    } else {
      // if the button is to the right of the middle

      // get the last button
      renderBox = _keys[widget.listWidget.length - 1]
          .currentContext
          ?.findRenderObject();
      if (renderBox is! RenderBox) {
        return;
      }
      // get its position
      position = renderBox.localToGlobal(Offset.zero).dx;
      // and size
      size = renderBox.size.width;

      // if the last button doesn't reach the right side, use it's right side as the limit of the screen for the TabBar
      if (position + size < screenWidth) screenWidth = position + size;

      // if the offset pulls the last button away from the right side limit, we reduce that movement so the last button is stuck to the right side limit
      if (position + size - offset < screenWidth) {
        offset = position + size - screenWidth;
      }
    }

    // scroll the calculated ammount
    widget.scrollController.animateTo(offset + widget.scrollController.offset,
        duration: const Duration(milliseconds: 150), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // this is the TabBar
        SizedBox(
          height: 49.0,
          child: ListView.builder(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: widget.listWidget.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                key: _keys[index],
                padding: const EdgeInsets.all(6.0),
                child: AnimatedBuilder(
                  animation: widget.colorTweenBackgroundOn,
                  builder: (context, child) => TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _getBackgroundColor(index),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0)),
                    ),
                    onPressed: () {
                      setState(() {
                        _buttonTap = true;
                      });

                      widget.tabController.animateTo(index);

                      _setCurrentIndex(index);

                      _scrollTo(index);
                    },
                    child: Icon(
                      widget.listWidget[index].icon,
                      color: _getForegroundColor(index),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Flexible(
          child: TabBarView(
            controller: widget.tabController,
            children: widget.listWidget.map((e) => e.page).toList(),
          ),
        ),
      ],
    );
  }
}
