# ssh2

SSH and SFTP client for Flutter. Wraps iOS library NMSSH and Android library JSch. This is a fork of flutter_ssh: https://github.com/shaqian/flutter_ssh

Wraps iOS library [NMSSH](https://github.com/gaetanzanella/NMSSH/tree/feature/catalyst) and Android library [JSch](https://github.com/mwiede/jsch).

## Installation

Add `ssh2` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Known issue

- Older Gradle versions are not supported due to incompatibilities with the newer JSch dependency. This release was tested with Gradle version 7.0.2.

## Usage

### Create a client using password authentication
```dart
import 'package:ssh2/ssh2.dart';

var client = new SSHClient(
  host: "my.sshtest",
  port: 22,
  username: "sha",
  passwordOrKey: "Password01.",
);
```

### Create a client using public key authentication
```dart
import 'package:ssh2/ssh2.dart';

var client = new SSHClient(
  host: "my.sshtest",
  port: 22,
  username: "sha",
  passwordOrKey: {
    "privateKey": """-----BEGIN RSA PRIVATE KEY-----
    ......
-----END RSA PRIVATE KEY-----""",
    "passphrase": "passphrase-for-key",
  },
);
```

#### OpenSSH keys

Recent versions of OpenSSH introduce a proprietary key format that is not supported by most other software, including this one, you must convert it to a PEM-format RSA key using the `puttygen` tool. On Windows this is a graphical tool. On the Mac, install it per [these instructions](https://www.ssh.com/ssh/putty/mac/). On Linux install your distribution's `putty` or `puttygen` packages.

* Temporarily remove the passphrase from the original key (enter blank password as the new password)  
`ssh-keygen -p -f id_rsa`
* convert to RSA PEM format  
`puttygen id_rsa -O private-openssh -o id_rsa_unencrypted`
* re-apply the passphrase to the original key  
`ssh-keygen -p -f id_rsa`
* apply a passphrase to the converted key:  
`puttygen id_rsa_unencrypted -P -O private-openssh -o id_rsa_flutter`
* remove the unencrypted version:  
`rm id_rsa_unencrypted`

### Connect client
```dart
await client.connect();
```

### Close client
```dart
await client.disconnect();
```

### Execute SSH command
```dart
var result = await client.execute("ps");
```

### Get the fingerprint of the remote host
```dart
var result = await client.getHostFingerprint();
```

### Get the banner of the remote host
```dart
var result = await client.getBanner();
```

### Shell

#### Start shell: 
- Supported ptyType: vanilla, vt100, vt102, vt220, ansi, xterm
```dart
var result = await client.startShell(
  ptyType: "xterm", // defaults to vanilla
  callback: (dynamic res) {
    print(res);     // read from shell
  }
);
```

#### Write to shell: 
```dart
await client.writeToShell("ls\n");
```

#### Close shell: 
```dart
await client.closeShell();
```

### SFTP

#### Connect SFTP:
```dart
await client.connectSFTP();
```

#### List directory: 
```dart
var array = await client.sftpLs("/home"); // defaults to .
```

#### Create directory: 
```dart
await client.sftpMkdir("testdir");
```

#### Rename file or directory: 
```dart
await client.sftpRename(
  oldPath: "testfile",
  newPath: "newtestfile",
);
```

#### Remove directory: 
```dart
await client.sftpRmdir("testdir");
```

#### Remove file: 
```dart
await client.sftpRm("testfile");
```

#### Download file: 
```dart
var filePath = await client.sftpDownload(
  path: "testfile",
  toPath: tempPath,
  callback: (progress) {
    print(progress); // read download progress
  },
);

// Cancel download:
await client.sftpCancelDownload();
```

#### Upload file: 
```dart
await client.sftpUpload(
  path: filePath,
  toPath: ".",
  callback: (progress) {
    print(progress); // read upload progress
  },
);

// Cancel upload:
await client.sftpCancelUpload();
```

#### Close SFTP: 
```dart
await client.disconnectSFTP();
```

## Demo

Refer to the [example](https://github.com/jda258/flutter_ssh/tree/master/example).
