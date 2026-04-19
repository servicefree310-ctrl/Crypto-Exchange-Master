import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/domain/entities/author_entity.dart';
import '../../../../profile/data/services/profile_service.dart';
import '../bloc/authors_bloc.dart';
import '../../../../../injection/injection.dart';

class AuthorApplicationPage extends StatefulWidget {
  const AuthorApplicationPage({super.key});

  @override
  State<AuthorApplicationPage> createState() => _AuthorApplicationPageState();
}

class _AuthorApplicationPageState extends State<AuthorApplicationPage> {
  AuthorStatus? _currentAuthorStatus;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Check current author status from profile service (most up-to-date)
    final profileService = getIt<ProfileService>();
    final profile = profileService.currentProfile;

    if (profile?.author != null) {
      _currentAuthorStatus = profile!.author!.status;
    } else {
      // Fallback to auth state if profile not available yet
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _currentAuthorStatus = authState.user.author?.status;
      }
    }
  }

  Widget _buildCurrentStatusWidget(BuildContext context) {
    if (_currentAuthorStatus == null) {
      return _buildNotAppliedStatus(context);
    }

    switch (_currentAuthorStatus!) {
      case AuthorStatus.pending:
        return _buildPendingStatus(context);
      case AuthorStatus.approved:
        return _buildApprovedStatus(context);
      case AuthorStatus.rejected:
        return _buildRejectedStatus(context);
    }
  }

  Widget _buildNotAppliedStatus(BuildContext context) {
    return _buildApplySection(context);
  }

  Widget _buildPendingStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.orangeAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.orangeAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pending,
            size: 48,
            color: context.orangeAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Application Under Review',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your author application is currently being reviewed by our team.',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.orangeAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: context.orangeAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Review time: 24-48 hours',
                  style: context.bodyS.copyWith(
                    color: context.orangeAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.priceUpColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.priceUpColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified,
            size: 48,
            color: context.priceUpColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Congratulations! You\'re an Author',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You can now create and publish blog posts on ${AppConstants.appName}.',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to create post page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Create post feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.priceUpColor,
                foregroundColor: context.colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Create Your First Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.priceDownColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.priceDownColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cancel,
            size: 48,
            color: context.priceDownColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Application Not Approved',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unfortunately, your author application was not approved at this time. You can reapply after 30 days.',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              // Navigate to FAQ or support
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Contact support for more information')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: context.textPrimary,
              side: BorderSide(color: context.dividerColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthorsBloc>(),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: SafeArea(
          child: BlocConsumer<AuthorsBloc, AuthorsState>(
            listener: (context, state) {
              if (state is AuthorsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.failure.message),
                    backgroundColor: context.priceDownColor,
                  ),
                );
              }
              setState(() {
                _isApplying = false;
              });
            },
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: context.colors.surface,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.colors.primary,
                              context.colors.secondary,
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Pattern overlay
                            Positioned.fill(
                              child: CustomPaint(
                                painter: GridPatternPainter(
                                  color:
                                      context.colors.onPrimary.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            // Content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: context.colors.onPrimary
                                          .withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _currentAuthorStatus ==
                                              AuthorStatus.approved
                                          ? Icons.verified
                                          : Icons.edit_note,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _currentAuthorStatus ==
                                            AuthorStatus.approved
                                        ? 'Author Dashboard'
                                        : 'Become an Author',
                                    style: context.h6.copyWith(
                                      color: context.colors.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: context.colors.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Current Status Section
                          _buildCurrentStatusWidget(context),

                          const SizedBox(height: 32),

                          // Only show benefits and requirements if not approved
                          if (_currentAuthorStatus !=
                              AuthorStatus.approved) ...[
                            // Benefits Section
                            _buildSectionCard(
                              context,
                              title: 'Why Become an Author?',
                              icon: Icons.star,
                              iconColor: context.orangeAccent,
                              children: [
                                _buildBenefitItem(
                                  context,
                                  icon: Icons.visibility,
                                  title: 'Reach Thousands',
                                  description:
                                      'Share your crypto insights with our growing community',
                                ),
                                _buildBenefitItem(
                                  context,
                                  icon: Icons.trending_up,
                                  title: 'Build Your Brand',
                                  description:
                                      'Establish yourself as a thought leader in crypto',
                                ),
                                _buildBenefitItem(
                                  context,
                                  icon: Icons.people,
                                  title: 'Connect & Network',
                                  description:
                                      'Engage with readers and fellow crypto enthusiasts',
                                ),
                                _buildBenefitItem(
                                  context,
                                  icon: Icons.workspace_premium,
                                  title: 'Exclusive Features',
                                  description:
                                      'Access author-only tools and analytics',
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Requirements Section
                            _buildSectionCard(
                              context,
                              title: 'Author Requirements',
                              icon: Icons.checklist,
                              iconColor: context.colors.primary,
                              children: [
                                _buildRequirementItem(
                                  context,
                                  'Complete KYC verification',
                                  Icons.verified_user,
                                ),
                                _buildRequirementItem(
                                  context,
                                  'Active ${AppConstants.appName} account for 30+ days',
                                  Icons.calendar_today,
                                ),
                                _buildRequirementItem(
                                  context,
                                  'Commit to publishing quality content',
                                  Icons.high_quality,
                                ),
                                _buildRequirementItem(
                                  context,
                                  'Follow community guidelines',
                                  Icons.rule,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Guidelines Section
                            _buildSectionCard(
                              context,
                              title: 'Content Guidelines',
                              icon: Icons.description,
                              iconColor: context.colors.tertiary,
                              children: [
                                _buildGuidelineItem(
                                  context,
                                  'Original Content',
                                  'All articles must be original and not published elsewhere',
                                ),
                                _buildGuidelineItem(
                                  context,
                                  'Quality Standards',
                                  'Well-researched, informative, and professionally written',
                                ),
                                _buildGuidelineItem(
                                  context,
                                  'No Financial Advice',
                                  'Educational content only, no investment recommendations',
                                ),
                                _buildGuidelineItem(
                                  context,
                                  'Respectful Tone',
                                  'Professional and respectful to all community members',
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],

                          // FAQ Link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                // Navigate to FAQ
                              },
                              child: Text(
                                'Have questions? Read our Author FAQ',
                                style: context.bodyM.copyWith(
                                  color: context.colors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildApplySection(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.1),
                context.colors.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.rocket_launch,
                size: 48,
                color: context.colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to Share Your Knowledge?',
                style: context.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Start your journey as a ${AppConstants.appName} author today',
                style: context.bodyM.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isApplying
                      ? null
                      : () async {
                          if (authState is AuthAuthenticated) {
                            setState(() {
                              _isApplying = true;
                            });
                            context.read<AuthorsBloc>().add(
                                  ApplyForAuthorRequested(authState.user.id),
                                );
                            // Update the status to pending
                            setState(() {
                              _currentAuthorStatus = AuthorStatus.pending;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isApplying
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                context.colors.onPrimary),
                          ),
                        )
                      : const Text(
                          'Apply Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: context.colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.priceUpColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.bodyM.copyWith(
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for grid pattern
class GridPatternPainter extends CustomPainter {
  final Color color;

  GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
