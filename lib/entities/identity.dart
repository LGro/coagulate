import 'package:flutter/widgets.dart';
import 'package:veilid/veilid.dart';

@immutable
class Identity {
  final TypedKey identityPublicKey;
  final TypedKey masterPublicKey;
  final Signature identitySignature;
  final Signature masterSignature;

  const Identity(
      {required this.identityPublicKey,
      required this.masterPublicKey,
      required this.identitySignature,
      required this.masterSignature});

  // Todo with slightly different content.
  Identity copyWith(
      {TypedKey? identityPublicKey,
      TypedKey? masterPublicKey,
      Signature? identitySignature,
      Signature? masterSignature}) {
    return Identity(
      identityPublicKey: identityPublicKey ?? this.identityPublicKey,
      masterPublicKey: masterPublicKey ?? this.masterPublicKey,
      identitySignature: identitySignature ?? this.identitySignature,
      masterSignature: masterSignature ?? this.masterSignature,
    );
  }

  Identity.fromJson(Map<String, dynamic> json)
      : identityPublicKey = TypedKey.fromJson(json['identity_public_key']),
        masterPublicKey = TypedKey.fromJson(json['master_public_key']),
        identitySignature = Signature.fromJson(json['identity_signature']),
        masterSignature = Signature.fromJson(json['master_signature']);

  Map<String, dynamic> toJson() {
    return {
      'identity_public_key': identityPublicKey.toJson(),
      'master_public_key': masterPublicKey.toJson(),
      'identity_signature': identitySignature.toJson(),
      'master_signature': masterSignature.toJson(),
    };
  }
}
