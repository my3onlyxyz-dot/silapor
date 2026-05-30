import 'package:flutter/material.dart';

void main() {
  runApp(const SiLaporApp());
}

// ===== DATA MODEL =====
class Laporan {
  int id;
  String judul, pelapor, kategori, tanggal, status, prioritas, lokasi, deskripsi;
  Laporan({required this.id, required this.judul, required this.pelapor, required this.kategori, required this.tanggal, required this.status, required this.prioritas, required this.lokasi, required this.deskripsi});
}

// ===== WARNA =====
const kPrimary = Color(0xFF1a3a5c);
const kPrimaryLight = Color(0xFF2d5f8a);
const kAccent = Color(0xFFe8a020);
const kBg = Color(0xFFf0f4f8);
const kBorder = Color(0xFFdde3ec);
const kText = Color(0xFF1a2533);
const kTextMuted = Color(0xFF6b7c93);
const kSuccess = Color(0xFF2ecc71);
const kDanger = Color(0xFFe74c3c);
const kWarning = Color(0xFFf39c12);
const kInfo = Color(0xFF3498db);

// ===== APP =====
class SiLaporApp extends StatelessWidget {
  const SiLaporApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiLapor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ===== LOGIN PAGE =====
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String role = 'admin';
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String errorMsg = '';

  void doLogin() {
    final u = userCtrl.text.trim();
    final p = passCtrl.text.trim();
    if ((role == 'admin' && u == 'admin' && p == 'admin123') ||
        (role == 'user' && u == 'user' && p == 'user123')) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => AppPage(role: role, username: u),
      ));
    } else {
      setState(() => errorMsg = 'Username atau password salah!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimary, kPrimaryLight, kPrimary],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 20))],
              ),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('🏛️', style: TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(height: 12),
                  const Text('SiLapor', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kPrimary)),
                  const Text('Sistem Informasi Pelaporan Kecamatan', style: TextStyle(fontSize: 12, color: kTextMuted)),
                  const SizedBox(height: 28),

                  // Role tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      _RoleTab(label: '👨‍💼 Admin', active: role == 'admin', onTap: () => setState(() => role = 'admin')),
                      _RoleTab(label: '👤 Pengguna', active: role == 'user', onTap: () => setState(() => role = 'user')),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Error
                  if (errorMsg.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFfdecea), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFf5c6cb))),
                      child: Row(children: [const Text('❌ '), Text(errorMsg, style: const TextStyle(color: Color(0xFFc0392b), fontSize: 13))]),
                    ),

                  // Username
                  _FormField(label: 'Username', controller: userCtrl, hint: 'Masukkan username'),
                  const SizedBox(height: 14),
                  _FormField(label: 'Password', controller: passCtrl, hint: 'Masukkan password', obscure: true),
                  const SizedBox(height: 20),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('🔐 Masuk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Admin: admin / admin123  |  User: user / user123', style: TextStyle(fontSize: 11, color: kTextMuted), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _RoleTab({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? kPrimary : kTextMuted)),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final bool obscure;
  final int maxLines;
  const _FormField({required this.label, required this.controller, required this.hint, this.obscure = false, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kTextMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimaryLight, width: 2)),
        ),
      ),
    ]);
  }
}

// ===== APP PAGE =====
class AppPage extends StatefulWidget {
  final String role, username;
  const AppPage({super.key, required this.role, required this.username});
  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int selectedNav = 0;
  String toastMsg = '';

  List<Laporan> laporanData = [
    Laporan(id: 1, judul: 'Jalan rusak RT 03', pelapor: 'Siti Rahayu', kategori: 'Infrastruktur', tanggal: '2026-05-28', status: 'Menunggu', prioritas: 'Tinggi', lokasi: 'RT 03 Kel. Merdeka', deskripsi: 'Jalan berlubang di depan gang masuk RT 03, membahayakan pengendara motor.'),
    Laporan(id: 2, judul: 'Lampu jalan mati', pelapor: 'Ahmad Fauzi', kategori: 'Fasilitas', tanggal: '2026-05-27', status: 'Diproses', prioritas: 'Normal', lokasi: 'Jl. Mawar Kel. Sejahtera', deskripsi: 'Lampu PJU di jalan mawar sudah mati 3 hari.'),
    Laporan(id: 3, judul: 'Got tersumbat', pelapor: 'Dewi Lestari', kategori: 'Kebersihan', tanggal: '2026-05-26', status: 'Selesai', prioritas: 'Normal', lokasi: 'RT 07 Kel. Makmur', deskripsi: 'Saluran air tersumbat sampah, air meluap ke jalan.'),
    Laporan(id: 4, judul: 'Pohon tumbang', pelapor: 'user', kategori: 'Kebencanaan', tanggal: '2026-05-29', status: 'Darurat', prioritas: 'Darurat', lokasi: 'Jl. Kenanga RT 05', deskripsi: 'Pohon besar tumbang menutup jalan setelah hujan deras semalam.'),
  ];

