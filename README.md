# Todo en uno

App personal (un solo usuario, sin login) que reúne calendario, control de
mensualidades en MXN y notas flexibles. Sincroniza en tiempo real entre
Android y Windows vía Firebase.

Estilo: **coffee / lo-fi / chill**, paleta "Latte cálido", pensado para ser
amable con TDAH (poca carga por pantalla, jerarquía clara, animaciones suaves).

## Estado

| Fase | Contenido | Estado |
|---|---|---|
| 0 | Cimientos: tema, navegación animada, Firebase, shell | ✅ Listo |
| 1 | Mensualidades (pagos MXN, totales, gasto por categoría) | ✅ Listo |
| 2 | Notas: checklist/secuencia/imágenes + home con carpetas, drag & drop y despensa | ✅ Listo |
| 3 | Calendario e integración (pagos + notas con fecha) | ✅ Listo |

## Arranque rápido

```bash
flutter pub get
flutter run -d windows
```

Firebase ya está configurado (proyecto `my-personal-app-773f2`); ver
[`GUIA_FIREBASE.md`](GUIA_FIREBASE.md) para los detalles y lo que falta
(Storage/Blaze, necesario solo para las imágenes de la Fase 2).

## Estructura

Arquitectura *feature-first* por capas:

```
lib/
  main.dart                 # bootstrap: fechas es-MX, Firebase, ProviderScope
  app.dart                  # MaterialApp.router, tema, localización
  core/
    theme/                  # paleta, espaciado, tipografía, tema claro/oscuro
    router/                 # go_router: rutas y shell de secciones
    firebase/               # init no fatal, sesión anónima, providers
    widgets/                # shell, transiciones, andamios compartidos
  features/
    calendar/  finance/  notes/
      data/                 # modelos + repositorios (Firestore)
      application/          # providers Riverpod (streams + agregados)
      presentation/         # pantallas y widgets
```

## Convenciones

- **Estado:** Riverpod con providers escritos a mano (sin codegen).
  Los modelos sí usan `freezed` (requiere `dart run build_runner build`).
- **Colores y medidas:** nunca literales sueltos en la UI — todo sale de
  `core/theme/app_colors.dart` y `app_spacing.dart`, así el estilo es único.
- **Animaciones:** duraciones y curvas desde `AppMotion`. Nada brusco.
- **Iconos:** Material Symbols en fuente variable (`fill` 0→1 al seleccionar).
  Sin PNG ni logos rasterizados en ningún lado.

## Cómo se evitan peticiones de más

- Persistencia offline de Firestore activada: al recargar, la UI sale del caché
  local y los listeners solo reciben deltas.
- Un solo listener por colección, expuesto con `StreamProvider`; Riverpod cierra
  la suscripción cuando nadie la observa.
- Escrituras quirúrgicas (`update` / `set(merge: true)`), nunca reescribir la
  colección completa. Debounce en la edición de texto.
- Los totales y desgloses se calculan en el cliente sobre la lista ya recibida:
  cero lecturas extra para el resumen y las gráficas.
- Las secciones inactivas quedan en `Offstage`: siguen montadas (conservan su
  estado) pero no consumen layout ni pintado.
