// Copyright 2024 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

Widget avatar(Contact? contact,
    {double radius = 48.0, IconData defaultIcon = Icons.person}) {
  if (contact?.photoOrThumbnail != null) {
    return CircleAvatar(
      backgroundImage: MemoryImage(contact!.photoOrThumbnail!),
      radius: radius,
    );
  }
  return CircleAvatar(radius: radius, child: Icon(defaultIcon));
}
