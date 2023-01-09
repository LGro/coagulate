import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'loggy.dart';

class StateLogger extends ProviderObserver {
  const StateLogger();
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    log.debug('''{
  provider: ${provider.name ?? provider.runtimeType},
  oldValue: $previousValue,
  newValue: $newValue
}
''');
    super.didUpdateProvider(provider, previousValue, newValue, container);
  }
}
