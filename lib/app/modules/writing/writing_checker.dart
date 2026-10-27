import 'dart:convert';
import 'dart:io';
import 'dart:math';

class WritingIssue {
  final int offset, length;
  final String message, type; // type: grammar | spelling | punctuation
  final List<String> fixes;
  const WritingIssue(this.offset, this.length, this.message, this.type, [this.fixes = const []]);
  String snippet(String t) => t.substring(offset, min(t.length, offset + length));
}

class ScoreLine {
  final String label, note;
  final double got, max;
  const ScoreLine(this.label, this.got, this.max, this.note);
}

class WritingCheck {
  final double score; // 0..5 (steps of 0.5)
  final List<ScoreLine> lines;
  final List<WritingIssue> issues;
  final bool online; // true = LanguageTool, false = offline rules
  final int words;
  const WritingCheck(this.score, this.lines, this.issues, this.online, this.words);
}

/// Practice checker (NOT official ETS scoring).
class WritingChecker {
  // ───────────── public API ─────────────
  static Future<WritingCheck> checkEmail(String text, List<String> points) async {
    final words = _wc(text);
    if (words == 0) {
      return _empty(const [
        ScoreLine('Length', 0, 1, 'Nothing written'),
        ScoreLine('Format', 0, 1, 'No greeting or closing'),
        ScoreLine('Covers the 3 points', 0, 1.5, 'Nothing written'),
        ScoreLine('Grammar & spelling', 0, 1.5, 'Nothing written'),
      ]);
    }
    final lower = text.toLowerCase();

    final greet = RegExp(r'^\s*(dear|hi|hello|hey|good (morning|afternoon|evening))\b').hasMatch(lower);
    final tail = lower.length > 160 ? lower.substring(lower.length - 160) : lower;
    final close = RegExp(r'(regards|sincerely|thank you|thanks|best wishes|yours|cheers|\bbest\b|look forward)')
        .hasMatch(tail);
    final fmt = (greet ? .5 : 0.0) + (close ? .5 : 0.0);

    final stems = _stems(lower);
    var cover = 0.0;
    final missed = <int>[];
    for (var i = 0; i < points.length; i++) {
      final s = _pointScore(points[i].toLowerCase(), lower, stems);
      cover += s;
      if (s < .5) missed.add(i + 1);
    }
    cover = min(1.5, cover);

    final g = await _grammar(text);
    return _build([
      _length(words, 50, 140, 35, 180),
      ScoreLine('Format', fmt, 1,
          '${greet ? 'Greeting ✓' : 'No greeting'} · ${close ? 'Closing ✓' : 'No closing'}'),
      ScoreLine('Covers the 3 points', cover, 1.5,
          missed.isEmpty ? 'All points seem covered' : 'Check point ${missed.join(', ')} of the task'),
      _gramLine(g.$1, words),
    ], g.$1, g.$2, words);
  }

  static Future<WritingCheck> checkDiscussion(String text, String question, List<String> names) async {
    final words = _wc(text);
    if (words == 0) {
      return _empty(const [
        ScoreLine('Length', 0, 1, 'Nothing written'),
        ScoreLine('Responds to classmates', 0, 1, 'Nothing written'),
        ScoreLine('Reasons & examples', 0, 1, 'Nothing written'),
        ScoreLine('Answers the question', 0, .5, 'Nothing written'),
        ScoreLine('Grammar & spelling', 0, 1.5, 'Nothing written'),
      ]);
    }
    final lower = text.toLowerCase();

    final named = names.where((n) => lower.contains(n.toLowerCase())).length;
    final engage = min(1.0, named * .5);

    const markers = [
      'because', 'for example', 'for instance', 'such as', 'since ', 'therefore',
      'as a result', 'which means', 'so that', 'however', 'in addition', 'moreover',
    ];
    final m = markers.where(lower.contains).length;
    final reasons = m >= 3 ? 1.0 : m == 2 ? .7 : m == 1 ? .4 : 0.0;

    final qStems = _keywords(question.toLowerCase());
    final tStems = _stems(lower);
    final hit = qStems.where(tStems.contains).length;
    final rel = hit >= 3 ? .5 : hit >= 1 ? .25 : 0.0;

    final g = await _grammar(text);
    return _build([
      _length(words, 80, 160, 60, 200),
      ScoreLine('Responds to classmates', engage, 1,
          named == 0 ? 'Mention a classmate by name' : '$named of ${names.length} classmates mentioned'),
      ScoreLine('Reasons & examples', reasons, 1,
          m == 0 ? 'Add reasons (because, for example…)' : '$m linking/reason phrases found'),
      ScoreLine('Answers the question', rel, .5, rel >= .5 ? 'On topic' : 'Stay closer to the question'),
      _gramLine(g.$1, words),
    ], g.$1, g.$2, words);
  }

