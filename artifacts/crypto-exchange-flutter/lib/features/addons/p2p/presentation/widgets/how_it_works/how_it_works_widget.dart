import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';

/// How It Works Widget - Based on v5 frontend design
/// Interactive timeline showing the 4-step P2P trading process
class HowItWorksWidget extends StatelessWidget {
  const HowItWorksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildHeader(context),

          // Interactive Timeline
          _buildTimeline(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Simple Process',
              style: context.bodyS.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            'How It Works',
            style: context.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            'Our streamlined process makes trading fast and secure',
            style: context.bodyS.copyWith(
              color: context.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Column(
      children: [
        _buildStep(
          context,
          stepNumber: 1,
          title: 'Browse Offers',
          description: 'Find the best offers with our advanced filtering',
          icon: Icons.search,
          color: context.colors.primary,
          features: [
            'Filter by payment method & location',
            'Compare trader ratings & reviews',
            'Real-time price updates',
          ],
        ),
        const SizedBox(height: 12),
        _buildStep(
          context,
          stepNumber: 2,
          title: 'Select & Connect',
          description: 'Choose an offer from verified traders',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF10B981), // Green
          features: [
            'View trader reputation & history',
            'Instant chat communication',
            'Transparent pricing & terms',
          ],
        ),
        const SizedBox(height: 12),
        _buildStep(
          context,
          stepNumber: 3,
          title: 'Secure Trade',
          description: 'Our escrow system protects all transactions',
          icon: Icons.security,
          color: const Color(0xFF3B82F6), // Blue
          features: [
            'Real-time chat with trading partner',
            'Automatic escrow protection',
            '24/7 dispute resolution support',
          ],
        ),
        const SizedBox(height: 12),
        _buildStep(
          context,
          stepNumber: 4,
          title: 'Rate & Grow',
          description: 'Share your experience and build reputation',
          icon: Icons.star_outline,
          color: const Color(0xFFF59E0B), // Yellow
          features: [
            'Build your reputation score',
            'Unlock premium benefits',
            'Help the community grow',
          ],
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> features,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          // Main Step Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Icon & Number
                Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$stepNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Connector Line (except for last step)
                    if (!isLast) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: 2,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.3),
                              context.borderColor,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(width: 16),

                // Step Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Accent Line
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.bodyL.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 30,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.5)],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Description
                      Text(
                        description,
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Features List
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map((feature) => _buildFeature(context, feature, color))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(BuildContext context, String feature, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              feature,
              style: context.bodyS.copyWith(
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
