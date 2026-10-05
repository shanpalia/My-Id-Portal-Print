import 'dart:io';
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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1479FF)),
          scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        ),
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
    if (index != 0) {
      setState(() => index = 0);
      return false;
    }
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

  Future<void> _openSetup(BuildContext context, String path, String title) async {
    if (!context.mounted) return;
    final options = await showDialog<DocumentPrintOptions>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PrintSetupDialog(),
    );
    if (options == null || !context.mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => DocumentEditorPage(path: path, title: title, options: options)));
  }

  Future<void> _browse(BuildContext context, {String title = 'Document'}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, withData: false);
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;
    await _openSetup(context, path, title);
  }

  Future<void> _scan(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 100);
    if (image == null || !context.mounted) return;
    await _openSetup(context, image.path, 'Scanned Document');
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('My ID Portal Print', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF14233D))),
                SizedBox(height: 2),
                Text('By PaliaAPK HUB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF72809A))),
              ])),
              Container(width: 54, height: 54, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 10, offset: Offset(0, 3))]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: SvgPicture.asset('assets/app_icon.svg'))),
            ]),
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(colors: [Color(0xFFDDF2FF), Color(0xFFEEF7FF)])), child: const Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Scan, Crop & Print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF142D63))), SizedBox(height: 7), Text('Place your ID on A4 and adjust its position before printing.', style: TextStyle(color: Color(0xFF4D6486), height: 1.35))])), Icon(Icons.document_scanner_rounded, size: 70, color: Color(0xFF1479FF))])),
            const SizedBox(height: 18),
            Row(children: [
              _ActionCard(Icons.camera_alt_rounded, 'Scan', const Color(0xFF1479FF), () => _scan(context)),
              const SizedBox(width: 10),
              _ActionCard(Icons.photo_library_rounded, 'Gallery', const Color(0xFF12B76A), () => _browse(context, title: 'Gallery Document')),
              const SizedBox(width: 10),
              _ActionCard(Icons.picture_as_pdf_rounded, 'PDF', const Color(0xFFF04444), () => _browse(context, title: 'PDF Document')),
            ]),
            const SizedBox(height: 24),
            const Text('Popular Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
            const SizedBox(height: 12),
            GridView.count(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: .92, children: [
              _DocTile(Icons.badge_rounded, 'Aadhaar', () => _browse(context, title: 'Aadhaar')),
              _DocTile(Icons.credit_card_rounded, 'PAN', () => _browse(context, title: 'PAN')),
              _DocTile(Icons.how_to_vote_rounded, 'Voter ID', () => _browse(context, title: 'Voter ID')),
              _DocTile(Icons.directions_car_rounded, 'DL', () => _browse(context, title: 'Driving Licence')),
              _DocTile(Icons.public_rounded, 'Passport', () => _browse(context, title: 'Passport')),
              _DocTile(Icons.description_rounded, 'Ration', () => _browse(context, title: 'Ration Card')),
              _DocTile(Icons.school_rounded, 'School ID', () => _browse(context, title: 'School ID')),
              _DocTile(Icons.more_horiz_rounded, 'Other', () => _browse(context, title: 'Other Document')),
            ]),
          ],
        ),
      );
}

class DocumentPrintOptions {
  final String unit;
  final double width;
  final double height;
  final bool blackAndWhite;
  const DocumentPrintOptions({required this.unit, required this.width, required this.height, required this.blackAndWhite});

  double get widthMm => unit == 'inch' ? width * 25.4 : unit == 'cm' ? width * 10 : width;
  double get heightMm => unit == 'inch' ? height * 25.4 : unit == 'cm' ? height * 10 : height;
  double get widthPt => widthMm / 25.4 * 72;
  double get heightPt => heightMm / 25.4 * 72;
}

class _PrintSetupDialog extends StatefulWidget {
  const _PrintSetupDialog();
  @override
  State<_PrintSetupDialog> createState() => _PrintSetupDialogState();
}

class _PrintSetupDialogState extends State<_PrintSetupDialog> {
  final width = TextEditingController(text: '85.6');
  final height = TextEditingController(text: '54');
  String unit = 'mm';
  bool blackAndWhite = false;

  @override
  void dispose() {
    width.dispose();
    height.dispose();
    super.dispose();
  }

