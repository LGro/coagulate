import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../veilid_support/veilid_support.dart';
import 'identity.dart';

part 'user_login.freezed.dart';
part 'user_login.g.dart';

// Represents a currently logged in account
// User logins are stored in the user_logins tablestore table
// indexed by the accountMasterKey
@freezed
class UserLogin with _$UserLogin {
  const factory UserLogin({
    // Master record key for the user used to index the local accounts table
    required TypedKey accountMasterRecordKey,
    // The identity secret as unlocked from the local accounts table
    required TypedSecret identitySecret,
    // The account record key, owner key and secret pulled from the identity
    required AccountRecordInfo accountRecordInfo,

    // The time this login was most recently used
    required Timestamp lastActive,
  }) = _UserLogin;

  factory UserLogin.fromJson(dynamic json) =>
      _$UserLoginFromJson(json as Map<String, dynamic>);
}

// Represents a set of user logins
// and the currently selected account
@freezed
class ActiveLogins with _$ActiveLogins {
  const factory ActiveLogins({
    // The list of current logged in accounts
    required IList<UserLogin> userLogins,
    // The current selected account indexed by master record key
    TypedKey? activeUserLogin,
  }) = _ActiveLogins;

  factory ActiveLogins.empty() =>
      const ActiveLogins(userLogins: IListConst([]));

  factory ActiveLogins.fromJson(dynamic json) =>
      _$ActiveLoginsFromJson(json as Map<String, dynamic>);
}
