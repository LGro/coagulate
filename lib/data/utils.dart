// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'package:veilid_support/veilid_support.dart';

Future<TypedKeyPair> generateTypedKeyPairBest() async =>
    DHTRecordPool.instance.veilid.bestCryptoSystem().then((cs) => cs
        .generateKeyPair()
        .then((kp) => TypedKeyPair.fromKeyPair(cs.kind(), kp)));

Future<FixedEncodedString43> generateRandomSharedSecretBest() async =>
    Veilid.instance.bestCryptoSystem().then((cs) => cs.randomSharedSecret());
