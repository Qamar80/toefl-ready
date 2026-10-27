import 'package:flutter/material.dart';

/*class Skill {
  final String name, route;
  final IconData icon;
  final double progress;
  final Color color;
  const Skill(this.name, this.icon, this.progress, this.color, this.route);
}*/

class Skill {
  final String name;
  final String route;
  final IconData? icon;
  final String? assetImage;
  final double progress;
  final Color color;

  const Skill(
      this.name,
      this.icon,
      this.progress,
      this.color,
      this.route, {
        this.assetImage,
      });
}



class McqQuestion {
  final String text, explanation;
  final List<String> options;
  final int answer;
  const McqQuestion(this.text, this.options, this.answer, this.explanation);
}

class Flashcard {
  final String word, phonetic, level, definition, example;
  final List<String> synonyms;
  const Flashcard(this.word, this.phonetic, this.level, this.definition, this.synonyms, this.example);
}

class Mistake {
  final String tag, question, yours, correct, explanation;
  const Mistake(this.tag, this.question, this.yours, this.correct, this.explanation);
}
