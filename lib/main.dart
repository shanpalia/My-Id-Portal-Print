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

void main() {
  runApp(const MyIdPortalPrintApp());
}

class MyIdPortalPrintApp extends StatelessWidget {
  const MyIdPortalPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  DateTime? lastBack;

  final pages = const <Widget>[
    HomePage(),
    FilesPage(),
    PrintPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  Future<void> _handleBack() async {
    if (index != 0) {
      setState(() => index = 0);
      return;
    }
    final now = DateTime.now();
    if (lastBack == null || now.difference(lastBack!) > const Duration(seconds: 2)) {
      lastBack = now;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'My Files'),
            NavigationDestination(icon: Icon(Icons.print_outlined), selectedIcon: Icon(Icons.print), label: 'Print'),
            NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openSetup(BuildContext context, String path, String title) async {
    final options = await showDialog<DocumentPrintOptions>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PrintSetupDialog(),
    );
    if (options == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentEditorPage(path: path, title: title, options: options),
      ),
    );
  }

  Future<void> _browse(BuildContext context, {String title = 'Document'}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );
    if (!context.mounted) return;
    final path = result?.files.single.path;
    if (path == null) return;
    await _openSetup(context, path, title);
  }

  Future<void> _scan(BuildContext context) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (!context.mounted || image == null) return;
    await _openSetup(context, image.path, 'Scanned Document');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My ID Portal Print', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF14233D))),
                    SizedBox(height: 2),
                    Text('By PaliaAPK HUB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF72809A))),
                  ],
                ),
              ),
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SvgPicture.asset('assets/app_icon.svg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(colors: [Color(0xFFDDF2FF), Color(0xFFEEF7FF)]),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scan, Crop & Print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF142D63))),
                      SizedBox(height: 7),
                      Text('Place your ID on A4 and adjust its position before printing.', style: TextStyle(color: Color(0xFF4D6486), height: 1.35)),
                    ],
                  ),
                ),
                Icon(Icons.document_scanner_rounded, size: 70, color: Color(0xFF1479FF)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ActionCard(icon: Icons.camera_alt_rounded, label: 'Scan', color: const Color(0xFF1479FF), onTap: () => _scan(context)),
              const SizedBox(width: 10),
              ActionCard(icon: Icons.photo_library_rounded, label: 'Gallery', color: const Color(0xFF12B76A), onTap: () => _browse(context, title: 'Gallery Document')),
              const SizedBox(width: 10),
              ActionCard(icon: Icons.picture_as_pdf_rounded, label: 'PDF', color: const Color(0xFFF04444), onTap: () => _browse(context, title: 'PDF Document')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Popular Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: .92,
            children: [
              DocTile(icon: Icons.badge_rounded, label: 'Aadhaar', onTap: () => _browse(context, title: 'Aadhaar')),
              DocTile(icon: Icons.credit_card_rounded, label: 'PAN', onTap: () => _browse(context, title: 'PAN')),
              DocTile(icon: Icons.how_to_vote_rounded, label: 'Voter ID', onTap: () => _browse(context, title: 'Voter ID')),
              DocTile(icon: Icons.directions_car_rounded, label: 'DL', onTap: () => _browse(context, title: 'Driving Licence')),
              DocTile(icon: Icons.public_rounded, label: 'Passport', onTap: () => _browse(context, title: 'Passport')),
              DocTile(icon: Icons.description_rounded, label: 'Ration', onTap: () => _browse(context, title: 'Ration Card')),
              DocTile(icon: Icons.school_rounded, label: 'School ID', onTap: () => _browse(context, title: 'School ID')),
              DocTile(icon: Icons.more_horiz_rounded, label: 'Other', onTap: () => _browse(context, title: 'Other Document')),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const ActionCard({super.key, required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          ),
        ),
      ),
    );
  }
}

class DocTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DocTile({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF1479FF), size: 30),
            const SizedBox(height: 7),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
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

class PrintSetupDialog extends StatefulWidget {
  const PrintSetupDialog({super.key});

  @override
  State<PrintSetupDialog> createState() => _PrintSetupDialogState();
}

