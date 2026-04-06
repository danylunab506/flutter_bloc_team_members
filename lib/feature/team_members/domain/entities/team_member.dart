import 'package:equatable/equatable.dart';

class TeamMember extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String title;
  final String avatar;
  final String bio;

  const TeamMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.title,
    required this.avatar,
    required this.bio,
  });

  @override
  List<Object> get props => [id, firstName, lastName, title, avatar, bio];
}
