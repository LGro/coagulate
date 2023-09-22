import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../../components/bottom_sheet_action_button.dart';
import '../../components/paste_invite_dialog.dart';
import '../../components/send_invite_dialog.dart';
import '../../tools/tools.dart';
import 'account_page.dart';
import 'chats_page.dart';

class MainPager extends ConsumerStatefulWidget {
  const MainPager({super.key});

  @override
  MainPagerState createState() => MainPagerState();

  static MainPagerState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainPagerState>();
}

class MainPagerState extends ConsumerState<MainPager>
    with TickerProviderStateMixin {
  //////////////////////////////////////////////////////////////////

  final _unfocusNode = FocusNode();

  var _currentPage = 0;
  final pageController = PageController();

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
    pageController.dispose();
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

  Future<void> sendContactInvitationDialog(BuildContext context) async {
    await showDialog<void>(
        context: context,
        // ignore: prefer_expression_function_bodies
        builder: (context) {
          return const AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              contentPadding: EdgeInsets.only(
                top: 10,
              ),
              title: Text(
                'Send Contact Invite',
                style: TextStyle(fontSize: 24),
              ),
              content: SendInviteDialog());
        });
  }

  Future<void> pasteContactInvitationDialog(BuildContext context) async {
    await showDialog<void>(
        context: context,
        // ignore: prefer_expression_function_bodies
        builder: (context) {
          return const AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              contentPadding: EdgeInsets.only(
                top: 10,
              ),
              title: Text(
                'Paste Contact Invite',
                style: TextStyle(fontSize: 24),
              ),
              content: PasteInviteDialog());
        });
  }

  Widget _newContactInvitationBottomSheetBuilder(
      // ignore: prefer_expression_function_bodies
      BuildContext context) {
    return KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (ke) {
          if (ke.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.pop(context);
          }
        },
        child: SizedBox(
            height: 200,
            child: Column(children: [
              Text(translate('accounts_menu.invite_contact'),
                      style: Theme.of(context).textTheme.titleMedium)
                  .paddingAll(8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await sendContactInvitationDialog(context);
                      },
                      iconSize: 64,
                      icon: const Icon(Icons.contact_page)),
                  Text(translate('accounts_menu.create_invite'))
                ]),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      iconSize: 64,
                      icon: const Icon(Icons.qr_code_scanner)),
                  Text(translate('accounts_menu.scan_invite'))
                ]),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await pasteContactInvitationDialog(context);
                      },
                      iconSize: 64,
                      icon: const Icon(Icons.paste)),
                  Text(translate('accounts_menu.paste_invite'))
                ])
              ]).expanded()
            ])));
  }

  // ignore: prefer_expression_function_bodies
  Widget _onNewChatBottomSheetBuilder(BuildContext context) {
    return const SizedBox(height: 200, child: Center(child: Text("test")));
  }

  Widget _bottomSheetBuilder(BuildContext context) {
    if (_currentPage == 0) {
      // New contact invitation
      return _newContactInvitationBottomSheetBuilder(context);
    } else if (_currentPage == 1) {
      // New chat
      return _onNewChatBottomSheetBuilder(context);
    } else {
      // Unknown error
      return waitingPage(context);
    }
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = theme.extension<ScaleScheme>()!;

    return Scaffold(
      extendBody: true,
      backgroundColor: scale.grayScale.subtleBackground,
      body: NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
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
        //borderRadius: BorderRadius.all(Radius.circular(16)),
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
          await pageController.animateToPage(index,
              duration: 250.ms, curve: Curves.easeInOut);
        },
      ),

      floatingActionButton: BottomSheetActionButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14))),
          //foregroundColor: theme.colorScheme.secondary,
          backgroundColor: theme.colorScheme.secondaryContainer,
          builder: (context) => Icon(
                _fabIconList[_currentPage],
                color: theme.colorScheme.onSecondaryContainer,
              ),
          bottomSheetBuilder: _bottomSheetBuilder),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