class _PrintSetupDialogState extends State<PrintSetupDialog> {
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set ID Print Size', style: TextStyle(fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose the physical size before placing the ID on A4.'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: unit,
              decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'inch', child: Text('Inch (in)')),
                DropdownMenuItem(value: 'mm', child: Text('Millimeter (mm)')),
                DropdownMenuItem(value: 'cm', child: Text('Centimeter (cm)')),
              ],
              onChanged: (value) => setState(() => unit = value ?? 'mm'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: width, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Width', border: OutlineInputBorder()))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height', border: OutlineInputBorder()))),
            ]),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: blackAndWhite,
              onChanged: (value) => setState(() => blackAndWhite = value),
              title: const Text('Black & White'),
              subtitle: const Text('Print the ID in grayscale'),
              secondary: const Icon(Icons.contrast_rounded),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        FilledButton.icon(onPressed: _continue, icon: const Icon(Icons.arrow_forward_rounded), label: const Text('CONTINUE')),
      ],
    );
  }
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

  @override
  void initState() {
    super.initState();
    widthPt = widget.options.widthPt;
    heightPt = widget.options.heightPt;
  }

  void _reset() {
    setState(() {
      x = .08;
      y = .08;
      rotation = 0;
      widthPt = widget.options.widthPt;
      heightPt = widget.options.heightPt;
    });
  }

  Future<Uint8List> _processedImageBytes() async {
    final source = await File(widget.path).readAsBytes();
    if (!widget.options.blackAndWhite) return source;

    final codec = await ui.instantiateImageCodec(source);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()
      ..colorFilter = const ui.ColorFilter.matrix(<double>[
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
    final document = pw.Document();
    final image = pw.MemoryImage(bytes);
    const pageW = 595.28;
    const pageH = 841.89;
    final width = widthPt.clamp(1.0, pageW).toDouble();
    final height = heightPt.clamp(1.0, pageH).toDouble();
    final left = (x * pageW).clamp(0.0, pageW - width).toDouble();
    final top = (y * pageH).clamp(0.0, pageH - height).toDouble();

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Stack(
          children: [
            pw.Positioned(
              left: left,
              top: top,
              child: pw.SizedBox(
                width: width,
                height: height,
                child: pw.Transform.rotate(
                  angle: rotation,
                  child: pw.Image(image, fit: pw.BoxFit.fill),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return document.save();
  }

  Future<void> _print() async {
    setState(() => busy = true);
    try {
      final data = await _makePdf();
      await Printing.layoutPdf(onLayout: (_) async => data);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _sharePdf() async {
    setState(() => busy = true);
    try {
      final data = await _makePdf();
      await Printing.sharePdf(bytes: data, filename: '${widget.title.replaceAll(' ', '_')}_A4.pdf');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(onPressed: _reset, tooltip: 'Reset', icon: const Icon(Icons.refresh_rounded))],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableW = constraints.maxWidth - 28;
                final availableH = constraints.maxHeight - 8;
                final rawW = availableH * 210 / 297;
                final pageW = rawW.clamp(180.0, availableW).toDouble();
                final pageH = pageW * 297 / 210;
                final imageW = (widthPt / 595.28 * pageW).clamp(20.0, pageW).toDouble();
                final imageH = (heightPt / 841.89 * pageH).clamp(20.0, pageH).toDouble();
                final left = (x * pageW).clamp(0.0, pageW - imageW).toDouble();
                final top = (y * pageH).clamp(0.0, pageH - imageH).toDouble();

                return Center(
                  child: Container(
                    width: pageW,
                    height: pageH,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16)],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: CustomPaint(painter: A4GridPainter())),
                        Positioned(
                          left: left,
                          top: top,
                          width: imageW,
                          height: imageH,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                x = (x + details.delta.dx / pageW).clamp(0.0, 1.0).toDouble();
                                y = (y + details.delta.dy / pageH).clamp(0.0, 1.0).toDouble();
                              });
                            },
                            onScaleUpdate: (details) {
                              setState(() {
                                rotation += details.rotation;
                                final factor = details.scale.clamp(.95, 1.05).toDouble();
                                widthPt = (widthPt * factor).clamp(20.0, 595.28).toDouble();
                                heightPt = (heightPt * factor).clamp(20.0, 841.89).toDouble();
                              });
                            },
                            child: ColorFiltered(
                              colorFilter: widget.options.blackAndWhite
                                  ? const ColorFilter.matrix(<double>[
                                      0.299, 0.587, 0.114, 0, 0,
                                      0.299, 0.587, 0.114, 0, 0,
                                      0.299, 0.587, 0.114, 0, 0,
                                      0, 0, 0, 1, 0,
                                    ])
                                  : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                              child: Transform.rotate(angle: rotation, child: Image.file(File(widget.path), fit: BoxFit.fill)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Text('${widget.options.width.toStringAsFixed(1)} ${widget.options.unit} × ${widget.options.height.toStringAsFixed(1)} ${widget.options.unit}${widget.options.blackAndWhite ? ' • B&W' : ' • Color'}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF40516D))),
                  const SizedBox(height: 4),
                  const Text('Drag to move • Pinch to resize/rotate', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF72809A))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton.icon(onPressed: busy ? null : _reset, icon: const Icon(Icons.refresh_rounded), label: const Text('RESET'))),
                      const SizedBox(width: 8),
                      Expanded(child: FilledButton.icon(onPressed: busy ? null : _print, icon: const Icon(Icons.print_rounded), label: const Text('PRINT A4'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(onPressed: busy ? null : _sharePdf, icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('PDF'))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class A4GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFE9EEF5)..strokeWidth = 1;
    for (double px = size.width / 3; px < size.width; px += size.width / 3) {
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), grid);
    }
    for (double py = size.height / 3; py < size.height; py += size.height / 3) {
      canvas.drawLine(Offset(0, py), Offset(size.width, py), grid);
    }
  }

  @override
  bool shouldRepaint(covariant A4GridPainter oldDelegate) => false;
}

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Your selected documents will appear here.'));
  }
}

class PrintPage extends StatelessWidget {
  const PrintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Select an ID from Home to prepare an A4 print.'));
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Print history will appear here.'));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              SizedBox(width: 64, height: 64, child: SvgPicture.asset('assets/app_icon.svg')),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('My ID Portal Print', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('By PaliaAPK HUB', style: TextStyle(color: Color(0xFF72809A), fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Version 1.0.0', style: TextStyle(color: Color(0xFF72809A), fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.system_update_rounded, color: Color(0xFF1479FF)),
              title: const Text('Check for Update', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Check the latest My ID Portal Print release'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update check will use the configured release source.'))),
            ),
          ),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.print_rounded, color: Color(0xFF1479FF)),
              title: const Text('Printer Settings', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('A4 print is handled through Android print services'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
