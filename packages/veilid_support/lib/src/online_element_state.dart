import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class OnlineElementState<T> extends Equatable {
  const OnlineElementState({required this.value, required this.isOffline});
  final T value;
  final bool isOffline;

  @override
  List<Object?> get props => [value, isOffline];
}
