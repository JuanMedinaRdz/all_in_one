import 'package:flutter/material.dart';

import '../../data/person.dart';

/// Avatar circular de una persona: emoji sobre un anillo de su color.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.person,
    this.size = 40,
    this.selected = false,
    this.dimmed = false,
  });

  final Person person;
  final double size;
  final bool selected;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: person.color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? person.color : scheme.outline.withValues(alpha: 0.4),
            width: selected ? 2.5 : 1.5,
          ),
        ),
        child: Text(person.emoji, style: TextStyle(fontSize: size * 0.5)),
      ),
    );
  }
}
