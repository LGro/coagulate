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

typedef FetchLocalAccountRef = AutoDisposeFutureProviderRef<LocalAccount?>;

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
    required this.accountMasterRecordKey,
  }) : super.internal(
          (ref) => fetchLocalAccount(
            ref,
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
        );

  final Typed<FixedEncodedString43> accountMasterRecordKey;

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

String _$localAccountsHash() => r'a9a1e1765188556858ec982c9e99f780756ade1e';

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
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
