import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _creditScoreCtrl   = TextEditingController(text: '650');
  final _ageCtrl           = TextEditingController(text: '35');
  final _tenureCtrl        = TextEditingController(text: '5');
  final _balanceCtrl       = TextEditingController(text: '0');
  final _numProductsCtrl   = TextEditingController(text: '1');
  final _salaryCtrl        = TextEditingController(text: '100000');

  // Dropdowns
  String _geography    = 'France';
  String _gender       = 'Male';
  int    _hasCrCard    = 1;
  int    _isActive     = 1;

  final List<String> _geoOptions    = ['France', 'Germany', 'Spain'];
  final List<String> _genderOptions = ['Male', 'Female'];

  @override
  void dispose() {
    _creditScoreCtrl.dispose();
    _ageCtrl.dispose();
    _tenureCtrl.dispose();
    _balanceCtrl.dispose();
    _numProductsCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final inputData = {
        'CreditScore':     double.parse(_creditScoreCtrl.text),
        'Age':             double.parse(_ageCtrl.text),
        'Tenure':          double.parse(_tenureCtrl.text),
        'Balance':         double.parse(_balanceCtrl.text),
        'NumOfProducts':   double.parse(_numProductsCtrl.text),
        'HasCrCard':       _hasCrCard.toDouble(),
        'IsActiveMember':  _isActive.toDouble(),
        'EstimatedSalary': double.parse(_salaryCtrl.text),
        'Geography':       _geography,
        'Gender':          _gender,
      };

      final result = await ApiService.predict(inputData);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: result,
              inputData: inputData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}',
                style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Data Nasabah',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Informasi Pribadi ──
              _sectionTitle('👤 Informasi Pribadi'),
              const SizedBox(height: 12),

              _buildDropdown(
                  label: 'Geography (Negara)',
                  value: _geography,
                  items: _geoOptions,
                  onChanged: (v) => setState(() => _geography = v!),
                  icon: Icons.location_on_outlined),

              const SizedBox(height: 12),

              _buildDropdown(
                  label: 'Gender',
                  value: _gender,
                  items: _genderOptions,
                  onChanged: (v) => setState(() => _gender = v!),
                  icon: Icons.person_outline),

              const SizedBox(height: 12),

              _buildTextField(
                  ctrl: _ageCtrl,
                  label: 'Usia (tahun)',
                  icon: Icons.cake_outlined,
                  hint: 'Contoh: 35',
                  min: 18, max: 100),

              const SizedBox(height: 24),

              // ── Section: Informasi Kredit ──
              _sectionTitle('💳 Informasi Kredit & Rekening'),
              const SizedBox(height: 12),

              _buildTextField(
                  ctrl: _creditScoreCtrl,
                  label: 'Credit Score',
                  icon: Icons.score_outlined,
                  hint: 'Contoh: 650',
                  min: 300, max: 900),

              const SizedBox(height: 12),

              _buildTextField(
                  ctrl: _balanceCtrl,
                  label: 'Balance (Saldo Rekening)',
                  icon: Icons.account_balance_wallet_outlined,
                  hint: 'Contoh: 75000',
                  isDecimal: true),

              const SizedBox(height: 12),

              _buildTextField(
                  ctrl: _salaryCtrl,
                  label: 'Estimated Salary (Gaji)',
                  icon: Icons.payments_outlined,
                  hint: 'Contoh: 100000',
                  isDecimal: true),

              const SizedBox(height: 24),

              // ── Section: Informasi Produk ──
              _sectionTitle('🏦 Informasi Produk Bank'),
              const SizedBox(height: 12),

              _buildTextField(
                  ctrl: _tenureCtrl,
                  label: 'Tenure (Lama menjadi nasabah, tahun)',
                  icon: Icons.timer_outlined,
                  hint: 'Contoh: 5',
                  min: 0, max: 10),

              const SizedBox(height: 12),

              _buildTextField(
                  ctrl: _numProductsCtrl,
                  label: 'Jumlah Produk Bank',
                  icon: Icons.inventory_2_outlined,
                  hint: 'Contoh: 1 atau 2',
                  min: 1, max: 4),

              const SizedBox(height: 12),

              // Toggle HasCrCard
              _buildToggle(
                label: 'Memiliki Kartu Kredit?',
                icon: Icons.credit_card_outlined,
                value: _hasCrCard == 1,
                onChanged: (v) => setState(() => _hasCrCard = v ? 1 : 0),
              ),

              const SizedBox(height: 12),

              // Toggle IsActiveMember
              _buildToggle(
                label: 'Nasabah Aktif?',
                icon: Icons.verified_user_outlined,
                value: _isActive == 1,
                onChanged: (v) => setState(() => _isActive = v ? 1 : 0),
              ),

              const SizedBox(height: 32),

              // ── Tombol Prediksi ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _predict,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white, size: 28)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.analytics_outlined, size: 22),
                            const SizedBox(width: 10),
                            Text('Prediksi Churn',
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3B82F6),
            letterSpacing: 0.5),
      );

  Widget _buildTextField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required String hint,
    double? min,
    double? max,
    bool isDecimal = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType:
            TextInputType.numberWithOptions(decimal: isDecimal),
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
              color: const Color(0xFF64748B), fontSize: 13),
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              color: const Color(0xFF374151), fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Wajib diisi';
          final val = double.tryParse(v);
          if (val == null) return 'Masukkan angka yang valid';
          if (min != null && val < min) return 'Minimum $min';
          if (max != null && val > max) return 'Maksimum $max';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF1F2937),
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
              color: const Color(0xFF64748B), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          border: InputBorder.none,
        ),
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: GoogleFonts.inter(color: Colors.white))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildToggle({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8), fontSize: 13))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF1E3A5F),
          ),
        ],
      ),
    );
  }
}
