# Guía de configuración de Firebase

> **Estado: ya configurado y funcionando** ✅
>
> - Proyecto: `my-personal-app-773f2`
> - Firestore en modo producción, con las reglas de este repo publicadas
> - Login anónimo activo (verificado: la app crea sesión al arrancar)
> - Apps registradas: Android y Windows
>
> **Pendiente (solo para la Fase 2, notas con imágenes):** activar el plan
> **Blaze** y **Storage**. Las Mensualidades (Fase 1) no lo necesitan.
>
> Lo de abajo queda como referencia, por si algún día hay que rehacerlo o
> configurar otra máquina.

---

## 1. Crear el proyecto

1. Entra a <https://console.firebase.google.com> y crea un proyecto
   (por ejemplo `todo-en-uno`). Puedes desactivar Google Analytics.

## 2. Activar el plan Blaze

Necesario **solo por Firebase Storage** (las imágenes de las notas).
Pide tarjeta, pero el uso personal cabe de sobra en la capa gratuita
(5 GB de almacenamiento, 1 GB/día de descarga). En la práctica: ~$0 MXN.

- En la consola: engrane ⚙️ → **Uso y facturación** → **Modificar plan** → **Blaze**.
- Recomendado: define un **presupuesto con alerta** (p. ej. $50 MXN) para
  enterarte si algo se dispara.

## 3. Activar el login anónimo

Es lo que da sesión a la app sin que tú veas ninguna pantalla de login.

- **Authentication** → **Get started** → pestaña **Sign-in method**
  → **Anonymous** → *Enable* → Guardar.

## 4. Crear la base y el bucket

- **Firestore Database** → *Create database* → modo **Production** → elige la
  región `nam5` o la más cercana a México.
- **Storage** → *Get started* → modo **Production** → misma región.

> No te preocupes por las reglas que sugiere la consola: las sobrescribimos
> en el paso 7 con las de este repo.

---

## 5. Instalar las herramientas

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

## 6. Conectar el proyecto con la app

Desde la raíz del proyecto (`all_in_one`):

```bash
firebase login
flutterfire configure --platforms=android,windows
```

Elige tu proyecto en la lista. Esto **regenera `lib/firebase_options.dart`**
con tus credenciales reales y reemplaza el marcador de posición actual.

## 7. Publicar las reglas de seguridad

```bash
firebase deploy --only firestore:rules,storage
```

Las reglas ya están escritas en [`firestore.rules`](firestore.rules) y
[`storage.rules`](storage.rules): exigen sesión iniciada y solo permiten tocar
`workspace/main`. Todo lo demás queda bloqueado.

## 8. Probar

```bash
flutter run -d windows
```

El aviso ámbar debe desaparecer. En la consola de Firebase, en
**Authentication → Users**, verás aparecer un usuario anónimo.

---

## Cómo están organizados los datos

Todo vive bajo un único documento raíz compartido:

```
workspace/main/payments/{id}   ← mensualidades
workspace/main/notes/{id}      ← notas
workspace/main/events/{id}     ← calendario
```

**Por qué no `users/{uid}`:** no hay login, así que cada dispositivo recibe un
UID anónimo distinto. Si los datos colgaran del UID, tu teléfono y tu PC verían
información diferente. Con una ruta fija compartida, ambos ven lo mismo y las
reglas siguen exigiendo una sesión válida.

---

## Notas

- **Android:** para compilar en tu teléfono necesitas **Android SDK 36**
  (ahora tienes el 35). En Android Studio: *SDK Manager* → instalar API 36.
  También acepta las licencias con `flutter doctor --android-licenses`.
- **No borres `lib/firebase_options.dart` del repo**, pero recuerda que
  contiene claves de tu proyecto. Al ser una app personal y con reglas que
  exigen sesión, no es un riesgo grave, pero no lo publiques en un repo público.
