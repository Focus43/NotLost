    //
//  LBMGUtilities.m
//  Tours
//
//  Created by Alan Smithee on 4/3/13.
//  Copyright (c) 2013 LBMG. All rights reserved.
//

#import "LBMGUtilities.h"
#import "SSZipArchive.h"
#import "LBMGImage.h"
#import "TourData.h"
#import "TourDetail.h"
#import "Event.h"
#import "EventCategories.h"
#import "Category.h"
#import "EventSubCategory.h"
#import "EventDescription.h"
#import "UAPush.h"


NSString * const LBMGUtilitiesDownloadComplete = @"LBMGUtilitiesDownloadComplete";
NSString * const LBMGUtilitiesDownloadProgress = @"LBMGUtilitiesDownloadProgress";

@implementation LBMGUtilities

+ (NSString *)pathToDocuments {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        return paths[0];
    } else {
        return nil;
    }
}

+ (NSString *)basePathForTourData {
    return [NSString stringWithFormat:@"%@/TourData/", [LBMGUtilities pathToDocuments]];
}

+ (NSString *)basePathForEventData {
    return [NSString stringWithFormat:@"%@/EventData/", [LBMGUtilities pathToDocuments]];
}

+ (NSString *)basePathForTourRoutes {
    return [NSString stringWithFormat:@"%@/TourRoutes/", [LBMGUtilities pathToDocuments]];
}

