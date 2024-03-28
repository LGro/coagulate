import 'package:bloc/bloc.dart';

mixin BlocTools<State> on BlocBase<State> {
  void withStateListen(void Function(State event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    if (onData != null) {
      onData(state);
    }
    stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
