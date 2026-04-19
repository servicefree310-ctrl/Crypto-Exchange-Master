// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'p2p_trade_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

P2PTradeModel _$P2PTradeModelFromJson(Map<String, dynamic> json) {
  return _P2PTradeModel.fromJson(json);
}

/// @nodoc
mixin _$P2PTradeModel {
  String get id => throw _privateConstructorUsedError;
  String get offerId => throw _privateConstructorUsedError;
  String get buyerUserId => throw _privateConstructorUsedError;
  String get sellerUserId => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get tradeType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get lastResponseAt => throw _privateConstructorUsedError;
  String? get referenceNumber => throw _privateConstructorUsedError;
  String? get chatRoomId => throw _privateConstructorUsedError;
  String? get escrowId => throw _privateConstructorUsedError;
  String? get disputeId => throw _privateConstructorUsedError;
  String? get paymentProof => throw _privateConstructorUsedError;
  String? get buyerNote => throw _privateConstructorUsedError;
  String? get sellerNote => throw _privateConstructorUsedError;
  String? get adminNote => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  P2POfferModel? get offer => throw _privateConstructorUsedError;
  P2PUserModel? get buyer => throw _privateConstructorUsedError;
  P2PUserModel? get seller => throw _privateConstructorUsedError;
  P2PPaymentMethodModel? get paymentMethod =>
      throw _privateConstructorUsedError;
  List<P2PTradeMessageModel>? get messages =>
      throw _privateConstructorUsedError;
  List<P2PTradeTimelineModel>? get timeline =>
      throw _privateConstructorUsedError;

  /// Serializes this P2PTradeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PTradeModelCopyWith<P2PTradeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PTradeModelCopyWith<$Res> {
  factory $P2PTradeModelCopyWith(
          P2PTradeModel value, $Res Function(P2PTradeModel) then) =
      _$P2PTradeModelCopyWithImpl<$Res, P2PTradeModel>;
  @useResult
  $Res call(
      {String id,
      String offerId,
      String buyerUserId,
      String sellerUserId,
      String currency,
      double amount,
      double price,
      double total,
      String status,
      String tradeType,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? completedAt,
      DateTime? expiresAt,
      DateTime? lastResponseAt,
      String? referenceNumber,
      String? chatRoomId,
      String? escrowId,
      String? disputeId,
      String? paymentProof,
      String? buyerNote,
      String? sellerNote,
      String? adminNote,
      Map<String, dynamic>? metadata,
      P2POfferModel? offer,
      P2PUserModel? buyer,
      P2PUserModel? seller,
      P2PPaymentMethodModel? paymentMethod,
      List<P2PTradeMessageModel>? messages,
      List<P2PTradeTimelineModel>? timeline});

  $P2POfferModelCopyWith<$Res>? get offer;
  $P2PUserModelCopyWith<$Res>? get buyer;
  $P2PUserModelCopyWith<$Res>? get seller;
  $P2PPaymentMethodModelCopyWith<$Res>? get paymentMethod;
}

