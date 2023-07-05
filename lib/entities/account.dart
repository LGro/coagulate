import 'package:flutter/widgets.dart';
import 'profile.dart';
import 'identity.dart';

@immutable
class Account {
  final Profile profile;
  final Identity identity;

  const Account({required this.profile, required this.identity});

  Account copyWith({Profile? profile, Identity? identity}) {
    return Account(
      profile: profile ?? this.profile,
      identity: identity ?? this.identity,
    );
  }

  Account.fromJson(Map<String, dynamic> json)
      : profile = Profile.fromJson(json['profile']),
        identity = Identity.fromJson(json['identity']);

  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
      'identity': identity.toJson(),
    };
  }
}