+ (NSString *)plistPathForTourID:(NSNumber *)tourID {
    
//    return [[NSBundle mainBundle] pathForResource:@"OfficeRoute" ofType:@"json"];
    return [NSString stringWithFormat:@"%@/TourRoutes/Tour%i.plist", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)imagePathForTourID:(NSNumber *)tourID {

    return [NSString stringWithFormat:@"%@/TourData/Tour%d/images/", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)videoPathForTourID:(NSNumber *)tourID {
    
    return [NSString stringWithFormat:@"%@/TourData/Tour%d/videos/", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)audioPathForTourID:(NSNumber *)tourID {
    
    return [NSString stringWithFormat:@"%@/TourData/Tour%d/audio/", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)userDataPathForTourID:(NSNumber *)tourID {
    return [NSString stringWithFormat:@"%@/TourData/Tour%d/userData/", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)userDataPlistPathForTourID:(NSNumber *)tourID {
    return [NSString stringWithFormat:@"%@/TourData/Tour%d/userData/userdata.plist", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)userTouchedPoiPlistPathForTourID:(NSNumber *)tourID {
    return [NSString stringWithFormat:@"%@/TourData/Tour%d/userData/touchedPois.plist", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)basePathForTourID:(NSNumber *)tourID {
    return [NSString stringWithFormat:@"%@/TourData/Tour%d", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (NSString *)basePathForDownloadingTourID:(NSNumber *)tourID {
    return [NSString stringWithFormat:@"%@/TourData/Downloading%d.plist", [LBMGUtilities pathToDocuments], [tourID intValue]];
}

+ (BOOL)tourExistsForID:(NSNumber *)tourID {
    return [[NSFileManager defaultManager] fileExistsAtPath:[LBMGUtilities basePathForTourID:tourID]];
}

+ (BOOL)tourDownloadingForID:(NSNumber *)tourID {
    return [[NSFileManager defaultManager] fileExistsAtPath:[LBMGUtilities basePathForDownloadingTourID:tourID]];
}


+ (NSArray *)GetSavedTourIdPaths {
	
    NSError *error;
	NSArray *filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self basePathForTourRoutes] error:&error];
	NSMutableArray *tourIDs = [NSMutableArray array];
	for (NSString *path in filePaths) {
		if ([[path substringFromIndex:[path length]-5] isEqualToString:@"plist"]) {
            NSString* fileName = [[path lastPathComponent] stringByDeletingPathExtension];
            int num = [[fileName substringFromIndex:4] intValue];
            [tourIDs addObject:[NSNumber numberWithInt:num]];
		}
	}
	return [tourIDs copy];
}

+ (void)createFolderForTourData {
    NSString *userPath = [[self pathToDocuments] stringByAppendingPathComponent:@"TourRoutes"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:userPath]) {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:userPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            DLog(@"Error creating user folder!");
        }
    }
    
    NSString *dataPath = [[self pathToDocuments] stringByAppendingPathComponent:@"TourData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            DLog(@"Error creating user folder!");
        }
    }
}

+ (void)removeHangingDownloadFiles {
    NSError *error;
	NSArray *filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self basePathForTourData] error:&error];

	for (NSString *path in filePaths) {
        // if there's a .zip or downloading .plist file then delete them
		if ([[path substringFromIndex:[path length]-5] isEqualToString:@"plist"] ||
            [[path substringFromIndex:[path length]-3] isEqualToString:@"zip"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString pathWithComponents:@[[self basePathForTourData], path]] error:&error];
        }
        
        // if the current path is a directory
        if ([path rangeOfString:@"."].location == NSNotFound) {
            // if there is a folder that does not have a plist in TourRotes delete it
            NSNumber *tourId = [NSNumber numberWithInt:[[path stringByReplacingOccurrencesOfString:@"Tour" withString:@""] intValue]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:[LBMGUtilities plistPathForTourID:tourId]]) {
               [[NSFileManager defaultManager] removeItemAtPath:[NSString pathWithComponents:@[[self basePathForTourData], path]] error:&error]; 
            }
        }

	}
    
    // check to make sure all of the plists have associated folders and delete them if they don't
    filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self basePathForTourRoutes] error:&error];
    for (NSString *path in filePaths) {
        NSString *tourId = [[[path lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"Tour" withString:@""];
        NSString *zipPath = [LBMGUtilities basePathForTourID:[NSNumber numberWithInt:[tourId intValue]]];
        // if this is no associated folder then delete
        if (![[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
  
            [[NSFileManager defaultManager] removeItemAtPath:[NSString pathWithComponents:@[[self basePathForTourRoutes], path]] error:&error];
		}
	}
    
}

+ (void)removeTourRoutePlist:(NSNumber *)tourID {
    NSString *filePath = [self plistPathForTourID:tourID];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
}

+ (void)deleteTourWithId:(NSNumber *)tourID {
    [self removeTourRoutePlist:tourID];
    
    NSString *tourDataPath = [self basePathForTourID:tourID];
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:tourDataPath error:&error];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:[tourID stringValue]];
    NSString *keyStr = [NSString stringWithFormat:@"playedAudio_%@", [tourID stringValue]];
    [userDefaults removeObjectForKey:keyStr];

}

+ (void)downloadZippedDataForID:(NSNumber *)tourID atPath:(NSString *)path withError:(void (^)(MKNetworkOperation *, NSError *))errorBlock {
    NSString *downloadingPath = [LBMGUtilities basePathForDownloadingTourID:tourID];
    // create the user downloadingStatus plist
    NSArray *progress = @[@0];
    [progress writeToFile:downloadingPath atomically:YES];

    NSString *storagePath = [[LBMGUtilities basePathForTourData] stringByAppendingFormat:@"tour%@.zip", tourID];
    MKNetworkOperation *downloadOp = [ApplicationDelegate.lbmgEngine downloadFileFromURL:path andStoreAtFilePath:storagePath];
    [downloadOp onDownloadProgressChanged:^(double progress) {
        
        NSString *downloadingPath = [LBMGUtilities basePathForDownloadingTourID:tourID];
        NSArray *progress1 = @[[NSNumber numberWithFloat:progress*100.0]];
        [progress1 writeToFile:downloadingPath atomically:YES];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progress]
                                                             forKey:tourID];
        [[NSNotificationCenter defaultCenter] postNotificationName:LBMGUtilitiesDownloadProgress
                                                            object:nil
                                                          userInfo:userInfo];
    }];

    
    [downloadOp addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSError *error;
        
        // if zip is empty
       [SSZipArchive unzipFileAtPath:storagePath toDestination:[LBMGUtilities basePathForTourID:tourID] overwrite:YES password:nil error:&error];
        
        [[NSFileManager defaultManager] removeItemAtPath:storagePath error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:downloadingPath error:&error];
        DLog(@"Unzipped");
        
        // create the users folder
        NSString *userPath = [[self basePathForTourID:tourID] stringByAppendingPathComponent:@"userData"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:userPath]) {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:userPath withIntermediateDirectories:NO attributes:nil error:&error]) {
                DLog(@"Error creating user folder!");
            }
            
            // create the user data plist
            NSArray *userData = [[NSArray alloc] init];
            NSString *plistPath = [userPath stringByAppendingPathComponent:@"userdata.plist"];
            [userData writeToFile:plistPath atomically:YES];
            
            // create the touched pois plist
            NSArray *touchedPois = [[NSArray alloc] init];
            NSString *poiPath = [userPath stringByAppendingPathComponent:@"touchedPois.plist"];
            [touchedPois writeToFile:poiPath atomically:YES];
        }
        
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self createAndStoreThumbnailsForID:tourID];
        });
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:tourID
                                                      forKey:@"tourID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:LBMGUtilitiesDownloadComplete
                                                     object:nil
                                                   userInfo:userInfo];
        NSString *tagString = [NSString stringWithFormat:@"tour_dl-%@",[tourID stringValue]];
        DLog(@"%@", tagString);
        [[UAPush shared] addTagToCurrentDevice:tagString];
        [[UAPush shared] updateRegistration];
        
    } errorHandler:errorBlock];
}

