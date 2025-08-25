abstract class DecodeEvent {}

class StartDecoding extends DecodeEvent {
  final String filePath;
  StartDecoding(this.filePath);
}
