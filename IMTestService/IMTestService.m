//
//  IMTestService.m
//  IMTestService
//
//  Created by Taras Kalapun on 10.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IMTestService.h"

@interface IMTestService ()
- (NSArray *)usersForGroup:(NSString *)groupName;
- (void)log:(NSString *)text;
@end

@implementation IMTestService

@synthesize application, accountSettings;

- (void)dealloc {
    //self.application = nil;
    self.accountSettings = nil;
    [super dealloc];
}

+ (void)load
{
    [@"start" writeToFile:@"/NSLog.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil]; 
    id fileHandle = [NSFileHandle fileHandleForWritingAtPath:@"/NSLog.txt"]; 
    [fileHandle retain];  
    // Redirect stderr 
    int err = dup2([fileHandle fileDescriptor], STDERR_FILENO);
    if (!err) NSLog(@"Couldn't redirect stderr");
    
    NSLog(@"Loading class");
}

#pragma mark - IMServicePlugIn

/*!
 At instantiation time, you are handed an IMServiceApplication
 which implements the corresponding protocols for each 
 optional protocol that your IMServicePlugIn implements.
 
 @param      serviceApplication  Your service application interface, used
 to communicate upwards to iChat.
 */
- (id)initWithServiceApplication:(id<IMServiceApplication>)serviceApplication
{
    
    
    //NSLog(@"Starting with: %@", serviceApplication);
    
    if ((self=[super init])) {
        //NSLog(@"initing");
        self.application = (id)serviceApplication;
        
    }
    return self;
}


/*!
 iChat calls this method on the IMServicePlugIn prior to login
 with the user's account settings.
 
 @param      accountSettings  An NSDictionary containing the account settings.
 
 Common keys:
 IMServerHostAccountSetting     NSString - the server hostname
 IMServerPortAccountSetting     NSNumber - the server port number
 IMLoginHandleAccountSetting    NSString - the login handle to use
 IMPasswordAccountSetting       NSString - the password
 IMUsesSSLAccountSetting        NSNumber - (YES = use SSL, NO = do not use SSL)
 */
- (oneway void)updateAccountSettings:(NSDictionary *)newAccountSettings
{
    //NSLog(@"updateAccountSettings: %@", newAccountSettings);
    [self log:[NSString stringWithFormat:@"updateAccountSettings: %@", newAccountSettings]];
    self.accountSettings = newAccountSettings;
}


/*!
 iChat calls this method on the IMServicePlugIn instance when the user 
 wishes to log into your service.
 
 iChat will show your service in the "Connecting" state until
 -plugInDidLogIn is called on the service application.
 */
- (oneway void)login
{
    //NSLog(@"login requested");
    [self.application plugInDidLogIn];
    
    
    //[self.application plugInDidReceiveAuthorizationRequestFromHandle:@"testUser"];
    
    [self log:@"logged in"];
}


/*!
 @method     logout
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user 
 wishes to disconnect from your service.
 
 iChat will show your service in the "Disconnecting" state until
 -plugInDidLogOutWithError: is called on the service application.
 */
- (oneway void)logout
{
    //NSLog(@"logout");
    [self.application plugInDidLogOutWithError:nil reconnect:NO];
}

#pragma mark - IMServicePlugInGroupListSupport

/*!
 @method     requestGroupList
 
 @discussion iChat calls this method on the IMServicePlugIn when the user
 finishes modifying the group list.
 
 After a -requestGroupList is requested, the service plug-in should
 respond with -plugInDidUpdateGroupList:error: with the current "truth"
 of the group list.
 
 If any operations from IMServicePlugInGroupListEditingSupport
 are still pending, -plugInDidUpdateGroupList:error: should not be
 called until they finish.
 */
- (oneway void)requestGroupList 
{
    //NSLog(@"requestGroupList");
    
    IMGroupListPermissions allGroupPermissions = IMGroupListCanReorderGroup | IMGroupListCanRenameGroup | IMGroupListCanAddNewMembers | IMGroupListCanRemoveMembers | IMGroupListCanReorderMembers;
    
    NSArray *groups = [NSArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        IMGroupListNameKey, IMGroupListDefaultGroup,
                        IMGroupListPermissionsKey, [NSNumber numberWithUnsignedInteger:IMGroupListCanAddNewMembers],
                        IMGroupListHandlesKey, [self usersForGroup:nil],
                        nil],
                       /*
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        IMGroupListNameKey, @"first",
                        IMGroupListPermissionsKey, [NSNumber numberWithUnsignedInteger:allGroupPermissions],
                        IMGroupListHandlesKey, [NSArray array],
                        nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        IMGroupListNameKey, @"test",
                        IMGroupListPermissionsKey, [NSNumber numberWithUnsignedInteger:allGroupPermissions],
                        IMGroupListHandlesKey, [NSArray arrayWithObjects:@"testUser", nil],
                        nil], 
                        */
                       nil];
    
    //NSLog(@"sending test groups: %@", groups);
    [self log:[NSString stringWithFormat:@"sending test groups: %@ \n to app: %@ ", groups, self.application]];
    
    //NSLog(@"app alive: %@", self.application);
    
    NSError *error = nil;
    [self.application plugInDidUpdateGroupList:groups error:error];
    

}

