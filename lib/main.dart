import 'dart:async';
import 'package:flutter/material.dart';

// ===== THEME NOTIFIER =====
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

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
  static final List<UserAccount> _users = [
    UserAccount(nama: 'Administrator', username: 'admin', password: 'admin123', nik: '0000000000000000', noHp: '', role: 'admin'),
  ];
  static final List<Laporan> _laporan = [];

  // ValueNotifiers — semua widget yang listen akan rebuild otomatis
  static final laporanNotifier = ValueNotifier<int>(0);
  static final userNotifier    = ValueNotifier<int>(0);

  static List<UserAccount> get users  => _users;
  static List<Laporan>     get laporan => _laporan;

  // Mutasi laporan
  static void addLaporan(Laporan l) {
    _laporan.insert(0, l);
    laporanNotifier.value++;
  }
  static void updateLaporan() => laporanNotifier.value++;

  // Mutasi user
  static UserAccount? login(String u, String p) {
    try { return _users.firstWhere((x) => x.username == u && x.password == p); } catch (_) { return null; }
  }
  static bool usernameExists(String u) => _users.any((x) => x.username == u);
  static void register(UserAccount a) { _users.add(a); userNotifier.value++; }
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
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: themeNotifier,
    builder: (_, mode, __) => MaterialApp(
      title: 'SiLapor',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
      ),
      darkTheme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.dark),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0f1923),
      ),
      home: const LoginPage(),
    ),
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
  bool showContactMenu = false;

  bool get isAdmin => widget.account.role == 'admin';
  List<Laporan> get laporanData => AppDB.laporan;

  List<String> get navLabels => isAdmin
    ? ['Dashboard', 'Laporan', 'Berkas', 'Statistik', 'Pengguna', 'Pengaturan']
    : ['Dashboard', 'Laporan Saya', 'Buat Laporan', 'Statistik', 'Pengaturan'];

  List<String> get navIcons => isAdmin
    ? ['📊', '📋', '📁', '📈', '👥', '⚙️']
    : ['📊', '📋', '✏️', '📈', '⚙️'];

  void showToast(String msg) {
    setState(() => toastMsg = msg);
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => toastMsg = ''); });
  }

  void doLogout() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppDB.laporanNotifier,
      builder: (context, _lVal, __) => ValueListenableBuilder<int>(
        valueListenable: AppDB.userNotifier,
        builder: (context, _uVal, __) => _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    Widget page;
    if (isAdmin) {
      switch (selectedNav) {
        case 0: page = AdminDashboardPage(username: widget.account.nama); break;
        case 1: page = AdminLaporanPage(showToast: showToast); break;
        case 2: page = BerkasPage(showToast: showToast); break;
        case 3: page = StatistikPage(); break;
        case 4: page = ManajemenPenggunaPage(showToast: showToast); break;
        case 5: page = PengaturanPage(showToast: showToast, onLogout: doLogout); break;
        default: page = AdminDashboardPage(username: widget.account.nama);
      }
    } else {
      switch (selectedNav) {
        case 0: page = UserDashboardPage(username: widget.account.nama, myUsername: widget.account.username); break;
        case 1: page = UserLaporanPage(username: widget.account.username, showToast: showToast); break;
        case 2: page = BuatLaporanPage(username: widget.account.username, onUpdate: () { showToast('✅ Laporan berhasil dikirim!'); setState(() => selectedNav = 1); }); break;
        case 3: page = UserStatistikPage(username: widget.account.username); break;
        case 4: page = UserPengaturanPage(account: widget.account, showToast: showToast, onLogout: doLogout); break;
        default: page = UserDashboardPage(username: widget.account.nama, myUsername: widget.account.username);
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(children: [
        isWide
          ? Row(children: [
              _Sidebar(isAdmin: isAdmin, account: widget.account, selectedNav: selectedNav, navLabels: navLabels, navIcons: navIcons, onNav: (i) => setState(() => selectedNav = i), onLogout: doLogout),
              Expanded(child: Column(children: [
                _Topbar(title: navLabels[selectedNav], isAdmin: isAdmin),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: page)),
              ])),
            ])
          : Column(children: [
              _Topbar(title: navLabels[selectedNav], isAdmin: isAdmin),
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
      bottomNavigationBar: isWide ? null : ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, mode, __) {
          final isDark = mode == ThemeMode.dark;
          final navBg = isDark ? const Color(0xFF1a2535) : Colors.white;
          final navBorder = isDark ? const Color(0xFF2a3a50) : kBorder;
          return Container(
            decoration: BoxDecoration(color: navBg, border: Border(top: BorderSide(color: navBorder))),
            child: NavigationBar(
              selectedIndex: selectedNav,
              onDestinationSelected: (i) => setState(() => selectedNav = i),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              indicatorColor: kPrimary.withOpacity(isDark ? 0.25 : 0.12),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: List.generate(navLabels.length, (i) => NavigationDestination(
                icon: Text(navIcons[i], style: TextStyle(fontSize: 20, color: isDark ? const Color(0xFF8a9bb0) : kTextMuted)),
                selectedIcon: Text(navIcons[i], style: const TextStyle(fontSize: 20)),
                label: navLabels[i],
              )),
            ),
          );
        },
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
  const _Sidebar({required this.isAdmin, required this.account, required this.selectedNav, required this.navLabels, required this.navIcons, required this.onNav, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final menunggu = AppDB.laporan.where((l) => l.status == 'Menunggu').length;
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
  final bool isAdmin;
  const _Topbar({required this.title, required this.isAdmin});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darurat = AppDB.laporan.where((l) => l.status == 'Darurat').length;
    final bg = isDark ? const Color(0xFF1a2535) : Colors.white;
    final border = isDark ? const Color(0xFF2a3a50) : kBorder;
    final textC = isDark ? Colors.white : kText;
    final iconBg = isDark ? const Color(0xFF243044) : kBg;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: bg, border: Border(bottom: BorderSide(color: border))),
      child: Row(children: [
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textC)),
        const Spacer(),
        // DARK MODE QUICK TOGGLE
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (_, mode, __) {
            final dark = mode == ThemeMode.dark;
            return GestureDetector(
              onTap: () => themeNotifier.value = dark ? ThemeMode.light : ThemeMode.dark,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38, height: 38, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
                child: Center(child: Text(dark ? '☀️' : '🌙', style: const TextStyle(fontSize: 16))),
              ),
            );
          },
        ),
        if (isAdmin) Stack(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
            child: const Center(child: Text('🔔', style: TextStyle(fontSize: 16)))),
          if (darurat > 0) Positioned(top: 6, right: 6,
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: kDanger, shape: BoxShape.circle))),
        ]),
      ]),
    );
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
  final String username;
  const AdminDashboardPage({super.key, required this.username});

  void _showUserDetail(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final itemBg = isDark ? const Color(0xFF243044) : kBg;
    final users = AppDB.users.where((u) => u.role == 'user').toList();
    const color = Color(0xFF7c3aed);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55, minChildSize: 0.3, maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('👥', style: TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Daftar Pengguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('${users.length} pengguna terdaftar', style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text('${users.length}', style: const TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15))),
              ]),
            ),
            const Divider(height: 1),
            Expanded(child: users.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('👤', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text('Belum ada pengguna terdaftar', style: TextStyle(color: kTextMuted, fontSize: 13)),
                ]))
              : ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    final initial = u.nama.isNotEmpty ? u.nama[0].toUpperCase() : 'U';
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: itemBg, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.15))),
                      child: Row(children: [
                        Container(width: 40, height: 40,
                          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(initial, style: const TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(u.nama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('@${u.username} · ${u.noHp.isEmpty ? "No HP -" : u.noHp}',
                            style: const TextStyle(fontSize: 11, color: kTextMuted)),
                        ])),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: kSuccess.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Aktif', style: TextStyle(color: kSuccess, fontSize: 10, fontWeight: FontWeight.w700))),
                      ]),
                    );
                  }),
            ),
          ]),
        ),
      ),
    );
  }

  void _showStatDetail(BuildContext context, String label, String icon, Color color, List<Laporan> filtered) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('${filtered.length} laporan', style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text('${filtered.length}', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15))),
              ]),
            ),
            const Divider(height: 1),
            Expanded(child: filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('📭', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('Tidak ada data untuk "$label"', style: const TextStyle(color: kTextMuted, fontSize: 13)),
                ]))
              : ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final l = filtered[i];
                    final statusColors = {'Menunggu': kWarning, 'Diproses': kInfo, 'Selesai': kSuccess, 'Darurat': kDanger};
                    final statusIcons = {'Menunggu': '⏳', 'Diproses': '🔄', 'Selesai': '✅', 'Darurat': '🚨'};
                    final sc = statusColors[l.status] ?? kTextMuted;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF243044) : kBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: sc.withOpacity(0.2)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(l.judul, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('${statusIcons[l.status]} ${l.status}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc))),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          Text('👤 ${l.pelapor}', style: const TextStyle(fontSize: 11, color: kTextMuted)),
                          const SizedBox(width: 10),
                          Text('📍 ${l.lokasi}', style: const TextStyle(fontSize: 11, color: kTextMuted)),
                          const Spacer(),
                          Text('📅 ${l.tanggal}', style: const TextStyle(fontSize: 10, color: kTextMuted)),
                        ]),
                      ]),
                    );
                  }),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final border = isDark ? const Color(0xFF2a3a50) : kBorder;
    final mutedC = isDark ? const Color(0xFF8a9bb0) : kTextMuted;

    final total = AppDB.laporan.length;
    final menunggu = AppDB.laporan.where((l) => l.status == 'Menunggu').toList();
    final selesai = AppDB.laporan.where((l) => l.status == 'Selesai').toList();
    final darurat = AppDB.laporan.where((l) => l.status == 'Darurat').toList();
    final diproses = AppDB.laporan.where((l) => l.status == 'Diproses').toList();
    final totalUser = AppDB.users.where((u) => u.role == 'user').length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // CLOCK
      const _ClockWidget(),
      const SizedBox(height: 18),

      // GREETING ROW
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(width: 46, height: 46,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [kAccent, Color(0xFFd4890e)]), borderRadius: BorderRadius.circular(13)),
            child: const Center(child: Text('👑', style: TextStyle(fontSize: 22)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Selamat datang, $username', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            Text('Panel Admin · ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: TextStyle(fontSize: 11, color: mutedC)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: kSuccess.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: const Text('● Online', style: TextStyle(color: kSuccess, fontSize: 11, fontWeight: FontWeight.w700))),
        ]),
      ),
      const SizedBox(height: 16),

      // STAT CARDS — 2x2 grid + 1 full width
      Row(children: [
        Expanded(child: _TappableStatCard(
          icon: '📋', iconBg: const Color(0xFFe8f0fe), iconColor: kInfo,
          value: '$total', label: 'Total Laporan', sublabel: 'Semua laporan',
          onTap: () => _showStatDetail(context, 'Total Laporan', '📋', kInfo, laporanData),
        )),
        const SizedBox(width: 10),
        Expanded(child: _TappableStatCard(
          icon: '⏳', iconBg: const Color(0xFFfef9e7), iconColor: kWarning,
          value: '${menunggu.length}', label: 'Menunggu', sublabel: 'Perlu ditangani',
          onTap: () => _showStatDetail(context, 'Menunggu', '⏳', kWarning, menunggu),
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _TappableStatCard(
          icon: '🔄', iconBg: const Color(0xFFe8f4fd), iconColor: kPrimaryLight,
          value: '${diproses.length}', label: 'Diproses', sublabel: 'Sedang ditangani',
          onTap: () => _showStatDetail(context, 'Diproses', '🔄', kPrimaryLight, diproses),
        )),
        const SizedBox(width: 10),
        Expanded(child: _TappableStatCard(
          icon: '✅', iconBg: const Color(0xFFe6f9f0), iconColor: kSuccess,
          value: '${selesai.length}', label: 'Selesai', sublabel: 'Berhasil diselesaikan',
          onTap: () => _showStatDetail(context, 'Selesai', '✅', kSuccess, selesai),
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _TappableStatCard(
          icon: '🚨', iconBg: const Color(0xFFfdecea), iconColor: kDanger,
          value: '${darurat.length}', label: 'Darurat', sublabel: 'Prioritas tinggi',
          onTap: () => _showStatDetail(context, 'Darurat', '🚨', kDanger, darurat),
        )),
        const SizedBox(width: 10),
        Expanded(child: _TappableStatCard(
          icon: '👥', iconBg: const Color(0xFFf3e8ff), iconColor: const Color(0xFF7c3aed),
          value: '$totalUser', label: 'Pengguna', sublabel: 'Terdaftar',
          onTap: () => _showUserDetail(context),
        )),
      ]),
      const SizedBox(height: 20),

      // QUICK ACTIONS
      Text('⚡ Aksi Cepat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: mutedC)),
      const SizedBox(height: 10),
      Row(children: [
        _QuickAction(icon: '📋', label: 'Semua\nLaporan', color: kInfo),
        const SizedBox(width: 8),
        _QuickAction(icon: '🚨', label: 'Laporan\nDarurat', color: kDanger),
        const SizedBox(width: 8),
        _QuickAction(icon: '👥', label: 'Pengguna', color: const Color(0xFF7c3aed)),
        const SizedBox(width: 8),
        _QuickAction(icon: '📈', label: 'Statistik', color: kSuccess),
      ]),
      const SizedBox(height: 20),

      // LAPORAN TERBARU
      Container(
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(children: [
              const Text('📋', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text('Laporan Terbaru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (AppDB.laporan.isNotEmpty)
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                  child: Text('${AppDB.laporan.length} total', style: const TextStyle(color: kPrimary, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
          ),
          Divider(height: 1, color: border),
          AppDB.laporan.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('📭', style: TextStyle(fontSize: 30)))),
                  const SizedBox(height: 14),
                  const Text('Belum ada laporan masuk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Laporan dari masyarakat akan muncul di sini', style: TextStyle(fontSize: 12, color: mutedC)),
                ]),
              )
            : Column(children: AppDB.laporan.take(5).map((l) => _LaporanTile(l: l)).toList()),
        ]),
      ),
      const SizedBox(height: 8),
    ]);
  }
}

