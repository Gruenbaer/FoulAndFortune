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
  bool _loading = true;

  // Filter state
  PracticeCategory? _categoryFilter;
  PracticeDifficulty? _difficultyFilter;
  String? _focusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final progress = await _service.loadProgress();
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _loading = false;
    });
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

    final filteredDrills = kPracticeDrills.where((drill) {
      if (_categoryFilter != null && drill.category != _categoryFilter) return false;
      if (_difficultyFilter != null && drill.difficulty != _difficultyFilter) return false;
      if (_focusFilter != null && drill.focus != _focusFilter) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Academy'),
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMethodologyCard(theme),
                const SizedBox(height: 16),
                Text(
                  'Übungen (${filteredDrills.length})',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...filteredDrills.map((drill) => _buildDrillCard(drill, theme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip<PracticeCategory>(
            label: 'Kategorie',
            current: _categoryFilter,
            items: PracticeCategory.values,
            itemLabel: (v) => _getCategoryLabel(v),
            onChanged: (v) => setState(() => _categoryFilter = v),
          ),
          const SizedBox(width: 8),
          _buildFilterChip<PracticeDifficulty>(
            label: 'Schwierigkeit',
            current: _difficultyFilter,
            items: PracticeDifficulty.values,
            itemLabel: (v) => _getDifficultyLabel(v),
            onChanged: (v) => setState(() => _difficultyFilter = v),
          ),
          const SizedBox(width: 8),
          _buildFilterChip<String>(
            label: 'Fokus',
            current: _focusFilter,
            items: _getAllFoci(),
            itemLabel: (v) => v,
            onChanged: (v) => setState(() => _focusFilter = v),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _categoryFilter = null;
                _difficultyFilter = null;
                _focusFilter = null;
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip<T>({
    required String label,
    required T? current,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return PopupMenuButton<T>(
      initialValue: current,
      onSelected: onChanged,
      child: Chip(
        label: Text(current == null ? label : itemLabel(current)),
        backgroundColor: current != null ? Theme.of(context).colorScheme.primaryContainer : null,
        onDeleted: current != null ? () => onChanged(null) : null,
      ),
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<T>(
            value: item,
            child: Text(itemLabel(item)),
          );
        }).toList();
      },
    );
  }

  String _getCategoryLabel(PracticeCategory cat) {
    switch (cat) {
      case PracticeCategory.straightness:
        return 'Geradlinigkeit';
      case PracticeCategory.potting:
        return 'Senken';
      case PracticeCategory.technique:
        return 'Technik';
      case PracticeCategory.position:
        return 'Positionsspiel';
      case PracticeCategory.gameplay:
        return 'Game Mode';
    }
  }

  String _getDifficultyLabel(PracticeDifficulty diff) {
    switch (diff) {
      case PracticeDifficulty.beginner:
        return 'Einsteiger';
      case PracticeDifficulty.intermediate:
        return 'Fortgeschritten';
      case PracticeDifficulty.advanced:
        return 'Profi';
    }
  }

  List<String> _getAllFoci() {
    return kPracticeDrills.map((d) => d.focus).toSet().toList()..sort();
  }

  Widget _buildMethodologyCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pre-Shot Routine & Methodik', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Die Routine hilft dir, vor jedem Stoß klare Entscheidungen zu treffen und den Ablauf mental vorzubereiten. '
              'Ziel ist ein stabiler, wiederholbarer Prozess.',
            ),
            const SizedBox(height: 8),
            ...kPreShotChecklist.map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(text)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillCard(PracticeDrill drill, ThemeData theme) {
    final p = _progress[drill.id] ?? DrillProgress.empty;
    final avg = p.attempts == 0 ? 0.0 : (p.successes / p.attempts) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(drill.title),
        subtitle: Text(
          '${_getDifficultyLabel(drill.difficulty)} • ${drill.focus}\nØ ${avg.toStringAsFixed(1)}% • Best ${p.bestPercent.toStringAsFixed(1)}%',
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.asset(
            drill.imageAsset,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.fitness_center),
            fit: BoxFit.cover,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ziel:', style: theme.textTheme.titleSmall),
                Text(drill.goal),
                const SizedBox(height: 8),
                Text('Beschreibung:', style: theme.textTheme.titleSmall),
                Text(drill.description),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Empfohlen: ${drill.recommendedReps} Reps'),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_task),
                      onPressed: () => _recordDrill(drill),
                      label: const Text('Ergebnis eintragen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
