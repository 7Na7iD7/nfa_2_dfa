import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/math_content_data.dart';
import 'dart:ui';

// Enhanced AnimatedFadeIn with more sophisticated animations
class AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;
  final bool slideFromBottom;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 800),
    this.offset = const Offset(0, 30),
    this.curve = Curves.elasticOut,
    this.slideFromBottom = true,
  });

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _opacity;
  late Animation<Offset> _position;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.duration.inMilliseconds + 200)
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart)
    );

    _position = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve)
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut)
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _scaleController]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Transform.translate(
              offset: _position.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// Enhanced ContentCard with glassmorphism and micro-interactions
class ContentCard extends StatefulWidget {
  final ContentBlock content;
  final Color color;
  final bool hasGlow;

  const ContentCard({
    super.key,
    required this.content,
    this.color = Colors.blue,
    this.hasGlow = true,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.elasticOut)
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut)
    );

    if (widget.hasGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
        HapticFeedback.lightImpact();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverController, _glowController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (_isHovered) ...[
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.15),
                          widget.color.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: widget.color.withOpacity(0.3 + (_glowAnimation.value * 0.2)),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.lightbulb_outline,
                                color: widget.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.content.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: widget.color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.content.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (widget.content.formula != null) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color.withOpacity(0.2),
                                  widget.color.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.color.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              widget.content.formula!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Mono',
                                color: widget.color,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Enhanced ExampleCard with step-by-step animation
class ExampleCard extends StatefulWidget {
  final ExampleItem example;
  final Color color;

  const ExampleCard({
    super.key,
    required this.example,
    this.color = Colors.amber,
  });

  @override
  State<ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<ExampleCard>
    with TickerProviderStateMixin {
  bool _showSteps = false;
  late AnimationController _expandController;
  late AnimationController _stepController;
  late Animation<double> _expandAnimation;
  int _currentStepIndex = -1;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _toggleSteps() async {
    setState(() => _showSteps = !_showSteps);
    HapticFeedback.mediumImpact();

    if (_showSteps) {
      _expandController.forward();
      // Animate steps one by one
      for (int i = 0; i < widget.example.steps.length; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          setState(() => _currentStepIndex = i);
        }
      }
    } else {
      _expandController.reverse();
      setState(() => _currentStepIndex = -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                widget.color.withOpacity(0.12),
                widget.color.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: widget.color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: widget.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.example.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('مسئله', widget.example.problem, Icons.help_outline),
              const SizedBox(height: 12),
              _buildInfoRow('پاسخ', widget.example.solution, Icons.check_circle_outline),
              const SizedBox(height: 16),
              InkWell(
                onTap: _toggleSteps,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.15),
                        widget.color.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showSteps ? 'مخفی کردن مراحل' : 'نمایش مراحل حل',
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _showSteps ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: widget.color,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ...widget.example.steps.asMap().entries.map((entry) {
                      final isVisible = _currentStepIndex >= entry.key;
                      return AnimatedOpacity(
                        opacity: isVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.color.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    height: 1.5,
                                    fontSize: 14,
                                    color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: widget.color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.color,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Interactive Venn Diagram with 3D effects
class InteractiveVennDiagram extends StatefulWidget {
  const InteractiveVennDiagram({super.key});

  @override
  State<InteractiveVennDiagram> createState() => _InteractiveVennDiagramState();
}

enum VennOperation { none, union, intersection, diffA, diffB }

class _InteractiveVennDiagramState extends State<InteractiveVennDiagram>
    with TickerProviderStateMixin {
  VennOperation _operation = VennOperation.none;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildButton(String label, VennOperation op, Color color, IconData icon) {
    final isSelected = _operation == op;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _operation = op);
          HapticFeedback.selectionClick();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : color.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withOpacity(0.15),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.indigo.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_tree,
                    color: Colors.indigo[300],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'نمودار ون تعاملی',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[300],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.indigo.withOpacity(0.2),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: VennDiagramPainter(_operation, _pulseAnimation.value),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildButton('اجتماع', VennOperation.union, Colors.blue, Icons.all_inclusive),
                  const SizedBox(width: 6),
                  _buildButton('اشتراک', VennOperation.intersection, Colors.red, Icons.crop_free),
                  const SizedBox(width: 6),
                  _buildButton('تفاضل A', VennOperation.diffA, Colors.green, Icons.remove_circle_outline),
                  const SizedBox(width: 6),
                  _buildButton('تفاضل B', VennOperation.diffB, Colors.purple, Icons.remove_circle_outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VennDiagramPainter extends CustomPainter {
  final VennOperation operation;
  final double animationValue;

  VennDiagramPainter(this.operation, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3.5;
    final offset = radius / 2.2;

    // Create circles with slight animation
    final animatedOffset = offset + (math.sin(animationValue * 2 * math.pi) * 2);

    final circleA = Path()..addOval(
      Rect.fromCircle(
          center: center.translate(-animatedOffset, 0),
          radius: radius
      ),
    );
    final circleB = Path()..addOval(
      Rect.fromCircle(
          center: center.translate(animatedOffset, 0),
          radius: radius
      ),
    );

    // Enhanced stroke paint with gradient effect
    final paintStroke = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final paintFill = Paint()..style = PaintingStyle.fill;

    // Draw circles
    canvas.drawPath(circleA, paintStroke);
    canvas.drawPath(circleB, paintStroke);

    // Fill based on operation
    Path? fillPath;
    Color? fillColor;

    switch (operation) {
      case VennOperation.union:
        fillPath = Path.combine(PathOperation.union, circleA, circleB);
        fillColor = Colors.blue.withOpacity(0.4 + animationValue * 0.2);
        break;
      case VennOperation.intersection:
        fillPath = Path.combine(PathOperation.intersect, circleA, circleB);
        fillColor = Colors.red.withOpacity(0.4 + animationValue * 0.2);
        break;
      case VennOperation.diffA:
        fillPath = Path.combine(PathOperation.difference, circleA, circleB);
        fillColor = Colors.green.withOpacity(0.4 + animationValue * 0.2);
        break;
      case VennOperation.diffB:
        fillPath = Path.combine(PathOperation.difference, circleB, circleA);
        fillColor = Colors.purple.withOpacity(0.4 + animationValue * 0.2);
        break;
      case VennOperation.none:
        break;
    }

    if (fillPath != null && fillColor != null) {
      // Add glow effect
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = fillColor.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(fillPath, paintFill..color = fillColor);
    }

    // Draw labels with better positioning
    _drawText(canvas, 'A', center.translate(-radius * 0.7, -radius * 0.7));
    _drawText(canvas, 'B', center.translate(radius * 0.7, -radius * 0.7));
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: 18,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2)
    );
  }

  @override
  bool shouldRepaint(covariant VennDiagramPainter oldDelegate) {
    return oldDelegate.operation != operation ||
        oldDelegate.animationValue != animationValue;
  }
}

// Enhanced QuizView with progress indicators and celebrations
class QuizView extends StatefulWidget {
  final List<QuizQuestion> questions;
  final Color color;

  const QuizView({
    super.key,
    required this.questions,
    this.color = Colors.green,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _showResult = false;
  int? _tappedAnswerIndex;
  late AnimationController _progressController;
  late AnimationController _celebrationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut)
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _selectAnswer(int questionIndex, int answerIndex) {
    setState(() => _tappedAnswerIndex = answerIndex);

    bool isCorrect = widget.questions[questionIndex].correctAnswer == answerIndex;

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      _celebrationController.forward().then((_) => _celebrationController.reset());
    } else {
      HapticFeedback.lightImpact();
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if(mounted) {
        setState(() {
          _selectedAnswers[questionIndex] = answerIndex;
          _tappedAnswerIndex = null;
          if (_currentIndex < widget.questions.length - 1) {
            _currentIndex++;
            _progressController.animateTo((_currentIndex + 1) / widget.questions.length);
          } else {
            _showResult = true;
          }
        });
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedAnswers.clear();
      _showResult = false;
      _tappedAnswerIndex = null;
    });
    _progressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      int correctCount = 0;
      for (int i = 0; i < widget.questions.length; i++) {
        if (_selectedAnswers[i] == widget.questions[i].correctAnswer) {
          correctCount++;
        }
      }
      return QuizResultCard(
        score: correctCount,
        total: widget.questions.length,
        onRetry: _resetQuiz,
        color: widget.color,
      );
    }

    final question = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            widget.color.withOpacity(0.15),
            widget.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: widget.color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with progress
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: widget.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سوال ${_currentIndex + 1} از ${widget.questions.length}',
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: widget.color.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Question
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.color.withOpacity(0.2)),
                ),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Answer options
              ...List.generate(question.options.length, (index) {
                bool isSelected = _tappedAnswerIndex == index;
                bool isCorrect = question.correctAnswer == index;
                bool showResult = _tappedAnswerIndex != null;

                AnswerState state = AnswerState.unselected;
                if (isSelected) {
                  state = isCorrect ? AnswerState.correct : AnswerState.incorrect;
                } else if (showResult && isCorrect) {
                  state = AnswerState.showCorrect;
                }

                return AnimatedFadeIn(
                  delay: Duration(milliseconds: index * 100),
                  child: AnswerOption(
                    text: question.options[index],
                    state: state,
                    onTap: () {
                      if (_tappedAnswerIndex == null) {
                        _selectAnswer(_currentIndex, index);
                      }
                    },
                  ),
                );
              }),

              // Celebration animation overlay
              if (_tappedAnswerIndex != null &&
                  _tappedAnswerIndex == widget.questions[_currentIndex].correctAnswer)
                AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green.withOpacity(
                                0.2 * _celebrationController.value
                            ),
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: 1 + (_celebrationController.value * 0.3),
                              child: Opacity(
                                opacity: 1 - _celebrationController.value,
                                child: const Icon(
                                  Icons.celebration,
                                  size: 50,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AnswerState { unselected, correct, incorrect, showCorrect }

class AnswerOption extends StatefulWidget {
  final String text;
  final AnswerState state;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnswerOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state && widget.state != AnswerState.unselected) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.grey.withOpacity(0.3);
    IconData? icon;
    Color iconColor = Colors.grey;

    switch (widget.state) {
      case AnswerState.correct:
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case AnswerState.incorrect:
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case AnswerState.showCorrect:
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green.withOpacity(0.5);
        icon = Icons.lightbulb;
        iconColor = Colors.green;
        break;
      case AnswerState.unselected:
        backgroundColor = Colors.transparent;
        break;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double shakeOffset = widget.state == AnswerState.incorrect
            ? math.sin(_shakeAnimation.value * math.pi * 4) * 3
            : 0;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform.scale(
            scale: widget.state == AnswerState.correct ? _scaleAnimation.value : 1.0,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: widget.state != AnswerState.unselected
                      ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: widget.state != AnswerState.unselected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (icon != null)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuizResultCard extends StatefulWidget {
  final int score;
  final int total;
  final VoidCallback onRetry;
  final Color color;

  const QuizResultCard({
    super.key,
    required this.score,
    required this.total,
    required this.onRetry,
    required this.color,
  });

  @override
  State<QuizResultCard> createState() => _QuizResultCardState();
}

class _QuizResultCardState extends State<QuizResultCard>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _confettiController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.score.toDouble()).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut)
    );
    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _confettiController, curve: Curves.easeOut)
    );

    // Start animations
    _scoreController.forward();
    if (widget.score / widget.total >= 0.8) {
      _confettiController.forward();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.total > 0 ? (widget.score / widget.total) * 100 : 0;
    Color resultColor = widget.color;
    String resultMessage = 'عالی!';
    IconData resultIcon = Icons.emoji_events;

    if (percentage >= 90) {
      // [FIXED] Replaced Colors.gold with Colors.amber
      resultColor = Colors.amber;
      resultMessage = 'فوق‌العاده!';
      resultIcon = Icons.star;
    } else if (percentage >= 70) {
      resultColor = Colors.green;
      resultMessage = 'خوب!';
      resultIcon = Icons.thumb_up;
    } else if (percentage >= 50) {
      resultColor = Colors.orange;
      resultMessage = 'نیاز به تمرین بیشتر';
      resultIcon = Icons.school;
    } else {
      resultColor = Colors.red;
      resultMessage = 'تلاش مجدد کنید';
      resultIcon = Icons.refresh;
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                resultColor.withOpacity(0.2),
                resultColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: resultColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: resultColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  // Result icon and title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      resultIcon,
                      size: 40,
                      color: resultColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'پایان آزمون!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    resultMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: resultColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Score display
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          resultColor.withOpacity(0.15),
                          resultColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: resultColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'نمره شما',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Text(
                              '${_scoreAnimation.value.toInt()} از ${widget.total}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: resultColor,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CustomPaint(
                            painter: CircularProgressPainter(
                              percentage / 100,
                              resultColor,
                            ),
                            child: Center(
                              child: Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: resultColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onRetry();
                      },
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text(
                        'تلاش مجدد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: resultColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: resultColor.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Confetti animation for high scores
        if (percentage >= 80)
          AnimatedBuilder(
            animation: _confettiAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ConfettiPainter(_confettiAnimation.value),
              );
            },
          ),
      ],
    );
  }
}

// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// Custom painter for confetti animation
class ConfettiPainter extends CustomPainter {
  final double animationValue;

  ConfettiPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent animation
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final color = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
      ][i % 6];

      paint.color = color.withOpacity(1 - animationValue);

      final x = size.width * random.nextDouble();
      final y = size.height * animationValue + (size.height * 0.2 * random.nextDouble());
      final radius = 3 + (5 * random.nextDouble());

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}