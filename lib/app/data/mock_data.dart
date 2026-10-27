import 'package:flutter/material.dart';
import 'package:toefl_pro/app/core/theme/app_colors.dart';
import 'package:toefl_pro/app/routes/app_routes.dart';
import 'models/models.dart';

class MockData {

  static const skills = <Skill>[
    Skill('Reading', Icons.menu_book_rounded, .50, AppColors.teal600, Routes.reading,
        assetImage: 'assets/images/reading.png'),
    Skill('Listening', Icons.headphones_rounded, .48, AppColors.indigo600, Routes.listening,
        assetImage: 'assets/images/listening.png'),
    Skill('Speaking', Icons.mic_rounded, .30, AppColors.amber, Routes.speaking,
        assetImage: 'assets/images/speaking.png'),
    Skill('Writing', Icons.edit_rounded, .22, AppColors.rose, Routes.writing,
        assetImage: 'assets/images/writing.png'),
  ];


  static const readingPassage =
      '[A] Cities around the world are rethinking where their food comes from. Rooftop gardens, '
      'vertical farms and community plots now supply fresh produce to neighbourhoods that once '
      'relied entirely on long-distance transport.\n\n'
      '[B] Supporters argue that growing food close to consumers reduces emissions and food waste, '
      'while critics point to high energy costs for indoor lighting and the limited range of crops '
      'that can be grown profitably.';

  static const readingQuestions = <McqQuestion>[
    McqQuestion('According to paragraph B, what is one main criticism of urban farming?', [
      'It produces food of lower quality',
      'Indoor systems require a lot of energy',
      'It increases transport emissions',
      'Consumers distrust local produce',
    ], 1, 'Paragraph B says critics point to high energy costs for indoor lighting.'),
    McqQuestion('The word "relied" in paragraph A is closest in meaning to', [
      'depended', 'argued', 'decided', 'refused'
    ], 0, '"Relied on" means depended on.'),
    McqQuestion('What do supporters say about local food?', [
      'It is cheaper to store',
      'It reduces emissions and waste',
      'It grows faster',
      'It needs no energy'
    ], 1, 'Supporters argue it reduces emissions and food waste.'),
  ];

  static const listeningQuestions = <McqQuestion>[
    McqQuestion('Why does the professor mention coral bleaching?', [
      'To describe a recent field trip',
      'To illustrate how temperature affects reefs',
      'To show an example of species adaptation',
    ], 1, 'She uses bleaching to show temperature sensitivity of reefs.'),
  ];

  static const mockQuestions = <McqQuestion>[
    McqQuestion('The writer suggests that the main benefit of bilingual education is that it…', [
      'improves performance in mathematics',
      'delays the onset of memory decline',
      'strengthens attention and task-switching',
      'helps students learn a third language'
    ], 2, 'The passage links bilingualism with executive control.'),
    McqQuestion('The word "mitigate" in paragraph 3 is closest in meaning to', [
      'intensify', 'reduce the severity of', 'ignore', 'predict'
    ], 1, '"Mitigate" means to make less severe.'),
    McqQuestion('Which sentence best expresses the essential information in the highlighted text?', [
      'Rainfall patterns are stable.',
      'Climate shifts altered farming habits.',
      'Farmers rejected new crops.',
      'Rivers dried up completely.'
    ], 1, 'Option B keeps the core idea without distortion.'),
    McqQuestion('What can be inferred about the author\'s attitude?', [
      'Dismissive', 'Cautiously optimistic', 'Hostile', 'Indifferent'
    ], 1, 'The tone is hopeful but hedged.'),
    McqQuestion('Why does the author mention rooftop gardens?', [
      'To compare costs', 'To give an example of local supply', 'To criticise cities', 'To define farming'
    ], 1, 'Rooftop gardens exemplify local food supply.'),
    McqQuestion('According to the passage, vertical farms mainly use…', [
      'sunlight only', 'artificial lighting', 'no water', 'imported soil'
    ], 1, 'Indoor lighting is repeatedly mentioned.'),
  ];

  static const flashcards = <Flashcard>[
    Flashcard('ubiquitous', '/juːˈbɪk.wɪ.təs/', 'C1 level',
        'Present, appearing or found everywhere at the same time.',
        ['widespread', 'pervasive', 'omnipresent'],
        'Smartphones have become ubiquitous in modern classrooms.'),
    Flashcard('mitigate', '/ˈmɪt.ɪ.ɡeɪt/', 'C1 level',
        'To make something less harmful, serious or severe.',
        ['alleviate', 'reduce', 'lessen'], 'Trees help mitigate the effects of urban heat.'),
    Flashcard('infer', '/ɪnˈfɜːr/', 'B2 level',
        'To reach a conclusion from evidence and reasoning.',
        ['deduce', 'conclude', 'gather'], 'We can infer that the author supports the policy.'),
  ];

  static const mistakes = <Mistake>[
    Mistake('Reading · Q12', 'What does the word "mitigate" in paragraph C most closely mean?',
        'B · intensify', 'D · reduce the severity of',
        'The text says new barriers were built "to mitigate flood damage" — they make the damage less severe.'),
    Mistake('Listening · Q7', 'According to the speaker, the library\'s new opening hours start…',
        'Not answered', 'next Monday', 'The speaker says the new schedule begins on Monday.'),
    Mistake('Grammar · Q3', 'Choose the correct form: "If I ___ earlier, I would have caught the bus."',
        'A · leave', 'C · had left', 'Third conditional requires past perfect in the if-clause.'),
  ];
}