// ===== USER DASHBOARD =====
class UserDashboardPage extends StatelessWidget {
  final String username, myUsername;
  const UserDashboardPage({super.key, required this.username, required this.myUsername});

  void _showStatDetail(BuildContext context, String label, String icon, Color color, List<Laporan> filtered) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55, minChildSize: 0.3, maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text('${filtered.length} laporan saya', style: const TextStyle(fontSize: 12, color: kTextMuted)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text('${filtered.length}', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15))),
              ]),
            ),
            const Divider(height: 1),
            Expanded(child: filtered.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('📭', style: TextStyle(fontSize: 40)), const SizedBox(height: 12),
                  Text('Tidak ada laporan "$label"', style: const TextStyle(color: kTextMuted, fontSize: 13)),
                ]))
              : ListView.separated(
                  controller: ctrl, padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final l = filtered[i];
                    final sc = {'Menunggu': kWarning, 'Diproses': kInfo, 'Selesai': kSuccess, 'Darurat': kDanger}[l.status] ?? kTextMuted;
                    final si = {'Menunggu': '⏳', 'Diproses': '🔄', 'Selesai': '✅', 'Darurat': '🚨'}[l.status] ?? '';
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF243044) : kBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: sc.withOpacity(0.2))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(l.judul, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('$si ${l.status}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc))),
                        ]),
                        const SizedBox(height: 6),
                        Text('📍 ${l.lokasi} · 📅 ${l.tanggal}', style: const TextStyle(fontSize: 11, color: kTextMuted)),
                      ]),
                    );
                  }),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final border = isDark ? const Color(0xFF2a3a50) : kBorder;
    final mutedC = isDark ? const Color(0xFF8a9bb0) : kTextMuted;

    final my = AppDB.laporan.where((l) => l.pelapor == myUsername).toList();
    final selesai = my.where((l) => l.status == 'Selesai').toList();
    final diproses = my.where((l) => l.status == 'Diproses').toList();
    final menunggu = my.where((l) => l.status == 'Menunggu').toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _ClockWidget(),
      const SizedBox(height: 18),

      // GREETING
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(children: [
          Container(width: 46, height: 46,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]), borderRadius: BorderRadius.circular(13)),
            child: Center(child: Text(username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Halo, $username 👋', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            Text('${my.length} laporan dikirim', style: TextStyle(fontSize: 11, color: mutedC)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: kSuccess.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: const Text('● Aktif', style: TextStyle(color: kSuccess, fontSize: 11, fontWeight: FontWeight.w700))),
        ]),
      ),
      const SizedBox(height: 16),

      // STAT CARDS
      Row(children: [
        Expanded(child: _TappableStatCard(
          icon: '📋', iconBg: const Color(0xFFe8f0fe), iconColor: kInfo,
          value: '${my.length}', label: 'Laporan Saya', sublabel: 'Total dikirim',
          onTap: () => _showStatDetail(context, 'Semua Laporan', '📋', kInfo, my),
        )),
        const SizedBox(width: 10),
        Expanded(child: _TappableStatCard(
          icon: '⏳', iconBg: const Color(0xFFfef9e7), iconColor: kWarning,
          value: '${menunggu.length}', label: 'Menunggu', sublabel: 'Belum ditangani',
          onTap: () => _showStatDetail(context, 'Menunggu', '⏳', kWarning, menunggu),
        )),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _TappableStatCard(
          icon: '🔄', iconBg: const Color(0xFFe8f4fd), iconColor: kPrimaryLight,
          value: '${diproses.length}', label: 'Diproses', sublabel: 'Sedang ditangani',
          onTap: () => _showStatDetail(context, 'Diproses', '🔄', kPrimaryLight, diproses),
        )),
        const SizedBox(width: 10),
        Expanded(child: _TappableStatCard(
          icon: '✅', iconBg: const Color(0xFFe6f9f0), iconColor: kSuccess,
          value: '${selesai.length}', label: 'Selesai', sublabel: 'Berhasil diselesaikan',
          onTap: () => _showStatDetail(context, 'Selesai', '✅', kSuccess, selesai),
        )),
      ]),
      const SizedBox(height: 20),

      // LAPORAN TERBARU
      Container(
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(children: [
              const Text('📋', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text('Laporan Terbaru Saya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (my.isNotEmpty)
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                  child: Text('${my.length} total', style: const TextStyle(color: kPrimary, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
          ),
          Divider(height: 1, color: border),
          my.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: Text('✏️', style: TextStyle(fontSize: 30)))),
                  const SizedBox(height: 14),
                  const Text('Belum ada laporan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Gunakan "Buat Laporan" untuk mulai melapor', style: TextStyle(fontSize: 12, color: mutedC)),
                ]),
              )
            : Column(children: my.take(5).map((l) => _LaporanTile(l: l)).toList()),
        ]),
      ),
      const SizedBox(height: 8),
    ]);
  }
}

