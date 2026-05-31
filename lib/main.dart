import 'dart:async';
import 'package:flutter/material.dart';

void main() { runApp(const SiLaporApp()); }

// ===== MODEL =====
class Laporan {
  int id;
  String judul, pelapor, kategori, tanggal, status, prioritas, lokasi, deskripsi;
  Laporan({required this.id, required this.judul, required this.pelapor, required this.kategori, required this.tanggal, required this.status, required this.prioritas, required this.lokasi, required this.deskripsi});
}

class UserAccount {
  String nama, username, password, nik, noHp, role;
  UserAccount({required this.nama, required this.username, required this.password, required this.nik, required this.noHp, required this.role});
}

// ===== DATABASE =====
class AppDB {
  static final List<UserAccount> users = [
    UserAccount(nama: 'Administrator', username: 'admin', password: 'admin123', nik: '0000000000000000', noHp: '', role: 'admin'),
  ];
  static UserAccount? login(String u, String p) {
    try { return users.firstWhere((x) => x.username == u && x.password == p); } catch (_) { return null; }
  }
  static bool usernameExists(String u) => users.any((x) => x.username == u);
  static void register(UserAccount a) => users.add(a);
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
  Widget build(BuildContext context) => MaterialApp(
    title: 'SiLapor',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'sans-serif', colorScheme: ColorScheme.fromSeed(seedColor: kPrimary), useMaterial3: true),
    home: const LoginPage(),
  );
}

// ===== LOGIN PAGE =====
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String errorMsg = '';

  void doLogin() {
    final u = userCtrl.text.trim();
    final p = passCtrl.text.trim();
    if (u.isEmpty || p.isEmpty) { setState(() => errorMsg = 'Username dan password wajib diisi!'); return; }
    final acc = AppDB.login(u, p);
    if (acc != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppPage(account: acc)));
    } else {
      setState(() => errorMsg = 'Username atau password salah!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPrimary, kPrimaryLight, kPrimary]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 20))]),
              child: Column(children: [
                Container(width: 64, height: 64,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]), borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('🏛️', style: TextStyle(fontSize: 28)))),
                const SizedBox(height: 12),
                const Text('SiLapor', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kPrimary)),
                const Text('Sistem Informasi Pelaporan Kecamatan', style: TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 28),
                if (errorMsg.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFfdecea), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFf5c6cb))),
                    child: Row(children: [const Text('❌ '), Expanded(child: Text(errorMsg, style: const TextStyle(color: Color(0xFFc0392b), fontSize: 13)))]),
                  ),
                _FormField(label: 'Username', controller: userCtrl, hint: 'Masukkan username'),
                const SizedBox(height: 14),
                _FormField(label: 'Password', controller: passCtrl, hint: 'Masukkan password', obscure: true),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: doLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('🔐 Masuk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  )),
                const SizedBox(height: 16),
                const Divider(color: kBorder),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Belum punya akun? ', style: TextStyle(fontSize: 13, color: kTextMuted)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DaftarPage())),
                    child: const Text('Daftar sekarang', style: TextStyle(fontSize: 13, color: kPrimaryLight, fontWeight: FontWeight.w700))),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== DAFTAR PAGE =====
class DaftarPage extends StatefulWidget {
  const DaftarPage({super.key});
  @override
  State<DaftarPage> createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final namaCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final konfirCtrl = TextEditingController();
  final nikCtrl = TextEditingController();
  final noHpCtrl = TextEditingController();
  String errorMsg = '';
  String successMsg = '';