#pragma mark - IMServicePlugInGroupListEditingSupport <IMServicePlugInGroupListSupport>


/*!
 @method     addGroups:
 
 @discussion iChat calls this method when the user had added one or 
 more groups to the group list.
 
 @param      groupNames  An array of NSString objects, corresponding to the
 names of the added groups
 */
- (oneway void)addGroups:(NSArray *)groupNames
{
    //NSLog(@"addGroups: %@", groupNames);
    [self log:[NSString stringWithFormat:@"add groups: %@", groupNames]];
}


/*!
 @method     removeGroups:
 
 @discussion iChat calls this method when the user had removed one or
 more groups from the group list.
 
 @param      groupNames  An array of NSString objects, corresponding to the
 names of the removed groups
 */
- (oneway void)removeGroups:(NSArray *)groupNames 
{
    //NSLog(@"removeGroups: %@", groupNames);
    [self log:[NSString stringWithFormat:@"remove groups: %@", groupNames]];
}


/*!
 @method     renameGroup:toGroup:
 
 @discussion iChat calls this method when the user renames a group.
 
 @param      oldGroupName  The former name of the group
 @param      newGroupName  The new name of the group
 */
- (oneway void)renameGroup:(NSString *)oldGroupName toGroup:(NSString *)newGroupName 
{
    NSLog(@"renameGroup %@ to %@", oldGroupName, newGroupName);
}


/*!
 @method     addHandles:toGroup:
 
 @discussion iChat calls this method when the user adds member handles to a group.
 
 In the event that the user moves a member from one group to
 another group, iChat will first call this method for the
 destination group, and then call -removeHandles:fromGroup:
 for the source group.
 
 @param      handles    The added handles
 @param      groupName  The name of the group
 */
- (oneway void)addHandles:(NSArray *)handles toGroup:(NSString *)groupName 
{
    //NSLog(@"addHandles: %@ to: %@", handles, groupName);
    [self log:[NSString stringWithFormat:@"add handles: %@ to: %@", handles, groupName]];
}


/*!
 @method     removeHandles:fromGroup:
 
 @discussion iChat calls this method when the adds member handles to a group.
 
 In the event that the user moves a member from one group to
 another group, iChat will first call -addHandles:toGroup: 
 for the destination group, and then call this method for
 the source group.
 
 @param      handles    The removed handles
 @param      groupName  The name of the group
 */
- (oneway void)removeHandles:(NSArray *)handles fromGroup:(NSString *)groupName
{
    NSLog(@"removeHandles: %@ to: %@", handles, groupName);
}


#pragma mark - IMServicePlugInGroupListAuthorizationSupport <IMServicePlugInGroupListSupport>


/*!
 @method     sendAuthorizationRequestToHandle:
 
 @discussion When iChat adds a handle to the group list on a service which requires authorization,
 it will call -sendAuthorizationRequestToHandle: for each handle after 
 -addHandles:toGroup:
 
 @param      handle     The handle from which to request authorization
 */
- (oneway void)sendAuthorizationRequestToHandle:(NSString *)handle 
{
    NSLog(@"sendAuthorizationRequestToHandle: %@", handle);
}


/*!
 @method     acceptAuthorizationRequestFromHandle:
 
 @discussion When the user clicks the "Accept" button on a pending authorization request.  iChat
 calls this method on the service plug-in
 
 @param      handle     The handle to authorize
 */
