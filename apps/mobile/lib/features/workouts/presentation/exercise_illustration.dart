import 'package:flutter/material.dart';

import '../domain/exercise_illustrations.dart';
import '../domain/exercise_pose.dart';

/// Schematická ilustrace cviku (C54 §2/§3): nativní vykreslení archetypu
/// s plynulou interpolací klíčových poloh. [animate] = false (pauza,
/// `disableAnimations`, detail) → statická první poloha (EXI-009).
/// Kód bez archetypu → `SizedBox.shrink()` (poctivý fallback, EXI-004).
class ExerciseIllustration extends StatefulWidget {
  const ExerciseIllustration({
    required this.exerciseCode,
    this.animate = true,
    this.size = 120,
    super.key,
  });

  final String exerciseCode;
  final bool animate;
  final double size;

  static Key illustrationKey(String code) => Key('exercise_illustration_$code');

  @override
  State<ExerciseIllustration> createState() => _ExerciseIllustrationState();
}

class _ExerciseIllustrationState extends State<ExerciseIllustration>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  ExercisePoseAnimation? get _animation => illustrationFor(widget.exerciseCode);

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ExerciseIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseCode != widget.exerciseCode ||
        oldWidget.animate != widget.animate) {
      _sync();
    }
  }

  void _sync() {
    final animation = _animation;
    _controller?.dispose();
    _controller = null;
    if (animation == null || animation.frames.length < 2) {
      return;
    }
    final controller = AnimationController(
      vsync: this,
      duration: animation.cycle * (animation.loop == PoseLoop.pingPong ? 2 : 1),
    );
    _controller = controller;
    if (widget.animate) {
      controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    if (animation == null || !animation.isValid) {
      return const SizedBox.shrink();
    }
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final controller = _controller;
    if (controller != null) {
      if (widget.animate && !disable && !controller.isAnimating) {
        controller.repeat();
      } else if ((!widget.animate || disable) && controller.isAnimating) {
        controller.stop();
      }
    }
    final color = Theme.of(context).colorScheme.onSurface;
    final accent = Theme.of(context).colorScheme.primary;
    return SizedBox(
      key: ExerciseIllustration.illustrationKey(widget.exerciseCode),
      width: widget.size,
      height: widget.size,
      child: controller == null
          ? CustomPaint(
              painter: PosePainter(
                animation: animation,
                t: 0,
                color: color,
                accent: accent,
              ),
            )
          : AnimatedBuilder(
              animation: controller,
              builder: (context, _) => CustomPaint(
                painter: PosePainter(
                  animation: animation,
                  t: controller.value,
                  color: color,
                  accent: accent,
                ),
              ),
            ),
    );
  }
}

/// Deterministický painter: postava v čase [t] (0..1) + rekvizity.
class PosePainter extends CustomPainter {
  const PosePainter({
    required this.animation,
    required this.t,
    required this.color,
    required this.accent,
  });

  final ExercisePoseAnimation animation;
  final double t;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final prop = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.round;
    for (final item in animation.props) {
      switch (item) {
        case PoseProp.floor:
          canvas.drawLine(
            Offset(size.width * 0.04, size.height * 0.9),
            Offset(size.width * 0.96, size.height * 0.9),
            prop,
          );
        case PoseProp.bar:
          canvas.drawLine(
            Offset(size.width * 0.28, size.height * 0.08),
            Offset(size.width * 0.72, size.height * 0.08),
            prop,
          );
        case PoseProp.rings:
          for (final x in [0.42, 0.58]) {
            canvas.drawLine(
              Offset(size.width * x, 0),
              Offset(size.width * x, size.height * 0.3),
              prop,
            );
          }
        case PoseProp.wall:
          canvas.drawLine(
            Offset(size.width * 0.96, size.height * 0.02),
            Offset(size.width * 0.96, size.height * 0.98),
            prop,
          );
        case PoseProp.bench:
          canvas.drawRect(
            Rect.fromLTWH(
              size.width * 0.14,
              size.height * 0.64,
              size.width * 0.6,
              size.height * 0.05,
            ),
            prop..style = PaintingStyle.fill,
          );
        case PoseProp.box:
          canvas.drawRect(
            Rect.fromLTWH(
              size.width * 0.5,
              size.height * 0.74,
              size.width * 0.3,
              size.height * 0.16,
            ),
            prop..style = PaintingStyle.stroke,
          );
        case PoseProp.roller:
          canvas.drawCircle(
            Offset(size.width * 0.5, size.height * 0.84),
            size.width * 0.06,
            prop..style = PaintingStyle.stroke,
          );
      }
    }

    final points = poseAt(animation, t);
    final line = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Offset scaled(Offset p) => Offset(p.dx * size.width, p.dy * size.height);
    for (final (a, b) in animation.topology.segments) {
      canvas.drawLine(scaled(points[a]), scaled(points[b]), line);
    }
    final head = animation.topology.head;
    if (head >= 0) {
      canvas.drawCircle(
        scaled(points[head]),
        size.width * 0.07,
        Paint()..color = accent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.animation != animation ||
      oldDelegate.color != color;
}
