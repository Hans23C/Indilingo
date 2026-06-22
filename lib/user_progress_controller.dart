import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course_models.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String profilePhotoPath;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoPath = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? 'invitado',
      name: json['name'] as String? ?? 'Estudiante INDIlingo',
      email: json['email'] as String? ?? 'invitado@indilingo.local',
      profilePhotoPath: json['profilePhotoPath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePhotoPath': profilePhotoPath,
    };
  }

  AppUser copyWith({String? name, String? email, String? profilePhotoPath}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
    );
  }
}

class UserProgress {
  final Map<String, Set<String>> completedBySection;
  final Map<String, int> practiceStreakByLanguage;

  UserProgress({
    Map<String, Set<String>>? completedBySection,
    Map<String, int>? practiceStreakByLanguage,
  }) : completedBySection = completedBySection ?? {},
       practiceStreakByLanguage = practiceStreakByLanguage ?? {};

  Set<String> completedActivities(String languageName, SkillArea area) {
    return completedBySection[_sectionKey(languageName, area)] ?? <String>{};
  }

  bool completeActivity(
    String languageName,
    SkillArea area,
    String activityId,
  ) {
    final key = _sectionKey(languageName, area);
    final completed = completedBySection.putIfAbsent(key, () => <String>{});
    final added = completed.add(activityId);
    if (added) {
      practiceStreakByLanguage[languageName] =
          (practiceStreakByLanguage[languageName] ?? 0) + 1;
    }
    return added;
  }

  int completedCount(String languageName, SkillArea area) {
    return completedActivities(languageName, area).length;
  }

  int streakDays(String languageName) {
    return practiceStreakByLanguage[languageName] ?? 0;
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final rawCompleted =
        json['completedBySection'] as Map<String, dynamic>? ?? {};
    final rawStreak =
        json['practiceStreakByLanguage'] as Map<String, dynamic>? ?? {};

    return UserProgress(
      completedBySection: rawCompleted.map((key, value) {
        final activities = value is List
            ? value.whereType<String>().toSet()
            : <String>{};
        return MapEntry(key, activities);
      }),
      practiceStreakByLanguage: rawStreak.map((key, value) {
        return MapEntry(
          key,
          value is int ? value : int.tryParse('$value') ?? 0,
        );
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedBySection': completedBySection.map((key, value) {
        return MapEntry(key, value.toList());
      }),
      'practiceStreakByLanguage': practiceStreakByLanguage,
    };
  }

  static String _sectionKey(String languageName, SkillArea area) {
    return '$languageName:${area.name}';
  }
}

class UserProgressController {
  UserProgressController._();

  static const String _storageKey = 'indilingo_user_progress_v1';
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static final Map<String, AppUser> _users = {};
  static final Map<String, UserProgress> _progressByUser = {};
  static AppUser? _currentUser;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);

    if (stored != null && stored.isNotEmpty) {
      final data = jsonDecode(stored) as Map<String, dynamic>;
      final rawUsers = data['users'] as Map<String, dynamic>? ?? {};
      final rawProgress = data['progress'] as Map<String, dynamic>? ?? {};
      final currentUserId = data['currentUserId'] as String?;

      _users
        ..clear()
        ..addAll(
          rawUsers.map((key, value) {
            return MapEntry(
              key,
              AppUser.fromJson(value as Map<String, dynamic>),
            );
          }),
        );
      _progressByUser
        ..clear()
        ..addAll(
          rawProgress.map((key, value) {
            return MapEntry(
              key,
              UserProgress.fromJson(value as Map<String, dynamic>),
            );
          }),
        );

      if (currentUserId != null && _users.containsKey(currentUserId)) {
        _currentUser = _users[currentUserId];
      }
    }

    _initialized = true;
    currentUser;
    changes.value++;
  }

  static AppUser get currentUser {
    return _currentUser ??= _ensureUser(
      id: 'invitado',
      name: 'Estudiante INDIlingo',
      email: 'invitado@indilingo.local',
    );
  }

  static UserProgress get currentProgress {
    return _progressByUser.putIfAbsent(currentUser.id, UserProgress.new);
  }

  static AppUser register({required String name, required String email}) {
    final id = _normalizeId(email);
    final user = AppUser(id: id, name: name, email: email);
    _users[id] = user;
    _progressByUser[id] = UserProgress();
    _currentUser = user;
    unawaited(_save());
    changes.value++;
    return user;
  }

  static Future<AppUser> registerAndSave({
    required String name,
    required String email,
  }) async {
    final user = register(name: name, email: email);
    await _save();
    return user;
  }

  static AppUser login({required String userOrEmail}) {
    final id = _normalizeId(userOrEmail);
    _currentUser =
        _users[id] ??
        _ensureUser(
          id: id,
          name: userOrEmail,
          email: userOrEmail.contains('@')
              ? userOrEmail
              : '$id@indilingo.local',
        );
    unawaited(_save());
    changes.value++;
    return _currentUser!;
  }

  static Future<AppUser> loginAndSave({required String userOrEmail}) async {
    final user = login(userOrEmail: userOrEmail);
    await _save();
    return user;
  }

  static bool completeActivity({
    required String languageName,
    required SkillArea area,
    required String activityId,
  }) {
    final gainedExp = currentProgress.completeActivity(
      languageName,
      area,
      activityId,
    );
    if (gainedExp) {
      unawaited(_save());
      changes.value++;
    }
    return gainedExp;
  }

  static Future<bool> completeActivityAndSave({
    required String languageName,
    required SkillArea area,
    required String activityId,
  }) async {
    final gainedExp = currentProgress.completeActivity(
      languageName,
      area,
      activityId,
    );
    if (gainedExp) {
      await _save();
      changes.value++;
    }
    return gainedExp;
  }

  static Future<void> updateProfilePhotoPath(String path) async {
    final updated = currentUser.copyWith(profilePhotoPath: path);
    _users[updated.id] = updated;
    _currentUser = updated;
    await _save();
    changes.value++;
  }

  static AppUser _ensureUser({
    required String id,
    required String name,
    required String email,
  }) {
    final user = _users.putIfAbsent(
      id,
      () => AppUser(id: id, name: name, email: email),
    );
    _progressByUser.putIfAbsent(id, UserProgress.new);
    return user;
  }

  static Future<void> _save() async {
    if (!_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'currentUserId': currentUser.id,
      'users': _users.map((key, value) => MapEntry(key, value.toJson())),
      'progress': _progressByUser.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  static String _normalizeId(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.isEmpty ? 'invitado' : normalized;
  }
}
