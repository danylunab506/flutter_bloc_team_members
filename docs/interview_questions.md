# Interview Questions — flutter_bloc_team_members

---

## Arquitectura

**1. Explicame la arquitectura que usaste.**

> Usé Clean Architecture organizada por feature. Cada feature tiene tres capas: `data`, `domain` y `presentation`. La capa `domain` es independiente — no importa nada de Flutter ni de paquetes externos, solo define entidades, contratos de repositorio y use cases. La capa `data` implementa esos contratos con datasources concretos. La `presentation` consume el dominio a través del BLoC. Esto permite cambiar la fuente de datos sin tocar la UI, y testear cada capa en aislamiento.

---

**2. Por qué organizaste por feature y no por tipo de clase (data/domain/presentation en la raíz)?**

> Organizar por feature escala mejor. Si el proyecto crece y se agregan features nuevos, cada uno es un módulo autocontenido. Podés trabajar en `team_members` sin tocar `invoices` ni `settings`. Si organizás por tipo, un cambio en un feature implica navegar entre cuatro carpetas distintas. La cohesión debería ser por feature, no por capa.

---

**3. Por qué `TeamMemberScheme extends TeamMember` en lugar de mapear?**

> Es una simplificación válida para este contexto. Como el datasource es local y no hay divergencia entre lo que devuelve el JSON y lo que necesita el dominio, el scheme puede heredar directamente de la entidad. Si el día de mañana la API remota devolviera campos con nombres distintos o estructura diferente, separaría el scheme de la entidad e introduciría un mapper. El scheme vive en `data/schemes/` (no `data/models/`) porque su única responsabilidad es mapear la forma cruda de la fuente — JSON local o API — a un objeto que la capa de datos pueda usar.

---

**4. Por qué hay un `_cache` en el repositorio?**

> El JSON es la fuente original e inmutable. Las eliminaciones son en memoria — no escribimos de vuelta al asset. Sin la cache, cada llamada a `removeTeamMember` recargaría el JSON y perdería las eliminaciones anteriores. El repositorio actúa como la fuente de verdad en runtime, inicializada desde el JSON y modificada en memoria durante la sesión.

---

## BLoC

**5. Por qué BLoC y no Riverpod o Provider?**

> BLoC impone una separación explícita entre eventos, estados y lógica. Eso hace que el flujo sea muy predecible y fácil de testear — `blocTest` te permite seedear un estado inicial, disparar un evento y verificar exactamente qué estados se emiten. Para un equipo, BLoC también es más legible porque cada interacción del usuario tiene un evento con nombre. Riverpod es más flexible pero menos prescriptivo, lo que puede ser una ventaja o desventaja dependiendo del equipo.

---

**6. Explicame los cuatro widgets de BLoC que usaste y por qué cada uno.**

> — `BlocBuilder` en `MemberCountHeader`: necesito reconstruir el widget completo cuando cambia el estado, con un filtro `buildWhen` para ignorar estados que no sean `Loaded`.
>
> — `BlocSelector` en `MemberCountBadge`: solo me importa el `int` count. El selector extrae ese valor y el widget solo se reconstruye cuando ese entero cambia, sin importar qué otros campos del estado hayan cambiado.
>
> — `BlocListener` en `RemovalListener`: el SnackBar es un efecto secundario, no necesita reconstruir nada. `BlocListener` es transparente en el árbol de widgets.
>
> — `BlocConsumer` en `MembersErrorConsumer`: el error requiere dos cosas simultáneas — mostrar un SnackBar y reemplazar la UI con una vista de error. Necesito tanto `listener` como `builder`, entonces `BlocConsumer` es la herramienta correcta.

---

**7. Por qué el `BlocBuilder` de la página tiene `buildWhen: (prev, curr) => curr is! TeamMembersError`?**

> Cuando ocurre un error, el `MembersErrorConsumer` ya se encarga de mostrarlo — tanto el SnackBar como la vista de error. Si el `BlocBuilder` padre no filtrara ese estado, recibiría `TeamMembersError` y limpiaría la lista que ya estaba en pantalla. Con ese `buildWhen` el `BlocBuilder` ignora los errores y le cede esa responsabilidad al `BlocConsumer`. Cada widget tiene una sola responsabilidad.

---

