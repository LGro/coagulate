import 'package:bloc_advanced_tools/bloc_advanced_tools.dart';

import '../models/models.dart';
import '../repository/processor_repository.dart';

export '../models/processor_connection_state.dart';

class ConnectionStateCubit
    extends StreamWrapperCubit<ProcessorConnectionState> {
  ConnectionStateCubit(ProcessorRepository processorRepository)
      : super(processorRepository.streamProcessorConnectionState(),
            defaultState: processorRepository.processorConnectionState);
}
