import 'package:shared_preferences/shared_preferences.dart';

class HighScoreRepository {
  static const String _timeKeyPrefix = 'highscore_time_';
  static const String _wordsKeyPrefix = 'highscore_words_';

  Future<double> getHighScore(String modeName, int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(modeName, amount);
    return prefs.getDouble(key) ?? 0.0;
  }

  Future<void> saveHighScore(String modeName, int amount, double wpm) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(modeName, amount);
    await prefs.setDouble(key, wpm);
  }

  String _getKey(String modeName, int amount) {
    if (modeName == 'time') {
      return '$_timeKeyPrefix$amount';
    } else {
      return '$_wordsKeyPrefix$amount';
    }
  }
}