  void doDaftar() {
    final nama = namaCtrl.text.trim();
    final user = userCtrl.text.trim();
    final pass = passCtrl.text.trim();
    final konfir = konfirCtrl.text.trim();
    final nik = nikCtrl.text.trim();
    final noHp = noHpCtrl.text.trim();
    setState(() { errorMsg = ''; successMsg = ''; });
    if (nama.isEmpty || user.isEmpty || pass.isEmpty || nik.isEmpty) { setState(() => errorMsg = 'Nama, NIK, Username, Password wajib diisi!'); return; }
    if (nik.length != 16) { setState(() => errorMsg = 'NIK harus 16 digit!'); return; }
    if (pass.length < 6) { setState(() => errorMsg = 'Password minimal 6 karakter!'); return; }
    if (pass != konfir) { setState(() => errorMsg = 'Konfirmasi password tidak cocok!'); return; }
    if (AppDB.usernameExists(user)) { setState(() => errorMsg = 'Username sudah digunakan!'); return; }
    AppDB.register(UserAccount(nama: nama, username: user, password: pass, nik: nik, noHp: noHp, role: 'user'));
    setState(() => successMsg = 'Pendaftaran berhasil! Silakan login.');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [kPrimary, kPrimaryLight, kPrimary]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 20))]),
              child: Column(children: [
                Container(width: 64, height: 64,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]), borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('📝', style: TextStyle(fontSize: 28)))),
                const SizedBox(height: 12),
                const Text('Daftar Akun', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kPrimary)),
                const Text('Buat akun SiLapor baru', style: TextStyle(fontSize: 12, color: kTextMuted)),
                const SizedBox(height: 28),
                if (errorMsg.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFfdecea), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFf5c6cb))),
                    child: Row(children: [const Text('❌ '), Expanded(child: Text(errorMsg, style: const TextStyle(color: Color(0xFFc0392b), fontSize: 13)))])),
                if (successMsg.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFe6f9f0), borderRadius: BorderRadius.circular(10), border: Border.all(color: kSuccess)),
                    child: Row(children: [const Text('✅ '), Expanded(child: Text(successMsg, style: const TextStyle(color: Color(0xFF1a7a4a), fontSize: 13)))])),
                _FormField(label: 'Nama Lengkap *', controller: namaCtrl, hint: 'Masukkan nama lengkap'),
                const SizedBox(height: 12),
                _FormField(label: 'NIK (16 digit) *', controller: nikCtrl, hint: 'Nomor Induk Kependudukan'),
                const SizedBox(height: 12),
                _FormField(label: 'No. HP', controller: noHpCtrl, hint: 'Contoh: 08123456789'),
                const SizedBox(height: 12),
                _FormField(label: 'Username *', controller: userCtrl, hint: 'Buat username unik'),
                const SizedBox(height: 12),
                _FormField(label: 'Password *', controller: passCtrl, hint: 'Min. 6 karakter', obscure: true),
                const SizedBox(height: 12),
                _FormField(label: 'Konfirmasi Password *', controller: konfirCtrl, hint: 'Ulangi password', obscure: true),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: doDaftar,
                    style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('📝 Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Sudah punya akun? ', style: TextStyle(fontSize: 13, color: kTextMuted)),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                    child: const Text('Masuk di sini', style: TextStyle(fontSize: 13, color: kPrimaryLight, fontWeight: FontWeight.w700))),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== FORM FIELD =====
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
        controller: controller, obscureText: obscure, maxLines: obscure ? 1 : maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: kTextMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimaryLight, width: 2)),
        ),
      ),
    ]);
  }
}

// ===== DROPDOWN FIELD =====
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
        value: value, items: items.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
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

// ===== APP PAGE =====
class AppPage extends StatefulWidget {
  final UserAccount account;
  const AppPage({super.key, required this.account});
  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int selectedNav = 0;
  String toastMsg = '';
  List<Laporan> laporanData = [];
  bool showContactMenu = false;

  bool get isAdmin => widget.account.role == 'admin';

  List<String> get navLabels => isAdmin
    ? ['Dashboard', 'Laporan', 'Berkas', 'Statistik', 'Pengguna', 'Pengaturan']
    : ['Dashboard', 'Laporan Saya', 'Buat Laporan', 'Profil'];

