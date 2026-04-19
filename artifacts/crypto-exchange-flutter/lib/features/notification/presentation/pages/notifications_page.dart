import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../core/widgets/error_widget.dart' as core;
import '../../../../core/widgets/loading_widget.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late NotificationBloc _notificationBloc;

  final TextEditingController _searchController = TextEditingController();
  final Set<NotificationType> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notificationBloc = getIt<NotificationBloc>();

    // Load notifications on page load
    _notificationBloc.add(const NotificationLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        backgroundColor: context.cardBackground,
        appBar: _buildAppBar(),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const LoadingWidget(message: 'Loading notifications...');
            }

            if (state is NotificationError &&
                (state.cachedNotifications?.isEmpty ?? true)) {
              return core.ErrorWidget(
                message: state.message,
                onRetry: () => _notificationBloc.add(
                  const NotificationLoadRequested(),
                ),
              );
            }

            return _buildNotificationContent(state);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.cardBackground,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: context.textPrimary,
          size: 20,
        ),
      ),
      title: Text(
        'Notifications',
        style: context.h5.copyWith(
          color: context.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _buildMarkAllReadButton(),
        _buildDeleteAllButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationContent(NotificationState state) {
    final allNotifications = _getNotificationsFromState(state);
    final notifications = _getFilteredNotifications(allNotifications);

    return Column(
      children: [
        // Header with stats
        _buildNotificationHeader(notifications),

        // Search and filters
        _buildSearchAndFilters(),

        // Tabs
        _buildTabBar(notifications),

        // Notifications List
        Expanded(
          child: _buildNotificationsList(notifications, state),
        ),
      ],
    );
  }

  Widget _buildNotificationHeader(List<NotificationEntity> notifications) {
    final totalCount = notifications.length;
    final unreadCount = notifications.where((n) => !n.read).length;
    final readCount = notifications.where((n) => n.read).length;

    return Container(
      margin: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Total notifications
          Expanded(
            child: _buildStatCard(
              icon: Icons.notifications_outlined,
              title: 'Total',
              count: totalCount,
              color: context.colors.primary,
            ),
          ),
          SizedBox(width: context.isSmallScreen ? 12.0 : 16.0),
          // Unread notifications
          Expanded(
            child: _buildStatCard(
              icon: Icons.mark_email_unread_outlined,
              title: 'Unread',
              count: unreadCount,
              color: context.warningColor,
            ),
          ),
          SizedBox(width: context.isSmallScreen ? 12.0 : 16.0),
          // Read notifications
          Expanded(
            child: _buildStatCard(
              icon: Icons.mark_email_read_outlined,
              title: 'Read',
              count: readCount,
              color: context.priceUpColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(context.isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: context.isSmallScreen ? 20.0 : 24.0,
          ),
          SizedBox(height: context.isSmallScreen ? 4.0 : 6.0),
          Text(
            count.toString(),
            style: context.h5.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.0),
          Text(
            title,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: context.isSmallScreen ? 16.0 : 20.0),
      child: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          SizedBox(height: context.isSmallScreen ? 12.0 : 16.0),
          // Filter Chips
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: context.bodyM.copyWith(color: context.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: context.bodyM.copyWith(color: context.textTertiary),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: context.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.clear_rounded,
                    color: context.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: context.isSmallScreen ? 12.0 : 16.0,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Clear All chip
          if (_selectedFilters.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  'Clear All',
                  style: context.bodyS.copyWith(
                    color: context.priceDownColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onSelected: (_) => setState(() {
                  _selectedFilters.clear();
                }),
                backgroundColor: context.priceDownColor.withValues(alpha: 0.1),
                selectedColor: context.priceDownColor.withValues(alpha: 0.2),
                side: BorderSide(
                  color: context.priceDownColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),

          // Type filter chips
          ...NotificationType.values.map((type) {
            final isSelected = _selectedFilters.contains(type);
            final color = _getTypeColor(type);

            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  _getTypeName(type),
                  style: context.bodyS.copyWith(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFilters.add(type);
                    } else {
                      _selectedFilters.remove(type);
                    }
                  });
                },
                backgroundColor: color.withValues(alpha: 0.1),
                selectedColor: color,
                side: BorderSide(
                  color: isSelected ? color : color.withValues(alpha: 0.3),
                  width: 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabBar(List<NotificationEntity> notifications) {
    final allCount = notifications.length;
    final unreadCount = notifications.where((n) => !n.read).length;
    final readCount = notifications.where((n) => n.read).length;

    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: context.isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: context.inputBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: context.colors.primary,
        unselectedLabelColor: context.textSecondary,
        indicatorColor: context.colors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: context.bodyS.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: context.bodyS.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: 'All ($allCount)'),
          Tab(text: 'Unread ($unreadCount)'),
          Tab(text: 'Read ($readCount)'),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    List<NotificationEntity> notifications,
    NotificationState state,
  ) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotificationsListView(notifications, state), // All
        _buildNotificationsListView(
          notifications.where((n) => !n.read).toList(),
          state,
        ), // Unread
        _buildNotificationsListView(
          notifications.where((n) => n.read).toList(),
          state,
        ), // Read
      ],
    );
  }

  Widget _buildNotificationsListView(
    List<NotificationEntity> notifications,
    NotificationState state,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _notificationBloc.add(const NotificationLoadRequested());
      },
      child: ListView.builder(
        padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, state);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.inputBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: context.textTertiary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: context.h5.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: context.bodyM.copyWith(
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationEntity notification,
    NotificationState state,
  ) {
    final isUnread = !notification.read;
    final typeColor = _getTypeColor(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isUnread
              ? typeColor.withValues(alpha: 0.3)
              : context.borderColor.withValues(alpha: 0.3),
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: EdgeInsets.all(context.isSmallScreen ? 16.0 : 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: context.isSmallScreen ? 40.0 : 48.0,
                  height: context.isSmallScreen ? 40.0 : 48.0,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: typeColor,
                    size: context.isSmallScreen ? 20.0 : 24.0,
                  ),
                ),
                SizedBox(width: context.isSmallScreen ? 12.0 : 16.0),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: context.bodyL.copyWith(
                                color: context.textPrimary,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: context.bodyM.copyWith(
                          color: context.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: context.textTertiary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(notification.createdAt),
                            style: context.bodyS.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                          Spacer(),
                          _buildNotificationActions(notification),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationActions(NotificationEntity notification) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: context.textSecondary,
        size: 20,
      ),
      onSelected: (value) {
        switch (value) {
          case 'read':
            _notificationBloc.add(
              NotificationMarkReadRequested(notification.id),
            );
            break;
          case 'unread':
            _notificationBloc.add(
              NotificationMarkUnreadRequested(notification.id),
            );
            break;
          case 'delete':
            _showDeleteDialog(notification);
            break;
        }
      },
      itemBuilder: (context) => [
        if (!notification.read)
          PopupMenuItem<String>(
            value: 'read',
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_read_rounded,
                  color: context.priceUpColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Mark as read',
                  style: context.bodyM.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        if (notification.read)
          PopupMenuItem<String>(
            value: 'unread',
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_unread_rounded,
                  color: context.warningColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Mark as unread',
                  style: context.bodyM.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: context.priceDownColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Delete',
                style: context.bodyM.copyWith(
                  color: context.priceDownColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkAllReadButton() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final allNotifications = _getNotificationsFromState(state);
        final hasUnread = allNotifications.any((n) => !n.read);

        return Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: hasUnread
                ? context.priceUpColor.withValues(alpha: 0.1)
                : context.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasUnread
                  ? context.priceUpColor.withValues(alpha: 0.3)
                  : context.borderColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: IconButton(
            onPressed: hasUnread
                ? () => _notificationBloc.add(
                      const NotificationMarkAllReadRequested(),
                    )
                : null,
            icon: Icon(
              Icons.done_all_rounded,
              color: hasUnread ? context.priceUpColor : context.textTertiary,
              size: 20,
            ),
            tooltip: 'Mark all as read',
          ),
        );
      },
    );
  }

  Widget _buildDeleteAllButton() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final allNotifications = _getNotificationsFromState(state);
        final hasNotifications = allNotifications.isNotEmpty;

        return Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: hasNotifications
                ? context.priceDownColor.withValues(alpha: 0.1)
                : context.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasNotifications
                  ? context.priceDownColor.withValues(alpha: 0.3)
                  : context.borderColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: IconButton(
            onPressed: hasNotifications ? () => _showDeleteAllDialog() : null,
            icon: Icon(
              Icons.delete_sweep_rounded,
              color: hasNotifications
                  ? context.priceDownColor
                  : context.textTertiary,
              size: 20,
            ),
            tooltip: 'Delete all notifications',
          ),
        );
      },
    );
  }

  List<NotificationEntity> _getNotificationsFromState(NotificationState state) {
    if (state is NotificationLoaded) {
      return state.notifications;
    } else if (state is NotificationError) {
      return state.cachedNotifications ?? [];
    } else if (state is NotificationActionSuccess) {
      return state.notifications;
    } else if (state is NotificationActionInProgress) {
      return state.notifications;
    }
    return [];
  }

  List<NotificationEntity> _getFilteredNotifications(
      List<NotificationEntity> notifications) {
    var filtered = notifications;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((n) =>
              n.title.toLowerCase().contains(query) ||
              n.message.toLowerCase().contains(query) ||
              (n.details?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Apply type filters
    if (_selectedFilters.isNotEmpty) {
      filtered =
          filtered.where((n) => _selectedFilters.contains(n.type)).toList();
    }

    return filtered;
  }

  void _handleNotificationTap(NotificationEntity notification) {
    // Mark as read if unread
    if (!notification.read) {
      _notificationBloc.add(
        NotificationMarkReadRequested(notification.id),
      );
    }

    // Navigate to link if available
    if (notification.link != null) {
      _showLinkDialog(notification.link!);
    }
  }

  void _showLinkDialog(String link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'External Link',
          style: context.h5.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Open: $link',
          style: context.bodyM.copyWith(
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(link);
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Could not open link'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Open',
              style: context.bodyM.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(NotificationEntity notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Delete Notification',
          style: context.h5.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this notification?',
          style: context.bodyM.copyWith(
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationBloc.add(
                NotificationDeleteRequested(notification.id),
              );
            },
            child: Text(
              'Delete',
              style: context.bodyM.copyWith(
                color: context.priceDownColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Delete All Notifications',
          style: context.h5.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
          style: context.bodyM.copyWith(
            color: context.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationBloc.add(
                const NotificationDeleteAllRequested(),
              );
            },
            child: Text(
              'Delete All',
              style: context.bodyM.copyWith(
                color: context.priceDownColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.investment:
        return Icons.trending_up_rounded;
      case NotificationType.message:
        return Icons.message_rounded;
      case NotificationType.user:
        return Icons.person_rounded;
      case NotificationType.alert:
        return Icons.warning_rounded;
      case NotificationType.system:
        return Icons.settings_rounded;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.investment:
        return context.priceUpColor;
      case NotificationType.message:
        return context.colors.primary;
      case NotificationType.user:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationType.alert:
        return context.warningColor;
      case NotificationType.system:
        return context.textSecondary;
    }
  }

  String _getTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.investment:
        return 'Investment';
      case NotificationType.message:
        return 'Message';
      case NotificationType.user:
        return 'User';
      case NotificationType.alert:
        return 'Alert';
      case NotificationType.system:
        return 'System';
    }
  }
}