  void _continue() {
    final w = double.tryParse(width.text.trim());
    final h = double.tryParse(height.text.trim());
    if (w == null || h == null || w <= 0 || h <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid width and height.')));
      return;
    }
    Navigator.pop(context, DocumentPrintOptions(unit: unit, width: w, height: h, blackAndWhite: blackAndWhite));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Set ID Print Size', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose the physical size before placing the ID on A4.'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(value: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()), items: const [
            DropdownMenuItem(value: 'inch', child: Text('Inch (in)')),
            DropdownMenuItem(value: 'mm', child: Text('Millimeter (mm)')),
            DropdownMenuItem(value: 'cm', child: Text('Centimeter (cm)')),
          ], onChanged: (v) => setState(() => unit = v ?? 'mm')),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: TextField(controller: width, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Width', border: OutlineInputBorder()))), const SizedBox(width: 10), Expanded(child: TextField(controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height', border: OutlineInputBorder())))]),
          const SizedBox(height: 14),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: blackAndWhite, onChanged: (v) => setState(() => blackAndWhite = v), title: const Text('Black & White'), subtitle: const Text('Print the ID in grayscale'), secondary: const Icon(Icons.contrast_rounded)),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')), FilledButton.icon(onPressed: _continue, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('CONTINUE'))],
      );
}

class DocumentEditorPage extends StatefulWidget {
  final String path;
  final String title;
  final DocumentPrintOptions options;
  const DocumentEditorPage({super.key, required this.path, required this.title, required this.options});
  @override
  State<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends State<DocumentEditorPage> {
  double x = .08;
  double y = .08;
  double rotation = 0;
  late double widthPt;
  late double heightPt;
  bool busy = false;
  Size? imageSize;

  @override
  void initState() {
    super.initState();
    widthPt = widget.options.widthPt;
    heightPt = widget.options.heightPt;
    _readImageSize();
  }

  Future<void> _readImageSize() async {
    final bytes = await File(widget.path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) setState(() => imageSize = Size(frame.image.width.toDouble(), frame.image.height.toDouble()));
  }

  void _reset() => setState(() { x = .08; y = .08; rotation = 0; });

  Future<Uint8List> _processedImageBytes() async {
    final source = await File(widget.path).readAsBytes();
    if (!widget.options.blackAndWhite) return source;
    final codec = await ui.instantiateImageCodec(source);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..colorFilter = const ui.ColorFilter.matrix(<double>[
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0.299, 0.587, 0.114, 0, 0,
      0, 0, 0, 1, 0,
    ]);
    canvas.drawImage(image, ui.Offset.zero, paint);
    final picture = recorder.endRecording();
    final rendered = await picture.toImage(image.width, image.height);
    final data = await rendered.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<Uint8List> _makePdf() async {
    final bytes = await _processedImageBytes();
    final doc = pw.Document();
    final image = pw.MemoryImage(bytes);
    const pageW = 595.28;
    const pageH = 841.89;
    final width = widthPt.clamp(1.0, pageW);
    final height = heightPt.clamp(1.0, pageH);
    final left = (x * pageW).clamp(0.0, pageW - width);
    final top = (y * pageH).clamp(0.0, pageH - height);
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => pw.Stack(children: [
        pw.Positioned(
          left: left,
          top: top,
          child: pw.Container(
            width: width,
            height: height,
            child: pw.Transform.rotate(
              angle: rotation,
              child: pw.Image(image, fit: pw.BoxFit.fill),
            ),
          ),
        ),
      ]),
    ));
    return doc.save();
  }

  Future<void> _print() async {
    setState(() => busy = true);
    try { final data = await _makePdf(); await Printing.layoutPdf(onLayout: (_) async => data); }
    finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> _sharePdf() async {
    setState(() => busy = true);
    try { final data = await _makePdf(); await Printing.sharePdf(bytes: data, filename: '${widget.title.replaceAll(' ', '_')}_A4.pdf'); }
    finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.transparent, elevation: 0, actions: [IconButton(onPressed: _reset, tooltip: 'Reset position', icon: const Icon(Icons.refresh_rounded))]),
        body: Column(children: [
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            final availableW = constraints.maxWidth - 28;
            final availableH = constraints.maxHeight - 8;
            final pageW = (availableH * 210 / 297).clamp(180.0, availableW);
            final pageH = pageW * 297 / 210;
            final imageW = widthPt / 595.28 * pageW;
            final imageH = heightPt / 841.89 * pageH;
            final left = (x * pageW).clamp(0.0, pageW - imageW);
            final top = (y * pageH).clamp(0.0, pageH - imageH);
            return Center(child: Container(width: pageW, height: pageH, clipBehavior: Clip.hardEdge, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16)]), child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _A4GridPainter())),
              Positioned(left: left, top: top, width: imageW, height: imageH, child: GestureDetector(
                onPanUpdate: (d) => setState(() { x = (x + d.delta.dx / pageW).clamp(0.0, 1.0); y = (y + d.delta.dy / pageH).clamp(0.0, 1.0); }),
                onScaleUpdate: (d) => setState(() { rotation += d.rotation; if (d.scale != 1) { final factor = d.scale.clamp(.95, 1.05); widthPt = (widthPt * factor).clamp(20, 595.28); heightPt = (heightPt * factor).clamp(20, 841.89); } }),
                child: ColorFiltered(
                  colorFilter: widget.options.blackAndWhite ? const ColorFilter.matrix(<double>[0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0.299, 0.587, 0.114, 0, 0, 0, 0, 0, 1, 0]) : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                  child: Transform.rotate(angle: rotation, child: Image.file(File(widget.path), fit: BoxFit.fill)),
                ),
              )),
            ]));
          })),
          Container(padding: const EdgeInsets.fromLTRB(16, 10, 16, 14), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))), child: Column(children: [
            Row(children: [const Icon(Icons.straighten_rounded, size: 20, color: Color(0xFF1479FF)), const SizedBox(width: 8), Expanded(child: Text('${widget.options.width.toStringAsFixed(1)} ${widget.options.unit} × ${widget.options.height.toStringAsFixed(1)} ${widget.options.unit}${widget.options.blackAndWhite ? ' • B&W' : ' • Color'}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF40516D)))]),
            const SizedBox(height: 4),
            const Text('Drag to move • Pinch to resize/rotate', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF72809A))),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () async { final o = await showDialog<DocumentPrintOptions>(context: context, barrierDismissible: false, builder: (_) => _PrintSetupDialogFromCurrent(options: widget.options)); if (o != null && mounted) { setState(() { widthPt = o.widthPt; heightPt = o.heightPt; }); } }, icon: const Icon(Icons.tune_rounded), label: const Text('Size / Color'))), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: busy ? null : _print, icon: const Icon(Icons.print_rounded), label: const Text('Print A4'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: busy ? null : _sharePdf, icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('PDF')))]),
          ])),
        ]),
      );
}

