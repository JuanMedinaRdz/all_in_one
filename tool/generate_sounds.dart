// Genera los sonidos de la interfaz sintetizándolos, en vez de depender de
// assets descargados. Correr con:
//
//     dart run tool/generate_sounds.dart
//
// Produce `assets/sounds/tap_a.wav` y `tap_b.wav`: dos variantes de un "thock"
// suave de tecla, cálido y corto, al estilo lo-fi. Se alternan al azar para que
// tocar la app no suene monótono ni robótico.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _sampleRate = 44100;

void main() {
  final dir = Directory('assets/sounds')..createSync(recursive: true);

  // Tres alturas ligeramente distintas: el oído las percibe como "la misma
  // tecla" pero evita el efecto de bucle exacto. Muy graves a propósito: es lo
  // que separa un "thock" cremoso de un "clack" agudo.
  File('${dir.path}/tap_a.wav').writeAsBytesSync(_thock(baseHz: 96));
  File('${dir.path}/tap_b.wav').writeAsBytesSync(_thock(baseHz: 108));
  File('${dir.path}/tap_c.wav').writeAsBytesSync(_thock(baseHz: 120));

  stdout.writeln('Listo: assets/sounds/tap_a.wav, tap_b.wav y tap_c.wav');
}

/// Sintetiza un "thock" de teclado mecánico **creamy** (~130 ms).
///
/// La firma de un switch lineal bien lubricado es: grave, redondo y lleno, sin
/// el chasquido agudo de los clicky. Se arma en cuatro capas:
/// - **Sub**: el "bottom out", la profundidad que se siente más que se oye.
/// - **Cuerpo**: la fundamental, que cae un poco de tono como el plástico real.
/// - **Modo**: una resonancia no armónica y muy corta, el carácter del material.
/// - **Transitorio**: ruido triplemente suavizado y discreto. Define el ataque
///   sin sonar a "clack"; si se sube, deja de ser creamy.
///
/// Al final pasa por un filtro paso-bajo: quitar los agudos es justo lo que
/// convierte un golpe seco en uno cremoso.
Uint8List _thock({required double baseHz}) {
  // Más largo y con cola más suave = sensación "marshmallow", no seca.
  const duration = 0.13;
  final samples = (duration * _sampleRate).round();
  final buffer = List<double>.filled(samples, 0);
  final rand = math.Random(baseHz.round()); // determinista: mismo wav siempre

  // Tres polos de suavizado dejan el ruido mullido, sin aspereza digital.
  var n1 = 0.0, n2 = 0.0, n3 = 0.0;

  for (var i = 0; i < samples; i++) {
    final t = i / _sampleRate;

    // Sub grave y con más cuerpo: la profundidad del "bottom out" que se siente.
    final sub = math.sin(2 * math.pi * (baseHz * 0.5) * t) *
        math.exp(-t / 0.05) *
        0.8;

    // El tono cae ~11%: da el "poik" orgánico del plástico al asentarse.
    final freq = baseHz * (1 - 0.11 * (t / duration));
    final body = math.sin(2 * math.pi * freq * t) * math.exp(-t / 0.038) * 0.95;

    // Resonancia de material: más baja y mucho más discreta (nada de "ping").
    final mode = math.sin(2 * math.pi * (baseHz * 2.1) * t) *
        math.exp(-t / 0.007) *
        0.06;

    // Transitorio (el "toque"): muy reducido y más corto. Subirlo lo vuelve
    // "clacky"; bajarlo es lo que lo hace cremoso.
    final white = rand.nextDouble() * 2 - 1;
    n1 = n1 * 0.80 + white * 0.20;
    n2 = n2 * 0.80 + n1 * 0.20;
    n3 = n3 * 0.80 + n2 * 0.20;
    final tap = n3 * math.exp(-t / 0.004) * 0.9;

    // Ataque de 2 ms: más redondo, sin el "pop" ni el filo del arranque.
    final attack = math.min(1.0, t / 0.002);
    buffer[i] = (sub + body + mode + tap) * attack;
  }

  // Corte bajo, aplicado dos veces (pendiente más pronunciada): quitar agudos
  // es lo que convierte el golpe en algo cremoso, sin filo ni "ping".
  _lowPass(buffer, cutoffHz: 1150);
  _lowPass(buffer, cutoffHz: 1150);

  // Normalizar antes de saturar da un nivel de entrada predecible al soft clip;
  // volver a normalizar después recupera el volumen que la saturación comprime
  // (si no, el archivo saldría al ~56% y sonaría flojo).
  _normalize(buffer, peak: 1);
  for (var i = 0; i < samples; i++) {
    buffer[i] = _softClip(buffer[i]);
  }
  _normalize(buffer, peak: 0.95);

  final data = Int16List(samples);
  for (var i = 0; i < samples; i++) {
    data[i] = (buffer[i] * 32767).clamp(-32768, 32767).round();
  }
  return _wavFile(data);
}

/// Filtro paso-bajo de un polo, aplicado en sitio. Es lo que da la cremosidad:
/// recorta el brillo que haría sonar la tecla "clacky".
void _lowPass(List<double> samples, {required double cutoffHz}) {
  final dt = 1 / _sampleRate;
  final rc = 1 / (2 * math.pi * cutoffHz);
  final alpha = dt / (rc + dt);

  var previous = 0.0;
  for (var i = 0; i < samples.length; i++) {
    previous += alpha * (samples[i] - previous);
    samples[i] = previous;
  }
}

/// Escala el buffer para que su pico quede en [peak]. Así ambas variantes
/// suenan igual de fuertes aunque su mezcla interna difiera.
void _normalize(List<double> samples, {required double peak}) {
  var max = 0.0;
  for (final s in samples) {
    final abs = s.abs();
    if (abs > max) max = abs;
  }
  if (max < 1e-9) return;

  final gain = peak / max;
  for (var i = 0; i < samples.length; i++) {
    samples[i] *= gain;
  }
}

double _softClip(double x) => _tanhApprox(x * 1.6) / 1.6;

/// `tanh` no viene en dart:math; se arma con exponenciales.
double _tanhApprox(double x) {
  final e2 = math.exp(2 * x);
  return (e2 - 1) / (e2 + 1);
}

/// Empaqueta las muestras en un WAV PCM 16-bit mono.
Uint8List _wavFile(Int16List samples) {
  final dataBytes = samples.buffer.asUint8List();
  final builder = BytesBuilder();

  void ascii(String s) => builder.add(s.codeUnits);
  void u32(int v) => builder.add(Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little));
  void u16(int v) => builder.add(Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little));

  ascii('RIFF');
  u32(36 + dataBytes.length);
  ascii('WAVE');
  ascii('fmt ');
  u32(16); // tamaño del chunk fmt
  u16(1); // PCM
  u16(1); // mono
  u32(_sampleRate);
  u32(_sampleRate * 2); // byte rate (1 canal * 16 bits)
  u16(2); // block align
  u16(16); // bits por muestra
  ascii('data');
  u32(dataBytes.length);
  builder.add(dataBytes);

  return builder.toBytes();
}
