import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../../components/contact_invitation_display.dart';
import 'account_page.dart';
import 'chats_page.dart';

class MainPager extends ConsumerStatefulWidget {
  const MainPager({super.key});

  @override
  MainPagerState createState() => MainPagerState();
}

class MainPagerState extends ConsumerState<MainPager>
    with TickerProviderStateMixin {
  //////////////////////////////////////////////////////////////////

  final _unfocusNode = FocusNode();

  final _pageController = PageController();
  var _currentPage = 0;

  final _selectedIconList = <IconData>[Icons.person, Icons.chat];
  // final _unselectedIconList = <IconData>[
  //   Icons.chat_outlined,
  //   Icons.person_outlined
  // ];
  final _fabIconList = <IconData>[
    Icons.person_add_sharp,
    Icons.add_comment_sharp,
  ];
  final _labelList = <String>[
    translate('pager.account'),
    translate('pager.chats'),
  ];
  final List<Widget> _bottomBarPages = [
    const AccountPage(),
    const ChatsPage(),
  ];

  //////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          // _hideBottomBarAnimationController.reverse();
          // _fabAnimationController.forward(from: 0);
          break;
        case ScrollDirection.reverse:
          // _hideBottomBarAnimationController.forward();
          // _fabAnimationController.reverse(from: 1);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  BottomBarItem buildBottomBarItem(int index) {
    final theme = Theme.of(context);
    return BottomBarItem(
      title: Text(_labelList[index]),
      icon: Icon(_selectedIconList[index],
          color: theme.colorScheme.onPrimaryContainer),
      selectedIcon: Icon(_selectedIconList[index],
          color: theme.colorScheme.onPrimaryContainer),
      backgroundColor: theme.colorScheme.onPrimaryContainer,
      //unSelectedColor: theme.colorScheme.primaryContainer,
      //selectedColor: theme.colorScheme.primary,
      //badge: const Text('9+'),
      //showBadge: true,
    );
  }

  List<BottomBarItem> _buildBottomBarItems() {
    final bottomBarItems = List<BottomBarItem>.empty(growable: true);
    for (var index = 0; index < _bottomBarPages.length; index++) {
      final item = buildBottomBarItem(index);
      bottomBarItems.add(item);
    }
    return bottomBarItems;
  }

  Future<void> _onNewContactInvitation(BuildContext context) async {
    Scaffold.of(context).showBottomSheet<void>((context) => SizedBox(
        height: 200, child: Center(child: ContactInvitationDisplay())));
  }

  Future<void> _onNewChat(BuildContext context) async {
    //
  }

  Future<void> _onFloatingActionButtonPressed(BuildContext context) async {
    if (_currentPage == 0) {
      // New contact invitation
      return _onNewContactInvitation(context);
    } else if (_currentPage == 1) {
      // New chat
      return _onNewChat(context);
    }
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: PageView(
            controller: _pageController,
            //physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
                _bottomBarPages.length, (index) => _bottomBarPages[index]),
          )),
      // appBar: AppBar(
      //   toolbarHeight: 24,
      //   title: Text(
      //     'C',
      //     style: Theme.of(context).textTheme.headlineSmall,
      //   ),
      // ),
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: theme.colorScheme.primaryContainer,
        // gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: <Color>[
        //       theme.colorScheme.primary,
        //       theme.colorScheme.primaryContainer,
        //     ]),
        option: AnimatedBarOptions(
          // iconSize: 32,
          //barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.animated,
          inkEffect: true,
          inkColor: theme.colorScheme.primary,
          //opacity: 0.3,
        ),
        items: _buildBottomBarItems(),
        hasNotch: true,
        fabLocation: StylishBarFabLocation.end,
        currentIndex: _currentPage,
        onTap: (index) async {
          await _pageController.animateToPage(index,
              duration: 250.ms, curve: Curves.easeInOut);
          setState(() {
            _currentPage = index;
          });
        },
      ),

      floatingActionButton: FloatingActionButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          //foregroundColor: theme.colorScheme.secondary,
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            _fabIconList[_currentPage],
            color: theme.colorScheme.onSecondaryContainer,
          ),
          onPressed: () async => _onFloatingActionButtonPressed(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
