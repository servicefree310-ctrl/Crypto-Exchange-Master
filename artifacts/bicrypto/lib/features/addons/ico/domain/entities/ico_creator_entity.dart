import 'package:equatable/equatable.dart';
import 'ico_offering_entity.dart';

/// ICO Creator Dashboard Statistics
class IcoCreatorStatsEntity extends Equatable {
  const IcoCreatorStatsEntity({
    required this.totalTokensCreated,
    required this.activeTokens,
    required this.pendingTokens,
    required this.totalRaised,
    required this.totalInvestors,
    required this.avgRoi,
    required this.successRate,
  });

  final int totalTokensCreated;
  final int activeTokens;
  final int pendingTokens;
  final double totalRaised;
  final int totalInvestors;
  final double avgRoi;
  final double successRate;

  @override
  List<Object?> get props => [
        totalTokensCreated,
        activeTokens,
        pendingTokens,
        totalRaised,
        totalInvestors,
        avgRoi,
        successRate,
      ];
}

/// ICO Creator Performance Data
class IcoCreatorPerformanceEntity extends Equatable {
  const IcoCreatorPerformanceEntity({
    required this.period,
    required this.totalRaised,
    required this.totalInvestors,
    required this.averageInvestment,
    required this.performanceHistory,
  });

  final String period; // 'week', 'month', 'year'
  final double totalRaised;
  final int totalInvestors;
  final double averageInvestment;
  final List<PerformanceDataPoint> performanceHistory;

  @override
  List<Object?> get props => [
        period,
        totalRaised,
        totalInvestors,
        averageInvestment,
        performanceHistory,
      ];
}

/// Performance data point for charts
class PerformanceDataPoint extends Equatable {
  const PerformanceDataPoint({
    required this.date,
    required this.value,
    required this.investors,
    required this.volume,
  });

  final DateTime date;
  final double value;
  final int investors;
  final double volume;

  @override
  List<Object?> get props => [date, value, investors, volume];
}

/// ICO Creator Token with extended information
class IcoCreatorTokenEntity extends Equatable {
  const IcoCreatorTokenEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.description,
    required this.tokenType,
    required this.blockchain,
    required this.status,
    required this.totalSupply,
    required this.tokenPrice,
    required this.softCap,
    required this.hardCap,
    required this.raisedAmount,
    required this.investorCount,
    required this.progressPercentage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.logoUrl,
    this.websiteUrl,
    this.whitepaperUrl,
    this.teamMembers,
    this.roadmapItems,
    this.socialLinks,
  });

  final String id;
  final String name;
  final String symbol;
  final String description;
  final IcoTokenType tokenType;
  final String blockchain;
  final IcoOfferingStatus status;
  final double totalSupply;
  final double tokenPrice;
  final double softCap;
  final double hardCap;
  final double raisedAmount;
  final int investorCount;
  final double progressPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String? logoUrl;
  final String? websiteUrl;
  final String? whitepaperUrl;
  final List<TeamMemberEntity>? teamMembers;
  final List<RoadmapItemEntity>? roadmapItems;
  final List<SocialLinkEntity>? socialLinks;

  bool get isActive => status == IcoOfferingStatus.active;
  bool get isPending => status == IcoOfferingStatus.pending;
  bool get isUpcoming => status == IcoOfferingStatus.upcoming;
  bool get isCompleted => status == IcoOfferingStatus.success;

  @override
  List<Object?> get props => [
        id,
        name,
        symbol,
        description,
        tokenType,
        blockchain,
        status,
        totalSupply,
        tokenPrice,
        softCap,
        hardCap,
        raisedAmount,
        investorCount,
        progressPercentage,
        startDate,
        endDate,
        createdAt,
        logoUrl,
        websiteUrl,
        whitepaperUrl,
        teamMembers,
        roadmapItems,
        socialLinks,
      ];
}

