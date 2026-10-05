import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

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
  late final List<Widget> pages = <Widget>[const HomePage(), const FilesPage(), const PrintPage(), const HistoryPage(), const SettingsPage()];

  Future<bool> handleBack() async {
    if (index != 0) {
      setState(() => index = 0);
      return false;
    }
    final now = DateTime.now();
    if (lastBack == null || now.difference(lastBack!) > const Duration(seconds: 2)) {
      lastBack = now;
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Press back again to exit'), duration: Duration(seconds: 2)));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (await handleBack() && mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          body: IndexedStack(index: index, children: pages),
          bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'My Files'),
            NavigationDestination(icon: Icon(Icons.print_outlined), selectedIcon: Icon(Icons.print_rounded), label: 'Print'),
            NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history_rounded), label: 'History'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
          ]),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _browse(BuildContext context, String title) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (!context.mounted) return;
    final path = result?.files.single.path;
    if (path == null) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PrintSetupPage(path: path, title: title)));
  }

  Future<void> _scan(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100);
    if (!context.mounted || image == null) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => PrintSetupPage(path: image.path, title: 'Scanned Document')));
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My ID Portal Print', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF14233D))), SizedBox(height: 2), Text('By PaliaAPK HUB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF72809A)))])),
          Container(width: 54, height: 54, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 10, offset: Offset(0, 3))]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: SvgPicture.asset('assets/app_icon.svg'))),
        ]),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(colors: [Color(0xFFDDF2FF), Color(0xFFEEF7FF)])), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Scan, Crop & Print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF142D63))), SizedBox(height: 7), Text('Upload an ID, choose its physical size, adjust it on A4 and print.', style: TextStyle(color: Color(0xFF4D6486), height: 1.35))])), Icon(Icons.document_scanner_rounded, size: 70, color: Color(0xFF1479FF))])),
        const SizedBox(height: 18),
        Row(children: [
          _ActionCard(Icons.camera_alt_rounded, 'Scan', const Color(0xFF1479FF), () => _scan(context)),
          const SizedBox(width: 10),
          _ActionCard(Icons.folder_open_rounded, 'Browse', const Color(0xFF12B76A), () => _browse(context, 'Document')),
          const SizedBox(width: 10),
          _ActionCard(Icons.picture_as_pdf_rounded, 'PDF', const Color(0xFFF04444), () => _browse(context, 'PDF Print')),
        ]),
        const SizedBox(height: 24),
        const Text('ID Card Print', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
        const SizedBox(height: 12),
        GridView.count(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .92, children: [
          _DocTile(Icons.badge_rounded, 'Aadhaar', () => _browse(context, 'Aadhaar')),
          _DocTile(Icons.credit_card_rounded, 'PAN', () => _browse(context, 'PAN Card')),
          _DocTile(Icons.how_to_vote_rounded, 'Voter ID', () => _browse(context, 'Voter ID')),
          _DocTile(Icons.directions_car_rounded, 'DL', () => _browse(context, 'Driving Licence')),
          _DocTile(Icons.public_rounded, 'Passport', () => _browse(context, 'Passport')),
          _DocTile(Icons.description_rounded, 'Ration', () => _browse(context, 'Ration Card')),
          _DocTile(Icons.school_rounded, 'School ID', () => _browse(context, 'School ID')),
          _DocTile(Icons.more_horiz_rounded, 'Other', () => _browse(context, 'Other Document')),
        ]),
      ]));
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionCard(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: Material(color: Colors.white, borderRadius: BorderRadius.circular(18), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Column(children: [Icon(icon, size: 30, color: color), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))])))));
}

class _DocTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _DocTile(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(16), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4EAF3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: const Color(0xFF1479FF), size: 30), const SizedBox(height: 7), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))]))));
}

class PrintOptions {
  final String unit; final double width; final double height; final bool blackAndWhite; final String cardType;
  const PrintOptions({required this.unit, required this.width, required this.height, required this.blackAndWhite, required this.cardType});
  double get widthMm => unit == 'inch' ? width * 25.4 : unit == 'cm' ? width * 10 : width;
  double get heightMm => unit == 'inch' ? height * 25.4 : unit == 'cm' ? height * 10 : height;
}

class PrintSetupPage extends StatefulWidget {
  final String path; final String title;
  const PrintSetupPage({super.key, required this.path, required this.title});
  @override State<PrintSetupPage> createState() => _PrintSetupPageState();
}