  void showToast(String msg) {
    setState(() => toastMsg = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => toastMsg = '');
    });
  }

  void doLogout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  String get userName => widget.role == 'admin' ? 'Budi Santoso' : 'Siti Rahayu';
  String get userAvatar => widget.role == 'admin' ? 'B' : 'S';
  String get userRole => widget.role == 'admin' ? 'Administrator' : 'Pengguna';

  final List<String> navLabels = ['Dashboard', 'Laporan', 'Berkas', 'Statistik', 'Pengaturan'];
  final List<String> navIcons = ['📊', '📋', '📁', '📈', '⚙️'];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    Widget page;
    switch (selectedNav) {
      case 0: page = DashboardPage(laporanData: laporanData, role: widget.role, username: userName); break;
      case 1: page = LaporanPage(laporanData: laporanData, role: widget.role, username: widget.username, onUpdate: () => setState(() {}), showToast: showToast); break;
      case 2: page = BerkasPage(showToast: showToast); break;
      case 3: page = StatistikPage(laporanData: laporanData); break;
      case 4: page = PengaturanPage(showToast: showToast); break;
      default: page = DashboardPage(laporanData: laporanData, role: widget.role, username: userName);
    }

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        isWide
          ? Row(children: [
              _Sidebar(role: widget.role, userName: userName, userAvatar: userAvatar, userRole: userRole, selectedNav: selectedNav, navLabels: navLabels, navIcons: navIcons, onNav: (i) => setState(() => selectedNav = i), onLogout: doLogout, laporanData: laporanData),
              Expanded(child: Column(children: [
                _Topbar(title: navLabels[selectedNav], laporanData: laporanData),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: page)),
              ])),
            ])
          : Column(children: [
              _Topbar(title: navLabels[selectedNav], laporanData: laporanData),
              Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: page)),
            ]),

        // Toast
        if (toastMsg.isNotEmpty)
          Positioned(
            bottom: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12), boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 16)]),
              child: Text(toastMsg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
      ]),
      bottomNavigationBar: isWide ? null : NavigationBar(
        selectedIndex: selectedNav,
        onDestinationSelected: (i) => setState(() => selectedNav = i),
        backgroundColor: Colors.white,
        indicatorColor: kPrimary.withOpacity(0.15),
        destinations: List.generate(navLabels.length, (i) => NavigationDestination(
          icon: Text(navIcons[i], style: const TextStyle(fontSize: 20)),
          label: navLabels[i],
        )),
      ),
    );
  }
}

// ===== SIDEBAR =====
class _Sidebar extends StatelessWidget {
  final String role, userName, userAvatar, userRole;
  final int selectedNav;
  final List<String> navLabels, navIcons;
  final Function(int) onNav;
  final VoidCallback onLogout;
  final List<Laporan> laporanData;
  const _Sidebar({required this.role, required this.userName, required this.userAvatar, required this.userRole, required this.selectedNav, required this.navLabels, required this.navIcons, required this.onNav, required this.onLogout, required this.laporanData});