class _PrintSetupDialogFromCurrent extends StatefulWidget {
  final DocumentPrintOptions options;
  const _PrintSetupDialogFromCurrent({required this.options});
  @override
  State<_PrintSetupDialogFromCurrent> createState() => _PrintSetupDialogFromCurrentState();
}

class _PrintSetupDialogFromCurrentState extends State<_PrintSetupDialogFromCurrent> {
  late final TextEditingController width;
  late final TextEditingController height;
  late String unit;
  late bool blackAndWhite;

  @override
  void initState() {
    super.initState();
    unit = widget.options.unit;
    width = TextEditingController(text: widget.options.width.toString());
    height = TextEditingController(text: widget.options.height.toString());
    blackAndWhite = widget.options.blackAndWhite;
  }

  @override
  void dispose() { width.dispose(); height.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _PrintSetupDialogBody(width: width, height: height, unit: unit, blackAndWhite: blackAndWhite, onUnitChanged: (v) => setState(() => unit = v), onBwChanged: (v) => setState(() => blackAndWhite = v), onSave: () { final w = double.tryParse(width.text); final h = double.tryParse(height.text); if (w == null || h == null || w <= 0 || h <= 0) return; Navigator.pop(context, DocumentPrintOptions(unit: unit, width: w, height: h, blackAndWhite: blackAndWhite)); });
}

class _PrintSetupDialogBody extends StatelessWidget {
  final TextEditingController width;
  final TextEditingController height;
  final String unit;
  final bool blackAndWhite;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<bool> onBwChanged;
  final VoidCallback onSave;
  const _PrintSetupDialogBody({required this.width, required this.height, required this.unit, required this.blackAndWhite, required this.onUnitChanged, required this.onBwChanged, required this.onSave});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Set ID Print Size', style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Choose the physical size before placing the ID on A4.'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(value: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'inch', child: Text('Inch (in)')), DropdownMenuItem(value: 'mm', child: Text('Millimeter (mm)')), DropdownMenuItem(value: 'cm', child: Text('Centimeter (cm)'))], onChanged: (v) { if (v != null) onUnitChanged(v); }),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: TextField(controller: width, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Width', border: OutlineInputBorder()))), const SizedBox(width: 10), Expanded(child: TextField(controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height', border: OutlineInputBorder())))]),
          const SizedBox(height: 14),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: blackAndWhite, onChanged: onBwChanged, title: const Text('Black & White'), subtitle: const Text('Print the ID in grayscale'), secondary: const Icon(Icons.contrast_rounded)),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')), FilledButton.icon(onPressed: onSave, icon: const Icon(Icons.check_rounded), label: const Text('APPLY'))],
      );
}

class _A4GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFE9EEF5)..strokeWidth = 1;
    for (double px = size.width / 3; px < size.width; px += size.width / 3) canvas.drawLine(Offset(px, 0), Offset(px, size.height), grid);
    for (double py = size.height / 3; py < size.height; py += size.height / 3) canvas.drawLine(Offset(0, py), Offset(size.width, py), grid);
    final border = Paint()..color = const Color(0xFFB7C7DA)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawRect(Offset.zero & size, border);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
