import '../../domain/entities/team_member.dart';

class TeamMemberModel extends TeamMember {
  const TeamMemberModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.title,
    required super.avatar,
    required super.bio,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      title: json['title'] as String,
      avatar: json['avatar'] as String,
      bio: json['bio'] as String,
    );
  }
}