class _PrintSetupPageState extends State<PrintSetupPage> {
  String unit = 'mm'; String cardType = 'ID Card'; double width = 85.6; double height = 54; bool bw = false;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('ID Card Print')), body: ListView(padding: const EdgeInsets.all(16), children: [
    const Text('1. Select Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 10),
    Wrap(spacing: 8, runSpacing: 8, children: ['ID Card', 'Aadhaar', 'Voter', 'PAN', 'DL'].map((v) => ChoiceChip(label: Text(v), selected: cardType == v, onSelected: (_) => setState(() => cardType = v))).toList()),
    const SizedBox(height: 22), const Text('2. Size before A4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 10),
    DropdownButtonFormField<String>(initialValue: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'inch', child: Text('Inch')), DropdownMenuItem(value: 'mm', child: Text('Millimeter')), DropdownMenuItem(value: 'cm', child: Text('Centimeter'))], onChanged: (v) => setState(() => unit = v ?? 'mm')),
    const SizedBox(height: 12),
    Row(children: [Expanded(child: TextFormField(initialValue: '85.6', keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Width', border: OutlineInputBorder()), onChanged: (v) => width = double.tryParse(v) ?? width)), const SizedBox(width: 10), Expanded(child: TextFormField(initialValue: '54', keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height', border: OutlineInputBorder()), onChanged: (v) => height = double.tryParse(v) ?? height))]),
    const SizedBox(height: 12), Card(child: SwitchListTile(value: bw, onChanged: (v) => setState(() => bw = v), title: const Text('Black & White'), subtitle: const Text('Grayscale output'), secondary: const Icon(Icons.contrast_rounded))),
    const SizedBox(height: 16), FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentEditorPage(path: widget.path, title: widget.title, options: PrintOptions(unit: unit, width: width, height: height, blackAndWhite: bw, cardType: cardType)))),
      icon: const Icon(Icons.tune_rounded), label: const Text('OPEN A4 EDITOR')),
  ]));
}

class DocumentEditorPage extends StatefulWidget {
  final String path; final String title; final PrintOptions options;
  const DocumentEditorPage({super.key, required this.path, required this.title, required this.options});
  @override State<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends State<DocumentEditorPage> {
  double x = .08, y = .08, scale = 1, rotation = 0; bool busy = false;

  void _reset() => setState(() { x = .08; y = .08; scale = 1; rotation = 0; });

  Future<Uint8List> _imageBytes() async {
    final source = await File(widget.path).readAsBytes();
    if (!widget.options.blackAndWhite) return source;
    final codec = await ui.instantiateImageCodec(source); final frame = await codec.getNextFrame(); final image = frame.image;
    final recorder = ui.PictureRecorder(); final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..colorFilter = const ui.ColorFilter.matrix(<double>[0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0,0,0,1,0]);
    canvas.drawImage(image, ui.Offset.zero, paint); final rendered = await recorder.endRecording().toImage(image.width, image.height); final data = await rendered.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _makePdf() async {
    final bytes = await _imageBytes(); final doc = pw.Document(); final image = pw.MemoryImage(bytes);
    const pageW = 595.28, pageH = 841.89;
    final w = (widget.options.widthMm / 25.4 * 72 * scale).clamp(1.0, pageW); final h = (widget.options.heightMm / 25.4 * 72 * scale).clamp(1.0, pageH);
    final left = (x * pageW).clamp(0.0, math.max(0.0, pageW - w)); final top = (y * pageH).clamp(0.0, math.max(0.0, pageH - h));
    doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, margin: pw.EdgeInsets.zero, build: (_) => pw.Stack(children: [pw.Positioned(left: left, top: top, child: pw.Container(width: w, height: h, child: pw.Transform.rotate(angle: rotation, child: pw.Image(image, fit: pw.BoxFit.fill))))]));
    return doc.save();
  }

  Future<void> _print() async { setState(() => busy = true); try { final data = await _makePdf(); if (!mounted) return; await Printing.layoutPdf(onLayout: (_) async => data); } finally { if (mounted) setState(() => busy = false); } }
  Future<void> _share() async { setState(() => busy = true); try { final data = await _makePdf(); if (!mounted) return; await Printing.sharePdf(bytes: data, filename: '${widget.title.replaceAll(' ', '_')}_A4.pdf'); } finally { if (mounted) setState(() => busy = false); } }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('${widget.options.cardType} • A4'), actions: [IconButton(onPressed: _reset, icon: const Icon(Icons.refresh_rounded))]), body: Column(children: [
    Expanded(child: LayoutBuilder(builder: (context, constraints) {
      final pageW = math.min(constraints.maxWidth - 28, (constraints.maxHeight - 16) * 210 / 297); final pageH = pageW * 297 / 210;
      final cardW = (widget.options.widthMm / 210) * pageW * scale; final cardH = (widget.options.heightMm / 297) * pageH * scale;
      return Center(child: Container(width: pageW, height: pageH, decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFCBD5E1)), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 16)]), child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(left: x * pageW, top: y * pageH, child: GestureDetector(onScaleUpdate: (d) => setState(() { x = (x + d.focalPointDelta.dx / pageW).clamp(0.0, 1.0); y = (y + d.focalPointDelta.dy / pageH).clamp(0.0, 1.0); if (d.scale != 1) scale = (scale * d.scale).clamp(.25, 3.0); if (d.rotation != 0) rotation += d.rotation; }), child: Transform.rotate(angle: rotation, child: Container(width: cardW.clamp(20.0, pageW), height: cardH.clamp(20.0, pageH), decoration: BoxDecoration(border: Border.all(color: const Color(0xFF1479FF), width: 2)), child: ColorFiltered(colorFilter: widget.options.blackAndWhite ? const ColorFilter.matrix(<double>[0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0.299,0.587,0,0,0,0,0,1,0]) : const ColorFilter.mode(Colors.transparent, BlendMode.dst), child: Image.file(File(widget.path), fit: BoxFit.fill, filterQuality: FilterQuality.high))))),
      ]));
    })),
    Container(padding: const EdgeInsets.fromLTRB(14, 10, 14, 12), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE4EAF3)))), child: Column(children: [
      Row(children: [const Icon(Icons.open_with_rounded, size: 18), const SizedBox(width: 6), Expanded(child: Text('Drag • Pinch resize • Rotate • ${widget.options.blackAndWhite ? 'B&W' : 'Color'}', style: const TextStyle(fontWeight: FontWeight.w700))),]),
      const SizedBox(height: 8), Row(children: [Expanded(child: FilledButton.icon(onPressed: busy ? null : _print, icon: const Icon(Icons.print_rounded), label: const Text('PRINT A4'))), const SizedBox(width: 8), IconButton(onPressed: busy ? null : _share, tooltip: 'PDF', icon: const Icon(Icons.picture_as_pdf_rounded))]), if (busy) const LinearProgressIndicator(),
    ])),
  ]));
}