// ===== ADMIN LAPORAN =====
class AdminLaporanPage extends StatefulWidget {
  final Function(String) showToast;
  const AdminLaporanPage({super.key, required this.showToast});
  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  String searchQ = '';
  String filterStatus = '';

  List<Laporan> get filtered => AppDB.laporan.where((l) {
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
          onPressed: () {
            l.status = newStatus;
            AppDB.updateLaporan(); // trigger semua listener rebuild
            setState(() {});
            Navigator.pop(ctx);
            widget.showToast('✅ Status diperbarui!');
          },
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
class UserLaporanPage extends StatefulWidget {
  final String username;
  final Function(String) showToast;
  const UserLaporanPage({super.key, required this.username, required this.showToast});
  @override
  State<UserLaporanPage> createState() => _UserLaporanPageState();
}

class _UserLaporanPageState extends State<UserLaporanPage> {
  String searchQ = '';
  String filterStatus = '';

  void lihatDetail(Laporan l) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final statusColors = {'Menunggu': kWarning, 'Diproses': kInfo, 'Selesai': kSuccess, 'Darurat': kDanger};
    final sc = statusColors[l.status] ?? kTextMuted;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.92,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: ListView(controller: ctrl, padding: const EdgeInsets.all(20), children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            Row(children: [
              Expanded(child: Text(l.judul, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: sc.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(l.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sc))),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _DetailRow(icon: '📋', label: 'Kategori', value: l.kategori),
            _DetailRow(icon: '⚡', label: 'Prioritas', value: l.prioritas),
            _DetailRow(icon: '📍', label: 'Lokasi', value: l.lokasi.isEmpty ? '-' : l.lokasi),
            _DetailRow(icon: '📅', label: 'Tanggal', value: l.tanggal),
            const SizedBox(height: 12),
            const Text('📝 Deskripsi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF243044) : kBg, borderRadius: BorderRadius.circular(12)),
              child: Text(l.deskripsi, style: const TextStyle(fontSize: 13))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final borderC = isDark ? const Color(0xFF2a3a50) : kBorder;
    final my = AppDB.laporan.where((l) => l.pelapor == widget.username).toList();
    final filtered = my.where((l) {
      final q = searchQ.toLowerCase();
      return (q.isEmpty || l.judul.toLowerCase().contains(q) || l.lokasi.toLowerCase().contains(q))
          && (filterStatus.isEmpty || l.status == filterStatus);
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Laporan Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      Text('${my.length} laporan yang kamu kirimkan', style: const TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: TextField(
          onChanged: (v) => setState(() => searchQ = v),
          decoration: InputDecoration(hintText: '🔍 Cari laporan...', contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderC)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderC))))),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: filterStatus.isEmpty ? null : filterStatus,
          hint: const Text('Semua', style: TextStyle(fontSize: 13)),
          items: ['', 'Menunggu', 'Diproses', 'Selesai', 'Darurat'].map((s) => DropdownMenuItem(value: s, child: Text(s.isEmpty ? 'Semua' : s, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (v) => setState(() => filterStatus = v ?? '')),
      ]),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderC)),
        child: filtered.isEmpty
          ? Padding(padding: const EdgeInsets.all(32), child: Center(child: Column(children: [
              const Text('📭', style: TextStyle(fontSize: 40)), const SizedBox(height: 12),
              Text(my.isEmpty ? 'Belum ada laporan.' : 'Tidak ada laporan yang cocok.', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const Text('Gunakan menu "Buat Laporan" untuk mulai.', style: TextStyle(fontSize: 12, color: kTextMuted)),
            ])))
          : Column(children: filtered.map((l) => GestureDetector(onTap: () => lihatDetail(l), child: _LaporanTile(l: l))).toList())),
    ]);
  }
}

// ===== BUAT LAPORAN =====
class BuatLaporanPage extends StatefulWidget {
  final String username;
  final VoidCallback onUpdate;
  const BuatLaporanPage({super.key, required this.username, required this.onUpdate});
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
    AppDB.addLaporan(Laporan(
      id: AppDB.laporan.length + 1, judul: judulCtrl.text, pelapor: widget.username,
      kategori: kategori, tanggal: DateTime.now().toString().split(' ')[0],
      status: prioritas == 'Darurat' ? 'Darurat' : 'Menunggu',
      prioritas: prioritas, lokasi: lokasiCtrl.text, deskripsi: deskCtrl.text));
    judulCtrl.clear(); lokasiCtrl.clear(); deskCtrl.clear();
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final borderC = isDark ? const Color(0xFF2a3a50) : kBorder;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // HEADER — sama seperti admin pages
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kAccent, Color(0xFFd4890e)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: kAccent.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('✏️', style: TextStyle(fontSize: 24)))),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Buat Laporan Baru', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Laporkan masalah di lingkungan Anda', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
        ]),
      ),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderC)),
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
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4, shadowColor: kPrimary.withOpacity(0.4)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('📤', style: TextStyle(fontSize: 16)), SizedBox(width: 8),
                Text('Kirim Laporan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ]))),
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


// ===== USER STATISTIK =====
class UserStatistikPage extends StatelessWidget {
  final String username;
  const UserStatistikPage({super.key, required this.username});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final borderC = isDark ? const Color(0xFF2a3a50) : kBorder;
    final my = AppDB.laporan.where((l) => l.pelapor == username).toList();
    final byKategori = <String, int>{};
    for (final l in my) { byKategori[l.kategori] = (byKategori[l.kategori] ?? 0) + 1; }
    final selesai = my.where((l) => l.status == 'Selesai').length;
    final pct = my.isEmpty ? 0.0 : selesai / my.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF7c3aed), Color(0xFF5b21b6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF7c3aed).withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))]),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('📈', style: TextStyle(fontSize: 24)))),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Statistik Laporan Saya', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Analisis laporan yang kamu kirimkan', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _StatMini(icon: '📋', label: 'Total', value: '${my.length}', color: kInfo)),
        const SizedBox(width: 10),
        Expanded(child: _StatMini(icon: '✅', label: 'Selesai', value: '$selesai', color: kSuccess)),
        const SizedBox(width: 10),
        Expanded(child: _StatMini(icon: '⏳', label: 'Proses', value: '${my.where((l) => l.status == 'Diproses' || l.status == 'Menunggu').length}', color: kWarning)),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderC)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📊 Tingkat Penyelesaian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Laporan selesai', style: TextStyle(fontSize: 13)),
            Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w800, color: kSuccess)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: pct, backgroundColor: kBg, color: kSuccess, minHeight: 10)),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderC)),
        child: my.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada data laporan.', style: TextStyle(color: kTextMuted))))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📋 Laporan per Kategori', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...byKategori.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(e.key, style: const TextStyle(fontSize: 13)),
                    Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: e.value / my.length, backgroundColor: kBg, color: kPrimary, minHeight: 8)),
                ]))),
            ]),
      ),
    ]);
  }
}

