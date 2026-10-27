import 'dart:math';
import 'reading_models.dart';

const _main = 'Main idea';
const _detail = 'Detail';
const _vocab = 'Vocabulary';
const _inf = 'Inference';
const _purpose = 'Purpose';

/// [right] is always the correct option; options are shuffled at runtime.
McqItem _m(String type, String text, String right, List<String> wrong, String why) =>
    McqItem(type: type, text: text, options: [right, ...wrong], correct: 0, explanation: why);

ReadingTask _ctw(String id, int level, String title, String body) => ReadingTask(
    id: id, type: TaskType.completeWords, level: level, title: title, kind: 'Academic paragraph', body: body);

ReadingTask _rdl(String id, int level, String kind, String title, String body, List<McqItem> qs) => ReadingTask(
    id: id, type: TaskType.dailyLife, level: level, title: title, kind: kind, body: body, questions: qs);

ReadingTask _ap(String id, int level, String topic, String title, String body, List<McqItem> qs) => ReadingTask(
    id: id, type: TaskType.academic, level: level, title: title, kind: topic, body: body, questions: qs);

class ReadingBank {
  /// Each full test uses 2 medium tasks of every kind in Module 1
  /// (1 Complete the Words, 2 Daily Life, 1 Academic), so the bank supports 2 tests.
  static const int maxTests = 2;

  /// Builds one module: [Complete the Words, Daily Life x2, Academic Passage].
  /// Picks unused tasks of [level] first and falls back to the nearest level.
  static List<ReadingTask>? module(int level, Set<String> used, Random r, {Set<String> exclude = const {}}) {
    List<ReadingTask>? take(TaskType t, int n, Set<String> taken) {
      final pool = tasks.where((x) => x.type == t && !used.contains(x.id) && !exclude.contains(x.id) && !taken.contains(x.id)).toList()
        ..shuffle(r)
        ..sort((a, b) => (a.level - level).abs().compareTo((b.level - level).abs()));
      return pool.length < n ? null : pool.take(n).toList();
    }

    final ctw = take(TaskType.completeWords, 1, {});
    final rdl = take(TaskType.dailyLife, 2, {});
    final ap = take(TaskType.academic, 1, {});
    if (ctw == null || rdl == null || ap == null) return null;
    return [...ctw, ...rdl, ...ap];
  }

