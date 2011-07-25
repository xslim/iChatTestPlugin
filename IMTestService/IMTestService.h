//
//  IMTestService.h
//  IMTestService
//
//  Created by Taras Kalapun on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <IMServicePlugIn/IMServicePlugIn.h>
#import <IMServicePlugIn/IMServicePlugInFileTransferSessionSupport.h>

@interface IMTestService : NSObject <IMServicePlugIn, IMServicePlugInGroupListSupport, IMServicePlugInGroupListEditingSupport, IMServicePlugInGroupListAuthorizationSupport, IMServicePlugInInstantMessagingSupport, IMServicePlugInPresenceSupport, IMServicePlugInFileTransferSessionSupport>


@property (assign) id <IMServiceApplicationGroupListAuthorizationSupport, IMServiceApplicationInstantMessagingSupport> application;
@property (retain) NSDictionary *accountSettings;

@end
