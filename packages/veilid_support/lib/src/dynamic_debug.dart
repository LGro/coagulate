import 'package:async_tools/async_tools.dart';
import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';
import 'package:convert/convert.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'online_element_state.dart';

typedef ToDebugFunction = dynamic Function(dynamic protoObj);

// This should be implemented to add toDebug capability
// ignore: one_member_abstracts
abstract class ToDebugMap {
  Map<String, dynamic> toDebugMap();
}

// We explicitly want this class to avoid having a global function 'toDebug'
// ignore: avoid_classes_with_only_static_members
class DynamicDebug {
  /// Add a 'toDebug' handler to the chain
  static void registerToDebug(ToDebugFunction toDebugFunction) {
    final _oldToDebug = _toDebug;
    _toDebug = (obj) => _oldToDebug(toDebugFunction(obj));
  }

  /// Convert a type to a debug version of the same type that
  /// has a better `toString` representation and possibly other extra debug
  /// information
  static dynamic toDebug(dynamic obj) {
    try {
      return _toDebug(obj);
      // In this case we watch to catch everything
      // because toDebug need to never fail
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      // Ensure this gets printed, but continue
      // ignore: avoid_print
      print('Exception in toDebug: $e');
      return obj.toString();
    }
  }

  //////////////////////////////////////////////////////////////
  static dynamic _baseToDebug(dynamic obj) {
    if (obj is AsyncValue<dynamic>) {
      if (obj.isLoading) {
        return {r'$runtimeType': obj.runtimeType, 'loading': null};
      }
      if (obj.isError) {
        return {
          r'$runtimeType': obj.runtimeType,
          'error': toDebug(obj.asError!.error),
          'stackTrace': toDebug(obj.asError!.stackTrace),
        };
      }
      if (obj.isData) {
        return {
          r'$runtimeType': obj.runtimeType,
          'data': toDebug(obj.asData!.value),
        };
      }
      return obj.toString();
    }
    if (obj is IMap<dynamic, dynamic>) {
      // Handled by Map
      return _baseToDebug(obj.unlockView);
    }
    if (obj is IMapOfSets<dynamic, dynamic>) {
      // Handled by Map
      return _baseToDebug(obj.unlock);
    }
    if (obj is ISet<dynamic>) {
      // Handled by Iterable
      return _baseToDebug(obj.unlockView);
    }
    if (obj is IList<dynamic>) {
      return _baseToDebug(obj.unlockView);
    }
    if (obj is BlocBusyState<dynamic>) {
      return {
        r'$runtimeType': obj.runtimeType,
        'busy': obj.busy,
        'state': toDebug(obj.state),
      };
    }
    if (obj is OnlineElementState<dynamic>) {
      return {
        r'$runtimeType': obj.runtimeType,
        'isOffline': obj.isOffline,
        'value': toDebug(obj.value),
      };
    }
    if (obj is List<int>) {
      try {
        // Do bytes as a hex string for brevity and clarity
        return 'List<int>: ${hex.encode(obj)}';
        // One has to be able to catch this
        // ignore: avoid_catching_errors
      } on RangeError {
        // Otherwise directly convert as list of integers
        return obj.toString();
      }
    }
    if (obj is Map<dynamic, dynamic>) {
      return obj.map((k, v) => MapEntry(toDebug(k), toDebug(v)));
    }
    if (obj is Iterable<dynamic>) {
      return obj.map(toDebug).toList();
    }
    if (obj is String || obj is bool || obj is num || obj == null) {
      return obj;
    }
    if (obj is ToDebugMap) {
      // Handled by Map
      return _baseToDebug(obj.toDebugMap());
    }

    try {
      // Let's try convering to a json object
      // ignore: avoid_dynamic_calls
      return obj.toJson();

      // No matter how this fails, we shouldn't throw
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}

    return obj.toString();
  }

  static ToDebugFunction _toDebug = _baseToDebug;
}
