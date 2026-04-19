# Profile Switch Widgets

This directory contains reusable switch widgets for the BiCrypto profile pages, providing consistent switch handling across the app.

## Components

### ProfileSwitchItem

A reusable switch item widget that provides consistent switch handling with loading states, error handling, and theme integration.

#### Features

- ✅ **Theme Integration**: Automatically adapts to light/dark themes
- ✅ **Loading States**: Shows loading indicators during API calls
- ✅ **Error Handling**: Displays error messages with visual feedback
- ✅ **Accessibility**: Proper touch targets and semantic labels
- ✅ **Consistent Design**: Follows BiCrypto design system
- ✅ **Interactive**: Tap anywhere on the item to toggle

#### Usage

```dart
import '../widgets/profile_switch_item.dart';

ProfileSwitchItem(
  icon: Icons.notifications,
  title: 'Push Notifications',
  subtitle: 'Receive push notifications on your device',
  value: _pushNotifications,
  isLoading: _isLoading,
  errorMessage: _errorMessage,
  onChanged: (value) => _updatePushNotifications(value),
)
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `icon` | `IconData` | ✅ | Icon to display in the switch item |
| `title` | `String` | ✅ | Main title text |
| `subtitle` | `String` | ✅ | Descriptive subtitle text |
| `value` | `bool` | ✅ | Current switch state |
| `onChanged` | `ValueChanged<bool>` | ✅ | Callback when switch is toggled |
| `isLoading` | `bool` | ❌ | Shows loading indicator (default: false) |
| `errorMessage` | `String?` | ❌ | Error message to display (default: null) |

#### States

1. **Normal State**: Standard switch with enabled/disabled states
2. **Loading State**: Shows spinner and disables interaction
3. **Error State**: Shows error message with red border and icon
4. **Disabled State**: Grayed out when loading or error

### ProfileSwitchSection

A wrapper component for grouping related switch items with consistent styling.

#### Usage

```dart
ProfileSwitchSection(
  title: 'General Notifications',
  subtitle: 'Choose how you want to receive notifications',
  children: [
    ProfileSwitchItem(...),
    ProfileSwitchItem(...),
    ProfileSwitchItem(...),
  ],
)
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `title` | `String` | ✅ | Section title |
| `subtitle` | `String` | ✅ | Section description |
| `children` | `List<Widget>` | ✅ | List of switch items |

## Implementation Examples

### Basic Switch

```dart
ProfileSwitchItem(
  icon: Icons.notifications,
  title: 'Push Notifications',
  subtitle: 'Receive push notifications on your device',
  value: _pushNotifications,
  onChanged: (value) => setState(() => _pushNotifications = value),
)
```

### Switch with Loading State

```dart
ProfileSwitchItem(
  icon: Icons.security,
  title: 'Two-Factor Authentication',
  subtitle: 'Add an extra layer of security to your account',
  value: _twoFactorEnabled,
  isLoading: _isLoading,
  onChanged: (value) => _updateTwoFactor(value),
)
```

### Switch with Error Handling

```dart
ProfileSwitchItem(
  icon: Icons.cloud_sync,
  title: 'Auto Sync',
  subtitle: 'Automatically sync your data',
  value: _autoSync,
  errorMessage: _syncError,
  onChanged: (value) => _updateAutoSync(value),
)
```

### Complete Section Example

```dart
ProfileSwitchSection(
  title: 'Notification Settings',
  subtitle: 'Customize how you receive notifications',
  children: [
    ProfileSwitchItem(
      icon: Icons.email_outlined,
      title: 'Email Notifications',
      subtitle: 'Receive notifications via email',
      value: _emailNotifications,
      isLoading: _isEmailLoading,
      onChanged: (value) => _updateEmailNotifications(value),
    ),
    ProfileSwitchItem(
      icon: Icons.phone_android,
      title: 'Push Notifications',
      subtitle: 'Receive push notifications on your device',
      value: _pushNotifications,
      isLoading: _isPushLoading,
      onChanged: (value) => _updatePushNotifications(value),
    ),
  ],
)
```

## Best Practices

### 1. Loading States

Always provide loading states for API calls:

```dart
void _updateNotification(bool value) async {
  setState(() => _isLoading = true);
  
  try {
    await apiService.updateNotification(value);
    setState(() {
      _notification = value;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Failed to update notification';
    });
  }
}
```

### 2. Error Handling

Provide meaningful error messages:

```dart
ProfileSwitchItem(
  // ... other properties
  errorMessage: _errorMessage,
  onChanged: (value) => _updateWithErrorHandling(value),
)
```

### 3. State Management

Use proper state management for complex scenarios:

```dart
class _MyPageState extends State<MyPage> {
  bool _switchValue = false;
  bool _isLoading = false;
  String? _errorMessage;

  void _updateSwitch(bool value) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiCall(value);
      setState(() {
        _switchValue = value;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update setting';
      });
    }
  }
}
```

### 4. Accessibility

The widget automatically handles accessibility, but ensure your callbacks are accessible:

```dart
onChanged: (value) {
  // Provide feedback for screen readers
  if (value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${title} enabled')),
    );
  }
  _updateSetting(value);
},
```

## Theme Integration

The widget automatically uses the global theme extensions:

- **Colors**: Uses `context.colors.primary` for active states
- **Typography**: Uses `context.labelL` for titles, `context.bodyS` for subtitles
- **Spacing**: Uses `context.cardPadding` for consistent spacing
- **Borders**: Uses `context.borderColor` for borders

## Migration Guide

### From Custom Switch Implementation

**Before:**
```dart
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF1A1D29),
    borderRadius: BorderRadius.circular(16),
  ),
  child: ListTile(
    leading: Icon(Icons.notifications),
    title: Text('Push Notifications'),
    subtitle: Text('Receive notifications'),
    trailing: Switch(
      value: _value,
      onChanged: _onChanged,
      activeColor: Colors.green,
    ),
  ),
)
```

**After:**
```dart
ProfileSwitchItem(
  icon: Icons.notifications,
  title: 'Push Notifications',
  subtitle: 'Receive notifications',
  value: _value,
  onChanged: _onChanged,
)
```

## Demo

See `profile_switch_demo.dart` for a comprehensive demonstration of all widget features and states.

## Files

- `profile_switch_item.dart` - Main switch widget implementation
- `profile_switch_demo.dart` - Demo page showcasing all features
- `README.md` - This documentation file 