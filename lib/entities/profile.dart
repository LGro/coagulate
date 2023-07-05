import 'package:flutter/widgets.dart';
import 'package:veilid/veilid.dart';

@immutable
class Profile {
  final String name;
  final TypedKey publicKey;
  final bool invisible;

  const Profile(
      {required this.name, required this.publicKey, required this.invisible});

  // Todo with slightly different content.
  Profile copyWith({String? name, TypedKey? publicKey, bool? invisible}) {
    return Profile(
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      invisible: invisible ?? this.invisible,
    );
  }

  Profile.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        publicKey = TypedKey.fromJson(json['public_key']),
        invisible = json['invisible'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'public_key': publicKey.toJson(),
      'invisible': invisible,
    };
  }
}
