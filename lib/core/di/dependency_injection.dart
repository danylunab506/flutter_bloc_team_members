import 'package:get_it/get_it.dart';

import 'app_module.dart';
import 'features/team_members_module.dart';

final getIt = GetIt.instance;

void initDependencies() {
  registerAppDependencies(getIt);
  registerTeamMembersDependencies(getIt);
}
