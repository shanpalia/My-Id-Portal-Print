import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const MyIdPortalPrintApp());

class MyIdPortalPrintApp extends StatelessWidget {
  const MyIdPortalPrintApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My ID Portal Print',
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1479FF)), scaffoldBackgroundColor: const Color(0xFFF7FAFF)),
        home: const HomeShell(),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  DateTime? lastBack;
  final pages = const [HomePage(), FilesPage(), PrintPage(), HistoryPage(), SettingsPage()];

  Future<bool> handleBack() async {
    if (Navigator.of(context).canPop()) return true;
    if (index != 0) { setState(() => index = 0); return false; }
    final now = DateTime.now();
    if (lastBack == null || now.difference(lastBack!) > const Duration(seconds: 2)) {
      lastBack = now;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Press back again to exit'), duration: Duration(seconds: 2)));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop && await handleBack() && mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          body: IndexedStack(index: index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'My Files'),
              NavigationDestination(icon: Icon(Icons.print_outlined), selectedIcon: Icon(Icons.print_rounded), label: 'Print'),
              NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history_rounded), label: 'History'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
            ],
          ),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => _Page(
        title: 'My ID Portal Print',
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 24), children: [
          Center(child: Container(width: 92, height: 92, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 14, offset: Offset(0, 5))]), child: ClipRRect(borderRadius: BorderRadius.circular(19), child: SvgPicture.asset('assets/app_icon.svg')))),
          const SizedBox(height: 12),
          const Center(child: Text('My ID Portal Print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),),
          const SizedBox(height: 4),
          const Center(child: Text('All Your ID Documents in One Place', style: TextStyle(color: Color(0xFF72809A))),),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(colors: [Color(0xFFDDF2FF), Color(0xFFEEF7FF)])), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Scan, Crop & Print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF142D63))), SizedBox(height: 8), Text('Make clean A4 prints with automatic alignment.', style: TextStyle(color: Color(0xFF4D6486), height: 1.35))])), Icon(Icons.document_scanner_rounded, size: 78, color: Color(0xFF1479FF))])),
          const SizedBox(height: 18),
          Row(children: [_ActionCard(Icons.camera_alt_rounded, 'Scan', const Color(0xFF1479FF), () {}), const SizedBox(width: 10), _ActionCard(Icons.photo_library_rounded, 'Gallery', const Color(0xFF12B76A), () {}), const SizedBox(width: 10), _ActionCard(Icons.picture_as_pdf_rounded, 'PDF', const Color(0xFFF04444), () {})]),
          const SizedBox(height: 24),
          const Text('Popular Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))), const SizedBox(height: 12),
          GridView.count(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .95, children: const [_DocTile(Icons.badge_rounded, 'Aadhaar'), _DocTile(Icons.credit_card_rounded, 'PAN'), _DocTile(Icons.how_to_vote_rounded, 'Voter ID'), _DocTile(Icons.directions_car_rounded, 'DL'), _DocTile(Icons.public_rounded, 'Passport'), _DocTile(Icons.description_rounded, 'Ration'), _DocTile(Icons.school_rounded, 'School ID'), _DocTile(Icons.more_horiz_rounded, 'Other')]),
          const SizedBox(height: 24), const Text('Recent Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))), const SizedBox(height: 10),
          const _RecentCard('Aadhaar_Print', 'Recent', Icons.badge_rounded), const _RecentCard('PAN_Print', 'Recent', Icons.credit_card_rounded),
        ]));
}

class FilesPage extends StatelessWidget { const FilesPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'My Files', child: Center(child: Text('Your saved documents will appear here.'))); }
class PrintPage extends StatelessWidget { const PrintPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'Print', child: Center(child: Text('A4 print setup will appear here.'))); }
class HistoryPage extends StatelessWidget { const HistoryPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'History', child: Center(child: Text('Print history will appear here.'))); }

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => _Page(title: 'Settings', child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE4EAF3))), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 64, height: 64, child: SvgPicture.asset('assets/app_icon.svg'))), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My ID Portal Print', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF14233D))), SizedBox(height: 3), Text('Developer by ShanPalia', style: TextStyle(color: Color(0xFF72809A), fontSize: 12)), SizedBox(height: 3), Text('Version 1.0.0', style: TextStyle(color: Color(0xFF1479FF), fontWeight: FontWeight.w600, fontSize: 12))]))])),
        const SizedBox(height: 14),
        Card(elevation: 0, color: const Color(0xFFEAF5FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.system_update_rounded, color: Color(0xFF1479FF))), title: const Text('Check for Update', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF14233D))), subtitle: const Text('Check the latest My ID Portal Print version'), trailing: FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are using the latest available version.'))); }, child: const Text('CHECK')))),
        const SizedBox(height: 12),
        _SettingTile(Icons.print_rounded, 'Printer Settings', 'Configure your printer', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrinterSettingsPage()))),
        _SettingTile(Icons.picture_as_pdf_rounded, 'A4 & PDF Settings', 'Paper and PDF preferences', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfSettingsPage()))),
        _SettingTile(Icons.info_outline_rounded, 'About', 'My ID Portal Print', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()))),
      ]));
}

class PrinterSettingsPage extends StatelessWidget { const PrinterSettingsPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'Printer Settings', child: Center(child: Text('Printer settings'))); }
class PdfSettingsPage extends StatelessWidget { const PdfSettingsPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'A4 & PDF Settings', child: Center(child: Text('A4 and PDF settings'))); }
class AboutPage extends StatelessWidget { const AboutPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'About', child: Center(child: Text('My ID Portal Print\nDeveloper by ShanPalia', textAlign: TextAlign.center))); }

class _Page extends StatelessWidget { final String title; final Widget child; const _Page({required this.title, required this.child}); @override Widget build(BuildContext context) => SafeArea(child: Column(children: [AppBar(title: Text(title), backgroundColor: Colors.transparent, elevation: 0), Expanded(child: child)])); }
class _ActionCard extends StatelessWidget { final IconData icon; final String label; final Color color; final VoidCallback onTap; const _ActionCard(this.icon, this.label, this.color, this.onTap); @override Widget build(BuildContext c) => Expanded(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Ink(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE4EAF3))), child: Column(children: [Icon(icon, size: 30, color: color), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))])))); }
class _DocTile extends StatelessWidget { final IconData icon; final String label; const _DocTile(this.icon, this.label); @override Widget build(BuildContext c) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4EAF3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF1479FF), size: 30), const SizedBox(height: 7), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))])); }
class _RecentCard extends StatelessWidget { final String title, subtitle; final IconData icon; const _RecentCard(this.title, this.subtitle, this.icon); @override Widget build(BuildContext c) => Card(elevation: 0, child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFE8F2FF), child: Icon(icon, color: const Color(0xFF1479FF))), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle))); }
class _SettingTile extends StatelessWidget { final IconData icon; final String title, subtitle; final VoidCallback onTap; const _SettingTile(this.icon, this.title, this.subtitle, this.onTap); @override Widget build(BuildContext c) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: onTap, leading: Icon(icon, color: const Color(0xFF1479FF)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded))); }
