import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fashion_profile.dart';
import '../models/saved_fashion_look.dart';

class FashionProfileState extends ChangeNotifier {
  static const key = 'twinly.fashion_profile';
  FashionProfile? profile;
  FashionProfileState(this.profile);
  Future<void> save(FashionProfile next) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(next.toJson()));
    profile = next;
    notifyListeners();
  }

  Future<void> updateFromAvatar({
    required double height,
    required double shoulderWidth,
    required double chest,
    required double waist,
    required double hip,
    required String skinTone,
    required String hairType,
  }) async {
    final current = profile ?? const FashionProfile();
    await save(
      FashionProfile(
        height: height,
        shoulderWidth: shoulderWidth,
        bust: chest,
        waist: waist,
        hip: hip,
        bodyShape: current.bodyShape,
        preferredFit: current.preferredFit,
        skinTone: skinTone,
        hairType: hairType,
        style: current.style,
        budget: current.budget,
      ),
    );
  }

  static Future<FashionProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    return raw == null ? null : FashionProfile.fromJson(jsonDecode(raw));
  }
}

class SavedLooksState extends ChangeNotifier {
  static const key = 'twinly.fashion_saved_looks';
  List<SavedFashionLook> looks = [];
  SavedLooksState() {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw != null) {
      looks = (jsonDecode(raw) as List)
          .map(
            (e) =>
                SavedFashionLook.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<void> add(SavedFashionLook look) async {
    looks = [look, ...looks];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(looks.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }
}
