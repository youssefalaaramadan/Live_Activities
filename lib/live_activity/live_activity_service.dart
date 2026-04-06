import 'package:live_activities/live_activities.dart';
import 'package:live_activities_usecase/match/match_entity.dart';

// Service responsible for handling Live Activities
class LiveActivityService {
  // Plugin instance

  final LiveActivities _plugin = LiveActivities();
  // Initialize the plugin

  void init() {
    _plugin.init(appGroupId: '');
  }
  // Start a new match live activity

  Future<String?> startMatch(MatchEntity match) async {
    await _plugin.endAllActivities();
    // Prepare data to send to the live activity

    final data = {
      'matchName': 'World Cup Final ⚽️',
      ...match.toMap(),
      //later create seperate classes for ImageURls
      // Team logos
      'teamAImageUrl':
          'https://www.pngkey.com/detail/u2e6q8q8i1y3q8u2_psg-logo-png-transparent-psg/?utm_source=chatgpt.com',
      'teamBImageUrl':
          'https://hdpng.com/chelsea-logo-png/chelsea-logo-png-chelsea-fc-logo-png-and-vector-logo-img-4096x4096-178729?utm_source=chatgpt.com',
    };
    // Create and return activity ID

    return await _plugin.createActivity('football_match', data);
  }
  // Update an existing match activity

  Future<void> updateMatch(String id, MatchEntity match) async {
    await _plugin.updateActivity(id, match.toMap());
  }
  // Stop all live activities

  Future<void> stopMatch() async {
    await _plugin.endAllActivities();
  }
  // Check if live activities are supported on the device

  Future<bool> isSupported() async {
    return await _plugin.areActivitiesEnabled();
  }
  // Dispose plugin resources

  void dispose() {
    _plugin.dispose();
  }
}