+ (void)addNewTourDetails:(TourDetail *)tour {
    
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"myTours.data"];
    NSData *tourData = [NSData dataWithContentsOfFile:userPath];
    NSMutableArray *tours = [NSKeyedUnarchiver unarchiveObjectWithData:tourData];
    if (!tours) tours = [NSMutableArray arrayWithCapacity:1];
    [tours addObject:tour];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tours];
    BOOL success = [data writeToFile:userPath atomically:YES];
    if (!success) {
        DLog(@"Problem writing TourDetailfile");
    }
}

+ (NSArray *)getStoredTourDetails {
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"myTours.data"];
    NSData *tourData = [NSData dataWithContentsOfFile:userPath];
    NSMutableArray *tours = [NSKeyedUnarchiver unarchiveObjectWithData:tourData];
    return tours;    
}

+ (void)removeTourDetails:(TourDetail *)tour {
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"myTours.data"];
    NSData *tourData = [NSData dataWithContentsOfFile:userPath];
    NSMutableArray *tours = [NSKeyedUnarchiver unarchiveObjectWithData:tourData];
    NSMutableArray *toursLeft = [[NSMutableArray alloc] init];
    for (TourDetail *tourDetail in tours) {
        if (![tourDetail.tourDetailId isEqualToNumber:tour.tourDetailId]) {
            [toursLeft addObject:tourDetail];
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:toursLeft];
    BOOL success = [data writeToFile:userPath atomically:YES];
    if (!success) {
        DLog(@"Problem writing TourDetailfile");
    }
}

+ (void)addNewCalendarEvent:(Event *)event {
    
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"calendarEvents.data"];
    NSData *eventData = [NSData dataWithContentsOfFile:userPath];
    NSMutableDictionary *events = [NSKeyedUnarchiver unarchiveObjectWithData:eventData];
    if (!events) events = [NSMutableDictionary dictionaryWithCapacity:1];
    
    NSString *keyID;
    if ([event.eventDescriptionId intValue] == 0) {
        keyID = event.factualId;
    } else {
        keyID = [event.eventDescriptionId stringValue];
    }
    [events setObject:event forKey:keyID];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:events];
    BOOL success = [data writeToFile:userPath atomically:YES];
    if (!success) {
        DLog(@"Problem writing Event Set file");
    }
    
    NSString *tagString = [NSString stringWithFormat:@"listing_favorite-%@",keyID];
    DLog(@"%@", tagString);
    [[UAPush shared] addTagToCurrentDevice:tagString];
    [[UAPush shared] updateRegistration];

}

+ (void)removeCalendarEvent:(Event *)event {
    
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"calendarEvents.data"];
    NSData *eventData = [NSData dataWithContentsOfFile:userPath];
    NSMutableDictionary *events = [NSKeyedUnarchiver unarchiveObjectWithData:eventData];
    if (!events) return;
    
    NSString *keyID;
    if ([event.eventDescriptionId intValue] == 0) {
        keyID = event.factualId;
    } else {
        keyID = [event.eventDescriptionId stringValue];
    }
    [events removeObjectForKey:keyID];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:events];
    BOOL success = [data writeToFile:userPath atomically:YES];
    if (!success) {
        DLog(@"Problem writing Event Set file");
    }
    
    NSString *tagString = [NSString stringWithFormat:@"listing_favorite-%@",keyID];
    DLog(@"%@", tagString);
    [[UAPush shared] removeTagFromCurrentDevice:tagString];
    [[UAPush shared] updateRegistration];
}

