import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E1A), Color(0xFF1A1040), Color(0xFF0A0E1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.psychology_rounded,
                            color: Color(0xFF3B82F6), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ML Churn Predictor',
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('UAS Praktikum Machine Learning',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B))),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Hero
                FadeInUp(
                  duration: const Duration(milliseconds: 700),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A5F), Color(0xFF1A1040)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_rounded,
                              color: Color(0xFF3B82F6), size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text('Bank Customer\nChurn Prediction',
                            style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2)),
                        const SizedBox(height: 10),
                        Text(
                            'Prediksi apakah nasabah akan churn atau bertahan menggunakan model Deep Learning CNN 1D.',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Model Info Cards
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Row(children: [
                    Expanded(child: _infoCard(
                        Icons.check_circle_rounded,
                        '86.0%', 'Akurasi Model',
                        const Color(0xFF3B82F6))),
                    const SizedBox(width: 12),
                    Expanded(child: _infoCard(
                        Icons.dataset_rounded,
                        '10.000', 'Total Data',
                        const Color(0xFF8B5CF6))),
                    const SizedBox(width: 12),
                    Expanded(child: _infoCard(
                        Icons.memory_rounded,
                        'CNN 1D', 'Model',
                        const Color(0xFF34D399))),
                  ]),
                ),

                const SizedBox(height: 28),

                // Info Dataset
                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E3A5F)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFF3B82F6), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Dataset: Bank Customer Churn Modeling\n10.000 data nasabah | 11 fitur input',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF94A3B8),
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Button
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const InputScreen())),
                      icon: const Icon(Icons.analytics_rounded, size: 20),
                      label: Text('Mulai Prediksi',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 14)),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}