  @override
  Widget build(BuildContext context) {
    final menunggu = laporanData.where((l) => l.status == 'Menunggu').length;
    return Container(
      width: 240,
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kPrimary, Color(0xFF0f2540)])),
      child: Column(children: [
        // Brand
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('🏛️', style: TextStyle(fontSize: 18)))),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SiLapor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Kecamatan Digital', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ]),
        ),
        // User
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(18)), child: Center(child: Text(userAvatar, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(userName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(userRole, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ]),
        ),
        // Nav
        Expanded(
          child: ListView(padding: const EdgeInsets.all(12), children: [
            ...List.generate(navLabels.length, (i) {
              if (i == 4 && role != 'admin') return const SizedBox();
              final active = selectedNav == i;
              return GestureDetector(
                onTap: () => onNav(i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: active ? kAccent : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Text(navIcons[i], style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Text(navLabels[i], style: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
                    if (i == 1 && menunggu > 0) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: kDanger, borderRadius: BorderRadius.circular(20)),
                        child: Text('$menunggu', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                ),
              );
            }),
          ]),
        ),
        // Logout
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
          child: GestureDetector(
            onTap: onLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Text('🚪', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Text('Keluar', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ===== TOPBAR =====
class _Topbar extends StatelessWidget {
  final String title;
  final List<Laporan> laporanData;
  const _Topbar({required this.title, required this.laporanData});
  @override
  Widget build(BuildContext context) {
    final darurat = laporanData.where((l) => l.status == 'Darurat').length;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: kBorder))),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
        const Spacer(),
        Stack(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
            child: const Center(child: Text('🔔', style: TextStyle(fontSize: 16))),
          ),
          if (darurat > 0) Positioned(top: 6, right: 6, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kDanger, shape: BoxShape.circle))),
        ]),
      ]),
    );
  }
}

// ===== DASHBOARD PAGE =====
class DashboardPage extends StatelessWidget {
  final List<Laporan> laporanData;
  final String role, username;
  const DashboardPage({super.key, required this.laporanData, required this.role, required this.username});

  @override
  Widget build(BuildContext context) {
    final total = laporanData.length;
    final menunggu = laporanData.where((l) => l.status == 'Menunggu').length;
    final selesai = laporanData.where((l) => l.status == 'Selesai').length;
    final darurat = laporanData.where((l) => l.status == 'Darurat').length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Selamat datang, $username 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Berikut ringkasan laporan kecamatan hari ini.', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 24),

      // Stats
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2,
        children: [
          _StatCard(icon: '📋', iconBg: const Color(0xFFe8f0fe), value: '$total', label: 'Total Laporan'),
          _StatCard(icon: '⏳', iconBg: const Color(0xFFfef9e7), value: '$menunggu', label: 'Menunggu'),
          _StatCard(icon: '✅', iconBg: const Color(0xFFe6f9f0), value: '$selesai', label: 'Selesai'),
          _StatCard(icon: '🚨', iconBg: const Color(0xFFfdecea), value: '$darurat', label: 'Darurat'),
        ],
      ),
      const SizedBox(height: 24),

      // Laporan terbaru
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(children: [Text('📋 Laporan Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))]),
          ),
          const Divider(height: 1, color: kBorder),
          ...laporanData.take(4).map((l) => _LaporanTile(l: l)),
        ]),
      ),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String icon, value, label;
  final Color iconBg;
  const _StatCard({required this.icon, required this.iconBg, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
          Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

class _LaporanTile extends StatelessWidget {
  final Laporan l;
  const _LaporanTile({required this.l});
  @override
  Widget build(BuildContext context) {
    final colors = {'Menunggu': kWarning, 'Diproses': kInfo, 'Selesai': kSuccess, 'Darurat': kDanger};
    final icons = {'Menunggu': '⏳', 'Diproses': '🔄', 'Selesai': '✅', 'Darurat': '🚨'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBorder))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(l.pelapor, style: const TextStyle(fontSize: 11, color: kTextMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: (colors[l.status] ?? kTextMuted).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('${icons[l.status]} ${l.status}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors[l.status] ?? kTextMuted)),
        ),
      ]),
    );
  }
}

// ===== LAPORAN PAGE =====
class LaporanPage extends StatefulWidget {
  final List<Laporan> laporanData;
  final String role, username;
  final VoidCallback onUpdate;
  final Function(String) showToast;
  const LaporanPage({super.key, required this.laporanData, required this.role, required this.username, required this.onUpdate, required this.showToast});
  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String searchQ = '';
  String filterStatus = '';

  List<Laporan> get filtered {
    return widget.laporanData.where((l) {
      final matchQ = l.judul.toLowerCase().contains(searchQ.toLowerCase()) || l.pelapor.toLowerCase().contains(searchQ.toLowerCase());
      final matchS = filterStatus.isEmpty || l.status == filterStatus;
      return matchQ && matchS;
    }).toList();
  }

