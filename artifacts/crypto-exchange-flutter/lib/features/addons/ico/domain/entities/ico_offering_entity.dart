import 'package:equatable/equatable.dart';

enum IcoOfferingStatus {
  active,
  upcoming,
  pending,
  success,
  failed,
  rejected,
}

enum IcoTokenType {
  utility,
  security,
  governance,
  payment,
}

class IcoOfferingEntity extends Equatable {
  const IcoOfferingEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.icon,
    required this.status,
    required this.tokenType,
    required this.tokenPrice,
    required this.targetAmount,
    required this.raisedAmount,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.blockchain,
    required this.description,
    this.currentPhase,
    this.nextPhase,
    this.phases = const [],
    this.teamMembers = const [],
    this.roadmapItems = const [],
    this.website,
    this.isPaused = false,
    this.isFlagged = false,
    this.featured = false,
    this.priceChange,
    this.totalSupply,
    this.tokensForSale,
    this.salePercentage,
    this.links,
  });

  final String id;
  final String name;
  final String symbol;
  final String icon;
  final IcoOfferingStatus status;
  final IcoTokenType tokenType;
  final double tokenPrice;
  final double targetAmount;
  final double raisedAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int participants;
  final String blockchain;
  final String description;
  final IcoPhaseEntity? currentPhase;
  final IcoPhaseEntity? nextPhase;
  final List<IcoPhaseEntity> phases;
  final List<IcoTeamMemberEntity> teamMembers;
  final List<IcoRoadmapItemEntity> roadmapItems;
  final String? website;
  final bool isPaused;
  final bool isFlagged;
  final bool featured;
  final double? priceChange;
  final double? totalSupply;
  final double? tokensForSale;
  final double? salePercentage;
  final IcoLinksEntity? links;

  double get progressPercentage => targetAmount > 0
      ? (raisedAmount / targetAmount * 100).clamp(0.0, 100.0)
      : 0.0;

  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isActive =>
      status == IcoOfferingStatus.active && !isPaused && !isFlagged;
  bool get isUpcoming => status == IcoOfferingStatus.upcoming;
  bool get isCompleted =>
      status == IcoOfferingStatus.success || status == IcoOfferingStatus.failed;

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        icon,
        status,
        tokenType,
        tokenPrice,
        targetAmount,
        raisedAmount,
        startDate,
        endDate,
        participants,
        blockchain,
        description,
        currentPhase,
        nextPhase,
        phases,
        teamMembers,
        roadmapItems,
        website,
        isPaused,
        isFlagged,
        featured,
        priceChange,
        totalSupply,
        tokensForSale,
        salePercentage,
        links,
      ];

  IcoOfferingEntity copyWith({
    String? id,
    String? name,
    String? symbol,
    String? icon,
    IcoOfferingStatus? status,
    IcoTokenType? tokenType,
    double? tokenPrice,
    double? targetAmount,
    double? raisedAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? participants,
    String? blockchain,
    String? description,
    IcoPhaseEntity? currentPhase,
    IcoPhaseEntity? nextPhase,
    List<IcoPhaseEntity>? phases,
    List<IcoTeamMemberEntity>? teamMembers,
    List<IcoRoadmapItemEntity>? roadmapItems,
    String? website,
    bool? isPaused,
    bool? isFlagged,
    bool? featured,
    double? priceChange,
    double? totalSupply,
    double? tokensForSale,
    double? salePercentage,
    IcoLinksEntity? links,
  }) {
    return IcoOfferingEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      tokenType: tokenType ?? this.tokenType,
      tokenPrice: tokenPrice ?? this.tokenPrice,
      targetAmount: targetAmount ?? this.targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participants: participants ?? this.participants,
      blockchain: blockchain ?? this.blockchain,
      description: description ?? this.description,
      currentPhase: currentPhase ?? this.currentPhase,
      nextPhase: nextPhase ?? this.nextPhase,
      phases: phases ?? this.phases,
      teamMembers: teamMembers ?? this.teamMembers,
      roadmapItems: roadmapItems ?? this.roadmapItems,
      website: website ?? this.website,
      isPaused: isPaused ?? this.isPaused,
      isFlagged: isFlagged ?? this.isFlagged,
      featured: featured ?? this.featured,
      priceChange: priceChange ?? this.priceChange,
      totalSupply: totalSupply ?? this.totalSupply,
      tokensForSale: tokensForSale ?? this.tokensForSale,
      salePercentage: salePercentage ?? this.salePercentage,
      links: links ?? this.links,
    );
  }
}

class IcoPhaseEntity extends Equatable {
  const IcoPhaseEntity({
    required this.id,
    required this.name,
    required this.tokenPrice,
    required this.allocation,
    required this.remaining,
    required this.duration,
  });

  final String id;
  final String name;
  final double tokenPrice;
  final double allocation;
  final double remaining;
  final int duration; // in days

  double get soldPercentage => allocation > 0
      ? ((allocation - remaining) / allocation * 100).clamp(0.0, 100.0)
      : 0.0;

  @override
  List<Object?> get props =>
      [id, name, tokenPrice, allocation, remaining, duration];
}

class IcoTeamMemberEntity extends Equatable {
  const IcoTeamMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    this.bio,
    this.linkedin,
    this.twitter,
  });

  final String id;
  final String name;
  final String role;
  final String avatar;
  final String? bio;
  final String? linkedin;
  final String? twitter;

  @override
  List<Object?> get props => [id, name, role, avatar, bio, linkedin, twitter];
}

class IcoRoadmapItemEntity extends Equatable {
  const IcoRoadmapItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.completed,
  });

  final String id;
  final String title;
  final String description;
  final String date; // e.g., "Q1 2024"
  final bool completed;

  @override
  List<Object?> get props => [id, title, description, date, completed];
}

class IcoLinksEntity extends Equatable {
  const IcoLinksEntity({
    this.whitepaper,
    this.github,
    this.telegram,
    this.twitter,
    this.discord,
    this.medium,
  });

  final String? whitepaper;
  final String? github;
  final String? telegram;
  final String? twitter;
  final String? discord;
  final String? medium;

  @override
  List<Object?> get props =>
      [whitepaper, github, telegram, twitter, discord, medium];
}
