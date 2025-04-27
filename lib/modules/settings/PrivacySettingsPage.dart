import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mehra_app/shared/components/constants.dart';

class PrivacySettingsPage extends StatefulWidget {
  @override
  _PrivacySettingsPageState createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool isPrivateAccount = false;
  bool hideOnlineStatus = false;
  String messagePermission = 'everyone';
  List<String> blockedUserIds = [];
  String? uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      loadPrivacySettings();
      loadBlockedUsers();
    } else {
      print("المستخدم غير مسجل الدخول!");
    }
  }

  Future<void> loadPrivacySettings() async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        isPrivateAccount = data['isPrivate'] ?? false;
        hideOnlineStatus = data['hideOnline'] ?? false;
        messagePermission = data['messagePermission'] ?? 'everyone';
      });
    }
  }

  Future<void> loadBlockedUsers() async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        blockedUserIds = List<String>.from(data['blockedUsers'] ?? []);
      });
    }
  }

  Future<void> updatePrivacySetting(String field, dynamic value) async {
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      field: value,
    });
  }

  Future<void> unblockUser(String userId) async {
    blockedUserIds.remove(userId);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'blockedUsers': blockedUserIds,
    });
    setState(() {});
  }

  Future<String> getUsername(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? (doc.data()!['username'] ?? 'مستخدم') : 'غير معروف';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: MyColor.lightprimaryColor,
      appBar: AppBar(
        title: Text(localizations.privacyTitle, style: TextStyle(fontFamily: 'Tajawal')),
        backgroundColor: MyColor.purpleColor,
      ),
      body: uid == null
          ? Center(child: Text(localizations.loginToViewPrivacy))
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: Text(localizations.privateAccount),
                  value: isPrivateAccount,
                  onChanged: (value) {
                    setState(() => isPrivateAccount = value);
                    updatePrivacySetting('isPrivate', value);
                  },
                ),
                SwitchListTile(
                  title: Text(localizations.hideOnlineStatus),
                  value: hideOnlineStatus,
                  onChanged: (value) {
                    setState(() => hideOnlineStatus = value);
                    updatePrivacySetting('hideOnline', value);
                  },
                ),
                ListTile(
                  title: Text(localizations.messagePermission),
                  subtitle: Text(
                    messagePermission == 'everyone'
                        ? localizations.everyone
                        : messagePermission == 'followers'
                            ? localizations.followersOnly
                            : localizations.noOne,
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(localizations.everyone),
                            onTap: () {
                              setState(() => messagePermission = 'everyone');
                              updatePrivacySetting('messagePermission', 'everyone');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(localizations.followersOnly),
                            onTap: () {
                              setState(() => messagePermission = 'followers');
                              updatePrivacySetting('messagePermission', 'followers');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(localizations.noOne),
                            onTap: () {
                              setState(() => messagePermission = 'none');
                              updatePrivacySetting('messagePermission', 'none');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  title: Text(localizations.hideStoriesFrom),
                  subtitle: Text(localizations.noStoriesHidden),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // مستقبلاً: افتح صفحة تحديد الأشخاص
                  },
                ),
                Divider(),
                ExpansionTile(
                  title: Text(localizations.blockedUsers),
                  subtitle: blockedUserIds.isEmpty
                      ? Text(localizations.noBlockedUsers)
                      : Text(localizations.blockedCount(blockedUserIds.length)),
                  children: blockedUserIds.map((userId) {
                    return FutureBuilder<String>(
                      future: getUsername(userId),
                      builder: (context, snapshot) {
                        final username = snapshot.data ?? '...';
                        return ListTile(
                          title: Text(username),
                          trailing: TextButton(
                            onPressed: () => unblockUser(userId),
                            child: Text(localizations.unblock, style: TextStyle(color: Colors.red)),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
