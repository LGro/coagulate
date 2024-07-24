import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../veilid_support.dart';

part 'super_identity.freezed.dart';
part 'super_identity.g.dart';

/// SuperIdentity key structure for created account
///
/// SuperIdentity key allows for regeneration of identity DHT record
/// Bidirectional Super<->Instance signature allows for
/// chain of identity ownership for account recovery process
///
/// Backed by a DHT key at superRecordKey, the secret is kept
/// completely offline and only written to upon account recovery
///
/// DHT Schema: DFLT(1)
/// DHT Record Key (Public): SuperIdentity.recordKey
/// DHT Owner Key: SuperIdentity.publicKey
/// DHT Owner Secret: SuperIdentity Secret Key (kept offline)
/// Encryption: None
@freezed
class SuperIdentity with _$SuperIdentity {
  const factory SuperIdentity({
    /// Public DHT record storing this structure for account recovery
    /// changing this can migrate/forward the SuperIdentity to a new DHT record
    /// Instances should not hash this recordKey, rather the actual record
    /// key used to store the superIdentity, as this may change.
    required TypedKey recordKey,

    /// Public key of the SuperIdentity used to sign identity keys for recovery
    /// This must match the owner of the superRecord DHT record and can not be
    /// changed without changing the record
    required PublicKey publicKey,

    /// Current identity instance
    /// The most recently generated identity instance for this SuperIdentity
    required IdentityInstance currentInstance,

    /// Deprecated identity instances
    /// These may be compromised and should not be considered valid for
    /// new signatures, but may be used to validate old signatures
    required List<IdentityInstance> deprecatedInstances,

    /// Deprecated superRecords
    /// These may be compromised and should not be considered valid for
    /// new signatures, but may be used to validate old signatures
    required List<TypedKey> deprecatedSuperRecordKeys,

    /// Signature of recordKey, currentInstance signature,
    /// signatures of deprecatedInstances, and deprecatedSuperRecordKeys
    /// by publicKey
    required Signature signature,
  }) = _SuperIdentity;

  ////////////////////////////////////////////////////////////////////////////
  // Constructors

  factory SuperIdentity.fromJson(dynamic json) =>
      _$SuperIdentityFromJson(json as Map<String, dynamic>);

  const SuperIdentity._();

  /// Opens an existing super identity and validates it
  static Future<SuperIdentity> open({required TypedKey superRecordKey}) async {
    final pool = DHTRecordPool.instance;

    // SuperIdentity DHT record is public/unencrypted
    return (await pool.openRecordRead(superRecordKey,
            debugName: 'SuperIdentity::openSuperIdentity::SuperIdentityRecord'))
        .deleteScope((superRec) async {
      final superIdentity = (await superRec.getJson(SuperIdentity.fromJson,
          refreshMode: DHTRecordRefreshMode.network))!;

      // Validate current IdentityInstance
      if (!await superIdentity.currentInstance.validateIdentityInstance(
          superRecordKey: superRecordKey,
          superPublicKey: superIdentity.publicKey)) {
        // Invalid current IdentityInstance signature(s)
        throw IdentityException.invalid;
      }

      // Validate deprecated IdentityInstances
      for (final deprecatedInstance in superIdentity.deprecatedInstances) {
        if (!await deprecatedInstance.validateIdentityInstance(
            superRecordKey: superRecordKey,
            superPublicKey: superIdentity.publicKey)) {
          // Invalid deprecated IdentityInstance signature(s)
          throw IdentityException.invalid;
        }
      }

      // Validate SuperIdentity
      final deprecatedInstancesSignatures =
          superIdentity.deprecatedInstances.map((x) => x.signature).toList();
      if (!await _validateSuperIdentitySignature(
          recordKey: superIdentity.recordKey,
          currentInstanceSignature: superIdentity.currentInstance.signature,
          deprecatedInstancesSignatures: deprecatedInstancesSignatures,
          deprecatedSuperRecordKeys: superIdentity.deprecatedSuperRecordKeys,
          publicKey: superIdentity.publicKey,
          signature: superIdentity.signature)) {
        // Invalid SuperIdentity signature
        throw IdentityException.invalid;
      }

      return superIdentity;
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // Public Interface

  /// Deletes a super identity and the identity instance records under it
  /// Only deletes from the local machine not the DHT
  Future<void> delete() async {
    final pool = DHTRecordPool.instance;
    await pool.deleteRecord(recordKey);
  }

  Future<VeilidCryptoSystem> get cryptoSystem =>
      Veilid.instance.getCryptoSystem(recordKey.kind);

  KeyPair writer(SecretKey secretKey) =>
      KeyPair(key: publicKey, secret: secretKey);

  TypedKey get typedPublicKey =>
      TypedKey(kind: recordKey.kind, value: publicKey);

  Future<VeilidCryptoSystem> validateSecret(SecretKey secretKey) async {
    final cs = await cryptoSystem;
    final keyOk = await cs.validateKeyPair(publicKey, secretKey);
    if (!keyOk) {
      throw IdentityException.invalid;
    }
    return cs;
  }

  ////////////////////////////////////////////////////////////////////////////
  // Internal implementation

  static Uint8List signatureBytes({
    required TypedKey recordKey,
    required Signature currentInstanceSignature,
    required List<Signature> deprecatedInstancesSignatures,
    required List<TypedKey> deprecatedSuperRecordKeys,
  }) {
    final sigBuf = BytesBuilder()
      ..add(recordKey.decode())
      ..add(currentInstanceSignature.decode())
      ..add(deprecatedInstancesSignatures.expand((s) => s.decode()).toList())
      ..add(deprecatedSuperRecordKeys.expand((s) => s.decode()).toList());
    return sigBuf.toBytes();
  }

  static Future<bool> _validateSuperIdentitySignature({
    required TypedKey recordKey,
    required Signature currentInstanceSignature,
    required List<Signature> deprecatedInstancesSignatures,
    required List<TypedKey> deprecatedSuperRecordKeys,
    required PublicKey publicKey,
    required Signature signature,
  }) async {
    final cs = await Veilid.instance.getCryptoSystem(recordKey.kind);
    final sigBytes = SuperIdentity.signatureBytes(
        recordKey: recordKey,
        currentInstanceSignature: currentInstanceSignature,
        deprecatedInstancesSignatures: deprecatedInstancesSignatures,
        deprecatedSuperRecordKeys: deprecatedSuperRecordKeys);
    return cs.verify(publicKey, sigBytes, signature);
  }
}
