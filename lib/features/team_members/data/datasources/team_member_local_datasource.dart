import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/team_member_model.dart';

abstract class TeamMemberLocalDatasource {
  Future<List<TeamMemberModel>> getTeamMembers();
}

class TeamMemberLocalDatasourceImpl implements TeamMemberLocalDatasource {
  @override
  Future<List<TeamMemberModel>> getTeamMembers() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final jsonString = await rootBundle.loadString('assets/team.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const DataParsingException('The data could not be read. Please contact support.');
    } catch (_) {
      throw const DataLoadException('Could not load team members. Please try again.');
    }
  }
}
