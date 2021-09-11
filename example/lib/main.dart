import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ssh2/ssh2.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = '';
  List _array = [];

  // ***** Change these settings for your environment *****
  final String hostname = 'changeme';
  final String username = 'changeme';
  final String password = 'changeme';
  final String privateKey = """-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA2DdFSeWG8wOHddRpOhf4FRqksJITr59iXdNrXq+n79QFN1g4
bvRG9zCDmyLb8EF+gah78dpJsGZVIltmfYWpsk7ok9GT/foCB1d2E6DbEU6mBIPe
OLxYOqyiea8mi7iGt9BvAB4Mj+v2LnhK4O2BB6PTU4KLjSgMdqtV/EGctLdK+JEU
5Vo/tDvtF8jmUYGV57V8VovgQJHxOWcT9Mgz+c5EcyVvhwvA/88emYkZ49cn4N0A
az7YsOTHItvbhxf9xI3bBwxoPvfLx/G0n48TeY33D0qu/qjAloOfqPMHwj+upn/K
RrAawl2N1MObCc5/q1WYTftd5+uoQsB1RN7ptQIDAQABAoIBAQCzKBkhwi6v7pyv
5fHLUVEfK5SLOn9VZpv7YtP1AVgGQYiQ82jPh1nGOUzTn27fBWXtyc3p+RZWNHUW
ouWp3LdgKEJPObmHGUHVE4OjgAYFsUWfOCVKncX92E5IxfkKjTwT04Imdr+yAbNb
jhF9j077JaRV7jX0INsy+YWmIDfZBQHdR4gpip6ye70yc4p0M7DbrhjEFi6cvf5b
OaSsbKAunxZte42RYY1ap6GmEii5B/wWe37176jBUrCeQzN9poTSFEv99+Av6M3R
yyBD1PyawR+dPCAicvIY88ME4fAJSi6Gp8Kmievq7bXnGw8ICWggVSnl0TBYhwSY
SN8mBr2BAoGBAPNNQ+77kEkwsA0pzZljbwDhJ03jATsWpA4yN4S3Gz456ZUDxode
lbHERy7RR8l6EunSRdlWGVW9d/8uXBKsvp78hZnJkUE1fLCP+5UH1DVYn+hSYhjj
g9lnQXbKpXm5tpABiM7+sMq+pC2N6K8yQ7P33TXCcRCWpjK0OJcEVxq/AoGBAOOA
HNlZe8gQeH3OrQWKEJjgF6oQ9pGdRgJJctdSHDsqP8cPV7BuiYaTh/Q+R+HIueJ+
3abGLkRqxbNb5FIgX7HJRYLGlusccjd0L4OJ5upGDQJgJzQOryPFofihLvvNbY1K
zLLNvvYoaWtXhSGusj5N9T6DuA6qxMs+0OwPeZyLAoGBAPHIjwInrTOO1uW97TvJ
vL47Ajw8ozR9Q3t4HAQfk0s7cg1MOza7oDeQvsyf3Z8zWShUdmWNUpAKQf2trIJC
eQy2Fm7GCTusU8WC0JlBtnltITxW4nWpY5XhLwVGTTuyeuKRI8vQ/w/8dFtw8xNn
+DAY2hRartG1ZGRvBO3OumExAoGAeJuar7+417+joU7Ie39OfT2QTiDgFyKB0wSN
VYm6XcNwPF/t5SM01ZuxH9NE2HZJ1cHcUGYQcUUJuqSkzsVK9j32E/akW9Cg3LVD
20BooxqwGupO3lJKl3RXAjCxb9zgj19wVfqtmmKiQL4NXmX3KQC7W4EJOv1dh0Ku
D/fESTECgYBwWv9yveto6pP6/xbR9k/Jdgr+vXQ3BJVU3BOsD38SeSrZfMSNGqgx
eiukCOIsRHYY7Qqi2vCJ62mwbHJ3RhSKKxcGpgzGX7KoGZS+bb5wb7RGNYK/mVaI
pFkz72+8eA2cnbWUqHt9WqMUgUBYZTMESzQrTf7+q+0gWf49AZJ/QQ==
-----END RSA PRIVATE KEY-----""";
  final String passphrase = "changeme"; // For password encrypted private key

  final ButtonStyle buttonStyle =
      TextButton.styleFrom(backgroundColor: Colors.blue);

  void resetValues() {
    setState(() {
      _result = 'Loading';
      _array = [];
    });
  }

  Future<void> onClickCmd() async {
    String result = '';

    resetValues();

    var client = new SSHClient(
      host: hostname,
      port: 22,
      username: username,
      passwordOrKey: password,
    );

    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") result = await client.execute("ps") ?? 'Null result';
      await client.disconnect();
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result = errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
    });
  }

  Future<void> onClickShell() async {
    String result = '';

    resetValues();

    var client = new SSHClient(
      host: hostname,
      port: 22,
      username: username,
      passwordOrKey: {
        "privateKey": privateKey,
        "passphrase": passphrase, // Remove line if key is not password protected
      },
    );

    try {
      result = await client.connect() ?? 'Null result';

      if (result == "session_connected") {
        result = await client.startShell(
            ptyType: "xterm",
            callback: (dynamic res) {
              setState(() {
                result += res;
              });
            }) ?? 'Null result';

        if (result == "shell_started") {
          print(await client.writeToShell("echo hello > world\n"));
          print(await client.writeToShell("cat world\n"));

        }

        // Disconnect from SSH client
        await client.disconnect();
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
    });
  }

  Future<void> onClickSFTP() async {
    String result = '';
    List array = [];

    resetValues();

    var client = new SSHClient(
      host: hostname,
      port: 22,
      username: username,
      passwordOrKey: password,
    );

    try {
      result = await client.connect() ?? 'Null result';
      if (result == "session_connected") {
        result = await client.connectSFTP() ?? 'Null result';
        if (result == "sftp_connected") {
          array = await client.sftpLs() ?? [];

          // Create a test directory
          print(await client.sftpMkdir("testsftp"));

          // Rename the test directory
          print(await client.sftpRename(
            oldPath: "testsftp",
            newPath: "testsftprename",
          ));

          // Remove the renamed test directory
          print(await client.sftpRmdir("testsftprename"));

          // Get local device temp directory
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;

          // Create local test file
          final String fileName = 'ssh2_test_upload.txt';
          final File file = File('$tempPath/$fileName');
          await file.writeAsString('Testing file upload');

          print('Local file path is ${file.path}');

          // Upload test file
          print(await client.sftpUpload(
            path: file.path,
            toPath: ".",
            callback: (progress) async {
              print(progress);
              // if (progress == 30) await client.sftpCancelUpload();
            },
          ) ?? 'Upload failed');

          // Download test file
          print(await client.sftpDownload(
            path: fileName,
            toPath: tempPath,
            callback: (progress) async {
              print(progress);
              // if (progress == 20) await client.sftpCancelDownload();
            },
          ) ?? 'Download failed');

          // Delete the remote test file
          print(await client.sftpRm(fileName));

          // Delete the local test file
          await file.delete();

          // Disconnect from SFTP client - don't use
          // There is a bug that prevents the ssh client connection from being
          // closed after calling disconnectSFTP()
          //print(await client.disconnectSFTP());

          // Disconnect from SSH client
          await client.disconnect();
        }


      }
    } on PlatformException catch (e) {
      String errorMessage = 'Error: ${e.code}\nError Message: ${e.message}';
      result += errorMessage;
      print(errorMessage);
    }

    setState(() {
      _result = result;
      _array = array;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget renderButtons() {
      return ButtonTheme(
        padding: EdgeInsets.all(5.0),
        child: ButtonBar(
          children: <Widget>[
            TextButton(
              style: buttonStyle,
              child: Text(
                'Test command',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: onClickCmd,
            ),
            TextButton(
              style: buttonStyle,
              child: Text(
                'Test shell',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: onClickShell,
            ),
            TextButton(
              style: buttonStyle,
              child: Text(
                'Test SFTP',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: onClickSFTP,
            ),
          ],
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ssh2 plugin example app'),
        ),
        body: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Text(
                "Please edit the connection settings in the source code before clicking the test buttons"),
            renderButtons(),
            Text(_result),
            _array.length > 0
                ? Column(
                    children: _array.map((f) {
                      return Text(
                          "${f["filename"]} ${f["isDirectory"]} ${f["modificationDate"]} ${f["lastAccess"]} ${f["fileSize"]} ${f["ownerUserID"]} ${f["ownerGroupID"]} ${f["permissions"]} ${f["flags"]}");
                    }).toList(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