  void showBuatLaporan() {
    final judulCtrl = TextEditingController();
    final lokasiCtrl = TextEditingController();
    final deskCtrl = TextEditingController();
    String kategori = 'Infrastruktur';
    String prioritas = 'Normal';

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('📋 Buat Laporan Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _FormField(label: 'Judul Laporan *', controller: judulCtrl, hint: 'Masukkan judul laporan'),
        const SizedBox(height: 12),
        _DropdownField(label: 'Kategori', value: kategori, items: ['Infrastruktur', 'Kebersihan', 'Keamanan', 'Fasilitas', 'Kebencanaan', 'Lainnya'], onChanged: (v) => setS(() => kategori = v!)),
        const SizedBox(height: 12),
        _DropdownField(label: 'Prioritas', value: prioritas, items: ['Normal', 'Tinggi', 'Darurat'], onChanged: (v) => setS(() => prioritas = v!)),
        const SizedBox(height: 12),
        _FormField(label: 'Lokasi', controller: lokasiCtrl, hint: 'RT/RW, Kelurahan...'),
        const SizedBox(height: 12),
        _FormField(label: 'Deskripsi *', controller: deskCtrl, hint: 'Jelaskan detail laporan...', maxLines: 4),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (judulCtrl.text.isEmpty) { widget.showToast('⚠️ Judul wajib diisi!'); return; }
            setState(() {
              widget.laporanData.insert(0, Laporan(
                id: widget.laporanData.length + 1,
                judul: judulCtrl.text, pelapor: widget.username,
                kategori: kategori, tanggal: DateTime.now().toString().split(' ')[0],
                status: prioritas == 'Darurat' ? 'Darurat' : 'Menunggu',
                prioritas: prioritas, lokasi: lokasiCtrl.text, deskripsi: deskCtrl.text,
              ));
            });
            widget.onUpdate();
            Navigator.pop(ctx);
            widget.showToast('✅ Laporan berhasil dikirim!');
          },
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white),
          child: const Text('📤 Kirim'),
        ),
      ],
    )));
  }

  void lihatDetail(Laporan l) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('📋 Detail Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, children: [
          _Badge(label: l.status), _Chip(label: l.kategori), _Chip(label: '📍 ${l.lokasi}'), _Chip(label: '📅 ${l.tanggal}'),
        ]),
        const SizedBox(height: 12),
        Text(l.judul, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('Dilaporkan oleh: ${l.pelapor}', style: const TextStyle(fontSize: 12, color: kTextMuted)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)), child: Text(l.deskripsi, style: const TextStyle(fontSize: 13))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        if (widget.role == 'admin')
          ElevatedButton(
            onPressed: () { setState(() { l.status = l.status == 'Selesai' ? 'Menunggu' : 'Selesai'; }); widget.onUpdate(); Navigator.pop(context); widget.showToast('Status diperbarui!'); },
            style: ElevatedButton.styleFrom(backgroundColor: kSuccess, foregroundColor: Colors.white),
            child: const Text('✅ Tandai Selesai'),
          ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Manajemen Laporan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('Daftar laporan masuk dari masyarakat', style: TextStyle(fontSize: 13, color: kTextMuted)),
        ])),
        ElevatedButton(
          onPressed: showBuatLaporan,
          style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('+ Laporan'),
        ),
      ]),
      const SizedBox(height: 16),

      // Search & Filter
      Row(children: [
        Expanded(
          child: TextField(
            onChanged: (v) => setState(() => searchQ = v),
            decoration: InputDecoration(
              hintText: '🔍 Cari laporan...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: filterStatus.isEmpty ? null : filterStatus,
          hint: const Text('Semua', style: TextStyle(fontSize: 13)),
          items: ['', 'Menunggu', 'Diproses', 'Selesai', 'Darurat'].map((s) => DropdownMenuItem(value: s, child: Text(s.isEmpty ? 'Semua' : s, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => filterStatus = v ?? ''),
        ),
      ]),
      const SizedBox(height: 16),

      // List
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(children: filtered.isEmpty
          ? [const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Tidak ada laporan', style: TextStyle(color: kTextMuted))))]
          : filtered.map((l) => _LaporanRow(l: l, role: widget.role, onDetail: () => lihatDetail(l), onUbah: () { setState(() { l.status = l.status == 'Selesai' ? 'Menunggu' : 'Selesai'; }); widget.showToast('Status diperbarui!'); }, onHapus: () { setState(() => widget.laporanData.remove(l)); widget.showToast('🗑️ Laporan dihapus!'); })).toList(),
        ),
      ),
    ]);
  }
}

