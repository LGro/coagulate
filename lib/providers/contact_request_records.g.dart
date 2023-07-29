// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_request_records.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchContactRequestRecordsHash() =>
    r'603c6d81b22d1cb4fd26cf32b98d3206ff6bc38c';

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

typedef FetchContactRequestRecordsRef
    = AutoDisposeFutureProviderRef<ContactRequestRecords?>;

/// See also [fetchContactRequestRecords].
@ProviderFor(fetchContactRequestRecords)
const fetchContactRequestRecordsProvider = FetchContactRequestRecordsFamily();

/// See also [fetchContactRequestRecords].
class FetchContactRequestRecordsFamily
    extends Family<AsyncValue<ContactRequestRecords?>> {
  /// See also [fetchContactRequestRecords].
  const FetchContactRequestRecordsFamily();

  /// See also [fetchContactRequestRecords].
  FetchContactRequestRecordsProvider call({
    required ContactRequestRecordsParams params,
  }) {
    return FetchContactRequestRecordsProvider(
      params: params,
    );
  }

  @override
  FetchContactRequestRecordsProvider getProviderOverride(
    covariant FetchContactRequestRecordsProvider provider,
  ) {
    return call(
      params: provider.params,
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
  String? get name => r'fetchContactRequestRecordsProvider';
}

/// See also [fetchContactRequestRecords].
class FetchContactRequestRecordsProvider
    extends AutoDisposeFutureProvider<ContactRequestRecords?> {
  /// See also [fetchContactRequestRecords].
  FetchContactRequestRecordsProvider({
    required this.params,
  }) : super.internal(
          (ref) => fetchContactRequestRecords(
            ref,
            params: params,
          ),
          from: fetchContactRequestRecordsProvider,
          name: r'fetchContactRequestRecordsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchContactRequestRecordsHash,
          dependencies: FetchContactRequestRecordsFamily._dependencies,
          allTransitiveDependencies:
              FetchContactRequestRecordsFamily._allTransitiveDependencies,
        );

  final ContactRequestRecordsParams params;

  @override
  bool operator ==(Object other) {
    return other is FetchContactRequestRecordsProvider &&
        other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
