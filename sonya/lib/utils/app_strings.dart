class AppStrings {
  final String lang;
  const AppStrings(this.lang);

  bool get isMr => lang == 'mr';

  String get appTitle => isMr ? 'मुरघास व्यवसाय व्यवस्थापन' : 'Murghas Business';
  String get home => isMr ? 'मुख्यपृष्ठ' : 'Home';
  String get customers => isMr ? 'ग्राहक' : 'Customers';
  String get work => isMr ? 'काम' : 'Work';
  String get payments => isMr ? 'पेमेंट्स' : 'Payments';
  String get more => isMr ? 'अधिक' : 'More';

  // Dashboard
  String get totalRevenue => isMr ? 'एकूण उत्पन्न' : 'Total Revenue';
  String get totalExpenses => isMr ? 'एकूण खर्च' : 'Total Expenses';
  String get netProfit => isMr ? 'निव्वळ नफा' : 'Net Profit';
  String get totalProduction => isMr ? 'एकूण उत्पादन (टन)' : 'Total Production';
  String get totalCustomers => isMr ? 'एकूण ग्राहक' : 'Total Customers';
  String get pendingPayments => isMr ? 'येणे बाकी' : 'Pending Payments';
  String get todaysWork => isMr ? 'आजचे काम' : "Today's Work";
  String get thisMonthsWork => isMr ? 'या महिन्याचे काम' : "This Month's Work";
  String get weekly => isMr ? 'साप्ताहिक' : 'Weekly';
  String get monthly => isMr ? 'मासिक' : 'Monthly';
  String get quickActions => isMr ? 'जलद कृती' : 'Quick Actions';
  String get newWork => isMr ? 'नवीन काम' : 'New Work';
  String get addPayment => isMr ? 'पेमेंट नोंदवा' : 'Add Payment';
  String get addExpense => isMr ? 'खर्च नोंदवा' : 'Add Expense';
  String get addCustomer => isMr ? 'नवीन ग्राहक' : 'Add Customer';
  String get recentWork => isMr ? 'अलीकडील कामे' : 'Recent Work Entries';
  String get recentPayments => isMr ? 'अलीकडील पेमेंट्स' : 'Recent Payments';
  String get pendingList => isMr ? 'बाकी रक्कम यादी' : 'Pending Payments List';
  String get revenueVsExpense => isMr ? 'उत्पन्न विरुद्ध खर्च' : 'Revenue vs Expense';

  // Customers
  String get searchCustomers => isMr ? 'नाव किंवा मोबाईल शोधा...' : 'Search name or mobile...';
  String get allVillages => isMr ? 'सर्व गावे' : 'All Villages';
  String get customerName => isMr ? 'ग्राहकाचे नाव' : 'Customer Name';
  String get mobileNumber => isMr ? 'मोबाईल नंबर' : 'Mobile Number';
  String get village => isMr ? 'गाव' : 'Village';
  String get address => isMr ? 'पत्ता' : 'Address';
  String get totalBilled => isMr ? 'एकूण बिल' : 'Total Billed';
  String get totalReceived => isMr ? 'मिळालेली रक्कम' : 'Received';
  String get remainingBalance => isMr ? 'येणे बाकी' : 'Balance';
  String get workHistory => isMr ? 'कामाचा इतिहास' : 'Work History';
  String get paymentHistory => isMr ? 'पेमेंट इतिहास' : 'Payment History';
  String get editCustomer => isMr ? 'ग्राहक संपादित करा' : 'Edit Customer';

  // Work Entry
  String get workDate => isMr ? 'कामाची तारीख' : 'Work Date';
  String get machineName => isMr ? 'मशीन / ट्रॅक्टरचे नाव' : 'Machine / Tractor Name';
  String get quantityTons => isMr ? 'मका कटाई प्रमाण (टन)' : 'Maize Cutting Quantity (Tons)';
  String get ratePerTon => isMr ? 'दर प्रति टन (₹)' : 'Rate per Ton (₹)';
  String get additionalCharges => isMr ? 'अतिरिक्त शुल्क (₹)' : 'Additional Charges (₹)';
  String get discount => isMr ? 'सवलत (₹)' : 'Discount (₹)';
  String get totalBillAmount => isMr ? 'एकूण बिल रक्कम' : 'Total Bill Amount';
  String get advancePayment => isMr ? 'अॅडव्हान्स पेमेंट (₹)' : 'Advance / Received (₹)';
  String get notes => isMr ? 'टीप' : 'Notes';
  String get saveWork => isMr ? 'काम जतन करा' : 'Save Work Entry';
  String get updateWork => isMr ? 'काम अद्ययावत करा' : 'Update Work Entry';

  // Payments
  String get recordPayment => isMr ? 'पेमेंट नोंदवा' : 'Record Payment';
  String get selectCustomer => isMr ? 'ग्राहक निवडा' : 'Select Customer';
  String get selectWorkEntry => isMr ? 'कामाची नोंद निवडा' : 'Select Work Entry';
  String get paymentAmount => isMr ? 'पेमेंट रक्कम (₹)' : 'Payment Amount (₹)';
  String get paymentDate => isMr ? 'पेमेंट तारीख' : 'Payment Date';
  String get paymentMethod => isMr ? 'पेमेंट पद्धत' : 'Payment Method';

  // Expenses
  String get expenses => isMr ? 'खर्च व्यवस्थापन' : 'Expenses';
  String get expenseCategory => isMr ? 'खर्च प्रकार' : 'Expense Category';
  String get expenseDate => isMr ? 'खर्चाची तारीख' : 'Expense Date';
  String get amount => isMr ? 'रक्कम (₹)' : 'Amount (₹)';
  String get description => isMr ? 'तपशील' : 'Description';
  String get today => isMr ? 'आज' : 'Today';
  String get thisWeek => isMr ? 'हा आठवडा' : 'This Week';
  String get thisMonth => isMr ? 'हा महिना' : 'This Month';

  // Reports & More
  String get reports => isMr ? 'व्यवसाय अहवाल' : 'Reports & Analytics';
  String get businessProfile => isMr ? 'व्यवसाय प्रोफाइल' : 'Business Profile';
  String get settings => isMr ? 'सेटिंग्ज' : 'Settings';
  String get exportPdf => isMr ? 'PDF निर्यात करा' : 'Export PDF';
  String get downloadPdf => isMr ? 'PDF डाउनलोड' : 'Download PDF';
  String get sharePdf => isMr ? 'PDF शेअर करा' : 'Share PDF';
  String get shareWhatsApp => isMr ? 'WhatsApp वर पाठवा' : 'Share on WhatsApp';
  String get printReceipt => isMr ? 'पावती प्रिंट करा' : 'Print Receipt';
  String get delete => isMr ? 'हटवा' : 'Delete';
  String get cancel => isMr ? 'रद्द करा' : 'Cancel';
  String get save => isMr ? 'जतन करा' : 'Save';
  String get edit => isMr ? 'संपादित करा' : 'Edit';
  String get confirmDelete => isMr ? 'हटवण्याची खात्री करा' : 'Confirm Delete';
}
