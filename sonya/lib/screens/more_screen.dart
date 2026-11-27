import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import 'business_profile_screen.dart';
import 'expenses_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = app.strings;

    return Scaffold(
      appBar: AppBar(title: Text(s.more)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.deepGreen.withValues(alpha: 0.14),
                child: const Icon(
                  Icons.storefront,
                  color: AppColors.deepGreen,
                  size: 28,
                ),
              ),
              title: Text(
                app.profile.businessName,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              subtitle: Text(
                '${app.profile.ownerName} • दर: ₹${app.profile.defaultRatePerTon.toStringAsFixed(0)}/टन',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BusinessProfileScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _menuTile(
            context,
            icon: Icons.receipt_long,
            color: AppColors.expenseRed,
            title: s.expenses,
            subtitle: 'डिझेल, मजुरी, ट्रॅक्टर, दुरुस्ती आणि इतर खर्च',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpensesScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.bar_chart_rounded,
            color: AppColors.deepGreen,
            title: s.reports,
            subtitle: 'दैनिक, साप्ताहिक, मासिक आणि ग्राहकनिहाय PDF अहवाल',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.business_center_outlined,
            color: AppColors.infoBlue,
            title: s.businessProfile,
            subtitle: 'व्यवसायाचे नाव, मालक, लोगो आणि प्रति टन दर',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BusinessProfileScreen(),
              ),
            ),
          ),
          _menuTile(
            context,
            icon: Icons.settings_outlined,
            color: Colors.blueGrey,
            title: s.settings,
            subtitle: 'डार्क मोड / लाईट मोड आणि भाषा',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
