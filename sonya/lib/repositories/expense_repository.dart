import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseRepository {
  static const _webKey = 'web_expenses_v1';
  final DatabaseService _dbService;
  ExpenseRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Expense>> getAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webKey);
      if (raw == null || raw.isEmpty) return [];
      final list = (jsonDecode(raw) as List)
          .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      return list;
    }
    final db = await _dbService.database;
    final maps = await db.query(
      'expenses',
      orderBy: 'expense_date DESC, created_at DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<void> _saveWeb(List<Expense> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _webKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> insert(Expense expense) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((e) => e.id == expense.id);
      list.add(expense);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Expense expense) async {
    if (kIsWeb) {
      final list = await getAll();
      final idx = list.indexWhere((e) => e.id == expense.id);
      if (idx != -1) {
        list[idx] = expense;
        await _saveWeb(list);
      }
      return;
    }
    final db = await _dbService.database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> delete(String id) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((e) => e.id == id);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
