import 'package:flutter/material.dart';

enum AuthTab { login, signUp }

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: Image.asset(
        'lib/core/assets/yoummy_logo.png',
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) {
          return Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(size * 0.25),
            ),
          );
        },
      ),
    );
  }
}

class AuthTabs extends StatelessWidget {
  final AuthTab selected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;

  const AuthTabs({
    super.key,
    required this.selected,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.22)
        : Colors.white;
    final indicatorColor = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.7)
        : Colors.white;
    final shadowColor = isDark
        ? Color(0x330F4CFF)
        : theme.colorScheme.primary.withValues(alpha: 0.16);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(5),
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOutCubic,
            alignment: selected == AuthTab.login
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: isDark ? 18 : 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _AuthSegmentButton(
                  label: 'Log In',
                  selected: selected == AuthTab.login,
                  onTap: onLoginTap,
                ),
              ),
              Expanded(
                child: _AuthSegmentButton(
                  label: 'Sign Up',
                  selected: selected == AuthTab.signUp,
                  onTap: onSignUpTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthSegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AuthSegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.onSurface;
    final inactiveColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.8)
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: onTap,
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: selected ? activeColor : inactiveColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const GradientPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = Color.lerp(primary, Colors.black, 0.12) ?? primary;
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330F4CFF),
              blurRadius: 12,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.2,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  final VoidCallback onTap;

  const GoogleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/core/assets/google_logo.png',
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.brightness == Brightness.dark
        ? Color.lerp(primary, Colors.white, 0.08) ?? primary
        : Color.lerp(primary, Colors.black, 0.35) ?? primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (!width.isFinite || !height.isFinite) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [secondary, primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _AccentPainter(
                  stripeColor: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-1.1, -0.9),
              child: Container(
                width: width * 0.9,
                height: width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(1.05, 1.1),
              child: Container(
                width: width * 0.7,
                height: width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            ..._foodSpots.map((spot) {
              final icon = _foodIcons[spot.iconIndex % _foodIcons.length];
              return Positioned(
                left: spot.dx * width,
                top: spot.dy * height,
                child: Transform.rotate(
                  angle: spot.rotation,
                  child: Opacity(
                    opacity: 0.32,
                    child: Icon(
                      icon,
                      size: 35,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _AccentPainter extends CustomPainter {
  final Color stripeColor;

  _AccentPainter({required this.stripeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = stripeColor;

    final path1 = Path()
      ..moveTo(0, size.height * 0.18)
      ..lineTo(size.width * 0.55, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.14)
      ..close();

    final path2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.35, size.height)
      ..lineTo(size.width, size.height * 0.58)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width * 0.25, size.height)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FoodSpot {
  final double dx;
  final double dy;
  final int iconIndex;
  final double rotation;

  const _FoodSpot({
    required this.dx,
    required this.dy,
    required this.iconIndex,
    this.rotation = 0,
  });
}

const _foodIcons = [
  Icons.local_pizza,
  Icons.ramen_dining,
  Icons.emoji_food_beverage,
  Icons.icecream,
  Icons.lunch_dining,
  Icons.rice_bowl,
  Icons.coffee,
  Icons.cookie,
  Icons.egg_alt,
  Icons.fastfood,
  Icons.kebab_dining,
  Icons.local_dining,
  Icons.set_meal,
  Icons.soup_kitchen,
  Icons.local_cafe,
  Icons.bakery_dining,
  Icons.brunch_dining,
  Icons.cake,
  Icons.donut_small,
  Icons.icecream_outlined,
  Icons.local_bar,
  Icons.local_cafe_outlined,
  Icons.local_drink,
];

const _foodSpots = [
  _FoodSpot(dx: 0.03, dy: 0.05, iconIndex: 0, rotation: -0.06),
  _FoodSpot(dx: 0.24, dy: 0.12, iconIndex: 1, rotation: 0.07),
  _FoodSpot(dx: 0.08, dy: 0.22, iconIndex: 2, rotation: -0.05),
  _FoodSpot(dx: 0.35, dy: 0.26, iconIndex: 3, rotation: 0.1),
  _FoodSpot(dx: 0.46, dy: 0.16, iconIndex: 4, rotation: -0.08),
  _FoodSpot(dx: 0.62, dy: 0.12, iconIndex: 5, rotation: 0.05),
  _FoodSpot(dx: 0.78, dy: 0.10, iconIndex: 6, rotation: -0.04),
  _FoodSpot(dx: 0.92, dy: 0.16, iconIndex: 7, rotation: 0.12),
  _FoodSpot(dx: 0.18, dy: 0.34, iconIndex: 8, rotation: -0.1),
  _FoodSpot(dx: 0.68, dy: 0.26, iconIndex: 9, rotation: 0.06),
  _FoodSpot(dx: 0.54, dy: 0.32, iconIndex: 10, rotation: -0.07),
  _FoodSpot(dx: 0.90, dy: 0.42, iconIndex: 7, rotation: -0.05),
  _FoodSpot(dx: 0.20, dy: 0.60, iconIndex: 8, rotation: 0.08),
  _FoodSpot(dx: 0.40, dy: 0.58, iconIndex: 9, rotation: -0.06),
  _FoodSpot(dx: 0.60, dy: 0.56, iconIndex: 10, rotation: 0.1),
  _FoodSpot(dx: 0.82, dy: 0.58, iconIndex: 11, rotation: -0.08),
  _FoodSpot(dx: 0.06, dy: 0.70, iconIndex: 12, rotation: 0.06),
  _FoodSpot(dx: 0.26, dy: 0.68, iconIndex: 13, rotation: -0.05),
  _FoodSpot(dx: 0.44, dy: 0.70, iconIndex: 14, rotation: 0.1),
  _FoodSpot(dx: 0.64, dy: 0.68, iconIndex: 15, rotation: -0.07),
  _FoodSpot(dx: 0.86, dy: 0.66, iconIndex: 16, rotation: 0.08),
  _FoodSpot(dx: 0.14, dy: 0.80, iconIndex: 17, rotation: -0.04),
  _FoodSpot(dx: 0.34, dy: 0.82, iconIndex: 18, rotation: 0.09),
  _FoodSpot(dx: 0.56, dy: 0.80, iconIndex: 19, rotation: -0.08),
  _FoodSpot(dx: 0.76, dy: 0.78, iconIndex: 20, rotation: 0.07),
  _FoodSpot(dx: 0.92, dy: 0.76, iconIndex: 21, rotation: -0.06),
  _FoodSpot(dx: 0.22, dy: 0.92, iconIndex: 22, rotation: 0.05),
  _FoodSpot(dx: 0.46, dy: 0.90, iconIndex: 23, rotation: -0.09),
  _FoodSpot(dx: 0.70, dy: 0.92, iconIndex: 24, rotation: 0.1),
  _FoodSpot(dx: 0.90, dy: 0.90, iconIndex: 25, rotation: -0.08),
];

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required String hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2F6BFF), width: 1.4),
    ),
    suffixIcon: suffixIcon,
  );
}
