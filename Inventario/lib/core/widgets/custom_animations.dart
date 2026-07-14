import 'package:flutter/material.dart';

// ============================================
// ANIMACIÓN DE ÉXITO (CHECK VERDE)
// ============================================
class SuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const SuccessAnimation({super.key, this.onComplete, this.size = 100});

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward().then((_) => widget.onComplete?.call());
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade400, Colors.green.shade700],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade300.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
      ),
    );
  }
}

// ============================================
// ANIMACIÓN DE ERROR (X ROJA)
// ============================================
class ErrorAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const ErrorAnimation({super.key, this.onComplete, this.size = 100});

  @override
  State<ErrorAnimation> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _shakeAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    _controller.forward().then((_) => widget.onComplete?.call());
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.rotate(
              angle: (_shakeAnimation.value) * (3.14159 / 180),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade400, Colors.red.shade700],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade300.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 50),
      ),
    );
  }
}

// ============================================
// ANIMACIÓN DE CARGA (SPINNER)
// ============================================
class LoadingAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const LoadingAnimation({super.key, this.size = 80, this.color = Colors.blue});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: widget.color.withOpacity(0.2), width: 3),
        ),
        child: Center(
          child: SizedBox(
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            child: CircularProgressIndicator(
              color: widget.color,
              strokeWidth: 4,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
//  ANIMACIÓN DE CONFETI
// ============================================

class ConfettiAnimation extends StatefulWidget {
  final int particleCount;
  final double size;

  const ConfettiAnimation({
    super.key,
    this.particleCount = 80,
    this.size = 300,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particles = List.generate(
      widget.particleCount,
      (index) => _ConfettiParticle.random(index),
    );

    _controller.forward();
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
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double startX;
  final double startY;
  final double size;
  final Color color;
  final double speed;
  final double drift; // desviación lateral
  final double rotationSpeed;

  _ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.size,
    required this.color,
    required this.speed,
    required this.drift,
    required this.rotationSpeed,
  });

  factory _ConfettiParticle.random(int seed) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.lime,
      Colors.deepOrange,
      Colors.deepPurple,
    ];

    // Usar el seed para generar números aleatorios consistentes
    final rng = (seed * 9973 + 7919) % 100000;

    return _ConfettiParticle(
      startX: 0.05 + ((rng % 900) / 900) * 0.9,
      startY: 0.1 + ((rng % 800) / 800) * 0.8,
      size: 3 + (rng % 7),
      color: colors[rng % colors.length],
      speed: 0.4 + (rng % 100) / 100,
      drift: (rng % 200 - 100) / 200,
      rotationSpeed: (rng % 300 - 150) / 150,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      // ✅ Movimiento: caen desde arriba con desviación lateral
      final yOffset = progress * p.speed * size.height * 0.7;
      final xOffset = progress * p.drift * size.width * 0.3;

      final x = (p.startX * size.width) + xOffset;
      final y = (p.startY * size.height) - yOffset;

      // Si la partícula se salió de la pantalla, la reposicionamos arriba
      final finalY = y < -20 ? size.height + 20 : y;
      final finalX = x < -20
          ? size.width + 20
          : (x > size.width + 20 ? -20 : x);

      // Rotación
      final rotation = progress * 8 * p.rotationSpeed;

      canvas.save();
      canvas.translate(finalX.toDouble(), finalY.toDouble());
      canvas.rotate(rotation);

      // Dibujar confeti (rectángulo)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size * 0.6,
      );
      final rrect = RRect.fromRectXY(rect, 2, 2);
      canvas.drawRRect(rrect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