class _LaporanRow extends StatelessWidget {
  final Laporan l;
  final String role;
  final VoidCallback onDetail, onUbah, onHapus;
  const _LaporanRow({required this.l, required this.role, required this.onDetail, required this.onUbah, required this.onHapus});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBorder))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(l.judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          _Badge(label: l.status),
        ]),
        const SizedBox(height: 4),
        Text('${l.pelapor} • ${l.kategori} • ${l.tanggal}', style: const TextStyle(fontSize: 11, color: kTextMuted)),
        const SizedBox(height: 8),
        Row(children: [
          OutlinedButton(onPressed: onDetail, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11)), child: const Text('👁 Detail')),
          if (role == 'admin') ...[
            const SizedBox(width: 6),
            ElevatedButton(onPressed: onUbah, style: ElevatedButton.styleFrom(backgroundColor: kSuccess, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11)), child: const Text('✅')),
            const SizedBox(width: 6),
            ElevatedButton(onPressed: onHapus, style: ElevatedButton.styleFrom(backgroundColor: kDanger, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11)), child: const Text('🗑')),
          ],
        ]),
      ]),
    );
  }
}

// ===== BERKAS PAGE =====
class BerkasPage extends StatelessWidget {
  final Function(String) showToast;
  const BerkasPage({super.key, required this.showToast});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Berkas & File', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Kelola dokumen dan berkas kecamatan', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(children: [
          const Text('📁', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Upload Berkas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Ketuk tombol di bawah untuk upload file', style: TextStyle(fontSize: 13, color: kTextMuted)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => showToast('⬆️ Fitur upload akan segera hadir!'),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('📎 Pilih File'),
          ),
        ]),
      ),
    ]);
  }
}

// ===== STATISTIK PAGE =====
class StatistikPage extends StatelessWidget {
  final List<Laporan> laporanData;
  const StatistikPage({super.key, required this.laporanData});
  @override
  Widget build(BuildContext context) {
    final byKategori = <String, int>{};
    for (final l in laporanData) { byKategori[l.kategori] = (byKategori[l.kategori] ?? 0) + 1; }
    final byBulan = {'Jan': 15, 'Feb': 11, 'Mar': 18, 'Apr': 14, 'Mei': 24};

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Statistik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Analisis data laporan kecamatan', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📊 Laporan per Kategori', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...byKategori.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 13)), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]),
              const SizedBox(height: 4),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: e.value / laporanData.length, backgroundColor: kBg, color: kPrimary, minHeight: 8)),
            ]),
          )),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📅 Laporan per Bulan (2026)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...byBulan.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 40, child: Text(e.key, style: const TextStyle(fontSize: 13))),
              const SizedBox(width: 8),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: e.value / 30, backgroundColor: kBg, color: kAccent, minHeight: 14))),
              const SizedBox(width: 8),
              Text('${e.value}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          )),
        ]),
      ),
    ]);
  }
}

// ===== PENGATURAN PAGE =====
class PengaturanPage extends StatelessWidget {
  final Function(String) showToast;
  const PengaturanPage({super.key, required this.showToast});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pengaturan Sistem', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Konfigurasi aplikasi pelaporan kecamatan', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🏛️ Info Kecamatan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _SettingField(label: 'Nama Kecamatan', value: 'Kecamatan Contoh Jaya'),
          _SettingField(label: 'Kabupaten/Kota', value: 'Kota Contoh'),
          _SettingField(label: 'Camat', value: 'Bpk. H. Budi Santoso, S.IP'),
          _SettingField(label: 'Alamat', value: 'Jl. Raya Kecamatan No. 1'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => showToast('💾 Pengaturan disimpan!'),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('💾 Simpan'),
          ),
        ]),
      ),
    ]);
  }
}

class _SettingField extends StatelessWidget {
  final String label, value;
  const _SettingField({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
          ),
        ),
      ]),
    );
  }
}

// ===== HELPERS =====
class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    final map = {
      'Selesai': [const Color(0xFFe6f9f0), const Color(0xFF1a7a4a)],
      'Menunggu': [const Color(0xFFfef9e7), const Color(0xFFa07700)],
      'Darurat': [const Color(0xFFfdecea), const Color(0xFFc0392b)],
      'Diproses': [const Color(0xFFe8f4fd), const Color(0xFF1a6fa0)],
    };
    final colors = map[label] ?? [kBg, kTextMuted];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors[0], borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors[1])),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final Function(String?) onChanged;
  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
        ),
      ),
    ]);
  }
}
