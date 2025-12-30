import 'package:flutter/material.dart';

/// 加载动画组件
class LoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final String? text;

  const LoadingAnimation({
    Key? key,
    this.size = 50.0,
    this.color,
    this.text,
  }) : super(key: key);

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
      duration: const Duration(seconds: 2),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 外圈旋转
                Transform.rotate(
                  angle: _controller.value * 2 * 3.14159,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (widget.color ?? Colors.blue).withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _LoadingPainter(
                        color: widget.color ?? Colors.blue,
                        progress: _controller.value,
                      ),
                    ),
                  ),
                ),
                // 中心音符图标
                Icon(
                  Icons.music_note,
                  size: widget.size * 0.4,
                  color: widget.color ?? Colors.blue,
                ),
              ],
            );
          },
        ),
        if (widget.text != null) ...[
          const SizedBox(height: 10),
          Text(
            widget.text!,
            style: TextStyle(
              color: widget.color ?? Colors.blue,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _LoadingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -3.14159 / 2;
    final sweepAngle = 3.14159 * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_LoadingPainter oldDelegate) => true;
}

/// 脉冲加载动画
class PulseLoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;

  const PulseLoadingAnimation({
    Key? key,
    this.size = 50.0,
    this.color,
  }) : super(key: key);

  @override
  State<PulseLoadingAnimation> createState() => _PulseLoadingAnimationState();
}

class _PulseLoadingAnimationState extends State<PulseLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              Icons.album,
              size: widget.size,
              color: widget.color ?? Colors.blue,
            ),
          ),
        );
      },
    );
  }
}

/// 三点跳跃加载动画
class DotsLoadingAnimation extends StatefulWidget {
  final Color? color;
  final double size;

  const DotsLoadingAnimation({
    Key? key,
    this.color,
    this.size = 10.0,
  }) : super(key: key);

  @override
  State<DotsLoadingAnimation> createState() => _DotsLoadingAnimationState();
}

class _DotsLoadingAnimationState extends State<DotsLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final bounce = (0.5 - (value - 0.5).abs()) * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, -bounce * 10),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color ?? Colors.blue,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
