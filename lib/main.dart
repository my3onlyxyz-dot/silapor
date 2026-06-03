import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const IPTrackerApp());
}

// ===== THEME =====
const kPrimary   = Color(0xFF6C63FF);
const kAccent    = Color(0xFF00D4AA);
const kDanger    = Color(0xFFFF5E6C);
const kBg        = Color(0xFF0F1117);
const kCard      = Color(0xFF1A1D2E);
const kCard2     = Color(0xFF252840);
const kBorder    = Color(0xFF2E3154);
const kText      = Color(0xFFEAEBFF);
const kMuted     = Color(0xFF7B7FA6);

// ===== MODEL =====
class IPInfo {
  final String ip, country, countryCode, region, city, zip, lat, lon,
      timezone, isp, org, query;
  const IPInfo({
    required this.ip, required this.country, required this.countryCode,
    required this.region, required this.city, required this.zip,
    required this.lat, required this.lon, required this.timezone,
    required this.isp, required this.org, required this.query,
  });

  factory IPInfo.fromJson(Map<String, dynamic> j) => IPInfo(
    ip: j['query'] ?? '',
    query: j['query'] ?? '',
    country: j['country'] ?? 'Unknown',
    countryCode: j['countryCode'] ?? '',
    region: j['regionName'] ?? 'Unknown',
    city: j['city'] ?? 'Unknown',
    zip: j['zip'] ?? '-',
    lat: (j['lat'] ?? 0.0).toString(),
    lon: (j['lon'] ?? 0.0).toString(),
    timezone: j['timezone'] ?? '-',
    isp: j['isp'] ?? 'Unknown',
    org: j['org'] ?? '-',
  );
}

// ===== HISTORY =====
class HistoryItem {
  final String ip, city, country, countryCode, isp;
  final DateTime time;
  HistoryItem({required this.ip, required this.city, required this.country,
      required this.countryCode, required this.isp, required this.time});
}

// ===== APP =====
class IPTrackerApp extends StatefulWidget {
  const IPTrackerApp({super.key});
  @override
  State<IPTrackerApp> createState() => _IPTrackerAppState();
}