**8. Por qué el BLoC está registrado como `registerFactory` y no como `registerLazySingleton`?**

> El BLoC tiene estado. Si fuera singleton, al navegar hacia atrás y volver a la pantalla el BLoC conservaría el estado de la sesión anterior. Con `registerFactory`, cada navegación crea una instancia nueva que arranca en `TeamMembersInitial`. Los use cases y el repositorio sí son `lazySingleton` porque no tienen estado mutable propio — el repositorio tiene la cache, pero esa es precisamente la que queremos compartir.

---

**9. Cómo funciona el pull-to-refresh con BLoC?**

> El `RefreshIndicator` espera que el `Future` del `onRefresh` complete para detener la animación. Con BLoC no tenés un `Future` directo que resolver, entonces escucho el stream del BLoC y espero el primer estado terminal:
> ```dart
> await bloc.stream.firstWhere(
>   (s) => s is TeamMembersLoaded || s is TeamMembersEmpty || s is TeamMembersError,
> );
> ```
> Cuando el BLoC emite cualquiera de esos estados, el `Future` completa y el spinner desaparece.

---

## Testing

**10. Cómo testeaste el BLoC?**

> Con `bloc_test` y `mocktail`. `blocTest` permite definir un estado inicial con `seed`, disparar eventos con `act` y verificar la secuencia exacta de estados emitidos con `expect`. Los use cases están mockeados con `mocktail`, entonces el BLoC se testea completamente en aislamiento sin tocar el repositorio ni el datasource. También verifico con `verify` que el use case fue llamado exactamente una vez.

---

**11. Qué diferencia hay entre tus unit tests y tus widget tests?**

> Los unit tests verifican la lógica del BLoC en aislamiento total — sin Flutter, sin widgets, sin UI. Los widget tests verifican que los widgets renderizan correctamente dado un estado del BLoC. Para los widget tests uso un `MockTeamMembersBloc` al que le inyecto el estado que quiero testear. Tengo helpers compartidos: `pump_app.dart` que wrappea el widget con `MaterialApp` y el tema, y `team_member_factory.dart` con fixtures de datos consistentes.

---

**12. Qué testarías si tuvieras más tiempo?**

> Agregaría tests de integración que ejerciten el flujo completo desde el datasource hasta la UI, sin mocks. También testaría el `RemovalListener` para verificar que `clearSnackBars()` se llama antes de mostrar el nuevo SnackBar cuando se eliminan miembros consecutivos. Y agregaría golden tests para los widgets visuales más importantes como `TeamMemberItem` y `EmptyMembersWidget`.

---

## Decisiones puntuales

**13. Por qué usaste `sealed class` para los estados?**

> `sealed class` habilita pattern matching exhaustivo con `switch`. Si agrego un nuevo estado y no lo manejo en el `switch` de la UI, el compilador lo detecta como error. Sin `sealed`, un `switch` o `if/else` incompleto fallará silenciosamente en runtime. Es type-safety en tiempo de compilación.

---

**14. Cuando hay un error en el JSON, qué ve el usuario?**

> Un mensaje legible. En el datasource capturo `FormatException` específicamente y lanzo un `DataParsingException` con el texto "The data could not be read". Cualquier otro error lanza un `DataLoadException` con "Could not load team members. Please try again." El BLoC solo hace `e.toString()` y ese mensaje limpio llega al estado de error. El usuario nunca ve un stack trace ni un mensaje técnico de Dart.

---

**15. Cómo escalarías la inyección de dependencias si el proyecto crece?**

> Separando los registros por feature en módulos independientes. `dependency_injection.dart` queda como orquestador que solo llama a cada módulo. Agregar un feature nuevo es crear un archivo en `core/di/features/` y añadir una línea en `initDependencies()`. El archivo principal nunca crece.

---

**16. Por qué no usaste `WidgetsFlutterBinding.ensureInitialized()`?**

> Porque no hay ninguna operación asíncrona ni plugin nativo antes de `runApp`. `initDependencies()` es código Dart puro que solo registra factories en `get_it`. `ensureInitialized()` es necesario cuando antes de `runApp` se usa un plugin como Firebase, SharedPreferences o path_provider, que necesitan que el binding con el engine nativo esté listo. Agregarlo sin necesidad sería código sin propósito.
