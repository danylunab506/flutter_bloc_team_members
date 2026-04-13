# Interview Questions — Advanced Topics

---

## Performance & DevTools

**1. Cómo detectás un problema de performance en una app Flutter?**

> El primer paso es abrir Flutter DevTools y usar el Performance panel. Activo el "Track widget rebuilds" para ver qué widgets se están reconstruyendo en cada frame. Si un frame tarda más de 16ms (60fps) o 8ms (120fps), aparece en rojo en el flame chart. Ahí identifico si el cuello de botella está en el UI thread o en el raster thread. Si está en el UI thread, busco rebuilds innecesarios o trabajo pesado en el árbol de widgets. Si está en el raster thread, busco efectos costosos como `saveLayer`, sombras complejas o imágenes sin caché.

---

**2. Qué es el Widget Rebuild Tracker y cuándo lo usás?**

> Es una herramienta dentro del Inspector de DevTools que resalta en colores los widgets que se reconstruyeron en el último frame. Verde significa pocos rebuilds, rojo significa muchos. Lo uso cuando sospecho que un widget se está reconstruyendo más de lo necesario. Por ejemplo, si un `Text` que muestra un contador se reconstruye junto con toda la pantalla, lo envuelvo en un `BlocSelector` o separo el widget en uno más pequeño para aislar el rebuild.

---

**3. Qué diferencia hay entre el UI thread y el Raster thread en el flame chart?**

> El UI thread ejecuta el código Dart: construcción del widget tree, lógica del BLoC, animaciones. El Raster thread toma el layer tree generado por el UI thread y lo convierte en pixels usando Skia/Impeller. Si el UI thread está saturado, hay demasiado trabajo en Dart. Si el Raster thread está saturado, hay operaciones gráficas costosas — por ejemplo, `BackdropFilter`, `ClipPath` complejo, o imágenes muy grandes sin comprimir. La solución para cada uno es distinta.

---

**4. Qué es `const` y por qué importa para la performance?**

> Un widget `const` se construye una sola vez y se reutiliza. Flutter puede saltear su reconstrucción completamente porque sabe que su output nunca cambia. Si un widget padre se reconstruye, los hijos `const` no se tocan. En este proyecto todos los widgets que no dependen de estado son `const` — `LoadingWidget`, `EmptyMembersWidget`, los `SizedBox`, los `Text` estáticos. Es la optimización más barata disponible: solo requiere agregar la keyword.

---

**5. Cómo evitás rebuilds innecesarios en una lista larga?**

> Tres estrategias principales:
> 1. Usar `ListView.builder` o `SliverList` con `SliverChildBuilderDelegate` — solo construye los items visibles, no toda la lista.
> 2. Extraer cada item en su propio widget con `const` o con `keys` estables para que Flutter pueda reconciliar el árbol eficientemente.
> 3. Usar `BlocSelector` o `buildWhen` para que el widget de la lista no se reconstruya cuando cambian partes del estado que no le afectan.
> En este proyecto uso `SliverList` con `SliverChildBuilderDelegate` precisamente por esto.

---

**6. Qué es `RepaintBoundary` y cuándo lo usás?**

> `RepaintBoundary` crea una capa de composición separada para su subárbol. Cuando ese subárbol se repinta, Flutter no tiene que repintar el resto de la pantalla. Es útil para widgets que se animan o cambian frecuentemente en una pantalla que por lo demás es estática — por ejemplo, un contador que se actualiza cada segundo, o una animación Lottie dentro de una lista. El costo es memoria adicional por la capa extra, así que no se aplica indiscriminadamente.

---

**7. Cómo profileás memoria en Flutter DevTools?**

> En el panel Memory de DevTools puedo tomar snapshots del heap y comparar entre dos puntos en el tiempo. Busco objetos que crecen sin límite — listas que se acumulan, streams que no se cierran, BLoCs que no se disposan. También uso el "Allocation Tracing" para ver qué clases se están instanciando más. Un patrón común de memory leak en Flutter BLoC es no llamar `bloc.close()` al desmontar el widget, pero `BlocProvider` lo hace automáticamente.

