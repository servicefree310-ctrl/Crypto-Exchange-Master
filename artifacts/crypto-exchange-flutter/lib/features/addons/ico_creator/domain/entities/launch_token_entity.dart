import 'package:equatable/equatable.dart';

class LaunchTokenEntity extends Equatable {
  const LaunchTokenEntity({
    required this.name,
    required this.symbol,
    required this.icon,
    required this.tokenType,
    required this.blockchain,
    required this.totalSupply,
    required this.description,
    required this.tokenDetails,
    required this.teamMembers,
    required this.roadmap,
    required this.website,
    required this.targetAmount,
    required this.startDate,
    required this.phases,
    required this.termsAccepted,
    required this.selectedPlanId,
    required this.paymentComplete,
  });

  final String name;
  final String symbol;
  final String icon;
  final String tokenType;
  final String blockchain;
  final double totalSupply;
  final String description;
  final TokenDetailsEntity tokenDetails;
  final List<TeamMemberEntity> teamMembers;
  final List<RoadmapItemEntity> roadmap;
  final String website;
  final double targetAmount;
  final DateTime startDate;
  final List<PhaseEntity> phases;
  final bool termsAccepted;
  final String selectedPlanId;
  final bool paymentComplete;

  @override
  List<Object?> get props => [
        name,
        symbol,
        icon,
        tokenType,
        blockchain,
        totalSupply,
        description,
        tokenDetails,
        teamMembers,
        roadmap,
        website,
        targetAmount,
        startDate,
        phases,
        termsAccepted,
        selectedPlanId,
        paymentComplete,
      ];
}

class TokenDetailsEntity extends Equatable {
  const TokenDetailsEntity({
    required this.whitepaper,
    required this.github,
    required this.twitter,
    required this.telegram,
    required this.useOfFunds,
  });

  final String whitepaper;
  final String github;
  final String twitter;
  final String telegram;
  final List<String> useOfFunds;

  @override
  List<Object?> get props =>
      [whitepaper, github, twitter, telegram, useOfFunds];
}

class TeamMemberEntity extends Equatable {
  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    this.linkedin,
    this.twitter,
    this.github,
    this.website,
    this.avatar,
  });

  final String id;
  final String name;
  final String role;
  final String bio;
  final String? linkedin;
  final String? twitter;
  final String? github;
  final String? website;
  final String? avatar;

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        bio,
        linkedin,
        twitter,
        github,
        website,
        avatar,
      ];
}

class RoadmapItemEntity extends Equatable {
  const RoadmapItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.completed = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool completed;

  @override
  List<Object?> get props => [id, title, description, date, completed];
}

class PhaseEntity extends Equatable {
  const PhaseEntity({
    required this.id,
    required this.name,
    required this.tokenPrice,
    required this.allocation,
    required this.durationDays,
  });

  final String id;
  final String name;
  final double tokenPrice;
  final double allocation;
  final int durationDays;

  @override
  List<Object?> get props => [id, name, tokenPrice, allocation, durationDays];
}

// Validation helper
class LaunchTokenValidator {
  static const int minDescriptionLength = 50;
  static const int maxDescriptionLength = 1000;
  static const int minNameLength = 2;
  static const int minSymbolLength = 2;
  static const int maxSymbolLength = 8;
  static const int maxTeamBioLength = 500;
  static const int maxRoadmapDescriptionLength = 1000;

  static List<String> validate(LaunchTokenEntity entity) {
    final errors = <String>[];

    // Basic validation
    if (entity.name.length < minNameLength) {
      errors.add('Token name must be at least $minNameLength characters');
    }

    if (entity.symbol.length < minSymbolLength) {
      errors.add('Token symbol must be at least $minSymbolLength characters');
    }

    if (entity.symbol.length > maxSymbolLength) {
      errors.add('Token symbol must be at most $maxSymbolLength characters');
    }

    if (entity.description.length < minDescriptionLength) {
      errors
          .add('Description must be at least $minDescriptionLength characters');
    }

    if (entity.description.length > maxDescriptionLength) {
      errors
          .add('Description must be at most $maxDescriptionLength characters');
    }

    if (entity.icon.isEmpty) {
      errors.add('Token icon is required');
    }

    if (entity.icon.isNotEmpty && !_isValidUrl(entity.icon)) {
      errors.add('Invalid icon URL');
    }

    if (entity.website.isNotEmpty && !_isValidUrl(entity.website)) {
      errors.add('Invalid website URL');
    }

    if (entity.totalSupply <= 0) {
      errors.add('Total supply must be greater than 0');
    }

    if (entity.targetAmount <= 0) {
      errors.add('Target amount must be greater than 0');
    }

    if (entity.phases.isEmpty) {
      errors.add('At least one phase is required');
    }

    // Token details validation
    if (!_isValidUrl(entity.tokenDetails.whitepaper)) {
      errors.add('Invalid whitepaper URL');
    }

    if (!_isValidUrl(entity.tokenDetails.github)) {
      errors.add('Invalid GitHub URL');
    }

    if (!_isValidUrl(entity.tokenDetails.twitter)) {
      errors.add('Invalid Twitter URL');
    }

    if (!_isValidUrl(entity.tokenDetails.telegram)) {
      errors.add('Invalid Telegram URL');
    }

    if (entity.tokenDetails.useOfFunds.isEmpty) {
      errors.add('Use of funds is required');
    }

    // Team validation
    for (final member in entity.teamMembers) {
      if (member.name.isEmpty) {
        errors.add('Team member name is required');
      }
      if (member.role.isEmpty) {
        errors.add('Team member role is required');
      }
      if (member.bio.isEmpty) {
        errors.add('Team member bio is required');
      }
      if (member.bio.length > maxTeamBioLength) {
        errors.add(
            'Team member bio must be at most $maxTeamBioLength characters');
      }
    }

    // Roadmap validation
    for (final item in entity.roadmap) {
      if (item.title.isEmpty) {
        errors.add('Roadmap item title is required');
      }
      if (item.description.isEmpty) {
        errors.add('Roadmap item description is required');
      }
      if (item.description.length > maxRoadmapDescriptionLength) {
        errors.add(
            'Roadmap description must be at most $maxRoadmapDescriptionLength characters');
      }
    }

    // Terms acceptance
    if (!entity.termsAccepted) {
      errors.add('Terms and conditions must be accepted');
    }

    return errors;
  }

  static bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
