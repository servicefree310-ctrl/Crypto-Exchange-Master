import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../notification/domain/entities/announcement_entity.dart';

class AnnouncementsSlider extends StatefulWidget {
  const AnnouncementsSlider({
    super.key,
    required this.announcements,
  });

  final List<AnnouncementEntity> announcements;

  @override
  State<AnnouncementsSlider> createState() => _AnnouncementsSliderState();
}

class _AnnouncementsSliderState extends State<AnnouncementsSlider>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _autoScrollTimer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation and auto-scroll if announcements are available
    if (widget.announcements.isNotEmpty) {
      _animationController.forward();
      _startAutoScroll();
    }
  }

  @override
  void didUpdateWidget(AnnouncementsSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle announcements updates
    if (widget.announcements.isNotEmpty) {
      _animationController.forward();
      _startAutoScroll();
    } else {
      _stopAutoScroll();
      _animationController.reverse();
    }
  }

  void _startAutoScroll() {
    _stopAutoScroll();
    if (widget.announcements.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted && _pageController.hasClients) {
          final nextIndex = (currentIndex + 1) % widget.announcements.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeAnnouncements =
        widget.announcements.where((a) => a.status).toList();

    if (activeAnnouncements.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius:
              BorderRadius.circular(context.isSmallScreen ? 14.0 : 16.0),
          border: Border.all(
            color: context.borderColor,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and live indicator
            _buildHeader(context, activeAnnouncements.length),
            SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),

            // Announcements content
            SizedBox(
              height: context.isSmallScreen ? 80.0 : 100.0,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemCount: activeAnnouncements.length,
                    itemBuilder: (context, index) {
                      return _buildAnnouncementCard(activeAnnouncements[index]);
                    },
                  ),
                  if (activeAnnouncements.length > 1) _buildPageIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int announcementCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            Icons.campaign_outlined,
            color: context.colors.primary,
            size: 20.0,
          ),
        ),
        SizedBox(width: context.isSmallScreen ? 12.0 : 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Announcements',
                style: context.h6.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.0),
              Text(
                '$announcementCount active • Live updates',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.isSmallScreen ? 8.0 : 12.0,
            vertical: 6.0,
          ),
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            'LIVE',
            style: context.bodyS.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10.0,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(AnnouncementEntity announcement) {
    return GestureDetector(
      onTap: () => _handleAnnouncementTap(announcement),
      child: Container(
        padding: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              announcement.title,
              style: context.h6.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.isSmallScreen ? 4.0 : 6.0),
            Expanded(
              child: Text(
                announcement.message,
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: context.isSmallScreen ? 6.0 : 8.0),
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 12.0,
                  color: context.textTertiary,
                ),
                SizedBox(width: 4.0),
                Text(
                  'Tap to read more',
                  style: context.bodyS.copyWith(
                    color: context.textTertiary,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final activeAnnouncements =
        widget.announcements.where((a) => a.status).toList();

    return Positioned(
      bottom: 8.0,
      right: 12.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: context.cardBackground.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            activeAnnouncements.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: currentIndex == index ? 16.0 : 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? context.colors.primary
                    : context.borderColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAnnouncementTap(AnnouncementEntity announcement) async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AnnouncementDetailsSheet(announcement: announcement),
    );
  }
}

/// A modal sheet that shows the full announcement details and an optional
/// button to open the related link in an in-app web view (custom tab/SafariVC).
class _AnnouncementDetailsSheet extends StatelessWidget {
  const _AnnouncementDetailsSheet({required this.announcement});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets +
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            announcement.title,
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            announcement.message,
            style: context.bodyM.copyWith(
              color: context.textSecondary,
            ),
          ),
          if (announcement.link != null && announcement.link!.isNotEmpty) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(announcement.link!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.inAppWebView);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not open link'),
                        backgroundColor: context.warningColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Link'),
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
