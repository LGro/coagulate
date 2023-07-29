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

typedef FetchLoginRef = AutoDisposeFutureProviderRef<UserLogin?>;

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
    required this.accountMasterRecordKey,
  }) : super.internal(
          (ref) => fetchLogin(
            ref,
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
        );

  final Typed<FixedEncodedString43> accountMasterRecordKey;

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

String _$loginsHash() => r'ed9dbe91a248f662ccb0fac6edf5b1892cf2ef92';

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
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
