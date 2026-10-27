/// Models for the TOEFL iBT 2026 Speaking section:
/// 1 x Listen and Repeat (7 sentences) + 1 x Take an Interview (4 questions).

class InterviewQ {
  final String question;
  final String sample; // model answer (about 45 seconds)
  const InterviewQ(this.question, this.sample);
}

class SpeakingTest {
  final String id;
  final int number;
  final String scene; // setting for Listen and Repeat
  final List<String> repeats; // 7 sentences, getting longer
  final String interviewer;
  final String topic;
  final List<InterviewQ> questions; // 4

  const SpeakingTest({
    required this.id,
    required this.number,
    required this.scene,
    required this.repeats,
    required this.interviewer,
    required this.topic,
    required this.questions,
  });
}

/// Practice estimate only (NOT an official ETS score).
class SpeakingScoring {
  /// [repeat] = average accuracy 0..1, [interview] = average score 0..5.
  /// Use -1 when not checked yet.
  static double estimate({required double repeat, required double interview}) {
    var w = 0.0, s = 0.0;
    if (repeat >= 0) {
      w += .40;
      s += .40 * repeat;
    }
    if (interview >= 0) {
      w += .60;
      s += .60 * interview / 5;
    }
    if (w == 0) return 1;
    final b = 1 + (s / w) * 5;
    return ((b.clamp(1.0, 6.0)) * 2).round() / 2;
  }
}

class SpeakingAttempt {
  final int no;
  final String testId;
  final double band;
  final double repeatAcc; // 0..1
  final double interviewScore; // 0..5, -1 = not checked yet
  final List<String> repeatHeard;
  final List<String> interviewText;
  final List<int> interviewSecs;
  final int seconds;
  final int ts;

  const SpeakingAttempt({
    required this.no,
    required this.testId,
    required this.band,
    required this.repeatAcc,
    required this.interviewScore,
    required this.repeatHeard,
    required this.interviewText,
    required this.interviewSecs,
    required this.seconds,
    required this.ts,
  });

  SpeakingAttempt copyWith({double? band, double? interviewScore}) => SpeakingAttempt(
    no: no,
    testId: testId,
    band: band ?? this.band,
    repeatAcc: repeatAcc,
    interviewScore: interviewScore ?? this.interviewScore,
    repeatHeard: repeatHeard,
    interviewText: interviewText,
    interviewSecs: interviewSecs,
    seconds: seconds,
    ts: ts,
  );

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(ts);

  Map<String, dynamic> toJson() => {
    'no': no,
    'id': testId,
    'band': band,
    'ra': repeatAcc,
    'is': interviewScore,
    'rh': repeatHeard,
    'it': interviewText,
    'isec': interviewSecs,
    'sec': seconds,
    'ts': ts,
  };

  factory SpeakingAttempt.fromJson(Map<String, dynamic> j) => SpeakingAttempt(
    no: j['no'] as int,
    testId: (j['id'] ?? '') as String,
    band: (j['band'] as num).toDouble(),
    repeatAcc: ((j['ra'] ?? 0) as num).toDouble(),
    interviewScore: ((j['is'] ?? -1) as num).toDouble(),
    repeatHeard: ((j['rh'] ?? []) as List).map((e) => e.toString()).toList(),
    interviewText: ((j['it'] ?? []) as List).map((e) => e.toString()).toList(),
    interviewSecs: ((j['isec'] ?? []) as List).map((e) => (e as num).toInt()).toList(),
    seconds: (j['sec'] ?? 0) as int,
    ts: (j['ts'] ?? 0) as int,
  );
}