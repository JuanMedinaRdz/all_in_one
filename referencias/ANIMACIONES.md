# Spec de animaciones — Todo en uno

Referencia visual: los archivos `Cozy*.dc.html` (son HTML; ábrelos en el navegador para ver cada animación en vivo).
Regla general: todo es sutil y lento, nada bloquea la interacción, y **todo se desactiva con "reducir movimiento"** del sistema.

## 1. Mascota "Tacita"

SVG en viewBox `0 0 64 64`. Se basa en el logo de la taza.

```svg
<!-- vapor (3 trazos, animados) -->
<path class="steam"    d="M24 16c-3-4 3-6 0-11" stroke="#c3cad3" stroke-width="2.4" fill="none" stroke-linecap="round"/>
<path class="steam s2" d="M31 16c-3-4 3-6 0-11" .../>
<path class="steam s3" d="M38 16c-3-4 3-6 0-11" .../>
<!-- cuerpo -->
<path d="M12 22h36v12a16 16 0 0 1-16 16h-4a16 16 0 0 1-16-16z" fill="#2ecc8f"/>
<rect x="10" y="19" width="40" height="5" rx="2.5" fill="#5fe0ad"/>
<path d="M48 27h3a7 7 0 0 1 0 14h-4" fill="none" stroke="#2ecc8f" stroke-width="4.5"/>
<!-- ojos (parpadean) -->
<g class="blink"><circle cx="24" cy="33" r="2.5" fill="#0e1116"/><circle cx="36" cy="33" r="2.5" fill="#0e1116"/></g>
<!-- boca y mejillas -->
<path d="M27 38.5q3 3 6 0" fill="none" stroke="#0e1116" stroke-width="2" stroke-linecap="round"/>
<ellipse cx="19" cy="37.5" rx="2.8" ry="1.7" fill="#ff8fa3" opacity=".75"/>
<ellipse cx="41" cy="37.5" rx="2.8" ry="1.7" fill="#ff8fa3" opacity=".75"/>
```

### Estados

| Estado | Cuándo | Cambios sobre la base |
|---|---|---|
| `idle` (Tranquila) | Por defecto | vapor + parpadeo + `bob` |
| `focus` (Enfocada) | Hay ≥1 tarea "En progreso" | vapor naranja `#f0a43a` y 2× más rápido (1.4s), cejas, boca recta, relojito girando (6s) |
| `celebrate` (Celebrando) | Al marcar un paso o cerrar una tarea | ojos `^ ^` (`M21 34l3-3 3 3M33 34l3-3 3 3`), boca abierta, destellos, `hop` 2 ciclos y vuelve a `idle` |
| `sleep` (Dormida) | Estados vacíos (columna o día sin tareas) | cuerpo más oscuro `#2a8f69`, ojos cerrados (`M21 33q3 2.4 6 0M33 33q3 2.4 6 0`), sin vapor, "z z z" subiendo |

Ubicaciones: tarjeta al fondo del sidebar (escritorio), globo de ánimo en "Hoy" (móvil), columna "Hecho" vacía, hoja de "tarea completa".

## 2. Keyframes (CSS de referencia)

```css
@keyframes steam   {0%{transform:translateY(4px);opacity:0}40%{opacity:.75}100%{transform:translateY(-7px);opacity:0}}
.steam{animation:steam 2.8s ease-in-out infinite}.s2{animation-delay:.9s}.s3{animation-delay:1.8s}

@keyframes blink   {0%,92%,100%{transform:scaleY(1)}95%{transform:scaleY(.1)}}
.blink{animation:blink 4.6s infinite;transform-box:fill-box;transform-origin:center}

@keyframes bob     {0%,100%{transform:translateY(0)}50%{transform:translateY(-3px)}}      /* 3.2s */
@keyframes hop     {0%,100%{transform:translateY(0)}30%{transform:translateY(-10px)}60%{transform:translateY(0)}75%{transform:translateY(-4px)}} /* 1.4s */
@keyframes zzz     {0%{transform:translate(0,0) scale(.8);opacity:0}30%{opacity:.85}100%{transform:translate(10px,-22px) scale(1.1);opacity:0}} /* 3.2s, 3 letras con delay 0/1.1/2.2s */
@keyframes twinkle {0%,100%{transform:scale(.55);opacity:.25}50%{transform:scale(1);opacity:1}} /* 1.8s */
@keyframes pulse   {0%{transform:scale(1);opacity:.55}100%{transform:scale(1.75);opacity:0}}  /* 2.4s ease-out */
@keyframes shimmer {0%{background-position:-80px 0}100%{background-position:240px 0}}        /* 2.8s, brillo blanco 50% de 70px de ancho */
@keyframes cloud   {0%,100%{transform:translateX(0)}50%{transform:translateX(22px)}}           /* 16s y 21s */
@keyframes spin    {to{transform:rotate(360deg)}}                                               /* rayos del sol: 40s linear */
@keyframes wag     {0%,100%{transform:rotate(-8deg)}50%{transform:rotate(8deg)}}               /* flores: 1.6s, origen abajo */
@keyframes fall    {0%{transform:translateY(-20px) rotate(0);opacity:0}15%{opacity:1}100%{transform:translateY(120px) rotate(260deg);opacity:0}} /* confeti 2.6s */
@keyframes check   {from{stroke-dashoffset:24}to{stroke-dashoffset:0}}                         /* check que se dibuja, 0.5s */

@media (prefers-reduced-motion: reduce){*{animation:none!important;transition:none!important}}
```

## 3. Dónde va cada animación

| Elemento | Animación |
|---|---|
| Logo del sidebar | vapor (2 trazos verdes) |
| Día de hoy en calendario | `pulse` detrás del círculo verde |
| Header | saludo "Buen día" + sol con rayos en `spin` |
| Panel del día (espacio vacío) | paisaje: 2 nubes `cloud`, sol tenue, 2 flores `wag`, colinas verdes; texto "Día ligero" |
| Barra de progreso de tarea | relleno con `shimmer`; nodo actual con `pulse` |
| Paso recién completado | 3 puntitos `twinkle` alrededor del check; check con `check` |
| Tarjetas | hover: `translateY(-3px)` + sombra, 0.2s |
| Botón "+" (Nueva / Agregar tarea) | hover: el ícono rota 90°, 0.35s |
| Arrastrando tarjeta | tarjeta rotada -1.5° con sombra fuerte; zona destino con borde punteado del color de la columna |
| Tarea completada (móvil) | hoja inferior: confeti `fall`, Tacita `celebrate`, barra crece a 100% (1.2s), botones "Deshacer" / "Mover a Hecho" |
| Columna "Hecho" vacía | Tacita `sleep` |

## 4. Colores

Fondo `#0e1116` · tarjetas `#161b23` / `#1a2029` · borde `#222933` · texto `#e8edf2` · secundario `#8b95a3`
Verde `#2ecc8f` · morado `#a78bfa` · amarillo `#f5c542` · naranja `#f0a43a` · rosa `#ff8fa3`

## 5. Si es Flutter

- Animaciones en loop → `AnimationController(..)..repeat()` o el paquete `flutter_animate` (`.animate(onPlay: (c) => c.repeat())`).
- Tacita → `CustomPainter` o SVG con `flutter_svg`; para los estados, idealmente un archivo **Rive** con una state machine (`idle`, `focus`, `celebrate`, `sleep`).
- Confeti → paquete `confetti`.
- Reducir movimiento → `MediaQuery.of(context).disableAnimations`.