+ (NSDate *)checkForID:(Event *)event {
    
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"calendarEvents.data"];
    NSData *eventData = [NSData dataWithContentsOfFile:userPath];
    NSMutableDictionary *events = [NSKeyedUnarchiver unarchiveObjectWithData:eventData];
    if (!events) return nil;
    
    NSString *keyID;
    if ([event.eventDescriptionId intValue] == 0) {
        keyID = event.factualId;
    } else {
        keyID = [event.eventDescriptionId stringValue];
    }
    Event *savedEvent = [events objectForKey:keyID];
    if (savedEvent) return savedEvent.selectedDate;
    
    return nil;
}

+ (NSDictionary *)savedEventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"calendarEvents.data"];
    NSData *eventData = [NSData dataWithContentsOfFile:userPath];
    NSMutableDictionary *events = [NSKeyedUnarchiver unarchiveObjectWithData:eventData];
    if (!events) return nil;
    
    NSTimeInterval fromInterval = [fromDate timeIntervalSince1970];
    NSTimeInterval toInterval = [toDate timeIntervalSince1970]+86400;
    
    NSMutableDictionary *weeksEvents = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [events enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        Event *event = (Event *)object;
        NSTimeInterval selectedInterval = [event.selectedDate timeIntervalSince1970];
        
        // check if event is without a selected date but within the to and from dates
        if (event.sponsored && event.startDate != NULL && event.endDate != NULL) {
            NSTimeInterval startInterval = [event.startDate timeIntervalSince1970];
            NSTimeInterval endInterval = [event.endDate timeIntervalSince1970];
            
            // if the first event starts before the 2nd's end date and the 2nd starts before the first end date
            if ((fromInterval <= endInterval) && (startInterval <= toInterval)) {
                NSDate *eventDate = ([event.startDate timeIntervalSince1970] > [fromDate timeIntervalSince1970]) ? event.startDate : fromDate;
                NSDate *endDateForResults = ([event.endDate timeIntervalSince1970] < [toDate timeIntervalSince1970]) ? event.endDate : toDate;
                
                // add a day to the end so that it can account for the time being past 00:00
                endDateForResults = [NSDate dateWithTimeInterval:86400 sinceDate:endDateForResults];
                
                // for each day between the dates add it to the list to make it display in the calendar
                // start at the event start date or the week start whichever is later
                while([eventDate timeIntervalSince1970] <= [endDateForResults timeIntervalSince1970])
                {
                    NSTimeInterval eventDateInterval = [eventDate timeIntervalSince1970];
                    
                    if ([eventDate timeIntervalSince1970] < endInterval) {
                        int diff = (eventDateInterval - fromInterval) / 86400;
                        NSMutableArray *dayEvents = [weeksEvents objectForKey:[NSNumber numberWithInt:diff]];
                        if (!dayEvents) dayEvents = [NSMutableArray arrayWithCapacity:1];
                        [dayEvents addObject:event];
                        [weeksEvents setObject:dayEvents forKey:[NSNumber numberWithInt:diff]];
                    }
                    eventDate = [NSDate dateWithTimeInterval:86400 sinceDate:eventDate];
                }
            }
        }
        else {
            
            if (selectedInterval > fromInterval && selectedInterval < toInterval) {  // Within the week
                int diff = (selectedInterval - fromInterval) / 86400;
                NSMutableArray *dayEvents = [weeksEvents objectForKey:[NSNumber numberWithInt:diff]];
                if (!dayEvents) dayEvents = [NSMutableArray arrayWithCapacity:1];
                [dayEvents addObject:event];
                [weeksEvents setObject:dayEvents forKey:[NSNumber numberWithInt:diff]];
            }
        }
    }];
    return [weeksEvents copy];
}

