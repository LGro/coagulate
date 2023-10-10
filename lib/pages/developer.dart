import 'package:ansicolor/ansicolor.dart';
import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:loggy/loggy.dart';
import 'package:quickalert/quickalert.dart';
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
  final _terminalController = TerminalController();
  final _debugCommandController = TextEditingController();
  final _logLevelController = DropdownController(duration: 250.ms);
  final List<CoolDropdownItem<LogLevel>> _logLevelDropdownItems = [];
  var _logLevelDropDown = log.level.logLevel;
  var _showEllet = false;

  @override
  void initState() {
    super.initState();
    _terminalController.addListener(() {
      setState(() {});
    });

    for (var i = 0; i < logLevels.length; i++) {
      _logLevelDropdownItems.add(CoolDropdownItem<LogLevel>(
          label: logLevelName(logLevels[i]),
          icon: Text(logLevelEmoji(logLevels[i])),
          value: logLevels[i]));
    }
  }

  void _debugOut(String out) {
    final pen = AnsiPen()..cyan(bold: true);
    final colorOut = pen(out);
    debugPrint(colorOut);
    globalDebugTerminal.write(colorOut.replaceAll('\n', '\r\n'));
  }

  Future<void> _sendDebugCommand(String debugCommand) async {
    if (debugCommand == 'ellet') {
      setState(() {
        _showEllet = !_showEllet;
      });
      return;
    }
    _debugOut('DEBUG >>>\n$debugCommand\n');
    try {
      final out = await Veilid.instance.debug(debugCommand);
      _debugOut('<<< DEBUG\n$out\n');
    } on Exception catch (e, st) {
      _debugOut('<<< ERROR\n$e\n<<< STACK\n$st');
    }
  }

  Future<void> clear(BuildContext context) async {
    globalDebugTerminal.buffer.clear();
    if (context.mounted) {
      showInfoToast(context, translate('developer.cleared'));
    }
  }

  Future<void> copySelection(BuildContext context) async {
    final selection = _terminalController.selection;
    if (selection != null) {
      final text = globalDebugTerminal.buffer.getText(selection);
      _terminalController.clearSelection();
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showInfoToast(context, translate('developer.copied'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
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
                onPressed: _terminalController.selection == null
                    ? null
                    : () async {
                        await copySelection(context);
                      }),
            IconButton(
                icon: const Icon(Icons.clear_all),
                color: scale.primaryScale.text,
                disabledColor: scale.grayScale.subtleText,
                onPressed: () async {
                  await QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      title: translate('developer.are_you_sure_clear'),
                      textColor: scale.primaryScale.text,
                      confirmBtnColor: scale.primaryScale.elementBackground,
                      backgroundColor: scale.primaryScale.subtleBackground,
                      headerBackgroundColor: scale.primaryScale.background,
                      confirmBtnText: translate('button.ok'),
                      cancelBtnText: translate('button.cancel'),
                      onConfirmBtnTap: () async {
                        Navigator.pop(context);
                        if (context.mounted) {
                          await clear(context);
                        }
                      });
                }),
            CoolDropdown<LogLevel>(
              controller: _logLevelController,
              defaultItem: _logLevelDropdownItems
                  .singleWhere((x) => x.value == _logLevelDropDown),
              onChange: (value) {
                setState(() {
                  _logLevelDropDown = value;
                  Loggy('').level = getLogOptions(value);
                  setVeilidLogLevel(value);
                  _logLevelController.close();
                });
              },
              resultOptions: ResultOptions(
                width: 64,
                height: 40,
                render: ResultRender.icon,
                textStyle: textTheme.labelMedium!
                    .copyWith(color: scale.primaryScale.text),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                openBoxDecoration: BoxDecoration(
                    color: scale.primaryScale.activeElementBackground),
                boxDecoration:
                    BoxDecoration(color: scale.primaryScale.elementBackground),
              ),
              dropdownOptions: DropdownOptions(
                width: 160,
                align: DropdownAlign.right,
                duration: 150.ms,
                color: scale.primaryScale.elementBackground,
                borderSide: BorderSide(color: scale.primaryScale.border),
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              ),
              dropdownTriangleOptions: const DropdownTriangleOptions(
                  align: DropdownTriangleAlign.right),
              dropdownItemOptions: DropdownItemOptions(
                  selectedTextStyle: textTheme.labelMedium!
                      .copyWith(color: scale.primaryScale.text),
                  textStyle: textTheme.labelMedium!
                      .copyWith(color: scale.primaryScale.text),
                  selectedBoxDecoration: BoxDecoration(
                      color: scale.primaryScale.activeElementBackground),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  selectedPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4)),
              dropdownList: _logLevelDropdownItems,
            )
          ],
          title: Text(translate('developer.title'),
              style:
                  textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Column(children: [
          Stack(alignment: AlignmentDirectional.center, children: [
            Image.asset('assets/images/ellet.png'),
            TerminalView(globalDebugTerminal,
                textStyle: kDefaultTerminalStyle,
                controller: _terminalController,
                //autofocus: true,
                backgroundOpacity: _showEllet ? 0.75 : 1.0,
                onSecondaryTapDown: (details, offset) async {
              await copySelection(context);
            })
          ]).expanded(),
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
                  onPressed: _debugCommandController.text.isEmpty
                      ? null
                      : () async {
                          final debugCommand = _debugCommandController.text;
                          _debugCommandController.clear();
                          await _sendDebugCommand(debugCommand);
                        },
                )),
            onChanged: (_) {
              setState(() => {});
            },
            onSubmitted: (debugCommand) async {
              _debugCommandController.clear();
              await _sendDebugCommand(debugCommand);
            },
          ).paddingAll(4)
        ])));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TerminalController>(
          'terminalController', _terminalController))
      ..add(
          DiagnosticsProperty<LogLevel>('logLevelDropDown', _logLevelDropDown));
  }
}