class _IPTrackerAppState extends State<IPTrackerApp> {
  int _tab = 0;
  IPInfo? _result;
  bool _loading = false;
  String _error = '';
  final List<HistoryItem> _history = [];
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  Future<void> _lookup([String? ip]) async {
    final target = (ip ?? _ctrl.text).trim();
    setState(() { _loading = true; _error = ''; _result = null; });
    try {
      final url = target.isEmpty
          ? 'http://ip-api.com/json/?fields=66846719'
          : 'http://ip-api.com/json/$target?fields=66846719';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'fail') throw Exception(data['message'] ?? 'Gagal');
      final info = IPInfo.fromJson(data);
      setState(() {
        _result = info;
        _loading = false;
        _history.insert(0, HistoryItem(
          ip: info.ip, city: info.city, country: info.country,
          countryCode: info.countryCode, isp: info.isp, time: DateTime.now()));
        if (_history.length > 30) _history.removeLast();
      });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IP Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.dark(primary: kPrimary, surface: kCard),
        fontFamily: 'monospace',
      ),
      home: Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Column(children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _tab == 0 ? _buildTracker() : _buildHistory()),
          ]),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1A1D2E), Color(0xFF252840)]),
      border: Border(bottom: BorderSide(color: kBorder))),
    child: Row(children: [
      Container(width: 42, height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, Color(0xFF9C91FF)]),
          borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.radar, color: Colors.white, size: 22)),
      const SizedBox(width: 12),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('IP Tracker', style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        Text('Lacak informasi IP address', style: TextStyle(color: kMuted, fontSize: 11)),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kAccent.withOpacity(0.12),
          border: Border.all(color: kAccent.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20)),
        child: const Row(children: [
          Icon(Icons.circle, size: 7, color: kAccent),
          SizedBox(width: 5),
          Text('LIVE', style: TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        ])),
    ]));

  // ===== TAB BAR =====
  Widget _buildTabBar() => Container(
    color: kCard,
    child: Row(children: [
      _TabBtn(label: '🔍  Lacak IP', active: _tab == 0, onTap: () => setState(() => _tab = 0)),
      _TabBtn(label: '🕒  Riwayat (${_history.length})', active: _tab == 1, onTap: () => setState(() => _tab = 1)),
    ]));

  // ===== TRACKER TAB =====
  Widget _buildTracker() => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Search box
      Container(
        decoration: BoxDecoration(
          color: kCard,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              const Icon(Icons.search, color: kMuted, size: 18),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: const TextStyle(color: kText, fontSize: 15, fontFamily: 'monospace'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Masukkan IP (kosong = IP saya)',
                  hintStyle: TextStyle(color: kMuted, fontSize: 14)),
                onSubmitted: (_) => _lookup(),
              )),
              if (_ctrl.text.isNotEmpty)
                GestureDetector(
                  onTap: () { _ctrl.clear(); setState(() {}); },
                  child: const Icon(Icons.close, color: kMuted, size: 18)),
            ])),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(children: [
              Expanded(child: _ActionBtn(
                label: '🌐  IP Saya',
                color: kAccent,
                onTap: () { _ctrl.clear(); _lookup(''); })),
              const SizedBox(width: 10),
              Expanded(child: _ActionBtn(
                label: '🔍  Lacak',
                color: kPrimary,
                onTap: () => _lookup())),
            ])),
        ])),

      const SizedBox(height: 20),

      // Quick examples
      const Text('Contoh IP:', style: TextStyle(color: kMuted, fontSize: 12)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        '8.8.8.8', '1.1.1.1', '208.67.222.222', '9.9.9.9',
      ].map((ip) => GestureDetector(
        onTap: () { _ctrl.text = ip; _lookup(ip); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kCard2,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(20)),
          child: Text(ip, style: const TextStyle(color: kMuted, fontSize: 12, fontFamily: 'monospace'))),
      )).toList()),

      const SizedBox(height: 24),

      if (_loading) _buildLoading(),
      if (_error.isNotEmpty) _buildError(),
      if (_result != null && !_loading) _buildResult(_result!),
    ]));

  Widget _buildLoading() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
    child: const Column(children: [
      SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: kPrimary, strokeWidth: 3)),
      SizedBox(height: 16),
      Text('Melacak IP...', style: TextStyle(color: kMuted, fontSize: 14)),
    ]));

  Widget _buildError() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kDanger.withOpacity(0.08),
      border: Border.all(color: kDanger.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      const Icon(Icons.error_outline, color: kDanger, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(_error, style: const TextStyle(color: kDanger, fontSize: 13))),
    ]));

  Widget _buildResult(IPInfo info) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // IP Banner
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [kPrimary.withOpacity(0.15), kAccent.withOpacity(0.08)]),
        border: Border.all(color: kPrimary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('IP ADDRESS', style: TextStyle(color: kMuted, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: Text(info.ip,
            style: const TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'monospace'))),
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: info.ip)),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: kCard2, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.copy, color: kMuted, size: 16))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text(_flagEmoji(info.countryCode), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text('${info.city}, ${info.country}',
            style: const TextStyle(color: kAccent, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ])),

    const SizedBox(height: 14),

    // Grid 2x2
    GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: [
        _InfoCard(icon: '🌍', label: 'Negara', value: '${info.country} (${info.countryCode})'),
        _InfoCard(icon: '🏙️', label: 'Kota', value: info.city),
        _InfoCard(icon: '📍', label: 'Region', value: info.region),
        _InfoCard(icon: '📮', label: 'Kode Pos', value: info.zip),
      ]),

    const SizedBox(height: 10),

    // Koordinat
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('📡', style: TextStyle(fontSize: 13)),
          SizedBox(width: 8),
          Text('KOORDINAT', style: TextStyle(color: kMuted, fontSize: 10, letterSpacing: 1.5)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _CoordItem(label: 'Latitude', value: info.lat)),
          const SizedBox(width: 12),
          Expanded(child: _CoordItem(label: 'Longitude', value: info.lon)),
        ]),
      ])),

    const SizedBox(height: 10),

    // Jaringan
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('🔗', style: TextStyle(fontSize: 13)),
          SizedBox(width: 8),
          Text('JARINGAN', style: TextStyle(color: kMuted, fontSize: 10, letterSpacing: 1.5)),
        ]),
        const SizedBox(height: 12),
        _NetRow(label: 'ISP', value: info.isp),
        const SizedBox(height: 8),
        _NetRow(label: 'Org', value: info.org),
        const SizedBox(height: 8),
        _NetRow(label: 'Timezone', value: info.timezone),
      ])),

    const SizedBox(height: 20),
  ]);

  // ===== HISTORY TAB =====
  Widget _buildHistory() {
    if (_history.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 70, height: 70,
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text('🕒', style: TextStyle(fontSize: 32)))),
        const SizedBox(height: 16),
        const Text('Belum ada riwayat', style: TextStyle(color: kText, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Lacak IP untuk melihat riwayat', style: TextStyle(color: kMuted, fontSize: 13)),
      ]));

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_history.length} riwayat', style: const TextStyle(color: kMuted, fontSize: 13)),
          GestureDetector(
            onTap: () => setState(() => _history.clear()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kDanger.withOpacity(0.1),
                border: Border.all(color: kDanger.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20)),
              child: const Text('🗑 Hapus Semua', style: TextStyle(color: kDanger, fontSize: 12)))),
        ])),
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final h = _history[i];
          return GestureDetector(
            onTap: () { _ctrl.text = h.ip; _lookup(h.ip); setState(() => _tab = 0); },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kCard, border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(width: 42, height: 42,
                  decoration: BoxDecoration(color: kCard2, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(_flagEmoji(h.countryCode), style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(h.ip, style: const TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                  const SizedBox(height: 3),
                  Text('${h.city}, ${h.country}', style: const TextStyle(color: kMuted, fontSize: 12)),
                  Text(h.isp, style: const TextStyle(color: kMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Icon(Icons.chevron_right, color: kMuted, size: 18),
                  const SizedBox(height: 4),
                  Text(_timeAgo(h.time), style: const TextStyle(color: kMuted, fontSize: 10)),
                ]),
              ])));
        })),
    ]);
  }

  String _flagEmoji(String code) {
    if (code.length != 2) return '🌐';
    final a = 0x1F1E6 + (code.codeUnitAt(0) - 0x41);
    final b = 0x1F1E6 + (code.codeUnitAt(1) - 0x41);
    return String.fromCharCode(a) + String.fromCharCode(b);
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }
}

// ===== REUSABLE WIDGETS =====
class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: active ? kPrimary : Colors.transparent, width: 2))),
      child: Text(label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: active ? kPrimary : kMuted,
          fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400)))));
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10)),
      child: Text(label,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))));
}

class _InfoCard extends StatelessWidget {
  final String icon, label, value;
  const _InfoCard({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: kCard, border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: kMuted, fontSize: 10, letterSpacing: 0.5)),
      ]),
      const Spacer(),
      Text(value, style: const TextStyle(color: kText, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
    ]));
}

class _CoordItem extends StatelessWidget {
  final String label, value;
  const _CoordItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: kMuted, fontSize: 11)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(color: kAccent, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
  ]);
}

class _NetRow extends StatelessWidget {
  final String label, value;
  const _NetRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 70, child: Text(label, style: const TextStyle(color: kMuted, fontSize: 12))),
    Expanded(child: Text(value, style: const TextStyle(color: kText, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis)),
  ]);
}
