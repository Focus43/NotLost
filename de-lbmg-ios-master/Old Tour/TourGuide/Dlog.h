// A variation Dlog that has 4 options including a local notification option
//
//      DLog   =  NSLog
//      DLogD  =  Detail - Full logging detail
//      DLogS  =  Short  - Short Detail minus time stamp & app data
//      DLogN  =  Detail - Local Notification



#ifdef DEBUG
    // Bog standard Logging
    #define DLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__);
    // Log statement with a bit more detail as to where you are
    #define DLogD(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    // Log statement without the normal NSLog fluff at the start
    #define DLogS(fmt, ...) fprintf( stderr, "%s\n", [[NSString stringWithFormat:(@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__] UTF8String] );
    // Logs out to a UILocalNotification, where you can pull it down in Notification Center
    #define DLogN(fmt, ...) UILocalNotification *localNotif__LINE__ = [[UILocalNotification alloc] init];\
    if (localNotif__LINE__) {\
    localNotif__LINE__.alertBody = [NSString stringWithFormat:(fmt), ##__VA_ARGS__];\
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif__LINE__];\
    }

    // You can use this type to delay expensive logging computation by wrapping it in a block.
    typedef NSString *(^LoggingOnlyComposeString)();

#else
    // No definition unless debugging is on
    #define DLog(fmt, ...)
    #define DLogD(fmt, ...)
    #define DLogS(fmt, ...)
    #define DLogN(fmt, ...)

#endif
