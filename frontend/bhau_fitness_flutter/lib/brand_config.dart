import 'package:flutter/material.dart';

// =============================================================================
// TENANT CONFIGURATION — edit only [activeTenant] to white-label this app.
// =============================================================================
// To deploy for a new client gym:
//  1. Replace the values in [activeTenant] with the new gym's details.
//  2. Drop their logo PNG at [logoAsset] path inside assets/images/.
//  3. Run: flutter build apk   (or flutter build ios)
//  4. Done — the whole app is rebranded instantly.
// =============================================================================

class TenantConfig {
  // Brand Identity
  final String brandName;
  final String wordmarkPart1;
  final String wordmarkPart2;
  final String tagline;
  final String logoAsset;

  // Contact and Location
  final String whatsappNumber;
  final String contactPhone;
  final String contactEmail;
  final String instagramHandle;
  final String mapsQuery;
  final String address;
  final String locationEyebrow;

  // Business Hours
  final int openHour;
  final int closeHour;
  final String hoursLabel;

  // Hero Stats
  final String statMembers;
  final String statClasses;
  final String statYears;
  final String statTrainers;

  // Brand Colours
  final Color primaryColor;
  final Color secondaryColor;

  const TenantConfig({
    required this.brandName,
    required this.wordmarkPart1,
    required this.wordmarkPart2,
    required this.tagline,
    required this.logoAsset,
    required this.whatsappNumber,
    required this.contactPhone,
    required this.contactEmail,
    required this.instagramHandle,
    required this.mapsQuery,
    required this.address,
    required this.locationEyebrow,
    required this.openHour,
    required this.closeHour,
    required this.hoursLabel,
    required this.statMembers,
    required this.statClasses,
    required this.statYears,
    required this.statTrainers,
    this.primaryColor = const Color(0xFFC6FF3D),
    this.secondaryColor = const Color(0xFF00E0FF),
  });

  String get whatsappGreeting => 'Hi $brandName!';
  String get mapsUrl => 'https://maps.google.com/?q=$mapsQuery';
  bool get isOpenNow {
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday) return false;
    return now.hour >= openHour && now.hour < closeHour;
  }

  String get mapLabel =>
      '$brandName - ${locationEyebrow.split("·").first.trim()} - tap to open in Maps';
  String get copyrightLine =>
      '© ${DateTime.now().year} $brandName. All rights reserved.';
  String get ctaJoinLabel => 'Join $brandName';
}

// =============================================================================
// ACTIVE TENANT — change this to white-label for a client gym.
// =============================================================================
const activeTenant = TenantConfig(
  brandName: 'BHAU FITNESS',
  wordmarkPart1: 'BHAU',
  wordmarkPart2: 'FITNESS',
  tagline: 'WHERE STRENGTH MEETS LUXURY',
  logoAsset: 'assets/images/logo.png',
  whatsappNumber: '919876543210',
  contactPhone: '+91 98765 43210',
  contactEmail: 'shanuuikey1@gmail.com',
  instagramHandle: 'hackthealgorithm.in',
  mapsQuery: 'Parasia,Chhindwara,Madhya+Pradesh',
  address: 'PARASIA, CHHINDWARA, MADHYA PRADESH',
  locationEyebrow: 'PARASIA - CHHINDWARA',
  openHour: 5,
  closeHour: 23,
  hoursLabel: 'MON-SAT 5AM - 11PM',
  statMembers: '5000+',
  statClasses: '40+',
  statYears: '15+',
  statTrainers: '12',
);

// =============================================================================
// Example: Iron Temple Gym (uncomment + set activeTenant = ironTempleTenant)
// =============================================================================
// const ironTempleTenant = TenantConfig(
//   brandName: 'IRON TEMPLE',
//   wordmarkPart1: 'IRON',
//   wordmarkPart2: 'TEMPLE',
//   tagline: 'FORGE YOUR LIMITS',
//   logoAsset: 'assets/images/logo_iron_temple.png',
//   whatsappNumber: '911234567890',
//   contactPhone: '+91 12345 67890',
//   contactEmail: 'info@irontemple.in',
//   instagramHandle: 'irontemple.in',
//   mapsQuery: 'Bhopal,Madhya+Pradesh',
//   address: 'MP NAGAR, BHOPAL, MADHYA PRADESH',
//   locationEyebrow: 'MP NAGAR - BHOPAL',
//   openHour: 6,
//   closeHour: 22,
//   hoursLabel: 'MON-SAT 6AM - 10PM',
//   statMembers: '2000+',
//   statClasses: '20+',
//   statYears: '5+',
//   statTrainers: '8',
//   primaryColor: Color(0xFFFF6B2C),
//   secondaryColor: Color(0xFFFFD600),
// );
