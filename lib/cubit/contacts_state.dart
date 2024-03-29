// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0
part of 'contacts_cubit.dart';

@JsonSerializable()
class CoagContactSchema {
  CoagContactSchema(
      {required this.contact,
      required this.addressCoordinates,
      this.publicKey,
      this.dhtKey,
      this.dhtWriter});
  final Contact contact;
  final Map<String, (num, num)> addressCoordinates;
  final String? publicKey;
  final String? dhtKey;
  final String? dhtWriter;

  factory CoagContactSchema.fromJson(Map<String, dynamic> json) =>
      _$CoagContactSchemaFromJson(json);

  Map<String, dynamic> toJson() => _$CoagContactSchemaToJson(this);
}

@JsonSerializable()
class PeerDHTRecord {
  PeerDHTRecord({required this.key, this.writer, this.psk, this.pubKey});

  final String key;
  // Optional writer keypair in case I shared first and offered a DHT record for
  // my peer to share back
  final String? writer;
  // Optional pre-shared secret in case I shared first and did not yet have
  // their public key
  final String? psk;
  // Optional peer public key in case they share it; superseeds the psk
  final String? pubKey;
  // TODO: Reconsile pubKey and writer somehow so that only one is needed?

  factory PeerDHTRecord.fromJson(Map<String, dynamic> json) =>
      _$PeerDHTRecordFromJson(json);

  Map<String, dynamic> toJson() => _$PeerDHTRecordToJson(this);
}

@JsonSerializable()
class MyDHTRecord {
  MyDHTRecord({required this.key, required this.writer, this.psk});

  final String key;
  final String writer;
  // TODO: Use higher level veilid types?
  // final DHTRecordDescriptor record;
  final String? psk;

  factory MyDHTRecord.fromJson(Map<String, dynamic> json) =>
      _$MyDHTRecordFromJson(json);

  Map<String, dynamic> toJson() => _$MyDHTRecordToJson(this);
}

enum DhtUpdateStatus { progress, success, failure }

extension DhtUpdateStatusX on DhtUpdateStatus {
  bool get isProgress => this == DhtUpdateStatus.progress;
  bool get isAttempting => this == DhtUpdateStatus.success;
  bool get isCoagulated => this == DhtUpdateStatus.failure;
}

// TODO: Add state to allow displaying loading while coagulating indicator
@JsonSerializable()
class CoagContact {
  // TODO: Add constructor with everything, but remove sharing profile here to allow for default value
  CoagContact(
      {required this.contact,
      required this.addressCoordinates,
      this.dhtUpdateStatus,
      this.peerRecord,
      this.myRecord,
      this.sharingProfile});

  factory CoagContact.fromJson(Map<String, dynamic> json) =>
      _$CoagContactFromJson(json);

  // System contact copy
  final Contact contact;

  // Location coordinates longitude and latitude for each address in contact
  final Map<String, (double, double)> addressCoordinates;

  final DhtUpdateStatus? dhtUpdateStatus;

  // DHT record where peer shares updates with me
  final PeerDHTRecord? peerRecord;
  // DHT record where I share updates with peer
  final MyDHTRecord? myRecord;

  final String? sharingProfile;

  // TODO: Add missing fields
  // - last update recieved -> when I've received the last update from the DHT (use dhtwatchvalue)
  //   - date
  //   - content version
  //   - + all shared fields with values
  // - shared fields[] -> all fields of my profile that I've shared
  // - last update sent -> when I've sent the last update of my info
  //   - date
  //   - content version
  //   - + all shared fields with values

  CoagContact copyWith(
          {Contact? contact,
          Map<String, (double, double)>? addressCoordinates,
          DhtUpdateStatus? dhtUpdateStatus,
          PeerDHTRecord? peerRecord,
          MyDHTRecord? myRecord,
          String? sharingProfile}) =>
      CoagContact(
          contact: (contact != null) ? contact : this.contact,
          addressCoordinates: (addressCoordinates != null)
              ? addressCoordinates
              : this.addressCoordinates,
          dhtUpdateStatus: (dhtUpdateStatus != null)
              ? dhtUpdateStatus
              : this.dhtUpdateStatus,
          peerRecord: (peerRecord != null) ? peerRecord : this.peerRecord,
          myRecord: (myRecord != null) ? myRecord : this.myRecord,
          sharingProfile:
              (sharingProfile != null) ? sharingProfile : this.sharingProfile);

  Map<String, dynamic> toJson() => _$CoagContactToJson(this);
}

enum CoagContactStatus { initial, success, denied }

extension CoagContactStatusX on CoagContactStatus {
  bool get isInitial => this == CoagContactStatus.initial;
  bool get isSuccess => this == CoagContactStatus.success;
  bool get isDenied => this == CoagContactStatus.denied;
}

@JsonSerializable()
final class CoagContactState extends Equatable {
  const CoagContactState(this.contacts, this.status);

  factory CoagContactState.fromJson(Map<String, dynamic> json) =>
      _$CoagContactStateFromJson(json);

  final Map<String, CoagContact> contacts;
  final CoagContactStatus status;

  Map<String, dynamic> toJson() => _$CoagContactStateToJson(this);

  @override
  List<Object?> get props => [contacts, status];
}
