import '../../../domain/entities/decoded_message.dart';

abstract class DecodeState {}

class DecodeInitial extends DecodeState {}

class DecodeLoading extends DecodeState {}

class DecodeSuccess extends DecodeState {
  final DecodedMessage message;
  DecodeSuccess(this.message);
}

class DecodeError extends DecodeState {
  final String error;
  DecodeError(this.error);
}