+ (void)saveFavoriteByArea:(NSString *)areaName andCategory:(NSString *)categoryName andSubCategory:(NSString *)subCategoryName
{
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"myFavorites.data"];
    NSMutableDictionary *favData = [NSMutableDictionary dictionaryWithContentsOfFile:userPath];
    if (!favData) favData = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *keyName;
    if (!subCategoryName) {
        keyName = [NSString stringWithFormat:@"%@+%@",areaName, categoryName];
    } else {
        keyName = [NSString stringWithFormat:@"%@+%@+%@",areaName, categoryName, subCategoryName];        
    }
    [favData setObject:@" " forKey:keyName];
    BOOL success = [favData writeToFile:userPath atomically:YES];
    if (!success) {
        DLog(@"Problem writing Favorite file");
    }
}

+ (NSDictionary *)fetchFavorites
{
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"myFavorites.data"];
    NSMutableDictionary *favData = [NSMutableDictionary dictionaryWithContentsOfFile:userPath];
    return [favData copy];
}

+ (void)deleteFavoriteByArea:(NSString *)areaName andCategory:(NSString *)categoryName andSubCategory:(NSString *)subCategoryName
{
    NSString *userPath = [[self basePathForTourData] stringByAppendingPathComponent:@"myFavorites.data"];
    NSMutableDictionary *favData = [NSMutableDictionary dictionaryWithContentsOfFile:userPath];
    if (!favData) favData = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString *keyName;
    if (!subCategoryName) {
        keyName = [NSString stringWithFormat:@"%@+%@",areaName, categoryName];
    } else {
        keyName = [NSString stringWithFormat:@"%@+%@+%@",areaName, categoryName, subCategoryName];
    }
    [favData removeObjectForKey:keyName];
    BOOL success = [favData writeToFile:userPath atomically:YES];
    if (!success) {
        DLog(@"Problem writing Favorite file");
    }
}

#pragma mark - Thumbnail Methods
+ (void)createAndStoreThumbnailsForID:(NSNumber *)tourID {
    NSString *pathToPhotoFolder = [self imagePathForTourID:tourID];

    NSError *error;
    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToPhotoFolder error:&error];
    if (!error) {        
        for (NSString *photo in folderContents) {
            NSString *imagePath = [pathToPhotoFolder stringByAppendingPathComponent:photo];
            UIImage *contentImage = [UIImage imageWithContentsOfFile:imagePath];
            
            [self createAndStoreThumbnailForImage:contentImage named:photo atPath:pathToPhotoFolder];
            
            if (error != nil) {
                DLog(@"Error writing thumbnail image: %@", error);
            }
        }
    }
}

// creates a thumbnail for the given image and stores it at the given path
+ (void)createAndStoreThumbnailForImage:(UIImage *)contentImage named:(NSString *)photoName atPath:(NSString *)path {
    UIImage *thumbnail = [self thumbForImage:contentImage withMaxSize:CGSizeMake(50, 50)];
    
    NSData *thumbData;
    if ([[photoName substringFromIndex:([photoName length] - 3)] isEqualToString:@"jpg"])
        thumbData = UIImageJPEGRepresentation(thumbnail, 0.5);
    else if ([[photoName substringFromIndex:([photoName length] - 3)] isEqualToString:@"png"])
        thumbData = UIImagePNGRepresentation(thumbnail);
    else
        thumbData = UIImageJPEGRepresentation(thumbnail, 0.7);
    
    NSString *thumbnailName = [NSString stringWithFormat:@"thmb_%@", photoName];
    NSString *thumbnailPath = [path stringByAppendingPathComponent:thumbnailName];
    NSError *error;
    [thumbData writeToFile:thumbnailPath options:NSDataWritingAtomic error:&error];

}

+ (UIImage*)thumbForImage:(UIImage*)image withMaxSize:(CGSize)maxSize {
    float scaleFactor;
    if (image.size.width > image.size.height)
        scaleFactor = maxSize.width / (double)image.size.width;
    else
        scaleFactor = maxSize.height / (double)image.size.height;
    
    int height = image.size.height * scaleFactor;
    int width = image.size.width * scaleFactor;

    return [LBMGImage imageWithImage:image scaledToSize:CGSizeMake(width, height)];
}

#pragma mark - User Content Methods
+ (void)updateUserContentForTour:(NSNumber *)tourID withItem:(NSDictionary *)item {
    NSString *plistPath = [LBMGUtilities userDataPlistPathForTourID:tourID];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager isWritableFileAtPath:plistPath]) {
        NSMutableArray *itemArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
        [itemArray addObject:item];
        [itemArray writeToFile:plistPath atomically:NO];
        [manager setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate] ofItemAtPath:[[NSBundle mainBundle] bundlePath] error:nil];
    }
}

