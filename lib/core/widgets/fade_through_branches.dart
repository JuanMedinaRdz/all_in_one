import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Contenedor de las secciones del shell con transición *fade-through*.
///
/// Optimización: solo se pintan la sección activa y (durante la transición) la
/// saliente. Las demás quedan en [Offstage] — siguen montadas, así que
/// conservan su estado y sus listeners, pero no consumen layout ni pintado.
class FadeThroughBranches extends StatefulWidget {
  const FadeThroughBranches({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<FadeThroughBranches> createState() => _FadeThroughBranchesState();
}

class _FadeThroughBranchesState extends State<FadeThroughBranches>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
      value: 1, // sin animación en el primer build
    );
  }

  @override
  void didUpdateWidget(FadeThroughBranches oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isAnimating = _controller.value < 1;
        return Stack(
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _branch(i, isAnimating),
          ],
        );
      },
    );
  }

  Widget _branch(int index, bool isAnimating) {
    final isCurrent = index == widget.currentIndex;
    final isOutgoing = !isCurrent && index == _previousIndex && isAnimating;
    final child = widget.children[index];

    // Fuera de escena: montada (conserva estado) pero sin layout ni pintado.
    if (!isCurrent && !isOutgoing) {
      return Offstage(
        child: TickerMode(enabled: false, child: child),
      );
    }

    final t = _controller.value;
    final opacity = isCurrent
        ? Curves.easeOut.transform(t)
        : 1 - Curves.easeIn.transform(t);
    // La entrante crece muy sutilmente: da sensación de calma, no de brinco.
    final scale = isCurrent ? 0.985 + 0.015 * t : 1.0;

    return IgnorePointer(
      ignoring: !isCurrent,
      child: TickerMode(
        enabled: isCurrent,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        ),
      ),
    );
  }
}
