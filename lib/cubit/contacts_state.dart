// Copyright 2024 Lukas Grossberger
part of 'contacts_cubit.dart';

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
  factory CoagContact.fromJson(Map<String, dynamic> json) =>
      _$CoagContactFromJson(json);
  // TODO: Add constructor with everything, but remove sharing profile here to allow for default value
  CoagContact(
      {required this.contact,
      this.dhtUpdateStatus,
      this.peerRecord,
      this.myRecord,
      this.lng,
      this.lat,
      this.sharingProfile});

  // System contact copy
  final Contact contact;

  final DhtUpdateStatus? dhtUpdateStatus;

  // DHT record where peer shares updates with me
  final PeerDHTRecord? peerRecord;
  // DHT record where I share updates with peer
  final MyDHTRecord? myRecord;

  // Location coordinates longitude and latitude
  final num? lng;
  final num? lat;

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
          DhtUpdateStatus? dhtUpdateStatus,
          num? lng,
          num? lat,
          PeerDHTRecord? peerRecord,
          MyDHTRecord? myRecord,
          String? sharingProfile}) =>
      CoagContact(
          contact: (contact != null) ? contact : this.contact,
          dhtUpdateStatus: (dhtUpdateStatus != null)
              ? dhtUpdateStatus
              : this.dhtUpdateStatus,
          lng: (lng != null) ? lng : this.lng,
          lat: (lat != null) ? lat : this.lat,
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
