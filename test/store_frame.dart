import 'package:flutter/material.dart';

class StoreFrame extends StatelessWidget {
  const StoreFrame({
    required this.child,
    required this.tagline,
    required this.headline,
    super.key,
    this.features = const [],
  });

  final Widget child;
  final String tagline;
  final String headline;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = (size.width * 0.07).clamp(40.0, 64.0);
    final titleSize = (size.width * 0.07).clamp(24.0, 36.0);
    final taglineSize = (size.width * 0.035).clamp(12.0, 18.0);
    final headlineSize = (size.width * 0.05).clamp(16.0, 24.0);
    final featureSize = (size.width * 0.035).clamp(11.0, 17.0);
    const topPct = 0.14;
    const botPct = 0.14;
    const sidePct = 0.06;

    final topH = size.height * topPct;
    final botH = size.height * botPct;
    final sidePad = size.width * sidePct;

    final availW = size.width - sidePad * 2;
    final availH = size.height - topH - botH;
    final overlap = topH * 0.15;
    final extAvailH = availH + overlap;

    const appRatio = 9.0 / 16.0;
    var scrW = availW;
    var scrH = scrW / appRatio;
    if (scrH > extAvailH) {
      scrH = extAvailH;
      scrW = scrH * appRatio;
    }

    final scrTop = (topH - overlap) + (extAvailH - scrH) / 2;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Container(color: const Color(0xFF8BAA7E)),
          Positioned(
            top: 0, left: 0, right: 0, height: topH,
            child: Container(
              color: const Color(0xFF2D5A27),
              padding: EdgeInsets.only(top: topH * 0.18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/icon/icon.png', width: iconSize, height: iconSize, fit: BoxFit.contain),
                      const SizedBox(width: 12),
                      Text(
                        'Fox',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF8F5F1),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: topH * 0.04),
                  Text(
                    tagline,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: taglineSize,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFFD8D0C0),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0, height: botH,
          child: ColoredBox(
            color: const Color(0xFF2D5A27),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    headline,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: headlineSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF8F5F1),
                    ),
                  ),
                  SizedBox(height: botH * 0.08),
                  ...features.map((f) => Padding(
                        padding: EdgeInsets.only(bottom: botH * 0.04),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: Color(0xFFD8D0C0)),
                            SizedBox(width: 8),
                            Text(
                              f,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: featureSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFD8D0C0),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            top: scrTop,
            left: (size.width - scrW) / 2,
            width: scrW,
            height: scrH,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

