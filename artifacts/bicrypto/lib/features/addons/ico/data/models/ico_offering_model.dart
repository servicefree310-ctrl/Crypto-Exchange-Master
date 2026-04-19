import '../../domain/entities/ico_offering_entity.dart';
import 'ico_phase_model.dart';
import 'ico_token_detail_model.dart';
import 'ico_team_member_model.dart';
import 'ico_roadmap_item_model.dart';

class IcoOfferingModel {
  const IcoOfferingModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.typeId,
    required this.name,
    required this.symbol,
    required this.icon,
    required this.status,
    required this.purchaseWalletCurrency,
    required this.purchaseWalletType,
    required this.tokenPrice,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
    required this.participants,
    this.currentPrice,
    this.priceChange,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.reviewNotes,
    this.isPaused = false,
    this.isFlagged = false,
    this.featured,
    this.website,
    this.createdAt,
    this.updatedAt,
    this.phases = const [],
    this.tokenDetail,
    this.teamMembers = const [],
    this.roadmapItems = const [],
    this.currentRaised,
    this.raisedPercentage,
    this.currentPhase,
    this.nextPhase,
    this.daysRemaining,
  });

  final String id;
  final String userId;
  final String planId;
  final String typeId;
  final String name;
  final String symbol;
  final String icon;
  final String status;
  final String purchaseWalletCurrency;
  final String purchaseWalletType;
  final double tokenPrice;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int participants;
  final double? currentPrice;
  final double? priceChange;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? reviewNotes;
  final bool isPaused;
  final bool isFlagged;
  final bool? featured;
  final String? website;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<IcoPhaseModel> phases;
  final IcoTokenDetailModel? tokenDetail;
  final List<IcoTeamMemberModel> teamMembers;
  final List<IcoRoadmapItemModel> roadmapItems;
  final double? currentRaised;
  final double? raisedPercentage;
  final IcoPhaseModel? currentPhase;
  final IcoPhaseModel? nextPhase;
  final int? daysRemaining;

  factory IcoOfferingModel.fromJson(Map<String, dynamic> json) {
    return IcoOfferingModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      typeId: json['typeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      purchaseWalletCurrency: json['purchaseWalletCurrency']?.toString() ?? '',
      purchaseWalletType: json['purchaseWalletType']?.toString() ?? '',
      tokenPrice: (json['tokenPrice'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : DateTime.now(),
      participants: (json['participants'] as num?)?.toInt() ?? 0,
      currentPrice: json['currentPrice'] != null
          ? (json['currentPrice'] as num).toDouble()
          : null,
      priceChange: json['priceChange'] != null
          ? (json['priceChange'] as num).toDouble()
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'] as String)
          : null,
      reviewNotes: json['reviewNotes'] as String?,
      isPaused: json['isPaused'] as bool? ?? false,
      isFlagged: json['isFlagged'] as bool? ?? false,
      featured: json['featured'] as bool?,
      website: json['website'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      phases: json['phases'] != null
          ? (json['phases'] as List)
              .map((p) => IcoPhaseModel.fromJson(p as Map<String, dynamic>))
              .toList()
          : const [],
      tokenDetail: json['tokenDetail'] != null
          ? IcoTokenDetailModel.fromJson(
              json['tokenDetail'] as Map<String, dynamic>)
          : null,
      teamMembers: json['teamMembers'] != null
          ? (json['teamMembers'] as List)
              .map(
                  (t) => IcoTeamMemberModel.fromJson(t as Map<String, dynamic>))
              .toList()
          : const [],
      roadmapItems: json['roadmapItems'] != null
          ? (json['roadmapItems'] as List)
              .map((r) =>
                  IcoRoadmapItemModel.fromJson(r as Map<String, dynamic>))
              .toList()
          : const [],
      currentRaised: json['currentRaised'] != null
          ? (json['currentRaised'] as num).toDouble()
          : null,
      raisedPercentage: json['raisedPercentage'] != null
          ? (json['raisedPercentage'] as num).toDouble()
          : null,
      currentPhase: json['currentPhase'] != null
          ? IcoPhaseModel.fromJson(json['currentPhase'] as Map<String, dynamic>)
          : null,
      nextPhase: json['nextPhase'] != null
          ? IcoPhaseModel.fromJson(json['nextPhase'] as Map<String, dynamic>)
          : null,
      daysRemaining: json['daysRemaining'] as int?,
    );
  }

  IcoOfferingEntity toEntity() {
    return IcoOfferingEntity(
      id: id,
      name: name,
      symbol: symbol,
      icon: icon,
      status: _mapStatus(status),
      tokenType: _mapTokenType(tokenDetail?.tokenType ?? 'Utility'),
      tokenPrice: tokenPrice,
      targetAmount: targetAmount,
      raisedAmount: currentRaised ?? 0.0,
      startDate: startDate,
      endDate: endDate,
      participants: participants,
      blockchain: tokenDetail?.blockchain ?? 'Ethereum',
      description: tokenDetail?.description ?? '',
      currentPhase: currentPhase?.toEntity(),
      nextPhase: nextPhase?.toEntity(),
      phases: phases.map((p) => p.toEntity()).toList(),
      teamMembers: teamMembers.map((t) => t.toEntity()).toList(),
      roadmapItems: roadmapItems.map((r) => r.toEntity()).toList(),
      website: website,
      priceChange: priceChange,
      featured: featured ?? false,
      totalSupply: tokenDetail?.totalSupply,
      tokensForSale: tokenDetail?.tokensForSale,
      salePercentage: tokenDetail?.salePercentage,
      links: tokenDetail?.links != null
          ? IcoLinksEntity(
              whitepaper: tokenDetail!.links['whitepaper'] as String?,
              github: tokenDetail!.links['github'] as String?,
              telegram: tokenDetail!.links['telegram'] as String?,
              twitter: tokenDetail!.links['twitter'] as String?,
              discord: tokenDetail!.links['discord'] as String?,
              medium: tokenDetail!.links['medium'] as String?,
            )
          : null,
    );
  }

  IcoOfferingStatus _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return IcoOfferingStatus.active;
      case 'UPCOMING':
        return IcoOfferingStatus.upcoming;
      case 'PENDING':
        return IcoOfferingStatus.pending;
      case 'SUCCESS':
        return IcoOfferingStatus.success;
      case 'FAILED':
        return IcoOfferingStatus.failed;
      case 'REJECTED':
        return IcoOfferingStatus.rejected;
      case 'COMPLETED':
        return IcoOfferingStatus.success;
      case 'CANCELLED':
        return IcoOfferingStatus.failed;
      case 'DISABLED':
        return IcoOfferingStatus.failed;
      default:
        return IcoOfferingStatus.pending;
    }
  }

  IcoTokenType _mapTokenType(String tokenType) {
    switch (tokenType.toLowerCase()) {
      case 'utility':
        return IcoTokenType.utility;
      case 'security':
        return IcoTokenType.security;
      case 'governance':
        return IcoTokenType.governance;
      case 'payment':
        return IcoTokenType.payment;
      default:
        return IcoTokenType.utility;
    }
  }
}
