import 'dart:typed_data';

import 'package:hive/hive.dart';

/// Abstract cipher can be implemented to customize encryption.
abstract class StateCipher implements HiveCipher {
  /// Calculate a hash of the key. Make sure to use a secure hash.
  @override
  int calculateKeyCrc();

  /// The maximum size the input can have after it has been encrypted.
  @override
  int maxEncryptedSize(Uint8List inp);

  /// Encrypt the given bytes.
  @override
  int encrypt(
    Uint8List inp,
    int inpOff,
    int inpLength,
    Uint8List out,
    int outOff,
  );

  /// Decrypt the given bytes.
  @override
  int decrypt(
    Uint8List inp,
    int inpOff,
    int inpLength,
    Uint8List out,
    int outOff,
  );
}

/// Default encryption algorithm. Uses AES256 CBC with PKCS7 padding.
class StateAesCipher extends HiveAesCipher implements StateCipher {
  /// Create a cipher with the given [key].
  StateAesCipher(super.key);
}
