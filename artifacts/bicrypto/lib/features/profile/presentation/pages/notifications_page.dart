import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../bloc/notification_settings_cubit.dart';
import '../widgets/profile_switch_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationSettingsCubit>(
      create: (_) => getIt<NotificationSettingsCubit>()..initialize(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationSettingsCubit>();

    return BlocConsumer<NotificationSettingsCubit, NotificationSettingsState>(
      listener: (context, state) {
        if (state.status == NotificationSettingsStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification settings saved!')),
          );
          Navigator.pop(context);
        } else if (state.status == NotificationSettingsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Failed to save')),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state.status == NotificationSettingsStatus.saving;
        return Scaffold(
          backgroundColor: context.colors.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Notifications', style: context.h5),
            actions: [
              TextButton(
                onPressed: isSaving ? null : cubit.save,
                child: isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Save',
                        style: context.labelL.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        )),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: context.horizontalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationCard(context),
                const SizedBox(height: 24),
                _buildGeneralSection(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context) {
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
                colors: [context.colors.primary, context.colors.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child:
                const Icon(Icons.notifications, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          Text('Notification Settings', style: context.h5),
          const SizedBox(height: 8),
          Text('Manage how you receive notifications',
              textAlign: TextAlign.center,
              style: context.bodyS.copyWith(color: context.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(
      BuildContext context, NotificationSettingsState state) {
    final cubit = context.read<NotificationSettingsCubit>();
    return ProfileSwitchSection(
      title: 'Notifications',
      subtitle: 'Enable or disable notifications',
      children: [
        ProfileSwitchItem(
          icon: Icons.email_outlined,
          title: 'Email Notifications',
          subtitle: 'Receive notifications via email',
          value: state.email,
          isLoading: state.status == NotificationSettingsStatus.saving,
          onChanged: cubit.toggleEmail,
        ),
        ProfileSwitchItem(
          icon: Icons.sms_outlined,
          title: 'SMS Notifications',
          subtitle: 'Receive notifications via SMS',
          value: state.sms,
          isLoading: state.status == NotificationSettingsStatus.saving,
          onChanged: cubit.toggleSms,
        ),
        ProfileSwitchItem(
          icon: Icons.phone_android,
          title: 'Push Notifications',
          subtitle: 'Receive push notifications on your device',
          value: state.push,
          isLoading: state.status == NotificationSettingsStatus.saving,
          onChanged: cubit.togglePush,
        ),
      ],
    );
  }
}
