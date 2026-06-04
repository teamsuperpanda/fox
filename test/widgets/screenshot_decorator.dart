import 'package:flutter/material.dart';

const _headerHeight = 90.0;
const _footerHeight = 80.0;
const _frameBezelWidth = 3.0;
const _frameCornerRadius = 28.0;
const _screenCornerRadius = 18.0;
const _frameHPadding = 16.0;
const _frameTopPadding = 8.0;
const _frameBottomPadding = 8.0;

class ScreenshotDecorator extends StatelessWidget {
  const ScreenshotDecorator({
    required this.child,
    required this.deviceWidth,
    required this.deviceHeight,
    required this.light,
    this.tagline,
    this.marketingLine1,
    this.marketingLine2,
    this.canvasColor,
    super.key,
  });

  final Widget child;
  final double deviceWidth;
  final double deviceHeight;
  final bool light;
  final String? tagline;
  final String? marketingLine1;
  final String? marketingLine2;
  final Color? canvasColor;

  double get _screenWidth =>
      deviceWidth - _frameHPadding * 2 - _frameBezelWidth * 2;

  double get _screenHeight =>
      deviceHeight -
      _headerHeight -
      _footerHeight -
      _frameTopPadding -
      _frameBezelWidth * 2 -
      _frameBottomPadding;

  double get _frameWidth => _screenWidth + _frameBezelWidth * 2;

  double get _frameHeight => _screenHeight + _frameBezelWidth * 2;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        canvasColor ??
        (light ? const Color(0xFFF5F3F0) : const Color(0xFF202124));

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: deviceWidth,
        height: deviceHeight,
        color: bgColor,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _headerHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _Header(light: light, tagline: tagline),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _footerHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _Footer(
                  light: light,
                  line1: marketingLine1,
                  line2: marketingLine2,
                ),
              ),
            ),
            Positioned(
              top: _headerHeight,
              left: 0,
              right: 0,
              bottom: _footerHeight,
              child: Center(
                child: _buildFrame(bgColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrame(Color bgColor) {
    return SizedBox(
      width: _frameWidth,
      height: _frameHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_frameCornerRadius),
                border: Border.all(
                  color:
                      light ? Colors.grey.shade300 : Colors.grey.shade700,
                  width: _frameBezelWidth,
                ),
                color: bgColor,
              ),
            ),
          ),
          Positioned(
            top: _frameBezelWidth,
            left: _frameBezelWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_screenCornerRadius),
              child: SizedBox(
                width: _screenWidth,
                height: _screenHeight,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.light, this.tagline});

  final bool light;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fox',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            fontFamilyFallback: const [
              'NotoNaskhArabic',
              'NotoSansDevanagari',
              'NotoSansCJK',
            ],
            color: light ? const Color(0xFF333333) : Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tagline ?? 'Your notes, your way',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
            fontFamilyFallback: const [
              'NotoNaskhArabic',
              'NotoSansDevanagari',
              'NotoSansCJK',
            ],
            color: light ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.light,
    this.line1,
    this.line2,
  });

  final bool light;
  final String? line1;
  final String? line2;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.grey.shade700 : Colors.grey.shade300;
    final mutedColor = light ? Colors.grey.shade500 : Colors.grey.shade500;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          line1 ??
              'Offline-first  •  Rich text editing  •  Tags & folders',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Roboto',
            fontFamilyFallback: const [
              'NotoNaskhArabic',
              'NotoSansDevanagari',
              'NotoSansCJK',
            ],
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          line2 ??
              'Dark mode  •  Multiple languages  •  Custom themes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Roboto',
            fontFamilyFallback: const [
              'NotoNaskhArabic',
              'NotoSansDevanagari',
              'NotoSansCJK',
            ],
            color: mutedColor,
          ),
        ),
      ],
    );
  }
}
