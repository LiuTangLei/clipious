// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manage_subscriptions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ManageSubscriptionsState {
  List<Subscription> get subs => throw _privateConstructorUsedError;
  List<OfflineSubscription> get offlineSubs =>
      throw _privateConstructorUsedError;
  dynamic get isLoggedIn => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;

  /// Create a copy of ManageSubscriptionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ManageSubscriptionsStateCopyWith<ManageSubscriptionsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ManageSubscriptionsStateCopyWith<$Res> {
  factory $ManageSubscriptionsStateCopyWith(ManageSubscriptionsState value,
          $Res Function(ManageSubscriptionsState) then) =
      _$ManageSubscriptionsStateCopyWithImpl<$Res, ManageSubscriptionsState>;
  @useResult
  $Res call(
      {List<Subscription> subs,
      List<OfflineSubscription> offlineSubs,
      dynamic isLoggedIn,
      bool loading});
}

/// @nodoc
class _$ManageSubscriptionsStateCopyWithImpl<$Res,
        $Val extends ManageSubscriptionsState>
    implements $ManageSubscriptionsStateCopyWith<$Res> {
  _$ManageSubscriptionsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ManageSubscriptionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subs = null,
    Object? offlineSubs = null,
    Object? isLoggedIn = freezed,
    Object? loading = null,
  }) {
    return _then(_value.copyWith(
      subs: null == subs
          ? _value.subs
          : subs // ignore: cast_nullable_to_non_nullable
              as List<Subscription>,
      offlineSubs: null == offlineSubs
          ? _value.offlineSubs
          : offlineSubs // ignore: cast_nullable_to_non_nullable
              as List<OfflineSubscription>,
      isLoggedIn: freezed == isLoggedIn
          ? _value.isLoggedIn
          : isLoggedIn // ignore: cast_nullable_to_non_nullable
              as dynamic,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ManageSubscriptionsStateImplCopyWith<$Res>
    implements $ManageSubscriptionsStateCopyWith<$Res> {
  factory _$$ManageSubscriptionsStateImplCopyWith(
          _$ManageSubscriptionsStateImpl value,
          $Res Function(_$ManageSubscriptionsStateImpl) then) =
      __$$ManageSubscriptionsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Subscription> subs,
      List<OfflineSubscription> offlineSubs,
      dynamic isLoggedIn,
      bool loading});
}

/// @nodoc
class __$$ManageSubscriptionsStateImplCopyWithImpl<$Res>
    extends _$ManageSubscriptionsStateCopyWithImpl<$Res,
        _$ManageSubscriptionsStateImpl>
    implements _$$ManageSubscriptionsStateImplCopyWith<$Res> {
  __$$ManageSubscriptionsStateImplCopyWithImpl(
      _$ManageSubscriptionsStateImpl _value,
      $Res Function(_$ManageSubscriptionsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ManageSubscriptionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subs = null,
    Object? offlineSubs = null,
    Object? isLoggedIn = freezed,
    Object? loading = null,
  }) {
    return _then(_$ManageSubscriptionsStateImpl(
      subs: null == subs
          ? _value._subs
          : subs // ignore: cast_nullable_to_non_nullable
              as List<Subscription>,
      offlineSubs: null == offlineSubs
          ? _value._offlineSubs
          : offlineSubs // ignore: cast_nullable_to_non_nullable
              as List<OfflineSubscription>,
      isLoggedIn: freezed == isLoggedIn ? _value.isLoggedIn! : isLoggedIn,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ManageSubscriptionsStateImpl implements _ManageSubscriptionsState {
  const _$ManageSubscriptionsStateImpl(
      {final List<Subscription> subs = const [],
      final List<OfflineSubscription> offlineSubs = const [],
      this.isLoggedIn = false,
      this.loading = true})
      : _subs = subs,
        _offlineSubs = offlineSubs;

  final List<Subscription> _subs;
  @override
  @JsonKey()
  List<Subscription> get subs {
    if (_subs is EqualUnmodifiableListView) return _subs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subs);
  }

  final List<OfflineSubscription> _offlineSubs;
  @override
  @JsonKey()
  List<OfflineSubscription> get offlineSubs {
    if (_offlineSubs is EqualUnmodifiableListView) return _offlineSubs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_offlineSubs);
  }

  @override
  @JsonKey()
  final dynamic isLoggedIn;
  @override
  @JsonKey()
  final bool loading;

  @override
  String toString() {
    return 'ManageSubscriptionsState(subs: $subs, offlineSubs: $offlineSubs, isLoggedIn: $isLoggedIn, loading: $loading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ManageSubscriptionsStateImpl &&
            const DeepCollectionEquality().equals(other._subs, _subs) &&
            const DeepCollectionEquality()
                .equals(other._offlineSubs, _offlineSubs) &&
            const DeepCollectionEquality()
                .equals(other.isLoggedIn, isLoggedIn) &&
            (identical(other.loading, loading) || other.loading == loading));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_subs),
      const DeepCollectionEquality().hash(_offlineSubs),
      const DeepCollectionEquality().hash(isLoggedIn),
      loading);

  /// Create a copy of ManageSubscriptionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ManageSubscriptionsStateImplCopyWith<_$ManageSubscriptionsStateImpl>
      get copyWith => __$$ManageSubscriptionsStateImplCopyWithImpl<
          _$ManageSubscriptionsStateImpl>(this, _$identity);
}

abstract class _ManageSubscriptionsState implements ManageSubscriptionsState {
  const factory _ManageSubscriptionsState(
      {final List<Subscription> subs,
      final List<OfflineSubscription> offlineSubs,
      final dynamic isLoggedIn,
      final bool loading}) = _$ManageSubscriptionsStateImpl;

  @override
  List<Subscription> get subs;
  @override
  List<OfflineSubscription> get offlineSubs;
  @override
  dynamic get isLoggedIn;
  @override
  bool get loading;

  /// Create a copy of ManageSubscriptionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ManageSubscriptionsStateImplCopyWith<_$ManageSubscriptionsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
