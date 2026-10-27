import 'dart:math';
import 'listening_models.dart';



class _Draft {
  final String sentence;
  final List<String> options;
  final int answer; // 0-based
  const _Draft(this.sentence, this.options, this.answer);
}

class _Group {
  final String file;
  final String label; // 'Conversation' or 'Announcement'
  final String script;
  final List<_Draft> questions;
  const _Group(this.file, this.label, this.script, this.questions);
}

_Draft _q(String sentence, List<String> options, int correctNumber) =>
    _Draft(sentence, options, correctNumber - 1);

_Draft _gq(String question, List<String> options, int correctNumber) =>
    _Draft(question, options, correctNumber - 1);

_Group _g(String file, String label, String script, List<_Draft> questions) =>
    _Group(file, label, script, questions);

ListeningTest _t(int n, List<_Draft> items, [List<_Group> groups = const []]) {
  final list = <ListeningQuestion>[
    for (var i = 0; i < items.length; i++)
      ListeningQuestion(
        audio: 'audios/t$n/t${n}s${i + 1}.mp3',
        sentence: items[i].sentence,
        options: items[i].options,
        answer: items[i].answer,
      ),
    for (final g in groups)
      for (var j = 0; j < g.questions.length; j++)
        ListeningQuestion(
          audio: 'audios/t$n/${g.file}',
          sentence: g.questions[j].sentence,
          options: g.questions[j].options,
          answer: g.questions[j].answer,
          isGroup: true,
          groupLabel: g.label,
          script: g.script,
          groupStart: j == 0,
          groupPos: j + 1,
          groupSize: g.questions.length,
        ),
  ];
  return ListeningTest(id: 'l$n', number: n, questions: list);
}

class ListeningBank {
  static int get maxTests => tests.length;

  static int get questionsPerTest => tests.isEmpty ? 0 : tests.first.questions.length;

  static ListeningTest? pick(Set<String> used, Random r) {
    final pool = tests.where((t) => !used.contains(t.id)).toList();
    if (pool.isEmpty) return null;
    return pool[r.nextInt(pool.length)];
  }

