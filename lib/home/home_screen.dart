import 'package:flutter/material.dart';
import 'package:live_activities_usecase/match/match_controls.dart';
import 'package:live_activities_usecase/match/match_score_section.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../live_activity/live_activity_service.dart';
import '../../match/match_entity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LiveActivityService _service = LiveActivityService();

  String? _activityId;
  bool _permissionGranted = false;

  int teamAScore = 0;
  int teamBScore = 0;

  final String teamAName = 'PSG';
  final String teamBName = 'Chelsea';

  @override
  void initState() {
    super.initState();
    _service.init();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    setState(() => _permissionGranted = status.isGranted);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  MatchEntity _buildMatch() {
    return MatchEntity(
      teamAName: teamAName,
      teamBName: teamBName,
      teamAScore: teamAScore,
      teamBScore: teamBScore,
    );
  }

  Future<void> _startMatch() async {
    if (!_permissionGranted) return;
    final id = await _service.startMatch(_buildMatch());
    setState(() => _activityId = id);
  }

  Future<void> _updateScore() async {
    if (_activityId == null) return;
    await _service.updateMatch(_activityId!, _buildMatch());
  }

  Future<void> _stopMatch() async {
    await _service.stopMatch();
    setState(() => _activityId = null);
  }

  void _checkSupport() async {
    final supported = await _service.isSupported();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(supported ? 'Supported' : 'Not supported')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _activityId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Activities')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              MatchScoreSection(
                teamAScore: teamAScore,
                teamBScore: teamBScore,
                teamAName: teamAName,
                teamBName: teamBName,
                onTeamAScoreChanged: (score) {
                  setState(() => teamAScore = score);
                  _updateScore();
                },
                onTeamBScoreChanged: (score) {
                  setState(() => teamBScore = score);
                  _updateScore();
                },
              ),

            const SizedBox(height: 20),

            MatchControls(
              isMatchActive: isActive,
              onStart: _startMatch,
              onStop: _stopMatch,
              onCheckSupport: _checkSupport,
            ),
          ],
        ),
      ),
    );
  }
}
