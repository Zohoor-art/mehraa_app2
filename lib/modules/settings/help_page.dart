import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  void _launchUrl(String url) async {
    final launched = await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      debugPrint('❌ لا يمكن فتح الرابط: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.helpTitle, style: TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text(localizations.helpCenter),
            onTap: () => _launchUrl('https://help.instagram.com/'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.bug_report),
            title: Text(localizations.reportProblem),
            onTap: () => _launchUrl('https://help.instagram.com/contact/383679321740945'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text(localizations.privacyPolicy),
            onTap: () => _launchUrl('https://privacycenter.instagram.com/policy'),
          ),
          Divider(),
        ],
      ),
    );
  }
}