  List<String> get navIcons => isAdmin
    ? ['📊', '📋', '📁', '📈', '👥', '⚙️']
    : ['🏠', '📋', '✏️', '👤'];

  void showToast(String msg) {
    setState(() => toastMsg = msg);
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => toastMsg = ''); });
  }

  void doLogout() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    Widget page;
    if (isAdmin) {
      switch (selectedNav) {
        case 0: page = AdminDashboardPage(laporanData: laporanData, username: widget.account.nama); break;
        case 1: page = AdminLaporanPage(laporanData: laporanData, onUpdate: () => setState(() {}), showToast: showToast); break;
        case 2: page = BerkasPage(showToast: showToast); break;
        case 3: page = StatistikPage(laporanData: laporanData); break;
        case 4: page = ManajemenPenggunaPage(showToast: showToast); break;
        case 5: page = PengaturanPage(showToast: showToast); break;
        default: page = AdminDashboardPage(laporanData: laporanData, username: widget.account.nama);
      }
    } else {
      switch (selectedNav) {
        case 0: page = UserDashboardPage(laporanData: laporanData, username: widget.account.nama, myUsername: widget.account.username); break;
        case 1: page = UserLaporanPage(laporanData: laporanData, username: widget.account.username, onUpdate: () => setState(() {}), showToast: showToast); break;
        case 2: page = BuatLaporanPage(laporanData: laporanData, username: widget.account.username, onUpdate: () { setState(() {}); showToast('✅ Laporan berhasil dikirim!'); setState(() => selectedNav = 1); }); break;
        case 3: page = ProfilPage(account: widget.account, showToast: showToast); break;
        default: page = UserDashboardPage(laporanData: laporanData, username: widget.account.nama, myUsername: widget.account.username);
      }
    }

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(children: [
        isWide
          ? Row(children: [
              _Sidebar(isAdmin: isAdmin, account: widget.account, selectedNav: selectedNav, navLabels: navLabels, navIcons: navIcons, onNav: (i) => setState(() => selectedNav = i), onLogout: doLogout, laporanData: laporanData),
              Expanded(child: Column(children: [
                _Topbar(title: navLabels[selectedNav], laporanData: laporanData, isAdmin: isAdmin),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: page)),
              ])),
            ])
          : Column(children: [
              _Topbar(title: navLabels[selectedNav], laporanData: laporanData, isAdmin: isAdmin),
              Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: page)),
            ]),

        // ===== CONTACT FAB =====
        if (showContactMenu)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => showContactMenu = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
        if (showContactMenu)
          Positioned(
            bottom: 90,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ContactItem(icon: '📞', label: 'Telepon Kecamatan', sublabel: '(021) 123-4567', color: kPrimary,
                  onTap: () { setState(() => showContactMenu = false); showToast('📞 Menghubungi (021) 123-4567...'); }),
                const SizedBox(height: 10),
                _ContactItem(icon: '✉️', label: 'Email Kecamatan', sublabel: 'info@kec-contoh.go.id', color: kInfo,
                  onTap: () { setState(() => showContactMenu = false); showToast('✉️ Membuka email...'); }),
                const SizedBox(height: 10),
                _ContactItem(icon: '💬', label: 'WhatsApp', sublabel: '+62 812-3456-7890', color: const Color(0xFF25D366),
                  onTap: () { setState(() => showContactMenu = false); showToast('💬 Membuka WhatsApp...'); }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        Positioned(
          bottom: 24,
          right: 20,
          child: GestureDetector(
            onTap: () => setState(() => showContactMenu = !showContactMenu),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: showContactMenu ? [kDanger, const Color(0xFFc0392b)] : [kAccent, const Color(0xFFd4890e)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: (showContactMenu ? kDanger : kAccent).withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Center(child: Text(showContactMenu ? '✕' : '📲', style: const TextStyle(fontSize: 22))),
            ),
          ),
        ),

        if (toastMsg.isNotEmpty)
          Positioned(bottom: 90, left: 20,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(12), boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 16)]),
              child: Text(toastMsg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)))),
      ]),
      bottomNavigationBar: isWide ? null : NavigationBar(
        selectedIndex: selectedNav, onDestinationSelected: (i) => setState(() => selectedNav = i),
        backgroundColor: Colors.white, indicatorColor: kPrimary.withOpacity(0.15),
        destinations: List.generate(navLabels.length, (i) => NavigationDestination(
          icon: Text(navIcons[i], style: const TextStyle(fontSize: 20)), label: navLabels[i])),
      ),
    );
  }
}

