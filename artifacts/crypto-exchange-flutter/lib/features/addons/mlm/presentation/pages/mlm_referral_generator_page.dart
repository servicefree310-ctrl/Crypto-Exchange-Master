import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/constants/api_constants.dart';
import '../bloc/mlm_bloc.dart';

class MlmReferralGeneratorPage extends StatefulWidget {
  const MlmReferralGeneratorPage({super.key});

  @override
  State<MlmReferralGeneratorPage> createState() =>
      _MlmReferralGeneratorPageState();
}

class _MlmReferralGeneratorPageState extends State<MlmReferralGeneratorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _campaignNameController = TextEditingController();

  String _selectedSource = 'Social Media';
  double _qrSize = 200;

  static const List<String> _trafficSources = [
    'Social Media',
    'Email',
    'Blog',
    'Advertisement',
    'Direct',
    'Other',
  ];

  static final Map<double, String> _qrSizeLabels = {
    150: 'Small',
    200: 'Medium',
    300: 'Large',
  };

  String _baseReferralLink = '';
  String _generatedLink = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLinks();
    });
  }

  void _initLinks() {
    final baseUrl = ApiConstants.baseUrl;
    String userId = '';
    try {
      final dashboardState = context.read<MlmDashboardBloc>().state;
      if (dashboardState is MlmDashboardLoaded) {
        userId = dashboardState.dashboard.userProfile.id;
      } else if (dashboardState is MlmDashboardRefreshing) {
        userId = dashboardState.currentDashboard.userProfile.id;
      }
    } catch (_) {}

    final link = userId.isNotEmpty
        ? '$baseUrl/register?ref=$userId'
        : '$baseUrl/register';

    setState(() {
      _baseReferralLink = link;
      _generatedLink = link;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _campaignNameController.dispose();
    super.dispose();
  }

  void _generateLink() {
    String link = _baseReferralLink;
    final campaign = _campaignNameController.text.trim();
    if (campaign.isNotEmpty) {
      final encodedCampaign = Uri.encodeComponent(campaign);
      final encodedSource = Uri.encodeComponent(_selectedSource);
      link = '$link&campaign=$encodedCampaign&source=$encodedSource';
    }
    setState(() {
      _generatedLink = link;
    });
  }

  void _resetCampaign() {
    _campaignNameController.clear();
    setState(() {
      _selectedSource = 'Social Media';
      _generatedLink = _baseReferralLink;
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$label copied!',
            style: context.bodyM.copyWith(color: Colors.white),
          ),
          backgroundColor: context.priceUpColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _shareViaWhatsApp() async {
    final message = _buildShareMessage();
    final encoded = Uri.encodeComponent(message);
    final url = 'https://wa.me/?text=$encoded';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('WhatsApp not installed');
      }
    } catch (_) {
      _showError('Failed to open WhatsApp');
    }
  }

  Future<void> _shareViaEmail() async {
    final message = _buildShareMessage();
    final subject = Uri.encodeComponent('Join ${AppConstants.appName}!');
    final body = Uri.encodeComponent(message);
    final url = 'mailto:?subject=$subject&body=$body';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError('No email app found');
      }
    } catch (_) {
      _showError('Failed to open email app');
    }
  }

  Future<void> _shareGeneric() async {
    await Share.share(_buildShareMessage());
  }

  String _buildShareMessage() {
    return 'Join me on ${AppConstants.appName}! Start trading crypto today. Use my link: $_generatedLink';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: context.bodyM.copyWith(color: Colors.white),
          ),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Referral Generator'),
            Text(
              'Create custom referral links to track your campaigns',
              style: context.bodyS.copyWith(fontSize: 11),
            ),
          ],
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Link'),
            Tab(text: 'QR Code'),
            Tab(text: 'Share'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLinkTab(),
          _buildQrTab(),
          _buildShareTab(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // TAB 1: Link
  // ──────────────────────────────────────────

  Widget _buildLinkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.link_rounded,
            title: 'Base Referral Link',
          ),
          const SizedBox(height: 12),
          _buildLinkDisplay(
            link: _baseReferralLink.isEmpty ? 'Loading...' : _baseReferralLink,
            onCopy: () => _copyToClipboard(_baseReferralLink, 'Referral link'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.tune_rounded,
            title: 'Campaign Customization',
            subtitle: 'Optional — adds tracking parameters to your link',
          ),
          const SizedBox(height: 12),
          _buildCampaignForm(),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.auto_awesome_rounded,
            title: 'Generated Link',
          ),
          const SizedBox(height: 12),
          _buildLinkDisplay(
            link: _generatedLink.isEmpty ? 'Loading...' : _generatedLink,
            onCopy: () => _copyToClipboard(_generatedLink, 'Generated link'),
          ),
          const SizedBox(height: 16),
          _buildLinkActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: context.priceUpColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.priceUpColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.labelL.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.bodyS.copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkDisplay({
    required String link,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              link,
              style: context.bodyS.copyWith(
                fontFamily: 'monospace',
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.copy_rounded,
            color: context.priceUpColor,
            onTap: onCopy,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Name',
            style: context.labelS.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _campaignNameController,
            style: context.bodyM.copyWith(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Summer Promo 2024',
              hintStyle: context.bodyM.copyWith(
                color: context.textSecondary.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: context.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Traffic Source',
            style: context.labelS.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSource,
                isExpanded: true,
                dropdownColor: context.cardBackground,
                style: context.bodyM.copyWith(color: context.textPrimary),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.textSecondary,
                ),
                items: _trafficSources
                    .map(
                      (source) => DropdownMenuItem(
                        value: source,
                        child: Text(source),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSource = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Generate',
            icon: Icons.auto_awesome_rounded,
            color: context.priceUpColor,
            onTap: _generateLink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Reset',
            icon: Icons.refresh_rounded,
            color: context.warningColor,
            onTap: _resetCampaign,
            outlined: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(12),
        border: outlined ? Border.all(color: color, width: 1.5) : null,
        boxShadow: outlined
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: outlined ? color : Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: context.labelL.copyWith(
                    color: outlined ? color : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // TAB 2: QR Code
  // ──────────────────────────────────────────

  Widget _buildQrTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSectionHeader(
            icon: Icons.qr_code_rounded,
            title: 'QR Code',
            subtitle: 'Scan to open your referral link',
          ),
          const SizedBox(height: 24),
          if (_generatedLink.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: _generatedLink,
                version: QrVersions.auto,
                size: _qrSize,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            )
          else
            Container(
              width: _qrSize,
              height: _qrSize,
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.borderColor.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_rounded,
                      size: 48,
                      color: context.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading...',
                      style: context.bodyS,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.photo_size_select_large_rounded,
            title: 'QR Code Size',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Row(
              children: _qrSizeLabels.entries.map((entry) {
                final isSelected = _qrSize == entry.key;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _qrSize = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.priceUpColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.value,
                        style: context.labelS.copyWith(
                          color:
                              isSelected ? Colors.white : context.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.link_rounded,
            title: 'Current Link',
          ),
          const SizedBox(height: 12),
          _buildLinkDisplay(
            link: _generatedLink.isEmpty ? 'Loading...' : _generatedLink,
            onCopy: () => _copyToClipboard(_generatedLink, 'Generated link'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // TAB 3: Share
  // ──────────────────────────────────────────

  Widget _buildShareTab() {
    final shareMessage = _buildShareMessage();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.share_rounded,
            title: 'Share Your Link',
            subtitle: 'Choose a channel to share your referral link',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildShareButton(
                  icon: Icons.message_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: _shareViaWhatsApp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  color: context.colors.primary,
                  onTap: _shareViaEmail,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy Link',
                  color: context.warningColor,
                  onTap: () =>
                      _copyToClipboard(_generatedLink, 'Referral link'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.share_rounded,
                  label: 'More',
                  color: context.colors.secondary,
                  onTap: _shareGeneric,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Message Template',
            subtitle: 'Pre-written message you can customize',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        shareMessage,
                        style: context.bodyM.copyWith(
                          color: context.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      icon: Icons.copy_rounded,
                      color: context.priceUpColor,
                      onTap: () =>
                          _copyToClipboard(shareMessage, 'Message template'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.link_rounded,
            title: 'Active Referral Link',
          ),
          const SizedBox(height: 12),
          _buildLinkDisplay(
            link: _generatedLink.isEmpty ? 'Loading...' : _generatedLink,
            onCopy: () => _copyToClipboard(_generatedLink, 'Referral link'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              label: 'Share Now',
              icon: Icons.share_rounded,
              color: context.priceUpColor,
              onTap: _shareGeneric,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShareButton({
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: context.labelS.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
