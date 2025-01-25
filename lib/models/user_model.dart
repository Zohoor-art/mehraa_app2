class User {
  final int id;
  final String name;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.avatar,
  });

  static final User currentUser =
      User(id: 0, name: 'You', avatar: 'assets/images/1.jpg');

  static final User addison =
      User(id: 1, name: 'Addison', avatar: 'assets/images/2.jpg');

  static final User angel =
      User(id: 2, name: 'Angel', avatar: 'assets/images/3.jpg');

  static final User deanna =
      User(id: 3, name: 'Deanna', avatar: 'assets/images/4.jpg');

  static final User jason =
      User(id: 4, name: 'Json', avatar: 'assets/images/5.jpg');

  static final User judd =
      User(id: 5, name: 'Judd', avatar: 'assets/images/6.jpg');

  static final User leslie =
      User(id: 6, name: 'Leslie', avatar: 'assets/images/2.jpg');

  static final User nathan =
      User(id: 7, name: 'Nathan', avatar: 'assets/images/4.jpg');

  static final User stanley =
      User(id: 8, name: 'Stanley', avatar: 'assets/images/6.jpg');

  static final User virgil =
      User(id: 9, name: 'Virgil', avatar: 'assets/images/5.jpg');
}
