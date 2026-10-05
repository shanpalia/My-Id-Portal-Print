import 'package:flutter/material.dart';

void main() => runApp(const MyIdPortalPrintApp());

class MyIdPortalPrintApp extends StatelessWidget {
  const MyIdPortalPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My ID Portal Print',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1479FF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.print_rounded, color: Color(0xFF1479FF), size: 30),
            SizedBox(width: 10),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'My ID Portal ', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
              TextSpan(text: 'Print', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1479FF))),
            ])),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        children: [
          const Text('All Your ID Documents in One Place', style: TextStyle(color: Color(0xFF72809A))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(colors: [Color(0xFFDDF2FF), Color(0xFFEEF7FF)]),
            ),
            child: Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Scan, Crop & Print', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF142D63))),
                SizedBox(height: 8),
                Text('Make clean A4 prints with automatic alignment.', style: TextStyle(color: Color(0xFF4D6486), height: 1.35)),
                SizedBox(height: 16),
              ])),
              const Icon(Icons.document_scanner_rounded, size: 78, color: Color(0xFF1479FF)),
            ]),
          ),
          const SizedBox(height: 18),
          Row(children: [
            _ActionCard(Icons.camera_alt_rounded, 'Scan', Color(0xFF1479FF), () {}),
            const SizedBox(width: 10),
            _ActionCard(Icons.photo_library_rounded, 'Gallery', Color(0xFF12B76A), () {}),
            const SizedBox(width: 10),
            _ActionCard(Icons.picture_as_pdf_rounded, 'PDF', Color(0xFFF04444), () {}),
          ]),
          const SizedBox(height: 24),
          const Text('Popular Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: .95,
            children: [
              _DocTile(Icons.badge_rounded, 'Aadhaar'),
              _DocTile(Icons.credit_card_rounded, 'PAN'),
              _DocTile(Icons.how_to_vote_rounded, 'Voter ID'),
              _DocTile(Icons.directions_car_rounded, 'DL'),
              _DocTile(Icons.public_rounded, 'Passport'),
              _DocTile(Icons.description_rounded, 'Ration'),
              _DocTile(Icons.school_rounded, 'School ID'),
              _DocTile(Icons.more_horiz_rounded, 'Other'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Documents', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Color(0xFF14233D))),
          const SizedBox(height: 10),
          const _RecentCard('Aadhaar_Print', 'Today, 10:25 AM', Icons.badge_rounded),
          const _RecentCard('PAN_Print', 'Today, 09:40 AM', Icons.credit_card_rounded),
        ],
      ),
      bottomNavigationBar: const NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: 'My Files'),
          NavigationDestination(icon: Icon(Icons.print_outlined), selectedIcon: Icon(Icons.print_rounded), label: 'Print'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE4EAF3))),
        child: Column(children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 9),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF253553))),
        ]),
      ),
    ),
  );
}

class _DocTile extends StatelessWidget {
  final IconData icon; final String label;
  const _DocTile(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4EAF3))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: const Color(0xFF1479FF), size: 30),
      const SizedBox(height: 8),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF33415C))),
    ]),
  );
}

class _RecentCard extends StatelessWidget {
  final String title, subtitle; final IconData icon;
  const _RecentCard(this.title, this.subtitle, this.icon);
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFE8F2FF), child: Icon(icon, color: const Color(0xFF1479FF))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.more_vert_rounded),
    ),
  );
}
