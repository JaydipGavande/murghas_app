import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../widgets/customer_card.dart';
import '../widgets/empty_state_widget.dart';
import 'customer_detail_screen.dart';
import 'customer_form_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';
  String _selectedVillage = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppProvider>().strings;
    final data = context.watch<BusinessDataProvider>();
    final villages = data.distinctVillages;

    final filtered = data.customers.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.mobile.contains(_searchQuery) ||
          c.village.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesVillage =
          _selectedVillage.isEmpty || c.village == _selectedVillage;
      return matchesSearch && matchesVillage;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.customers),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: s.searchCustomers,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
                if (villages.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(s.allVillages),
                            selected: _selectedVillage.isEmpty,
                            onSelected: (_) =>
                                setState(() => _selectedVillage = ''),
                          ),
                        ),
                        ...villages.map(
                          (v) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(v),
                              selected: _selectedVillage == v,
                              onSelected: (_) => setState(
                                () => _selectedVillage =
                                    _selectedVillage == v ? '' : v,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: data.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.people_outline,
                        title: 'कोणताही ग्राहक सापडला नाही',
                        subtitle:
                            'मुरघास कटाईचे काम, बिले आणि बाकी रक्कम पाहण्यासाठी ग्राहक जोडा.',
                        actionLabel: s.addCustomer,
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerFormScreen(),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return CustomerCard(
                            customer: c,
                            totalBilled: data.customerTotalBilled(c.id),
                            totalReceived: data.customerTotalReceived(c.id),
                            remainingBalance:
                                data.customerRemainingBalance(c.id),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CustomerDetailScreen(customerId: c.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: Text(s.addCustomer),
      ),
    );
  }
}
