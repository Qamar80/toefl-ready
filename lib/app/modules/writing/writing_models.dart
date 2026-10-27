/// Models for the TOEFL iBT 2026 Writing section:
/// 10 x Build a Sentence  +  1 x Write an Email  +  1 x Academic Discussion.

/// One "Build a Sentence" item. [chunks] are stored in the CORRECT order and
/// are shuffled at runtime. [end] is the final punctuation mark.
class BuildItem {
  final String context; // the question / statement the sentence replies to
  final List<String> chunks;
  final String end;
  final List<String> alts; // other full sentences that are also correct

  const BuildItem({
    required this.context,
    required this.chunks,
    required this.end,
    this.alts = const [],
  });

  String get answer => '${chunks.join(' ')}$end';

  static String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  bool matches(List<String> placed) {
    final given = _norm('${placed.join(' ')}$end');
    if (given == _norm(answer)) return true;
    return alts.any((a) => _norm(a) == given);
  }
}

class EmailTask {
  final String to;
  final String subject;
  final String scenario;
  final List<String> points; // the 3 things the email must do
  final String sample;

  const EmailTask({
    required this.to,
    required this.subject,
    required this.scenario,
    required this.points,
    required this.sample,
  });
}

class DiscussionTask {
  final String field; // e.g. Sociology
  final String professor;
  final String question;
  final String s1Name, s1Text, s2Name, s2Text;
  final String sample;

  const DiscussionTask({
    required this.field,
    required this.professor,
    required this.question,
    required this.s1Name,
    required this.s1Text,
    required this.s2Name,
    required this.s2Text,
    required this.sample,
  });
}

class WritingTest {
  final String id;
  final int number;
  final List<BuildItem> builds;
  final EmailTask email;
  final DiscussionTask discussion;

  const WritingTest({
    required this.id,
    required this.number,
    required this.builds,
    required this.email,
    required this.discussion,
  });
}

/// Practice estimate only (NOT an official ETS score).
class WritingScoring {
  /// [email] / [disc] are automatic-check scores 0..5, or -1 when not checked yet.
  static double estimate({
    required int buildGot,
    required int buildTotal,
    required double email,
    required double disc,
  }) {
    var w = 0.0, s = 0.0;
    if (buildTotal > 0) {
      w += .30;
      s += .30 * buildGot / buildTotal;
    }
    if (email >= 0) {
      w += .35;
      s += .35 * email / 5;
    }
    if (disc >= 0) {
      w += .35;
      s += .35 * disc / 5;
    }
    if (w == 0) return 1;
    final b = 1 + (s / w) * 5;
    return ((b.clamp(1.0, 6.0)) * 2).round() / 2;
  }
}

class WritingAttempt {
  final int no;
  final String testId;
  final double band;
  final int buildGot, buildTotal;
  final int emailWords, discWords;
  final double selfEmail, selfDisc; // 0..5 (auto-checked), -1 = not checked yet
  final String emailText, discText;
  final int seconds;
  final int ts;

  const WritingAttempt({
    required this.no,
    required this.testId,
    required this.band,
    required this.buildGot,
    required this.buildTotal,
    required this.emailWords,
    required this.discWords,
    required this.selfEmail,
    required this.selfDisc,
    required this.emailText,
    required this.discText,
    required this.seconds,
    required this.ts,
  });

  WritingAttempt copyWith({double? band, double? selfEmail, double? selfDisc}) => WritingAttempt(
    no: no,
    testId: testId,
    band: band ?? this.band,
    buildGot: buildGot,
    buildTotal: buildTotal,
    emailWords: emailWords,
    discWords: discWords,
    selfEmail: selfEmail ?? this.selfEmail,
    selfDisc: selfDisc ?? this.selfDisc,
    emailText: emailText,
    discText: discText,
    seconds: seconds,
    ts: ts,
  );

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(ts);

  Map<String, dynamic> toJson() => {
    'no': no,
    'id': testId,
    'band': band,
    'bg': buildGot,
    'bt': buildTotal,
    'ew': emailWords,
    'dw': discWords,
    'se': selfEmail,
    'sd': selfDisc,
    'et': emailText,
    'dt': discText,
    'sec': seconds,
    'ts': ts,
  };

  factory WritingAttempt.fromJson(Map<String, dynamic> j) => WritingAttempt(
    no: j['no'] as int,
    testId: (j['id'] ?? '') as String,
    band: (j['band'] as num).toDouble(),
    buildGot: j['bg'] as int,
    buildTotal: j['bt'] as int,
    emailWords: (j['ew'] ?? 0) as int,
    discWords: (j['dw'] ?? 0) as int,
    selfEmail: ((j['se'] ?? -1) as num).toDouble(),
    selfDisc: ((j['sd'] ?? -1) as num).toDouble(),
    emailText: (j['et'] ?? '') as String,
    discText: (j['dt'] ?? '') as String,
    seconds: (j['sec'] ?? 0) as int,
    ts: (j['ts'] ?? 0) as int,
  );
}