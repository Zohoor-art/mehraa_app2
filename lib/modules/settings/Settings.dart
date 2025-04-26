import 'package:flutter/material.dart';
import 'package:mehra_app/modules/register/register_screen.dart';
import 'package:mehra_app/modules/settings/PrivacySettingsPage.dart';
import 'package:mehra_app/modules/settings/UserProvider.dart';
import 'package:mehra_app/modules/settings/about_page.dart';
import 'package:mehra_app/modules/settings/help_page.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColor.blueColor, MyColor.purpleColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    languageProvider.selectedLanguage == 'العربية'
                        ? 'الإعدادات'
                        : 'Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  SettingTile(
  title: languageProvider.selectedLanguage == 'العربية'
      ? 'المظهر'
      : 'Appearance',
  icon: Icons.visibility,
  trailing: Switch(
    value: userProvider.isDarkMode,
    onChanged: (value) {
      userProvider.toggleTheme();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.selectedLanguage == 'العربية'
                ? (value ? 'تم تفعيل الوضع الداكن' : 'تم تفعيل الوضع الفاتح')
                : (value ? 'Dark mode activated' : 'Light mode activated'),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    },
  ),
  alignment: CrossAxisAlignment.end,
),

 SettingTile(
                    title: languageProvider.selectedLanguage == 'العربية'
                        ? 'الخصوصية'
                        : 'Privacy',
                    icon: Icons.lock,
                    trailing: Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
                    alignment: CrossAxisAlignment.start,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PrivacySettingsPage()),
                      );
                    },
                  ),
                  SettingTile(
                    title: languageProvider.selectedLanguage == 'العربية'
                        ? 'اللغة'
                        : 'Language',
                    icon: Icons.language,
                    trailing: DropdownButton<String>(
                      value: languageProvider.selectedLanguage,
                      dropdownColor: Theme.of(context).cardColor,
                      icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color),
                      onChanged: (String? newValue) {
                        setState(() {
                          languageProvider.changeLanguage(newValue!);
                        });
                      },
                      items: <String>['العربية', 'الإنجليزية']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
                        );
                      }).toList(),
                    ),
                    alignment: CrossAxisAlignment.center,
                  ),
                  SettingTile(
                    title: languageProvider.selectedLanguage == 'العربية'
                        ? 'البريد الإلكتروني'
                        : 'Email',
                    icon: Icons.email,
                    trailing: FutureBuilder<User?>(
                      future: Future.value(FirebaseAuth.instance.currentUser),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('...', style: Theme.of(context).textTheme.bodyMedium);
                        } else if (snapshot.hasData && snapshot.data != null) {
                          return Text(snapshot.data!.email ?? 'غير معروف', style: Theme.of(context).textTheme.bodyMedium);
                        } else {
                          return Text('غير مسجل', style: Theme.of(context).textTheme.bodyMedium);
                        }
                      },
                    ),
                    alignment: CrossAxisAlignment.end,
                  ),
                  SettingTile(
                    title: languageProvider.selectedLanguage == 'العربية'
                        ? 'المساعدة'
                        : 'Help',
                    icon: Icons.help,
                    trailing: Icon(Icons.help, color: Theme.of(context).iconTheme.color),
                    alignment: CrossAxisAlignment.start,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpPage()),
                      );
                    },
                  ),
                  SettingTile(
                    title: languageProvider.selectedLanguage == 'العربية'
                        ? 'حول'
                        : 'About',
                    icon: Icons.info,
                    trailing: Icon(Icons.info, color: Theme.of(context).iconTheme.color),
                    alignment: CrossAxisAlignment.start,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutPage()),
                      );
                    },
                  ),
                  SettingTile(
                    title: languageProvider.selectedLanguage == 'العربية'
                        ? 'تسجيل الخروج'
                        : 'Log Out',
                    icon: Icons.exit_to_app,
                    trailing: Icon(Icons.exit_to_app, color: Theme.of(context).iconTheme.color),
                    alignment: CrossAxisAlignment.start,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
