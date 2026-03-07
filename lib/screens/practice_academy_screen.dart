import 'package:flutter/material.dart';

import '../models/practice_drill.dart';
import '../services/practice_service.dart';

class PracticeAcademyScreen extends StatefulWidget {
  const PracticeAcademyScreen({super.key});

  @override
  State<PracticeAcademyScreen> createState() => _PracticeAcademyScreenState();
}

class _PracticeAcademyScreenState extends State<PracticeAcademyScreen> {
  final PracticeService _service = PracticeService();

  Map<String, DrillProgress> _progress = {};
  List<bool> _preShotChecks = List<bool>.filled(kPreShotChecklist.length, false);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = await _service.loadProgress();
    final checks = await _service.loadPreShotChecks();
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _preShotChecks = checks;
      _loading = false;
    });
  }

  Future<void> _saveChecks() async {
    await _service.savePreShotChecks(_preShotChecks);
  }

  Future<void> _recordDrill(PracticeDrill drill) async {
    final attemptsController = TextEditingController(text: '${drill.recommendedReps}');
    final hitsController = TextEditingController(text: '0');

    final result = await showDialog<_RecordResult>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ergebnis erfassen: ${drill.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: attemptsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Versuche'),
              ),
              TextField(
                controller: hitsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Treffer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                final attempts = int.tryParse(attemptsController.text) ?? 0;
                final hits = int.tryParse(hitsController.text) ?? 0;
                Navigator.pop(context, _RecordResult(attempts: attempts, hits: hits));
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );

    if (result == null || result.attempts <= 0) return;

    final boundedHits = result.hits.clamp(0, result.attempts);
    final percent = (boundedHits / result.attempts) * 100;
    final current = _progress[drill.id] ?? DrillProgress.empty;

    final next = current.copyWith(
      attempts: current.attempts + result.attempts,
      successes: current.successes + boundedHits,
      lastPercent: percent,
      bestPercent: percent > current.bestPercent ? percent : current.bestPercent,
    );

    final updated = {..._progress, drill.id: next};
    await _service.saveProgress(updated);

    if (!mounted) return;
    setState(() {
      _progress = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Academy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pre-Shot Routine',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(kPreShotChecklist.length, (index) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _preShotChecks[index],
                      title: Text(kPreShotChecklist[index]),
                      onChanged: (value) {
                        setState(() {
                          _preShotChecks[index] = value ?? false;
                        });
                        _saveChecks();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Drills',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...kPracticeDrills.map((drill) {
            final p = _progress[drill.id] ?? DrillProgress.empty;
            final avg = p.attempts == 0 ? 0.0 : (p.successes / p.attempts) * 100;

            return Card(
              child: ListTile(
                title: Text(drill.title),
                subtitle: Text(
                  '${drill.goal}\nØ ${avg.toStringAsFixed(1)}% • Best ${p.bestPercent.toStringAsFixed(1)}% • Last ${p.lastPercent.toStringAsFixed(1)}%',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.add_task),
                  onPressed: () => _recordDrill(drill),
                  tooltip: 'Ergebnis eintragen',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RecordResult {
  const _RecordResult({required this.attempts, required this.hits});

  final int attempts;
  final int hits;
}
