/// Static marketing content mirrored from bhau_fitness_v3.html — programs,
/// equipment, testimonials, trainers, FAQ. These never come from the API in
/// the HTML site either (hardcoded JS arrays), so we keep them as Dart consts.
/// Values here are copied verbatim from the HTML's live-rendered `PROGRAMS`/
/// `TRAINERS`/`TESTIMONIALS`/`EQUIPMENT`/`FAQS` consts (not the CSS comment
/// markers of the same name), so they match what a visitor to the original
/// site actually sees.
class ProgramItem {
  final String title;
  final String desc;
  final String weeks;
  final String level;
  final String tag;
  final String image;
  const ProgramItem(this.title, this.desc, this.weeks, this.level, this.tag, this.image);
}

const programs = [
  ProgramItem(
    'Strength Training',
    'Build raw power and muscle mass with a program designed by professional powerlifters.',
    '12 Weeks',
    'All Levels',
    'STRENGTH',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
  ),
  ProgramItem(
    'Body Transformation',
    'Complete body recomposition combining strength, conditioning, and custom nutrition tailored to Indian home-cooked meals.',
    '16 Weeks',
    'Beginner+',
    'TRANSFORM',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
  ),
  ProgramItem(
    'Fat Loss Protocol',
    'Science-backed fat loss with HIIT, metabolic conditioning, and strategic Indian macro planning.',
    '8 Weeks',
    'All Levels',
    'FAT LOSS',
    'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&q=80',
  ),
  ProgramItem(
    'Functional Athlete',
    'Move better, jump higher, hit harder. Built for sports like cricket, football, and real-world performance.',
    '10 Weeks',
    'Intermediate',
    'ATHLETIC',
    'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&q=80',
  ),
  ProgramItem(
    'HIIT & Conditioning',
    'Burn maximum calories in minimum time with high-intensity interval training.',
    '6 Weeks',
    'All Levels',
    'HIIT',
    'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=800&q=80',
  ),
  ProgramItem(
    'Yoga & Mobility',
    'Restore flexibility, balance, and calm with traditional Indian yogic flows and modern mobility work.',
    'Ongoing',
    'All Levels',
    'RECOVERY',
    'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&q=80',
  ),
];

class EquipmentItem {
  final String name;
  final String category;
  final String image;
  const EquipmentItem(this.name, this.category, this.image);
}