- (oneway void)acceptAuthorizationRequestFromHandle:(NSString *)handle
{
    NSLog(@"acceptAuthorizationRequestFromHandle: %@", handle);
}


/*!
 @method     declineAuthorizationRequestFromHandle:
 
 @discussion When the user clicks the "Decline" button on a pending authorization request.  iChat
 calls this method on the service plug-in
 
 @param      handle     The handle to not authorize
 */
- (oneway void)declineAuthorizationRequestFromHandle:(NSString *)handle 
{
    NSLog(@"declineAuthorizationRequestFromHandle: %@", handle);
}

#pragma mark - IMServicePlugInGroupListHandlePictureSupport



#pragma mark - IMServicePlugInInstantMessagingSupport


/*!
 @method     userDidStartTypingToHandle:
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user starts
 typing a message to a specific handle from the input line.
 
 @param      handle  The handle to which the user has started typing.
 */
- (oneway void)userDidStartTypingToHandle:(NSString *)handle 
{
    NSLog(@"userDidStartTypingToHandle: %@", handle);
}


/*!
 @method     userDidStopTypingToHandle:
 
 @discussion iChat calls this method on the IMServicePlugIn instance if the user clears the input line
 after typing instead of sending the message.
 
 @param      handle  The handle to which the user started typing, but then cleared the input line.
 */
- (oneway void)userDidStopTypingToHandle:(NSString *)handle 
{
    NSLog(@"userDidStopTypingToHandle: %@", handle);
}


/*!
 @method     sendMessage:toHandle:
 
 @discussion iChat calls this method on the IMServicePlugIn instance when the user sends a message
 to a specific handle.
 
 To indicate successful delivery of the message (and have it show up in iChat), the
 IMServicePlugIn should reflect the message via
 
 -[id<IMServiceApplicationInstantMessagingSupport> plug-inDidSendMessage:toHandle:error:]
 
 with a nil error.  A non-nil error indicates that the message could not be sent.
 
 @param      message  The message to send
 @param      handle   The receipient of the message
 */
- (oneway void)sendMessage:(IMServicePlugInMessage *)message toHandle:(NSString *)handle 
{
    NSLog(@"sendMessage: %@ to: %@", message, handle);
}

#pragma mark - IMServicePlugInPresenceSupport

/*!
 Chat calls this method on the IMServicePlugIn instance when the 
 the user's availability, status message, idle state, or picture
 changes.
 
 @param      properties  A dictionary, corresponding to the modified session properties
 
 Available keys include:
 IMSessionPropertyAvailability   - the user's availablility
 IMSessionPropertyStatusMessage  - the user's status message
 IMSessionPropertyPictureData    - the user's icon
 IMSessionPropertyIdleDate       - the time of the last user activity
 IMSessionPropertyIsInvisible    - If YES, the user wishes to appear offline to other users
 */

- (oneway void)updateSessionProperties:(NSDictionary *)properties
{
    NSLog(@"updateSessionProperties: %@", properties);
}

#pragma mark - IMServicePlugInFileTransferSessionSupport

- (oneway void)startOutgoingFileTransferSession:(IMServicePlugInOutgoingFileTransferSession *)session toHandle:(NSString *)handle
{
    NSLog(@"startOutgoingFileTransferSession: %@ to: %@", session, handle);
}

- (oneway void)acceptIncomingFileTransferSession:(IMServicePlugInIncomingFileTransferSession *)session
{
    NSLog(@"acceptIncomingFileTransferSession: %@", session);
}

- (oneway void)cancelFileTransferSession:(IMServicePlugInFileTransferSession *)session
{
    NSLog(@"cancelFileTransferSession: %@", session);
}



#pragma mark - Private


- (void)log:(NSString *)text
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text];
    IMServicePlugInMessage *msg = [IMServicePlugInMessage servicePlugInMessageWithContent:attrString];
    [attrString release];
    
    [self.application plugInDidReceiveMessage:msg fromHandle:@"log"];
}

- (NSArray *)usersForGroup:(NSString *)groupName
{
    NSMutableArray *users = [NSMutableArray array];
    
    int n = 5;
    for (int i=0; i<n; i++) {
        NSString *user = [NSString stringWithFormat:@"testUser%d", i];
        [users addObject:user];
    }
    
    return (NSArray *)users;
}



@end