  // ───────────── scoring helpers ─────────────
  static WritingCheck _build(List<ScoreLine> lines, List<WritingIssue> issues, bool online, int words) {
    final sum = lines.fold<double>(0, (a, l) => a + l.got);
    final score = ((sum * 2).round() / 2).clamp(0.0, 5.0).toDouble();
    return WritingCheck(score, lines, issues, online, words);
  }

  static WritingCheck _empty(List<ScoreLine> l) => WritingCheck(0, l, const [], false, 0);

  static ScoreLine _length(int w, int lo, int hi, int softLo, int softHi) {
    final p = (w >= lo && w <= hi) ? 1.0 : (w >= softLo && w <= softHi) ? .5 : 0.0;
    final note = w < lo ? 'too short' : w > hi ? 'a bit long' : 'good';
    return ScoreLine('Length', p, 1, '$w words (aim for $lo–$hi) · $note');
  }

  static ScoreLine _gramLine(List<WritingIssue> issues, int words) {
    final per100 = issues.length * 100 / max(words, 1);
    final p = per100 <= 2 ? 1.5 : per100 <= 4 ? 1.2 : per100 <= 6 ? .9 : per100 <= 9 ? .6 : per100 <= 13 ? .3 : 0.0;
    return ScoreLine('Grammar & spelling', p, 1.5,
        issues.isEmpty ? 'No mistakes found' : '${issues.length} possible mistake${issues.length == 1 ? '' : 's'}');
  }

  // ───────────── task coverage (approximate) ─────────────
  static const _stop = {
    'the', 'and', 'for', 'that', 'this', 'with', 'your', 'you', 'what', 'when', 'where', 'which', 'will',
    'should', 'would', 'could', 'about', 'from', 'have', 'been', 'they', 'them', 'their', 'there', 'some',
    'many', 'much', 'more', 'than', 'then', 'into', 'also', 'make', 'sure', 'say', 'does', 'think',
  };

  static Set<String> _stems(String lower) =>
      RegExp(r"[a-z']+").allMatches(lower).map((m) => _stem(m.group(0)!)).toSet();

  static String _stem(String w) => w.length > 5 ? w.substring(0, 5) : w;

  static Set<String> _keywords(String lower) => RegExp(r"[a-z]+")
      .allMatches(lower)
      .map((m) => m.group(0)!)
      .where((w) => w.length > 3 && !_stop.contains(w))
      .map(_stem)
      .toSet();

  static final _cues = <(RegExp, RegExp)>[
    (RegExp(r'explain|why|reason'), RegExp(r'because|since|due to|as i |so i ')),
    (RegExp(r'\bask\b|how (can|do)|when'),
    RegExp(r'\?|could you|would you|can you|please (tell|let)|i would like to know')),
    (RegExp(r'offer|volunteer'), RegExp(r"i can|i could|i will|i'd be|i would be|glad to|happy to|willing")),
    (RegExp(r'suggest|propose'),
    RegExp(r"could|why don't|how about|let's|let us|i suggest|propose|would it be possible|we can|we could")),
    (RegExp(r'remind'), RegExp(r'took|attended|last (semester|year)|class|course')),
    (RegExp(r'what you (need|would)|say what|kind of'), RegExp(r'would like|need|prefer|appreciate|hope')),
    (RegExp(r'describe|problem|state'),
    RegExp(r"problem|issue|not working|stopped|cannot|can't|broken|noisy|loud")),
  ];

  static double _pointScore(String point, String lower, Set<String> textStems) {
    final kw = _keywords(point);
    final hits = kw.where(textStems.contains).length;
    var cue = false;
    for (final (trigger, answer) in _cues) {
      if (trigger.hasMatch(point) && answer.hasMatch(lower)) {
        cue = true;
        break;
      }
    }
    if ((cue && hits >= 1) || (kw.isNotEmpty && hits / kw.length >= .5)) return .5;
    if (cue || hits >= 1) return .25;
    return 0;
  }

