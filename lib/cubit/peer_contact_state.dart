// Copyright 2024 Lukas Grossberger
part of 'peer_contact_cubit.dart';

// class PeerDHTRecord {
//   PeerDHTRecord({required this.key, this.writer, this.psk, this.pubKey});

//   final String key;
//   // Optional writer keypair in case I shared first and offered a DHT record for
//   // my peer to share back
//   final KeyPair? writer;
//   // Optional pre-shared secret in case I shared first and did not yet have
//   // their public key
//   final String? psk;
//   // Optional peer public key in case they share it; superseeds the psk
//   final String? pubKey;
//   // TODO: Reconsile pubKey and writer somehow so that only one is needed?
// }

// class MyDHTRecord {
//   MyDHTRecord({required this.key, required this.writer, this.psk});

//   final String key;
//   final KeyPair writer;
//   final String? psk;
// }

@JsonSerializable()
class PeerContact {
  PeerContact({required this.contact});

  // System contact copy
  final Contact contact;
  // DHT record where peer shares updates with me
  // final PeerDHTRecord? peerRecord;
  // DHT record where I share updates with peer
  // final MyDHTRecord? myRecord;

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

  PeerContact copyWith({required Contact contact}) => PeerContact(contact:contact);

  factory PeerContact.fromJson(Map<String, dynamic> json) =>
      _$PeerContactFromJson(json);

  Map<String, dynamic> toJson() => _$PeerContactToJson(this);
}

enum PeerContactStatus { initial, success, denied }

extension PeerContactStatusX on PeerContactStatus {
  bool get isInitial => this == PeerContactStatus.initial;
  bool get isSuccess => this == PeerContactStatus.success;
  bool get isDenied => this == PeerContactStatus.denied;
}

@JsonSerializable()
final class PeerContactState extends Equatable {
  const PeerContactState(this.contacts, this.status);

  factory PeerContactState.fromJson(Map<String, dynamic> json) =>
      _$PeerContactStateFromJson(json);

  final Map<String, PeerContact> contacts;
  final PeerContactStatus status;

  Map<String, dynamic> toJson() => _$PeerContactStateToJson(this);

  @override
  List<Object?> get props => [contacts];
}
