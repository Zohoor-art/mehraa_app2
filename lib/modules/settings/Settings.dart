import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/components.dart';
import 'package:mehra_app/shared/components/constants.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
     appBar: AppBar(
        toolbarHeight: 15,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.blueColor,
                MyColor.purpleColor,
              ],
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
              width: 399, // العرض المطلوب
              height: 52, // الطول المطلوب
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'الاعدادات',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 12, 12, 12),
                      fontSize: 25,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Icon(
                    Icons.settings,
                    color:  Colors.black,
                  ),
                ],
              ),
            ),
       
            Expanded(
              child: ListView(
                children: [
                  SettingTile(
                    title: 'المظهر',
                    icon: Icons.visibility,
                    trailing: Switch(value: true, 
                    onChanged: (value) {}),
                    alignment: CrossAxisAlignment.end,
                  ),
                  SettingTile(
                    title: 'الخصوصية',
                    icon: Icons.lock,
                    trailing: Icon(Icons.lock),
                    alignment: CrossAxisAlignment.start,
                  ),
                  SettingTile(
                    title: 'اللغة',
                    icon: Icons.language,
                    trailing: DropdownButton<String>(
                      value: selectedLanguage,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black), // لون الأيقونة أسود
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLanguage = newValue ?? 'العربية';
                        });
                      },
                      items: <String>['العربية', 'الإنجليزية']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    alignment: CrossAxisAlignment.center,
                  ),
                  SettingTile(
                    title: 'البريد الإلكتروني',
                    icon: Icons.email,
                    trailing: Text('ola.abdllah@mail.com'),
                    alignment: CrossAxisAlignment.end,
                  ),
                  SettingTile(
                    title: 'المساعدة',
                    icon: Icons.help,
                    trailing: Icon(Icons.help),
                    alignment: CrossAxisAlignment.start,
                  ),
                  SettingTile(
                    title: 'حول',
                    icon: Icons.info,
                    trailing: Icon(Icons.info),
                    alignment: CrossAxisAlignment.start,
                  ),
                  SettingTile(
                    title: 'تسجيل الخروج',
                    icon: Icons.exit_to_app,
                    trailing: Icon(Icons.exit_to_app),
                    alignment: CrossAxisAlignment.start,
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
