import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/constants/api_constants.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  void _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      dev.log('Error loading app info: $e');
      setState(() {
        _version = '5.0.0';
        _buildNumber = '1';
      });
    }
  }

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
          'About',
          style: context.h5,
        ),
      ),
      body: SingleChildScrollView(
        padding: context.horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppCard(context),
            const SizedBox(height: 24),
            _buildInfoSection(context),
            const SizedBox(height: 24),
            _buildLegalSection(context),
            const SizedBox(height: 24),
            _buildSocialSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.largePadding,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.primary,
                  context.colors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'BC',
                style: context.h1.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppConstants.appName,
            style: context.h2.copyWith(color: context.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Version $_version ($_buildNumber)',
            style: context.bodyL.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'Your trusted cryptocurrency trading platform',
            textAlign: TextAlign.center,
            style: context.bodyM.copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'App Information',
      children: [
        _buildInfoItem(
          context: context,
          icon: Icons.info_outline,
          title: 'What\'s New',
          subtitle: 'See the latest updates and features',
          onTap: () => dev.log('What\'s New tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildInfoItem(
          context: context,
          icon: Icons.star_outline,
          title: 'Rate Us',
          subtitle: 'Rate ${AppConstants.appName} on the App Store',
          onTap: () => dev.log('Rate Us tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildInfoItem(
          context: context,
          icon: Icons.share_outlined,
          title: 'Share App',
          subtitle: 'Share ${AppConstants.appName} with friends',
          onTap: () => dev.log('Share App tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildInfoItem(
          context: context,
          icon: Icons.system_update_outlined,
          title: 'Check for Updates',
          subtitle: 'Make sure you have the latest version',
          onTap: () => _checkForUpdates(context),
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Legal',
      children: [
        _buildInfoItem(
          context: context,
          icon: Icons.article_outlined,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: () => dev.log('Terms of Service tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildInfoItem(
          context: context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Learn about our privacy practices',
          onTap: () => dev.log('Privacy Policy tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildInfoItem(
          context: context,
          icon: Icons.gavel_outlined,
          title: 'Licenses',
          subtitle: 'Open source licenses',
          onTap: () => _showLicenses(),
        ),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return _buildSection(
      context: context,
      title: 'Connect With Us',
      children: [
        _buildInfoItem(
          context: context,
          icon: Icons.language_outlined,
          title: 'Website',
          subtitle: 'Visit our official website',
          onTap: () => dev.log('Website tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildInfoItem(
          context: context,
          icon: Icons.forum_outlined,
          title: 'Community',
          subtitle: 'Join our community discussions',
          onTap: () => dev.log('Community tapped'),
        ),
        Divider(color: context.dividerColor, height: 1),
        _buildInfoItem(
          context: context,
          icon: Icons.alternate_email_outlined,
          title: 'Follow Us',
          subtitle: 'Stay updated on social media',
          onTap: () => dev.log('Follow Us tapped'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.h5,
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

  Widget _buildInfoItem({
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

  void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: context.priceUpColor),
            const SizedBox(width: 12),
            Text('You have the latest version!'),
          ],
        ),
        backgroundColor: context.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: _version,
      applicationLegalese:
          '© 2024 ${AppConstants.appName}. All rights reserved.',
    );
  }
}
