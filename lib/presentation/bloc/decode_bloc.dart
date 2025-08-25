import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/decode_audio_message.dart';
import 'decode_event.dart';
import 'decode_state.dart';

class DecodeBloc extends Bloc<DecodeEvent, DecodeState> {
  final DecodeAudioMessage decoder;

  DecodeBloc(this.decoder) : super(DecodeInitial()) {
    on<StartDecoding>((event, emit) async {
      emit(DecodeLoading());
      try {
        final message = await decoder(event.filePath);
        emit(DecodeSuccess(message));
      } catch (e) {
        emit(DecodeError(e.toString()));
      }
    });
  }
}
