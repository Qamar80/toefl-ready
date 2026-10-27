import 'dart:math';

enum TaskType { completeWords, dailyLife, academic }

/// Multiple-choice item. Authoring convention: option 0 is the correct one;
/// options are shuffled every time a module is built.
class McqItem {
  final String type;
  final String text;
  final List<String> options;
  final int correct;
  final String explanation;

  const McqItem({
    required this.type,
    required this.text,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  McqItem shuffled(Random r) {
    final idx = List<int>.generate(options.length, (i) => i)..shuffle(r);
    return McqItem(
      type: type,
      text: text,
      options: [for (final i in idx) options[i]],
      correct: idx.indexOf(correct),
      explanation: explanation,
    );
  }
}

/// A piece of a Complete-the-Words paragraph: plain text or a blank.
class CtwPart {
  final String text;
  final String? prefix; // letters shown
  final String? missing; // letters the student types
  const CtwPart.text(this.text)
      : prefix = null,
        missing = null;
  const CtwPart.blank(String p, String m)
      : text = '',
        prefix = p,
        missing = m;
  bool get isBlank => missing != null;
}

class ReadingTask {
  final String id;
  final TaskType type;
  final int level; // 1 easy, 2 medium, 3 hard
  final String title;
  final String kind; // e.g. Email, Notice, Biology
  final String body; // CTW: words in {braces} become blanks
  final List<McqItem> questions;

  ReadingTask({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.kind,
    required this.body,
    this.questions = const [],
  });

  static final _re = RegExp(r'\{([A-Za-z]+)\}');

  /// Complete-the-Words: the first half of each marked word is shown,
  /// the second half is missing (like the real test).
  List<CtwPart> get parts {
    final out = <CtwPart>[];
    var last = 0;
    for (final m in _re.allMatches(body)) {
      if (m.start > last) out.add(CtwPart.text(body.substring(last, m.start)));
      final w = m.group(1)!;
      final keep = (w.length + 1) ~/ 2;
      out.add(CtwPart.blank(w.substring(0, keep), w.substring(keep)));
      last = m.end;
    }
    if (last < body.length) out.add(CtwPart.text(body.substring(last)));
    return out;
  }

  int get blankCount => parts.where((p) => p.isBlank).length;
  int get points => type == TaskType.completeWords ? blankCount : questions.length;
  int get wordCount => body.split(RegExp(r'\s+')).length;

  ReadingTask shuffled(Random r) => ReadingTask(
    id: id,
    type: type,
    level: level,
    title: title,
    kind: kind,
    body: body,
    questions: [for (final q in questions) q.shuffled(r)],
  );
}
class AttemptResult {
  final int no;
  final double band;
  final int m1Score, m1Total, m2Score, m2Total;
  final bool hard;
  final int seconds;
  final int ts;                          // when it was finished (ms since epoch)
  final Map<String, List<int>> byType;   // TaskType.name -> [got, max]

  const AttemptResult({
    required this.no,
    required this.band,
    required this.m1Score,
    required this.m1Total,
    required this.m2Score,
    required this.m2Total,
    required this.hard,
    required this.seconds,
    this.ts = 0,
    this.byType = const {},
  });

  int get score => m1Score + m2Score;
  int get total => m1Total + m2Total;
  double get percent => total == 0 ? 0 : score / total;
  DateTime? get date => ts == 0 ? null : DateTime.fromMillisecondsSinceEpoch(ts);

  Map<String, dynamic> toJson() => {
    'no': no, 'band': band,
    'm1s': m1Score, 'm1t': m1Total, 'm2s': m2Score, 'm2t': m2Total,
    'hard': hard, 'sec': seconds,
    'ts': ts, 'bt': byType,
  };

  factory AttemptResult.fromJson(Map<String, dynamic> j) => AttemptResult(
    no: j['no'] as int,
    band: (j['band'] as num).toDouble(),
    m1Score: j['m1s'] as int,
    m1Total: j['m1t'] as int,
    m2Score: j['m2s'] as int,
    m2Total: j['m2t'] as int,
    hard: j['hard'] as bool,
    seconds: j['sec'] as int,
    ts: (j['ts'] as int?) ?? 0,
    byType: {
      for (final e in ((j['bt'] ?? {}) as Map).entries)
        e.key as String: (e.value as List).cast<int>(),
    },
  );
}
/*
class AttemptResult {
  final int no;
  final double band;
  final int m1Score, m1Total, m2Score, m2Total;
  final bool hard;
  final int seconds;

  const AttemptResult({
    required this.no,
    required this.band,
    required this.m1Score,
    required this.m1Total,
    required this.m2Score,
    required this.m2Total,
    required this.hard,
    required this.seconds,
  });

  int get score => m1Score + m2Score;
  int get total => m1Total + m2Total;
  double get percent => total == 0 ? 0 : score / total;

  Map<String, dynamic> toJson() => {
    'no': no,
    'band': band,
    'm1s': m1Score,
    'm1t': m1Total,
    'm2s': m2Score,
    'm2t': m2Total,
    'hard': hard,
    'sec': seconds,
  };

  factory AttemptResult.fromJson(Map<String, dynamic> j) => AttemptResult(
    no: j['no'] as int,
    band: (j['band'] as num).toDouble(),
    m1Score: j['m1s'] as int,
    m1Total: j['m1t'] as int,
    m2Score: j['m2s'] as int,
    m2Total: j['m2t'] as int,
    hard: j['hard'] as bool,
    seconds: j['sec'] as int,
  );
}*/
