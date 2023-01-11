class Profile {
  String name;
  String publicKey;
  bool invisible;

  Profile(this.name, this.publicKey) : invisible = false;

  Profile.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        publicKey = json['public_key'],
        invisible = json['invisible'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'public_key': publicKey,
      'invisible': invisible,
    };
  }
}
