// solitaire/presentation/widgets/step3_your_ring_card.dart
import 'package:flutter/material.dart';
import 'step3_section_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Step3YourRingCard extends StatelessWidget {
  final String stockCode;
  final String image; // ✅ single image only (no thumbs)

  const Step3YourRingCard({
    super.key,
    required this.stockCode,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Step3SectionCard(
      // icon: Icons.ring_volume,
      // title: 'Your Ring',
      leading: const FaIcon(
        FontAwesomeIcons.ring,
        color: Color(0xFF0B2E5E),
        size: 20,
      ),
      title: 'Your Ring',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bigImage(image),

          const SizedBox(height: 12),

          // ✅ Keep stock code box (website has it)
          Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              stockCode,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF4D6DFF),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        // ✅ slightly taller so card height matches better
        aspectRatio: 16 / 12,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFF2F2F2),
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported, color: Colors.black45),
          ),
        ),
      ),
    );
  }
}