// ===== CONTACT ITEM =====
class _ContactItem extends StatelessWidget {
  final String icon, label, sublabel;
  final Color color;
  final VoidCallback onTap;
  const _ContactItem({required this.icon, required this.label, required this.sublabel, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
          Text(sublabel, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
      const SizedBox(width: 10),
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
      ),
    ]),
  );
}

// ===== SIDEBAR =====
class _Sidebar extends StatelessWidget {
  final bool isAdmin;
  final UserAccount account;
  final int selectedNav;
  final List<String> navLabels, navIcons;
  final Function(int) onNav;
  final VoidCallback onLogout;
  final List<Laporan> laporanData;
  const _Sidebar({required this.isAdmin, required this.account, required this.selectedNav, required this.navLabels, required this.navIcons, required this.onNav, required this.onLogout, required this.laporanData});

  @override
  Widget build(BuildContext context) {
    final menunggu = laporanData.where((l) => l.status == 'Menunggu').length;
    final avatarLetter = account.nama.isNotEmpty ? account.nama[0].toUpperCase() : 'U';
    return Container(
      width: 240,
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [kPrimary, Color(0xFF0f2540)])),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('🏛️', style: TextStyle(fontSize: 18)))),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SiLapor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Kecamatan Digital', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ]),
          ])),
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: isAdmin ? kAccent : kSuccess, borderRadius: BorderRadius.circular(18)),
              child: Center(child: Text(avatarLetter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(account.nama, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              Container(margin: const EdgeInsets.only(top: 2), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: isAdmin ? kAccent.withOpacity(0.3) : kSuccess.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                child: Text(isAdmin ? '👑 Admin' : '👤 Pengguna', style: const TextStyle(color: Colors.white70, fontSize: 10))),
            ])),
          ])),
        Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
          ...List.generate(navLabels.length, (i) {
            final active = selectedNav == i;
            return GestureDetector(onTap: () => onNav(i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: active ? kAccent : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Text(navIcons[i], style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Text(navLabels[i], style: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
                  if (isAdmin && i == 1 && menunggu > 0) ...[
                    const Spacer(),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: kDanger, borderRadius: BorderRadius.circular(20)),
                      child: Text('$menunggu', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                  ],
                ]),
              ));
          }),
        ])),
        Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white12))),
          child: GestureDetector(onTap: onLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [Text('🚪', style: TextStyle(fontSize: 16)), SizedBox(width: 10), Text('Keluar', style: TextStyle(color: Colors.white70, fontSize: 13))])))),
      ]),
    );
  }
}

// ===== TOPBAR =====
class _Topbar extends StatelessWidget {
  final String title;
  final List<Laporan> laporanData;
  final bool isAdmin;
  const _Topbar({required this.title, required this.laporanData, required this.isAdmin});
  @override
  Widget build(BuildContext context) {
    final darurat = laporanData.where((l) => l.status == 'Darurat').length;
    return Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: kBorder))),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
        const Spacer(),
        if (isAdmin) Stack(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
            child: const Center(child: Text('🔔', style: TextStyle(fontSize: 16)))),
          if (darurat > 0) Positioned(top: 6, right: 6, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kDanger, shape: BoxShape.circle))),
        ]),
      ]));
  }
}