class _StatMini extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatMini({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final borderC = isDark ? const Color(0xFF2a3a50) : kBorder;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderC)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 16)))),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ===== USER PENGATURAN =====
class UserPengaturanPage extends StatefulWidget {
  final UserAccount account;
  final Function(String) showToast;
  final VoidCallback? onLogout;
  const UserPengaturanPage({super.key, required this.account, required this.showToast, this.onLogout});
  @override
  State<UserPengaturanPage> createState() => _UserPengaturanPageState();
}

class _UserPengaturanPageState extends State<UserPengaturanPage> with SingleTickerProviderStateMixin {
  bool notifUpdate = true;
  bool notifDarurat = false;
  bool isDarkMode = false;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    isDarkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _toggleDarkMode(bool v) {
    setState(() => isDarkMode = v);
    themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2d4259) : kBorder;
    final textColor = isDark ? Colors.white : kText;
    final mutedColor = isDark ? const Color(0xFF8a9bb0) : kTextMuted;
    final inputFill = isDark ? const Color(0xFF162130) : const Color(0xFFF8FAFC);
    final avatarLetter = widget.account.nama.isNotEmpty ? widget.account.nama[0].toUpperCase() : 'U';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))]),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 24)))),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pengaturan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Kelola akun dan preferensi Anda', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(isDarkMode ? '🌙' : '☀️', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(isDarkMode ? 'Dark' : 'Light', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _toggleDarkMode(!isDarkMode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44, height: 24,
                  decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF5B7FFF) : Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(margin: const EdgeInsets.all(3), width: 18, height: 18,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)])),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
        child: TabBar(
          controller: _tabCtrl,
          labelColor: kPrimary, unselectedLabelColor: mutedColor,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          indicator: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab, dividerColor: Colors.transparent,
          tabs: const [Tab(text: '👤 Akun Saya'), Tab(text: '🔔 Notifikasi'), Tab(text: '🎨 Tampilan')],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 520,
        child: TabBarView(controller: _tabCtrl, children: [
          SingleChildScrollView(child: Column(children: [
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
              child: Column(children: [
                Stack(children: [
                  Container(width: 80, height: 80,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]), borderRadius: BorderRadius.circular(24)),
                    child: Center(child: Text(avatarLetter, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)))),
                  Positioned(bottom: 0, right: 0, child: Container(width: 24, height: 24,
                    decoration: BoxDecoration(color: kSuccess, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBg, width: 2)),
                    child: const Center(child: Text('👤', style: TextStyle(fontSize: 11))))),
                ]),
                const SizedBox(height: 12),
                Text(widget.account.nama, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(color: kSuccess.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Pengguna', style: TextStyle(color: kSuccess, fontSize: 12, fontWeight: FontWeight.w700))),
              ]),
            ),
            _ElegantCard(title: '👤 Informasi Akun', subtitle: 'Data profil Anda', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantField(label: 'Nama Lengkap', value: widget.account.nama, icon: '👤', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Username', value: widget.account.username, icon: '🔑', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'NIK', value: widget.account.nik, icon: '🪪', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'No. HP', value: widget.account.noHp.isEmpty ? '-' : widget.account.noHp, icon: '📱', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
            ]),
            const SizedBox(height: 14),
            _ElegantCard(title: '🔒 Keamanan', subtitle: 'Ubah password akun', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantField(label: 'Password Baru', value: '', hint: 'Kosongkan jika tidak ingin mengubah', icon: '🔐', obscure: true, inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Konfirmasi Password', value: '', hint: 'Ulangi password baru', icon: '🔐', obscure: true, inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
            ]),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('🚪 Keluar dari Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(fontSize: 13)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(context); widget.onLogout?.call(); },
                      style: ElevatedButton.styleFrom(backgroundColor: kDanger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('Ya, Keluar')),
                  ],
                ),
              ),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kDanger.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: kDanger.withOpacity(0.35))),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: kDanger.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('🚪', style: TextStyle(fontSize: 18)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Keluar dari Akun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDanger)),
                    Text('Akhiri sesi dan kembali ke login', style: TextStyle(fontSize: 11, color: kDanger.withOpacity(0.7))),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: kDanger.withOpacity(0.6)),
                ]),
              ),
            ),
          ])),
          SingleChildScrollView(child: _ElegantCard(title: '🔔 Notifikasi', subtitle: 'Atur preferensi pemberitahuan', cardBg: cardBg, borderColor: borderColor, children: [
            _ElegantToggle(icon: '📩', label: 'Update Status Laporan', sublabel: 'Notifikasi saat status laporan berubah',
              value: notifUpdate, activeColor: kPrimary, onChanged: (v) => setState(() => notifUpdate = v),
              textColor: textColor, mutedColor: mutedColor, borderColor: borderColor),
            const SizedBox(height: 10),
            _ElegantToggle(icon: '🚨', label: 'Laporan Darurat', sublabel: 'Pemberitahuan untuk laporan prioritas tinggi',
              value: notifDarurat, activeColor: kDanger, onChanged: (v) => setState(() => notifDarurat = v),
              textColor: textColor, mutedColor: mutedColor, borderColor: borderColor),
          ])),
          SingleChildScrollView(child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isDarkMode ? [const Color(0xFF1a2b45), const Color(0xFF0f1923)] : [const Color(0xFFf0f7ff), Colors.white]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDarkMode ? const Color(0xFF2d4259) : const Color(0xFFcde0f5))),
            child: Row(children: [
              AnimatedContainer(duration: const Duration(milliseconds: 300), width: 52, height: 52,
                decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF243650) : const Color(0xFFe3f0fb), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(isDarkMode ? '🌙' : '☀️', style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mode Tampilan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textColor)),
                Text(isDarkMode ? 'Dark Mode aktif' : 'Light Mode aktif', style: TextStyle(fontSize: 11, color: mutedColor)),
              ])),
              GestureDetector(
                onTap: () => _toggleDarkMode(!isDarkMode),
                child: AnimatedContainer(duration: const Duration(milliseconds: 250), width: 52, height: 28,
                  decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF5B7FFF) : const Color(0xFFCBD5E0), borderRadius: BorderRadius.circular(14)),
                  child: AnimatedAlign(duration: const Duration(milliseconds: 250),
                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(margin: const EdgeInsets.all(3), width: 22, height: 22,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)])))),
              ),
            ]),
          )),
        ]),
      ),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: () => widget.showToast('Pengaturan berhasil disimpan!'),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4, shadowColor: kPrimary.withOpacity(0.4)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('💾', style: TextStyle(fontSize: 16)), SizedBox(width: 8),
            Text('Simpan Pengaturan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ]),
        )),
      const SizedBox(height: 24),
    ]);
  }
}

