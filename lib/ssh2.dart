import 'dart:async';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

const MethodChannel _channel = const MethodChannel('ssh');
const EventChannel _eventChannel = const EventChannel('shell_sftp');
Stream<dynamic>? _onStateChanged;

Stream<dynamic>? get onStateChanged {
  if (_onStateChanged == null) {
    _onStateChanged =
        _eventChannel.receiveBroadcastStream().map((dynamic event) => event);
  }
  return _onStateChanged;
}

typedef void Callback(dynamic result);

/// Uses specified credentials to create a connection to a host.
///
/// Using a password:
/// ```dart
/// var client = new SSHClient(
///   host: "my.sshtest",
///   port: 22,
///   username: "sha",
///   passwordOrKey: "Password01.",
/// );```
///
/// Using a key:
/// ```dart
/// var client = new SSHClient(
///   host: "my.sshtest",
///   port: 22,
///   username: "sha",
///   passwordOrKey: {
///     "privateKey": """-----BEGIN RSA PRIVATE KEY-----
///     ......
/// -----END RSA PRIVATE KEY-----""",
///     "passphrase": "passphrase-for-key",
///   },
/// );
/// ```
///
/// Recent versions of OpenSSH introduce a proprietary key format that is not supported by most other software, including this one, you must convert it to a PEM-format RSA key using the `puttygen` tool. On Windows this is a graphical tool. On the Mac, install it per [these instructions](https://www.ssh.com/ssh/putty/mac/). On Linux install your distribution's `putty` or `puttygen` packages.
///
/// * Temporarily remove the passphrase from the original key (enter blank password as the new password)
/// `ssh-keygen -p -f id_rsa`
/// * convert to RSA PEM format
/// `puttygen id_rsa -O private-openssh -o id_rsa_unencrypted`
/// * re-apply the passphrase to the original key
/// `ssh-keygen -p -f id_rsa`
/// * apply a passphrase to the converted key:
/// `puttygen id_rsa_unencrypted -P -O private-openssh -o id_rsa_flutter`
/// * remove the unencrypted version:
/// `rm id_rsa_unencrypted`
class SSHClient {
  String? id;
  String host;
  int port;
  String username;
  dynamic passwordOrKey;
  late StreamSubscription<dynamic> stateSubscription;
  Callback? shellCallback;
  Callback? uploadCallback;
  Callback? downloadCallback;

  SSHClient({
    required this.host,
    required this.port,
    required this.username,
    required this.passwordOrKey, // password or {privateKey: value, [publicKey: value, passphrase: value]}
  }) {
    var uuid = new Uuid();
    id = uuid.v4();
    stateSubscription = onStateChanged!.listen((dynamic result) {
      _parseOutput(result);
    });
  }

  _parseOutput(dynamic result) {
    switch (result["name"]) {
      case "Shell":
        if (shellCallback != null && result["key"] == id)
          shellCallback!(result["value"]);
        break;
      case "DownloadProgress":
        if (downloadCallback != null && result["key"] == id)
          downloadCallback!(result["value"]);
        break;
      case "UploadProgress":
        if (uploadCallback != null && result["key"] == id)
          uploadCallback!(result["value"]);
        break;
    }
  }

  /// Attempts to connect to the host using specified credentials.
  /// Returns the result of the connection attempt.
  Future<String?> connect() async {
    var result = await _channel.invokeMethod('connectToHost', {
      "id": id,
      "host": host,
      "port": port,
      "username": username,
      "passwordOrKey": passwordOrKey,
    });
    return result;
  }

  /// Sends a non-interactive ssh command. Returns the output of the command.
  ///
  /// ```dart
  /// var result = await client.execute("ps");
  /// ```
  Future<String?> execute(String cmd) async {
    var result = await _channel.invokeMethod('execute', {
      "id": id,
      "cmd": cmd,
    });
    return result;
  }

  /// Forward a port from the remote to the local host.
  Future<String?> portForwardL(int rport, int lport, String rhost) async {
    var result = await _channel.invokeMethod('portForwardL',
        {"id": id, "rhost": rhost, "rport": rport, "lport": lport});
    return result;
  }

  /// Starts an SSH shell. Use the specified callback to receive shell output.
  ///
  /// ```dart
  /// var result = await client.startShell(
  ///   ptyType: "xterm", // defaults to vanilla
  ///   callback: (dynamic res) {
  ///     print(res);     // read from shell
  ///   }
  /// );
  /// ```
  Future<String?> startShell({
    String ptyType = "vanilla", // vanilla, vt100, vt102, vt220, ansi, xterm
    Callback? callback,
  }) async {
    shellCallback = callback;
    var result = await _channel.invokeMethod('startShell', {
      "id": id,
      "ptyType": ptyType,
    });
    return result;
  }

  /// Sends a string to the shell.
  ///
  /// ```dart
  /// await client.writeToShell("ls\n");
  /// ```
  Future<String?> writeToShell(String cmd) async {
    var result = await _channel.invokeMethod('writeToShell', {
      "id": id,
      "cmd": cmd,
    });
    return result;
  }

  /// Closes the shell.
  ///
  /// ```dart
  /// await client.closeShell();
  /// ```
  Future closeShell() async {
    shellCallback = null;
    await _channel.invokeMethod('closeShell', {
      "id": id,
    });
  }

