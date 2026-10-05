import 'package:flutter/material.dart';

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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1479FF),
          brightness: Brightness.light,
        ),
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
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.print_rounded, color: Color(0xFF1479FF), size: 30),
            SizedBox(width: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'My ID Portal ',
                    style: TextStyle(
                      color: Color(0xFF14233D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Print',
                    style: TextStyle(
                      color: Color(0xFF1479FF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            const Text(
              'All Your ID Documents in One Place',
              style: TextStyle(color: Color(0xFF72809A), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFFDDF2FF), Color(0xFFEEF7FF)],
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan, Crop & Print',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF142D63),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Make clean A4 prints with automatic alignment.',
                          style: TextStyle(
                            color: Color(0xFF4D6486),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.arrow_forward_rounded),
                          label: Text('Get Started'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.document_scanner_rounded,
                    size: 76,
                    color: Color(0xFF1479FF),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _ActionCard(
                  icon: Icons.camera_alt_rounded,
                  label: 'Scan Document',
                  color: const Color(0xFF1479FF),
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  icon: Icons.photo_library_rounded,
                  label: 'Choose Gallery',
                  color: const Color(0xFF12B76A),
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Open PDF',
                  color: const Color(0xFFF04444),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Popular Documents',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF14233D),
              ),
            ),
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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent Documents',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF14233D),
                    ),
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            _RecentCard(
              title: 'Aadhaar_Print',
              subtitle: 'Today, 10:25 AM',
              icon: Icons.badge_rounded,
            ),
            _RecentCard(
              title: 'PAN_Print',
              subtitle: 'Today, 09:40 AM',
              icon: Icons.credit_card_rounded,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'My Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.print_outlined),
            selectedIcon: Icon(Icons.print_rounded),
            label: 'Print',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
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

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4EAF3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF253553),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DocTile(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1479FF), size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF33415C),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _RecentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8F2FF),
          child: Icon(icon, color: const Color(0xFF1479FF)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.more_vert_rounded),
      ),
    );
  }
}