+ (NSArray *)getUserContentForTour:(NSNumber *)tourID {
    NSString *plistPath = [LBMGUtilities userDataPlistPathForTourID:tourID];
    NSArray *userContent = [NSMutableArray arrayWithContentsOfFile:plistPath];
    return userContent;
}

#pragma mark - Get/Store User data methods
+ (TourData *)getTourDataForTour:(NSNumber *)tourID {
    NSString *plistPath = [LBMGUtilities plistPathForTourID:tourID];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    TourData *tour = [TourData instanceFromDictionary:data];
    return tour;
}

+ (void)storeTourData:(NSDictionary *)tourData forId:(NSNumber *)tourID {
    NSString *plistPath = [LBMGUtilities plistPathForTourID:tourID];
    [tourData writeToFile:plistPath atomically:NO];
}

#pragma mark - Get/Store Touched poi methods
+ (NSArray *)getTouchedPoisForTour:(NSNumber *)tourID {
    NSString *plistPath = [LBMGUtilities userTouchedPoiPlistPathForTourID:tourID];
    NSArray *data = [NSArray arrayWithContentsOfFile:plistPath];
    return data;
}

+ (void)storeTouchedPois:(NSArray *)tourData forId:(NSNumber *)tourID {
    NSString *plistPath = [LBMGUtilities userTouchedPoiPlistPathForTourID:tourID];
    [tourData writeToFile:plistPath atomically:NO];
}

+ (void)deleteTouchedPoisForID:(NSNumber *)tourID {
    NSArray *touchedPois = [[NSArray alloc] init];
    NSString *plistPath = [LBMGUtilities userTouchedPoiPlistPathForTourID:tourID];
    [touchedPois writeToFile:plistPath atomically:YES];
}

+ (NSString *)uniqueDeviceID {
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return idfv;
}

+ (void)buildSponseredEvents:(NSArray *)eventData {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSDictionary *favorites = [LBMGUtilities fetchFavorites];
        
        NSMutableDictionary *datedEvents = [NSMutableDictionary dictionaryWithCapacity:1];
        for (EventCategories *area in eventData) {
            NSString *areaName = area.name;
            for (Category *category in area.categories) {
                NSString *categoryName = category.name;
                NSString *shortkeyName = [NSString stringWithFormat:@"%@+%@",areaName, categoryName];
                for (EventSubCategory *subCategory in category.subCategories) {
                    NSString *subCategoryName = subCategory.name;
                    NSString *longKeyName = [NSString stringWithFormat:@"%@+%@+%@",areaName, categoryName, subCategoryName];
                    for (EventDescription *event in subCategory.events) {
                        if (event.startDate) {
                            if ([favorites objectForKey:shortkeyName] || [favorites objectForKey:longKeyName]) {
                                [datedEvents setObject:event forKey:event.startDate];                    }
                        }
                    }
                }
            }
        }
        ApplicationDelegate.sponsoredEvents = [datedEvents copy];
    });
}

+ (NSDictionary *)favoriteEventsForWeek:(NSDate *)fromDate
{
    NSDictionary *events = ApplicationDelegate.sponsoredEvents;
    
    NSMutableDictionary *weekEvents = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (int i = 0; i < 7; i++) {
        NSMutableArray *dayEvents = [NSMutableArray arrayWithCapacity:1];
        NSTimeInterval fromInterval = [fromDate timeIntervalSince1970] + (i * 84600);
        NSTimeInterval toInterval = fromInterval+86400;
        
        for (EventDescription *event in [events allValues]) {
            NSTimeInterval startInterval = [event.startDate timeIntervalSince1970];
            NSTimeInterval endInterval = [event.endDate timeIntervalSince1970];
            
            if ((endInterval > fromInterval) && (startInterval < toInterval)) {  // Within or overlapping the day
                [dayEvents addObject:event];
            }
        }
        if (dayEvents.count > 0) {
            [weekEvents setObject:dayEvents forKey:[NSNumber numberWithInt:i]];
        }
    }
    return [weekEvents copy];
}

@end
