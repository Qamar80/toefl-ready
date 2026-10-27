import 'dart:math';
import 'writing_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOW TO ADD A NEW TEST
//   1. Copy any `_t(...)` block at the bottom of `tests`.
//   2. Give it the next number. The store tracks used tests by id ("w11"...).
//   3. Build a Sentence: _b(context, 'chunk|chunk|chunk', '.', [alternatives])
//      - write the chunks in the CORRECT order; they are shuffled at runtime
//      - the first chunk should start with a capital letter
//      - `alts` = other full sentences that are also correct (optional)
// ─────────────────────────────────────────────────────────────────────────────

BuildItem _b(String ctx, String chunks, String end, [List<String> alts = const []]) =>
    BuildItem(context: ctx, chunks: chunks.split('|'), end: end, alts: alts);

EmailTask _email(String to, String subject, String scenario, List<String> points, String sample) =>
    EmailTask(to: to, subject: subject, scenario: scenario, points: points, sample: sample);

DiscussionTask _disc(String field, String prof, String q, String n1, String t1, String n2, String t2, String sample) =>
    DiscussionTask(
        field: field, professor: prof, question: q, s1Name: n1, s1Text: t1, s2Name: n2, s2Text: t2, sample: sample);

WritingTest _t(int n, List<BuildItem> b, EmailTask e, DiscussionTask d) =>
    WritingTest(id: 'w$n', number: n, builds: b, email: e, discussion: d);

class WritingBank {
  static int get maxTests => tests.length;

  /// Random unused test, or null when every test has been taken.
  static WritingTest? pick(Set<String> used, Random r) {
    final pool = tests.where((t) => !used.contains(t.id)).toList();
    if (pool.isEmpty) return null;
    return pool[r.nextInt(pool.length)];
  }

