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
    final prediction = (result['final_prediction'] as String?) ?? 'Retain';
    final churnProb  = (result['bilstm']?['churn_risk'] as num?)?.toDouble() ?? 0.0;
    final retainProb = (result['bilstm']?['retain_prob'] as num?)?.toDouble() ?? 0.0;
    final confidence = (result['bilstm']?['confidence'] as num?)?.toDouble() ?? 0.0;
    final riskLevel  = churnProb >= 75 ? 'Tinggi' : churnProb >= 50 ? 'Sedang' : churnProb >= 25 ? 'Rendah' : 'Sangat Rendah';
    final isChurn    = prediction == 'Churn';

    final riskColor = isChurn
        ? (churnProb >= 75
            ? const Color(0xFFEF4444)
            : const Color(0xFFF97316))
        : const Color(0xFF22C55E);

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
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          TextButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (r) => r.isFirst),
            icon: const Icon(Icons.home_rounded,
                color: Color(0xFF3B82F6), size: 18),
            label: Text('Home',
                style: GoogleFonts.inter(
                    color: const Color(0xFF3B82F6), fontSize: 13)),
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
                  border: Border.all(color: riskColor, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isChurn
                            ? Icons.trending_down_rounded
                            : Icons.trending_up_rounded,
                        color: riskColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isChurn ? 'CHURN' : 'RETAIN',
                      style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: riskColor,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isChurn
                          ? 'Nasabah diprediksi akan meninggalkan bank'
                          : 'Nasabah diprediksi akan tetap bertahan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: riskColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded,
                              color: riskColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Risiko: $riskLevel',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: riskColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.memory_rounded,
                            color: Color(0xFF64748B), size: 13),
                        const SizedBox(width: 4),
                        Text(
                          'CNN 1D  |  Akurasi Testing: 86.0%',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── PROBABILITAS ──
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
                    Row(children: [
                      const Icon(Icons.bar_chart_rounded,
                          color: Color(0xFF3B82F6), size: 20),
                      const SizedBox(width: 8),
                      Text('Probabilitas Prediksi',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15)),
                    ]),
                    const SizedBox(height: 16),
                    _probBar('Churn', churnProb,
                        const Color(0xFFF97316)),
                    const SizedBox(height: 12),
                    _probBar('Retain', retainProb,
                        const Color(0xFF22C55E)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0E1A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF1E3A5F)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFF3B82F6), size: 16),
                          const SizedBox(width: 8),
                          Text('Tingkat Keyakinan Model',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8))),
                          const Spacer(),
                          Text(
                              '${confidence.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF3B82F6))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── PIE CHART ──
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
                    Row(children: [
                      const Icon(Icons.pie_chart_rounded,
                          color: Color(0xFF8B5CF6), size: 20),
                      const SizedBox(width: 8),
                      Text('Distribusi Probabilitas',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15)),
                    ]),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              value: churnProb,
                              color: const Color(0xFFF97316),
                              title:
                                  '${churnProb.toStringAsFixed(1)}%',
                              radius: 60,
                              titleStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              value: retainProb,
                              color: const Color(0xFF22C55E),
                              title:
                                  '${retainProb.toStringAsFixed(1)}%',
                              radius: 60,
                              titleStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legend('Churn',
                            const Color(0xFFF97316)),
                        const SizedBox(width: 24),
                        _legend('Retain',
                            const Color(0xFF22C55E)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── PERFORMA MODEL ──
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
                    Row(children: [
                      const Icon(Icons.leaderboard_rounded,
                          color: Color(0xFF34D399), size: 20),
                      const SizedBox(width: 8),
                      Text('Performa Model CNN 1D',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15)),
                    ]),
                    const SizedBox(height: 4),
                    Text('Diuji pada 1.000 data testing',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B))),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData:
                              BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (v, _) =>
                                    Text('${v.toInt()}%',
                                        style: GoogleFonts.inter(
                                            fontSize: 9,
                                            color: const Color(
                                                0xFF64748B))),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final labels = [
                                    'Akurasi',
                                    'Presisi',
                                    'Recall',
                                    'F1'
                                  ];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 6),
                                    child: Text(labels[v.toInt()],
                                        style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.w600)),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 25,
                            getDrawingHorizontalLine: (_) =>
                                const FlLine(
                                    color: Color(0xFF1E3A5F),
                                    strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            _barGroup(0, 86.0,
                                const Color(0xFF3B82F6)),
                            _barGroup(1, 76.0,
                                const Color(0xFF8B5CF6)),
                            _barGroup(2, 45.0,
                                const Color(0xFF34D399)),
                            _barGroup(3, 57.0,
                                const Color(0xFFFB923C)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _metricPill('Akurasi', '86.0%',
                            const Color(0xFF3B82F6)),
                        _metricPill('Presisi', '76.0%',
                            const Color(0xFF8B5CF6)),
                        _metricPill('Recall', '45.0%',
                            const Color(0xFF34D399)),
                        _metricPill('F1-Score', '57.0%',
                            const Color(0xFFFB923C)),
                      ],
                    ),
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
                    Row(children: [
                      const Icon(Icons.person_rounded,
                          color: Color(0xFF3B82F6), size: 20),
                      const SizedBox(width: 8),
                      Text('Data Nasabah yang Diinput',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15)),
                    ]),
                    const SizedBox(height: 14),
                    ...inputData.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color:
                                          const Color(0xFF64748B))),
                              Text(e.value.toString(),
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Prediksi Ulang',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _probBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Text('${value.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  BarChartGroupData _barGroup(int x, double val, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: val,
        color: color,
        width: 32,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(6)),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: 100,
          color: color.withOpacity(0.1),
        ),
      )
    ]);
  }

  Widget _legend(String label, Color color) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 6),
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8))),
    ]);
  }

  Widget _metricPill(String label, String value, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text('$label: $value',
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}