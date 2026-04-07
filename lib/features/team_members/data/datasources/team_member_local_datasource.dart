import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/team_member_model.dart';

abstract class TeamMemberLocalDatasource {
  Future<List<TeamMemberModel>> getTeamMembers();
}

class TeamMemberLocalDatasourceImpl implements TeamMemberLocalDatasource {
  @override
  Future<List<TeamMemberModel>> getTeamMembers() async {
    await Future.delayed(const Duration(seconds: 2));
    final jsonString = await rootBundle.loadString('assets/team.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