// ===== JAM & TANGGAL WIDGET =====
class _ClockWidget extends StatefulWidget {
  const _ClockWidget();
  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  String get _jam {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _tanggal {
    const hari = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    const bulan = ['','Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
    return '${hari[_now.weekday % 7]}, ${_now.day} ${bulan[_now.month]} ${_now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        const Text('🕐', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_jam, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 2)),
          const SizedBox(height: 2),
          Text(_tanggal, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: const Column(children: [
            Text('🏛️', style: TextStyle(fontSize: 18)),
            Text('SiLapor', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

// ===== ADMIN DASHBOARD =====
class AdminDashboardPage extends StatelessWidget {
  final List<Laporan> laporanData;
  final String username;
  const AdminDashboardPage({super.key, required this.laporanData, required this.username});
  @override
  Widget build(BuildContext context) {
    final total = laporanData.length;
    final menunggu = laporanData.where((l) => l.status == 'Menunggu').length;
    final selesai = laporanData.where((l) => l.status == 'Selesai').length;
    final darurat = laporanData.where((l) => l.status == 'Darurat').length;
    final totalUser = AppDB.users.where((u) => u.role == 'user').length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // JAM & TANGGAL
      const _ClockWidget(),
      const SizedBox(height: 20),
      // SAMBUTAN
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Selamat datang, $username 👑', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Text('Panel Admin — Ringkasan laporan kecamatan.', style: TextStyle(fontSize: 13, color: kTextMuted)),
        ])),
      ]),
      const SizedBox(height: 16),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2, children: [
        _StatCard(icon: '📋', iconBg: const Color(0xFFe8f0fe), value: '$total', label: 'Total Laporan'),
        _StatCard(icon: '⏳', iconBg: const Color(0xFFfef9e7), value: '$menunggu', label: 'Menunggu'),
        _StatCard(icon: '✅', iconBg: const Color(0xFFe6f9f0), value: '$selesai', label: 'Selesai'),
        _StatCard(icon: '🚨', iconBg: const Color(0xFFfdecea), value: '$darurat', label: 'Darurat'),
        _StatCard(icon: '👥', iconBg: const Color(0xFFf3e8ff), value: '$totalUser', label: 'Pengguna'),
      ]),
      const SizedBox(height: 24),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(20), child: Row(children: [Text('📋 Laporan Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))])),
          const Divider(height: 1, color: kBorder),
          laporanData.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('Belum ada laporan masuk.', style: TextStyle(color: kTextMuted)))
            : Column(children: laporanData.take(5).map((l) => _LaporanTile(l: l)).toList()),
        ]),
      ),
    ]);
  }
}

// ===== USER DASHBOARD =====
class UserDashboardPage extends StatelessWidget {
  final List<Laporan> laporanData;
  final String username, myUsername;
  const UserDashboardPage({super.key, required this.laporanData, required this.username, required this.myUsername});
  @override
  Widget build(BuildContext context) {
    final my = laporanData.where((l) => l.pelapor == myUsername).toList();
    final selesai = my.where((l) => l.status == 'Selesai').length;
    final diproses = my.where((l) => l.status == 'Diproses').length;
    final menunggu = my.where((l) => l.status == 'Menunggu').length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // JAM & TANGGAL
      const _ClockWidget(),
      const SizedBox(height: 20),
      Text('Halo, $username 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const Text('Pantau status laporan yang kamu kirimkan.', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 16),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2, children: [
        _StatCard(icon: '📋', iconBg: const Color(0xFFe8f0fe), value: '${my.length}', label: 'Laporan Saya'),
        _StatCard(icon: '⏳', iconBg: const Color(0xFFfef9e7), value: '$menunggu', label: 'Menunggu'),
        _StatCard(icon: '🔄', iconBg: const Color(0xFFe8f4fd), value: '$diproses', label: 'Diproses'),
        _StatCard(icon: '✅', iconBg: const Color(0xFFe6f9f0), value: '$selesai', label: 'Selesai'),
      ]),
      const SizedBox(height: 24),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(20), child: Row(children: [Text('📋 Laporan Terbaru Saya', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))])),
          const Divider(height: 1, color: kBorder),
          my.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('Belum ada laporan. Buat laporan pertamamu!', style: TextStyle(color: kTextMuted)))
            : Column(children: my.take(5).map((l) => _LaporanTile(l: l)).toList()),
        ]),
      ),
    ]);
  }
}

