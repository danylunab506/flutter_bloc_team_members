import '../../domain/entities/team_member.dart';

class TeamMemberScheme extends TeamMember {
  const TeamMemberScheme({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.title,
    required super.avatar,
    required super.bio,
  });

  factory TeamMemberScheme.fromJson(Map<String, dynamic> json) {
    return TeamMemberScheme(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      title: json['title'] as String,
      avatar: json['avatar'] as String,
      bio: json['bio'] as String,
    );
  }
}
