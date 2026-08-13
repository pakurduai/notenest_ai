// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter, unnecessary_import
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Synthesizes a loud, crystal-clear 2-tone bell chime sound (E6 1318Hz -> B6 1975Hz)
/// on Flutter Web via dynamically synthesized 44.1kHz 16-bit PCM WAV Audio Element
void playWebBellChimeSynth() {
  try {
    final wavBytes = _generateBellWavBytes();
    final base64Wav = base64Encode(wavBytes);
    final audioDataUri = 'data:audio/wav;base64,$base64Wav';
    final audio = html.AudioElement(audioDataUri);
    audio.volume = 0.9;
    audio.play();
  } catch (e) {
    debugPrint('Web Audio Element Fallback Error: $e');
  }
}

/// Generates a valid 44.1kHz 16-bit PCM WAV byte array for a crystal bell chime
Uint8List _generateBellWavBytes() {
  const sampleRate = 44100;
  const durationSec = 0.6;
  final numSamples = (sampleRate * durationSec).toInt();
  const numChannels = 1;
  const bitsPerSample = 16;
  const bytesPerSample = bitsPerSample ~/ 8;
  final subchunk2Size = numSamples * numChannels * bytesPerSample;
  final chunkSize = 36 + subchunk2Size;

  final bd = ByteData(44 + subchunk2Size);

  // RIFF Header
  bd.setUint8(0, 0x52); // R
  bd.setUint8(1, 0x49); // I
  bd.setUint8(2, 0x46); // F
  bd.setUint8(3, 0x46); // F
  bd.setUint32(4, chunkSize, Endian.little);
  bd.setUint8(8, 0x57); // W
  bd.setUint8(9, 0x41); // A
  bd.setUint8(10, 0x56); // V
  bd.setUint8(11, 0x45); // E

  // fmt Subchunk
  bd.setUint8(12, 0x66); // f
  bd.setUint8(13, 0x6D); // m
  bd.setUint8(14, 0x74); // t
  bd.setUint8(15, 0x20); // ' '
  bd.setUint32(16, 16, Endian.little);
  bd.setUint16(20, 1, Endian.little); // PCM
  bd.setUint16(22, numChannels, Endian.little);
  bd.setUint32(24, sampleRate, Endian.little);
  bd.setUint32(28, sampleRate * numChannels * bytesPerSample, Endian.little);
  bd.setUint16(32, numChannels * bytesPerSample, Endian.little);
  bd.setUint16(34, bitsPerSample, Endian.little);

  // data Subchunk
  bd.setUint8(36, 0x64); // d
  bd.setUint8(37, 0x61); // a
  bd.setUint8(38, 0x74); // t
  bd.setUint8(39, 0x61); // a
  bd.setUint32(40, subchunk2Size, Endian.little);

  // PCM Sample Generation with E6 (1318Hz) & B6 (1975Hz) Bell Harmonics
  const freq1 = 1318.51;
  const freq2 = 1975.53;
  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final decay = math.exp(-7.0 * t);
    final sampleVal = (math.sin(2.0 * math.pi * freq1 * t) * 0.6 +
                       math.sin(2.0 * math.pi * freq2 * t) * 0.4) * decay;
    final int sample16 = (sampleVal * 32767.0).clamp(-32768.0, 32767.0).toInt();
    bd.setInt16(offset, sample16, Endian.little);
    offset += 2;
  }

  return bd.buffer.asUint8List();
}
