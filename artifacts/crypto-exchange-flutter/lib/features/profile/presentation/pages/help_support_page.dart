import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/constants/api_constants.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: context.h5,
        ),
      ),
      body: SingleChildScrollView(
        padding: context.horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpCard(context),
            const SizedBox(height: 24),
            _buildQuickHelpSection(context),
            const SizedBox(height: 24),
            _buildContactSection(context),
            const SizedBox(height: 24),
            _buildResourcesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.cardPadding,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary,
                  context.colors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How can we help?',
            style: context.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get support and find answers to your questions',
            textAlign: TextAlign.center,
            style: context.bodyM,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Quick Help',
      subtitle: 'Find answers to common questions',
      children: [
        _buildHelpItem(
          context: context,
          icon: Icons.quiz_outlined,
          title: 'FAQ',
          subtitle: 'Frequently asked questions',
          onTap: () => dev.log('FAQ tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.book_outlined,
          title: 'User Guide',
          subtitle: 'Learn how to use ${AppConstants.appName}',
          onTap: () => dev.log('User Guide tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.video_library_outlined,
          title: 'Video Tutorials',
          subtitle: 'Watch step-by-step tutorials',
          onTap: () => dev.log('Video Tutorials tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.security_outlined,
          title: 'Security Tips',
          subtitle: 'Keep your account secure',
          onTap: () => dev.log('Security Tips tapped'),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Contact Support',
      subtitle: 'Get in touch with our support team',
      children: [
        _buildHelpItem(
          context: context,
          icon: Icons.chat_outlined,
          title: 'Live Chat',
          subtitle: 'Chat with our support team',
          onTap: () => dev.log('Live Chat tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.email_outlined,
          title: 'Email Support',
          subtitle: 'Send us an email',
          onTap: () => _launchEmail(),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.bug_report_outlined,
          title: 'Report a Bug',
          subtitle: 'Help us improve the app',
          onTap: () => dev.log('Report Bug tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          subtitle: 'Share your thoughts with us',
          onTap: () => dev.log('Send Feedback tapped'),
        ),
      ],
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Resources',
      subtitle: 'Additional information and resources',
      children: [
        _buildHelpItem(
          context: context,
          icon: Icons.article_outlined,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: () => dev.log('Terms of Service tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Learn about our privacy practices',
          onTap: () => dev.log('Privacy Policy tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.language_outlined,
          title: 'API Documentation',
          subtitle: 'For developers and advanced users',
          onTap: () => dev.log('API Documentation tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildHelpItem(
          context: context,
          icon: Icons.forum_outlined,
          title: 'Community Forum',
          subtitle: 'Join our community discussions',
          onTap: () => dev.log('Community Forum tapped'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.h5,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: context.bodyM,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: context.cardPadding,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.labelL,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.bodyM,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward_ios,
                color: context.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@cryptox.in',
      query: 'subject=${AppConstants.appName} Mobile App Support',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      dev.log('Could not launch email client');
    }
  }
}
