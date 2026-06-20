/// Static marketing content mirrored from bhau_fitness_v3.html — programs,
/// equipment, testimonials, trainers, FAQ. These never come from the API in
/// the HTML site either (hardcoded JS arrays), so we keep them as Dart consts.
class ProgramItem {
  final String title;
  final String desc;
  final String tag;
  final String image;
  const ProgramItem(this.title, this.desc, this.tag, this.image);
}

const programs = [
  ProgramItem(
    'Strength Training',
    'Progressive overload programs built around compound lifts — for raw, measurable strength gains.',
    'STRENGTH',
    'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&q=80',
  ),
  ProgramItem(
    'Body Transformation',
    'A structured 12-week plan combining training, nutrition coaching, and weekly check-ins.',
    'TRANSFORM',
    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80',
  ),
  ProgramItem(
    'Fat Loss',
    'High-output metabolic circuits paired with a calorie-aware nutrition framework.',
    'FAT LOSS',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80',
  ),
  ProgramItem(
    'Functional Athlete',
    'Mobility, power, and conditioning work designed for real-world athletic performance.',
    'ATHLETIC',
    'https://images.unsplash.com/photo-1599901860904-17e6ed7083a0?w=800&q=80',
  ),
  ProgramItem(
    'HIIT',
    'Short, brutal, effective — interval training that torches calories in 30 minutes flat.',
    'HIIT',
    'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=800&q=80',
  ),
  ProgramItem(
    'Yoga & Mobility',
    'Recovery-focused sessions that keep you training hard without breaking down.',
    'RECOVERY',
    'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=800&q=80',
  ),
];

const equipmentImages = [
  'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&q=80',
  'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=600&q=80',
  'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=600&q=80',
  'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=600&q=80',
  'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600&q=80',
  'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=600&q=80',
  'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=600&q=80',
  'https://images.unsplash.com/photo-1558611848-73f7eb4001a1?w=600&q=80',
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
      'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800&q=80',
      'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&q=80'),
  Transformation('Priya K.', '12 weeks',
      'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=800&q=80',
      'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=800&q=80'),
];

class Testimonial {
  final String name;
  final String result;
  final String quote;
  const Testimonial(this.name, this.result, this.quote);
}

const testimonials = [
  Testimonial('Rohit Sahu', '-14kg in 5 months',
      "I'd tried every diet under the sun before BHAU. The coaching here actually held me accountable — and it worked."),
  Testimonial('Anjali Verma', '+6kg lean muscle',
      'The trainers actually watch your form. First gym where I felt like a person, not a membership number.'),
  Testimonial('Deepak Thakur', 'Back pain-free in 8 weeks',
      "The functional training program fixed posture issues my physio couldn't. Genuinely life-changing."),
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
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&q=80',
      exp: '12 years', instagram: 'vikram_lifts',
      certs: ['NSCA-CPT', 'ACE Strength Specialist'],
      tags: ['Powerlifting', 'Hypertrophy', 'Nutrition']),
  TrainerItem('Priya Nair', 'YOGA & MOBILITY',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=500&q=80',
      exp: '8 years', instagram: 'priya.flow',
      certs: ['RYT-500', 'Pilates Mat'],
      tags: ['Vinyasa', 'Mobility', 'Meditation']),
  TrainerItem('Arjun Mehta', 'HIIT & CROSSFIT',
      'https://images.unsplash.com/photo-1567013127542-490d757e51fc?w=500&q=80',
      exp: '6 years', instagram: 'arjun.metcon',
      certs: ['CrossFit L2', 'NASM-PES'],
      tags: ['HIIT', 'Conditioning', 'Fat Loss']),
  TrainerItem('Sneha Patel', 'CARDIO & CONDITIONING',
      'https://images.unsplash.com/photo-1554344728-77cf90d9ed26?w=500&q=80',
      exp: '9 years', instagram: 'sneha.endure',
      certs: ['ACSM-EP', 'Spinning'],
      tags: ['Endurance', 'Cycling', 'Marathon Prep']),
];

class FaqItem {
  final String q;
  final String a;
  const FaqItem(this.q, this.a);
}

const faqs = [
  FaqItem('Do I need a prior fitness background to join?',
      'Not at all — every program scales to your current level, from first-timers to competitive athletes.'),
  FaqItem('Can I freeze or cancel my membership?',
      'Yes, memberships can be paused for medical or travel reasons. Reach out to the front desk or support.'),
  FaqItem('Are personal training sessions included?',
      'Premium and Elite plans include PT session credits each month; Basic members can book PT separately.'),
  FaqItem('What are your operating hours?',
      'Open 5 AM – 11 PM on weekdays, 6 AM – 9 PM on weekends. Elite members get 24/7 access.'),
];