/// @nodoc
class _$P2PTradeModelCopyWithImpl<$Res, $Val extends P2PTradeModel>
    implements $P2PTradeModelCopyWith<$Res> {
  _$P2PTradeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? offerId = null,
    Object? buyerUserId = null,
    Object? sellerUserId = null,
    Object? currency = null,
    Object? amount = null,
    Object? price = null,
    Object? total = null,
    Object? status = null,
    Object? tradeType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? completedAt = freezed,
    Object? expiresAt = freezed,
    Object? lastResponseAt = freezed,
    Object? referenceNumber = freezed,
    Object? chatRoomId = freezed,
    Object? escrowId = freezed,
    Object? disputeId = freezed,
    Object? paymentProof = freezed,
    Object? buyerNote = freezed,
    Object? sellerNote = freezed,
    Object? adminNote = freezed,
    Object? metadata = freezed,
    Object? offer = freezed,
    Object? buyer = freezed,
    Object? seller = freezed,
    Object? paymentMethod = freezed,
    Object? messages = freezed,
    Object? timeline = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      offerId: null == offerId
          ? _value.offerId
          : offerId // ignore: cast_nullable_to_non_nullable
              as String,
      buyerUserId: null == buyerUserId
          ? _value.buyerUserId
          : buyerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerUserId: null == sellerUserId
          ? _value.sellerUserId
          : sellerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      tradeType: null == tradeType
          ? _value.tradeType
          : tradeType // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastResponseAt: freezed == lastResponseAt
          ? _value.lastResponseAt
          : lastResponseAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      chatRoomId: freezed == chatRoomId
          ? _value.chatRoomId
          : chatRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
      escrowId: freezed == escrowId
          ? _value.escrowId
          : escrowId // ignore: cast_nullable_to_non_nullable
              as String?,
      disputeId: freezed == disputeId
          ? _value.disputeId
          : disputeId // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentProof: freezed == paymentProof
          ? _value.paymentProof
          : paymentProof // ignore: cast_nullable_to_non_nullable
              as String?,
      buyerNote: freezed == buyerNote
          ? _value.buyerNote
          : buyerNote // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerNote: freezed == sellerNote
          ? _value.sellerNote
          : sellerNote // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNote: freezed == adminNote
          ? _value.adminNote
          : adminNote // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      offer: freezed == offer
          ? _value.offer
          : offer // ignore: cast_nullable_to_non_nullable
              as P2POfferModel?,
      buyer: freezed == buyer
          ? _value.buyer
          : buyer // ignore: cast_nullable_to_non_nullable
              as P2PUserModel?,
      seller: freezed == seller
          ? _value.seller
          : seller // ignore: cast_nullable_to_non_nullable
              as P2PUserModel?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as P2PPaymentMethodModel?,
      messages: freezed == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<P2PTradeMessageModel>?,
      timeline: freezed == timeline
          ? _value.timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<P2PTradeTimelineModel>?,
    ) as $Val);
  }

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $P2POfferModelCopyWith<$Res>? get offer {
    if (_value.offer == null) {
      return null;
    }

    return $P2POfferModelCopyWith<$Res>(_value.offer!, (value) {
      return _then(_value.copyWith(offer: value) as $Val);
    });
  }

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $P2PUserModelCopyWith<$Res>? get buyer {
    if (_value.buyer == null) {
      return null;
    }

    return $P2PUserModelCopyWith<$Res>(_value.buyer!, (value) {
      return _then(_value.copyWith(buyer: value) as $Val);
    });
  }

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $P2PUserModelCopyWith<$Res>? get seller {
    if (_value.seller == null) {
      return null;
    }

    return $P2PUserModelCopyWith<$Res>(_value.seller!, (value) {
      return _then(_value.copyWith(seller: value) as $Val);
    });
  }

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $P2PPaymentMethodModelCopyWith<$Res>? get paymentMethod {
    if (_value.paymentMethod == null) {
      return null;
    }

    return $P2PPaymentMethodModelCopyWith<$Res>(_value.paymentMethod!, (value) {
      return _then(_value.copyWith(paymentMethod: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$P2PTradeModelImplCopyWith<$Res>
    implements $P2PTradeModelCopyWith<$Res> {
  factory _$$P2PTradeModelImplCopyWith(
          _$P2PTradeModelImpl value, $Res Function(_$P2PTradeModelImpl) then) =
      __$$P2PTradeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String offerId,
      String buyerUserId,
      String sellerUserId,
      String currency,
      double amount,
      double price,
      double total,
      String status,
      String tradeType,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? completedAt,
      DateTime? expiresAt,
      DateTime? lastResponseAt,
      String? referenceNumber,
      String? chatRoomId,
      String? escrowId,
      String? disputeId,
      String? paymentProof,
      String? buyerNote,
      String? sellerNote,
      String? adminNote,
      Map<String, dynamic>? metadata,
      P2POfferModel? offer,
      P2PUserModel? buyer,
      P2PUserModel? seller,
      P2PPaymentMethodModel? paymentMethod,
      List<P2PTradeMessageModel>? messages,
      List<P2PTradeTimelineModel>? timeline});

  @override
  $P2POfferModelCopyWith<$Res>? get offer;
  @override
  $P2PUserModelCopyWith<$Res>? get buyer;
  @override
  $P2PUserModelCopyWith<$Res>? get seller;
  @override
  $P2PPaymentMethodModelCopyWith<$Res>? get paymentMethod;
}

/// @nodoc
class __$$P2PTradeModelImplCopyWithImpl<$Res>
    extends _$P2PTradeModelCopyWithImpl<$Res, _$P2PTradeModelImpl>
    implements _$$P2PTradeModelImplCopyWith<$Res> {
  __$$P2PTradeModelImplCopyWithImpl(
      _$P2PTradeModelImpl _value, $Res Function(_$P2PTradeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? offerId = null,
    Object? buyerUserId = null,
    Object? sellerUserId = null,
    Object? currency = null,
    Object? amount = null,
    Object? price = null,
    Object? total = null,
    Object? status = null,
    Object? tradeType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? completedAt = freezed,
    Object? expiresAt = freezed,
    Object? lastResponseAt = freezed,
    Object? referenceNumber = freezed,
    Object? chatRoomId = freezed,
    Object? escrowId = freezed,
    Object? disputeId = freezed,
    Object? paymentProof = freezed,
    Object? buyerNote = freezed,
    Object? sellerNote = freezed,
    Object? adminNote = freezed,
    Object? metadata = freezed,
    Object? offer = freezed,
    Object? buyer = freezed,
    Object? seller = freezed,
    Object? paymentMethod = freezed,
    Object? messages = freezed,
    Object? timeline = freezed,
  }) {
    return _then(_$P2PTradeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      offerId: null == offerId
          ? _value.offerId
          : offerId // ignore: cast_nullable_to_non_nullable
              as String,
      buyerUserId: null == buyerUserId
          ? _value.buyerUserId
          : buyerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      sellerUserId: null == sellerUserId
          ? _value.sellerUserId
          : sellerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      tradeType: null == tradeType
          ? _value.tradeType
          : tradeType // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastResponseAt: freezed == lastResponseAt
          ? _value.lastResponseAt
          : lastResponseAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      referenceNumber: freezed == referenceNumber
          ? _value.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      chatRoomId: freezed == chatRoomId
          ? _value.chatRoomId
          : chatRoomId // ignore: cast_nullable_to_non_nullable
              as String?,
      escrowId: freezed == escrowId
          ? _value.escrowId
          : escrowId // ignore: cast_nullable_to_non_nullable
              as String?,
      disputeId: freezed == disputeId
          ? _value.disputeId
          : disputeId // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentProof: freezed == paymentProof
          ? _value.paymentProof
          : paymentProof // ignore: cast_nullable_to_non_nullable
              as String?,
      buyerNote: freezed == buyerNote
          ? _value.buyerNote
          : buyerNote // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerNote: freezed == sellerNote
          ? _value.sellerNote
          : sellerNote // ignore: cast_nullable_to_non_nullable
              as String?,
      adminNote: freezed == adminNote
          ? _value.adminNote
          : adminNote // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      offer: freezed == offer
          ? _value.offer
          : offer // ignore: cast_nullable_to_non_nullable
              as P2POfferModel?,
      buyer: freezed == buyer
          ? _value.buyer
          : buyer // ignore: cast_nullable_to_non_nullable
              as P2PUserModel?,
      seller: freezed == seller
          ? _value.seller
          : seller // ignore: cast_nullable_to_non_nullable
              as P2PUserModel?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as P2PPaymentMethodModel?,
      messages: freezed == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<P2PTradeMessageModel>?,
      timeline: freezed == timeline
          ? _value._timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<P2PTradeTimelineModel>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PTradeModelImpl implements _P2PTradeModel {
  const _$P2PTradeModelImpl(
      {required this.id,
      required this.offerId,
      required this.buyerUserId,
      required this.sellerUserId,
      required this.currency,
      required this.amount,
      required this.price,
      required this.total,
      required this.status,
      required this.tradeType,
      required this.createdAt,
      required this.updatedAt,
      this.completedAt,
      this.expiresAt,
      this.lastResponseAt,
      this.referenceNumber,
      this.chatRoomId,
      this.escrowId,
      this.disputeId,
      this.paymentProof,
      this.buyerNote,
      this.sellerNote,
      this.adminNote,
      final Map<String, dynamic>? metadata,
      this.offer,
      this.buyer,
      this.seller,
      this.paymentMethod,
      final List<P2PTradeMessageModel>? messages,
      final List<P2PTradeTimelineModel>? timeline})
      : _metadata = metadata,
        _messages = messages,
        _timeline = timeline;

  factory _$P2PTradeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PTradeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String offerId;
  @override
  final String buyerUserId;
  @override
  final String sellerUserId;
  @override
  final String currency;
  @override
  final double amount;
  @override
  final double price;
  @override
  final double total;
  @override
  final String status;
  @override
  final String tradeType;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? lastResponseAt;
  @override
  final String? referenceNumber;
  @override
  final String? chatRoomId;
  @override
  final String? escrowId;
  @override
  final String? disputeId;
  @override
  final String? paymentProof;
  @override
  final String? buyerNote;
  @override
  final String? sellerNote;
  @override
  final String? adminNote;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final P2POfferModel? offer;
  @override
  final P2PUserModel? buyer;
  @override
  final P2PUserModel? seller;
  @override
  final P2PPaymentMethodModel? paymentMethod;
  final List<P2PTradeMessageModel>? _messages;
  @override
  List<P2PTradeMessageModel>? get messages {
    final value = _messages;
    if (value == null) return null;
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<P2PTradeTimelineModel>? _timeline;
  @override
  List<P2PTradeTimelineModel>? get timeline {
    final value = _timeline;
    if (value == null) return null;
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'P2PTradeModel(id: $id, offerId: $offerId, buyerUserId: $buyerUserId, sellerUserId: $sellerUserId, currency: $currency, amount: $amount, price: $price, total: $total, status: $status, tradeType: $tradeType, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt, expiresAt: $expiresAt, lastResponseAt: $lastResponseAt, referenceNumber: $referenceNumber, chatRoomId: $chatRoomId, escrowId: $escrowId, disputeId: $disputeId, paymentProof: $paymentProof, buyerNote: $buyerNote, sellerNote: $sellerNote, adminNote: $adminNote, metadata: $metadata, offer: $offer, buyer: $buyer, seller: $seller, paymentMethod: $paymentMethod, messages: $messages, timeline: $timeline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PTradeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.offerId, offerId) || other.offerId == offerId) &&
            (identical(other.buyerUserId, buyerUserId) ||
                other.buyerUserId == buyerUserId) &&
            (identical(other.sellerUserId, sellerUserId) ||
                other.sellerUserId == sellerUserId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tradeType, tradeType) ||
                other.tradeType == tradeType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.lastResponseAt, lastResponseAt) ||
                other.lastResponseAt == lastResponseAt) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.chatRoomId, chatRoomId) ||
                other.chatRoomId == chatRoomId) &&
            (identical(other.escrowId, escrowId) ||
                other.escrowId == escrowId) &&
            (identical(other.disputeId, disputeId) ||
                other.disputeId == disputeId) &&
            (identical(other.paymentProof, paymentProof) ||
                other.paymentProof == paymentProof) &&
            (identical(other.buyerNote, buyerNote) ||
                other.buyerNote == buyerNote) &&
            (identical(other.sellerNote, sellerNote) ||
                other.sellerNote == sellerNote) &&
            (identical(other.adminNote, adminNote) ||
                other.adminNote == adminNote) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.offer, offer) || other.offer == offer) &&
            (identical(other.buyer, buyer) || other.buyer == buyer) &&
            (identical(other.seller, seller) || other.seller == seller) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            const DeepCollectionEquality().equals(other._timeline, _timeline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        offerId,
        buyerUserId,
        sellerUserId,
        currency,
        amount,
        price,
        total,
        status,
        tradeType,
        createdAt,
        updatedAt,
        completedAt,
        expiresAt,
        lastResponseAt,
        referenceNumber,
        chatRoomId,
        escrowId,
        disputeId,
        paymentProof,
        buyerNote,
        sellerNote,
        adminNote,
        const DeepCollectionEquality().hash(_metadata),
        offer,
        buyer,
        seller,
        paymentMethod,
        const DeepCollectionEquality().hash(_messages),
        const DeepCollectionEquality().hash(_timeline)
      ]);

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PTradeModelImplCopyWith<_$P2PTradeModelImpl> get copyWith =>
      __$$P2PTradeModelImplCopyWithImpl<_$P2PTradeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PTradeModelImplToJson(
      this,
    );
  }
}

