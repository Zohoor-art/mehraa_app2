import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AboutDialog(
      applicationName: localizations.aboutAppName,
      applicationVersion: localizations.aboutAppVersion,
      applicationIcon: Icon(Icons.info, size: 48, color: Colors.blue),
      applicationLegalese: localizations.aboutLegal,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Text(
            localizations.aboutDescription,
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
        ),
      ],
    );
  }
}
