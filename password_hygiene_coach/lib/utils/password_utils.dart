import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';

Random _secureRandom() {
  try {
    return Random.secure();
  } on UnsupportedError catch (e) {
    throw UnsupportedError('Secure RNG unavailable on this platform: $e');
  }
}

// Entropy calculation (Strength meter logic)
class PasswordStrength {
  // Calculate the estimated cryptographic entropy in bits.
  // Entropy = L * log2(N), where L is length and R is character pool size.
  static double calculateEntropy(String password) {
    if (password.isEmpty) return 0.0;

    final int length = password.length;

    // Estimate the size of the character pool (R) used in the password.
    int poolSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += Charsets.lowercase.length;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += Charsets.uppercase.length;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += Charsets.numbers.length;
    if (password.contains(RegExp(r'[!@#\$%^&*()\-\_=+\[\]{}|;:,.<>?/~`]'))) poolSize += Charsets.symbols.length;

    // Build frequency map for Shannon calculation
    final Map<String, int> freq = <String, int>{};
    for (final r in password.runes) {
      final char = String.fromCharCode(r);
      freq[char] = (freq[char] ?? 0) + 1;
    }

    // If poolSize could not be determined from charsets (e.g., emoji, exotic chars),
    // fall back to the number of unique characters observed:
    if (poolSize == 0) poolSize = freq.keys.length;
    // Ensure the pool estimate is at least the number of unique symbols we see:
    if (poolSize < freq.keys.length) poolSize = freq.keys.length;

    // Brute-force estimate: L * log2(poolSize)
    final double bruteForceEntropy = length * (log(poolSize) / log(2));

    // Shannon entropy (bits per symbol) based on observed frequencies.
    double shannonPerSymbol = 0.0;
    for (final count in freq.values) {
      final p = count / length;
      if (p > 0) shannonPerSymbol -= p * (log(p) / log(2));
    }
    final double shannonTotal = shannonPerSymbol * length;

    // Penalty for repeated runs of the same character (compressibility)
    double runPenalty = 0.0;
    int runLen = 1;
    final chars = password.split('');
    for (var i = 1; i < chars.length; i++) {
      if (chars[i] == chars[i - 1]) {
        runLen++;
      } else {
        if (runLen > 1) runPenalty += log(runLen) / log(2);
        runLen = 1;
      }
    }
    if (runLen > 1) runPenalty += log(runLen) / log(2);

    // Penalty for repetition of a smaller substring (e.g., 'abcabcabc')
    double repeatSubPenalty = 0.0;
    for (int k = length; k >= 2; k--) {
      if (length % k != 0) continue;
      final subLen = length ~/ k;
      final sub = password.substring(0, subLen);
      var repeated = true;
      for (int i = 1; i < k; i++) {
        if (password.substring(i * subLen, (i + 1) * subLen) != sub) {
          repeated = false;
          break;
        }
      }
      if (repeated) {
        repeatSubPenalty = log(k) / log(2); // bits saved by repetition
        break;
      }
    }

    // Combine heuristics:
    // Use the lower of Shannon-based and brute-force estimates as a conservative value,
    // then subtract compressibility penalties.
    double entropy = math.min(bruteForceEntropy, shannonTotal) - runPenalty - repeatSubPenalty;
    if (entropy < 0.0) entropy = 0.0;
    return entropy;
  }

  static String getStrengthLabel(double entropy) {
    if (entropy < 25) return 'Very Weak';
    if (entropy < 50) return 'Weak';
    if (entropy < 75) return 'Moderate';
    if (entropy < 100) return 'Strong';
    return 'Very Strong';
  }

  static Color getStrengthColor(double entropy) {
    if (entropy < 25) return Color(0xFFFF0000); // Red
    if (entropy < 50) return Color(0xFFFFA500); // Orange
    if (entropy < 75) return Color.fromARGB(255, 243, 227, 48); // Yellow
    if (entropy < 100) return Color(0xFF9ACD32); // YellowGreen
    return Color(0xFF008000); // Green
  }
}

class PasswordGenerator {
  static String generate({
    required int length,
    required bool useLowercase,
    required bool useUppercase,
    required bool useNumbers,
    required bool useSymbols,
  }) {
    if (length < 8 || length > 64) {
      throw RangeError('length must be between 8 and 64 inclusive.');
    }

    String charPool = '';
    if (useLowercase) charPool += Charsets.lowercase;
    if (useUppercase) charPool += Charsets.uppercase;
    if (useNumbers) charPool += Charsets.numbers;
    if (useSymbols) charPool += Charsets.symbols;

    if (charPool.isEmpty) {
      throw ArgumentError('No character sets selected. Enable lowercase, uppercase, numbers, or symbols.');
    }

    final random = _secureRandom();
    final buffer = StringBuffer();

    // Ensure at least one character from each selected set is used
    final requiredChars = <String>[];
    if (useLowercase) requiredChars.add(Charsets.lowercase);
    if (useUppercase) requiredChars.add(Charsets.uppercase);
    if (useNumbers) requiredChars.add(Charsets.numbers);
    if (useSymbols) requiredChars.add(Charsets.symbols);

    for (String set in requiredChars) {
      if (buffer.length < length) {
        buffer.write(set[random.nextInt(set.length)]);
      }
    }

    // Fill the rest of the length from the complete charPool
    while (buffer.length < length) {
      buffer.write(charPool[random.nextInt(charPool.length)]);
    }

    // Shuffle the result to prevent predictable sequences
    final resultList = buffer.toString().split('');
    resultList.shuffle(random);

    return resultList.join();
  }

  static String generateWithInput({
    required int length,
    required String input,
  }) {
    if (length < 8 || length > 64) {
      throw RangeError('length must be between 8 and 64 inclusive.');
    }

    final random = _secureRandom();
    final defaults = Charsets.lowercase + Charsets.uppercase + Charsets.numbers + Charsets.symbols;

    String pool = input;
    while (pool.length < length) {
      pool += defaults[random.nextInt(defaults.length)];
    }

    if (pool.length > length) {
      pool = pool.substring(0, length);
    }

    final chars = pool.split('');
    chars.shuffle(random);
    return chars.join();
  }
}