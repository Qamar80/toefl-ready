import 'dart:math';
import 'speaking_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOW TO ADD A NEW TEST
//   1. Copy any `_t(...)` block at the bottom of `tests`.
//   2. Give it the next number (the store tracks used tests by id "s7"...).
//   3. Listen and Repeat: 7 sentences, short to long. Use NO contractions
//      (write "do not", not "don't") so word matching stays accurate.
//   4. Interview: 4 questions + a model answer of about 70-100 words each.
// ─────────────────────────────────────────────────────────────────────────────

InterviewQ _q(String q, String sample) => InterviewQ(q, sample);

SpeakingTest _t(int n, String scene, List<String> repeats, String interviewer, String topic,
    List<InterviewQ> qs) =>
    SpeakingTest(
        id: 's$n',
        number: n,
        scene: scene,
        repeats: repeats,
        interviewer: interviewer,
        topic: topic,
        questions: qs);

class SpeakingBank {
  static int get maxTests => tests.length;

  /// Random unused test, or null when every test has been taken.
  static SpeakingTest? pick(Set<String> used, Random r) {
    final pool = tests.where((t) => !used.contains(t.id)).toList();
    if (pool.isEmpty) return null;
    return pool[r.nextInt(pool.length)];
  }

  static final List<SpeakingTest> tests = [
    // ═══════════════════════════ TEST 1 ═══════════════════════════
    _t(
      1,
      'You are on a guided tour of a university campus.',
      [
        'The library opens at eight.',
        'Please keep your voice down inside.',
        'Students can borrow up to ten books.',
        'The study rooms must be reserved a day in advance.',
        'If you lose a book, you will need to pay a small fee.',
        'The computer lab on the second floor is open until midnight every day.',
        'After the tour, we will visit the cafeteria and then go to the sports center.',
      ],
      'Ms. Carter',
      'Study habits',
      [
        _q(
          'Thanks for joining me. First, how do you usually prepare for an important exam?',
          'I usually start preparing at least two weeks before the exam. First, I make a schedule so that I study a little every day instead of everything at the last minute. For example, I review one chapter each evening and write short summary notes. Because I do this, I feel calm on exam day, and I can spend the last night resting instead of panicking.',
        ),
        _q(
          'Do you prefer studying alone or with other students? Why?',
          'I prefer studying alone most of the time because I can concentrate better without distractions. When I am alone, I can choose my own speed and repeat difficult topics as many times as I need. However, I sometimes join a study group before exams. For instance, my friends and I explain the hardest questions to each other, which helps us find mistakes.',
        ),
        _q(
          'What is the most useful study tool you have used, and how did it help you?',
          'The most useful tool for me is a flashcard app. It lets me practice vocabulary and key ideas in short sessions, even when I am on the bus. Because the app shows difficult cards more often, I spend my time on what I do not know yet. Last semester it helped me raise my biology grade significantly.',
        ),
        _q(
          'Some universities want to make attendance mandatory in every class. What do you think about this idea?',
          'I think mandatory attendance is partly a good idea. Students who come to class usually learn more because they can ask questions and join discussions. However, adults should be able to manage their own time. For example, a student who already knows the material may waste hours in a lecture. A better solution is required attendance only for labs and small seminars.',
        ),
      ],
    ),

    // ═══════════════════════════ TEST 2 ═══════════════════════════
    _t(
      2,
      'You are visiting a history museum.',
      [
        'Welcome to the history museum.',
        'Photography is allowed in most galleries.',
        'Please do not touch the objects on display.',
        'The guided tour begins every hour at the front desk.',
        'Audio guides are available in six different languages.',
        'The special exhibition on ancient trade routes closes at the end of this month.',
        'If you would like to learn more, our staff will gladly answer all of your questions.',
      ],
      'Mr. Thompson',
      'Technology in everyday life',
      [
        _q(
          'To begin, which piece of technology do you use most in your daily life, and why?',
          'The piece of technology I use most is my smartphone. I use it for almost everything, such as checking my schedule, reading the news, and talking to my family. Because it is always in my pocket, it saves me a lot of time. For example, instead of carrying a dictionary and a map, I only need two apps. Without it, my daily routine would be much harder.',
        ),
        _q(
          "Do you think smartphones have made people's lives easier or more complicated?",
          'I think smartphones have mostly made life easier, but they also bring new problems. On the positive side, we can pay bills, order food, and find directions in seconds. However, notifications constantly interrupt us, and many people feel they must answer messages immediately. For me, the solution is to turn off alerts at certain times, so the phone helps me instead of controlling my day.',
        ),
        _q(
          'How has technology changed the way you communicate with your family and friends?',
          'Technology has made communication faster and more frequent. My family lives in another city, so we used to speak only on weekends. Now we send voice messages every day and have video calls on Sundays. Because of this, I feel closer to them. On the other hand, I sometimes miss long, careful letters, since short messages can feel less personal.',
        ),
        _q(
          'Some schools now allow students to use artificial intelligence tools for homework. Do you think this is a good idea?',
          'I think it is a good idea if students use these tools responsibly. For example, an AI tool can explain a difficult grammar rule or suggest ways to organize an essay. However, students should not let it do all the thinking, because then they will not develop their own skills. Teachers could set clear rules, such as asking students to explain how they used the tool.',
        ),
      ],
    ),

    // ═══════════════════════════ TEST 3 ═══════════════════════════
    _t(
      3,
      'You are at an international airport.',
      [
        'Please show your passport.',
        'Your flight departs from gate twelve.',
        'Boarding will begin in twenty minutes.',
        'Passengers must remove laptops from their bags at security.',
        'The shuttle bus to the city center leaves every fifteen minutes.',
        'If your luggage is delayed, please report it to the airline office immediately.',
        'Because of heavy fog this morning, several international flights have been rescheduled for this afternoon.',
      ],
      'Dr. Reyes',
      'Traveling and living abroad',
      [
        _q(
          "Let's begin. If you could live in any country for a year, where would you choose, and why?",
          'I would choose Japan because I am very interested in its culture and technology. Living there for a year would let me learn the language naturally and understand daily life, not just visit as a tourist. For example, I could study at a local university and make friends there. Also, the public transportation is excellent, so it would be easy to explore different regions.',
        ),
        _q(
          'What would be the hardest part of living in a foreign country?',
          'I think the hardest part would be missing my family and feeling lonely at the beginning. Everything would be unfamiliar, from the food to the way people communicate. In addition, small tasks such as opening a bank account could take much longer in a new language. However, I believe joining clubs and meeting local people would help me adjust faster.',
        ),
        _q(
          'Do you prefer traveling with a group or traveling alone? Please explain.',
          'I prefer traveling with a small group of friends because we can share costs and experiences. For instance, we can split the price of a hotel room, and we always have someone to take photos. Traveling alone is more flexible, but it can also feel lonely or unsafe in unfamiliar places. A group of three or four people seems perfect to me.',
        ),
        _q(
          'Some people say traveling is the best form of education. Do you agree?',
          'I partly agree. Traveling teaches us things that books cannot, such as how people in other countries really live and think. For example, visiting a historical site is far more memorable than reading about it. However, classroom education provides knowledge and skills that travel alone cannot offer. In my opinion, the two work best together.',
        ),
      ],
    ),

    // ═══════════════════════════ TEST 4 ═══════════════════════════
    _t(
      4,
      'You are in a university science laboratory.',
      [
        'Please wear your safety glasses.',
        'Wash your hands before leaving the lab.',
        'Record every measurement in your notebook.',
        'Never pour chemicals down the sink without permission.',
        'Each group will test three samples and compare the results.',
        'If you spill anything on the floor, tell your instructor right away.',
        'The final report is due next Friday, and it should include a graph of your data.',
      ],
      'Professor Nakamura',
      'Health and exercise',
      [
        _q(
          'To start, how often do you exercise, and what kind of activity do you enjoy?',
          'I exercise about three times a week, usually in the evening. My favorite activity is swimming because it is relaxing and works the whole body. On the weekends, I also like to go for a long walk in the park with my friends. Exercising regularly helps me sleep better, and I notice that I have more energy during the day.',
        ),
        _q(
          'What do you do to stay healthy during a stressful exam period?',
          'During exams, I try to keep a simple routine. First, I sleep at least seven hours, because tired students forget information quickly. Second, I take a short walk every afternoon, which clears my mind. I also avoid eating too much fast food, since it makes me sleepy. These small habits help me stay calm and focused.',
        ),
        _q(
          'Should universities require students to take a physical education class? Why or why not?',
          'I think universities should require a physical education class, at least in the first year. Many students spend hours sitting in lectures and libraries, so regular exercise is important for their health. For example, a weekly class could teach simple routines and reduce stress. However, students should be able to choose from different activities, so that the class is enjoyable and not a burden.',
        ),
        _q(
          'Do you think people today are healthier or less healthy than people in the past?',
          'I think it is a mix. Today we have better medicine and more knowledge about nutrition, so people live longer. However, many people work at desks, eat processed food, and move much less than their grandparents did. As a result, problems like obesity are more common. In my opinion, people today have more chances to be healthy, but they must make better choices.',
        ),
      ],
    ),

    // ═══════════════════════════ TEST 5 ═══════════════════════════
    _t(
      5,
      'You are ordering food at a campus cafe.',
      [
        'What would you like to order?',
        'Our soup of the day is tomato.',
        'You can pay at the counter after you order.',
        'We offer a discount for students with a valid card.',
        'The cafe closes early on weekends, so please plan accordingly.',
        'If you want a quieter place to study, there are tables on the second floor.',
        'We are hiring part-time workers for the fall semester, and no experience is required.',
      ],
      'Ms. Alvarez',
      'Learning languages',
      [
        _q(
          'Thank you for talking with me. Which foreign language would you most like to learn, and why?',
          'I would most like to learn Spanish because it is spoken in so many countries. If I speak Spanish, I can travel more easily and communicate with millions of people. It would also help my career, since many companies work with Latin America. Moreover, I enjoy Spanish music and films, so practicing would be fun for me.',
        ),
        _q(
          'What is the most effective way to improve your speaking skills?',
          'In my experience, the most effective way is to speak every day, even for a few minutes. For example, I record myself answering a question and then listen carefully to find mistakes. It also helps to talk with native speakers, because they use natural expressions. Finally, I try not to worry about perfection, since confidence is as important as grammar.',
        ),
        _q(
          'Do you think children should start learning a second language in primary school?',
          'Yes, I think children should start early. Young learners copy sounds easily, so they often develop a better accent. In addition, learning another language improves memory and helps children understand other cultures. For instance, my cousin started English at six, and now she speaks very naturally. Of course, lessons should be playful, with songs and games, so that children enjoy them.',
        ),
        _q(
          'Some people believe translation apps will make language learning unnecessary. What is your opinion?',
          'I disagree. Translation apps are useful for quick questions, but they cannot replace real communication. They often miss tone and cultural meaning, and a conversation becomes slow when you must type everything. Moreover, speaking someone\'s language builds trust and friendship. For example, locals are usually happier when a visitor tries a few words. So I believe learning languages will remain valuable.',
        ),
      ],
    ),

    // ═══════════════════════════ TEST 6 ═══════════════════════════
    _t(
      6,
      'You are listening to an announcement in a student dormitory.',
      [
        'Quiet hours begin at ten.',
        'Visitors must sign in at the front desk.',
        'The laundry room is located in the basement.',
        'Please report any broken equipment to the housing office.',
        'Residents can use the kitchen on each floor until eleven at night.',
        'If you forget your key, the staff can let you in after checking your identification.',
        'Next week, the dormitory will hold a meeting to discuss the new rules about guests and noise.',
      ],
      'Mr. Brooks',
      'Part-time jobs and money',
      [
        _q(
          "Let's start with this: have you ever had a part-time job, or would you like to have one?",
          'Yes, I worked part-time at a bookstore last summer. I helped customers find books and arranged shelves, three days a week. At first it was tiring, but I enjoyed it because I met interesting people. Also, the extra money allowed me to buy my own laptop. If I get the chance, I would like to work again during the next holiday.',
        ),
        _q(
          'What skills can students learn from working while they study?',
          'Students can learn many practical skills. First, they learn time management, because they must balance work and classes. They also develop communication skills by talking with customers and coworkers. For example, my friend who works in a cafe became much more confident when speaking to strangers. In addition, working teaches responsibility, which employers value highly.',
        ),
        _q(
          'Do you think students should manage their own budget, or should their parents help?',
          'I believe students should manage their own budget, with some support from parents at the beginning. When you control your money, you learn to make careful choices, such as cooking at home instead of eating out. For instance, I make a list of expenses every month, which helps me save. However, parents can give advice and help in emergencies, so it is a shared responsibility.',
        ),
        _q(
          'Some universities pay students to work on campus instead of giving scholarships. What do you think about that?',
          'I think it has both advantages and disadvantages. On the positive side, students earn money and gain experience, for example by working in the library or in a laboratory. However, working long hours may reduce the time they need for studying. A scholarship gives students more freedom to focus on learning. Ideally, a university should offer both options so students can choose.',
        ),
      ],
    ),
  ];
}