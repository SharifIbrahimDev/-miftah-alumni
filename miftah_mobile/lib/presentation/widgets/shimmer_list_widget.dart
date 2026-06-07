import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class ShimmerListWidget extends StatelessWidget {
  final int itemCount;
  
  const ShimmerListWidget({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 150, color: Colors.white24, margin: const EdgeInsets.only(bottom: 8)),
                    Container(height: 10, width: 100, color: Colors.white24),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.2));
      },
    );
  }
}
