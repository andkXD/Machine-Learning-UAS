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
    final isChurn    = best == 'Churn';

    final cnnChurn    = (cnn['churn_risk']    as num).toDouble();
    final cnnRetain   = (cnn['retain_prob']   as num).toDouble();
    final cnnConf     = (cnn['confidence']    as num?)?.toDouble() ?? (cnnRetain > 50 ? cnnRetain : cnnChurn);
    final bilstmChurn = (bilstm['churn_risk'] as num).toDouble();
    final bilstmRetain= (bilstm['retain_prob']as num).toDouble();
    final bilstmConf  = (bilstm['confidence'] as num?)?.toDouble() ?? (bilstmRetain > 50 ? bilstmRetain : bilstmChurn);

    final cnnPred     = cnn['prediction']    as String;
    final bilstmPred  = bilstm['prediction'] as String;
    final agreement   = cnnPred == bilstmPred ? 'Kedua model sepakat' : 'Kedua model berbeda pendapat';

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

            // ── SCORECARD MODEL ──
            FadeInUp(
              duration: const Duration(milliseconds: 550),
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
                    Text('Skor Perbandingan Model',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 16),

                    // Agreement Badge
                    Container(
                      width: double.infinity,
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
                      child: Text(
                        agreement.contains('sepakat')
                            ? '✅ $agreement hasil lebih reliable'
                            : '⚠️ $agreement gunakan model terbaik',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: agreement.contains('sepakat')
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFF97316)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Scorecard grid
                    Row(children: [
                      Expanded(child: _scorecardItem(
                        'CNN 1D', '🔷', cnnPred, cnnChurn, cnnRetain, cnnConf,
                        const Color(0xFF3B82F6), bestModel == 'CNN 1D')),
                      const SizedBox(width: 12),
                      Expanded(child: _scorecardItem(
                        'BiLSTM', '🔶', bilstmPred, bilstmChurn, bilstmRetain, bilstmConf,
                        const Color(0xFF8B5CF6), bestModel == 'BiLSTM')),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── DOUBLE BAR CHART: Churn vs Retain ──
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
                    Text('Probabilitas Churn vs Retain (%)',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Perbandingan keyakinan kedua model',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: const Color(0xFF64748B))),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF1F2937),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final labels = ['CNN Churn', 'CNN Retain', 'BiLSTM Churn', 'BiLSTM Retain'];
                                return BarTooltipItem(
                                  '${labels[group.x * 2 + rodIndex]}\n${rod.toY.toStringAsFixed(1)}%',
                                  GoogleFonts.inter(color: Colors.white, fontSize: 11),
                                );
                              },
                            ),
                          ),
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
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (_) =>
                                const FlLine(color: Color(0xFF1E3A5F), strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            // CNN 1D: Churn + Retain
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(
                                toY: cnnChurn, color: const Color(0xFFF97316),
                                width: 22, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                              BarChartRodData(
                                toY: cnnRetain, color: const Color(0xFF22C55E),
                                width: 22, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ], barsSpace: 4),
                            // BiLSTM: Churn + Retain
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(
                                toY: bilstmChurn, color: const Color(0xFFF97316),
                                width: 22, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                              BarChartRodData(
                                toY: bilstmRetain, color: const Color(0xFF22C55E),
                                width: 22, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ], barsSpace: 4),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _legend('Churn', const Color(0xFFF97316)),
                      const SizedBox(width: 20),
                      _legend('Retain', const Color(0xFF22C55E)),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── CONFIDENCE METER ──
            FadeInUp(
              duration: const Duration(milliseconds: 650),
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
                    Text('Tingkat Keyakinan Model',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Semakin tinggi = model semakin yakin dengan prediksinya',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: const Color(0xFF64748B))),
                    const SizedBox(height: 16),
                    _confidenceMeter('CNN 1D', cnnConf, const Color(0xFF3B82F6), bestModel == 'CNN 1D'),
                    const SizedBox(height: 12),
                    _confidenceMeter('BiLSTM', bilstmConf, const Color(0xFF8B5CF6), bestModel == 'BiLSTM'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── DATA INPUT ──
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
                child: Text('Prediksi Ulang',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _scorecardItem(String name, String emoji, String pred,
      double churn, double retain, double conf, Color color, bool isBest) {
    final isChurn = pred == 'Churn';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBest ? color : color.withOpacity(0.2),
          width: isBest ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            if (isBest) const Text('👑', style: TextStyle(fontSize: 14)),
          ]),
          const SizedBox(height: 8),
          Text(name,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isChurn
                  ? const Color(0xFFF97316).withOpacity(0.15)
                  : const Color(0xFF22C55E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(pred,
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: isChurn ? const Color(0xFFF97316) : const Color(0xFF22C55E))),
          ),
          const SizedBox(height: 8),
          Text('Churn: ${churn.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
          Text('Retain: ${retain.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text('Conf: ${conf.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _confidenceMeter(String name, double conf, Color color, bool isBest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(name,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isBest ? FontWeight.w700 : FontWeight.w400,
                    color: isBest ? color : const Color(0xFF64748B))),
            if (isBest) ...[
              const SizedBox(width: 4),
              const Text('👑', style: TextStyle(fontSize: 12)),
            ]
          ]),
          Text('${conf.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isBest ? FontWeight.w700 : FontWeight.w400,
                  color: isBest ? color : const Color(0xFF64748B))),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: conf / 100,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
                isBest ? color : color.withOpacity(0.3)),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _legend(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
    ]);
  }
}