class _DetailRow extends StatelessWidget {
  final String icon, label, value;
  const _DetailRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: kTextMuted))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
    ]));
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
class ManajemenPenggunaPage extends StatefulWidget {
  final Function(String) showToast;
  const ManajemenPenggunaPage({super.key, required this.showToast});
  @override
  State<ManajemenPenggunaPage> createState() => _ManajemenPenggunaPageState();
}

class _ManajemenPenggunaPageState extends State<ManajemenPenggunaPage> {
  @override
  Widget build(BuildContext context) {
    final users = AppDB.users.where((u) => u.role == 'user').toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manajemen Pengguna', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('${users.length} pengguna terdaftar', style: const TextStyle(fontSize: 13, color: kTextMuted)),
        ]),
        IconButton(
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh_rounded, color: kPrimary),
          tooltip: 'Refresh',
        ),
      ]),
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
  const StatistikPage({super.key});
  @override
  Widget build(BuildContext context) {
    final byKategori = <String, int>{};
    for (final l in AppDB.laporan) { byKategori[l.kategori] = (byKategori[l.kategori] ?? 0) + 1; }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Statistik', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('Analisis data laporan kecamatan', style: TextStyle(fontSize: 13, color: kTextMuted)),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
        child: AppDB.laporan.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada data laporan.', style: TextStyle(color: kTextMuted))))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📊 Laporan per Kategori', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...byKategori.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(e.key, style: const TextStyle(fontSize: 13)), Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))]),
                  const SizedBox(height: 4),
                  ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: e.value / AppDB.laporan.length, backgroundColor: kBg, color: kPrimary, minHeight: 8)),
                ]))),
            ])),
    ]);
  }
}

