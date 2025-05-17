class UserPermissions {
  final String accountType;

  UserPermissions(this.accountType);

  bool get canView => true;

  bool get canInteract => accountType == 'google' || accountType == 'commercial';

  bool get canPost => accountType == 'commercial';
}
