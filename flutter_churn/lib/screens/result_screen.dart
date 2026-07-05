import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final Map<String, dynamic> inputData;

  const ResultScreen({
    super.key,
    required this.result,
    required this.inputData,
  });

  @override
  Widget build(BuildContext context) {
    final cnn        = result['cnn1d']  as Map<String, dynamic>;
    final bilstm     = result['bilstm'] as Map<String, dynamic>;
    final best       = result['final_prediction'] as String;
    final bestModel  = result['best_model'] as String;
    final reason     = result['reason'] as String? ?? '';
    final agreement  = result['agreement'] as String? ?? '';
    final cnnConf    = (cnn['confidence'] as num?)?.toDouble() ?? 0.0;
    final bilstmConf = (bilstm['confidence'] as num?)?.toDouble() ?? 0.0;
    final isChurn    = best == 'Churn';
    final cnnChurn    = (cnn['churn_risk']    as num).toDouble();
    final bilstmChurn = (bilstm['churn_risk'] as num).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hasil Prediksi',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: Text('Home',
                style: GoogleFonts.inter(color: const Color(0xFF3B82F6), fontSize: 13)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ── HASIL UTAMA ──
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isChurn
                        ? [const Color(0xFF2D1200), const Color(0xFF1A0A00)]
                        : [const Color(0xFF052E16), const Color(0xFF001A0A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isChurn ? const Color(0xFFF97316) : const Color(0xFF22C55E),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(isChurn ? '⚠️' : '✅', style: const TextStyle(fontSize: 52)),
                    const SizedBox(height: 12),
                    Text(
                      isChurn ? 'CHURN' : 'RETAIN',
                      style: GoogleFonts.inter(
                        fontSize: 32, fontWeight: FontWeight.w900,
                        color: isChurn ? const Color(0xFFF97316) : const Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isChurn
                          ? 'Nasabah diprediksi akan meninggalkan bank'
                          : 'Nasabah diprediksi akan tetap bertahan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Model Terbaik: $bestModel',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── KENAPA MODEL INI TERBAIK ──
            FadeInUp(
              duration: const Duration(milliseconds: 550),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('🏆', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text('Mengapa $bestModel Terpilih?',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14)),
                    ]),
                    const SizedBox(height: 12),
                    _confidenceRow('CNN 1D', cnnConf, const Color(0xFF3B82F6), bestModel == 'CNN 1D'),
                    const SizedBox(height: 8),
                    _confidenceRow('BiLSTM', bilstmConf, const Color(0xFF8B5CF6), bestModel == 'BiLSTM'),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: agreement.contains('sepakat')
                            ? const Color(0xFF22C55E).withOpacity(0.1)
                            : const Color(0xFFF97316).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: agreement.contains('sepakat')
                              ? const Color(0xFF22C55E).withOpacity(0.3)
                              : const Color(0xFFF97316).withOpacity(0.3),
                        ),
                      ),
                      child: Row(children: [
                        Text(agreement.contains('sepakat') ? '✅' : '⚠️',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(agreement,
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: agreement.contains('sepakat')
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFF97316))),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0E1A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('💡 $reason',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF94A3B8), height: 1.5)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── PERBANDINGAN CNN vs BiLSTM ──
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📊 Perbandingan Model',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 16),
                    _modelResultCard(
                      modelName: 'CNN 1D',
                      prediction: cnn['prediction'] as String,
                      churnRisk: cnnChurn,
                      retainProb: (cnn['retain_prob'] as num).toDouble(),
                      color: const Color(0xFF3B82F6),
                      emoji: '🔷',
                    ),
                    const SizedBox(height: 12),
                    _modelResultCard(
                      modelName: 'BiLSTM',
                      prediction: bilstm['prediction'] as String,
                      churnRisk: bilstmChurn,
                      retainProb: (bilstm['retain_prob'] as num).toDouble(),
                      color: const Color(0xFF8B5CF6),
                      emoji: '🔶',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── BAR CHART ──
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📈 Risiko Churn (%)',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                                    style: GoogleFonts.inter(
                                        fontSize: 10, color: const Color(0xFF64748B))),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final labels = ['CNN 1D', 'BiLSTM'];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(labels[v.toInt()],
                                        style: GoogleFonts.inter(
                                            fontSize: 12, color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (_) =>
                                const FlLine(color: Color(0xFF1E3A5F), strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _barGroup(0, cnnChurn, const Color(0xFF3B82F6)),
                            _barGroup(1, bilstmChurn, const Color(0xFF8B5CF6)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── SUMMARY INPUT ──
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📋 Data Nasabah yang Diinput',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 14),
                    ...inputData.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: const Color(0xFF64748B))),
                              Text(e.value.toString(),
                                  style: GoogleFonts.inter(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('🔄 Prediksi Ulang',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _confidenceRow(String name, double conf, Color color, bool isBest) {
    return Row(children: [
      SizedBox(
        width: 60,
        child: Text(name,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: isBest ? color : const Color(0xFF64748B),
                fontWeight: isBest ? FontWeight.w700 : FontWeight.w400)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: conf / 100,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
                isBest ? color : color.withOpacity(0.4)),
            minHeight: 8,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text('${conf.toStringAsFixed(1)}%',
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isBest ? FontWeight.w700 : FontWeight.w400,
              color: isBest ? color : const Color(0xFF64748B))),
      if (isBest) ...[
        const SizedBox(width: 4),
        const Text('👑', style: TextStyle(fontSize: 12)),
      ]
    ]);
  }

  BarChartGroupData _barGroup(int x, double val, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: val,
        color: color,
        width: 40,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        backDrawRodData: BackgroundBarChartRodData(
          show: true, toY: 100, color: color.withOpacity(0.1),
        ),
      )
    ]);
  }

  Widget _modelResultCard({
    required String modelName,
    required String prediction,
    required double churnRisk,
    required double retainProb,
    required Color color,
    required String emoji,
  }) {
    final isChurn = prediction == 'Churn';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(modelName,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: churnRisk / 100,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isChurn ? const Color(0xFFF97316) : const Color(0xFF22C55E)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Churn: ${churnRisk.toStringAsFixed(1)}%  |  Retain: ${retainProb.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isChurn
                  ? const Color(0xFFF97316).withOpacity(0.15)
                  : const Color(0xFF22C55E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(prediction,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isChurn ? const Color(0xFFF97316) : const Color(0xFF22C55E))),
          ),
        ],
      ),
    );
  }
}