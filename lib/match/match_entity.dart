class MatchEntity {
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  // Constructor to initialize match data

  MatchEntity({
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
  });

  // Converts the object into a Map (useful for databases/APIs)

  Map<String, dynamic> toMap() {
    return {
      'teamAName': teamAName,
      'teamBName': teamBName,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,

      // Stores the current time as match start date
      'matchStartDate': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
