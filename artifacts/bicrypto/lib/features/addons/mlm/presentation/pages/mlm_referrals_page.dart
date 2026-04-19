import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/mlm_bloc.dart';
import '../widgets/mlm_referral_card.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/constants/api_constants.dart';

class MlmReferralsPage extends StatelessWidget {
  const MlmReferralsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<MlmReferralsBloc>()
        ..add(const MlmReferralsLoadRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: const Text('My Referrals'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showSearchDialog(context),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: BlocBuilder<MlmReferralsBloc, MlmReferralsState>(
          builder: (context, state) {
            if (state is MlmReferralsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MlmReferralsLoaded) {
              return _buildReferralsList(context, state);
            } else if (state is MlmReferralsError) {
              return _buildErrorView(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.borderColor,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showInviteDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.person_add_rounded,
                  size: 24,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralsList(BuildContext context, MlmReferralsLoaded state) {
    if (state.referrals.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<MlmReferralsBloc>()
            .add(const MlmReferralsRefreshRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.referrals.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= state.referrals.length) {
            // Load more indicator
            context.read<MlmReferralsBloc>().add(
                  MlmReferralsLoadMoreRequested(
                      nextPage: state.currentPage + 1),
                );
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final referral = state.referrals[index];
          return MlmReferralCard(
            referral: referral,
            onTap: () => _showReferralDetail(context, referral),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: context.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Referrals Yet',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start inviting friends to earn rewards!',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.priceUpColor,
                    context.priceUpColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: context.priceUpColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showInviteDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Invite Friends',
                          style: context.labelL.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, MlmReferralsError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Referrals',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage,
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<MlmReferralsBloc>().add(
                    MlmReferralsRetryRequested(page: state.page),
                  ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Referrals'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter name or email...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement search
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  String _getUserReferralLink(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl;
    // Try to get user ID from dashboard bloc if available
    try {
      final dashboardState = context.read<MlmDashboardBloc>().state;
      String userId = '';
      if (dashboardState is MlmDashboardLoaded) {
        userId = dashboardState.dashboard.userProfile.id;
      } else if (dashboardState is MlmDashboardRefreshing) {
        userId = dashboardState.currentDashboard.userProfile.id;
      }
      if (userId.isNotEmpty) {
        return '$baseUrl/register?ref=$userId';
      }
    } catch (_) {}
    return '$baseUrl/register';
  }

  void _showInviteDialog(BuildContext context) {
    final referralLink = _getUserReferralLink(context);
    final inviteMessage =
        'Join ${AppConstants.appName} and start trading cryptocurrencies! Use my referral link: $referralLink';

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: context.priceUpColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Invite Friends',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share your referral link and earn rewards',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Referral Link
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Referral Link',
                    style: context.labelS.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          referralLink,
                          style: context.bodyS.copyWith(
                            fontFamily: 'monospace',
                            color: context.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: context.priceUpColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: referralLink));
                              Navigator.pop(modalContext);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Referral link copied!',
                                      style: context.bodyM
                                          .copyWith(color: Colors.white),
                                    ),
                                    backgroundColor: context.priceUpColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.copy_rounded,
                                color: context.priceUpColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Share Options
            Text(
              'Share via',
              style: context.labelM.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildShareButton(
                    context: modalContext,
                    icon: Icons.message_rounded,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () => _shareViaWhatsApp(modalContext, inviteMessage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShareButton(
                    context: modalContext,
                    icon: Icons.email_rounded,
                    label: 'Email',
                    color: context.colors.primary,
                    onTap: () => _shareViaEmail(modalContext, inviteMessage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShareButton(
                    context: modalContext,
                    icon: Icons.share_rounded,
                    label: 'More',
                    color: context.colors.secondary,
                    onTap: () => _shareViaMore(modalContext, inviteMessage),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: context.labelS.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareViaWhatsApp(BuildContext context, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/?text=$encodedMessage';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl),
            mode: LaunchMode.externalApplication);
      } else {
        _showShareError(context, 'WhatsApp not installed');
      }
    } catch (e) {
      _showShareError(context, 'Failed to open WhatsApp');
    }

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _shareViaEmail(BuildContext context, String message) async {
    final subject = Uri.encodeComponent(
        'Join ${AppConstants.appName} - Cryptocurrency Trading Platform');
    final body = Uri.encodeComponent(message);
    final emailUrl = 'mailto:?subject=$subject&body=$body';

    try {
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        _showShareError(context, 'No email app found');
      }
    } catch (e) {
      _showShareError(context, 'Failed to open email app');
    }

    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _shareViaMore(BuildContext context, String message) async {
    // For more sharing options, we can use the share_plus package
    // For now, we'll copy to clipboard and show options
    await Clipboard.setData(ClipboardData(text: message));

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Message copied to clipboard',
            style: context.bodyM.copyWith(color: Colors.white),
          ),
          backgroundColor: context.colors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showShareError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: context.bodyM.copyWith(color: Colors.white),
          ),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showReferralDetail(BuildContext context, dynamic referral) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Referral Details',
                  style: context.h5.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                // Referral details would go here
                Text(
                  'Detailed referral information coming soon...',
                  style: context.bodyM.copyWith(
                    color: context.textSecondary,
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