abstract class _P2PTradeModel implements P2PTradeModel {
  const factory _P2PTradeModel(
      {required final String id,
      required final String offerId,
      required final String buyerUserId,
      required final String sellerUserId,
      required final String currency,
      required final double amount,
      required final double price,
      required final double total,
      required final String status,
      required final String tradeType,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? completedAt,
      final DateTime? expiresAt,
      final DateTime? lastResponseAt,
      final String? referenceNumber,
      final String? chatRoomId,
      final String? escrowId,
      final String? disputeId,
      final String? paymentProof,
      final String? buyerNote,
      final String? sellerNote,
      final String? adminNote,
      final Map<String, dynamic>? metadata,
      final P2POfferModel? offer,
      final P2PUserModel? buyer,
      final P2PUserModel? seller,
      final P2PPaymentMethodModel? paymentMethod,
      final List<P2PTradeMessageModel>? messages,
      final List<P2PTradeTimelineModel>? timeline}) = _$P2PTradeModelImpl;

  factory _P2PTradeModel.fromJson(Map<String, dynamic> json) =
      _$P2PTradeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get offerId;
  @override
  String get buyerUserId;
  @override
  String get sellerUserId;
  @override
  String get currency;
  @override
  double get amount;
  @override
  double get price;
  @override
  double get total;
  @override
  String get status;
  @override
  String get tradeType;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get lastResponseAt;
  @override
  String? get referenceNumber;
  @override
  String? get chatRoomId;
  @override
  String? get escrowId;
  @override
  String? get disputeId;
  @override
  String? get paymentProof;
  @override
  String? get buyerNote;
  @override
  String? get sellerNote;
  @override
  String? get adminNote;
  @override
  Map<String, dynamic>? get metadata;
  @override
  P2POfferModel? get offer;
  @override
  P2PUserModel? get buyer;
  @override
  P2PUserModel? get seller;
  @override
  P2PPaymentMethodModel? get paymentMethod;
  @override
  List<P2PTradeMessageModel>? get messages;
  @override
  List<P2PTradeTimelineModel>? get timeline;