// ===== PENGATURAN (REDESIGNED) =====
class PengaturanPage extends StatefulWidget {
  final Function(String) showToast;
  final VoidCallback? onLogout;
  const PengaturanPage({super.key, required this.showToast, this.onLogout});
  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> with SingleTickerProviderStateMixin {
  bool notifLaporan = true;
  bool notifDarurat = true;
  bool isDarkMode = false;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    isDarkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  void _toggleDarkMode(bool v) {
    setState(() => isDarkMode = v);
    themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2d4259) : kBorder;
    final textColor = isDark ? Colors.white : kText;
    final mutedColor = isDark ? const Color(0xFF8a9bb0) : kTextMuted;
    final inputFill = isDark ? const Color(0xFF162130) : const Color(0xFFF8FAFC);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ===== HEADER =====
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 24)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Pengaturan Sistem', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const Text('Konfigurasi aplikasi pelaporan kecamatan', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
          // DARK MODE TOGGLE — Hero Feature
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(isDarkMode ? '🌙' : '☀️', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(isDarkMode ? 'Dark' : 'Light', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _toggleDarkMode(!isDarkMode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44, height: 24,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF5B7FFF) : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(margin: const EdgeInsets.all(3), width: 18, height: 18,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)])),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 20),

      // ===== TAB BAR =====
      Container(
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
        child: TabBar(
          controller: _tabCtrl,
          labelColor: kPrimary,
          unselectedLabelColor: mutedColor,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          indicator: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: '🏛️ Kecamatan'),
            Tab(text: '📞 Kontak'),
            Tab(text: '🔔 Notifikasi'),
            Tab(text: '👤 Akun'),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ===== TAB VIEWS =====
      SizedBox(
        height: 520,
        child: TabBarView(controller: _tabCtrl, children: [

          // --- TAB 1: INFO KECAMATAN + WILAYAH + SLA ---
          SingleChildScrollView(child: Column(children: [
            _ElegantCard(title: '🏛️ Informasi Kecamatan', subtitle: 'Data identitas kecamatan', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantField(label: 'Nama Kecamatan', value: 'Kecamatan Brang Ene', icon: '🏢', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Kabupaten / Kota', value: 'Kabupaten Sumbawa Barat', icon: '📍', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Nama Camat', value: 'Bpk. H. Budi Santoso, S.IP', icon: '👨‍💼', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Alamat Kantor', value: 'Jl. Raya Brang Ene, NTB', icon: '🗺️', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
            ]),
            const SizedBox(height: 14),
            _ElegantCard(title: '🗺️ Data Wilayah', subtitle: 'Informasi wilayah administratif', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantField(label: 'Jumlah Desa', value: '6 Desa', icon: '🏘️', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Desa / Kelurahan', value: 'Mura, Kalimantong, Lampok, Manemeng, Mujahiddin, Mataiyang', icon: '📋', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              Row(children: [
                Expanded(child: _ElegantField(label: 'Jumlah RT', value: '-', icon: '🏠', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor)),
                const SizedBox(width: 12),
                Expanded(child: _ElegantField(label: 'Jumlah RW', value: '-', icon: '🏠', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor)),
                const SizedBox(width: 12),
                Expanded(child: _ElegantField(label: 'Kode Pos', value: '84455', icon: '📮', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor)),
              ]),
            ]),
            const SizedBox(height: 14),
            _ElegantCard(title: '📋 SLA Laporan', subtitle: 'Batas waktu penanganan laporan', cardBg: cardBg, borderColor: borderColor, children: [
              Row(children: [
                Expanded(child: _SlaChip(label: 'Tanggapan', value: '3 hari kerja', color: kInfo, icon: '⚡')),
                const SizedBox(width: 12),
                Expanded(child: _SlaChip(label: 'Penyelesaian', value: '14 hari kerja', color: kSuccess, icon: '✅')),
              ]),
            ]),
          ])),

          // --- TAB 2: KONTAK ---
          SingleChildScrollView(child: Column(children: [
            _ElegantCard(title: '📞 Kontak & Layanan', subtitle: 'Informasi kontak resmi kecamatan', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantField(label: 'No. Telepon Kantor', value: '+6285173464488', icon: '📞', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'No. WhatsApp Pengaduan', value: '+6285173464488', icon: '💬', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Email Resmi', value: 'my3onlyxyz@gmail.com', icon: '✉️', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Jam Operasional', value: 'Senin – Jumat, 08:00 – 16:00 WITA', icon: '🕐', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [kInfo.withOpacity(0.08), kPrimary.withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(14), border: Border.all(color: kInfo.withOpacity(0.25))),
              child: Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: kInfo.withOpacity(0.15), borderRadius: BorderRadius.circular(11)),
                  child: const Center(child: Text('ℹ️', style: TextStyle(fontSize: 18)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Info', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kInfo)),
                  Text('Perubahan kontak akan tampil di halaman Contact FAB pada semua pengguna.', style: TextStyle(fontSize: 11, color: mutedColor)),
                ])),
              ]),
            ),
          ])),

          // --- TAB 3: NOTIFIKASI & TAMPILAN ---
          SingleChildScrollView(child: Column(children: [
            // DARK MODE CARD
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                    ? [const Color(0xFF1a2b45), const Color(0xFF0f1923)]
                    : [const Color(0xFFf0f7ff), Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? const Color(0xFF2d4259) : const Color(0xFFcde0f5)),
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF243650) : const Color(0xFFe3f0fb),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(isDarkMode ? '🌙' : '☀️', style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mode Tampilan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textColor)),
                  Text(isDarkMode ? 'Dark Mode aktif — Tampilan gelap nyaman di malam hari' : 'Light Mode aktif — Tampilan terang dan bersih',
                    style: TextStyle(fontSize: 11, color: mutedColor)),
                ])),
                GestureDetector(
                  onTap: () => _toggleDarkMode(!isDarkMode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 52, height: 28,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF5B7FFF) : const Color(0xFFCBD5E0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      alignment: isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(margin: const EdgeInsets.all(3), width: 22, height: 22,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)])),
                    ),
                  ),
                ),
              ]),
            ),

            _ElegantCard(title: '🔔 Notifikasi', subtitle: 'Atur preferensi pemberitahuan', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantToggle(
                icon: '📩', label: 'Laporan Baru Masuk',
                sublabel: 'Pemberitahuan saat ada laporan dari masyarakat',
                value: notifLaporan, activeColor: kPrimary,
                onChanged: (v) => setState(() => notifLaporan = v),
                textColor: textColor, mutedColor: mutedColor, borderColor: borderColor,
              ),
              const SizedBox(height: 10),
              _ElegantToggle(
                icon: '🚨', label: 'Laporan Darurat',
                sublabel: 'Pemberitahuan prioritas tinggi dan mendesak',
                value: notifDarurat, activeColor: kDanger,
                onChanged: (v) => setState(() => notifDarurat = v),
                textColor: textColor, mutedColor: mutedColor, borderColor: borderColor,
              ),
            ]),
          ])),

          // --- TAB 4: AKUN ADMIN ---
          SingleChildScrollView(child: Column(children: [
            // AVATAR CARD
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
              child: Column(children: [
                Stack(children: [
                  Container(width: 80, height: 80,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kPrimaryLight]), borderRadius: BorderRadius.circular(24)),
                    child: const Center(child: Text('A', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)))),
                  Positioned(bottom: 0, right: 0, child: Container(width: 24, height: 24,
                    decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBg, width: 2)),
                    child: const Center(child: Text('👑', style: TextStyle(fontSize: 11))))),
                ]),
                const SizedBox(height: 12),
                Text('Administrator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor)),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(color: kAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Super Admin', style: TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.w700))),
              ]),
            ),

            _ElegantCard(title: '👤 Informasi Akun', subtitle: 'Data login administrator', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantField(label: 'Nama Tampilan', value: 'Administrator', icon: '👤', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Username', value: 'admin', icon: '🔑', inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
            ]),
            const SizedBox(height: 14),
            _ElegantCard(title: '🔒 Keamanan', subtitle: 'Ubah password akun admin', cardBg: cardBg, borderColor: borderColor, children: [
              _ElegantField(label: 'Password Baru', value: '', hint: 'Kosongkan jika tidak ingin mengubah', icon: '🔐', obscure: true, inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
              _ElegantField(label: 'Konfirmasi Password', value: '', hint: 'Ulangi password baru', icon: '🔐', obscure: true, inputFill: inputFill, mutedColor: mutedColor, textColor: textColor, borderColor: borderColor),
            ]),
            const SizedBox(height: 14),
            // LOGOUT BUTTON
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('🚪 Keluar dari Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    content: const Text('Apakah Anda yakin ingin keluar dari akun ini?', style: TextStyle(fontSize: 13)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () { Navigator.pop(context); widget.onLogout?.call(); },
                        style: ElevatedButton.styleFrom(backgroundColor: kDanger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Ya, Keluar'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kDanger.withOpacity(0.35)),
                ),
                child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: kDanger.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('🚪', style: TextStyle(fontSize: 18)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Keluar dari Akun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kDanger)),
                    Text('Akhiri sesi dan kembali ke halaman login', style: TextStyle(fontSize: 11, color: kDanger.withOpacity(0.7))),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: kDanger.withOpacity(0.6)),
                ]),
              ),
            ),
          ])),
        ]),
      ),

      const SizedBox(height: 20),
      // ===== SAVE BUTTON =====
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          onPressed: () => widget.showToast('💾 Pengaturan berhasil disimpan!'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4,
            shadowColor: kPrimary.withOpacity(0.4),
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('💾', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text('Simpan Semua Pengaturan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ]),
        )),
      const SizedBox(height: 24),
    ]);
  }
}