  static final List<ReadingTask> tasks = [
    // ───────────────── Complete the Words ─────────────────
    _ctw('ctw1', 1, 'Seasons',
        'Seasons change because the Earth is tilted as it moves around the sun. When the north part of the Earth leans toward the sun, that region has summer. {Days} are {longer} and the {weather} is {warm}. Six months {later}, the same {region} leans {away}, so the {sun} is {lower} and the {winter} is cold.'),
    _ctw('ctw2', 1, 'Bicycles',
        'Bicycles are one of the most efficient ways to travel. A rider uses {less} energy than a walker to cover the same {distance}. In many {cities}, people {choose} bikes {because} they are {cheap}, {quiet}, and good for {health}. Cities that {build} safe {lanes} often see more riders.'),
    _ctw('ctw3', 2, 'Ocean currents',
        'Ocean currents move enormous amounts of water around the planet. Warm currents carry heat from the equator toward the poles, while cold currents flow in the opposite direction. This {exchange} of energy {helps} regulate {climate} in coastal {regions}. For {example}, the Gulf {Stream} {makes} northwestern Europe {much} warmer than other {places} at the same {latitude}.'),
    _ctw('ctw4', 2, 'Public libraries',
        'Public libraries have changed greatly over the past century. Once quiet places for {borrowing} books, they now offer {computers}, language {classes}, and community {events}. Many libraries also lend tools and {equipment}, which helps people who cannot {afford} to buy them. As a result, {librarians} {increasingly} act as {guides} to {information} rather than simply keepers of books.'),
    _ctw('ctw5', 3, 'Confirmation bias',
        'Psychologists have long observed that human judgment is shaped by systematic errors in thinking. One well-documented pattern, confirmation bias, leads people to {favor} evidence that {supports} their existing {beliefs} while {discounting} information that {contradicts} them. The {tendency} is {especially} {strong} when the {subject} is {emotionally} significant.'),
    _ctw('ctw6', 3, 'Urban heat islands',
        'Cities are often several degrees warmer than the surrounding countryside, a phenomenon known as the urban heat island effect. Dark surfaces such as asphalt and rooftops {absorb} sunlight and {release} it slowly as {heat}, while the {scarcity} of {vegetation} {limits} natural {cooling}. Planners {attempt} to {reduce} the effect by {planting} trees and installing reflective roofs.'),

    // ───────────────── Read in Daily Life ─────────────────
    _rdl('rdl1', 1, 'Notice', 'Library closing early',
        'The Main Library will close early on Friday, March 14, at 3:00 p.m. for staff training. Normal hours (8:00 a.m. to 9:00 p.m.) will resume on Saturday.\n\nBooks due on Friday may be returned on Saturday without a late fee. The online catalog will remain available all day.',
        [
          _m(_detail, 'Why will the library close early on Friday?', 'Staff will be in training', ['The building needs repairs', 'There is a public holiday', 'A book sale is being held'], 'The notice says the closing is for staff training.'),
          _m(_detail, 'What is stated about books due on Friday?', 'They can be returned on Saturday without a fee', ['They must be returned by 3:00 p.m.', 'They will be renewed automatically', 'They can only be returned online'], 'Books due Friday may be returned Saturday without a late fee.'),
        ]),
    _rdl('rdl2', 1, 'Text messages', 'Study group tonight',
        'Maya: Are you coming to study group tonight?\nBen: I want to, but my bus was cancelled.\nMaya: We moved it to room 204. It starts at 7.\nBen: Okay. I will take a taxi and be there by 7:15.\nMaya: No problem. We will save you a seat.',
        [
          _m(_detail, 'Why might Ben be late?', 'His bus was cancelled', ['He forgot the time', 'He is feeling sick', 'The room changed'], 'Ben says his bus was cancelled, so he will take a taxi.'),
          _m(_inf, 'What does Maya mean by "We will save you a seat"?', 'They expect him to come and will make room', ['She wants him to find another group', 'The room will be full', 'She is leaving early'], 'Saving a seat shows they will welcome him even if he is late.'),
        ]),
    _rdl('rdl3', 1, 'Email', 'Your gym membership',
        'Hi Carlos,\n\nThank you for joining Fit Centre! Your membership starts on Monday, April 1. Please bring a photo ID to the front desk to collect your key card. Classes are free for members, but you must reserve a spot online at least one hour before class starts.\n\nBest wishes,\nAnna, Member Services',
        [
          _m(_detail, 'What should Carlos bring to collect his key card?', 'A photo ID', ['A payment receipt', 'A printed copy of this email', 'A towel'], 'The email asks him to bring a photo ID.'),
          _m(_detail, 'What must members do to attend a class?', 'Reserve a spot online in advance', ['Pay an extra fee', 'Call Member Services', 'Arrive an hour early'], 'Members must reserve online at least an hour before class.'),
        ]),
    _rdl('rdl4', 1, 'Flyer', 'Community Garden Volunteer Day',
        'Join us on Saturday, May 10, from 9 a.m. to noon. We will plant vegetables, build new garden beds, and clean tools. No experience is needed.\n\nGloves and water are provided, but please wear closed shoes. Volunteers will receive a free bag of fresh vegetables. Register at the garden gate or online.',
        [
          _m(_purpose, 'What is the main purpose of the flyer?', 'To invite people to volunteer', ['To sell vegetables', 'To announce a cooking class', 'To report that the garden is closing'], 'The flyer invites people to join a volunteer day.'),
          _m(_detail, 'What will volunteers receive?', 'A free bag of vegetables', ['A garden key', 'A set of new tools', 'A certificate'], 'The flyer says volunteers get a free bag of fresh vegetables.'),
        ]),
    _rdl('rdl5', 2, 'Email', 'Change to assignment deadline',
        'Dear students,\n\nBecause of the campus network outage last week, the deadline for Essay 2 has been extended from Monday, October 6 to Thursday, October 9. All essays must still be submitted through the course website; emailed copies will not be accepted.\n\nIf you have already submitted, you do not need to take any action. Please note that the quiz scheduled for Thursday has not been moved.\n\nProfessor Lindgren',
        [
          _m(_detail, 'Why was the deadline extended?', 'The campus network was down', ['The professor was traveling', 'Students asked for more time', 'The essay topic changed'], 'The email blames the campus network outage.'),
          _m(_inf, 'What can be inferred about students who already submitted?', 'Their essays are accepted as they are', ['They must submit again', 'They will lose points', 'They must email a copy'], 'They need to take no action, so their submissions stand.'),
          _m(_detail, 'What is still happening on Thursday?', 'The quiz', ['A workshop on Essay 2', 'Office hours', 'Website maintenance'], 'The quiz has not been moved.'),
        ]),
    _rdl('rdl6', 2, 'Advertisement', 'Riverside Apartments',
        'Studio and one-bedroom apartments available starting June 1. Rent includes water, heating, and high-speed internet. Residents enjoy a rooftop terrace, secure bike storage, and a fitness room.\n\nPets under 20 pounds are welcome with a one-time \$200 deposit. Leases begin at 12 months; shorter terms are available at a higher monthly rate. Call 555-0142 to schedule a tour.',
        [
          _m(_detail, 'What is included in the rent?', 'Water, heating, and internet', ['Electricity and parking', 'Gym classes', 'Furniture'], 'The ad lists water, heating, and high-speed internet.'),
          _m(_inf, 'Who would probably pay the extra deposit?', 'A tenant with a 15-pound dog', ['A tenant with a bicycle', 'A tenant with a 12-month lease', 'A tenant who takes a tour'], 'The deposit applies to pets under 20 pounds.'),
          _m(_inf, 'What is suggested about leases shorter than 12 months?', 'They cost more each month', ['They are not allowed', 'They are free of deposits', 'They require a tour first'], 'Shorter terms are offered at a higher monthly rate.'),
        ]),
    _rdl('rdl7', 2, 'Schedule', 'Campus shuttle winter schedule',
        'Beginning December 1, the Blue Line shuttle will run every 20 minutes instead of every 10 minutes between 7 a.m. and 6 p.m. on weekdays. After 6 p.m., service will continue every 30 minutes until midnight.\n\nThere is no shuttle service on weekends, but the Night Safety Escort remains available at all hours. Students can track shuttles in real time using the campus app.',
        [
          _m(_main, 'What is changing on December 1?', 'How often the shuttle runs during the day', ['Where the shuttle stops', 'Weekend service begins', 'The Night Safety Escort ends'], 'Daytime service changes from every 10 to every 20 minutes.'),
          _m(_inf, 'How often will the shuttle run at 8 p.m. on a Tuesday?', 'Every 30 minutes', ['Every 10 minutes', 'Every 20 minutes', 'It will not run'], 'After 6 p.m. service runs every 30 minutes until midnight.'),
          _m(_inf, 'What can a student use on Saturday night?', 'The Night Safety Escort', ['The Blue Line shuttle', 'An express shuttle', 'Nothing is available'], 'There is no weekend shuttle, but the escort is always available.'),
        ]),
    _rdl('rdl8', 2, 'Email', 'Group project meeting',
        'Hi everyone,\n\nI know we planned to meet on Wednesday, but the library study rooms are fully booked. I can reserve a room for Thursday at 4 p.m. instead. If that does not work, we could meet online on Wednesday evening.\n\nPlease reply by tomorrow so I can confirm the booking. Also, remember to upload your section of the slides to the shared folder before we meet.',
        [
          _m(_purpose, 'What is the main purpose of the email?', 'To suggest a new meeting time', ['To cancel the project', 'To assign sections of the slides', 'To ask for a new deadline'], 'The writer proposes Thursday or an online meeting.'),
          _m(_detail, 'Why can the group not use the library on Wednesday?', 'The study rooms are fully booked', ['The library is closed', 'The rooms are too noisy', 'The rooms are being repaired'], 'The email says the rooms are fully booked.'),
          _m(_detail, 'What should members do before the meeting?', 'Upload their slides', ['Reserve a room', 'Email the professor', 'Print their notes'], 'They are reminded to upload their section to the shared folder.'),
        ]),
    _rdl('rdl9', 3, 'Notice', 'Student housing policy update',
        'Dear residents,\n\nEffective January 1, guests staying overnight must be registered at the front desk at least 24 hours in advance. Unregistered guests will be asked to leave, and repeated violations may result in a fine.\n\nThis change follows an increase in security incidents and is not intended to restrict normal visits. Residents who have family visiting for extended periods should contact Housing Services to arrange temporary passes.',
        [
          _m(_detail, 'Why was the new policy introduced?', 'There were more security incidents', ['To reduce noise complaints', 'To raise money from fines', 'To meet fire regulations'], 'The notice says the change follows an increase in security incidents.'),
          _m(_inf, 'Why does the notice say the change "is not intended to restrict normal visits"?', 'To reassure residents', ['To discourage all visitors', 'To remove the fines', 'To make registration optional'], 'The sentence calms concerns that visits will be limited.'),
          _m(_detail, 'What should a resident do if relatives plan a long visit?', 'Contact Housing Services', ['Register them each day', 'Pay the fine in advance', 'Ask security for a pass'], 'Housing Services arranges temporary passes.'),
        ]),
    _rdl('rdl10', 3, 'Announcement', 'Member preview: Echoes of the Silk Road',
        'Museum members are invited to a private preview of the new exhibition on Thursday, September 18, from 6 to 8 p.m. Doors open at 5:30. Guests may bring one companion, but admission for additional guests must be purchased separately.\n\nThe exhibition features more than 200 artifacts, several of which have never been displayed publicly. Photography is permitted without flash. The exhibition opens to the general public on September 20.',
        [
          _m(_detail, 'Who is invited to the preview?', 'Museum members', ['The general public', 'Students only', 'Local artists'], 'The preview is for museum members.'),
          _m(_inf, 'What can be inferred about the artifacts?', 'Some will be seen by the public for the first time', ['All were previously displayed', 'All are on loan from other museums', 'None may be photographed'], 'Several have never been displayed publicly.'),
          _m(_detail, 'What is required for guests beyond one companion?', 'Separate admission tickets', ['A membership upgrade', 'Permission to use a flash', 'Arrival at 5:30'], 'Additional guests must buy admission separately.'),
        ]),
    _rdl('rdl11', 3, 'Email', 'Refund request #48213',
        'Dear Ms. Alvarez,\n\nThank you for contacting us. We are sorry that the headphones you received were defective. Our policy allows refunds within 30 days of delivery; however, since your request arrived on day 34, we are unable to issue a full refund.\n\nAs a gesture of goodwill, we can offer a replacement pair or a store credit equal to 80 percent of the purchase price. Please let us know your preference by Friday.',
        [
          _m(_detail, 'Why can the company not issue a full refund?', 'The request came after the refund period', ['The headphones were not defective', 'She did not keep the receipt', 'The headphones had been used'], 'The request arrived on day 34, past the 30-day limit.'),
          _m(_vocab, 'What does "a gesture of goodwill" mean here?', 'An offer made voluntarily', ['A legal requirement', 'A formal warning', 'A form of payment'], 'The company is offering something it is not obliged to give.'),
          _m(_detail, 'What does the company ask Ms. Alvarez to do?', 'Choose an option by Friday', ['Return the headphones today', 'Pay for shipping', 'Call customer service'], 'She is asked to share her preference by Friday.'),
        ]),
    _rdl('rdl12', 3, 'Course policy', 'Late work policy',
        'Assignments submitted within 24 hours of the deadline will lose 10 percent of the grade. Assignments submitted later than 24 hours will not be accepted unless the student obtained approval before the deadline.\n\nDocumented medical emergencies are exempt from this policy; students should submit documentation within one week. The lowest quiz score will be dropped, so students are encouraged not to request extensions for quizzes.',
        [
          _m(_inf, 'What happens to an assignment submitted 12 hours late?', 'It loses 10 percent of its grade', ['It is rejected', 'It receives full credit', 'It is treated as a quiz'], 'Work within 24 hours of the deadline loses 10 percent.'),
          _m(_detail, 'When could an assignment three days late be accepted?', 'If approval was obtained before the deadline', ['If the student apologizes', 'If it is submitted online', 'If it replaces a quiz'], 'Late work is accepted only with approval in advance (or a documented emergency).'),
          _m(_inf, 'Why are students discouraged from asking for quiz extensions?', 'The lowest quiz score is dropped', ['Quizzes are optional', 'Quizzes are graded pass or fail', 'Extensions are never allowed'], 'Since the lowest score is dropped, an extension is rarely needed.'),
        ]),

    // ───────────────── Read an Academic Passage ─────────────────
    _ap('ap1', 1, 'Biology', 'Why Leaves Change Color',
        'Each autumn, the leaves of many trees change from green to brilliant yellow, orange, and red. The green color comes from chlorophyll, a chemical that captures sunlight and helps the tree make food. During spring and summer, trees produce large amounts of chlorophyll, which hides other colors in the leaf.\n\nAs days grow shorter and temperatures fall, trees stop making chlorophyll. The green slowly disappears, revealing yellow and orange pigments that were present all along. Red colors are different. They come from sugars trapped in the leaf, which form a new pigment called anthocyanin in bright, cool weather.\n\nBecause weather varies from year to year, the intensity of autumn colors also varies. A season of sunny days and cool, dry nights usually produces the most vivid displays.',
        [
          _m(_main, 'What is the passage mainly about?', 'How and why leaves change color in autumn', ['How trees make food in spring', 'Why trees lose their leaves in winter', 'How weather damages trees'], 'The whole passage explains autumn color change.'),
          _m(_detail, 'According to the passage, what gives leaves their green color?', 'Chlorophyll', ['Anthocyanin', 'Yellow pigments', 'Trapped sugars'], 'Paragraph 1 names chlorophyll as the source of green.'),
          _m(_vocab, 'The word "vivid" in the passage is closest in meaning to', 'bright', ['faint', 'unusual', 'short'], 'Vivid displays of color are bright and intense.'),
          _m(_detail, 'How are red colors produced?', 'Trapped sugars form a new pigment', ['Chlorophyll turns red as it dies', 'Yellow pigments change in cold air', 'Trees absorb red pigment from soil'], 'Red comes from sugars that form anthocyanin.'),
          _m(_inf, 'What can be inferred about autumn colors?', 'They can differ from one year to the next', ['They are identical every year', 'They depend only on the tree species', 'They are brightest after rain'], 'The passage says intensity varies with the weather.'),
        ]),
    _ap('ap2', 1, 'History of technology', 'The Invention of the Bicycle',
        'The bicycle as we know it took nearly a century to develop. In 1817, a German inventor named Karl von Drais built a wooden machine with two wheels. Riders sat on it and pushed their feet against the ground to move forward, because it had no pedals. The machine was popular for a short time, but poor roads and its heavy weight made it uncomfortable.\n\nIn the 1860s, French inventors added pedals directly to the front wheel, which allowed riders to travel faster. To go even faster, makers increased the size of the front wheel, creating the "high-wheeler." These tall bicycles were dangerous, however, and falls were common.\n\nThe problem was solved in the 1880s with the "safety bicycle," which had two wheels of equal size and a chain connecting the pedals to the rear wheel. This design is the ancestor of the bicycles used today.',
        [
          _m(_purpose, 'How is the passage organized?', 'In the order in which the developments happened', ['By comparing two inventors', 'By listing problems with no solutions', 'By contrasting old and modern bicycles'], 'It moves from 1817 to the 1860s to the 1880s.'),
          _m(_detail, 'Why was Drais\'s machine uncomfortable?', 'Roads were poor and the machine was heavy', ['It had no wheels', 'It was too tall', 'It had no seat'], 'The passage cites poor roads and heavy weight.'),
          _m(_detail, 'Why did makers enlarge the front wheel?', 'To make bicycles go faster', ['To make them lighter', 'To reduce falls', 'To carry more riders'], 'A bigger front wheel allowed even more speed.'),
          _m(_vocab, 'The word "ancestor" is closest in meaning to', 'earlier form', ['competitor', 'replacement', 'opposite'], 'The safety bicycle is the earlier form of today\'s bikes.'),
          _m(_inf, 'What made the safety bicycle an improvement?', 'Equal-sized wheels and a chain drive made riding safer', ['A larger front wheel', 'A wooden frame', 'The first use of pedals'], 'It solved the danger of high-wheelers with equal wheels and a chain.'),
        ]),
    _ap('ap3', 2, 'Animal behavior', 'The Mystery of Bird Migration',
        'Every year, billions of birds travel thousands of kilometers between breeding grounds and wintering areas. For decades, scientists struggled to explain how such small animals find their way across unfamiliar landscapes. Research has since shown that birds rely on several navigational cues at once.\n\nDuring the day, many species use the position of the sun, adjusting for the time of day with an internal clock. At night, others orient by patterns of stars. Birds also appear to detect Earth\'s magnetic field, perhaps through light-sensitive proteins in their eyes, which gives them a compass that works even under cloudy skies.\n\nYoung birds migrating for the first time often follow instinctive directions inherited from their parents, but experienced birds improve their routes by learning landmarks such as coastlines and mountain ranges. This combination of inherited and learned information explains why first-year migrants are more likely to become lost than adults. Climate change now complicates the picture, since shifting seasons can cause birds to arrive after their food sources have peaked.',
        [
          _m(_main, 'Which statement best expresses the main idea?', 'Birds navigate using several cues combined with experience', ['Birds migrate only at night', 'Young birds navigate better than adults', 'Climate change has ended migration'], 'The passage describes multiple cues plus learning.'),
          _m(_detail, 'How might birds detect Earth\'s magnetic field?', 'Through light-sensitive proteins in their eyes', ['Through special bones in the wings', 'By smelling minerals', 'By following rivers'], 'Paragraph 2 mentions light-sensitive proteins in the eyes.'),
          _m(_vocab, 'The word "orient" in paragraph 2 is closest in meaning to', 'find their direction', ['gather in groups', 'rest', 'feed'], 'Birds use stars to find their direction.'),
          _m(_inf, 'Why are first-year migrants more likely to become lost?', 'They have less learned knowledge of landmarks', ['They cannot see the stars', 'They only fly at night', 'They have no inherited directions'], 'Experienced birds improve routes by learning landmarks.'),
          _m(_purpose, 'Why does the author mention climate change at the end?', 'To point out a new challenge for migrating birds', ['To prove the magnetic sense fails', 'To explain why young birds get lost', 'To argue that migration has stopped'], 'Shifting seasons can make birds miss peak food.'),
        ]),
    _ap('ap4', 2, 'Economics', 'Microfinance and Small Loans',
        'Traditional banks have long hesitated to lend to the very poor. Without property to offer as collateral, and with small sums involved, such loans seemed costly and risky. In the 1970s, the economist Muhammad Yunus began offering tiny loans to villagers in Bangladesh, often to women who wished to start small businesses such as weaving or selling food.\n\nInstead of requiring collateral, his bank organized borrowers into small groups whose members encouraged one another to repay. Repayment rates were surprisingly high, and the model, now called microfinance, spread to dozens of countries. Supporters argue that access to even modest credit allows families to invest in their businesses, send children to school, and withstand emergencies.\n\nCritics, however, point out that studies have found mixed results: while some borrowers prosper, many use the loans for daily expenses and struggle with debt, particularly when interest rates are high. As a result, many researchers now suggest that microfinance is most effective when combined with other support, such as training and savings programs.',
        [
          _m(_main, 'What is the passage mainly about?', 'The development of microfinance and the debate about its effects', ['How one economist became wealthy', 'Why banks avoid all loans', 'The history of education in Bangladesh'], 'It traces microfinance and weighs supporters and critics.'),
          _m(_detail, 'Why did traditional banks hesitate to lend to the poor?', 'Borrowers had no collateral and the sums were small', ['Governments forbade it', 'Poor borrowers never repaid', 'Banks did not operate in villages'], 'Paragraph 1 cites missing collateral and small sums.'),
          _m(_detail, 'How did Yunus\'s bank encourage repayment without collateral?', 'By organizing borrowers into supportive groups', ['By charging very high interest', 'By lending only to men', 'By requiring a savings deposit'], 'Group members encouraged one another to repay.'),
          _m(_vocab, 'The word "modest" in paragraph 2 is closest in meaning to', 'small', ['generous', 'uncertain', 'expensive'], 'Modest credit means a small amount of credit.'),
          _m(_inf, 'What can be inferred about the researchers in the last sentence?', 'They think loans alone are not always enough', ['They want microfinance to end', 'They believe interest rates do not matter', 'They think training harms borrowers'], 'They recommend pairing loans with training and savings programs.'),
        ]),
    _ap('ap5', 3, 'Ecology', 'Underground Fungal Networks',
        'Beneath a forest floor lies a vast web of fungal threads known as mycorrhizal networks. These fungi form partnerships with the roots of trees: the fungus extends the tree\'s reach for water and minerals, and in return receives sugars produced through photosynthesis.\n\nSome researchers have proposed that these networks also allow trees to share resources, with older "hub" trees supporting shaded seedlings by passing carbon through the fungal connections. Popular accounts have embraced this idea, describing forests as cooperative communities.\n\nYet several ecologists caution against such conclusions. Experiments demonstrating carbon transfer were often conducted in laboratory conditions, and it remains unclear whether the amounts transferred are large enough to benefit seedlings in natural settings. Moreover, the fungi may be acting in their own interest, redistributing resources in ways that favor the fungus rather than the trees. Consequently, while the existence of the networks is not in doubt, claims about their ecological significance should be treated as hypotheses awaiting stronger evidence.',
        [
          _m(_main, 'Which statement best summarizes the passage?', 'The networks exist, but their role in resource sharing is still debated', ['Trees cooperate through fungi in every forest', 'Fungi harm the trees they live on', 'Laboratory experiments have settled the question'], 'The passage separates the network\'s existence from its disputed significance.'),
          _m(_detail, 'What does the fungus receive from the tree?', 'Sugars from photosynthesis', ['Water', 'Minerals', 'Seedlings'], 'The fungus receives sugars in return for water and minerals.'),
          _m(_vocab, 'The word "embraced" in paragraph 2 is closest in meaning to', 'eagerly accepted', ['physically held', 'rejected', 'questioned'], 'Popular accounts readily adopted the idea.'),
          _m(_purpose, 'Why does the author mention laboratory conditions?', 'To explain why the evidence for carbon transfer may be limited', ['To show experiments are easy to repeat', 'To describe how fungi grow', 'To prove that seedlings never benefit'], 'Lab results may not apply in natural settings.'),
          _m(_inf, 'What does the author imply about popular accounts?', 'They may overstate what the evidence supports', ['They are scientifically rigorous', 'They ignore the role of fungi', 'They contradict laboratory results'], 'The author treats the claims as hypotheses awaiting evidence.'),
        ]),
    _ap('ap6', 3, 'Environmental science', 'Fire in Forest Ecosystems',
        'For much of the twentieth century, forest managers regarded wildfire as an unqualified threat and worked to suppress every fire as quickly as possible. Ecologists have since recognized that many forests evolved with periodic fire and depend on it.\n\nIn the ponderosa pine forests of the western United States, for example, frequent low-intensity fires once cleared away brush and small trees, leaving widely spaced mature pines. Fire also releases nutrients stored in dead vegetation and triggers certain seeds to germinate; the cones of lodgepole pines, for instance, open fully only when exposed to intense heat.\n\nDecades of suppression had unintended consequences. Fuel accumulated on the forest floor, and dense stands of young trees created continuous pathways for flames, so that when fires did start, they burned with a severity unprecedented in the historical record. Today, agencies increasingly use prescribed burns, deliberately set under controlled conditions, to reduce fuel and restore a more natural fire cycle, although smoke and the risk of escaped fires make such programs controversial.',
        [
          _m(_main, 'What is the main point of the passage?', 'Suppressing all fire caused problems, so controlled fire is now being reintroduced', ['Wildfires are always destructive', 'Pines are the most fire-resistant trees', 'Prescribed burns are universally accepted'], 'The passage traces suppression, its effects, and prescribed burns.'),
          _m(_detail, 'What happens to lodgepole pine cones?', 'They open fully only when exposed to intense heat', ['They are destroyed by any fire', 'They release seeds in winter', 'They need shade to open'], 'Paragraph 2 gives this as an example of fire-triggered germination.'),
          _m(_vocab, 'The word "unprecedented" is closest in meaning to', 'never seen before', ['widely expected', 'slowly increasing', 'limited in area'], 'A severity unprecedented in the record had not occurred earlier.'),
          _m(_purpose, 'Why does the author mention ponderosa pine forests?', 'To illustrate forests that historically depended on frequent fire', ['To show suppression works best', 'To contrast them with lodgepole forests', 'To explain smoke problems'], 'They are an example of forests shaped by frequent low-intensity fire.'),
          _m(_inf, 'What can be inferred about fires in forests with decades of suppression?', 'They tend to be more severe than past fires', ['They are less likely to start', 'They burn only brush', 'They are easier to control'], 'Built-up fuel and dense stands led to unprecedented severity.'),
        ]),
  ];
}