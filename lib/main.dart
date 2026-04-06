import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'score_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _liveActivitiesPlugin = LiveActivities();
  String? _latestActivityId;
  bool _notificationPermissionGranted = false;

  int teamAScore = 0;
  int teamBScore = 0;
  String teamAName = 'PSG';
  String teamBName = 'Chelsea';

  @override
  void initState() {
    super.initState();

    _liveActivitiesPlugin.init(appGroupId: '');
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationPermissionGranted = status.isGranted;
    });
    if (status.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
    }
  }

  @override
  void dispose() {
    _liveActivitiesPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Activities (Android)'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_latestActivityId != null)
              Card(
                child: SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: Row(
                    children: [
                      Expanded(
                        child: ScoreWidget(
                          score: teamAScore,
                          teamName: teamAName,
                          onScoreChanged: (score) {
                            setState(() => teamAScore = score < 0 ? 0 : score);
                            _updateScore();
                          },
                        ),
                      ),
                      Expanded(
                        child: ScoreWidget(
                          score: teamBScore,
                          teamName: teamBName,
                          onScoreChanged: (score) {
                            setState(() => teamBScore = score < 0 ? 0 : score);
                            _updateScore();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            if (_latestActivityId == null)
              TextButton(
                onPressed: _startMatch,
                child: const Column(
                  children: [
                    Text(
                      'Start football match ⚽️',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '(start live notification)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

            if (_latestActivityId != null)
              TextButton(
                onPressed: _stopMatch,
                child: const Column(
                  children: [
                    Text('Stop match ✋', style: TextStyle(fontSize: 18)),
                    Text('(end notification)'),
                  ],
                ),
              ),

            TextButton(
              onPressed: () async {
                final supported = await _liveActivitiesPlugin
                    .areActivitiesEnabled();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        supported
                            ? 'Supported on this device'
                            : 'Not supported',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Is live activities supported?'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startMatch() async {
    if (!_notificationPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission required')),
      );
      return;
    }

    await _liveActivitiesPlugin.endAllActivities();

    teamAScore = 0;
    teamBScore = 0;

    final data = {
      'matchName': 'World Cup Final ⚽️',
      'teamAName': teamAName,
      'teamBName': teamBName,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'matchStartDate': DateTime.now().millisecondsSinceEpoch,
      // Optional: send image URLs instead of assets (easier on Android)
      'teamAImageUrl':
          'https://www.pngkey.com/detail/u2e6q8q8i1y3q8u2_psg-logo-png-transparent-psg/?utm_source=chatgpt.com', // replace with real URLs
      'teamBImageUrl':
          'https://hdpng.com/chelsea-logo-png/chelsea-logo-png-chelsea-fc-logo-png-and-vector-logo-img-4096x4096-178729?utm_source=chatgpt.com',
    };

    final activityId = await _liveActivitiesPlugin.createActivity(
      'football_match',
      data,
    );
    print("Activity ID: $activityId");

    setState(() => _latestActivityId = activityId);
  }

  Future<void> _updateScore() async {
    if (_latestActivityId == null) return;

    final updatedData = {
      'teamAName': teamAName,
      'teamBName': teamBName,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'matchStartDate':
          DateTime.now().millisecondsSinceEpoch, // keep time running
    };

    await _liveActivitiesPlugin.updateActivity(_latestActivityId!, updatedData);
  }

  Future<void> _stopMatch() async {
    await _liveActivitiesPlugin.endAllActivities();
    setState(() => _latestActivityId = null);
  }
}