  static final List<ListeningTest> tests = [
    // ═══════════════════════════ TEST 1 ═══════════════════════════
    _t(
      1,

      [
        _q('When is your research presentation scheduled?', [
          'I have one next month.',
          "It's scheduled for next Thursday.",
          'The research was very interesting.',
          'I usually study in the library.',
        ], 2),
        _q('Have you finished reading the article?', [
          'It was published last year.',
          'Yes, I finished it last night.',
          'The library closes at six.',
          'I prefer reading novels.',
        ], 2),
        _q("Why don't we meet at the library?", [
          "It's on the second floor.",
          'I met him yesterday.',
          'That sounds like a good idea.',
          'The book is quite expensive.',
        ], 3),
        _q('How did your presentation go?', [
          'It went better than I expected.',
          'I have a presentation tomorrow.',
          'The professor is in his office.',
          'I prepared it on Monday.',
        ], 1),
        _q('Could you lend me your notes from class?', [
          'The class starts at nine.',
          "Of course, I'll bring them tomorrow.",
          'I took the bus to campus.',
          'My notes are about biology.',
        ], 2),
        _q('What time does the lecture begin?', [
          'It begins at ten thirty.',
          'The lecture was informative.',
          'In the main building.',
          'I attended it yesterday.',
        ], 1),
        _q('Did you manage to find the article online?', [
          'The internet is quite slow.',
          'I read it last week.',
          'Yes, I found it in the university database.',
          'The article was very long.',
        ], 3),
        _q('Would you mind opening the window?', [
          "It's raining outside.",
          'Not at all.',
          'The window is quite large.',
          'I opened the door earlier.',
        ], 2),
        _q('Why was the meeting postponed?', [
          'It lasted about an hour.',
          'The manager was unavailable.',
          'We met in the conference room.',
          'I prefer morning meetings.',
        ], 2),
        _q('Have you submitted your assignment yet?', [
          'The assignment was quite difficult.',
          'I submitted it this morning.',
          'The professor teaches mathematics.',
          'I have class every Monday.',
        ], 2),
      ],
      [
        _g(
          't1c1.mp3',
          'Conversation',
          'Emma: Hi, James. Have you started working on our biology project yet?\n\n'
              "James: I've collected some information, but I haven't finished the slides. I'm having trouble finding suitable images.\n\n"
              "Emma: Have you checked the university library's online database? It has some useful resources.\n\n"
              "James: Not yet. I'll take a look this afternoon. When should we finish the presentation?\n\n"
              'Emma: Our professor wants us to submit it by Friday morning.\n\n'
              'James: Friday morning? I thought we had until Monday.\n\n'
              "Emma: The deadline was changed during yesterday's lecture.\n\n"
              "James: I must have missed that. I'll finish my slides tonight, and we can review everything tomorrow.\n\n"
              "Emma: Great. Let's meet at the library at two o'clock.",
          [
            _gq('What are the students working on?', [
              'A history essay',
              'A biology project',
              'A research article',
              'A science examination',
            ], 2),
            _gq('What difficulty is James having?', [
              'Finding suitable images',
              'Understanding the professor',
              'Booking a library room',
              'Collecting laboratory equipment',
            ], 1),
            _gq('When is the project due?', [
              'Monday morning',
              'Thursday afternoon',
              'Friday morning',
              'Friday evening',
            ], 3),
            _gq('What will the students do tomorrow?', [
              'Submit the project',
              'Visit another university',
              'Meet their professor',
              'Review the presentation',
            ], 4),
          ],
        ),

        _g(
          't1c2.mp3',
          'Announcement',
          "Attention, students. Please be advised that the university library will close at six o'clock "
              'this Thursday due to scheduled maintenance. Students who need to borrow books should visit '
              "the circulation desk before five thirty. The library's online resources will remain available "
              "throughout the evening. The building is expected to reopen at eight o'clock on Friday morning. "
              'We apologize for any inconvenience and thank you for your cooperation.',
          [
            _gq('Why will the library close early on Thursday?', [
              'A public holiday',
              'Scheduled maintenance',
              'A staff meeting',
              'A university examination',
            ], 2),
            _gq('By what time should students visit the circulation desk?', [
              "Five o'clock",
              'Five thirty',
              "Six o'clock",
              "Eight o'clock",
            ], 2),
            _gq('What will remain available during the evening?', [
              'The computer laboratory',
              'The circulation desk',
              "The library's online resources",
              'The study rooms',
            ], 3),
            _gq('When is the library expected to reopen?', [
              "Thursday at six o'clock",
              "Thursday at eight o'clock",
              "Friday at six o'clock",
              "Friday at eight o'clock",
            ], 4),
          ],
        ),
        _g(
          't1c3.mp3',
          'Conversation',
          "Student: Good morning, Professor. Do you have a moment? I have a question about the assignment.\n\n"
              'Professor: Of course. What would you like to know?\n\n'
              "Student: I'm not sure how many academic sources we need to include in our research paper.\n\n"
              'Professor: You should use at least five reliable sources, including two academic journal articles.\n\n'
              "Student: I see. And when is the paper due?\n\n"
              'Professor: It\'s due next Monday. Please submit it through the online course portal.\n\n'
              'Student: Should we include a separate reference page?\n\n'
              'Professor: Yes, and make sure you follow the citation guidelines provided in the course materials.\n\n'
              "Student: Thank you, Professor. I'll review the instructions again.",
          [
            _gq('Why does the student speak to the professor?', [
              'To ask about a research assignment',
              'To request a course withdrawal',
              'To complain about a grade',
              'To arrange a class meeting',
            ], 1),
            _gq('How many sources must the student use at minimum?', [
              'Two',
              'Five',
              'Seven',
              'Ten',
            ], 2),
            _gq('When must the research paper be submitted?', [
              'This Friday',
              'Tomorrow morning',
              'Next Monday',
              'Next Wednesday',
            ], 3),
            _gq('How should the student submit the paper?', [
              'By postal mail',
              'In person at the office',
              'By email to a classmate',
              'Through the online course portal',
            ], 4),
          ],
        ),


        _g(
          't1c4.mp3',
          'Announcement',
          "Good morning, students. The university's annual career fair will take place next Wednesday "
              'in the main sports hall from ten in the morning until four in the afternoon. '
              'Representatives from more than twenty companies will attend the event. '
              'Students are encouraged to bring several copies of their résumés and dress professionally. '
              'A workshop on interview skills will begin at eleven thirty in Room 105. '
              'Admission is free for all currently enrolled students. '
              'Please register through the university website before Monday.',
          [
            _gq('Where will the career fair take place?', [
              'In the university library',
              'In the main sports hall',
              'In the student cafeteria',
              'In the administration building',
            ], 2),
            _gq('What are students encouraged to bring?', [
              'Their university textbooks',
              'Their student identification cards only',
              'Several copies of their résumés',
              'Letters from their professors',
            ], 3),
            _gq('When will the interview skills workshop begin?', [
              '10:00 a.m.',
              '11:00 a.m.',
              '12:30 p.m.',
              '11:30 a.m.',
            ], 4),
            _gq('How can students register for the career fair?', [
              'Through the university website',
              'By calling each company',
              'At the sports hall on Wednesday',
              'By emailing their professors',
            ], 1),
          ],
        ),

        _g(
          't1c5.mp3',
          'Conversation',
          "Sarah: Hey, Daniel. Have you decided which elective course you're going to take next semester?\n\n"
              "Daniel: Not yet. I'm thinking about taking an introductory psychology course, but I'm worried it might be too difficult.\n\n"
              'Sarah: My friend took it last semester. She said the professor explains everything clearly and gives practical examples.\n\n'
              'Daniel: That sounds helpful. How many assignments do students have to complete?\n\n'
              "Sarah: There are two major assignments and a final examination. There's also a short presentation near the end of the semester.\n\n"
              'Daniel: I see. I need to check whether it conflicts with my programming class.\n\n'
              'Sarah: You can find the timetable on the university website.\n\n'
              "Daniel: Good idea. I'll check it tonight before registering.",
          [
            _gq('Which course is Daniel considering taking?', [
              'Advanced mathematics',
              'Introductory psychology',
              'Computer networking',
              'Academic writing',
            ], 2),
            _gq('What does Sarah say about the professor?', [
              'The professor gives very difficult examinations.',
              'The professor assigns weekly essays.',
              'The professor explains concepts clearly.',
              'The professor rarely attends class.',
            ], 3),
            _gq('What is one requirement of the course?', [
              'A research internship',
              'A group trip',
              'Three laboratory experiments',
              'A short presentation',
            ], 4),
            _gq('What will Daniel do before registering?', [
              'Check the university timetable',
              'Speak to his programming teacher',
              'Buy a psychology textbook',
              'Visit the admissions office',
            ], 1),
          ],
        ),

        _g(
          't1c6.mp3',
          'Conversation',
          'Emily: Hi, Mark. Did you attend the economics lecture yesterday?\n\n'
              'Mark: No, I was sick and had to stay home. Did the professor introduce anything important?\n\n'
              'Emily: Yes, she explained the topics for our next examination and gave us a reading assignment.\n\n'
              'Mark: Could you send me a picture of the assignment details?\n\n'
              "Emily: Sure. I'll send them to you this afternoon.\n\n"
              'Mark: Thanks. Do you know when the examination is scheduled?\n\n'
              "Emily: It's on the twenty-second of October, so we still have some time to prepare.",
          [
            _gq('Why did Mark miss the lecture?', [
              'He was sick.',
              'He had another examination.',
              'He went to the library.',
              'He forgot the schedule.',
            ], 1),
            _gq('What did the professor explain?', [
              'The university admission process',
              'Topics for the next examination',
              'How to register for courses',
              'The results of the last examination',
            ], 2),
            _gq('What will Emily do for Mark?', [
              'Borrow him a textbook',
              'Arrange a meeting',
              'Send him the assignment details',
              'Speak to the professor',
            ], 3),
          ],
        ),
        _g(
          't1c7.mp3',
          'Announcement',
          'Attention, students. The university cafeteria will be closed this Saturday for cleaning '
              'and equipment maintenance. Students can purchase meals from the temporary food stalls '
              'outside the student centre between eleven in the morning and three in the afternoon. '
              'Normal cafeteria services will resume on Sunday. We apologize for any inconvenience.',
          [
            _gq('Why will the cafeteria close?', [
              'A university holiday',
              'A staff training session',
              'Cleaning and equipment maintenance',
              'A student competition',
            ], 3),
            _gq('Where can students buy meals on Saturday?', [
              'Inside the library',
              'Outside the student centre',
              'In the sports hall',
              'At the main reception',
            ], 2),
            _gq('When will normal cafeteria services resume?', [
              'Friday',
              'Saturday evening',
              'Monday',
              'Sunday',
            ], 4),
          ],
        ),



        _g(
          't1c8.mp3',
          'Conversation',
          'Student: Professor, could I ask you something about the statistics course?\n\n'
              'Professor: Certainly. What is your question?\n\n'
              "Student: I'm struggling with the last two exercises. I understand the formulas, but I don't know which one to use for each problem.\n\n"
              'Professor: I recommend reviewing the examples from Chapter Four and attending the extra tutorial on Wednesday.\n\n'
              'Student: Is the tutorial open to all students?\n\n'
              'Professor: Yes. It begins at three o\'clock in Room 210.\n\n'
              "Student: Thank you. I'll review the chapter before attending.",
          [
            _gq('What difficulty is the student experiencing?', [
              'Understanding the lecture schedule',
              'Choosing the correct formulas',
              'Finding the classroom',
              'Completing a group presentation',
            ], 2),
            _gq('What does the professor recommend?', [
              'Dropping the course',
              'Buying another textbook',
              'Reviewing Chapter Four and attending a tutorial',
              'Submitting the exercises again',
            ], 3),
            _gq('Where will the tutorial take place?', [
              'Room 210',
              'Room 120',
              'The university library',
              'The computer laboratory',
            ], 1),
          ],
        ),


        _g(
          't1c9.mp3',
          'Conversation',
          'Lily: Excuse me, I borrowed a book last week, but I need to keep it for a few more days.\n\n'
              'Librarian: Let me check your account. The book is due tomorrow.\n\n'
              'Lily: Could I renew it online?\n\n'
              'Librarian: Yes, provided that nobody else has requested it. You can renew it through the library website.\n\n'
              'Lily: Great. Is there a limit to how many times I can renew a book?\n\n'
              'Librarian: You can renew it twice, for two weeks each time.\n\n'
              "Lily: Thank you. I'll renew it when I get home.",
          [
            _gq('Why does Lily speak to the librarian?', [
              'She wants to return a damaged book.',
              'She cannot find her library card.',
              'She wants to keep a borrowed book longer.',
              'She wants to reserve a study room.',
            ], 3),
            _gq('How can Lily renew the book?', [
              'Through the library website',
              'By sending a letter',
              'By calling her professor',
              'Through the university cafeteria',
            ], 1),
            _gq('How many times can Lily renew the book?', [
              'Once',
              'Twice',
              'Three times',
              'Four times',
            ], 2),
          ],
        ),

        _g(
          't1c10.mp3',
          'Announcement',
          'Good afternoon, students. Starting next Monday, the campus shuttle bus will follow a new schedule. '
              'Buses will leave the main gate every fifteen minutes between seven in the morning and nine at night. '
              'The route will also include a new stop at the sports center. Students who live in the North Dormitory '
              'should note that the last bus will depart at ten thirty on weekends. Printed schedules are available '
              'at the student services office, and a digital copy is posted on the university website.',
          [
            _gq('What is changing next Monday?', [
              'The dormitory rules',
              'The shuttle bus schedule',
              'The sports center hours',
              'The price of bus tickets',
            ], 2),
            _gq('How often will buses leave the main gate?', [
              'Every five minutes',
              'Every ten minutes',
              'Every fifteen minutes',
              'Every thirty minutes',
            ], 3),
            _gq('Which new stop will be added?', [
              'The library',
              'The North Dormitory',
              'The science building',
              'The sports center',
            ], 4),
            _gq('Where can students get a printed schedule?', [
              'At the student services office',
              'At the main gate',
              'At the sports center',
              'At the dormitory',
            ], 1),
          ],
        ),


        _g(
          't1c11.mp3',
          'Conversation',
          'Sarah: Mike, did you finish the chemistry lab report?\n\n'
              'Mike: Almost. I still need to write the conclusion. The results of the experiment were confusing.\n\n'
              'Sarah: I had the same problem. I asked Professor Allen about it, and she said the temperature readings were the main issue.\n\n'
              "Mike: Really? I didn't check the temperature carefully. Maybe I should repeat part of the experiment.\n\n"
              'Sarah: The lab is open until seven tonight. You could go after your class.\n\n'
              "Mike: Good idea. I'll go at five, and then I'll email the report to the professor tomorrow morning.\n\n"
              'Sarah: Perfect. Good luck!',
          [
            _gq('What does Mike still need to write?', [
              'The introduction',
              'The conclusion',
              'The title page',
              'The reference list',
            ], 2),
            _gq('According to the professor, what caused the problem?', [
              'The temperature readings',
              'The wrong chemicals',
              'The broken equipment',
              'The lab schedule',
            ], 1),
            _gq('What will Mike do at five o\'clock?', [
              'Attend a lecture',
              'Email the professor',
              'Repeat part of the experiment',
              'Meet Sarah at the library',
            ], 3),
            _gq('When will Mike send the report?', [
              'Tonight',
              'Tomorrow morning',
              'Tomorrow evening',
              'Next week',
            ], 2),
          ],
        ),







      ],
    ),


















































    // ═══════════════════════════════════════════════════════════════
// PASTE THIS BLOCK inside `static final List<ListeningTest> tests = [ ... ]`
// in listening_data.dart, right AFTER the closing `),` of TEST 1.
// ═══════════════════════════════════════════════════════════════

    // ═══════════════════════════ TEST 2 ═══════════════════════════
    _t(
      2,

      [
        _q('Where can I pick up my student ID card?', [
          'I lost my card yesterday.',
          'You can get it at the registration office.',
          'The card is blue and white.',
          'I need it by next year.',
        ], 2),
        _q('Do you know if the bookstore sells used textbooks?', [
          'Yes, they have a section near the entrance.',
          'The textbook costs fifty dollars.',
          'I bought my books online.',
          'The bookstore opens at nine.',
        ], 1),
        _q('How about we study together for the chemistry exam?', [
          'The exam was really difficult.',
          'I studied chemistry last year.',
          'Sure, when are you free?',
          'My textbook is in my bag.',
        ], 3),
        _q("I'm sorry, I didn't catch your name.", [
          'It was a long trip.',
          "It's Anna. Nice to meet you.",
          'I caught the early bus.',
          'The names are on the list.',
        ], 2),
        _q('Which dorm are you living in this year?', [
          "I'm in Harper Hall, on the third floor.",
          'The dorm was built in 1990.',
          'I live far from the city.',
          'Next year I will move.',
        ], 1),
        _q('Is the café on campus still open?', [
          'I ordered a large coffee.',
          'The campus is very big.',
          'It opened two years ago.',
          'Yes, it stays open until nine.',
        ], 4),
        _q('Would you like to join our hiking club?', [
          'That sounds fun. When do you meet?',
          'The mountain is very high.',
          'I hiked there last summer.',
          'My shoes are quite old.',
        ], 1),
        _q('What did the professor say about the deadline?', [
          'The professor teaches history.',
          'She said we have an extra week.',
          'I have not met her yet.',
          'The lecture hall was full.',
        ], 2),
        _q("Haven't you registered for the workshop yet?", [
          'The workshop was on Tuesday.',
          'It is held in the main hall.',
          'I like workshops very much.',
          "I'm planning to do it tonight.",
        ], 4),
        _q('Could you tell me how to get to the science building?', [
          'The science test was easy.',
          'I study science every day.',
          "It's just past the fountain, on your left.",
          'The building is very old.',
        ], 3),
      ],
      [
        // ───── 1 · Conversation (4) ─────
        _g(
          't2c1.mp3',
          'Conversation',
          'Olivia: Hi, Noah. I heard you changed your major. Is that true?\n\n'
              "Noah: Yes. I started in engineering, but I realized I'm more interested in environmental science.\n\n"
              'Olivia: What made you change your mind?\n\n'
              'Noah: I took an introductory course last semester, and we studied how pollution affects rivers. I really enjoyed the fieldwork.\n\n'
              'Olivia: That sounds exciting. Did you have to fill out any forms?\n\n'
              "Noah: Yes, I needed my adviser's signature. She was very supportive and helped me choose my classes.\n\n"
              'Olivia: Great. When does your first environmental science class begin?\n\n'
              'Noah: Next Tuesday at nine in the morning.',
          [
            _gq('What did Noah do recently?', [
              'He changed his major.',
              'He left the university.',
              'He moved to a new city.',
              'He started a part-time job.',
            ], 1),
            _gq('Why did Noah make the change?', [
              'His friends advised him to.',
              'He found engineering too expensive.',
              'He enjoyed studying environmental topics.',
              'He wanted a shorter degree.',
            ], 3),
            _gq('What did Noah need to complete the change?', [
              'A payment receipt',
              "His adviser's signature",
              'A letter from his parents',
              'A medical certificate',
            ], 2),
            _gq('When does his first new class begin?', [
              'Monday at nine',
              'Tuesday at ten',
              'Wednesday at nine',
              'Next Tuesday at nine',
            ], 4),
          ],
        ),

        // ───── 2 · Announcement (4) ─────
        _g(
          't2c2.mp3',
          'Announcement',
          'Attention, residents of Maple Hall. Please note that the hot water supply will be turned off '
              'on Wednesday between nine in the morning and one in the afternoon so that technicians can replace '
              'old pipes. Residents are advised to take showers before nine or after one. The laundry room on '
              'the ground floor will remain open, but the machines will use cold water only. If you have questions, '
              'please contact the residence office, which is open until five every weekday.',
          [
            _gq('Why will the hot water be turned off?', [
              'To clean the water tanks',
              'To replace old pipes',
              'To save energy',
              'To install new showers',
            ], 2),
            _gq('When will the hot water be unavailable?', [
              'Wednesday from nine to one',
              'Wednesday from one to five',
              'Thursday from nine to one',
              'Monday from nine to five',
            ], 1),
            _gq('What is true about the laundry room?', [
              'It will be closed all day.',
              'It will use hot water only.',
              'It will open with cold water only.',
              'It will move to another floor.',
            ], 3),
            _gq('Where should residents go with questions?', [
              'The library',
              'The cafeteria',
              'The sports center',
              'The residence office',
            ], 4),
          ],
        ),

        // ───── 3 · Conversation (4) ─────
        _g(
          't2c3.mp3',
          'Conversation',
          'Student: Excuse me, Professor Lee. I wanted to ask about the group project.\n\n'
              'Professor: Of course. What is the problem?\n\n'
              'Student: One of my group members has not replied to any of our messages for two weeks.\n\n'
              'Professor: I see. Have you tried speaking to him in person?\n\n'
              "Student: We tried after class, but he left quickly. We're worried because the presentation is in ten days.\n\n"
              "Professor: Please send me an email with the details. I'll contact him and remind him of his responsibilities.\n\n"
              'Student: Thank you. Should we divide his part among the rest of us?\n\n'
              "Professor: Not yet. Let's wait until I hear from him. I'll let you know by Friday.",
          [
            _gq('What is the student worried about?', [
              'A low grade on an exam',
              'A group member who is not responding',
              'A change in the course schedule',
              'A lost assignment',
            ], 2),
            _gq('How long has the problem lasted?', [
              'Two days',
              'One week',
              'Two weeks',
              'One month',
            ], 3),
            _gq('What does the professor ask the student to do?', [
              'Send an email with the details',
              'Change groups',
              'Present alone',
              'Visit the dean',
            ], 1),
            _gq('When will the professor give an update?', [
              'Tomorrow',
              'On Monday',
              'In ten days',
              'By Friday',
            ], 4),
          ],
        ),

        // ───── 4 · Announcement (4) ─────
        _g(
          't2c4.mp3',
          'Announcement',
          "Good afternoon, everyone. The Student Union is pleased to announce this year's film festival, "
              'which will take place from Monday to Thursday next week in the Grand Auditorium. Each evening '
              'at seven, a different film from a different country will be shown. Tickets are free for students, '
              'but seats must be reserved online because space is limited. After Thursday\'s film, there will be a '
              'discussion with the director, who will visit from Spain. Refreshments will be provided in the lobby.',
          [
            _gq('Where will the film festival be held?', [
              'In the sports hall',
              'In the Grand Auditorium',
              'In the library',
              'In the student cafeteria',
            ], 2),
            _gq('How can students get tickets?', [
              'By paying at the door',
              'By asking their professors',
              'By reserving seats online',
              'By collecting them at the library',
            ], 3),
            _gq('What will happen after the Thursday film?', [
              'A concert',
              'A prize ceremony',
              'A free dinner',
              'A discussion with the director',
            ], 4),
            _gq('What will be provided in the lobby?', [
              'Refreshments',
              'Souvenirs',
              'Programs in several languages',
              'Parking passes',
            ], 1),
          ],
        ),

        // ───── 5 · Conversation (4) ─────
        _g(
          't2c5.mp3',
          'Conversation',
          "Grace: Hi, Tom. You look tired. Did you stay up late studying?\n\n"
              "Tom: Yes, I was working on my history paper until two in the morning. I still haven't finished the conclusion.\n\n"
              'Grace: When is it due?\n\n'
              "Tom: Tomorrow at noon. I'm also stressed because my computer keeps crashing.\n\n"
              'Grace: You could use the computer lab. It has fast machines, and a technician is always there.\n\n'
              'Tom: Good idea. Is it open at night?\n\n'
              'Grace: It closes at ten, but you can start right after your class this afternoon.\n\n'
              "Tom: Thanks. I'll save my work on a flash drive first.",
          [
            _gq('Why is Tom tired?', [
              'He worked at a part-time job.',
              'He stayed up writing a paper.',
              'He traveled the night before.',
              'He was ill.',
            ], 2),
            _gq('What is Tom\'s technical problem?', [
              'His printer is broken.',
              'His internet is slow.',
              'His computer keeps crashing.',
              'His flash drive is lost.',
            ], 3),
            _gq('What does Grace suggest?', [
              'Asking for an extension',
              'Writing the paper by hand',
              'Borrowing her laptop',
              'Using the computer lab',
            ], 4),
            _gq('What will Tom do first?', [
              'Save his work on a flash drive',
              'Talk to his professor',
              'Eat lunch',
              'Buy a new computer',
            ], 1),
          ],
        ),

        // ───── 6 · Conversation (3) ─────
        _g(
          't2c6.mp3',
          'Conversation',
          'Student: Hello, I would like to open a bank account on campus.\n\n'
              'Clerk: Certainly. Are you a full-time student?\n\n'
              'Student: Yes, I am. I also have my student ID and my passport.\n\n'
              'Clerk: That is all you need. Students get an account with no monthly fee for the first year.\n\n'
              'Student: That is great. How soon can I use my card?\n\n'
              'Clerk: We will mail it to your dormitory address, and it usually arrives within five working days.',
          [
            _gq('Why does the student visit the bank?', [
              'To exchange money',
              'To open a new account',
              'To apply for a loan',
              'To report a lost card',
            ], 2),
            _gq('What benefit do students receive?', [
              'A free laptop',
              'A higher interest rate',
              'No monthly fee for the first year',
              'Free insurance',
            ], 3),
            _gq('How will the student receive the card?', [
              'By mail to the dormitory',
              'At the bank counter',
              'By email',
              'From the registration office',
            ], 1),
          ],
        ),

        // ───── 7 · Announcement (3) ─────
        _g(
          't2c7.mp3',
          'Announcement',
          'Attention, all students. The campus parking lot behind the engineering building will be closed '
              'next week while workers repaint the lines and repair the surface. Drivers may use the temporary '
              'parking area near the soccer field instead. A free shuttle will take students from that area to '
              'the main buildings every ten minutes. The lot is expected to reopen the following Monday.',
          [
            _gq('Why will the parking lot be closed?', [
              'For a university event',
              'For construction of a new building',
              'For repainting and repairs',
              'For a safety inspection',
            ], 3),
            _gq('Where can drivers park next week?', [
              'Near the soccer field',
              'Near the library',
              'Outside the main gate',
              'Behind the cafeteria',
            ], 1),
            _gq('How often will the shuttle run?', [
              'Every five minutes',
              'Every ten minutes',
              'Every twenty minutes',
              'Every thirty minutes',
            ], 2),
          ],
        ),

        // ───── 8 · Conversation (3) ─────
        _g(
          't2c8.mp3',
          'Conversation',
          'Student: Professor Hughes, I missed the midterm because I was in the hospital. Can I take a make-up exam?\n\n'
              'Professor: I am sorry to hear that. Do you have a note from the doctor?\n\n'
              'Student: Yes, I brought it with me.\n\n'
              'Professor: Good. Please give it to the department secretary. The make-up exam will be next Tuesday at two in Room 305.\n\n'
              'Student: Will it cover the same material?\n\n'
              'Professor: Yes, but the questions will be different. I suggest you review chapters one through six.',
          [
            _gq('Why did the student miss the midterm?', [
              'He overslept.',
              'He had a family emergency.',
              'He was in the hospital.',
              'He had a travel delay.',
            ], 3),
            _gq('What must the student give to the secretary?', [
              'A doctor\'s note',
              'A written essay',
              'A payment',
              'A signed form from a friend',
            ], 1),
            _gq('What does the professor tell the student to review?', [
              'Only chapter six',
              'Chapters one through six',
              'Chapters four through ten',
              'The lecture slides only',
            ], 2),
          ],
        ),

        // ───── 9 · Conversation (3) ─────
        _g(
          't2c9.mp3',
          'Conversation',
          'Anna: Ben, are you going to the career talk this afternoon?\n\n'
              "Ben: I'd like to, but I have a lab session until four. When does the talk start?\n\n"
              'Anna: At three thirty, in Lecture Hall B. A manager from a software company is speaking about internships.\n\n'
              "Ben: That's exactly what I need. Is there any way to watch it later?\n\n"
              'Anna: The university will post a recording on its website tomorrow.\n\n'
              "Ben: Perfect. I'll watch it then, and maybe I can email the speaker with questions.",
          [
            _gq('What is the talk about?', [
              'Study abroad',
              'Scholarships',
              'Research funding',
              'Internships',
            ], 4),
            _gq('Why can Ben not attend?', [
              'He has a lab session.',
              'He is traveling.',
              'He has a job interview.',
              'He is not interested.',
            ], 1),
            _gq('How can Ben watch the talk later?', [
              'On a DVD from the library',
              'In a recording on the university website',
              'In a live stream tonight',
              'In a video from the speaker',
            ], 2),
          ],
        ),

        // ───── 10 · Announcement (4) ─────
        _g(
          't2c10.mp3',
          'Announcement',
          'Hello, students. The Health Center will offer free flu vaccinations on the first floor of the student '
              'center next Tuesday and Wednesday, from nine in the morning until three in the afternoon. '
              'No appointment is necessary, but students should bring their university identification. '
              'The vaccination takes only a few minutes, and mild soreness in the arm is normal. Students who '
              'are allergic to eggs should speak with a nurse before receiving the vaccine.',
          [
            _gq('What service does the Health Center offer?', [
              'Free dental checkups',
              'Free flu vaccinations',
              'Free eye tests',
              'Free vitamins',
            ], 2),
            _gq('Where will the service be located?', [
              'In the library',
              'In the sports hall',
              'On the first floor of the student center',
              'In the dormitory lobby',
            ], 3),
            _gq('What must students bring?', [
              'A doctor\'s letter',
              'Their university identification',
              'A signed form',
              'Their insurance card',
            ], 2),
            _gq('What should students with egg allergies do?', [
              'Skip the vaccine',
              'Return another day',
              'Bring a parent',
              'Speak with a nurse first',
            ], 4),
          ],
        ),

        // ───── 11 · Conversation (4) ─────
        _g(
          't2c11.mp3',
          'Conversation',
          'Rachel: Hi, David. I saw your poster about the volunteer program. How does it work?\n\n'
              'David: We help local elementary schools with reading. Each volunteer visits a school for two hours every week.\n\n'
              'Rachel: Do you need any experience?\n\n'
              'David: No. We provide a short training session on Saturday morning. After that, you can choose a day that fits your schedule.\n\n'
              'Rachel: That sounds great. Is transportation provided?\n\n'
              'David: Yes, a van leaves from the main gate thirty minutes before each session.\n\n'
              "Rachel: I'm in. Where do I sign up?\n\n"
              'David: At the Student Union office, or you can fill out the form on our website.',
          [
            _gq('What does the volunteer program do?', [
              'Helps children with reading',
              'Collects food for families',
              'Cleans local parks',
              'Teaches adults computer skills',
            ], 1),
            _gq('How much time do volunteers give each week?', [
              'One hour',
              'Two hours',
              'Three hours',
              'Four hours',
            ], 2),
            _gq('What is provided to volunteers?', [
              'Free meals',
              'A small payment',
              'Transportation by van',
              'Extra course credit',
            ], 3),
            _gq('How can Rachel sign up?', [
              'By calling the schools',
              'By emailing her professor',
              'By visiting the library',
              'At the Student Union office or online',
            ], 4),
          ],
        ),
      ],
    ),

// ═══════════════════════════════════════════════════════════════
// PASTE THIS BLOCK inside `static final List<ListeningTest> tests = [ ... ]`
// in listening_data.dart, right AFTER the closing `),` of TEST 2.
// Audio folder: assets/audios/t3/   (t3s1.mp3 … t3s10.mp3, t3c1.mp3 … t3c11.mp3)
// ═══════════════════════════════════════════════════════════════

    // ═══════════════════════════ TEST 3 ═══════════════════════════
    _t(
      3,

      [
        _q('Do you mind if I sit here?', [
          'The seat is made of wood.',
          'Not at all, go ahead.',
          'I sat there yesterday.',
          'The room is very cold.',
        ], 2),
        _q('When is the registration deadline?', [
          'It closes this Friday.',
          'I registered last year.',
          'The office is on the first floor.',
          'The form is quite long.',
        ], 1),
        _q('Why did you miss the bus this morning?', [
          'The bus stop is near my house.',
          'I take the bus every day.',
          'I overslept.',
          'The ticket was cheap.',
        ], 3),
        _q('Have you ever taken a class with Professor Green?', [
          'She teaches on Mondays.',
          "No, but I've heard she's excellent.",
          'Her office is upstairs.',
          'I have class at noon.',
        ], 2),
        _q('Could you help me carry these boxes?', [
          'Sure, where do you want them?',
          'The boxes are very old.',
          'I bought them last week.',
          'There are ten of them.',
        ], 1),
        _q('How was the field trip?', [
          'We left at seven.',
          'The bus was blue.',
          'It was educational and a lot of fun.',
          'I will go next month.',
        ], 3),
        _q('Do you know where the gym is?', [
          'I go there every morning.',
          'The gym is very expensive.',
          'I like swimming more.',
          "It's behind the student center.",
        ], 4),
        _q('I think the exam was too long.', [
          'I agree. I barely finished.',
          'The exam is next week.',
          'I studied in the library.',
          'It starts at nine.',
        ], 1),
        _q('Would you rather study in the morning or at night?', [
          'I study biology.',
          'The library closes at ten.',
          'I focus better in the morning.',
          'Night classes are expensive.',
        ], 3),
        _q('Did the library receive the new journals yet?', [
          'I borrowed two journals.',
          "They're supposed to arrive next week.",
          'The library is open late.',
          'Journals are in the basement.',
        ], 2),
      ],
      [
        // ───── 1 · Conversation (4) ─────
        _g(
          't3c1.mp3',
          'Conversation',
          'Student: Hello, Ms. Carter. I would like to find out about the study abroad program in Japan.\n\n'
              'Adviser: Certainly. The program lasts one semester, and students take courses in Japanese culture and language.\n\n'
              'Student: Do I need to speak Japanese already?\n\n'
              'Adviser: Not at all. There are classes for beginners. However, you do need a grade point average of at least three point two.\n\n'
              'Student: Mine is three point five. What is the application deadline?\n\n'
              'Adviser: Applications are due on the fifteenth of November. You will also need two recommendation letters.\n\n'
              "Student: I'll ask my professors this week. Thank you.",
          [
            _gq('What does the student want to learn about?', [
              'A summer internship',
              'The study abroad program in Japan',
              'A language examination',
              'A scholarship for graduate study',
            ], 2),
            _gq('What is required to join the program?', [
              'Fluency in Japanese',
              'A year of university study',
              'A minimum grade point average',
              'A passing language examination',
            ], 3),
            _gq('When is the application deadline?', [
              'October fifteenth',
              'November fifth',
              'December first',
              'November fifteenth',
            ], 4),
            _gq('What will the student do this week?', [
              'Ask professors for recommendation letters',
              'Travel to Japan',
              'Pay the program fee',
              'Take a placement test',
            ], 1),
          ],
        ),

        // ───── 2 · Announcement (4) ─────
        _g(
          't3c2.mp3',
          'Announcement',
          'Attention, students. The annual science fair will be held on Saturday, April twelfth, in the east gymnasium. '
              'Students from all departments may present projects, and prizes will be awarded for the three best entries. '
              'Anyone who wishes to participate must submit a short summary of their project to the Science Department office '
              'by March thirtieth. Judges include faculty members and scientists from local companies. '
              'Visitors are welcome, and admission is free.',
          [
            _gq('What event is being announced?', [
              'A job fair',
              'A science fair',
              'A music festival',
              'A book sale',
            ], 2),
            _gq('Where will the event be held?', [
              'In the east gymnasium',
              'In the main library',
              'In the science laboratory',
              'In the student center',
            ], 1),
            _gq('What must participants do by March thirtieth?', [
              'Pay a registration fee',
              'Prepare a large poster',
              'Submit a short project summary',
              'Find a partner',
            ], 3),
            _gq('Who will judge the projects?', [
              'Only the university president',
              'Student volunteers',
              'Visitors from other universities',
              'Faculty members and local scientists',
            ], 4),
          ],
        ),

        // ───── 3 · Conversation (4) ─────
        _g(
          't3c3.mp3',
          'Conversation',
          'Maya: Hey, Chris. I heard you got a job at the campus library. How is it going?\n\n'
              "Chris: It's great. I work at the front desk three afternoons a week, mostly helping students check out books.\n\n"
              'Maya: Is it hard to balance with classes?\n\n'
              "Chris: A little, but my supervisor is flexible. When I have exams, she lets me reduce my hours.\n\n"
              "Maya: That's good. Are they hiring anyone else?\n\n"
              'Chris: Yes, they need someone for the weekend shift. You can apply on the university website.\n\n'
              "Maya: Perfect. I need extra money for next semester's textbooks.",
          [
            _gq("What is Chris's job?", [
              'Working at the library front desk',
              'Teaching assistant',
              'Cafeteria cashier',
              'Computer laboratory technician',
            ], 1),
            _gq('How does his supervisor help him?', [
              'She pays him extra money.',
              'She reduces his hours during exams.',
              'She gives him free books.',
              'She lets him work from home.',
            ], 2),
            _gq('Which position is available?', [
              'An evening cleaner',
              'A weekday receptionist',
              'A weekend shift',
              'A night security guard',
            ], 3),
            _gq('Why does Maya want a job?', [
              'To pay for a trip',
              'To meet new friends',
              'To pay her rent',
              'To buy textbooks',
            ], 4),
          ],
        ),

        // ───── 4 · Announcement (4) ─────
        _g(
          't3c4.mp3',
          'Announcement',
          'Good morning, everyone. The campus bookstore will hold its end-of-semester sale from Monday through Friday next week. '
              'All sweatshirts and backpacks will be thirty percent off, and used textbooks will be half price. '
              'Students who show a valid ID will receive an additional five percent discount. '
              'The store will also buy back textbooks in good condition on Friday between noon and four. '
              'The bookstore will stay open until eight each evening during the sale.',
          [
            _gq('What is being announced?', [
              'A new store opening',
              'An end-of-semester sale',
              'A permanent change in store hours',
              'A textbook exchange between students',
            ], 2),
            _gq('How much will used textbooks cost?', [
              'Thirty percent off',
              'They will be free.',
              'Half price',
              'Five dollars each',
            ], 3),
            _gq('What extra benefit do students with ID receive?', [
              'Free delivery',
              'A gift card',
              'An extra week to return items',
              'An additional five percent discount',
            ], 4),
            _gq('When will the store buy back textbooks?', [
              'Friday between noon and four',
              'Monday morning',
              'Wednesday evening',
              'All day Saturday',
            ], 1),
          ],
        ),

        // ───── 5 · Conversation (4) ─────
        _g(
          't3c5.mp3',
          'Conversation',
          'Liam: Hi, Sophie. Have you chosen a topic for the marketing presentation?\n\n'
              "Sophie: I'm thinking about social media advertising, but I'm not sure if it's too common.\n\n"
              'Liam: Maybe you could focus on how small businesses use it. That might be more original.\n\n'
              "Sophie: That's a good idea. Do you know how long the presentation should be?\n\n"
              'Liam: Ten minutes, plus five minutes for questions.\n\n'
              'Sophie: Okay. Will we need slides?\n\n'
              'Liam: Yes, the professor wants a maximum of eight slides, and we have to send them to her the night before.\n\n'
              "Sophie: Thanks. I'll start working on them this weekend.",
          [
            _gq('What are the students discussing?', [
              'A group trip',
              'A marketing presentation',
              'A final examination',
              'A job interview',
            ], 2),
            _gq('What does Liam suggest?', [
              'Choosing a different course',
              'Asking the professor for help',
              'Focusing on small businesses',
              'Working in a group',
            ], 3),
            _gq('How long should the presentation be?', [
              'Five minutes',
              'Fifteen minutes without questions',
              'Twenty minutes',
              'Ten minutes plus five minutes for questions',
            ], 4),
            _gq('What must be sent to the professor the night before?', [
              'The slides',
              'A set of notes',
              'A written report',
              'A list of sources',
            ], 1),
          ],
        ),

        // ───── 6 · Conversation (3) ─────
        _g(
          't3c6.mp3',
          'Conversation',
          "Student: Hi, I can't connect to the campus Wi-Fi from my laptop.\n\n"
              'Technician: Let me help. Have you tried restarting your computer?\n\n'
              'Student: Yes, twice. It says my password is incorrect.\n\n'
              'Technician: Student passwords expire every ninety days. You probably need to reset yours on the university portal.\n\n'
              "Student: Oh, I didn't know that. How long does it take?\n\n"
              "Technician: Only a few minutes. If it still doesn't work afterward, come back and I'll check your device settings.",
          [
            _gq('What problem does the student have?', [
              'A broken laptop screen',
              'He cannot connect to the Wi-Fi.',
              'He has lost his files.',
              'His computer has a virus.',
            ], 2),
            _gq('Why is the password not working?', [
              'It is too short.',
              'It was typed incorrectly.',
              'It has expired.',
              'It belongs to someone else.',
            ], 3),
            _gq('What will the technician do if the problem continues?', [
              "Check the student's device settings",
              'Replace the laptop',
              'Install new software',
              'Call the professor',
            ], 1),
          ],
        ),

        // ───── 7 · Announcement (3) ─────
        _g(
          't3c7.mp3',
          'Announcement',
          'Attention, please. A fire drill will take place in the Business Building tomorrow at ten fifteen in the morning. '
              'When the alarm sounds, everyone must leave the building immediately through the nearest exit and gather on the lawn '
              'in front of the main entrance. Do not use the elevators. Classes will resume after the safety officer has checked '
              'that all areas are clear. The drill is expected to last about twenty minutes.',
          [
            _gq('When will the fire drill take place?', [
              'Today at ten fifteen',
              'Tomorrow at ten fifteen',
              'Tomorrow at one fifteen',
              'Next week at ten fifteen',
            ], 2),
            _gq('Where should people gather?', [
              'In the parking lot',
              'In the library',
              'On the lawn in front of the main entrance',
              'In the cafeteria',
            ], 3),
            _gq('What should people not use during the drill?', [
              'The stairs',
              'Their mobile phones',
              'The side doors',
              'The elevators',
            ], 4),
          ],
        ),

        // ───── 8 · Conversation (3) ─────
        _g(
          't3c8.mp3',
          'Conversation',
          "Student: Professor Adams, do you have a few minutes? I'd like to ask for a recommendation letter.\n\n"
              'Professor: Of course. What is it for?\n\n'
              "Student: I'm applying for a scholarship from the engineering foundation. The deadline is in three weeks.\n\n"
              'Professor: I would be happy to write it. Please send me your résumé and a short paragraph about your goals.\n\n'
              "Student: I'll email them to you tomorrow.\n\n"
              "Professor: Good. I'll need about ten days to finish the letter.",
          [
            _gq('Why does the student visit the professor?', [
              'To ask about a grade',
              'To request a recommendation letter',
              'To change courses',
              'To discuss a research project',
            ], 2),
            _gq('What must the student send to the professor?', [
              'A résumé and a short paragraph about his goals',
              'Two long essays',
              'A list of completed courses',
              'A letter from a friend',
            ], 1),
            _gq('How long will the professor need to finish the letter?', [
              'Three days',
              'One week',
              'Ten days',
              'Three weeks',
            ], 3),
          ],
        ),

        // ───── 9 · Conversation (3) ─────
        _g(
          't3c9.mp3',
          'Conversation',
          'Ella: Jack, have you used the new fitness center on campus yet?\n\n'
              'Jack: Yes, I went last week. It has modern equipment and a swimming pool.\n\n'
              'Ella: Is it expensive?\n\n'
              "Jack: Not really. Students pay twenty dollars per semester, and it's open from six in the morning until ten at night.\n\n"
              'Ella: That sounds reasonable. Do you need to book anything?\n\n'
              'Jack: Only for the swimming pool. You can reserve a time slot on the app.',
          [
            _gq('What does Jack say about the fitness center?', [
              'It is closed for repairs.',
              'It has modern equipment and a pool.',
              'It is only for staff.',
              'It is always too crowded.',
            ], 2),
            _gq('How much do students pay?', [
              'Nothing',
              'Ten dollars',
              'Twenty dollars per semester',
              'Fifty dollars per year',
            ], 3),
            _gq('What requires a reservation?', [
              'The weight room',
              'The group classes',
              'The lockers',
              'The swimming pool',
            ], 4),
          ],
        ),

        // ───── 10 · Announcement (4) ─────
        _g(
          't3c10.mp3',
          'Announcement',
          'Good afternoon. The Department of History is pleased to host a guest lecture by Dr. Helen Morris, who has spent '
              'twenty years studying ancient trade routes. The lecture will take place on Thursday at four o\'clock in Hall C. '
              'Dr. Morris will discuss how trade shaped early cities in the Middle East. Seating is limited, so students are advised '
              'to arrive early. After the lecture, copies of her new book will be available for purchase, and she will sign them '
              'in the lobby.',
          [
            _gq('Who is Dr. Morris?', [
              'A university president',
              'A student researcher',
              'A historian who studies trade routes',
              'A museum director',
            ], 3),
            _gq('Where will the lecture take place?', [
              'Hall A',
              'Hall B',
              'Hall D',
              'Hall C',
            ], 4),
            _gq('What will Dr. Morris discuss?', [
              'How trade shaped early cities',
              'How to write a book',
              'Modern economics',
              'Archaeological tools',
            ], 1),
            _gq('What can attendees do after the lecture?', [
              'Tour a museum',
              'Buy a signed copy of her book',
              'Meet the university president',
              'Receive a certificate',
            ], 2),
          ],
        ),

        // ───── 11 · Conversation (4) ─────
        _g(
          't3c11.mp3',
          'Conversation',
          "Student: Hi, I'd like to change rooms. My roommate and I have very different schedules, and it's hard for me to sleep.\n\n"
              'Staff: I understand. Room changes are possible, but they depend on availability. Which building are you in?\n\n'
              'Student: Oak Hall, on the second floor.\n\n'
              "Staff: Right now, there is an empty room in Pine Hall. It's slightly more expensive, about fifty dollars more per month.\n\n"
              "Student: That's fine. How soon could I move?\n\n"
              "Staff: If you complete the form today, you can move in on Monday. You'll also have to return your old room key before you receive the new one.\n\n"
              "Student: Great. I'll fill out the form now.",
          [
            _gq('Why does the student want to change rooms?', [
              'The room is too small.',
              "His roommate's schedule disturbs his sleep.",
              'The dormitory is too far from class.',
              'The room is too expensive.',
            ], 2),
            _gq('What is true about the available room?', [
              'It is in Pine Hall and costs more.',
              'It is in Oak Hall and costs less.',
              'It is off campus.',
              'It has no windows.',
            ], 1),
            _gq('When can the student move in if he completes the form today?', [
              'Tomorrow',
              'Next month',
              'On Monday',
              'On Friday',
            ], 3),
            _gq('What must the student return?', [
              'A parking pass',
              'A meal card',
              'A deposit receipt',
              'His old room key',
            ], 4),
          ],
        ),
      ],
    ),



  ];
}