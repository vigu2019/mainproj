import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/stats_service.dart';
import '../services/profile_service.dart';
import 'package:http/http.dart' as http;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _backendUrlController = TextEditingController();

  // State
  bool _isSavingProfile = false;
  bool _isSavingSettings = false;
  bool _isClearingDb = false;
  bool _isBackendOnline = false;
  bool _isCheckingBackend = false;
  int _totalScans = 0;
  int _scanCount = 0;
  bool _autoSaveDetections = true;
  String _saveProfileMsg = '';
  String _saveSettingsMsg = '';

  static const _nameKey = 'admin_name';
  static const _emailKey = 'admin_email';
  static const _backendKey = 'backend_url';
  static const _autoSaveKey = 'auto_save_detections';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadDbStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _backendUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey) ?? 'Admin User';
    final email = prefs.getString(_emailKey) ?? 'admin@so-yolo.local';
    final url = prefs.getString(_backendKey) ?? 'http://127.0.0.1:8000';
    final autoSave = prefs.getBool(_autoSaveKey) ?? true;
    final scans = await StatsService.getTotalScans();
    if (mounted) {
      setState(() {
        _nameController.text = name;
        _emailController.text = email;
        _backendUrlController.text = url;
        _autoSaveDetections = autoSave;
        _totalScans = scans;
      });
    }
  }

  Future<void> _loadDbStats() async {
    final rows = await DatabaseService().getScans(limit: 9999);
    if (mounted) {
      setState(() {
        _scanCount = rows.length;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() { _isSavingProfile = true; _saveProfileMsg = ''; });
    await ProfileService.saveProfile(_nameController.text.trim(), _emailController.text.trim());
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _isSavingProfile = false;
        _saveProfileMsg = 'Profile saved!';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _saveProfileMsg = '');
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() { _isSavingSettings = true; _saveSettingsMsg = ''; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendKey, _backendUrlController.text.trim());
    await prefs.setBool(_autoSaveKey, _autoSaveDetections);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _isSavingSettings = false;
        _saveSettingsMsg = 'Settings saved!';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _saveSettingsMsg = '');
      });
    }
  }

  Future<void> _testBackend() async {
    setState(() { _isCheckingBackend = true; });
    try {
      final url = _backendUrlController.text.trim();
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (mounted) {
        setState(() { _isBackendOnline = res.statusCode == 200; });
      }
    } catch (_) {
      if (mounted) setState(() { _isBackendOnline = false; });
    }
    if (mounted) setState(() { _isCheckingBackend = false; });
  }

  Future<void> _clearDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear All Scan Records',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          'This will permanently delete all scan history from the local database and reset the scan counter. This action cannot be undone.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Clear All', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() { _isClearingDb = true; });

    // Delete all scans by fetching IDs then deleting
    final db = DatabaseService();
    final rows = await db.getScans(limit: 9999);
    for (final row in rows) {
      await db.deleteScan(row['id'] as int);
    }
    // Reset stats counter
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_scans', 0);

    await _loadDbStats();
    if (mounted) {
      setState(() {
        _isClearingDb = false;
        _totalScans = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All scan records cleared.'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your profile, system settings, and database.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 40),

            // ── Two column layout ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 24),
                      _buildSystemSettingsCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right column
                SizedBox(
                  width: 340,
                  child: Column(
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 24),
                      _buildDatabaseCard(),
                      const SizedBox(height: 24),
                      _buildAppInfoCard(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Profile Card ────────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.manage_accounts_rounded, 'Profile', const Color(0xFF3B82F6)),
          const SizedBox(height: 24),

          // Avatar row
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Administrator', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('SO-YOLOv8 System', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          _inputField(label: 'Display Name', controller: _nameController, icon: Icons.badge_rounded),
          const SizedBox(height: 16),
          _inputField(label: 'Email Address', controller: _emailController, icon: Icons.email_rounded),
          const SizedBox(height: 24),

          Row(
            children: [
              _saveButton(
                label: 'Save Profile',
                isLoading: _isSavingProfile,
                onTap: _saveProfile,
                color: const Color(0xFF3B82F6),
              ),
              if (_saveProfileMsg.isNotEmpty) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 6),
                    Text(_saveProfileMsg, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── System Settings Card ────────────────────────────────────────────────────
  Widget _buildSystemSettingsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.settings_rounded, 'System Settings', const Color(0xFF8B5CF6)),
          const SizedBox(height: 24),

          _inputField(label: 'Backend URL', controller: _backendUrlController, icon: Icons.link_rounded),
          const SizedBox(height: 16),

          // Auto-save toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Auto-save Detections History', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              Switch(
                value: _autoSaveDetections,
                activeColor: const Color(0xFF8B5CF6),
                onChanged: (v) => setState(() => _autoSaveDetections = v),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _saveButton(
                label: 'Save Settings',
                isLoading: _isSavingSettings,
                onTap: _saveSettings,
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 12),
              // Test connection button
              OutlinedButton.icon(
                onPressed: _isCheckingBackend ? null : _testBackend,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _isBackendOnline ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: _isCheckingBackend
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF64748B)))
                    : Icon(
                        _isBackendOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                        size: 16,
                        color: _isBackendOnline ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                label: Text(
                  _isCheckingBackend ? 'Testing...' : 'Test Connection',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isBackendOnline ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  ),
                ),
              ),
              if (_saveSettingsMsg.isNotEmpty) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 6),
                    Text(_saveSettingsMsg, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Card ─────────────────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.analytics_rounded, 'Statistics', const Color(0xFF06B6D4)),
          const SizedBox(height: 20),
          _statRow('Total Scans (all time)', '$_totalScans', Icons.bar_chart_rounded, const Color(0xFF3B82F6)),
          const Divider(height: 28, color: Color(0xFFF1F5F9)),
          _statRow('Records in Database', '$_scanCount', Icons.storage_rounded, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  // ─── Database Card ───────────────────────────────────────────────────────────
  Widget _buildDatabaseCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.storage_rounded, 'Database', const Color(0xFFEF4444)),
          const SizedBox(height: 16),
          const Text(
            'Manage the local SQLite database that stores scan history. Clearing will remove all records and reset the counter.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isClearingDb ? null : _clearDatabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                foregroundColor: const Color(0xFFEF4444),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                ),
              ),
              icon: _isClearingDb
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                  : const Icon(Icons.delete_sweep_rounded, size: 18),
              label: Text(
                _isClearingDb ? 'Clearing...' : 'Clear All Scan Records',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Info Card ───────────────────────────────────────────────────────────
  Widget _buildAppInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.info_outline_rounded, 'App Info', const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _infoRow('App Name', 'SO-YOLOv8'),
          _infoRow('Version', '1.0.0'),
          _infoRow('Model', 'YOLOv8'),
          _infoRow('Platform', 'Flutter (Windows)'),
          _infoRow('Backend', 'FastAPI / Python'),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0x94, 0xA3, 0xB8, 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _inputField({required String label, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _saveButton({required String label, required bool isLoading, required VoidCallback onTap, required Color color}) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B)))),
        Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF64748B)))),
          Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}
