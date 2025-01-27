import './user_model.dart';

class Message {
  final User sender;
  final String avatar;
  final String time;
  final int unreadCount;
  final bool isRead;
  final String text;

  Message({
    required this.sender,
    required this.avatar,
    required this.time,
    required this.unreadCount,
    required this.text,
    required this.isRead,
  });
}

// مثال على المستخدمين، يمكنك تخصيص الأسماء حسب الحاجة
final User addison =
    User(name: 'الينا روز', avatar: 'assets/images/1.jpg', id: 1);
final User jason = User(name: 'لوليتا', avatar: 'assets/images/2.jpg', id: 2);
final User deanna =
    User(name: 'دياناياسر', avatar: 'assets/images/3.jpg', id: 3);
final User nathan =
    User(name: 'لينا ماهر', avatar: 'assets/images/4.jpg', id: 4);
final User virgil =
    User(name: 'سماح احمد', avatar: 'assets/images/5.jpg', id: 5);
final User stanley =
    User(name: 'ياسمينا', avatar: 'assets/images/6.jpg', id: 6);
final User leslie = User(name: 'روزي', avatar: 'assets/images/2.jpg', id: 7);
final User judd = User(name: 'جاد', avatar: 'assets/images/1.jpg', id: 8);
final User currentUser = User(name: 'المستخدم الحالي', avatar: '', id: 9);

// الرسائل الأخيرة
final List<Message> recentChats = [
  Message(
    sender: addison,
    avatar: addison.avatar,
    time: '01:25',
    text: "يكتب...",
    unreadCount: 1,
    isRead: false,
  ),
  Message(
    sender: jason,
    avatar: jason.avatar,
    time: '12:46',
    text: "هل سأكون في ذلك؟",
    unreadCount: 1,
    isRead: false,
  ),
  Message(
    sender: deanna,
    avatar: deanna.avatar,
    time: '05:26',
    text: "هذا لطيف جدًا.",
    unreadCount: 3,
    isRead: false,
  ),
  Message(
    sender: nathan,
    avatar: nathan.avatar,
    time: '12:45',
    text: "دعني أرى ما يمكنني فعله.",
    unreadCount: 2,
    isRead: false,
  ),
];

// جميع الرسائل
final List<Message> allChats = [
  Message(
    sender: virgil,
    avatar: virgil.avatar,
    time: '12:59',
    text: "لا! كنت أريد فقط",
    unreadCount: 0,
    isRead: true,
  ),
  Message(
    sender: stanley,
    avatar: stanley.avatar,
    time: '10:41',
    text: "ماذا فعلت؟",
    unreadCount: 1,
    isRead: false,
  ),
  Message(
    sender: leslie,
    avatar: leslie.avatar,
    time: '05:51',
    unreadCount: 0,
    isRead: true,
    text: "لقد قمت بالتسجيل.",
  ),
  Message(
    sender: judd,
    avatar: judd.avatar,
    time: '10:16',
    text: "هل يمكنني أن أسألك شيئًا؟",
    unreadCount: 2,
    isRead: false,
  ),
];

// الرسائل الخاصة بالمستخدم
final List<Message> messages = [
  Message(
    sender: addison,
    time: '12:09 AM',
    avatar: addison.avatar,
    text: "...",
    unreadCount: 1,
    isRead: false,
  ),
  Message(
    sender: currentUser,
    time: '12:05 AM',
    isRead: true,
    text: "أنا عائد إلى المنزل.",
    avatar: '',
    unreadCount: 1,
  ),
  Message(
    sender: currentUser,
    time: '12:05 AM',
    isRead: true,
    text: "انظر، كنت على حق، هذا لا يهمني.",
    avatar: '',
    unreadCount: 3,
  ),
  Message(
    sender: addison,
    time: '11:58 PM',
    avatar: addison.avatar,
    text: "أنا أوقع لك شيكات راتبك.",
    unreadCount: 4,
    isRead: false,
  ),
  Message(
    sender: addison,
    time: '11:58 PM',
    avatar: addison.avatar,
    text: "هل تعتقد أننا لا نملك شيئًا نتحدث عنه؟",
    unreadCount: 4,
    isRead: false,
  ),
  Message(
    sender: currentUser,
    time: '11:45 PM',
    isRead: true,
    text: "حسنًا، لأنني لم أكن أنوي أن أكون في مكتبك. قبل 20 دقيقة.",
    unreadCount: 4,
    avatar: '',
  ),
  Message(
    sender: addison,
    time: '11:30 PM',
    avatar: addison.avatar,
    text: "كنت أتوقعك في مكتبي قبل 20 دقيقة.",
    isRead: true,
    unreadCount: 5,
  ),
  Message(
    sender: addison,
    time: '11:30 PM',
    avatar: addison.avatar,
    text: "كنت أتوقعك في مكتبي قبل 20 دقيقة.",
    isRead: true,
    unreadCount: 5,
  ),
  Message(
    sender: addison,
    time: '11:30 PM',
    avatar: addison.avatar,
    text: "كنت أتوقعك في مكتبي قبل 20 دقيقة.",
    isRead: true,
    unreadCount: 5,
  ),
  Message(
    sender: currentUser,
    time: '11:30 PM',
    avatar: addison.avatar,
    text: "كنت أتوقعك في مكتبي قبل 20 دقيقة.",
    isRead: true,
    unreadCount: 5,
  ),
];
