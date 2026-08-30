/// Entity خالص کاربر — بدون هیچ وابستگی به Drift/Flutter (بخش ۱۰).
class AppUser {
  final int id;
  final String fullName;
  final String username;
  final String role;
  final bool isActive;
  final List<String> permissionKeys;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
    required this.isActive,
    required this.permissionKeys,
  });

  bool can(String permissionKey) => permissionKeys.contains(permissionKey);
}