  static final List<WritingTest> tests = [
    // ═══════════════════════════ TEST 1 ═══════════════════════════
    _t(
      1,
      [
        _b('Why are you late?', 'I missed|the bus|because|it left|early', '.'),
        _b('What did the professor say about the exam?', 'She said|that the exam|will cover|the first|four chapters', '.'),
        _b('Do you know where the library is?', 'It is|next to|the science|building', '.'),
        _b('Can you help me with my homework?', 'I would be|happy to|help you|after dinner', '.'),
        _b('How long have you studied English?', 'I have studied|English|for almost|five years', '.'),
        _b('What are you doing this weekend?', 'I am going|to visit|my grandparents|in the countryside', '.'),
        _b('Which course should I take next semester?', 'You should|take|the course|that Professor Lee|teaches', '.'),
        _b('Did you finish the report?', 'Not yet,|but I|will send it|to you|tomorrow', '.'),
        _b('Why did you choose this university?', 'I chose it|because|its engineering|program|is excellent', '.'),
        _b('Could you tell me what time the lab opens?', 'The lab|opens|at nine|every morning', '.',
            ['The lab opens every morning at nine.']),
      ],
      _email(
        'Professor Harris',
        "Missing Thursday's lecture",
        "You have to travel for a family wedding and will miss Thursday's lecture in Professor Harris's History 201 course. Write an email to the professor.",
        [
          'Explain why you will be absent',
          'Ask how you can get the lecture notes and slides',
          'Offer to hand in the weekly assignment early',
        ],
        "Dear Professor Harris,\n\nI am writing to let you know that I will not be able to attend Thursday's lecture because I have to travel to my cousin's wedding out of town. I am sorry for the inconvenience.\n\nCould you please tell me how I can get the lecture notes and slides? I would also be glad to submit this week's assignment early, on Wednesday, so that I do not fall behind.\n\nThank you for your understanding.\n\nSincerely,\nAlex",
      ),
      _disc(
        'Urban Studies',
        'Dr. Morales',
        'Several large cities have banned private cars from their downtown areas to reduce pollution and traffic. Do you think this is a good idea? Why or why not?',
        'Priya',
        'I support it. Cleaner air improves everyone\'s health, and people walk and shop more when the streets are safe and quiet.',
        'Daniel',
        'I am worried about it. Small shops depend on drivers, and elderly or disabled people may find it hard to get downtown.',
        "I agree with Priya that car-free centers are healthier, but Daniel raises a fair concern about accessibility. I think the ban works best when cities prepare first. For example, they can build frequent, cheap buses and keep a few drop-off zones for people who cannot walk far. Another benefit nobody mentioned is that quieter streets attract cafes and street performers, which can bring in more customers than parked cars ever did. Without a good transport plan the ban could hurt shops, but with one it can improve both the economy and public health.",
      ),
    ),

    // ═══════════════════════════ TEST 2 ═══════════════════════════
    _t(
      2,
      [
        _b('Where is the new student center?', 'It is|located|across from|the main|parking lot', '.'),
        _b('Why did you miss the lecture?', 'I had|a high fever|so I|stayed in bed', '.'),
        _b('What does the assignment require?', 'We have to|write|a short essay|about climate change', '.'),
        _b('Have you ever visited Canada?', 'No, but|I would like|to go|there someday', '.'),
        _b('Could you tell me when the bus arrives?', 'The bus|usually arrives|around|a quarter past|eight', '.'),
        _b('How do you get to campus?', 'I usually|ride my bike|unless|it is raining', '.'),
        _b('What did the teacher give you?', 'She gave me|a list of|books to read|over the break', '.'),
        _b('Is the museum open on Mondays?', 'Unfortunately,|it is|closed|on Mondays|and Tuesdays', '.'),
        _b('Do you want to join our study group?', 'I would love to,|but|I have|a part-time job|on Wednesdays', '.'),
        _b('What are you looking for?', 'I am looking for|a quiet place|where I can|study', '.'),
      ],
      _email(
        'Mr. Collins (Landlord)',
        'Heater not working in apartment 4B',
        'The heater in your apartment stopped working three days ago and the weather is getting cold. Write an email to your landlord.',
        [
          'Describe the problem and how long it has lasted',
          'Ask when someone can come to repair it',
          'Say what you need in the meantime',
        ],
        "Dear Mr. Collins,\n\nI am writing about the heater in apartment 4B. It stopped working three days ago, and the rooms have become very cold, especially at night.\n\nCould you please let me know when a technician can come to repair it? I am home after 4 p.m. on weekdays and all day on Saturday.\n\nUntil it is fixed, I would appreciate it if you could lend me a small electric heater or other temporary solution.\n\nThank you for your help.\n\nBest regards,\nMaria Lopez",
      ),
      _disc(
        'Education',
        'Professor Kim',
        'Many universities now offer entire degree programs online. Do you think online learning is as good as attending classes in person? Explain your opinion.',
        'Emma',
        'Online classes are great because I can learn at my own pace and still keep my job.',
        'Liam',
        'I prefer being on campus. Talking with classmates and teachers keeps me motivated and helps me understand difficult ideas.',
        "I partly agree with both classmates. Emma is right that online classes give flexibility, which matters for students who work. However, like Liam, I believe in-person classes create stronger motivation. When I study alone, I often postpone assignments, but when I know classmates are waiting for me in a room, I prepare. In addition, labs and group projects are hard to copy online. In my opinion, a mix works best: lectures online so students save time, and discussions and practical work on campus. That way students get both convenience and human contact.",
      ),
    ),

    // ═══════════════════════════ TEST 3 ═══════════════════════════
    _t(
      3,
      [
        _b('What time does the concert start?', 'The concert|starts|at seven|and ends|at ten', '.'),
        _b('Who wrote this article?', 'It was written|by a professor|from our|history department', '.'),
        _b('Why is the cafeteria so crowded?', 'Many students|are having|lunch|before|the exam', '.'),
        _b('Did you enjoy the field trip?', 'Yes,|it was|the most|interesting trip|I have ever taken', '.'),
        _b('What should I bring to the lab?', 'You need|to bring|a notebook|and safety glasses', '.',
            ['You need to bring safety glasses and a notebook.']),
        _b('Could you explain how the printer works?', 'You simply|insert|your card|and press|the green button', '.'),
        _b('How was your weekend?', 'It was relaxing|because|I did|not have|any homework', '.'),
        _b('Where did you buy that jacket?', 'My sister|bought it|for me|in Italy', '.',
            ['My sister bought it in Italy for me.']),
        _b('When will the results be announced?', 'They will be|posted online|by the end|of next week', '.'),
        _b('Why do you want to study biology?', 'I have always|been fascinated|by how|living things|work', '.'),
      ],
      _email(
        'Ms. Rivera, Film Club Advisor',
        'Proposal for a documentary night',
        'You are a member of the university film club and want to organize a special evening of student documentaries. Write an email to the club advisor.',
        [
          'Describe the event and explain why it would be popular',
          'Suggest a date and a place',
          'Ask what permission or equipment you will need',
        ],
        "Dear Ms. Rivera,\n\nI would like to propose a documentary night where club members show short films they made themselves. I think many students would come, because it would give them a chance to see their friends' work and discuss it afterwards.\n\nWe could hold the event on Friday, November 14, in Lecture Hall B, which has a large screen.\n\nCould you tell me what permission we need from the student office and whether the club can borrow a projector and speakers?\n\nThank you very much for considering this idea.\n\nSincerely,\nKenji Mori",
      ),
      _disc(
        'Linguistics',
        'Dr. Okafor',
        'Some universities require every student, whatever their major, to study a second language. Do you think this requirement is a good idea? Why or why not?',
        'Sofia',
        'Yes. Knowing another language opens career options and helps you understand other cultures.',
        'Marcus',
        'I disagree. Engineering students already have a heavy workload, and forcing them to take language classes wastes time they need for their field.',
        "Sofia makes a strong point about careers, but I understand Marcus's concern about workload. My view is that the requirement is useful if it is flexible. Students could choose a language that fits their goals, and the classes could focus on practical conversation instead of grammar tests. Learning a language also trains memory and problem-solving, which helps in technical subjects too. Finally, many engineering companies work with partners abroad, so a second language can make a graduate more valuable. A light, well-designed requirement would therefore benefit students rather than burden them.",
      ),
    ),

    // ═══════════════════════════ TEST 4 ═══════════════════════════
    _t(
      4,
      [
        _b('Can I borrow your dictionary?', 'Of course,|but please|return it|before Friday', '.'),
        _b('What is your major?', 'I am majoring|in economics|and minoring|in statistics', '.'),
        _b('What happened to the meeting?', 'It was|postponed|until|next Monday', '.'),
        _b('Do you like living in the dormitory?', 'It is|convenient,|although|it can|be noisy', '.'),
        _b('How can I improve my writing?', 'You should|read|more articles|and practice|every day', '.'),
        _b('What did the manager decide?', 'He decided|to hire|two more|assistants|for the summer', '.'),
        _b('Where can I find the schedule?', 'You can|download it|from|the university|website', '.'),
        _b('Has the package arrived yet?', 'I have|not received|it,|so I|will call the store', '.'),
        _b('What is the lecture about?', 'The speaker|will discuss|how|ancient cities|were built', '.'),
        _b('Why are you so tired?', 'I stayed up|late|finishing|my presentation', '.'),
      ],
      _email(
        'Campus Library Help Desk',
        'Lost library book',
        'You borrowed a book from the university library but now you cannot find it. Write an email to the library.',
        [
          'Say which book it is and when you borrowed it',
          'Explain what you think happened',
          'Ask what you should do and whether you will have to pay',
        ],
        "Hello,\n\nI am writing about a book I borrowed on September 20, called Introduction to Microeconomics. I have looked everywhere in my room, but I cannot find it. I think I may have left it on a bus last week.\n\nCould you please tell me what I should do next? I would also like to know whether I will have to pay a fee and how much it would be.\n\nI apologize for the trouble and I look forward to your reply.\n\nKind regards,\nSamira Khan",
      ),
      _disc(
        'Business',
        'Professor Bell',
        'Many companies now allow employees to work from home several days a week. Do you think working from home is better for employees and companies than working in an office?',
        'Hannah',
        'It is better. Employees save hours of commuting and can use that time to rest or be with family.',
        'Omar',
        'I am not sure. Teams share ideas more easily when they are in the same room, and new employees learn faster from watching others.',
        "I think working from home is better for most employees, though Omar is right about teamwork. As Hannah says, avoiding a long commute gives people more energy, and happier employees usually work harder. Companies also save money on office space. To solve the problem Omar describes, a company can ask everyone to come to the office one or two days a week for meetings and training. Another advantage is that firms can hire talented people who live far away. Overall, a hybrid schedule gives the benefits of both ways of working.",
      ),
    ),

    // ═══════════════════════════ TEST 5 ═══════════════════════════
    _t(
      5,
      [
        _b('Does this train go to the airport?', 'No,|you need|to take|the express|line', '.'),
        _b('What do you think of the new policy?', 'I think|it will|make|campus life|easier', '.'),
        _b('Where were you yesterday?', 'I was|at the clinic|for|a routine check-up', '.'),
        _b('Could you recommend a good novel?', 'I highly recommend|the book|that|I just|finished', '.'),
        _b('What does the sign say?', 'It says|that|visitors|must wear|badges', '.'),
        _b('Who is giving the presentation?', 'The director|of the|research center|will give it', '.'),
        _b('How much does the course cost?', 'The fee|is|two hundred dollars|per semester', '.'),
        _b('Why did the shop close?', 'The owner|retired|after|thirty years|in business', '.'),
        _b('Do you have any plans for the summer?', 'I am hoping|to find|an internship|at a hospital', '.'),
        _b('Is it safe to drink the tap water?', 'Yes,|it is|tested|regularly|by the city', '.'),
      ],
      _email(
        'Dr. Nguyen',
        'Letter of recommendation request',
        'You are applying for a scholarship and want your former professor to write a letter of recommendation. Write an email to the professor.',
        [
          'Remind the professor which class you took and when',
          'Explain what the scholarship is and when the deadline is',
          'Offer to send your resume and a summary of your achievements',
        ],
        "Dear Dr. Nguyen,\n\nI hope you are well. I took your Environmental Science course in the spring semester last year, and I really enjoyed your field project on river pollution.\n\nI am now applying for the Global Leaders Scholarship, and the deadline is December 1. I would be very grateful if you could write a letter of recommendation for me.\n\nI can send you my resume and a short summary of my achievements so that the letter is easier to write.\n\nThank you for considering my request.\n\nSincerely,\nDavid Chen",
      ),
      _disc(
        'Art History',
        'Dr. Chen',
        'Some people believe national museums should be free for everyone, while others think visitors should pay an entrance fee. Which do you agree with, and why?',
        'Nina',
        'Museums should be free. Art and history belong to everyone, not only to people who can afford a ticket.',
        'Tom',
        'Free entry sounds nice, but museums need money to protect their collections, and a small fee is a fair way to get it.',
        "I agree with Nina that museums should be open to everyone, but Tom is right that they need funding. I think the best solution is free entry for the permanent collection, paid tickets for special exhibitions, and donations from visitors who want to give. In some countries this model already works well. In addition, free museums attract school groups, and children who visit early often become supporters of culture as adults. The government can then cover the basic costs, because a museum is a public service just like a library or a park.",
      ),
    ),

    // ═══════════════════════════ TEST 6 ═══════════════════════════
    _t(
      6,
      [
        _b("I'm new here and a little lost.", 'Do you know|where|the admissions|office is|located', '?'),
        _b('I need some advice.', 'Could you tell me|how|I can|register|for the course', '?'),
        _b('The exam is next week.', 'Have you|started|studying|for it|yet', '?'),
        _b('I heard you moved recently.', 'How do you|like|your new|apartment', '?'),
        _b('My laptop broke yesterday.', 'Where can|I get|it|repaired|nearby', '?'),
        _b('I want to join a club.', 'Which clubs|are|open|to first-year|students', '?'),
        _b('The talk was really interesting.', 'Did you|understand|everything|the speaker|said', '?'),
        _b('I will be away next month.', 'Who|will|take care|of|your plants', '?'),
        _b('We have a group project.', 'When|should|we|schedule|our first meeting', '?'),
        _b('My friend just changed her major.', 'What made|her decide|to study|psychology', '?'),
      ],
      _email(
        'Your group members',
        'Change of meeting plan',
        'You are the leader of a group project. The room you booked for tomorrow has been cancelled. Write an email to your group members.',
        [
          'Explain the problem',
          'Suggest a new time and place',
          'Remind everyone what they must prepare',
        ],
        "Hi everyone,\n\nI have some bad news: the study room we booked for tomorrow afternoon has been cancelled because of a maintenance problem.\n\nI suggest we meet on Thursday at 3 p.m. in the student cafe next to the library. It has large tables and free Wi-Fi.\n\nPlease remember to bring your part of the presentation slides and a list of the sources you used. If Thursday does not work for you, reply today and we will find another time.\n\nThanks,\nJulia",
      ),
      _disc(
        'Psychology',
        'Professor Adams',
        'Some researchers claim that heavy use of social media shortens people\'s attention span. Do you agree that social media is harmful to concentration? Explain your view.',
        'Leila',
        'Yes. I check my phone constantly, and I find it hard to read a whole chapter without interruptions.',
        'Ben',
        'I do not think it is the main problem. Social media also helps me learn new skills through short tutorials.',
        "Leila describes a real problem, and I have the same habit. Notifications are designed to pull our attention away, so after each interruption it takes minutes to focus again. However, I agree with Ben that social media is not harmful in itself. The real issue is how we use it. I started turning off notifications while studying and keeping my phone in another room, and my reading time improved a lot. So I believe social media can damage concentration when it is used without limits, but students can control this with simple rules and self-discipline.",
      ),
    ),

    // ═══════════════════════════ TEST 7 ═══════════════════════════
    _t(
      7,
      [
        _b('Why was the flight delayed?', 'Heavy snow|made|it|impossible|to take off', '.'),
        _b('What would you do with extra time?', 'I would|spend|it|volunteering|at an animal shelter', '.'),
        _b('Is your sister older than you?', 'She is|three years|older|than I am', '.'),
        _b('Did the team win?', 'They played|so well|that|the crowd|cheered loudly', '.'),
        _b('Who helped you move?', 'My cousins|came|over|and helped|me carry the boxes', '.'),
        _b('What is the weather like today?', 'It is|cloudy,|but|it is|not very cold', '.'),
        _b('What does your neighbor do?', 'He works|as|an engineer|for|a software company', '.'),
        _b('How did you hear about the job?', 'A friend|who works|there|told me|about it', '.'),
        _b('Why should I read this book?', 'It will|change|the way|you think|about money', '.'),
        _b('Did you find your wallet?', 'Luckily,|a stranger|had|found it|and returned it', '.'),
      ],
      _email(
        'Jordan (your roommate)',
        'Noise at night',
        'Your roommate often plays loud music late at night while you are trying to sleep. You want to solve the problem politely. Write an email to your roommate.',
        [
          'Explain how the noise affects you',
          'Suggest a specific solution',
          'Invite your roommate to share their opinion',
        ],
        "Hi Jordan,\n\nI wanted to talk to you about the music at night. Lately it has been very loud after midnight, and I am having trouble sleeping before my early classes.\n\nWould it be possible to use headphones after 11 p.m.? On weekends, of course, I do not mind a little noise until later.\n\nI hope this sounds fair to you. Please tell me what you think, and if there is anything I can do to make the apartment more comfortable for you too.\n\nThanks for understanding,\nTaylor",
      ),
      _disc(
        'Education',
        'Dr. Santos',
        'Some school districts want to start the high school day later in the morning. Do you think high schools should start later? Why or why not?',
        'Chloe',
        'Definitely. Teenagers need more sleep, and tired students cannot learn well at 7:30 in the morning.',
        'Ravi',
        'A later start would end the day later, and many students have sports practice or jobs after school.',
        "Chloe is right that teenagers need more sleep, and research on adolescent sleep supports her. Ravi's point about sports and jobs is also important, but I think schools can adjust. For example, practices could be moved to the early evening, and students with jobs could ask for later shifts. A later start may also reduce mistakes, since students would be more alert in the first class. I would add that parents who drive their children to school often find a later start easier too. Overall, the health and learning benefits are worth the schedule changes.",
      ),
    ),

    // ═══════════════════════════ TEST 8 ═══════════════════════════
    _t(
      8,
      [
        _b('Where will the ceremony be held?', 'It will|take place|in the|main auditorium', '.'),
        _b('What is the deadline for applications?', 'Applications|must be|submitted|by|March first', '.'),
        _b('Is the museum worth visiting?', 'Absolutely,|its|collection|of paintings|is remarkable', '.'),
        _b('How was the interview?', 'It went|better|than|I had|expected', '.'),
        _b('What did you eat for lunch?', 'I had|a sandwich|and|a bowl|of soup', '.'),
        _b('Why are prices rising?', 'Costs|for|raw materials|have|increased sharply', '.'),
        _b('Who is the woman in the photo?', 'She is|the scientist|who|discovered|the new species', '.'),
        _b('Can you work on Saturday?', 'I can,|as long as|I am|home|by six', '.'),
        _b('What should we do about the noise?', 'We should|ask|the neighbors|to keep|it down', '.'),
        _b('When did you learn to swim?', 'I learned|when|I was|only|five years old', '.'),
      ],
      _email(
        'Mr. Patel, Volunteer Coordinator',
        'Question about volunteering at the food bank',
        'You saw an announcement that the community food bank needs volunteers and you would like to help. Write an email to the volunteer coordinator.',
        [
          'Say why you are interested in volunteering',
          'Describe when you are available',
          'Ask about training and what to bring or wear',
        ],
        "Dear Mr. Patel,\n\nI saw your announcement on the campus noticeboard, and I would like to volunteer at the community food bank. I think it is important to help families who struggle to buy enough food, and I want to do something useful for my neighborhood.\n\nI am available on Saturday mornings and on Tuesday evenings.\n\nCould you tell me whether there is any training before I start, and what I should wear or bring on my first day?\n\nThank you for your time.\n\nSincerely,\nAisha Rahman",
      ),
      _disc(
        'Economics',
        'Professor Lee',
        'Governments spend billions of dollars on space exploration each year. Some people say this money should be used to solve problems on Earth instead. What is your opinion?',
        'Maya',
        'I think the money should go to hospitals, schools, and clean energy. Problems on Earth are more urgent than discoveries in space.',
        'Peter',
        'Space programs create new technology that helps everyone, like satellites for weather forecasts and GPS.',
        "Maya has a fair point about urgent needs, but I find Peter's argument more convincing. Space research has produced many everyday benefits, such as satellite communication and medical imaging improvements. Also, the space budget is very small compared with what governments spend on defense or healthcare, so cutting it would not solve big social problems. Another reason to continue is that exploring other planets may teach us how to protect our own climate. Of course, governments should make sure the money is spent wisely, but I believe space exploration is a good long-term investment.",
      ),
    ),

    // ═══════════════════════════ TEST 9 ═══════════════════════════
    _t(
      9,
      [
        _b('How do I get a library card?', 'You must|show|your student|ID|at the desk', '.'),
        _b('What is the capital of Australia?', 'The capital|is|Canberra,|not|Sydney', '.'),
        _b('Why did the experiment fail?', 'The samples|had been|stored|at|the wrong temperature', '.'),
        _b('Do you cook often?', 'I try|to cook|at home|at least|four times a week', '.'),
        _b('Which road should we take?', 'The highway|is|faster,|but|it is more expensive', '.'),
        _b('What are your goals for this year?', 'I want|to improve|my English|and|save some money', '.'),
        _b('Why is she so happy?', 'She just|found out|that|she won|a scholarship', '.'),
        _b('How long is the film?', 'It lasts|nearly|three hours|including|the intermission', '.'),
        _b('Is there anything I can do to help?', 'You could|set|the tables|while|I finish cooking', '.'),
        _b('What does the committee want?', 'They want|us|to submit|a revised|proposal', '.'),
      ],
      _email(
        'Customer Service, BrightMart Online',
        'Wrong item received - order #58219',
        'You ordered a blue backpack from an online store, but you received a black one. Write an email to customer service.',
        [
          'State your order number and explain the problem',
          'Say what you would like the store to do',
          'Explain when you need the correct item',
        ],
        "Dear Customer Service,\n\nI am writing about order #58219. I ordered a blue backpack, but the package I received today contains a black one.\n\nI would like you to send me the correct blue backpack, and please tell me how to return the wrong one. I am happy to pay for the return shipping if necessary.\n\nI need the backpack before September 15, when my classes begin, so I would appreciate a quick reply.\n\nThank you for your help.\n\nSincerely,\nLucas Meyer",
      ),
      _disc(
        'Career Studies',
        'Dr. Walker',
        'Some people think an internship prepares students for work better than extra university courses. Which do you think is more valuable? Explain your answer.',
        'Isabel',
        'Internships are better. You learn how workplaces really operate and you build contacts who can help you find a job.',
        'Carlos',
        'I think courses matter more. Without a solid theoretical base, you cannot understand what you are doing at work.',
        "I see value in both views, but I lean toward Isabel's opinion. In an internship, students face real deadlines and real clients, which teaches communication and responsibility in a way a classroom cannot. Carlos is right that theory is essential; however, students can usually learn it alongside work, and an internship often makes the theory easier to understand because it gives it a context. Moreover, employers often prefer applicants with experience. If I had to choose, I would take one internship before graduation and then return to courses with clearer goals.",
      ),
    ),

    // ═══════════════════════════ TEST 10 ═══════════════════════════
    _t(
      10,
      [
        _b('How does the app work?', 'You take|a photo,|and|it identifies|the plant', '.'),
        _b('What did you learn from the course?', 'I learned|how|to analyze|data|using spreadsheets', '.'),
        _b('Why do you prefer the morning?', 'I can|concentrate|better|before|the day gets busy', '.'),
        _b('Were you surprised by the results?', 'Not really,|since|we had|predicted|them', '.'),
        _b('Where should we meet?', 'Let us|meet|in front of|the|bookstore', '.'),
        _b('How did the museum change?', 'It now|offers|free admission|on|the first Sunday of each month', '.'),
        _b('Is it too late to apply?', 'The deadline|has passed,|but|you can|still email the office', '.'),
        _b('What makes this city special?', 'It combines|modern buildings|with|a rich|history', '.'),
        _b('Which option is cheaper?', 'Renting|a car|costs|less|than taking taxis', '.'),
        _b('Do you have any questions?', 'Yes, I wonder|whether|the exam|will|include essays', '.'),
      ],
      _email(
        'Campus Housing Office',
        'Request to change rooms',
        'Your dormitory room is next to a construction site that is very noisy during the day. Write an email to the housing office to ask for a different room.',
        [
          'Describe the problem',
          'Say what kind of room you would like',
          'Ask about the process and when you could move',
        ],
        "Dear Housing Office,\n\nI live in room 312 of Oak Hall, and I am writing to ask for a room change. Construction work next to the building starts at 7 a.m. and continues all day, so it is almost impossible to study or rest.\n\nI would prefer a room on the other side of the building or in a different hall, preferably on a higher floor.\n\nCould you please tell me what the process is and how soon I could move? I can complete any forms this week.\n\nThank you for your assistance.\n\nBest regards,\nMia Anderson",
      ),
      _disc(
        'Business Ethics',
        'Professor Grant',
        'More and more companies use artificial intelligence to screen job applicants before any person reads their applications. Do you think this is a good practice? Why or why not?',
        'Zoe',
        'It is a good idea. A computer can review hundreds of applications quickly and does not get tired or have personal preferences.',
        'Andrew',
        'I disagree. AI learns from past hiring data, so it can repeat old unfair patterns and reject good candidates by mistake.',
        "Zoe is right that AI saves time, but Andrew's warning worries me more. If a system learns from past decisions that were biased, it will copy that bias, and applicants will not even know why they were rejected. I think companies can use AI for simple tasks such as organizing applications, while a human recruiter should make the final decision. Companies should also test their systems regularly and let applicants ask for a review. In this way they can keep the speed that Zoe mentions without losing fairness.",
      ),
    ),
  ];
}