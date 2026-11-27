import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

class CustomerRepository {
  static const _webKey = 'web_customers_v1';
  final DatabaseService _dbService;
  CustomerRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Customer>> getAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_webKey);
      if (raw == null || raw.isEmpty) return [];
      final list = (jsonDecode(raw) as List)
          .map((e) => Customer.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    }
    final db = await _dbService.database;
    final maps = await db.query('customers', orderBy: 'name COLLATE NOCASE ASC');
    return maps.map(Customer.fromMap).toList();
  }

  Future<void> _saveWeb(List<Customer> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _webKey,
      jsonEncode(items.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> insert(Customer customer) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((c) => c.id == customer.id);
      list.add(customer);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(Customer customer) async {
    if (kIsWeb) {
      final list = await getAll();
      final idx = list.indexWhere((c) => c.id == customer.id);
      if (idx != -1) {
        list[idx] = customer;
        await _saveWeb(list);
      }
      return;
    }
    final db = await _dbService.database;
    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> delete(String id) async {
    if (kIsWeb) {
      final list = await getAll();
      list.removeWhere((c) => c.id == id);
      await _saveWeb(list);
      return;
    }
    final db = await _dbService.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }
}
