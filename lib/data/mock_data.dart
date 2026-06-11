import '../models/user.dart';
import '../models/opportunity.dart';
import '../models/message.dart';
import '../models/organizer_request.dart';

/// Seed data used to populate the app on first launch. Because the brief
/// allows mock data, this lets us demo a lively, realistic feed without a
/// backend. New sign-ups and posts are added on top of these at runtime.
class MockData {
  static List<User> users() => [
        User(
          id: 'u_admin',
          name: 'Amara Okeke',
          email: 'admin@alu.edu',
          house: 'Ubuntu',
          campus: 'Kigali, Rwanda',
          bio: 'Student Life coordinator. Keeps the feed trustworthy.',
          role: UserRole.admin,
          skills: ['Operations', 'Community', 'Public Speaking'],
        ),
        User(
          id: 'u_org',
          name: 'Kwame Mensah',
          email: 'kwame@alu.edu',
          house: 'Imagine',
          campus: 'Kigali, Rwanda',
          bio: 'President, ALU Robotics Club.',
          role: UserRole.organizer,
          skills: ['Python', 'Machine Learning', 'Flutter'],
        ),
        User(
          id: 'u_student',
          name: 'Liana Uwase',
          email: 'liana@alu.edu',
          house: 'Ubuntu',
          campus: 'Kigali, Rwanda',
          bio: 'Passionate about building tech for Africa. '
              'Love hackathons and impact-driven startups.',
          role: UserRole.student,
          skills: ['UI/UX', 'Figma', 'Product Management'],
          seekingRoles: ['Backend Dev', 'Product Manager', 'Designer'],
          lookingForTeammates: true,
        ),
      ];

  static List<Opportunity> opportunities() => [
        Opportunity(
          id: 'o1',
          title: 'ALU Pan-African Hackathon 2026',
          type: OpportunityType.hackathon,
          description:
              'A 48-hour build sprint solving real African challenges. '
              'Teams of 3–5. Mentors from across the continent. Prizes for '
              'top three teams.',
          date: DateTime.now().add(const Duration(days: 6)),
          location: 'Innovation Hub, Kigali Campus',
          organizer: 'ALU Innovation Lab',
          skills: ['Python', 'Flutter', 'UI/UX', 'Machine Learning'],
          teamSize: 5,
          spotsAvailable: 40,
          interestedCount: 89,
          posterId: 'u_org',
          posterName: 'Kwame Mensah',
          attendees: {'u_student'},
        ),
        Opportunity(
          id: 'o2',
          title: 'Product Design Workshop: Figma to Flutter',
          type: OpportunityType.workshop,
          description:
              'Hands-on session turning a Figma mockup into a working mobile '
              'screen. Bring a laptop. Beginner friendly.',
          date: DateTime.now().add(const Duration(days: 2)),
          location: 'Lab 2B',
          organizer: 'ALU Design Club',
          skills: ['Figma', 'UI/UX', 'Flutter'],
          spotsAvailable: 25,
          interestedCount: 34,
          posterId: 'u_org',
          posterName: 'Kwame Mensah',
        ),
        Opportunity(
          id: 'o3',
          title: 'Summer Internship: Fintech Analyst (Remote)',
          type: OpportunityType.internship,
          description:
              'Verified opening with a partner fintech. Open to all years. '
              'Applications close in two weeks.',
          date: DateTime.now().add(const Duration(days: 14)),
          location: 'Remote',
          organizer: 'Flutterwave',
          skills: ['SQL', 'Python', 'Data Analysis'],
          applicationDeadline: DateTime.now().add(const Duration(days: 19)),
          interestedCount: 209,
          posterId: 'u_admin',
          posterName: 'Amara Okeke',
        ),
        Opportunity(
          id: 'o4',
          title: 'Ubuntu House Leadership Dinner',
          type: OpportunityType.leadership,
          description:
              'Monthly gathering for Ubuntu house members. Guest speaker on '
              'servant leadership. Dinner provided.',
          date: DateTime.now().add(const Duration(days: 4)),
          location: 'Dining Hall',
          organizer: 'ALU Student Government',
          skills: ['Leadership', 'Public Speaking'],
          interestedCount: 152,
          posterId: 'u_admin',
          posterName: 'Amara Okeke',
          attendees: {'u_student', 'u_org'},
        ),
      ];

  static List<Message> messages() => [
        Message(
          id: 'm1',
          opportunityId: 'o1',
          senderId: 'u_student',
          senderName: 'Liana Uwase',
          text: 'Can first-years join, or is it upper-years only?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Message(
          id: 'm2',
          opportunityId: 'o1',
          senderId: 'u_org',
          senderName: 'Kwame Mensah',
          text: 'All years welcome! Just bring a team or join one on the day.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Message(
          id: 'm3',
          opportunityId: 'o4',
          senderId: 'u_org',
          senderName: 'Kwame Mensah',
          text: 'Looking forward to the talk on servant leadership!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  static List<OrganizerRequest> requests() => [
        OrganizerRequest(
          id: 'r1',
          userId: 'u_student',
          userName: 'Liana Uwase',
          userHouse: 'Ubuntu',
          reason:
              'I am starting a Women in Tech circle and want to post our '
              'weekly sessions.',
        ),
      ];
}
