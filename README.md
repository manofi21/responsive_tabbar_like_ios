### :construction: Melakukan set up widget
#### Buat master tabbar dengan widget standar berikut di file `master_tabbar`:
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../model/master_tabbar_page_model.dart';

/// Current Condition of Widget:
/// 1. onPressed : Disable
/// 2. Icon color : Disable
/// 3. TextButton.styleFrom backgroundColor : Disable

class MasterTabbar extends StatefulWidget {
  final List<MasterTabbarPageModel> listWidget;
  const MasterTabbar({
    Key? key,
    required this.listWidget,
  }) : super(key: key);

  @override
  State<MasterTabbar> createState() => _MasterTabbarState();
}

class _MasterTabbarState extends State<MasterTabbar> {
  var _keys = <GlobalKey>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _keys = List.generate(widget.listWidget.length, ((index) => GlobalKey(debugLabel: "Widget $index")));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // this is the TabBar
        SizedBox(
          height: 49.0,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: widget.listWidget.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                key: _keys[index],
                padding: const EdgeInsets.all(6.0),
                child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                      ),
                      onPressed: () {},
                      child: Icon(
                        widget.listWidget[index].icon,
                      ),
                    ),
              );
            },
          ),
        ),
        Flexible(
          child: TabBarView(
            children: widget.listWidget.map((e) => e.page).toList(),
          ),
        ),
      ],
    );
  }
}
```

#### Kemudian panggil di dalam kelas statefull di file `tab_bar_page.dart`:
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:reusable_widget_tabbar_best_practice/core/widget/master_tabbar.dart';

import '../../../core/model/master_tabbar_page_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MasterTabbar(
        listWidget: widget.listWidget,
      ),
    );
  }
}
``` 

#### Dan yang terpenting panggil di main dengan list icon sudah di deklarasi:
```dart

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
```

### :video_game: Handling Tab dan Scroll Controller
#### Inisiasi controller variable 
mixin class statefull dengan class `TickerProviderStateMixin` dan tambahkan variable controller tab dan scroll di dalam `_TabBarPageState` di file `tab_bar_page.dart`:

```dart
class _TabBarPageState extends State<TabBarPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;
```

#### Mulai dengan deklarasi tab controller dan implementasi di `TabBarView`
Di dalam initState inisiasi tab controller dengan length sesuai dengan variable yang sudah di deklarasikan.
```dart
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: widget.listWidget.length);
  }
```

Kemudia di `MasterTabBar` tambahkan juga variable tab controller controller nya (yang berada di `master_tabbar.dart`).
```dart
class MasterTabbar extends StatefulWidget {
  final TabController tabController;
```

Lalu di file tersebut juga tambahkan function `animateTo` dari tabController di `onPressed` dari parameter `TextButton`.
```dart
    onPressed: () {
        widget.tabController.animateTo(index);
    },
```

Lalu deklarasi juga di parameter controller `TabBarView`.
```dart
    child: TabBarView(
        controller: widget.tabController,
```

#### Handle addListener tab controller
Tambahkan variable baru seperti berikut:
```dart
  bool _buttonTap = false;
  int _currentIndex = 0;
  int _prevControllerIndex = 0;
  double _aniValue = 0.0;
  double _prevAniValue = 0.0;
```

Lalu buat 2 function untuk handle update current index dan handle tab change.
```dart
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
      setState(() {
        _currentIndex = index;
      });
    }
  }
``` 

Dan tambahkan addListener untuk tab controller di initState/didChangeDependencies.
```dart
    widget.tabController.addListener(_handleTabChange);
```

#### Lalu deklarasi scroll controller dan implementasi di `ListView.builder`
Kembali ke file `tab_bar_page.dart` dan deklarasi kan variable scroll controllernya.
```dart
    _scrollController =  ScrollController();
```

Dan buat lagi parameter di `MasterTabbar`.
```dart
class MasterTabbar extends StatefulWidget {
  final TabController tabController;
  final ScrollController scrollController;
```

Dan janga lupa pasang di controller `ListView.builder`:
```dart
    child: ListView.builder(
        controller: widget.scrollController,
```
### :clapper: Handling animation controller
#### Deklarasi Animation Controller
Buat file `constant.dart` untuk menampung color berikut:
```dart
  // active button's foreground color
  final foregroundOn = Colors.white;
  final foregroundOff = Colors.black;

  // active button's background color
  final backgroundOn = Colors.blue;
  final backgroundOff = Colors.grey[300];
```

Buat variable dan dekalarasi di initState di file di `tab_bar_page.dart`.
```dart
  late AnimationController _animationControllerOn;

  late AnimationController _animationControllerOff;

  late Animation<Color?> _colorTweenBackgroundOn;
  late Animation<Color?> _colorTweenBackgroundOff;

  late Animation<Color?> _colorTweenForegroundOn;
  late Animation<Color?> _colorTweenForegroundOff;
```
```dart
  @override
  void initState() {
    super.initState();
    ...

    _animationControllerOff =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 75));
    // so the inactive buttons start in their "final" state (color)
    _animationControllerOff.value = 1.0;
    _colorTweenBackgroundOff = ColorTween(begin: backgroundOn, end: backgroundOff)
            .animate(_animationControllerOff);
    _colorTweenForegroundOff = ColorTween(begin: foregroundOn, end: foregroundOff)
            .animate(_animationControllerOff);

    _animationControllerOn =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 150));

    _animationControllerOn.value = 1.0;
    _colorTweenBackgroundOn = ColorTween(begin: backgroundOff, end: backgroundOn)
            .animate(_animationControllerOn);
    _colorTweenForegroundOn = ColorTween(begin: foregroundOff, end: foregroundOn)
            .animate(_animationControllerOn);
  }
```