---

## Clean Architecture

**8. Cuál es el principio central de Clean Architecture?**

> La regla de dependencia: las capas internas no conocen a las capas externas. El dominio no sabe que existe Flutter, ni `get_it`, ni `http`. La presentación no sabe cómo se implementa el repositorio. Cada capa depende solo hacia adentro. Esto permite testear el dominio con Dart puro, cambiar el datasource sin tocar la UI, y cambiar el framework de estado sin tocar el negocio.

---

**9. Qué va en el dominio y qué no?**

> En el dominio van: entidades (objetos de negocio puros), contratos de repositorio (interfaces abstractas), y use cases (lógica de negocio). No va nada que dependa de Flutter, de packages externos, de JSON, de HTTP, ni de la UI. Si necesitás importar algo que no sea `dart:core` o tus propias entidades, probablemente estás poniendo algo en el lugar equivocado.

---

**10. Para qué sirven los use cases si solo delegan al repositorio?**

> En proyectos simples parecen innecesarios, pero tienen dos propósitos. Primero, son el punto de extensión: cuando la lógica crece — validaciones, combinación de múltiples repositorios, reglas de negocio — el use case absorbe esa complejidad sin contaminar el BLoC ni el repositorio. Segundo, son la unidad de contrato con la presentación: el BLoC no conoce el repositorio directamente, solo conoce use cases con nombres que expresan intención (`GetTeamMembers`, `RemoveTeamMember`). Eso hace el BLoC más legible y más fácil de testear en aislamiento.

---

**11. Cuál es la diferencia entre una entidad y un modelo?**

> La entidad es el objeto de negocio puro — define qué es un `TeamMember` desde la perspectiva del dominio. No sabe nada de JSON ni de APIs. El modelo es la representación de datos de una fuente concreta — sabe hacer `fromJson`, puede tener campos extras que la API devuelve pero el dominio no necesita, o nombres de campos diferentes. El modelo vive en la capa `data` y se convierte a entidad antes de salir del repositorio. En este proyecto el modelo hereda de la entidad porque la fuente es local y no hay divergencia.

---

**12. Cómo testearías el repositorio en aislamiento?**

> Mockeando el datasource. El repositorio recibe el datasource por constructor (inyección de dependencias), entonces en el test paso un mock que devuelve datos controlados. Verifico que el repositorio transforma correctamente lo que devuelve el datasource, aplica la cache, y maneja errores. Sin mocks, el test dependería de leer un archivo real, lo que lo hace lento y frágil.

---

## Dependency Injection

**13. Qué es inyección de dependencias y por qué usarla?**

> Es el patrón de pasar las dependencias de una clase desde afuera en lugar de crearlas adentro. En lugar de que `TeamMembersBloc` haga `final repo = TeamMemberRepositoryImpl()`, recibe el repositorio por constructor. Esto tiene tres ventajas: las clases son testeables (podés pasar un mock), son intercambiables (podés pasar otra implementación sin cambiar la clase), y el grafo de dependencias es explícito y centralizado.

---

**14. Qué diferencia hay entre `registerSingleton`, `registerLazySingleton` y `registerFactory` en get_it?**

> `registerSingleton` crea la instancia inmediatamente al registrarla. `registerLazySingleton` la crea la primera vez que se solicita y la reutiliza siempre. `registerFactory` crea una instancia nueva cada vez que se solicita. En este proyecto: datasource, repositorio y use cases son `lazySingleton` porque deben ser únicos y no necesitan existir desde el arranque. El BLoC es `factory` porque cada pantalla necesita una instancia nueva con estado limpio.

---

**15. Cuál es la diferencia entre Service Locator y DI por constructor?**

