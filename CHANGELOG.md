## 2.2.3
* Update podspec to exclude arm64 architecture for iphone simulator builds

## 2.2.2
* Update mwiede jsch to version 0.1.66: https://github.com/mwiede/jsch/releases/tag/jsch-0.1.66
  * Support for several more algorithms in Android, including ssh-ed25519
* Bug fixes and improvements for example app
* Bump kotlin version and targetSdkVersion for Android

## 2.2.1
* Fix bug in isConnected that affected sftp connections in iOS
* Add function to get host fingerprint
* Add function to get host banner

## 2.2.0
* Change NMSSH to GZ-NMSSH: https://github.com/gaetanzanella/NMSSH/tree/feature/catalyst
  * Updated libssh and libssl
  * Supports more key types (ECDSA_256, ECDSA_384, ECDSA_521, ED25519)
  * Fix issues with multiple threads
* Change JSch to modernized fork: https://github.com/mwiede/jsch
  * Suports more key types (rsa-sha2-256, rsa-sha2-512, curve25519-sha256, curve448-sha512, chacha20-poly1305@openssh.com) 
  * More types will be supported once Android supports newer Java versions
  * Miscellaneous bug fixes
  * Deprecated older insecure key types
* Update to latest Gradle version

## 2.1.2
* Migrate Android plugin APIs to v2
* Fix Podspec name
* General code cleanup

## 2.1.1
* Fix package name in readme

## 2.1.0

* Nullsafe support
* Dependency and compatibility updates
* isConnected functionality added
* Add doc comments to all public APIs
* Fix issues to increase pub points
* Change package name to ssh2

## 0.0.7

* Moved getInputStream before channel connect on Android.
* Set minimum SDK version to 2.1.0. 

## 0.0.6

* Set compileSdkVersion to 28, fixing build error "Execution failed for task ':ssh:verifyReleaseResources'"
* Set uuid plugin version to ^2.0.0.

## 0.0.5

* Fixed download exception on Android due to [this issue](https://github.com/flutter/flutter/issues/34993).

## 0.0.4

* Changed disconnect() method to sync. 
* Fixed Android crash issue "Methods marked with @UiThread must be executed on the main thread.".

## 0.0.3

* Fixed invokeMethod missing indirection.
* Add note about OpenSSH keys, add passphrase to key example.

## 0.0.2

* Check if client is null before getting session in Android.

## 0.0.1

* Initial release.

