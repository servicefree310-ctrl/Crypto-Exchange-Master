import 'package:equatable/equatable.dart';

/// Theme types available in the app
enum AppThemeType { light, dark, system }

/// App theme entity for domain layer
class AppThemeEntity extends Equatable {
  final AppThemeType type;
  final String name;

  const AppThemeEntity({
    required this.type,
    required this.name,
  });

  @override
  List<Object> get props => [type, name];

  AppThemeEntity copyWith({
    AppThemeType? type,
    String? name,
  }) {
    return AppThemeEntity(
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }
}