> Service Locator (como `get_it`) es un registro global del que cualquier clase puede pedir sus dependencias llamando a `getIt<MiClase>()`. DI por constructor es cuando las dependencias se pasan explícitamente al crear el objeto. Service Locator es más conveniente pero oculta las dependencias — desde la firma del constructor no sabés qué necesita la clase. DI por constructor es más explícita y más testeable. En este proyecto uso get_it como orquestador en la capa de composición (router, módulos de DI), pero las clases del dominio y del BLoC reciben sus dependencias por constructor — lo mejor de los dos mundos.

---

**16. Cómo manejarías dependencias con scope en get_it? Por ejemplo, dependencias que solo viven mientras una pantalla está abierta.**

> get_it tiene soporte para scopes con `pushNewScope()` y `popScope()`. Al navegar a una pantalla, abrís un scope nuevo y registrás las dependencias de esa pantalla. Al salir, hacés `popScope()` y get_it las descarta automáticamente. Es útil para dependencias costosas que no necesitan vivir toda la sesión. En este proyecto no es necesario porque el BLoC se maneja con `registerFactory` y `BlocProvider` se encarga del ciclo de vida, pero en apps más grandes los scopes son la solución escalable.

---

## Mixins

**17. Qué es un mixin en Dart y para qué sirve?**

> Un mixin es un mecanismo para reutilizar código entre clases sin herencia. Se define con `mixin` y se aplica con `on` o `with`. A diferencia de la herencia, una clase puede usar múltiples mixins. Sirve para compartir comportamiento transversal — logging, validación, analytics — sin crear jerarquías de herencia artificiales.

---

**18. Cuál es la diferencia entre `mixin`, `abstract class` y `interface` en Dart?**

> Una `abstract class` puede tener implementación y estado, pero una clase solo puede extender una. Un `mixin` no puede ser instanciado directamente y se aplica con `with` — permite múltiple composición. En Dart no existe la keyword `interface` explícita: cualquier clase o abstract class puede usarse como interfaz implementándola con `implements`, lo que obliga a implementar todos sus miembros sin heredar implementación. En Clean Architecture, los contratos de repositorio son `abstract class` usadas como interfaces con `implements`.

---

**19. Cuándo usarías un mixin en un proyecto Flutter?**

> Casos comunes:
> - `WidgetsBindingObserver` como mixin para detectar cambios de ciclo de vida de la app (foreground/background).
> - Un mixin de logging que intercepta métodos y registra llamadas.
> - Un mixin de validación de formularios reutilizable entre múltiples BLoCs o cubit.
> - `AutomaticKeepAliveClientMixin` para mantener vivo el estado de una tab en un `TabBarView`.

---

**20. Qué restricción impone `on` en un mixin?**

> `on` restringe a qué clases se puede aplicar el mixin. Por ejemplo:
> ```dart
> mixin LoadingMixin on Bloc {
>   void showLoading() => emit(LoadingState());
> }
> ```
> Solo clases que extiendan `Bloc` pueden usar `LoadingMixin`. Esto permite que el mixin acceda a métodos de la clase base con seguridad de tipos.

---

## Push Notifications — FCM / PubNub

**21. Cómo implementarías push notifications con FCM en Flutter?**

> Con el package `firebase_messaging`. El flujo es:
> 1. Inicializar Firebase con `Firebase.initializeApp()`.
> 2. Pedir permisos con `FirebaseMessaging.instance.requestPermission()`.
> 3. Obtener el token del dispositivo con `getToken()` y enviarlo al backend para asociarlo al usuario.
> 4. Configurar handlers: `onMessage` para notificaciones en foreground, `onMessageOpenedApp` para cuando el usuario toca la notificación desde background, y `getInitialMessage` para cuando la app estaba terminada.
> 5. Para mostrar notificaciones en foreground en iOS y Android se usa `flutter_local_notifications` porque FCM no las muestra automáticamente en foreground.

---