// ===== ADMIN LAPORAN =====
class AdminLaporanPage extends StatefulWidget {
  final List<Laporan> laporanData;
  final VoidCallback onUpdate;
  final Function(String) showToast;
  const AdminLaporanPage({super.key, required this.laporanData, required this.onUpdate, required this.showToast});
  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  String searchQ = '';
  String filterStatus = '';

  List<Laporan> get filtered => widget.laporanData.where((l) {
    final matchQ = l.judul.toLowerCase().contains(searchQ.toLowerCase()) || l.pelapor.toLowerCase().contains(searchQ.toLowerCase());
    final matchS = filterStatus.isEmpty || l.status == filterStatus;
    return matchQ && matchS;
  }).toList();

  void lihatDetail(Laporan l) {
    String newStatus = l.status;
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('📋 Detail Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, children: [_Badge(label: l.status), _Chip(label: l.kategori), _Chip(label: '📍 ${l.lokasi}'), _Chip(label: '📅 ${l.tanggal}')]),
        const SizedBox(height: 12),
        Text(l.judul, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('Pelapor: ${l.pelapor}', style: const TextStyle(fontSize: 12, color: kTextMuted)),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10)), child: Text(l.deskripsi, style: const TextStyle(fontSize: 13))),
        const SizedBox(height: 16),
        const Text('Ubah Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: newStatus,
          items: ['Menunggu', 'Diproses', 'Selesai', 'Darurat'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setS(() => newStatus = v!),
          decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ElevatedButton(
          onPressed: () { setState(() => l.status = newStatus); widget.onUpdate(); Navigator.pop(ctx); widget.showToast('✅ Status diperbarui!'); },
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white),
          child: const Text('💾 Simpan')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Manajemen Laporan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Kelola semua laporan masuk dari masyarakat', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: TextField(
          onChanged: (v) => setState(() => searchQ = v),
          decoration: InputDecoration(hintText: '🔍 Cari laporan...', contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder))))),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: filterStatus.isEmpty ? null : filterStatus,
          hint: const Text('Semua', style: TextStyle(fontSize: 13)),
          items: ['', 'Menunggu', 'Diproses', 'Selesai', 'Darurat'].map((s) => DropdownMenuItem(value: s, child: Text(s.isEmpty ? 'Semua' : s, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => filterStatus = v ?? '')),
      ]),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: filtered.isEmpty
          ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Tidak ada laporan.', style: TextStyle(color: kTextMuted))))
          : Column(children: filtered.map((l) => GestureDetector(onTap: () => lihatDetail(l), child: _LaporanTile(l: l))).toList())),
    ]);
  }
}

// ===== USER LAPORAN =====
class UserLaporanPage extends StatelessWidget {
  final List<Laporan> laporanData;
  final String username;
  final VoidCallback onUpdate;
  final Function(String) showToast;
  const UserLaporanPage({super.key, required this.laporanData, required this.username, required this.onUpdate, required this.showToast});
  @override
  Widget build(BuildContext context) {
    final my = laporanData.where((l) => l.pelapor == username).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Laporan Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Daftar laporan yang kamu kirimkan', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: my.isEmpty
          ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Column(children: [
              Text('📭', style: TextStyle(fontSize: 40)), SizedBox(height: 12),
              Text('Belum ada laporan.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text('Gunakan menu "Buat Laporan" untuk mulai.', style: TextStyle(fontSize: 12, color: kTextMuted)),
            ])))
          : Column(children: my.map((l) => _LaporanTile(l: l)).toList())),
    ]);
  }
}

