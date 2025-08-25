import '../entities/decoded_message.dart';

abstract class DecodeAudioMessage {
  Future<DecodedMessage> call(String filePath);
}
