import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/weight_entry.dart';
import '../state/weight_notifier.dart';

class WeightLogPage extends ConsumerStatefulWidget {
  const WeightLogPage({super.key});

  @override
  ConsumerState<WeightLogPage> createState() => _WeightLogPageState();
}

class _WeightLogPageState extends ConsumerState<WeightLogPage> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0 || value > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight in kg.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(weightProvider.notifier).add(value);
      _controller.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save weight: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weightProvider);
    final entries = state.valueOrNull ?? const <WeightEntry>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Weight')),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Text('Track your progress over time', style: AppText.subtitle),
              const SizedBox(height: 18),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _SummaryRow(entries: entries),
                const SizedBox(height: 14),
                GlassCard(
                  padding: const EdgeInsets.fromLTRB(10, 18, 18, 10),
                  child: SizedBox(
                    height: 200,
                    child: entries.length < 2
                        ? Center(
                            child: Text(
                              entries.isEmpty
                                  ? 'Log your weight to see the trend.'
                                  : 'Add one more entry to draw the chart.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : _WeightChart(entries: entries),
                  ),
                ),
                const SizedBox(height: 16),
                _AddWeightRow(
                  controller: _controller,
                  saving: _saving,
                  onAdd: _add,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<WeightEntry> entries;

  const _SummaryRow({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return GlassCard(
        child: Text(
          'No weight logged yet.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final latest = entries.last.weightKg;
    final first = entries.first.weightKg;
    final change = latest - first;
    final gained = change > 0;

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${latest.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${gained ? '+' : ''}${change.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: change == 0
                        ? Colors.white
                        : (gained
                            ? const Color(0xFFFFADD8)
                            : const Color(0xFF8BE0B0)),
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;

  const _WeightChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].weightKg),
    ];
    final values = entries.map((e) => e.weightKg).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final pad = ((maxV - minV) * 0.2).clamp(1.0, 10.0);

    return LineChart(
      LineChartData(
        minY: minV - pad,
        maxY: maxV + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withOpacity(0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accent,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddWeightRow extends StatelessWidget {
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onAdd;

  const _AddWeightRow({
    required this.controller,
    required this.saving,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Today's weight (kg)",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: saving ? null : onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryBtnText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }
}
