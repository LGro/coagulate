// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchAccountHash() => r'88dadc0d005cef8b3df1d03088c8a5da728c333c';

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

typedef FetchAccountRef = AutoDisposeFutureProviderRef<AccountInfo>;

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
    required this.accountMasterRecordKey,
  }) : super.internal(
          (ref) => fetchAccount(
            ref,
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
        );

  final Typed<FixedEncodedString43> accountMasterRecordKey;

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

String _$fetchActiveAccountHash() =>
    r'8c7e571c135deeb5cacf56c61459d71f7447baaf';

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
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