  // ───────────── grammar: LanguageTool, then offline fallback ─────────────
  static Future<(List<WritingIssue>, bool)> _grammar(String text) async {
    final online = await _languageTool(text);
    if (online != null) return (online, true);
    return (_local(text), false);
  }

  static Future<List<WritingIssue>?> _languageTool(String text) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.postUrl(Uri.parse('https://api.languagetool.org/v2/check'));
      req.headers.contentType = ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
      req.write('language=en-US&text=${Uri.encodeQueryComponent(text)}');
      final res = await req.close().timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(await res.transform(utf8.decoder).join()) as Map;
      final out = <WritingIssue>[];
      for (final m in (data['matches'] as List)) {
        final rule = (m['rule'] ?? {}) as Map;
        final issueType = (rule['issueType'] ?? '') as String;
        if (issueType == 'style') continue;
        final off = m['offset'] as int, len = m['length'] as int;
        if (len <= 0 || off + len > text.length) continue;
        final snippet = text.substring(off, off + len);
        // names like "Nguyen" are not real spelling mistakes
        if (issueType == 'misspelling' && RegExp(r'^[A-Z]').hasMatch(snippet)) continue;
        final fixes = [for (final r in (m['replacements'] as List).take(3)) r['value'] as String];
        out.add(WritingIssue(
          off,
          len,
          (m['message'] ?? 'Possible mistake') as String,
          issueType == 'misspelling'
              ? 'spelling'
              : issueType == 'typographical'
              ? 'punctuation'
              : 'grammar',
          fixes,
        ));
      }
      return out;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  static final _rules = <(RegExp, String, String)>[
    (RegExp(r"\bi\b(?=[ ,.!?']|$)"), 'Write "I" with a capital letter.', 'I'),
    (RegExp(r'\b(\w+)\s+\1\b', caseSensitive: false), 'Repeated word.', ''),
    (RegExp(r'\b(dont|cant|wont|doesnt|didnt|isnt|arent|wasnt|havent|im|ive)\b', caseSensitive: false),
    'Missing apostrophe.', ''),
    (RegExp(r"\b(he|she|it) (don't|do not)\b", caseSensitive: false), 'Use "doesn\'t" with he/she/it.', "doesn't"),
    (RegExp(r'\b(we|you|they) was\b|\bI is\b|\b(he|she|it) are\b', caseSensitive: false),
    'Subject–verb agreement error.', ''),
    (RegExp(r'\bmore (better|easier|faster|cheaper|bigger)\b', caseSensitive: false),
    'Do not use "more" with a comparative.', ''),
    (RegExp(r'\b(peoples|informations|advices|furnitures)\b', caseSensitive: false),
    'This noun is not used in the plural.', ''),
    (RegExp(r'\b(should|could|would) of\b', caseSensitive: false), 'Use "have", not "of".', 'have'),
    (RegExp(r'\bdiscuss about\b', caseSensitive: false), '"Discuss" does not need "about".', 'discuss'),
    (RegExp(r'\bam agree\b', caseSensitive: false), 'Say "I agree".', 'agree'),
    (RegExp(r'\balot\b', caseSensitive: false), 'Write "a lot" as two words.', 'a lot'),
    (RegExp(r'\ba (?!one|once|eu|uni|use|usu|ut)[aeio]\w*', caseSensitive: false),
    'Use "an" before a vowel sound.', 'an'),
    (RegExp(r'\ban (?![hH])[bcdfgjklmnpqrstvwxyz][a-z]+'), 'Use "a" before a consonant sound.', 'a'),
    (RegExp(r'(?<=[.!?]\s)[a-z]'), 'Start a sentence with a capital letter.', ''),
    (RegExp(r',(?=[A-Za-z])'), 'Add a space after the comma.', ', '),
  ];

  static List<WritingIssue> _local(String text) {
    final all = <WritingIssue>[];
    for (final (re, msg, fix) in _rules) {
      for (final m in re.allMatches(text)) {
        if (m.end == m.start) continue;
        all.add(WritingIssue(m.start, m.end - m.start, msg, 'grammar', fix.isEmpty ? const [] : [fix]));
      }
    }
    all.sort((a, b) => a.offset.compareTo(b.offset));
    final out = <WritingIssue>[];
    var end = -1;
    for (final i in all) {
      if (i.offset >= end) {
        out.add(i);
        end = i.offset + i.length;
      }
    }
    return out;
  }

  static int _wc(String s) {
    final t = s.trim();
    return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
  }
}