  /// Connects to an SFTP server.
  ///
  /// ```dart
  /// await client.connectSFTP();
  /// ```
  Future<String?> connectSFTP() async {
    var result = await _channel.invokeMethod('connectSFTP', {
      "id": id,
    });
    return result;
  }

  /// Performs a directory listing using SFTP. Defaults to the current directory.
  ///
  /// ```dart
  /// var array = await client.sftpLs("/home");
  /// ```
  Future<List?> sftpLs([String path = '.']) async {
    var result = await _channel.invokeMethod('sftpLs', {
      "id": id,
      "path": path,
    });
    return result;
  }

  /// Renames a directory using SFTP.
  ///
  /// ```dart
  /// await client.sftpRename(
  ///   oldPath: "testfile",
  ///   newPath: "newtestfile",
  /// );
  /// ```
  Future<String?> sftpRename({
    required String oldPath,
    required String newPath,
  }) async {
    var result = await _channel.invokeMethod('sftpRename', {
      "id": id,
      "oldPath": oldPath,
      "newPath": newPath,
    });
    return result;
  }

  /// Creates a new directory in the current directory using SFTP.
  ///
  /// ```dart
  /// await client.sftpMkdir("testdir");
  /// ```
  Future<String?> sftpMkdir(String path) async {
    var result = await _channel.invokeMethod('sftpMkdir', {
      "id": id,
      "path": path,
    });
    return result;
  }

  /// Removes the specified file using SFTP.
  ///
  /// ```dart
  /// await client.sftpRm("testfile");
  /// ```
  Future<String?> sftpRm(String path) async {
    var result = await _channel.invokeMethod('sftpRm', {
      "id": id,
      "path": path,
    });
    return result;
  }

  /// Removes the specified directory using SFTP.
  ///
  /// ```dart
  /// await client.sftpRmdir("testdir");
  /// ```
  Future<String?> sftpRmdir(String path) async {
    var result = await _channel.invokeMethod('sftpRmdir', {
      "id": id,
      "path": path,
    });
    return result;
  }

  /// Downloads the specified file using SFTP.
  ///
  /// ```dart
  /// var filePath = await client.sftpDownload(
  ///   path: "testfile",
  ///   toPath: tempPath,
  ///   callback: (progress) {
  ///     print(progress); // read download progress
  ///   },
  /// );
  /// ```
  Future<String?> sftpDownload({
    required String path,
    required String toPath,
    Callback? callback,
  }) async {
    downloadCallback = callback;
    var result = await _channel.invokeMethod('sftpDownload', {
      "id": id,
      "path": path,
      "toPath": toPath,
    });
    return result;
  }

  /// Cancels an ongoing download using SFTP.
  ///
  /// ```dart
  /// await client.sftpCancelDownload();
  /// ```
  Future sftpCancelDownload() async {
    await _channel.invokeMethod('sftpCancelDownload', {
      "id": id,
    });
  }

  /// Uploads a file using SFTP.
  ///
  /// ```dart
  /// await client.sftpUpload(
  ///   path: filePath,
  ///   toPath: ".",
  ///   callback: (progress) {
  ///     print(progress); // read upload progress
  ///   },
  /// );
  /// ```
  Future<String?> sftpUpload({
    required String path,
    required String toPath,
    Callback? callback,
  }) async {
    uploadCallback = callback;
    var result = await _channel.invokeMethod('sftpUpload', {
      "id": id,
      "path": path,
      "toPath": toPath,
    });
    return result;
  }

  /// Cancels an ongoing upload using SFTP.
  ///
  /// ```dart
  /// await client.sftpCancelUpload();
  /// ```
  Future sftpCancelUpload() async {
    await _channel.invokeMethod('sftpCancelUpload', {
      "id": id,
    });
  }

  /// Closes the SFTP connection.
  ///
  /// ```dart
  /// await client.disconnectSFTP();
  /// ```
  Future disconnectSFTP() async {
    uploadCallback = null;
    downloadCallback = null;
    await _channel.invokeMethod('disconnectSFTP', {
      "id": id,
    });
  }

  /// Closes the SSH client connection.
  ///
  /// ```dart
  /// await client.disconnect();
  /// ```
  disconnect() {
    shellCallback = null;
    uploadCallback = null;
    downloadCallback = null;
    stateSubscription.cancel();
    _channel.invokeMethod('disconnect', {
      "id": id,
    });
  }

  /// Checks to see if the SSH client is currently connected.
  ///
  /// ```dart
  /// await client.isConnected();
  /// ```
  Future<bool> isConnected() async {
    bool connected = false; // default to false
    var result = await _channel.invokeMethod('flutterIsConnected', {
      "id": id,
    });
    if (result == "true") {
      // results returns a string, therefore we need to check the string 'true'
      connected = true;
    }
    return connected;
  }

  /// Gets the fingerprint of the remote host.
  ///
  /// ```dart
  /// String result = await client.getHostFingerprint();
  /// ```
  Future<String> getHostFingerprint() async {
    var result = await _channel.invokeMethod('getHostFingerprint', {
      "id": id,
    });
    return result;
  }

  /// Gets the banner of the remote host.
  ///
  /// ```dart
  /// String result = await client.getBanner();
  /// ```
  Future<String> getRemoteBanner() async {
    var result = await _channel.invokeMethod('getRemoteBanner', {
      "id": id,
    });
    return result;
  }
}
