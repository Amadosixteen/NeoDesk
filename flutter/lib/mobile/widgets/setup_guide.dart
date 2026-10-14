import 'package:flutter/material.dart';
import 'package:flutter_hbb/desktop/pages/desktop_home_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../models/platform_model.dart';
import '../../models/server_model.dart';
import '../pages/server_page.dart';

/// NeoDesk: guía para que este teléfono pueda ser controlado. Se oculta sola
/// cuando los tres pasos están hechos.
class SetupGuide extends StatefulWidget {
  const SetupGuide({Key? key}) : super(key: key);

  @override
  State<SetupGuide> createState() => _SetupGuideState();
}

class _SetupGuideState extends State<SetupGuide> {
  bool _passwordSet = true;

  @override
  void initState() {
    super.initState();
    _refreshPassword();
  }

  Future<void> _refreshPassword() async {
    final set =
        (await bind.mainGetCommon(key: "permanent-password-set")) == "true";
    if (mounted && set != _passwordSet) setState(() => _passwordSet = set);
  }

  @override
  Widget build(BuildContext context) {
    final serverModel = Provider.of<ServerModel>(context);
    final usesPermanent =
        serverModel.verificationMethod == kUsePermanentPassword;
    final passwordOk = !usesPermanent || _passwordSet;
    if (passwordOk && serverModel.mediaOk && serverModel.inputOk) {
      return const SizedBox.shrink();
    }
    return PaddingCard(
      title: translate("Allow control of this phone"),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Step(
          number: 1,
          text: translate("Set a permanent password"),
          done: passwordOk,
          action: translate("Set permanent password"),
          onPressed: () =>
              setPasswordDialog(notEmptyCallback: () => _refreshPassword()),
        ),
        _Step(
          number: 2,
          text: translate("Turn on NeoDesk Input in Accessibility"),
          done: serverModel.inputOk,
          action: translate("Open"),
          onPressed: serverModel.toggleInput,
        ),
        _Step(
          number: 3,
          text: translate("Start the service and accept screen recording"),
          done: serverModel.mediaOk,
          action: translate("Start service"),
          onPressed: bind.mainGetLocalOption(key: "show-scam-warning") != "N"
              ? () => showScamWarning(context, serverModel)
              : serverModel.toggleService,
        ),
        if (!serverModel.inputOk)
          _Tip(translate("setup_restricted_settings_tip")),
        if (!serverModel.inputOk && serverModel.mediaOk)
          _Tip(translate("setup_overlay_tip")),
        _Tip(translate("setup_battery_tip")),
      ]),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.text,
    required this.done,
    required this.action,
    required this.onPressed,
  });

  final int number;
  final String text;
  final bool done;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: done ? Colors.green : MyTheme.accent,
          child: done
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text('$number',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
        ).marginOnly(right: 12, top: 2),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text,
                style: TextStyle(
                    color: done ? MyTheme.darkGray : null,
                    decoration: done ? TextDecoration.lineThrough : null)),
            if (!done)
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.accent,
                    foregroundColor: Colors.white),
                child: Text(action),
              ).marginOnly(top: 6),
          ]),
        ),
      ]),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, size: 18, color: MyTheme.darkGray)
            .marginOnly(right: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: MyTheme.darkGray, fontSize: 13)),
        ),
      ]),
    );
  }
}
