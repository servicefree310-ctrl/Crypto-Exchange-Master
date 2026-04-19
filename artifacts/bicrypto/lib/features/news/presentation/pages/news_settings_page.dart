import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';

class NewsSettingsPage extends StatefulWidget {
  const NewsSettingsPage({super.key});

  @override
  State<NewsSettingsPage> createState() => _NewsSettingsPageState();
}

class _NewsSettingsPageState extends State<NewsSettingsPage> {
  bool _autoRefresh = true;
  bool _enableNotifications = false;

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
          'News Settings',
          style: context.h5,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: context.horizontalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'News Preferences',
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Auto Refresh',
                        style: context.labelM.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically refresh news content',
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      value: _autoRefresh,
                      onChanged: (value) =>
                          setState(() => _autoRefresh = value),
                      activeThumbColor: context.colors.primary,
                    ),
                    Divider(color: context.dividerColor, height: 1),
                    SwitchListTile(
                      title: Text(
                        'Enable Notifications',
                        style: context.labelM.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Get notified about breaking news',
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      value: _enableNotifications,
                      onChanged: (value) =>
                          setState(() => _enableNotifications = value),
                      activeThumbColor: context.colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