// Every URL below was individually downloaded and visually verified to show
// the correct equipment before being used — several of the HTML's original
// Unsplash IDs (e.g. its "Treadmill Pro"/"Rowing Erg" photos) turned out to
// have been swapped server-side to unrelated images since the HTML was built.
const equipment = [
  EquipmentItem('Power Rack', 'Strength', 'https://images.unsplash.com/photo-1620188467120-5042ed1eb5da?w=600&q=80'),
  EquipmentItem('Treadmill Pro', 'Cardio', 'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=600&q=80'),
  EquipmentItem('Cable Crossover', 'Functional', 'https://images.unsplash.com/photo-1571388208497-71bedc66e932?w=600&q=80'),
  EquipmentItem('Dumbbell Set', 'Free Weights', 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=600&q=80'),
  EquipmentItem('Smith Machine', 'Strength', 'https://images.unsplash.com/photo-1554344728-77cf90d9ed26?w=600&q=80'),
  EquipmentItem('Rowing Erg', 'Cardio', 'https://images.unsplash.com/photo-1623874514711-0f321325f318?w=600&q=80'),
  EquipmentItem('Kettlebell Rack', 'Functional', 'https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?w=600&q=80'),
  EquipmentItem('Leg Press', 'Strength', 'https://images.unsplash.com/photo-1561214078-f3247647fc5e?w=600&q=80'),
];

class Transformation {
  final String name;
  final String weeks;
  final String before;
  final String after;
  const Transformation(this.name, this.weeks, this.before, this.after);
}

// Same as equipment above — visually verified pairs (matching gender, similar
// framing) instead of the HTML's original IDs, several of which no longer
// resolve to plausible before/after pairings.
const transformations = [
  Transformation('Rahul S.', '16 weeks',
      'https://images.unsplash.com/photo-1556817411-31ae72fa3ea0?w=800&q=80',
      'https://images.unsplash.com/photo-1581009137042-c552e485697a?w=800&q=80'),
  Transformation('Priya K.', '12 weeks',
      'https://images.unsplash.com/photo-1581122584612-713f89daa8eb?w=800&q=80',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&q=80'),
];

class Testimonial {
  final String name;
  final String result;
  final String quote;
  final String image;
  const Testimonial(this.name, this.result, this.quote, this.image);
}

const testimonials = [
  Testimonial(
    'Rahul Sharma',
    'Lost 18kg in 4 months',
    'The trainers at BHAU helped me balance my traditional Indian home-cooked meals with precise nutrition. Lost 18kg in 4 months and my energy is through the roof!',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
  ),
  Testimonial(
    'Ananya Gupta',
    'Gained 8kg muscle',
    'As a vegetarian, I thought building serious muscle would be impossible, but the coaches at BHAU designed a perfect plan. From barely 5 push-ups to benching 80kg!',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
  ),
  Testimonial(
    'Karan Malhotra',
    'Body fat 28% → 12%',
    'The nutrition guidance combined with the training protocols here is unmatched. This is not just a gym, it is a lifestyle upgrade for the modern Indian.',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
  ),
];

class TrainerItem {
  final String name;
  final String spec;
  final String image;
  final String exp;
  final String instagram;
  final List<String> certs;
  final List<String> tags;
  const TrainerItem(this.name, this.spec, this.image,
      {required this.exp, required this.instagram, required this.certs, required this.tags});
}

const trainers = [
  TrainerItem('Vikram Singh', 'STRENGTH & POWERLIFTING',
      'assets/images/trainer_vikram.png',
      exp: '12 years', instagram: 'vikram_lifts',
      certs: ['NSCA-CPT', 'ACE Strength Specialist'],
      tags: ['Powerlifting', 'Hypertrophy', 'Nutrition']),
  TrainerItem('Priya Nair', 'YOGA & MOBILITY',
      'assets/images/trainer_priya.png',
      exp: '8 years', instagram: 'priya.flow',
      certs: ['RYT-500', 'Pilates Mat'],
      tags: ['Vinyasa', 'Mobility', 'Meditation']),
  TrainerItem('Arjun Mehta', 'HIIT & CROSSFIT',
      'assets/images/trainer_arjun.png',
      exp: '6 years', instagram: 'arjun.metcon',
      certs: ['CrossFit L2', 'NASM-PES'],
      tags: ['HIIT', 'Conditioning', 'Fat Loss']),
  TrainerItem('Sneha Patel', 'CARDIO & CONDITIONING',
      'assets/images/trainer_sneha.png',
      exp: '9 years', instagram: 'sneha.endure',
      certs: ['ACSM-EP', 'Spinning®'],
      tags: ['Endurance', 'Cycling', 'Marathon Prep']),
];

class FaqItem {
  final String q;
  final String a;
  const FaqItem(this.q, this.a);
}

const faqs = [
  FaqItem('What are the gym timings?',
      'We are open 5:00 AM to 11:00 PM, seven days a week. Elite members get 24/7 access.'),
  FaqItem('Can I switch my membership plan?',
      'Yes, you can upgrade or downgrade your plan at any time from your member portal or by contacting our front desk.'),
  FaqItem('Is there a joining fee?',
      'No hidden joining fees. You only pay your monthly membership fee. We believe in transparent pricing.'),
  FaqItem('Do you offer personal training?',
      'Absolutely. Personal training is included in our Premium and Elite plans, or available as an add-on for Basic members.'),
  FaqItem('What safety measures are in place?',
      'We maintain hospital-grade sanitization, air purification systems, and regular equipment maintenance checks.'),
  FaqItem('Can I freeze my membership?',
      'Yes, you can freeze your membership for up to 30 days per year due to travel or medical reasons.'),
];
