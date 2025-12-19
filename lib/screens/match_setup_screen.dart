import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/game_settings.dart';
import 'match_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  final TextEditingController _p1Controller = TextEditingController();
  final TextEditingController _p2Controller = TextEditingController();
  
  Player? _p1Profile;
  Player? _p2Profile;
  
  bool _isHandicap = false;
  String _goal = '100';
  String _p1Spot = '0';
  String _p2Spot = '0';

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  void _handleStart(GameProvider provider) {
    if (_p1Profile == null || _p2Profile == null) return;

    final settings = GameSettings(
      goalP1: int.tryParse(_goal) ?? 100,
      goalP2: int.tryParse(_goal) ?? 100,
      p1Spot: _isHandicap ? (int.tryParse(_p1Spot) ?? 0) : 0,
      p2Spot: _isHandicap ? (int.tryParse(_p2Spot) ?? 0) : 0,
    );

    provider.startMatch(_p1Profile!, _p2Profile!, settings);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MatchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final isReady = _p1Profile != null && _p2Profile != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(provider.t('newGame').toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSection(
              provider.t('players'),
              columnChildren: [
                _SmartPlayerSelect(
                  label: "Player 1",
                  controller: _p1Controller,
                  players: provider.players,
                  onSelect: (p) => setState(() {
                    _p1Profile = p;
                    _p1Controller.text = p.name;
                  }),
                  onCreate: (name) async {
                    await provider.addPlayer(name);
                    final newP = provider.players.last;
                    setState(() {
                      _p1Profile = newP;
                      _p1Controller.text = name;
                    });
                  },
                  onClear: () => setState(() => _p1Profile = null),
                  isSelected: _p1Profile != null,
                ),
                const SizedBox(height: 16),
                _SmartPlayerSelect(
                  label: "Player 2",
                  controller: _p2Controller,
                  players: provider.players,
                  onSelect: (p) => setState(() {
                    _p2Profile = p;
                    _p2Controller.text = p.name;
                  }),
                  onCreate: (name) async {
                    await provider.addPlayer(name);
                    final newP = provider.players.last;
                    setState(() {
                      _p2Profile = newP;
                      _p2Controller.text = name;
                    });
                  },
                  onClear: () => setState(() => _p2Profile = null),
                  isSelected: _p2Profile != null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              provider.t('settings'),
              columnChildren: [
                _buildRow(
                  provider.t('score'),
                  child: _buildNumberInput(_goal, (val) => setState(() => _goal = val)),
                ),
                _buildRow(
                  "Handicap",
                  child: Switch(
                    value: _isHandicap,
                    onChanged: (val) => setState(() => _isHandicap = val),
                    activeColor: const Color(0xFF22C55E),
                  ),
                ),
                if (_isHandicap) ...[
                  const Divider(color: Colors.white10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("P1 Spot", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            _buildNumberInput(_p1Spot, (val) => setState(() => _p1Spot = val)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("P2 Spot", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            _buildNumberInput(_p2Spot, (val) => setState(() => _p2Spot = val)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isReady ? () => _handleStart(provider) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  disabledBackgroundColor: const Color(0xFF1F2937),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isReady 
                    ? provider.t('newGame').toUpperCase() 
                    : (_p1Profile == null ? "Select Player 1" : "Select Player 2"),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, {required List<Widget> columnChildren}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          ...columnChildren,
        ],
      ),
    );
  }

  Widget _buildRow(String label, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          child,
        ],
      ),
    );
  }

  Widget _buildNumberInput(String value, Function(String) onChanged) {
    return Container(
      width: 80,
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF0F172A),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
        onChanged: onChanged,
      ),
    );
  }
}

class _SmartPlayerSelect extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<Player> players;
  final Function(Player) onSelect;
  final Function(String) onCreate;
  final VoidCallback onClear;
  final bool isSelected;

  const _SmartPlayerSelect({
    required this.label,
    required this.controller,
    required this.players,
    required this.onSelect,
    required this.onCreate,
    required this.onClear,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final value = controller.text;
    final suggestions = value.isNotEmpty 
      ? players.where((p) => p.name.toLowerCase().contains(value.toLowerCase())).toList()
      : [];
    
    final exactMatch = players.any((p) => p.name.toLowerCase() == value.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => onClear(),
                decoration: InputDecoration(
                  hintText: "Name...",
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF374151))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: value.isEmpty ? null : () => exactMatch ? onSelect(players.firstWhere((p) => p.name.toLowerCase() == value.toLowerCase())) : onCreate(value),
                style: ElevatedButton.styleFrom(
                  backgroundColor: exactMatch ? const Color(0xFF22C55E) : const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: exactMatch ? const Icon(Icons.check, color: Colors.white) : const Text("CREATE"),
              ),
            ),
          ],
        ),
        if (suggestions.isNotEmpty && !exactMatch)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF374151)),
            ),
            child: Column(
              children: suggestions.map((p) => ListTile(
                title: Text(p.name, style: const TextStyle(color: Colors.white)),
                onTap: () => onSelect(p),
              )).toList(),
            ),
          ),
      ],
    );
  }
}