Dan tambahkan parameternya juga di `master_tabbar.dart`.
```dart
  final AnimationController animationControllerOn;
  final AnimationController animationControllerOff;

  final Animation<Color?> colorTweenBackgroundOn;
  final Animation<Color?> colorTweenBackgroundOff;

  final Animation<Color?> colorTweenForegroundOn;
  final Animation<Color?> colorTweenForegroundOff;

  final List<MasterTabbarPageModel> listWidget;
  const MasterTabbar({
    Key? key,
    ...
    required this.animationControllerOn,
    required this.animationControllerOff,
    required this.colorTweenBackgroundOn,
    required this.colorTweenBackgroundOff,
    required this.colorTweenForegroundOn,
    required this.colorTweenForegroundOff,
    required this.listWidget,
  }) : super(key: key);
```

#### Buat function handing forward dan reset animasi
Buat function untuk menjalankan animasi dan set/pasang di `_setCurrentIndex`.
Jadi function ini yang bertugas menjalankan animasi atau mereset animasi tersebut.
Panggil dalam function `_setCurrentIndex` di dalam kondisi `index != _currentIndex`
```dart
  void _setCurrentIndex(int index) {
    if (index != _currentIndex) {
        ...
        _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    // reset the animations so they're ready to go
    widget.animationControllerOn.reset();
    widget.animationControllerOff.reset();

    // run the animations!
    widget.animationControllerOn.forward();
    widget.animationControllerOff.forward();
  }
```

#### Membungkus TextButton dengan AnimatedBuilder
Ganti widget di text button yang sebelumnya seperti ini:
```dart
    return Padding(
            key: _keys[index],
            padding: const EdgeInsets.all(6.0),
            child: TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7.0),
                ),
            ),
            onPressed: () {
                setState(() {
                _buttonTap = true;
                });

                widget.tabController.animateTo(index);
            },
            child: Icon(
                widget.listWidget[index].icon,
            ),
        ),
    );
```

Dibungkus dengan `AnimatedBuilder` dengan animation fokus pada variable _colorTweenBackgroundOn.
```dart
    return Padding(
        key: _keys[index],
        padding: const EdgeInsets.all(6.0),
        child: AnimatedBuilder(
                controller: widget.scrollController,
                builder: (context, child) => TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0)),
                ),
                onPressed: () {
                    setState(() {
                        _buttonTap = true;
                    });

                    widget.tabController.animateTo(index);

                    _setCurrentIndex(index);
                },
                child: Icon(
                    widget.listWidget[index].icon,
                ),
            ),
        ),
    );
```

#### Membuat function untuk return background color dan foreground color. Setelah itu implementasi di button `TextButton`.
```dart
  Color? _getBackgroundColor(int index) {
    if (index == _currentIndex) {
      return _colorTweenBackgroundOn.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenBackgroundOff.value;
    } else {
      return backgroundOff;
    }
  }

  Color? _getForegroundColor(int index) {
    if (index == _currentIndex) {
      return _colorTweenForegroundOn.value;
    } else if (index == _prevControllerIndex) {
      return _colorTweenForegroundOff.value;
    } else {
      return foregroundOff;
    }
  }
```

Lalu di deklarasikan `_getBackgroundColor` di backgroundColor `TextButton` dan `_getForegroundColor` di `Icon`.
```dart
TextButton(
    style: TextButton.styleFrom(
        backgroundColor: _getBackgroundColor(index),
        ...
    ),
    onPressed: () {...},
    child: Icon(
        _icons[index],
        color: _getForegroundColor(index),
    ),
)
```

#### Handling ketika Swipe di `TabBarView`, `TextButton` juga ikut Berubah
```dart
  _handleTabAnimation() {
    _aniValue = _controller.animation?.value ?? _aniValue;

    if (!_buttonTap && ((_aniValue - _prevAniValue).abs() < 1)) {
      _setCurrentIndex(_aniValue.round());
    }

    _prevAniValue = _aniValue;
  }
```

Lalu tambahakan listenernya di animation di initState/didChangeDependencies.
```dart
    widget.tabController.animation?.addListener(_handleTabAnimation);
```

#### Menambahkan kondisi TabBar scroll otomatis jika current TabBar tidak di UI
Pertama buat functionnya:
```dart
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
```

Lalu implementasi di onPressed `TextButton` dan function `_setCurrentIndex`
```dart
    onPressed: () {
        setState(() {
        _buttonTap = true;
        });

        widget.tabController.animateTo(index);

        _setCurrentIndex(index);

        _scrollTo(index);
    },
```

```dart
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
```