**22. Qué diferencia hay entre notificaciones en foreground, background y terminated?**

> — **Foreground**: la app está abierta. FCM entrega el mensaje a `onMessage`. La notificación no se muestra automáticamente en el sistema — tenés que mostrarla manualmente con `flutter_local_notifications` si querés que el usuario la vea.
> — **Background**: la app está en segundo plano. FCM muestra la notificación automáticamente en el sistema. Al tocarla, `onMessageOpenedApp` se dispara.
> — **Terminated**: la app está cerrada. FCM muestra la notificación. Al tocarla, la app se abre y `getInitialMessage()` devuelve el mensaje que la inició. Hay que llamarlo en el `main` después de `Firebase.initializeApp()`.

---

**23. Qué configuración específica requiere FCM en iOS que no requiere en Android?**

> En iOS hay que:
> 1. Habilitar las capabilities "Push Notifications" y "Background Modes > Remote notifications" en Xcode.
> 2. Subir el APNs Authentication Key o el APNs Certificate a la consola de Firebase.
> 3. Pedir permiso explícito al usuario con `requestPermission()` — en iOS es obligatorio, en Android a partir de Android 13 también, pero históricamente no lo era.
> 4. En algunos casos configurar `setForegroundNotificationPresentationOptions` para controlar si la notificación se muestra como banner, badge o sonido mientras la app está en foreground.

---

**24. Cómo usarías PubNub en lugar de FCM? Cuál es la diferencia principal?**

> PubNub es un servicio de mensajería en tiempo real basado en publish/subscribe. La diferencia principal con FCM es que PubNub es bidireccional y de baja latencia — está diseñado para chat, presencia, sincronización en tiempo real. FCM está optimizado para notificaciones push del sistema operativo, que el SO puede batear o retrasar para ahorrar batería. En Flutter se usa el SDK `pubnub` de Dart. Se suscribe a canales y se reciben mensajes en tiempo real a través de un stream. Para notificaciones push del sistema con PubNub se puede configurar Mobile Push Gateway que internamente usa FCM/APNs.

---

## Sockets / WebSockets

**25. Cómo implementarías WebSockets en Flutter?**

> Dart tiene soporte nativo con `WebSocket` de `dart:io`. En Flutter se puede usar directamente o el package `web_socket_channel` que provee una API más cómoda basada en streams. El flujo es:
> ```dart
> final channel = WebSocketChannel.connect(Uri.parse('wss://...'));
> channel.stream.listen((message) { /* recibir */ });
> channel.sink.add('mensaje');   // enviar
> channel.sink.close();          // cerrar
> ```
> El stream se integra naturalmente con BLoC: el BLoC escucha el stream del socket y emite estados según los mensajes recibidos.

---

**26. Cómo integrarías WebSockets con BLoC?**

> El BLoC se suscribe al stream del socket en su constructor o en respuesta a un evento, y emite estados con los datos recibidos. Es importante cancelar la suscripción en el `close()` del BLoC para evitar memory leaks:
> ```dart
> class ChatBloc extends Bloc<ChatEvent, ChatState> {
>   final WebSocketChannel _channel;
>   late final StreamSubscription _sub;
>
>   ChatBloc(this._channel) : super(ChatInitial()) {
>     _sub = _channel.stream.listen(
>       (message) => add(MessageReceived(message)),
>     );
>   }
>
>   @override
>   Future<void> close() {
>     _sub.cancel();
>     _channel.sink.close();
>     return super.close();
>   }
> }
> ```

---

**27. Cómo manejarías reconexión automática si el socket se cae?**

> Implementando un mecanismo de retry con backoff exponencial. Cuando el stream del socket emite un error o se cierra inesperadamente, espero un tiempo incremental antes de reconectar (1s, 2s, 4s, hasta un máximo). El BLoC emite un estado de `Reconnecting` para que la UI lo muestre. También escucho `ConnectivityStream` para reconectar automáticamente cuando el dispositivo recupera red. Es importante tener un límite de reintentos y un estado de `ConnectionFailed` si se agotan.