// ===== BUAT LAPORAN =====
class BuatLaporanPage extends StatefulWidget {
  final List<Laporan> laporanData;
  final String username;
  final VoidCallback onUpdate;
  const BuatLaporanPage({super.key, required this.laporanData, required this.username, required this.onUpdate});
  @override
  State<BuatLaporanPage> createState() => _BuatLaporanPageState();
}

class _BuatLaporanPageState extends State<BuatLaporanPage> {
  final judulCtrl = TextEditingController();
  final lokasiCtrl = TextEditingController();
  final deskCtrl = TextEditingController();
  String kategori = 'Infrastruktur';
  String prioritas = 'Normal';

  void kirim() {
    if (judulCtrl.text.isEmpty || deskCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan deskripsi wajib diisi!')));
      return;
    }
    widget.laporanData.insert(0, Laporan(
      id: widget.laporanData.length + 1, judul: judulCtrl.text, pelapor: widget.username,
      kategori: kategori, tanggal: DateTime.now().toString().split(' ')[0],
      status: prioritas == 'Darurat' ? 'Darurat' : 'Menunggu',
      prioritas: prioritas, lokasi: lokasiCtrl.text, deskripsi: deskCtrl.text));
    judulCtrl.clear(); lokasiCtrl.clear(); deskCtrl.clear();
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Buat Laporan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Laporkan masalah di sekitar lingkunganmu', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FormField(label: 'Judul Laporan *', controller: judulCtrl, hint: 'Contoh: Jalan rusak di RT 03'),
          const SizedBox(height: 14),
          _DropdownField(label: 'Kategori', value: kategori, items: ['Infrastruktur', 'Kebersihan', 'Keamanan', 'Fasilitas', 'Kebencanaan', 'Lainnya'], onChanged: (v) => setState(() => kategori = v!)),
          const SizedBox(height: 14),
          _DropdownField(label: 'Prioritas', value: prioritas, items: ['Normal', 'Tinggi', 'Darurat'], onChanged: (v) => setState(() => prioritas = v!)),
          const SizedBox(height: 14),
          _FormField(label: 'Lokasi', controller: lokasiCtrl, hint: 'RT/RW, Kelurahan...'),
          const SizedBox(height: 14),
          _FormField(label: 'Deskripsi *', controller: deskCtrl, hint: 'Jelaskan detail masalah...', maxLines: 4),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: kirim,
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('📤 Kirim Laporan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)))),
        ])),
    ]);
  }
}

// ===== PROFIL =====
class ProfilPage extends StatelessWidget {
  final UserAccount account;
  final Function(String) showToast;
  const ProfilPage({super.key, required this.account, required this.showToast});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Profil Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: Column(children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(36)),
            child: Center(child: Text(account.nama[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)))),
          const SizedBox(height: 12),
          Text(account.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: kSuccess.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: const Text('👤 Pengguna', style: TextStyle(color: kSuccess, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(height: 20),
          const Divider(color: kBorder),
          const SizedBox(height: 16),
          _InfoRow(label: 'Username', value: account.username),
          _InfoRow(label: 'NIK', value: account.nik),
          _InfoRow(label: 'No. HP', value: account.noHp.isEmpty ? '-' : account.noHp),
        ])),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: kTextMuted))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
    ]));
}

// ===== MANAJEMEN PENGGUNA =====
class ManajemenPenggunaPage extends StatelessWidget {
  final Function(String) showToast;
  const ManajemenPenggunaPage({super.key, required this.showToast});
  @override
  Widget build(BuildContext context) {
    final users = AppDB.users.where((u) => u.role == 'user').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Manajemen Pengguna', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      Text('${users.length} pengguna terdaftar', style: const TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: users.isEmpty
          ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Belum ada pengguna terdaftar.', style: TextStyle(color: kTextMuted))))
          : Column(children: users.map((u) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: kBorder))),
              child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: kSuccess.withOpacity(0.15), borderRadius: BorderRadius.circular(18)),
                  child: Center(child: Text(u.nama[0].toUpperCase(), style: const TextStyle(color: kSuccess, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('@${u.username} • ${u.noHp.isEmpty ? "-" : u.noHp}', style: const TextStyle(fontSize: 11, color: kTextMuted)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Aktif', style: TextStyle(color: kSuccess, fontSize: 11, fontWeight: FontWeight.w600))),
              ]))).toList()),
      ),
    ]);
  }
}

