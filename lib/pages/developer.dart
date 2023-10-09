import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:loggy/loggy.dart';
import 'package:xterm/xterm.dart';

import '../tools/tools.dart';
import '../veilid_support/veilid_support.dart';

final globalDebugTerminal = Terminal(
  maxLines: 50000,
);

const kDefaultTerminalStyle = TerminalStyle(
    fontSize: 11,
    // height: 1.2,
    fontFamily: 'Source Code Pro');

class DeveloperPage extends ConsumerStatefulWidget {
  const DeveloperPage({super.key});

  @override
  DeveloperPageState createState() => DeveloperPageState();
}

class DeveloperPageState extends ConsumerState<DeveloperPage> {
  final terminalController = TerminalController();
  var logLevelDropDown = log.level.logLevel;
  final TextEditingController _debugCommandController = TextEditingController();

  @override
  void initState() {
    // _scrollController = ScrollController(
    //   onAttach: _handlePositionAttach,
    //   onDetach: _handlePositionDetach,
    // );
    super.initState();
    terminalController.addListener(() {
      setState(() {});
    });
  }

  // void _handleScrollChange() {
  //   if (_isScrolling != _scrollController.position.isScrollingNotifier.value) {
  //     _isScrolling = _scrollController.position.isScrollingNotifier.value;
  //     _wantsBottom = _scrollController.position.pixels ==
  //         _scrollController.position.maxScrollExtent;
  //   }
  // }

  // void _handlePositionAttach(ScrollPosition position) {
  //   // From here, add a listener to the given ScrollPosition.
  //   // Here the isScrollingNotifier will be used to inform when scrolling starts
  //   // and stops and change the AppBar's color in response.
  //   position.isScrollingNotifier.addListener(_handleScrollChange);
  // }

  // void _handlePositionDetach(ScrollPosition position) {
  //   // From here, add a listener to the given ScrollPosition.
  //   // Here the isScrollingNotifier will be used to inform when scrolling starts
  //   // and stops and change the AppBar's color in response.
  //   position.isScrollingNotifier.removeListener(_handleScrollChange);
  // }

  // void _scrollToBottom() {
  //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   _wantsBottom = true;
  // }

  Future<void> _sendDebugCommand(String debugCommand) async {
    log.info('DEBUG >>>\n$debugCommand');
    final out = await Veilid.instance.debug(debugCommand);
    log.info('<<< DEBUG\n$out');
  }

  Future<void> copySelection(BuildContext context) async {
    final selection = terminalController.selection;
    if (selection != null) {
      final text = globalDebugTerminal.buffer.getText(selection);
      terminalController.clearSelection();
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showInfoToast(context, translate('developer.copied'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final textTheme = theme.textTheme;
    final scale = theme.extension<ScaleScheme>()!;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!_isScrolling && _wantsBottom) {
    //     _scrollToBottom();
    //   }
    // });

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: scale.primaryScale.text),
            onPressed: () => GoRouterHelper(context).pop(),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.copy),
                color: scale.primaryScale.text,
                disabledColor: scale.grayScale.subtleText,
                onPressed: terminalController.selection == null
                    ? null
                    : () async {
                        await copySelection(context);
                      }),
            DropdownMenu<LogLevel>(
                initialSelection: logLevelDropDown,
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      logLevelDropDown = value;
                      //log. = value;
                      setVeilidLogLevel(value);
                    });
                  }
                },
                dropdownMenuEntries: [
                  DropdownMenuEntry<LogLevel>(
                      value: LogLevel.error, label: translate('log.error')),
                  DropdownMenuEntry<LogLevel>(
                      value: LogLevel.warning, label: translate('log.warning')),
                  DropdownMenuEntry<LogLevel>(
                      value: LogLevel.info, label: translate('log.info')),
                  DropdownMenuEntry<LogLevel>(
                      value: LogLevel.debug, label: translate('log.debug')),
                  DropdownMenuEntry<LogLevel>(
                      value: traceLevel, label: translate('log.trace')),
                ])
          ],
          title: Text(translate('developer.title')),
          centerTitle: true,
        ),
        body: Column(children: [
          TerminalView(
            globalDebugTerminal,
            textStyle: kDefaultTerminalStyle,
            controller: terminalController,
            //autofocus: true,
            //backgroundOpacity: 0.9,
            onSecondaryTapDown: (details, offset) async {
              await copySelection(context);
            },
          ).expanded(),
          TextField(
            controller: _debugCommandController,
            decoration: InputDecoration(
                filled: true,
                contentPadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: scale.primaryScale.border)),
                fillColor: scale.primaryScale.subtleBackground,
                hintText: translate('developer.command'),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final debugCommand = _debugCommandController.text;
                    _debugCommandController.clear();
                    await _sendDebugCommand(debugCommand);
                  },
                )),
            onSubmitted: (debugCommand) async {
              _debugCommandController.clear();
              await _sendDebugCommand(debugCommand);
            },
          ).paddingAll(4)
        ]));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TerminalController>(
        'terminalController', terminalController));
  }
}