---

**28. Qué diferencia hay entre WebSockets y Server-Sent Events (SSE)?**

> WebSocket es bidireccional — cliente y servidor pueden enviarse mensajes en cualquier momento sobre la misma conexión. SSE es unidireccional — solo el servidor envía eventos al cliente sobre una conexión HTTP persistente. SSE es más simple de implementar, funciona sobre HTTP/2, y el navegador lo reconecta automáticamente. WebSocket es necesario cuando el cliente también necesita enviar mensajes frecuentes. Para casos de solo lectura como feeds de noticias o actualizaciones de estado, SSE es suficiente y más liviano.

---

## Freezed

**29. Qué es Freezed y para qué sirve?**

> Freezed es un generador de código para Dart que crea clases inmutables con value equality, `copyWith`, pattern matching y union types. Reemplaza el boilerplate de escribir `==`, `hashCode`, `copyWith` y constructores a mano. Es especialmente útil para estados, entidades y modelos donde la inmutabilidad y la igualdad por valor son importantes.

---

**30. En este proyecto usaste Equatable en lugar de Freezed. Cuál es la diferencia?**

> Equatable requiere que declares manualmente los campos en `props` y te da igualdad por valor y `toString`. Freezed genera todo automáticamente y además agrega `copyWith` e inmutabilidad forzada. Equatable es más liviano — no requiere generación de código ni `build_runner`. Freezed es más potente pero agrega complejidad al setup. Para este proyecto Equatable es suficiente. En un proyecto con modelos complejos que necesitan `copyWith` frecuente, elegiría Freezed.

---

**31. Cómo modelarías los estados del BLoC con Freezed?**

> ```dart
> @freezed
> sealed class TeamMembersState with _$TeamMembersState {
>   const factory TeamMembersState.initial() = TeamMembersInitial;
>   const factory TeamMembersState.loading() = TeamMembersLoading;
>   const factory TeamMembersState.loaded(List<TeamMember> members) = TeamMembersLoaded;
>   const factory TeamMembersState.empty() = TeamMembersEmpty;
>   const factory TeamMembersState.error(String message) = TeamMembersError;
> }
> ```
> Freezed genera `==`, `hashCode`, `copyWith` y permite usar `when` / `maybeWhen` para pattern matching. El resultado es equivalente al `sealed class` + Equatable de este proyecto, pero con menos código manual.

---

**32. Qué es `copyWith` y por qué es importante en objetos inmutables?**

> `copyWith` crea una nueva instancia del objeto con algunos campos modificados, manteniendo el resto igual. Es la alternativa a mutar un objeto directamente. En lugar de `member.name = 'nuevo'` (mutación, prohibida en objetos inmutables), hacés `member.copyWith(name: 'nuevo')` que devuelve un objeto nuevo. Esto es fundamental en BLoC — los estados son inmutables y cada cambio produce un nuevo estado, lo que hace que el flujo sea predecible y auditable.

---

**33. Freezed puede usarse para union types. Explicá con un ejemplo.**

> Un union type es un tipo que puede ser una de varias variantes, cada una con sus propios campos. Es exactamente lo que son los estados de BLoC. Con Freezed:
> ```dart
> @freezed
> class ApiResult<T> with _$ApiResult<T> {
>   const factory ApiResult.success(T data) = Success;
>   const factory ApiResult.failure(String error) = Failure;
>   const factory ApiResult.loading() = Loading;
> }
> ```
> Luego en la UI:
> ```dart
> result.when(
>   success: (data) => Text(data.toString()),
>   failure: (error) => Text(error),
>   loading: () => CircularProgressIndicator(),
> );
> ```
> El compilador garantiza que manejás todas las variantes. Es el equivalente al `sealed class` + `switch` de este proyecto, pero generado automáticamente.
