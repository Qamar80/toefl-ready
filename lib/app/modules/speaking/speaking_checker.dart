import 'dart:convert';
import 'dart:io';
import 'dart:math';

class SpeechIssue {
  final int offset, length;
  final String message, type; // grammar | spelling
  final List<String> fixes;
  const SpeechIssue(this.offset, this.length, this.message, this.type, [this.fixes = const []]);
  String snippet(String t) => t.substring(offset, min(t.length, offset + length));
}

class SpeechLine {
  final String label, note;
  final double got, max;
  const SpeechLine(this.label, this.got, this.max, this.note);
}

class WordMark {
  final String word;
  final bool ok;
  const WordMark(this.word, this.ok);
}

/// Result for one Listen and Repeat sentence.
class RepeatCheck {
  final double accuracy; // 0..1
  final List<WordMark> target;
  final List<String> extra; // words you said that are not in the sentence
  final String heard;
  const RepeatCheck(this.accuracy, this.target, this.extra, this.heard);
}

/// Result for one interview answer.
class InterviewCheck {
  final double score; // 0..5 (steps of 0.5)
  final List<SpeechLine> lines;
  final List<SpeechIssue> issues;
  final bool online;
  final int words;
  final String text; // transcript with capital letters and a final period added
  final double wpm;
  const InterviewCheck(this.score, this.lines, this.issues, this.online, this.words, this.text, this.wpm);
}

/// Practice checker (NOT official ETS scoring).
class SpeakingChecker {
  // ───────────── Listen and Repeat ─────────────
  static const _digits = {
    '0': 'zero', '1': 'one', '2': 'two', '3': 'three', '4': 'four', '5': 'five', '6': 'six',
    '7': 'seven', '8': 'eight', '9': 'nine', '10': 'ten', '11': 'eleven', '12': 'twelve',
    '13': 'thirteen', '14': 'fourteen', '15': 'fifteen', '16': 'sixteen', '17': 'seventeen',
    '18': 'eighteen', '19': 'nineteen', '20': 'twenty',
  };

  static String _w(String w) {
    final x = w.toLowerCase().replaceAll('’', "'").replaceAll(RegExp(r"[^a-z0-9']"), '');
    return _digits[x] ?? x;
  }

  static List<String> _tok(String s) {
    final t = s
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll("can't", 'can not')
        .replaceAll('cannot', 'can not')
        .replaceAll("won't", 'will not')
        .replaceAll("n't", ' not')
        .replaceAll("'ll", ' will')
        .replaceAll("'re", ' are')
        .replaceAll("'m", ' am')
        .replaceAll("'ve", ' have')
        .replaceAll("'d", ' would');
    return t.split(RegExp(r'\s+')).map(_w).where((w) => w.isNotEmpty).toList();
  }

