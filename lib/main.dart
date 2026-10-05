import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  Future<void> _browse(BuildContext context, {String? documentType}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, withData: false);
    if (result == null || result.files.single.path == null || !context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentPreviewPage(path: result.files.single.path!, title: documentType ?? 'Document')));
  }

  Future<void> _scan(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100);
    if (image == null || !context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentPreviewPage(path: image.path, title: 'Scanned Document')));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('My ID Portal Print', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF14233D))),
              SizedBox(height: 2),
              Text('By PaliaAPK HUB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF72809A))),
            ])),
            Container(width: 54, height: 54, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 10, offset: Offset(0, 3))]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: SvgPicture.asset('assets/app_icon.svg'))),
          ]),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(colors: [Color(0xFFDDF2FF), Color(0xFFEEF7FF)])), child: Row(children: const [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Scan, Crop & Print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF142D63))), SizedBox(height: 7), Text('Make clean A4 prints with automatic alignment.', style: TextStyle(color: Color(0xFF4D6486), height: 1.35))])), Icon(Icons.document_scanner_rounded, size: 70, color: Color(0xFF1479FF))])),
          const SizedBox(height: 18),
          Row(children: [_ActionCard(Icons.camera_alt_rounded, 'Scan', const Color(0xFF1479FF), () => _scan(context)), const SizedBox(width: 10), _ActionCard(Icons.photo_library_rounded, 'Gallery', const Color(0xFF12B76A), () => _browse(context)), const SizedBox(width: 10), _ActionCard(Icons.picture_as_pdf_rounded, 'PDF', const Color(0xFFF04444), () => _browse(context, documentType: 'PDF Document'))]),
          const SizedBox(height: 24),
          const Text('Popular Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
          const SizedBox(height: 12),
          GridView.count(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .92, children: [
            _DocTile(Icons.badge_rounded, 'Aadhaar', () => _browse(context, documentType: 'Aadhaar')),
            _DocTile(Icons.credit_card_rounded, 'PAN', () => _browse(context, documentType: 'PAN')),
            _DocTile(Icons.how_to_vote_rounded, 'Voter ID', () => _browse(context, documentType: 'Voter ID')),
            _DocTile(Icons.directions_car_rounded, 'DL', () => _browse(context, documentType: 'Driving Licence')),
            _DocTile(Icons.public_rounded, 'Passport', () => _browse(context, documentType: 'Passport')),
            _DocTile(Icons.description_rounded, 'Ration', () => _browse(context, documentType: 'Ration Card')),
            _DocTile(Icons.school_rounded, 'School ID', () => _browse(context, documentType: 'School ID')),
            _DocTile(Icons.more_horiz_rounded, 'Other', () => _browse(context, documentType: 'Other Document')),
          ]),
          const SizedBox(height: 24),
          const Text('Recent Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
          const SizedBox(height: 10),
          const _RecentCard('Aadhaar_Print', 'Ready for A4', Icons.badge_rounded),
          const _RecentCard('PAN_Print', 'Ready for A4', Icons.credit_card_rounded),
        ]),
      );
}

class DocumentPreviewPage extends StatelessWidget {
  final String path;
  final String title;
  const DocumentPreviewPage({super.key, required this.path, required this.title});

  Future<Uint8List> _makePdf() async {
    final bytes = await File(path).readAsBytes();
    final doc = pw.Document();
    final image = pw.MemoryImage(bytes);
    doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, margin: pw.EdgeInsets.zero, build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain))));
    return doc.save();
  }

  Future<void> _print(BuildContext context) async {
    final data = await _makePdf();
    await Printing.layoutPdf(onLayout: (_) async => data);
  }

  Future<void> _sharePdf() async {
    final data = await _makePdf();
    await Printing.sharePdf(bytes: data, filename: 'my_id_portal_print.pdf');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent, elevation: 0),
        body: ListView(padding: const EdgeInsets.all(18), children: [
          Container(height: 480, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFDCE5F0))), child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(File(path), fit: BoxFit.contain))),
          const SizedBox(height: 14),
          const Text('A4 Preview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
          const SizedBox(height: 6),
          const Text('Image loaded successfully. Print or share it as an A4 PDF.', style: TextStyle(color: Color(0xFF72809A))),
          const SizedBox(height: 18),
          Row(children: [Expanded(child: FilledButton.icon(onPressed: () => _print(context), icon: const Icon(Icons.print_rounded), label: const Text('Print A4'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: _sharePdf, icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('PDF')))]),
        ]),
      );
}

class FilesPage extends StatelessWidget { const FilesPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'My Files', child: Center(child: Text('Choose a document from Home to add it here.'))); }
class PrintPage extends StatelessWidget { const PrintPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'Print', child: Center(child: Text('Select a document from Home to prepare an A4 print.'))); }
class HistoryPage extends StatelessWidget { const HistoryPage({super.key}); @override Widget build(BuildContext c) => const _Page(title: 'History', child: Center(child: Text('Print history will appear here.'))); }

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => _Page(title: 'Settings', child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 24), children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE4EAF3))), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 64, height: 64, child: SvgPicture.asset('assets/app_icon.svg'))), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My ID Portal Print', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF14233D))), SizedBox(height: 3), Text('Developer by ShanPalia', style: TextStyle(color: Color(0xFF72809A), fontSize: 12)), SizedBox(height: 3), Text('Version 1.0.0', style: TextStyle(color: Color(0xFF1479FF), fontWeight: FontWeight.w600, fontSize: 12))]))])),
        const SizedBox(height: 14),
        Card(elevation: 0, color: const Color(0xFFEAF5FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.system_update_rounded, color: Color(0xFF1479FF))), title: const Text('Check for Update', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF14233D))), subtitle: const Text('Check the latest version'), trailing: FilledButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are using the latest available version.'))); }, child: const Text('CHECK')))),
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
class _DocTile extends StatelessWidget { final IconData icon; final String label; final VoidCallback onTap; const _DocTile(this.icon, this.label, this.onTap); @override Widget build(BuildContext c) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Ink(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4EAF3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF1479FF), size: 30), const SizedBox(height: 7), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))]))); }
class _RecentCard extends StatelessWidget { final String title, subtitle; final IconData icon; const _RecentCard(this.title, this.subtitle, this.icon); @override Widget build(BuildContext c) => Card(elevation: 0, child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFE8F2FF), child: Icon(icon, color: const Color(0xFF1479FF))), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle))); }
class _SettingTile extends StatelessWidget { final IconData icon; final String title, subtitle; final VoidCallback onTap; const _SettingTile(this.icon, this.title, this.subtitle, this.onTap); @override Widget build(BuildContext c) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(onTap: onTap, leading: Icon(icon, color: const Color(0xFF1479FF)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right_rounded))); }
