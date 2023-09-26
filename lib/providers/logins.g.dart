// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logins.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchLoginHash() => r'cfe13f5152f1275e6eccc698142abfd98170d9b9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [fetchLogin].
@ProviderFor(fetchLogin)
const fetchLoginProvider = FetchLoginFamily();

/// See also [fetchLogin].
class FetchLoginFamily extends Family<AsyncValue<UserLogin?>> {
  /// See also [fetchLogin].
  const FetchLoginFamily();

  /// See also [fetchLogin].
  FetchLoginProvider call({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) {
    return FetchLoginProvider(
      accountMasterRecordKey: accountMasterRecordKey,
    );
  }

  @override
  FetchLoginProvider getProviderOverride(
    covariant FetchLoginProvider provider,
  ) {
    return call(
      accountMasterRecordKey: provider.accountMasterRecordKey,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchLoginProvider';
}

/// See also [fetchLogin].
class FetchLoginProvider extends AutoDisposeFutureProvider<UserLogin?> {
  /// See also [fetchLogin].
  FetchLoginProvider({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) : this._internal(
          (ref) => fetchLogin(
            ref as FetchLoginRef,
            accountMasterRecordKey: accountMasterRecordKey,
          ),
          from: fetchLoginProvider,
          name: r'fetchLoginProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchLoginHash,
          dependencies: FetchLoginFamily._dependencies,
          allTransitiveDependencies:
              FetchLoginFamily._allTransitiveDependencies,
          accountMasterRecordKey: accountMasterRecordKey,
        );

  FetchLoginProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.accountMasterRecordKey,
  }) : super.internal();

  final Typed<FixedEncodedString43> accountMasterRecordKey;

  @override
  Override overrideWith(
    FutureOr<UserLogin?> Function(FetchLoginRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchLoginProvider._internal(
        (ref) => create(ref as FetchLoginRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        accountMasterRecordKey: accountMasterRecordKey,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserLogin?> createElement() {
    return _FetchLoginProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchLoginProvider &&
        other.accountMasterRecordKey == accountMasterRecordKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountMasterRecordKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FetchLoginRef on AutoDisposeFutureProviderRef<UserLogin?> {
  /// The parameter `accountMasterRecordKey` of this provider.
  Typed<FixedEncodedString43> get accountMasterRecordKey;
}

class _FetchLoginProviderElement
    extends AutoDisposeFutureProviderElement<UserLogin?> with FetchLoginRef {
  _FetchLoginProviderElement(super.provider);

  @override
  Typed<FixedEncodedString43> get accountMasterRecordKey =>
      (origin as FetchLoginProvider).accountMasterRecordKey;
}

String _$loginsHash() => r'41c4630869b474c409b2fb3461dd2a56d9350c7f';

/// See also [Logins].
@ProviderFor(Logins)
final loginsProvider =
    AutoDisposeAsyncNotifierProvider<Logins, ActiveLogins>.internal(
  Logins.new,
  name: r'loginsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loginsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Logins = AutoDisposeAsyncNotifier<ActiveLogins>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
