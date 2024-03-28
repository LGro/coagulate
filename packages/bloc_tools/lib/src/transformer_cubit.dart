import 'dart:async';

import 'package:bloc/bloc.dart';

class TransformerCubit<T, S> extends Cubit<T> {
  TransformerCubit(this.input, {required this.transform})
      : super(transform(input.state)) {
    _subscription = input.stream.listen((event) => emit(transform(event)));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await input.close();
    await super.close();
  }

  Cubit<S> input;
  T Function(S) transform;
  late final StreamSubscription<S> _subscription;
}
