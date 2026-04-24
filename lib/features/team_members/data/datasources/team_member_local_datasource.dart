import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/errors/exceptions.dart';
import '../schemes/team_member_scheme.dart';

abstract class TeamMemberLocalDatasource {
  Future<List<TeamMemberScheme>> getTeamMembers();
}

class TeamMemberLocalDatasourceImpl implements TeamMemberLocalDatasource {
  @override
  Future<List<TeamMemberScheme>> getTeamMembers() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final jsonString = await rootBundle.loadString('assets/team.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => TeamMemberScheme.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const DataParsingException('The data could not be read. Please contact support.');
    } catch (_) {
      throw const DataLoadException('Could not load team members. Please try again.');
    }
  }
}
