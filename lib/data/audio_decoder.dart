import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';

class DecodeStep {
  final String char;
  final double freq;
  final int matchedFreq;
  final List<double> spectrum;
  DecodeStep(this.char, this.freq, this.matchedFreq, this.spectrum);
}

class AudioDecoder {
  final Map<int, String> freqToChar = {
    440: "A", 350: "B", 260: "C", 474: "D", 492: "E",
    401: "F", 584: "G", 553: "H", 582: "I", 525: "J",
    501: "K", 532: "L", 594: "M", 599: "N", 528: "O",
    539: "P", 675: "Q", 683: "R", 698: "S", 631: "T",
    628: "U", 611: "V", 622: "W", 677: "X", 688: "Y",
    693: "Z", 418: " "
  };

  /// Returns a stream of decoding steps, one per letter
  Stream<DecodeStep> decodeStream(String filePath) async* {
    ByteData data = await rootBundle.load(filePath);
    Uint8List bytes = data.buffer.asUint8List();

    final pcmData = bytes.sublist(44);
    final samples = Int16List.view(pcmData.buffer);

    int sampleRate = bytes.buffer.asByteData().getUint32(24, Endian.little);
    int samplesPerLetter = (sampleRate * 0.3).round();

    for (int i = 0; i + samplesPerLetter <= samples.length; i += samplesPerLetter) {
      var window = samples.sublist(i, i + samplesPerLetter);

      // Convert to SciDart Array
      Array windowArray = Array(window.map((e) => e.toDouble()).toList());

      int fftSize = 4096;
      if (windowArray.length > fftSize) {
        windowArray = Array(windowArray.sublist(0, fftSize));
      } else if (windowArray.length < fftSize) {
        final padding = List<double>.filled(fftSize - windowArray.length, 0.0);
        windowArray = Array([...windowArray, ...padding]);
      }

      // Run FFT
      ArrayComplex spectrum = rfft(windowArray);

      // Magnitudes
      Array magnitudes = arrayComplexAbs(spectrum);

      // Peak index
      int peakIndex = arrayArgMax(magnitudes);
      double freq = peakIndex * (sampleRate / fftSize);

      // Match to nearest dictionary frequency
      int matchedFreq = freqToChar.keys.reduce((a, b) =>
      (freq - a).abs() < (freq - b).abs() ? a : b);

      String char = freqToChar[matchedFreq] ?? "?";

      // Convert spectrum to normal List<double> for Flutter graph
      List<double> specList = magnitudes.sublist(0, 200).toList();

      yield DecodeStep(char, freq, matchedFreq, specList);
    }
  }
}
