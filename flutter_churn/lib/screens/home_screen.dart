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
                // ── Header ──
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
                        child: const Icon(Icons.psychology,
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

                // ── Hero ──
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
                        const Text('🏦', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 16),
                        Text('Bank Customer\nChurn Prediction',
                            style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2)),
                        const SizedBox(height: 10),
                        Text(
                            'Prediksi apakah nasabah akan churn atau bertahan menggunakan dua model Deep Learning.',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                                height: 1.5)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Model Info Cards ──
                FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Row(children: [
                      Expanded(
                          child: _modelCard('CNN 1D',
                              'Convolutional Neural Network', '🔷')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _modelCard('BiLSTM',
                              'Bidirectional LSTM', '🔶')),
                    ])),

                const SizedBox(height: 28),

                // ── Info Dataset ──
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
                        const Icon(Icons.info_outline,
                            color: Color(0xFF3B82F6), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Dataset: Bank Customer Churn Modeling\n10.000 data nasabah | 11 fitur input',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: const Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // ── Button Mulai ──
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const InputScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Mulai Prediksi',
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
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

  Widget _modelCard(String title, String subtitle, String emoji) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(title,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 14)),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
