import 'package:flutter/material.dart';

class StoryReplyPage extends StatefulWidget {
  final String storyId;

  const StoryReplyPage({Key? key, required this.storyId}) : super(key: key);

  @override
  _StoryReplyPageState createState() => _StoryReplyPageState();
}

class _StoryReplyPageState extends State<StoryReplyPage> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendReply() {
    final replyText = _replyController.text.trim();
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ اكتب ردًا قبل الإرسال')),
      );
      return;
    }

    // هنا ممكن تضيف الكود لحفظ الرد في قاعدة البيانات
    print('📝 ردك على الستوري ${widget.storyId}: $replyText');

    // مسح الحقل بعد الإرسال
    _replyController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم إرسال الرد')),
    );

    Navigator.pop(context); // ترجع للخلف بعد الإرسال
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✍️ الرد على القصة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                labelText: 'أكتب ردك هنا...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _sendReply,
              icon: const Icon(Icons.send),
              label: const Text('إرسال الرد'),
            ),
          ],
        ),
      ),
    );
  }
}