// ===== ELEGANT CARD =====
class _ElegantCard extends StatelessWidget {
  final String title, subtitle;
  final List<Widget> children;
  final Color cardBg, borderColor;
  const _ElegantCard({required this.title, required this.subtitle, required this.children, required this.cardBg, required this.borderColor});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: kTextMuted)),
        ])),
      ]),
      const SizedBox(height: 16),
      const Divider(height: 1, color: Color(0xFFEDF2F7)),
      const SizedBox(height: 16),
      ...children,
    ]));
}

// ===== ELEGANT FIELD =====
class _ElegantField extends StatelessWidget {
  final String label, value, icon;
  final String? hint;
  final bool obscure;
  final Color inputFill, mutedColor, textColor, borderColor;
  const _ElegantField({required this.label, required this.value, required this.icon,
    this.hint, this.obscure = false,
    required this.inputFill, required this.mutedColor, required this.textColor, required this.borderColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: mutedColor)),
      ]),
      const SizedBox(height: 6),
      TextFormField(
        initialValue: value, obscureText: obscure,
        style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true, fillColor: inputFill,
          hintText: hint, hintStyle: TextStyle(color: mutedColor, fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kPrimaryLight, width: 1.5))),
      ),
    ]));
}

// ===== ELEGANT TOGGLE =====
class _ElegantToggle extends StatelessWidget {
  final String icon, label, sublabel;
  final bool value;
  final Color activeColor, textColor, mutedColor, borderColor;
  final Function(bool) onChanged;
  const _ElegantToggle({required this.icon, required this.label, required this.sublabel,
    required this.value, required this.activeColor, required this.onChanged,
    required this.textColor, required this.mutedColor, required this.borderColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: value ? activeColor.withOpacity(0.06) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: value ? activeColor.withOpacity(0.3) : borderColor),
    ),
    child: Row(children: [
      Container(width: 38, height: 38,
        decoration: BoxDecoration(color: value ? activeColor.withOpacity(0.12) : borderColor.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
        Text(sublabel, style: TextStyle(fontSize: 11, color: mutedColor)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: activeColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    ]));
}

// ===== SLA CHIP =====
class _SlaChip extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _SlaChip({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w500)),
    ]));
}

