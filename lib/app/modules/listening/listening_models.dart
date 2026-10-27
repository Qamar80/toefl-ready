/// Models for the TOEFL iBT 2026 Listening practice.
/// One test = Part 1 (short "Choose a Response" sentences)
///          + Part 2 (conversations / announcements with several questions each).

class ListeningQuestion {
  /// Path inside the `assets/` folder, e.g. `audios/t1/t1s1.mp3`.
  /// (audioplayers' AssetSource adds the `assets/` prefix by itself.)
  final String audio;

  /// Part 1: what the speaker says. Part 2: the question text.
  final String sentence;
  final List<String> options;

  /// 0-based index of the correct option in [options].
  final int answer;

  // ───── Part 2 (conversation / announcement) fields ─────
  /// True when several questions share one audio file.
  final bool isGroup;

  /// "Conversation" or "Announcement" (null for Part 1).
  final String? groupLabel;

  /// Full text of the audio. Shown on the result page and if audio fails.
  final String? script;

  /// True for the first question of a group (the audio plays here).
  final bool groupStart;

  /// Position of this question inside its group (1-based) and group size.
  final int groupPos;
  final int groupSize;

  const ListeningQuestion({
    required this.audio,
    required this.sentence,
    required this.options,
    required this.answer,
    this.isGroup = false,
    this.groupLabel,
    this.script,
    this.groupStart = false,
    this.groupPos = 1,
    this.groupSize = 1,
  });

  String get answerText => options[answer];

  /// What to show when the audio cannot be played.
  String get transcript => script ?? sentence;

  /// Title used in the app bar.
  String get sectionTitle => isGroup ? (groupLabel ?? 'Listening') : 'Choose a Response';
}

class ListeningTest {
  final String id;
  final int number;
  final List<ListeningQuestion> questions;

  const ListeningTest({
    required this.id,
    required this.number,
    required this.questions,
  });
}

/// Practice estimate only (NOT an official ETS score).
class ListeningScoring {
  static double estimate({required int got, required int total}) {
    if (total <= 0) return 1;
    final b = 1 + (got / total) * 5;
    return ((b.clamp(1.0, 6.0)) * 2).round() / 2;
  }
}

class ListeningAttempt {
  final int no;
  final String testId;
  final double band;
  final int got, total;

  /// Chosen option (index into the question's `options`) per question, -1 = not answered.
  final List<int> answers;
  final int seconds;
  final int ts;

  const ListeningAttempt({
    required this.no,
    required this.testId,
    required this.band,
    required this.got,
    required this.total,
    required this.answers,
    required this.seconds,
    required this.ts,
  });

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(ts);

  Map<String, dynamic> toJson() => {
    'no': no,
    'id': testId,
    'band': band,
    'got': got,
    'tot': total,
    'ans': answers,
    'sec': seconds,
    'ts': ts,
  };

  factory ListeningAttempt.fromJson(Map<String, dynamic> j) => ListeningAttempt(
    no: j['no'] as int,
    testId: (j['id'] ?? '') as String,
    band: (j['band'] as num).toDouble(),
    got: (j['got'] ?? 0) as int,
    total: (j['tot'] ?? 0) as int,
    answers: List<int>.from((j['ans'] ?? const []) as List),
    seconds: (j['sec'] ?? 0) as int,
    ts: (j['ts'] ?? 0) as int,
  );
}