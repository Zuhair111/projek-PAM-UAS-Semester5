import 'package:flutter/material.dart';

class UserRole {
  static String? _role;
  static String? _name;
  static final ValueNotifier<String?> roleNotifier = ValueNotifier<String?>(null);

  static void setRole(String role) {
    _role = role;
    roleNotifier.value = role;
  }

  static String? getRole() {
    return _role;
  }

  static bool isParent() {
    return _role == 'parent';
  }

  static bool isChild() {
    return _role == 'child';
  }

  static void setName(String name) {
    _name = name;
  }

  static String? getName() {
    return _name;
  }

  static void clear() {
    _role = null;
    _name = null;
    roleNotifier.value = null;
  }
}
