import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/note_folder.dart';

/// Qué eligió el usuario en el selector de carpeta.
sealed class FolderPickResult {
  const FolderPickResult();
}

/// Mover a esta carpeta (`null` = sin carpeta).
class PickedFolder extends FolderPickResult {
  const PickedFolder(this.folderId);
  final String? folderId;
}

/// Quiere crear una carpeta nueva y mover la nota ahí.
class CreateNewFolder extends FolderPickResult {
  const CreateNewFolder();
}

/// Selector de carpeta para una nota.
class FolderPickerSheet extends StatelessWidget {
  const FolderPickerSheet({
    super.key,
    required this.folders,
    required this.currentId,
  });

  final List<NoteFolder> folders;
  final String? currentId;

  static Future<FolderPickResult?> show(
    BuildContext context, {
    required List<NoteFolder> folders,
    required String? currentId,
  }) {
    return showModalBottomSheet<FolderPickResult>(
      context: context,
      builder: (_) => FolderPickerSheet(folders: folders, currentId: currentId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mover a...', style: theme.textTheme.titleMedium),
              AppSpacing.gapMd,
              _Option(
                emoji: '🗒️',
                label: 'Sin carpeta',
                selected: currentId == null,
                onTap: () =>
                    Navigator.of(context).pop(const PickedFolder(null)),
              ),
              for (final f in folders)
                _Option(
                  emoji: f.emoji,
                  label: f.name,
                  selected: currentId == f.id,
                  onTap: () => Navigator.of(context).pop(PickedFolder(f.id)),
                ),
              const Divider(),
              ListTile(
                leading: Icon(
                  Symbols.create_new_folder_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Nueva carpeta...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.brMd,
                ),
                onTap: () =>
                    Navigator.of(context).pop(const CreateNewFolder()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: selected
          ? Icon(Symbols.check_rounded, color: theme.colorScheme.primary)
          : null,
      selected: selected,
      selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      shape: const RoundedRectangleBorder(borderRadius: AppSpacing.brMd),
      onTap: onTap,
    );
  }
}
