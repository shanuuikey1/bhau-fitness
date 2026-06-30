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
    'assets/images/prog_strength.jpg',
  ),
  ProgramItem(
    'Body Transformation',
    'Complete body recomposition combining strength, conditioning, and custom nutrition tailored to Indian home-cooked meals.',
    '16 Weeks',
    'Beginner+',
    'TRANSFORM',
    'assets/images/prog_transformation.jpg',
  ),
  ProgramItem(
    'Fat Loss Protocol',
    'Science-backed fat loss with HIIT, metabolic conditioning, and strategic Indian macro planning.',
    '8 Weeks',
    'All Levels',
    'FAT LOSS',
    'assets/images/prog_fat_loss.jpg',
  ),
  ProgramItem(
    'Functional Athlete',
    'Move better, jump higher, hit harder. Built for sports like cricket, football, and real-world performance.',
    '10 Weeks',
    'Intermediate',
    'ATHLETIC',
    'assets/images/prog_athlete.jpg',
  ),
  ProgramItem(
    'HIIT & Conditioning',
    'Burn maximum calories in minimum time with high-intensity interval training.',
    '6 Weeks',
    'All Levels',
    'HIIT',
    'assets/images/prog_hiit.jpg',
  ),
  ProgramItem(
    'Yoga & Mobility',
    'Restore flexibility, balance, and calm with traditional Indian yogic flows and modern mobility work.',
    'Ongoing',
    'All Levels',
    'RECOVERY',
    'assets/images/prog_yoga.jpg',
  ),
];

class EquipmentItem {
  final String name;
  final String category;
  final String image;
  const EquipmentItem(this.name, this.category, this.image);
}

const equipment = [
  EquipmentItem('Power Rack', 'Strength', 'assets/images/eq_power_rack.jpg'),
  EquipmentItem('Treadmill Pro', 'Cardio', 'assets/images/eq_treadmill.jpg'),
  EquipmentItem('Cable Crossover', 'Functional', 'assets/images/eq_cable_crossover.jpg'),
  EquipmentItem('Dumbbell Set', 'Free Weights', 'assets/images/eq_dumbbell_set.jpg'),
  EquipmentItem('Smith Machine', 'Strength', 'assets/images/eq_smith_machine.jpg'),
  EquipmentItem('Rowing Erg', 'Cardio', 'assets/images/eq_rowing_erg.jpg'),
  EquipmentItem('Kettlebell Rack', 'Functional', 'assets/images/eq_kettlebell_rack.jpg'),
  EquipmentItem('Leg Press', 'Strength', 'assets/images/eq_leg_press.jpg'),
];

class Transformation {
  final String name;
  final String weeks;
  final String before;
  final String after;
  const Transformation(this.name, this.weeks, this.before, this.after);
}

const transformations = [
  Transformation('Rahul S.', '16 weeks',
      'assets/images/rahul_before.jpg',
      'assets/images/rahul_after.jpg'),
  Transformation('Priya K.', '12 weeks',
      'assets/images/priya_before.jpg',
      'assets/images/priya_after.jpg'),
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
    'assets/images/testi_rahul.jpg',
  ),
  Testimonial(
    'Ananya Gupta',
    'Gained 8kg muscle',
    'As a vegetarian, I thought building serious muscle would be impossible, but the coaches at BHAU designed a perfect plan. From barely 5 push-ups to benching 80kg!',
    'assets/images/testi_ananya.jpg',
  ),
  Testimonial(
    'Karan Malhotra',
    'Body fat 28% → 12%',
    'The nutrition guidance combined with the training protocols here is unmatched. This is not just a gym, it is a lifestyle upgrade for the modern Indian.',
    'assets/images/testi_karan.jpg',
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