#import <Flutter/Flutter.h>
#import <GZ_NMSSH/NMSSH.h>
#import "SSHClient.h"

@interface SshPlugin : NSObject<FlutterPlugin, NMSSHChannelDelegate, SSHClientDelegate, FlutterStreamHandler>
@end
