import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../veilid_support/veilid_support.dart';

part 'veilid_instance.g.dart';

// Expose the Veilid instance as a FutureProvider
@riverpod
FutureOr<Veilid> veilidInstance(VeilidInstanceRef ref) async =>
    await eventualVeilid.future;