/// Team member entity
class TeamMemberEntity extends Equatable {
  const TeamMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    this.avatarUrl,
    this.linkedinUrl,
    this.twitterUrl,
  });

  final String id;
  final String name;
  final String role;
  final String bio;
  final String? avatarUrl;
  final String? linkedinUrl;
  final String? twitterUrl;

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        bio,
        avatarUrl,
        linkedinUrl,
        twitterUrl,
      ];
}

/// Roadmap item entity
class RoadmapItemEntity extends Equatable {
  const RoadmapItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.quarter,
    required this.year,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String quarter; // Q1, Q2, Q3, Q4
  final int year;
  final RoadmapStatus status;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        quarter,
        year,
        status,
      ];
}

/// Social link entity
class SocialLinkEntity extends Equatable {
  const SocialLinkEntity({
    required this.platform,
    required this.url,
  });

  final String platform; // 'twitter', 'telegram', 'discord', etc.
  final String url;

  @override
  List<Object?> get props => [platform, url];
}

/// ICO Creator Investor Entity
class IcoCreatorInvestorEntity extends Equatable {
  const IcoCreatorInvestorEntity({
    required this.id,
    required this.walletAddress,
    required this.totalInvested,
    required this.tokenAmount,
    required this.investmentCount,
    required this.firstInvestmentDate,
    required this.lastInvestmentDate,
    required this.status,
    this.emailHash, // For gravatar or identifier
  });

  final String id;
  final String walletAddress;
  final double totalInvested;
  final double tokenAmount;
  final int investmentCount;
  final DateTime firstInvestmentDate;
  final DateTime lastInvestmentDate;
  final String status; // 'active', 'verified', 'pending'
  final String? emailHash;

  String get maskedWalletAddress =>
      '${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}';

  @override
  List<Object?> get props => [
        id,
        walletAddress,
        totalInvested,
        tokenAmount,
        investmentCount,
        firstInvestmentDate,
        lastInvestmentDate,
        status,
        emailHash,
      ];
}

/// Token Simulator Data for local calculations
class TokenSimulatorEntity extends Equatable {
  const TokenSimulatorEntity({
    required this.tokenName,
    required this.tokenSymbol,
    required this.totalSupply,
    required this.tokenPrice,
    required this.distribution,
    required this.vestingSchedule,
    required this.projectionParams,
  });

  final String tokenName;
  final String tokenSymbol;
  final double totalSupply;
  final double tokenPrice;
  final TokenDistributionEntity distribution;
  final VestingScheduleEntity vestingSchedule;
  final ProjectionParamsEntity projectionParams;

  @override
  List<Object?> get props => [
        tokenName,
        tokenSymbol,
        totalSupply,
        tokenPrice,
        distribution,
        vestingSchedule,
        projectionParams,
      ];
}

/// Token distribution breakdown
class TokenDistributionEntity extends Equatable {
  const TokenDistributionEntity({
    required this.publicSale,
    required this.privateSale,
    required this.team,
    required this.advisors,
    required this.treasury,
    required this.ecosystem,
    required this.liquidity,
    required this.marketing,
  });

  final double publicSale;
  final double privateSale;
  final double team;
  final double advisors;
  final double treasury;
  final double ecosystem;
  final double liquidity;
  final double marketing;

  double get total =>
      publicSale +
      privateSale +
      team +
      advisors +
      treasury +
      ecosystem +
      liquidity +
      marketing;

  @override
  List<Object?> get props => [
        publicSale,
        privateSale,
        team,
        advisors,
        treasury,
        ecosystem,
        liquidity,
        marketing,
      ];
}

/// Vesting schedule parameters
class VestingScheduleEntity extends Equatable {
  const VestingScheduleEntity({
    required this.teamCliffMonths,
    required this.teamVestingMonths,
    required this.advisorsCliffMonths,
    required this.advisorsVestingMonths,
    required this.publicSaleUnlock,
    required this.privateSaleCliffMonths,
    required this.privateSaleVestingMonths,
  });