// ===== BERKAS =====
class BerkasPage extends StatelessWidget {
  final Function(String) showToast;
  const BerkasPage({super.key, required this.showToast});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Berkas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    const Text('Dokumen dan arsip kecamatan', style: TextStyle(fontSize: 13, color: kTextMuted)),
    const SizedBox(height: 24),
    Container(padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: const Center(child: Column(children: [
        Text('📁', style: TextStyle(fontSize: 48)), SizedBox(height: 12),
        Text('Belum ada berkas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        Text('Fitur ini akan segera tersedia.', style: TextStyle(fontSize: 12, color: kTextMuted)),
      ]))),
  ]);
}

// ===== STATISTIK =====
class StatistikPage extends StatelessWidget {
  final List<Laporan> laporanData;
  const StatistikPage({super.key, required this.laporanData});
  @override
  Widget build(BuildContext context) {
    final byKategori = <String, int>{};
    for (final l in laporanData) { byKategori[l.kategori] = (byKategori[l.kategori] ?? 0) + 1; }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Statistik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Analisis data laporan kecamatan', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: laporanData.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada data laporan.', style: TextStyle(color: kTextMuted))))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📊 Laporan per Kategori', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...byKategori.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 13)), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: e.value / laporanData.length, backgroundColor: kBg, color: kPrimary, minHeight: 8)),
                ]))),
            ])),
    ]);
  }
}

// ===== PENGATURAN =====
class PengaturanPage extends StatelessWidget {
  final Function(String) showToast;
  const PengaturanPage({super.key, required this.showToast});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Pengaturan Sistem', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    const Text('Konfigurasi aplikasi pelaporan kecamatan', style: TextStyle(fontSize: 13, color: kTextMuted)),
    const SizedBox(height: 24),
    Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🏛️ Info Kecamatan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _SettingField(label: 'Nama Kecamatan', value: 'Kecamatan Contoh Jaya'),
        _SettingField(label: 'Kabupaten/Kota', value: 'Kota Contoh'),
        _SettingField(label: 'Camat', value: 'Bpk. H. Budi Santoso, S.IP'),
        _SettingField(label: 'Alamat', value: 'Jl. Raya Kecamatan No. 1'),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () => showToast('💾 Pengaturan disimpan!'),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('💾 Simpan')),
      ])),
  ]);
}

class _SettingField extends StatelessWidget {
  final String label, value;
  const _SettingField({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
      const SizedBox(height: 4),
      TextFormField(initialValue: value, style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)))),
    ]));
}

// ===== HELPERS =====
class _StatCard extends StatelessWidget {
  final String icon, value, label;
  final Color iconBg;
  const _StatCard({required this.icon, required this.iconBg, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 20)))),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText)),
        Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.w500)),
      ]),
    ]));
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
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: (colors[l.status] ?? kTextMuted).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('${icons[l.status]} ${l.status}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors[l.status] ?? kTextMuted))),
      ]));
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});
  @override
  Widget build(BuildContext context) {
    final map = {'Selesai': [const Color(0xFFe6f9f0), const Color(0xFF1a7a4a)], 'Menunggu': [const Color(0xFFfef9e7), const Color(0xFFa07700)], 'Darurat': [const Color(0xFFfdecea), const Color(0xFFc0392b)], 'Diproses': [const Color(0xFFe8f4fd), const Color(0xFF1a6fa0)]};
    final colors = map[label] ?? [kBg, kTextMuted];
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: colors[0], borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors[1])));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)));
}
