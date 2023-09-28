// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_accounts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchLocalAccountHash() => r'e9f8ea0dd15031cc8145532e9cac73ab7f0f81be';

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

/// See also [fetchLocalAccount].
@ProviderFor(fetchLocalAccount)
const fetchLocalAccountProvider = FetchLocalAccountFamily();

/// See also [fetchLocalAccount].
class FetchLocalAccountFamily extends Family<AsyncValue<LocalAccount?>> {
  /// See also [fetchLocalAccount].
  const FetchLocalAccountFamily();

  /// See also [fetchLocalAccount].
  FetchLocalAccountProvider call({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) {
    return FetchLocalAccountProvider(
      accountMasterRecordKey: accountMasterRecordKey,
    );
  }

  @override
  FetchLocalAccountProvider getProviderOverride(
    covariant FetchLocalAccountProvider provider,
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
  String? get name => r'fetchLocalAccountProvider';
}

/// See also [fetchLocalAccount].
class FetchLocalAccountProvider
    extends AutoDisposeFutureProvider<LocalAccount?> {
  /// See also [fetchLocalAccount].
  FetchLocalAccountProvider({
    required Typed<FixedEncodedString43> accountMasterRecordKey,
  }) : this._internal(
          (ref) => fetchLocalAccount(
            ref as FetchLocalAccountRef,
            accountMasterRecordKey: accountMasterRecordKey,
          ),
          from: fetchLocalAccountProvider,
          name: r'fetchLocalAccountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchLocalAccountHash,
          dependencies: FetchLocalAccountFamily._dependencies,
          allTransitiveDependencies:
              FetchLocalAccountFamily._allTransitiveDependencies,
          accountMasterRecordKey: accountMasterRecordKey,
        );

  FetchLocalAccountProvider._internal(
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
    FutureOr<LocalAccount?> Function(FetchLocalAccountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchLocalAccountProvider._internal(
        (ref) => create(ref as FetchLocalAccountRef),
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
  AutoDisposeFutureProviderElement<LocalAccount?> createElement() {
    return _FetchLocalAccountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchLocalAccountProvider &&
        other.accountMasterRecordKey == accountMasterRecordKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountMasterRecordKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FetchLocalAccountRef on AutoDisposeFutureProviderRef<LocalAccount?> {
  /// The parameter `accountMasterRecordKey` of this provider.
  Typed<FixedEncodedString43> get accountMasterRecordKey;
}

class _FetchLocalAccountProviderElement
    extends AutoDisposeFutureProviderElement<LocalAccount?>
    with FetchLocalAccountRef {
  _FetchLocalAccountProviderElement(super.provider);

  @override
  Typed<FixedEncodedString43> get accountMasterRecordKey =>
      (origin as FetchLocalAccountProvider).accountMasterRecordKey;
}

String _$localAccountsHash() => r'148d98fcd8a61147bb475708d50b9699887c5bec';

/// See also [LocalAccounts].
@ProviderFor(LocalAccounts)
final localAccountsProvider = AutoDisposeAsyncNotifierProvider<LocalAccounts,
    IList<LocalAccount>>.internal(
  LocalAccounts.new,
  name: r'localAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocalAccounts = AutoDisposeAsyncNotifier<IList<LocalAccount>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