  /// Create a copy of P2PTradeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PTradeModelImplCopyWith<_$P2PTradeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

P2PTradeMessageModel _$P2PTradeMessageModelFromJson(Map<String, dynamic> json) {
  return _P2PTradeMessageModel.fromJson(json);
}

/// @nodoc
mixin _$P2PTradeMessageModel {
  String get id => throw _privateConstructorUsedError;
  String get tradeId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get fileUrl => throw _privateConstructorUsedError;
  String? get fileName => throw _privateConstructorUsedError;
  String? get fileType => throw _privateConstructorUsedError;
  int? get fileSize => throw _privateConstructorUsedError;
  bool? get isSystemMessage => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this P2PTradeMessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PTradeMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PTradeMessageModelCopyWith<P2PTradeMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PTradeMessageModelCopyWith<$Res> {
  factory $P2PTradeMessageModelCopyWith(P2PTradeMessageModel value,
          $Res Function(P2PTradeMessageModel) then) =
      _$P2PTradeMessageModelCopyWithImpl<$Res, P2PTradeMessageModel>;
  @useResult
  $Res call(
      {String id,
      String tradeId,
      String userId,
      String message,
      String type,
      DateTime createdAt,
      String? fileUrl,
      String? fileName,
      String? fileType,
      int? fileSize,
      bool? isSystemMessage,
      bool isRead,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$P2PTradeMessageModelCopyWithImpl<$Res,
        $Val extends P2PTradeMessageModel>
    implements $P2PTradeMessageModelCopyWith<$Res> {
  _$P2PTradeMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PTradeMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tradeId = null,
    Object? userId = null,
    Object? message = null,
    Object? type = null,
    Object? createdAt = null,
    Object? fileUrl = freezed,
    Object? fileName = freezed,
    Object? fileType = freezed,
    Object? fileSize = freezed,
    Object? isSystemMessage = freezed,
    Object? isRead = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tradeId: null == tradeId
          ? _value.tradeId
          : tradeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileUrl: freezed == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: freezed == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileType: freezed == fileType
          ? _value.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      isSystemMessage: freezed == isSystemMessage
          ? _value.isSystemMessage
          : isSystemMessage // ignore: cast_nullable_to_non_nullable
              as bool?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2PTradeMessageModelImplCopyWith<$Res>
    implements $P2PTradeMessageModelCopyWith<$Res> {
  factory _$$P2PTradeMessageModelImplCopyWith(_$P2PTradeMessageModelImpl value,
          $Res Function(_$P2PTradeMessageModelImpl) then) =
      __$$P2PTradeMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tradeId,
      String userId,
      String message,
      String type,
      DateTime createdAt,
      String? fileUrl,
      String? fileName,
      String? fileType,
      int? fileSize,
      bool? isSystemMessage,
      bool isRead,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$P2PTradeMessageModelImplCopyWithImpl<$Res>
    extends _$P2PTradeMessageModelCopyWithImpl<$Res, _$P2PTradeMessageModelImpl>
    implements _$$P2PTradeMessageModelImplCopyWith<$Res> {
  __$$P2PTradeMessageModelImplCopyWithImpl(_$P2PTradeMessageModelImpl _value,
      $Res Function(_$P2PTradeMessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PTradeMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tradeId = null,
    Object? userId = null,
    Object? message = null,
    Object? type = null,
    Object? createdAt = null,
    Object? fileUrl = freezed,
    Object? fileName = freezed,
    Object? fileType = freezed,
    Object? fileSize = freezed,
    Object? isSystemMessage = freezed,
    Object? isRead = null,
    Object? metadata = freezed,
  }) {
    return _then(_$P2PTradeMessageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tradeId: null == tradeId
          ? _value.tradeId
          : tradeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileUrl: freezed == fileUrl
          ? _value.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: freezed == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileType: freezed == fileType
          ? _value.fileType
          : fileType // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      isSystemMessage: freezed == isSystemMessage
          ? _value.isSystemMessage
          : isSystemMessage // ignore: cast_nullable_to_non_nullable
              as bool?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PTradeMessageModelImpl implements _P2PTradeMessageModel {
  const _$P2PTradeMessageModelImpl(
      {required this.id,
      required this.tradeId,
      required this.userId,
      required this.message,
      required this.type,
      required this.createdAt,
      this.fileUrl,
      this.fileName,
      this.fileType,
      this.fileSize,
      this.isSystemMessage,
      this.isRead = false,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$P2PTradeMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PTradeMessageModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tradeId;
  @override
  final String userId;
  @override
  final String message;
  @override
  final String type;
  @override
  final DateTime createdAt;
  @override
  final String? fileUrl;
  @override
  final String? fileName;
  @override
  final String? fileType;
  @override
  final int? fileSize;
  @override
  final bool? isSystemMessage;
  @override
  @JsonKey()
  final bool isRead;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'P2PTradeMessageModel(id: $id, tradeId: $tradeId, userId: $userId, message: $message, type: $type, createdAt: $createdAt, fileUrl: $fileUrl, fileName: $fileName, fileType: $fileType, fileSize: $fileSize, isSystemMessage: $isSystemMessage, isRead: $isRead, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PTradeMessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tradeId, tradeId) || other.tradeId == tradeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.isSystemMessage, isSystemMessage) ||
                other.isSystemMessage == isSystemMessage) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tradeId,
      userId,
      message,
      type,
      createdAt,
      fileUrl,
      fileName,
      fileType,
      fileSize,
      isSystemMessage,
      isRead,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of P2PTradeMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PTradeMessageModelImplCopyWith<_$P2PTradeMessageModelImpl>
      get copyWith =>
          __$$P2PTradeMessageModelImplCopyWithImpl<_$P2PTradeMessageModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PTradeMessageModelImplToJson(
      this,
    );
  }
}

abstract class _P2PTradeMessageModel implements P2PTradeMessageModel {
  const factory _P2PTradeMessageModel(
      {required final String id,
      required final String tradeId,
      required final String userId,
      required final String message,
      required final String type,
      required final DateTime createdAt,
      final String? fileUrl,
      final String? fileName,
      final String? fileType,
      final int? fileSize,
      final bool? isSystemMessage,
      final bool isRead,
      final Map<String, dynamic>? metadata}) = _$P2PTradeMessageModelImpl;

  factory _P2PTradeMessageModel.fromJson(Map<String, dynamic> json) =
      _$P2PTradeMessageModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tradeId;
  @override
  String get userId;
  @override
  String get message;
  @override
  String get type;
  @override
  DateTime get createdAt;
  @override
  String? get fileUrl;
  @override
  String? get fileName;
  @override
  String? get fileType;
  @override
  int? get fileSize;
  @override
  bool? get isSystemMessage;
  @override
  bool get isRead;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of P2PTradeMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PTradeMessageModelImplCopyWith<_$P2PTradeMessageModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

P2PTradeTimelineModel _$P2PTradeTimelineModelFromJson(
    Map<String, dynamic> json) {
  return _P2PTradeTimelineModel.fromJson(json);
}

/// @nodoc
mixin _$P2PTradeTimelineModel {
  String get id => throw _privateConstructorUsedError;
  String get tradeId => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this P2PTradeTimelineModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of P2PTradeTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $P2PTradeTimelineModelCopyWith<P2PTradeTimelineModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $P2PTradeTimelineModelCopyWith<$Res> {
  factory $P2PTradeTimelineModelCopyWith(P2PTradeTimelineModel value,
          $Res Function(P2PTradeTimelineModel) then) =
      _$P2PTradeTimelineModelCopyWithImpl<$Res, P2PTradeTimelineModel>;
  @useResult
  $Res call(
      {String id,
      String tradeId,
      String action,
      String status,
      DateTime timestamp,
      String? userId,
      String? note,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$P2PTradeTimelineModelCopyWithImpl<$Res,
        $Val extends P2PTradeTimelineModel>
    implements $P2PTradeTimelineModelCopyWith<$Res> {
  _$P2PTradeTimelineModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of P2PTradeTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tradeId = null,
    Object? action = null,
    Object? status = null,
    Object? timestamp = null,
    Object? userId = freezed,
    Object? note = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tradeId: null == tradeId
          ? _value.tradeId
          : tradeId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$P2PTradeTimelineModelImplCopyWith<$Res>
    implements $P2PTradeTimelineModelCopyWith<$Res> {
  factory _$$P2PTradeTimelineModelImplCopyWith(
          _$P2PTradeTimelineModelImpl value,
          $Res Function(_$P2PTradeTimelineModelImpl) then) =
      __$$P2PTradeTimelineModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tradeId,
      String action,
      String status,
      DateTime timestamp,
      String? userId,
      String? note,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$P2PTradeTimelineModelImplCopyWithImpl<$Res>
    extends _$P2PTradeTimelineModelCopyWithImpl<$Res,
        _$P2PTradeTimelineModelImpl>
    implements _$$P2PTradeTimelineModelImplCopyWith<$Res> {
  __$$P2PTradeTimelineModelImplCopyWithImpl(_$P2PTradeTimelineModelImpl _value,
      $Res Function(_$P2PTradeTimelineModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of P2PTradeTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tradeId = null,
    Object? action = null,
    Object? status = null,
    Object? timestamp = null,
    Object? userId = freezed,
    Object? note = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$P2PTradeTimelineModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tradeId: null == tradeId
          ? _value.tradeId
          : tradeId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$P2PTradeTimelineModelImpl implements _P2PTradeTimelineModel {
  const _$P2PTradeTimelineModelImpl(
      {required this.id,
      required this.tradeId,
      required this.action,
      required this.status,
      required this.timestamp,
      this.userId,
      this.note,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$P2PTradeTimelineModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$P2PTradeTimelineModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tradeId;
  @override
  final String action;
  @override
  final String status;
  @override
  final DateTime timestamp;
  @override
  final String? userId;
  @override
  final String? note;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'P2PTradeTimelineModel(id: $id, tradeId: $tradeId, action: $action, status: $status, timestamp: $timestamp, userId: $userId, note: $note, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$P2PTradeTimelineModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tradeId, tradeId) || other.tradeId == tradeId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tradeId, action, status,
      timestamp, userId, note, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of P2PTradeTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$P2PTradeTimelineModelImplCopyWith<_$P2PTradeTimelineModelImpl>
      get copyWith => __$$P2PTradeTimelineModelImplCopyWithImpl<
          _$P2PTradeTimelineModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$P2PTradeTimelineModelImplToJson(
      this,
    );
  }
}

abstract class _P2PTradeTimelineModel implements P2PTradeTimelineModel {
  const factory _P2PTradeTimelineModel(
      {required final String id,
      required final String tradeId,
      required final String action,
      required final String status,
      required final DateTime timestamp,
      final String? userId,
      final String? note,
      final Map<String, dynamic>? metadata}) = _$P2PTradeTimelineModelImpl;

  factory _P2PTradeTimelineModel.fromJson(Map<String, dynamic> json) =
      _$P2PTradeTimelineModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tradeId;
  @override
  String get action;
  @override
  String get status;
  @override
  DateTime get timestamp;
  @override
  String? get userId;
  @override
  String? get note;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of P2PTradeTimelineModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$P2PTradeTimelineModelImplCopyWith<_$P2PTradeTimelineModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
