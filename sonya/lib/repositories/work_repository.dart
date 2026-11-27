import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/work_entry.dart';
import '../services/database_service.dart';

class WorkRepository {
  static const _webKey = 'web_work_entries_v1';
  final DatabaseService _dbService;
  WorkRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<WorkEntry>> getAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webKey);
      if (raw == null || raw.isEmpty) return [];
      final list = (jsonDecode(raw) as List)
          .map((e) => WorkEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => b.workDate.compareTo(a.workDate));
      return list;
    }
    final db = await _dbService.database;
    final maps = await db.query(
      'work_entries',
      orderBy: 'work_date DESC, created_at DESC',
    );
    return maps.map(WorkEntry.fromMap).toList();
  }

  Future<void> _saveWeb(List<WorkEntry> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _webKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> insert(WorkEntry entry) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((w) => w.id == entry.id);
      list.add(entry);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.insert(
      'work_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(WorkEntry entry) async {
    if (kIsWeb) {
      final list = await getAll();
      final idx = list.indexWhere((w) => w.id == entry.id);
      if (idx != -1) {
        list[idx] = entry;
        await _saveWeb(list);
      }
      return;
    }
    final db = await _dbService.database;
    await db.update(
      'work_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> delete(String id) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((w) => w.id == id);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.delete('work_entries', where: 'id = ?', whereArgs: [id]);
  }
}
