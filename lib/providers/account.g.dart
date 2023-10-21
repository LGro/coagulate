// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchAccountHash() => r'f3072fdd89611b53cd9821613acab450b3c08820';

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

/// Get an account from the identity key and if it is logged in and we
/// have its secret available, return the account record contents
///
/// Copied from [fetchAccount].
@ProviderFor(fetchAccount)
const fetchAccountProvider = FetchAccountFamily();

/// Get an account from the identity key and if it is logged in and we
/// have its secret available, return the account record contents
///
/// Copied from [fetchAccount].
class FetchAccountFamily extends Family<AsyncValue<AccountInfo>> {
  /// Get an account from the identity key and if it is logged in and we
  /// have its secret available, return the account record contents
  ///
  /// Copied from [fetchAccount].
  const FetchAccountFamily();

  /// Get an account from the identity key and if it is logged in and we
  /// have its secret available, return the account record contents
  ///
  /// Copied from [fetchAccount].
  FetchAccountProvider call({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) {
    return FetchAccountProvider(
      accountMasterRecordKey: accountMasterRecordKey,
    );
  }

  @override
  FetchAccountProvider getProviderOverride(
    covariant FetchAccountProvider provider,
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
  String? get name => r'fetchAccountProvider';
}

/// Get an account from the identity key and if it is logged in and we
/// have its secret available, return the account record contents
///
/// Copied from [fetchAccount].
class FetchAccountProvider extends AutoDisposeFutureProvider<AccountInfo> {
  /// Get an account from the identity key and if it is logged in and we
  /// have its secret available, return the account record contents
  ///
  /// Copied from [fetchAccount].
  FetchAccountProvider({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) : this._internal(
          (ref) => fetchAccount(
            ref as FetchAccountRef,
            accountMasterRecordKey: accountMasterRecordKey,
          ),
          from: fetchAccountProvider,
          name: r'fetchAccountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchAccountHash,
          dependencies: FetchAccountFamily._dependencies,
          allTransitiveDependencies:
              FetchAccountFamily._allTransitiveDependencies,
          accountMasterRecordKey: accountMasterRecordKey,
        );

  FetchAccountProvider._internal(
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
    FutureOr<AccountInfo> Function(FetchAccountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchAccountProvider._internal(
        (ref) => create(ref as FetchAccountRef),
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
  AutoDisposeFutureProviderElement<AccountInfo> createElement() {
    return _FetchAccountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchAccountProvider &&
        other.accountMasterRecordKey == accountMasterRecordKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountMasterRecordKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FetchAccountRef on AutoDisposeFutureProviderRef<AccountInfo> {
  /// The parameter `accountMasterRecordKey` of this provider.
  Typed<FixedEncodedString43> get accountMasterRecordKey;
}

class _FetchAccountProviderElement
    extends AutoDisposeFutureProviderElement<AccountInfo> with FetchAccountRef {
  _FetchAccountProviderElement(super.provider);

  @override
  Typed<FixedEncodedString43> get accountMasterRecordKey =>
      (origin as FetchAccountProvider).accountMasterRecordKey;
}

String _$fetchActiveAccountHash() =>
    r'197e5dd793563ff1d9927309a5ec9db1c9f67f07';

/// Get the active account info
///
/// Copied from [fetchActiveAccount].
@ProviderFor(fetchActiveAccount)
final fetchActiveAccountProvider =
    AutoDisposeFutureProvider<ActiveAccountInfo?>.internal(
  fetchActiveAccount,
  name: r'fetchActiveAccountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchActiveAccountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchActiveAccountRef
    = AutoDisposeFutureProviderRef<ActiveAccountInfo?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
