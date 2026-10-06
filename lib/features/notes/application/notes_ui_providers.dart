import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de interfaz del apartado de Notas (no se persiste; es de sesión).

/// Vista del Inicio: cuadrícula o lista de espacios.
class HomeSpacesGrid extends Notifier<bool> {
  @override
  bool build() => true; // true = cuadrícula
  void set(bool grid) => state = grid;
}

final homeSpacesGridProvider =
    NotifierProvider<HomeSpacesGrid, bool>(HomeSpacesGrid.new);

/// Vista dentro de un espacio.
enum SpaceView { cards, list, board }

class SpaceViewMode extends Notifier<SpaceView> {
  @override
  SpaceView build() => SpaceView.cards;
  void set(SpaceView v) => state = v;
}

final spaceViewProvider =
    NotifierProvider<SpaceViewMode, SpaceView>(SpaceViewMode.new);

/// Orden dentro de un espacio.
enum SpaceSort {
  recent('Recientes'),
  name('Nombre'),
  pending('Pendientes');

  const SpaceSort(this.label);
  final String label;

  SpaceSort get next => SpaceSort.values[(index + 1) % SpaceSort.values.length];
}

class SpaceSortMode extends Notifier<SpaceSort> {
  @override
  SpaceSort build() => SpaceSort.recent;
  void set(SpaceSort s) => state = s;
}

final spaceSortProvider =
    NotifierProvider<SpaceSortMode, SpaceSort>(SpaceSortMode.new);

/// Texto del buscador global de Notas.
class NotesSearch extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
  void clear() => state = '';
}

final notesSearchProvider = NotifierProvider<NotesSearch, String>(NotesSearch.new);