class _GridPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final p = Paint()..color = const Color(0xFFEAF0F7)..strokeWidth = .7; for (int i = 1; i < 10; i++) { final dx = size.width * i / 10; final dy = size.height * i / 10; canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), p); canvas.drawLine(Offset(0, dy), Offset(size.width, dy), p); } }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FilesPage extends StatelessWidget { const FilesPage({super.key}); @override Widget build(BuildContext context) => const _SimplePage(title: 'My Files', icon: Icons.folder_rounded, text: 'Selected documents will appear here.'); }
class PrintPage extends StatelessWidget { const PrintPage({super.key}); @override Widget build(BuildContext context) => const _SimplePage(title: 'Print', icon: Icons.print_rounded, text: 'Select an ID card from Home to start an A4 print.'); }
class HistoryPage extends StatelessWidget { const HistoryPage({super.key}); @override Widget build(BuildContext context) => const _SimplePage(title: 'History', icon: Icons.history_rounded, text: 'Print history will appear here.'); }

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE4EAF3))), child: Row(children: [Container(width: 58, height: 58, padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFEAF5FF), borderRadius: BorderRadius.circular(16)), child: SvgPicture.asset('assets/app_icon.svg')), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('My ID Portal Print', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text('By PaliaAPK HUB', style: TextStyle(color: Color(0xFF72809A))), SizedBox(height: 3), Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFF72809A)))]))])),
    const SizedBox(height: 16),
    Card(child: ListTile(leading: const Icon(Icons.system_update_rounded, color: Color(0xFF1479FF)), title: const Text('Check for Update', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Check the latest My ID Portal Print release'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Check for Update'), content: const Text('You are using My ID Portal Print 1.0.0.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))])))),
    Card(child: ListTile(leading: const Icon(Icons.info_outline_rounded), title: const Text('About'), subtitle: const Text('My ID Portal Print • PaliaAPK HUB'), trailing: const Icon(Icons.chevron_right_rounded), onTap: () => showAboutDialog(context: context, applicationName: 'My ID Portal Print', applicationVersion: '1.0.0', applicationLegalese: 'Developer by ShanPalia'))),
  ]));
}

class _SimplePage extends StatelessWidget {
  final String title; final IconData icon; final String text;
  const _SimplePage({required this.title, required this.icon, required this.text});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 64, color: const Color(0xFF1479FF)), const SizedBox(height: 14), Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFF5F6F86)))])));
}
