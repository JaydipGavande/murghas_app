import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class PaymentRepository {
  static const _webKey = 'web_payments_v1';
  final DatabaseService _dbService;
  PaymentRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Payment>> getAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webKey);
      if (raw == null || raw.isEmpty) return [];
      final list = (jsonDecode(raw) as List)
          .map((e) => Payment.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      return list;
    }
    final db = await _dbService.database;
    final maps = await db.query(
      'payments',
      orderBy: 'payment_date DESC, created_at DESC',
    );
    return maps.map(Payment.fromMap).toList();
  }

  Future<void> _saveWeb(List<Payment> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _webKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> insert(Payment payment) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((p) => p.id == payment.id);
      list.add(payment);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.insert(
      'payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((p) => p.id == id);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByWorkEntryId(String workEntryId) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((p) => p.workEntryId == workEntryId);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.delete(
      'payments',
      where: 'work_entry_id = ?',
      whereArgs: [workEntryId],
    );
  }
}
