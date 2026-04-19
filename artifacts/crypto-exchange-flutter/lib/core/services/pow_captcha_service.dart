import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Proof-of-Work CAPTCHA Service
/// Solves computational puzzles to prevent bot registrations
class PowCaptchaService {
  static const String _tag = 'POW_CAPTCHA';

  /// Solve a PoW challenge
  /// Returns a solution with nonce and hash
  static Future<PowSolution> solvePowChallenge({
    required String challenge,
    required int difficulty,
  }) async {
    dev.log('$_tag: Starting PoW challenge solving (difficulty: $difficulty)');
    final startTime = DateTime.now();

    int nonce = 0;
    String hash = '';
    bool solved = false;

    // Solve the puzzle by finding a nonce that produces a hash
    // with the required number of leading zero bits
    while (!solved) {
      final dataToHash = '$challenge:$nonce';
      hash = _computeSha256(dataToHash);

      if (_meetsDifficulty(hash, difficulty)) {
        solved = true;
        dev.log('$_tag: Solution found! Nonce: $nonce');
      } else {
        nonce++;
      }

      // Safety check: don't run forever
      if (nonce > 10000000) {
        throw Exception('PoW challenge too difficult to solve');
      }
    }

    final duration = DateTime.now().difference(startTime);
    dev.log('$_tag: Challenge solved in ${duration.inMilliseconds}ms with nonce: $nonce');

    return PowSolution(
      challenge: challenge,
      nonce: nonce,
      hash: hash,
    );
  }

  /// Compute SHA-256 hash
  static String _computeSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if hash meets difficulty requirement
  /// Difficulty is the number of leading zero bits required
  static bool _meetsDifficulty(String hash, int difficulty) {
    final binaryHash = _hexToBinary(hash);
    final leadingZeros = _countLeadingZeros(binaryHash);
    return leadingZeros >= difficulty;
  }

  /// Convert hex string to binary string
  static String _hexToBinary(String hex) {
    return hex.split('').map((char) {
      final value = int.parse(char, radix: 16);
      return value.toRadixString(2).padLeft(4, '0');
    }).join('');
  }

  /// Count leading zeros in binary string
  static int _countLeadingZeros(String binary) {
    int count = 0;
    for (int i = 0; i < binary.length; i++) {
      if (binary[i] == '0') {
        count++;
      } else {
        break;
      }
    }
    return count;
  }
}

/// PoW Solution model
class PowSolution {
  final String challenge;
  final int nonce;
  final String hash;

  PowSolution({
    required this.challenge,
    required this.nonce,
    required this.hash,
  });

  Map<String, dynamic> toJson() => {
        'challenge': challenge,
        'nonce': nonce,
        'hash': hash,
      };
}

/// PoW Challenge model
class PowChallenge {
  final String challenge;
  final int difficulty;
  final int timestamp;
  final int expiresIn;

  PowChallenge({
    required this.challenge,
    required this.difficulty,
    required this.timestamp,
    required this.expiresIn,
  });

  factory PowChallenge.fromJson(Map<String, dynamic> json) {
    return PowChallenge(
      challenge: json['challenge'] as String,
      difficulty: json['difficulty'] as int,
      timestamp: json['timestamp'] as int,
      expiresIn: json['expiresIn'] as int,
    );
  }
}
