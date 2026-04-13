import 'package:get_it/get_it.dart';

import '../../router/app_router.dart';

void registerAppDependencies(GetIt getIt) {
  getIt.registerLazySingleton(() => AppRouter());
}