  final int teamCliffMonths;
  final int teamVestingMonths;
  final int advisorsCliffMonths;
  final int advisorsVestingMonths;
  final double publicSaleUnlock; // percentage unlocked immediately
  final int privateSaleCliffMonths;
  final int privateSaleVestingMonths;

  @override
  List<Object?> get props => [
        teamCliffMonths,
        teamVestingMonths,
        advisorsCliffMonths,
        advisorsVestingMonths,
        publicSaleUnlock,
        privateSaleCliffMonths,
        privateSaleVestingMonths,
      ];
}

/// Market projection parameters
class ProjectionParamsEntity extends Equatable {
  const ProjectionParamsEntity({
    required this.initialMarketCap,
    required this.growthRate,
    required this.volatility,
    required this.adoptionRate,
    required this.projectionMonths,
  });

  final double initialMarketCap;
  final double growthRate; // Annual growth rate percentage
  final double volatility; // Volatility percentage
  final double adoptionRate; // User adoption rate
  final int projectionMonths;

  @override
  List<Object?> get props => [
        initialMarketCap,
        growthRate,
        volatility,
        adoptionRate,
        projectionMonths,
      ];
}

/// ICO Launch Request Entity
class IcoLaunchRequestEntity extends Equatable {
  const IcoLaunchRequestEntity({
    required this.tokenDetails,
    required this.offeringDetails,
    required this.teamInfo,
    required this.roadmap,
    required this.documents,
    required this.socialLinks,
  });

  final TokenDetailsEntity tokenDetails;
  final OfferingDetailsEntity offeringDetails;
  final List<TeamMemberEntity> teamInfo;
  final List<RoadmapItemEntity> roadmap;
  final DocumentsEntity documents;
  final List<SocialLinkEntity> socialLinks;

  @override
  List<Object?> get props => [
        tokenDetails,
        offeringDetails,
        teamInfo,
        roadmap,
        documents,
        socialLinks,
      ];
}

/// Token details for launch
class TokenDetailsEntity extends Equatable {
  const TokenDetailsEntity({
    required this.name,
    required this.symbol,
    required this.description,
    required this.tokenType,
    required this.blockchain,
    required this.totalSupply,
    required this.tokenPrice,
    this.logoUrl,
    this.websiteUrl,
  });

  final String name;
  final String symbol;
  final String description;
  final IcoTokenType tokenType;
  final String blockchain;
  final double totalSupply;
  final double tokenPrice;
  final String? logoUrl;
  final String? websiteUrl;

  @override
  List<Object?> get props => [
        name,
        symbol,
        description,
        tokenType,
        blockchain,
        totalSupply,
        tokenPrice,
        logoUrl,
        websiteUrl,
      ];
}

/// Offering details for launch
class OfferingDetailsEntity extends Equatable {
  const OfferingDetailsEntity({
    required this.softCap,
    required this.hardCap,
    required this.startDate,
    required this.endDate,
    required this.minInvestment,
    required this.maxInvestment,
  });

  final double softCap;
  final double hardCap;
  final DateTime startDate;
  final DateTime endDate;
  final double minInvestment;
  final double maxInvestment;

  @override
  List<Object?> get props => [
        softCap,
        hardCap,
        startDate,
        endDate,
        minInvestment,
        maxInvestment,
      ];
}

/// Documents for ICO launch
class DocumentsEntity extends Equatable {
  const DocumentsEntity({
    this.whitepaperUrl,
    this.pitchDeckUrl,
    this.legalDocumentsUrl,
    this.auditReportUrl,
  });

  final String? whitepaperUrl;
  final String? pitchDeckUrl;
  final String? legalDocumentsUrl;
  final String? auditReportUrl;

  @override
  List<Object?> get props => [
        whitepaperUrl,
        pitchDeckUrl,
        legalDocumentsUrl,
        auditReportUrl,
      ];
}

/// Enums
enum RoadmapStatus {
  planned,
  inProgress,
  completed,
  delayed,
}
