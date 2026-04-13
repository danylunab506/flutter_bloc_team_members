# Local Storage — DI Setup

---

## Estructura de archivos

```
core/di/features/
├── team_members_module.dart        ← ya existe
└── user_preferences_module.dart   ← nuevo

features/
└── user_preferences/
    ├── data/
    │   ├── datasources/
    │   │   ├── user_preferences_datasource.dart
    │   │   └── secure_user_preferences_datasource.dart
    │   └── repositories/
    │       └── user_preferences_repository_impl.dart
    └── domain/
        ├── repositories/
        │   └── user_preferences_repository.dart
        └── usecases/
            ├── get_auth_token.dart
            └── save_auth_token.dart
```

---

## Domain

```dart
// domain/repositories/user_preferences_repository.dart
abstract class UserPreferencesRepository {
  Future<String?> getAuthToken();
  Future<void> saveAuthToken(String token);
}
```

```dart
// domain/usecases/get_auth_token.dart
class GetAuthToken {
  final UserPreferencesRepository repository;

  const GetAuthToken(this.repository);

  Future<String?> call() => repository.getAuthToken();
}
```

```dart
// domain/usecases/save_auth_token.dart
class SaveAuthToken {
  final UserPreferencesRepository repository;

  const SaveAuthToken(this.repository);

  Future<void> call(String token) => repository.saveAuthToken(token);
}
```

---

## Data — Datasources

```dart
// data/datasources/user_preferences_datasource.dart
// SharedPreferences — datos no sensibles (tema, idioma, flags UI)
abstract class UserPreferencesDatasource {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
}

class UserPreferencesDatasourceImpl implements UserPreferencesDatasource {
  final SharedPreferences _prefs;

  UserPreferencesDatasourceImpl(this._prefs);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) async =>
      _prefs.setString(key, value);
}
```

```dart
// data/datasources/secure_user_preferences_datasource.dart
// FlutterSecureStorage — datos sensibles (tokens, credenciales)
abstract class SecureUserPreferencesDatasource {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureUserPreferencesDatasourceImpl
    implements SecureUserPreferencesDatasource {
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
```

---

## Data — Repository

```dart
// data/repositories/user_preferences_repository_impl.dart
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final UserPreferencesDatasource _prefs;
  final SecureUserPreferencesDatasource _securePrefs;

  UserPreferencesRepositoryImpl(this._prefs, this._securePrefs);

  @override
  Future<String?> getAuthToken() => _securePrefs.read('auth_token');

  @override
  Future<void> saveAuthToken(String token) =>
      _securePrefs.write('auth_token', token);
}
```

---

## DI — Módulo

```dart
// core/di/features/user_preferences_module.dart
void registerUserPreferencesDependencies(GetIt getIt) {
  // SharedPreferences necesita inicialización async
  getIt.registerSingletonAsync<SharedPreferences>(
    () async => SharedPreferences.getInstance(),
  );

  // FlutterSecureStorage — constructor síncrono, no necesita async
  getIt.registerLazySingleton<SecureUserPreferencesDatasource>(
    () => SecureUserPreferencesDatasourceImpl(),
  );

  // UserPreferencesDatasource depende de SharedPreferences (async)
  getIt.registerSingletonWithDependencies<UserPreferencesDatasource>(
    () => UserPreferencesDatasourceImpl(getIt<SharedPreferences>()),
    dependsOn: [SharedPreferences],
  );

  getIt.registerLazySingleton<UserPreferencesRepository>(
    () => UserPreferencesRepositoryImpl(
      getIt<UserPreferencesDatasource>(),
      getIt<SecureUserPreferencesDatasource>(),
    ),
  );

  getIt.registerLazySingleton(() => GetAuthToken(getIt<UserPreferencesRepository>()));
  getIt.registerLazySingleton(() => SaveAuthToken(getIt<UserPreferencesRepository>()));
}
```

---

## DI — Orquestador

```dart
// core/di/dependency_injection.dart
void initDependencies() {
  registerAppDependencies(getIt);
  registerTeamMembersDependencies(getIt);
  registerUserPreferencesDependencies(getIt); // ← nueva línea
}
```

---

## main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necesario por SharedPreferences
  initDependencies();
  await getIt.allReady(); // espera que los singletons async estén listos
  runApp(const MyApp());
}
```

---

## Por qué cada decisión

| Decisión | Razón |
|---|---|
| `FlutterSecureStorage` como `lazySingleton` síncrono | Su constructor no es async, no necesita `await` |
| `SharedPreferences` como `registerSingletonAsync` | `getInstance()` es async, debe resolverse antes de usarse |
| `registerSingletonWithDependencies` para el datasource | Garantiza que `SharedPreferences` esté listo antes de construir el datasource |
| `await getIt.allReady()` en `main` | Espera que todos los singletons async estén inicializados antes de arrancar la app |
| `WidgetsFlutterBinding.ensureInitialized()` | `SharedPreferences.getInstance()` accede a canales nativos, requiere el binding activo |
| Dos datasources separados | Separa datos sensibles de no sensibles, cada uno mockeable independientemente en tests |