// ===== LEGACY SECTION CARD (kept for compatibility) =====
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      ...children,
    ]));
}

class _ToggleRow extends StatelessWidget {
  final String label, sublabel;
  final bool value;
  final Function(bool) onChanged;
  const _ToggleRow({required this.label, required this.sublabel, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText)),
        Text(sublabel, style: const TextStyle(fontSize: 11, color: kTextMuted)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: kPrimary),
    ]));
}

class _SettingField extends StatelessWidget {
  final String label, value;
  final String? hint;
  final bool obscure;
  const _SettingField({required this.label, required this.value, this.hint, this.obscure = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted)),
      const SizedBox(height: 4),
      TextFormField(
        initialValue: value, obscureText: obscure, style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimaryLight, width: 2)))),
    ]));
}

// ===== HELPERS =====
class _TappableStatCard extends StatefulWidget {
  final String icon, value, label, sublabel;
  final Color iconBg, iconColor;
  final VoidCallback onTap;
  const _TappableStatCard({required this.icon, required this.iconBg, required this.iconColor,
    required this.value, required this.label, required this.sublabel, required this.onTap});
  @override
  State<_TappableStatCard> createState() => _TappableStatCardState();
}

class _TappableStatCardState extends State<_TappableStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final border = isDark ? const Color(0xFF2a3a50) : kBorder;
    final mutedC = isDark ? const Color(0xFF8a9bb0) : kTextMuted;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: widget.iconBg, borderRadius: BorderRadius.circular(11)),
                child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 18)))),
              const Spacer(),
              Container(width: 22, height: 22,
                decoration: BoxDecoration(color: widget.iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.chevron_right_rounded, size: 16, color: widget.iconColor)),
            ]),
            const SizedBox(height: 12),
            Text(widget.value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: widget.iconColor, height: 1)),
            const SizedBox(height: 2),
            Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            Text(widget.sublabel, style: TextStyle(fontSize: 10, color: mutedC)),
          ]),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String icon, label;
  final Color color;
  const _QuickAction({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1e2d3d) : Colors.white;
    final border = isDark ? const Color(0xFF2a3a50) : kBorder;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Column(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 17)))),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _LaporanTile extends StatelessWidget {
  final Laporan l;
  const _LaporanTile({required this.l});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF2a3a50) : kBorder;
    final colors = {'Menunggu': kWarning, 'Diproses': kInfo, 'Selesai': kSuccess, 'Darurat': kDanger};
    final icons = {'Menunggu': '⏳', 'Diproses': '🔄', 'Selesai': '✅', 'Darurat': '🚨'};
    final sc = colors[l.status] ?? kTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icons[l.status] ?? '', style: const TextStyle(fontSize: 16)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.judul, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${l.pelapor} · ${l.tanggal}', style: TextStyle(fontSize: 10, color: isDark ? const Color(0xFF8a9bb0) : kTextMuted)),
        ])),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(l.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc))),
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
