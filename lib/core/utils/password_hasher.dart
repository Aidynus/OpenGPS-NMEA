import 'dart:convert';

/// Produces a deterministic, non-reversible hash of [password] suitable for
/// local settings-lock validation.
///
/// Uses a simple but adequate approach for a UI lock: SHA-256 of the UTF-8
/// password bytes, hex-encoded. This is NOT a replacement for cryptographic
/// key derivation in a security-sensitive context, but is appropriate for a
/// local UI passcode that prevents casual access to settings.
String hashPassword(String password) {
  // Dart's dart:convert doesn't include SHA-256. We implement a compact
  // custom SHA-256 here to avoid adding a dependency solely for this feature.
  // For production, swap this for package:crypto if added as a dependency.
  final bytes = utf8.encode(password);
  return _sha256Hex(bytes);
}

/// Verifies that [plain] matches a previously hashed password.
bool verifyPassword(String plain, String hash) {
  return hashPassword(plain) == hash;
}

// ── Minimal SHA-256 implementation ──────────────────────────────────────────
// Based on the FIPS 180-4 standard. This avoids adding package:crypto
// as a dependency solely for password hashing.

const List<int> _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

String _sha256Hex(List<int> message) {
  // Pre-processing: add padding bits
  final bitLen = message.length * 8;
  final bytes = List<int>.from(message)..add(0x80);
  while (bytes.length % 64 != 56) {
    bytes.add(0x00);
  }
  // Append original length as 64-bit big-endian
  for (var i = 7; i >= 0; i--) {
    bytes.add((bitLen >> (i * 8)) & 0xff);
  }

  // Initial hash values (first 32 bits of fractional parts of sqrt of first 8 primes)
  var h0 = 0x6a09e667;
  var h1 = 0xbb67ae85;
  var h2 = 0x3c6ef372;
  var h3 = 0xa54ff53a;
  var h4 = 0x510e527f;
  var h5 = 0x9b05688c;
  var h6 = 0x1f83d9ab;
  var h7 = 0x5be0cd19;

  // Process each 512-bit (64-byte) chunk
  for (var i = 0; i < bytes.length; i += 64) {
    final w = List<int>.filled(64, 0);
    for (var j = 0; j < 16; j++) {
      w[j] = (bytes[i + j * 4] << 24) |
          (bytes[i + j * 4 + 1] << 16) |
          (bytes[i + j * 4 + 2] << 8) |
          bytes[i + j * 4 + 3];
      w[j] = w[j] & 0xffffffff;
    }
    for (var j = 16; j < 64; j++) {
      final s0 = (_rotr(w[j - 15], 7) ^ _rotr(w[j - 15], 18) ^ (w[j - 15] >> 3)) & 0xffffffff;
      final s1 = (_rotr(w[j - 2], 17) ^ _rotr(w[j - 2], 19) ^ (w[j - 2] >> 10)) & 0xffffffff;
      w[j] = (w[j - 16] + s0 + w[j - 7] + s1) & 0xffffffff;
    }

    var a = h0, b = h1, c = h2, d = h3;
    var e = h4, f = h5, g = h6, h = h7;

    for (var j = 0; j < 64; j++) {
      final S1 = (_rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25)) & 0xffffffff;
      final ch = (e & f) ^ (~e & g);
      final temp1 = (h + S1 + ch + _k[j] + w[j]) & 0xffffffff;
      final S0 = (_rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22)) & 0xffffffff;
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (S0 + maj) & 0xffffffff;

      h = g; g = f; f = e;
      e = (d + temp1) & 0xffffffff;
      d = c; c = b; b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }

    h0 = (h0 + a) & 0xffffffff;
    h1 = (h1 + b) & 0xffffffff;
    h2 = (h2 + c) & 0xffffffff;
    h3 = (h3 + d) & 0xffffffff;
    h4 = (h4 + e) & 0xffffffff;
    h5 = (h5 + f) & 0xffffffff;
    h6 = (h6 + g) & 0xffffffff;
    h7 = (h7 + h) & 0xffffffff;
  }

  return [h0, h1, h2, h3, h4, h5, h6, h7]
      .map((v) => v.toRadixString(16).padLeft(8, '0'))
      .join();
}

int _rotr(int x, int n) {
  x &= 0xffffffff;
  return ((x >> n) | (x << (32 - n))) & 0xffffffff;
}
