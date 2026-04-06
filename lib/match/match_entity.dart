class MatchEntity {
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;

  MatchEntity({
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'teamAName': teamAName,
      'teamBName': teamBName,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'matchStartDate': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