  static RepeatCheck checkRepeat(String target, String heard) {
    final display = target.trim().split(RegExp(r'\s+'));
    final t = display.map(_w).toList();
    final h = _tok(heard);
    final n = t.length, m = h.length;

    final dp = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        dp[i][j] = t[i - 1] == h[j - 1] ? dp[i - 1][j - 1] + 1 : max(dp[i - 1][j], dp[i][j - 1]);
      }
    }
    final okT = List<bool>.filled(n, false);
    final usedH = List<bool>.filled(m, false);
    var i = n, j = m;
    while (i > 0 && j > 0) {
      if (t[i - 1] == h[j - 1]) {
        okT[i - 1] = true;
        usedH[j - 1] = true;
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }
    final matched = okT.where((e) => e).length;
    final extra = [for (var k = 0; k < m; k++) if (!usedH[k]) h[k]];
    final acc = n == 0 ? 0.0 : ((matched - extra.length * .25) / n).clamp(0.0, 1.0).toDouble();
    return RepeatCheck(acc, [for (var k = 0; k < n; k++) WordMark(display[k], okT[k])], extra, heard.trim());
  }

  // ───────────── Interview ─────────────
  static String prepare(String raw) {
    var t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) return t;
    t = t.replaceAllMapped(RegExp(r"\bi\b(?=[ ,.!?']|$)"), (m) => 'I');
    t = t[0].toUpperCase() + t.substring(1);
    if (!RegExp(r'[.!?]$').hasMatch(t)) t += '.';
    return t;
  }

  static Future<InterviewCheck> checkInterview(String raw, String question, int seconds, double conf) async {
    final words = _wc(raw);
    if (words == 0) {
      return const InterviewCheck(0, [
        SpeechLine('Length', 0, .75, 'No speech was recorded'),
        SpeechLine('Pace', 0, .75, 'No speech was recorded'),
        SpeechLine('Answers the question', 0, 1, 'No speech was recorded'),
        SpeechLine('Reasons & examples', 0, 1, 'No speech was recorded'),
        SpeechLine('Grammar', 0, 1, 'No speech was recorded'),
        SpeechLine('Clarity', 0, .5, 'No speech was recorded'),
      ], [], false, 0, '', 0);
    }
    final text = prepare(raw);
    final lower = text.toLowerCase();
    final wpm = words * 60 / max(seconds, 1);

    final lenP = (words >= 55 && words <= 140) ? .75 : (words >= 35 && words <= 170) ? .4 : 0.0;
    final lenLine = SpeechLine('Length', lenP, .75,
        '$words words (aim for 55–140) · ${words < 55 ? 'too short' : words > 140 ? 'a bit long' : 'good'}');

    final paceP = (wpm >= 90 && wpm <= 180) ? .75 : (wpm >= 65 && wpm <= 210) ? .4 : 0.0;
    final paceLine = SpeechLine('Pace', paceP, .75,
        '${wpm.round()} words/min · ${wpm < 90 ? 'a little slow' : wpm > 180 ? 'a little fast' : 'natural pace'}');

    final hit = _keywords(question.toLowerCase()).where(_stems(lower).contains).length;
    final rel = hit >= 2 ? 1.0 : hit == 1 ? .5 : 0.0;
    final relLine = SpeechLine('Answers the question', rel, 1,
        rel >= 1 ? 'On topic' : 'Use words from the question and answer it directly');

    const markers = [
      'because', 'for example', 'for instance', 'such as', 'since ', 'as a result', 'also',
      'however', 'first', 'second', 'finally', 'in addition', 'moreover', 'another reason',
      'on the other hand',
    ];
    final m = markers.where(lower.contains).length;
    final dev = m >= 3 ? 1.0 : m == 2 ? .7 : m == 1 ? .4 : 0.0;
    final devLine = SpeechLine('Reasons & examples', dev, 1,
        m == 0 ? 'Add a reason or an example (because, for example…)' : '$m linking/reason phrases found');

    final g = await _grammar(text);
    final per100 = g.$1.length * 100 / max(words, 1);
    final gp = per100 <= 2 ? 1.0 : per100 <= 4 ? .8 : per100 <= 6 ? .6 : per100 <= 9 ? .4 : per100 <= 13 ? .2 : 0.0;
    final gramLine = SpeechLine('Grammar', gp, 1,
        g.$1.isEmpty ? 'No mistakes found' : '${g.$1.length} possible mistake${g.$1.length == 1 ? '' : 's'}');

    final cp = conf < 0 ? .35 : conf >= .85 ? .5 : conf >= .7 ? .35 : conf >= .5 ? .2 : 0.0;
    final clarLine = SpeechLine('Clarity', cp, .5,
        conf < 0 ? 'This device does not report confidence (neutral score)' : '${(conf * 100).round()}% recognized with confidence');

    final lines = [lenLine, paceLine, relLine, devLine, gramLine, clarLine];
    final sum = lines.fold<double>(0, (a, l) => a + l.got);
    final score = ((sum * 2).round() / 2).clamp(0.0, 5.0).toDouble();
    return InterviewCheck(score, lines, g.$1, g.$2, words, text, wpm);
  }

  // ───────────── helpers ─────────────
  static const _stop = {
    'the', 'and', 'for', 'that', 'this', 'with', 'your', 'you', 'what', 'when', 'where', 'which', 'will',
    'should', 'would', 'could', 'about', 'from', 'have', 'been', 'they', 'them', 'their', 'there', 'some',
    'many', 'much', 'more', 'than', 'then', 'into', 'also', 'make', 'sure', 'say', 'does', 'think', 'please',
  };

  static String _stem(String w) => w.length > 5 ? w.substring(0, 5) : w;

  static Set<String> _stems(String lower) =>
      RegExp(r"[a-z']+").allMatches(lower).map((m) => _stem(m.group(0)!)).toSet();

  static Set<String> _keywords(String lower) => RegExp(r'[a-z]+')
      .allMatches(lower)
      .map((m) => m.group(0)!)
      .where((w) => w.length > 3 && !_stop.contains(w))
      .map(_stem)
      .toSet();

  static int _wc(String s) {
    final t = s.trim();
    return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
  }

  // ───────────── grammar: LanguageTool, then offline fallback ─────────────
  static Future<(List<SpeechIssue>, bool)> _grammar(String text) async {
    final online = await _languageTool(text);
    if (online != null) return (online, true);
    return (_local(text), false);
  }

  // Speech has no commas or typography, so these categories are ignored.
  static const _skipCat = {
    'CASING', 'PUNCTUATION', 'TYPOGRAPHY', 'STYLE', 'REDUNDANCY', 'PLAIN_ENGLISH',
    'WIKIPEDIA', 'COLLOQUIALISMS', 'CREATIVE_WRITING',
  };

  static Future<List<SpeechIssue>?> _languageTool(String text) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final req = await client.postUrl(Uri.parse('https://api.languagetool.org/v2/check'));
      req.headers.contentType = ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
      req.write('language=en-US&text=${Uri.encodeQueryComponent(text)}');
      final res = await req.close().timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(await res.transform(utf8.decoder).join()) as Map;
      final out = <SpeechIssue>[];
      for (final m in (data['matches'] as List)) {
        final rule = (m['rule'] ?? {}) as Map;
        final issueType = (rule['issueType'] ?? '').toString();
        final cat = ((rule['category'] ?? {}) as Map)['id']?.toString() ?? '';
        final ruleId = (rule['id'] ?? '').toString();
        if (issueType == 'style' || _skipCat.contains(cat)) continue;
        if (ruleId.contains('WHITESPACE') || ruleId.startsWith('UPPERCASE')) continue;
        final off = m['offset'] as int, len = m['length'] as int;
        if (len <= 0 || off + len > text.length) continue;
        final snippet = text.substring(off, off + len);
        if (issueType == 'misspelling' && RegExp(r'^[A-Z]').hasMatch(snippet)) continue;
        final fixes = [for (final r in (m['replacements'] as List).take(3)) r['value'] as String];
        out.add(SpeechIssue(
          off,
          len,
          (m['message'] ?? 'Possible mistake') as String,
          issueType == 'misspelling' ? 'spelling' : 'grammar',
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
    (RegExp(r'\b(\w+)\s+\1\b', caseSensitive: false), 'Repeated word.', ''),
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
    (RegExp(r'\ba (?!one|once|eu|uni|use|usu|ut)[aeio]\w*', caseSensitive: false),
    'Use "an" before a vowel sound.', 'an'),
    (RegExp(r'\ban (?![hH])[bcdfgjklmnpqrstvwxyz][a-z]+'), 'Use "a" before a consonant sound.', 'a'),
  ];

  static List<SpeechIssue> _local(String text) {
    final all = <SpeechIssue>[];
    for (final (re, msg, fix) in _rules) {
      for (final m in re.allMatches(text)) {
        if (m.end == m.start) continue;
        all.add(SpeechIssue(m.start, m.end - m.start, msg, 'grammar', fix.isEmpty ? const [] : [fix]));
      }
    }
    all.sort((a, b) => a.offset.compareTo(b.offset));
    final out = <SpeechIssue>[];
    var end = -1;
    for (final i in all) {
      if (i.offset >= end) {
        out.add(i);
        end = i.offset + i.length;
      }
    }
    return out;
  }
}