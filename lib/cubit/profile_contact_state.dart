// Copyright 2024 Lukas Grossberger
part of 'profile_contact_cubit.dart';

enum ProfileContactStatus { initial, success, create, pick }

extension ProfileContactStatusX on ProfileContactStatus {
  bool get isInitial => this == ProfileContactStatus.initial;
  bool get isSuccess => this == ProfileContactStatus.success;
  bool get isCreate => this == ProfileContactStatus.create;
  bool get isPick => this == ProfileContactStatus.pick;
}

@JsonSerializable()
final class ProfileContactState extends Equatable {
  ProfileContactState({
    this.status = ProfileContactStatus.initial,
    this.profileContact,
  });

  factory ProfileContactState.fromJson(Map<String, dynamic> json) =>
      _$ProfileContactStateFromJson(json);

  final ProfileContactStatus status;
  final Contact? profileContact;

  ProfileContactState copyWith(
          {ProfileContactStatus? status, Contact? profileContact}) =>
      ProfileContactState(
        status: status ?? this.status,
        profileContact: profileContact ?? this.profileContact,
      );

  Map<String, dynamic> toJson() => _$ProfileContactStateToJson(this);

  @override
  List<Object?> get props => [status, profileContact];
}
