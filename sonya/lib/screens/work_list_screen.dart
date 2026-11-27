import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/business_data_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/work_entry_card.dart';
import 'payment_form_screen.dart';
import 'work_detail_screen.dart';
import 'work_form_screen.dart';

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  String _filter = 'all'; // all, pending, paid
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppProvider>().strings;
    final data = context.watch<BusinessDataProvider>();

    final entries = data.workEntries.where((w) {
      final matchesFilter = _filter == 'all' ||
          (_filter == 'pending' && !w.isPaid) ||
          (_filter == 'paid' && w.isPaid);
      final matchesSearch = _search.isEmpty ||
          w.customerName.toLowerCase().contains(_search.toLowerCase()) ||
          w.village.toLowerCase().contains(_search.toLowerCase()) ||
          w.machineName.toLowerCase().contains(_search.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(s.work)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'ग्राहक, गाव किंवा मशीन शोधा...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _search = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _search = v.trim()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('सर्व'),
                      selected: _filter == 'all',
                      onSelected: (_) => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('बाकी'),
                      selected: _filter == 'pending',
                      onSelected: (_) => setState(() => _filter = 'pending'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('जमा'),
                      selected: _filter == 'paid',
                      onSelected: (_) => setState(() => _filter = 'paid'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.agriculture_outlined,
                    title: 'कामाची नोंद नाही',
                    subtitle:
                        'दररोजची मका कटाई, टन, दर आणि बिलाची नोंद येथे करा.',
                    actionLabel: s.newWork,
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WorkFormScreen(),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final w = entries[i];
                      return WorkEntryCard(
                        work: w,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkDetailScreen(workId: w.id),
                          ),
                        ),
                        onCollectPayment: w.isPaid
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentFormScreen(
                                      initialCustomerId: w.customerId,
                                      initialWorkId: w.id,
                                    ),
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
          MaterialPageRoute(builder: (_) => const WorkFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(s.newWork),
      ),
    );
  }
}
