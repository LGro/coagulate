class Contact {
  String name;
  String publicKey;
  bool available;

  Contact(this.name, this.publicKey) : available = false;

  Contact.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        publicKey = json['public_key'],
        available = json['available'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'public_key': publicKey,
      'available': available,
    };
  }
}
