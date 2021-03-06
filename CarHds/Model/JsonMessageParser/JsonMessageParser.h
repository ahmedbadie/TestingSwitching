//
//  JsonMessageParser.h
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import <Quickblox/QBChatMessage.h>

#define MESSAGE_TARGET @"target"
#define MESSAGE_TARGET_BROADCAST @"broadcast"
#define MESSAGE_TARGET_HOST @"host"
#define MESSAGE_BROADCAST_TYPE @"type"
#define MESSAGE_BROADCAST_TYPE_CONCLUDE @"conclude"
#define MESSAGE_BROADCAST_TYPE_DUMMY @"dummy"
#define MESSAGE_HOST_TYPE @"type"
#define MESSAGE_HOST_NAME @"hostName"
#define MESSAGE_HOST_TYPE_LOGIN @"login"
#define MESSAGE_HOST_TYPE_LOGOUT @"logout"
#define MESSAGE_BROADCAST_TYPE_CLOSE @"closeRoom"
#define MESSAGE_BROADCAST_TYPE_NAME @"shareName"
#define MESSAGE_HOST_TYPE_CARD_VOTE @"cardVote"
#define MESSAGE_HOST_TYPE_CONCLUDE @"conclude"
#define MESSAGE_CARD_VOTE_CARD_NO @"cardNo"
#define MESSAGE_CARD_VOTE_VALUE @"value"
#define MESSAGE_CONCLUDE_CONTRIBUTION_TYPE @"contributionType"
#define MESSAGE_CONCLUDE_CONTRIBUTION_VALUE @"value"
#define MESSAGE_LOGIN_USERNAME @"username"
#define MESSAGE_LOGIN_FULLNAME @"fullname"

typedef enum
{
    CONTRIBUTION_TYPE_MEETING=0,
    CONTRIBUTION_TYPE_PERSONAL=1,
}CONTRIBUTION_TYPE;

typedef enum{
    CONTRIBUTION_VALUE_FIRST=0,
    CONTRIBUTION_VALUE_SECOND=1,
    CONTRIBUTION_VALUE_THIRD=2
    
} CONTRIBUTION_VALUE;
typedef enum{
    MessageTragetBroadcast=0,
    MessageTragetHost=1
} MessageTraget;


@protocol JsonMessageParserDelegate <NSObject>

-(void) receivedLoginMessageForUsername:(NSString*)username fullname:(NSString *)fullName fromMsg:(QBChatMessage*) msg;
-(void) receivedConclusionSignal;
-(void) receivedCardVoteForCard:(NSInteger) cardNo withValue:(BOOL) val fromMsg:(QBChatMessage*) msg;
-(void) receivedContributionMessageForType:(CONTRIBUTION_TYPE) type withValue:(CONTRIBUTION_VALUE) val fromMsg:(QBChatMessage*)msg;
-(void) logOutUser:(NSString*) username fromMsg:(QBChatMessage*) msg;
-(void) receivedCloseRoom;
@end
@interface JsonMessageParser : NSObject

+(NSString*) loginMessageWithUsername:(NSString *)username fullname:(NSString *)fullname;
+(NSString*) contributionMessageWithContributionIndex:(CONTRIBUTION_TYPE) contributionIndex withValue:(CONTRIBUTION_VALUE) value;
+(NSString*) broadcastContributionSignal;
+(NSString*) cardVoteMessageForCard:(NSInteger) cardNo withValue:(BOOL) value;
+(NSString*) logOutMessageForUser:(NSString*)username;
+(NSString*) dummyMessage;
+(NSString*)hostNameShareMessage;
+(NSString*) closeRoomMessage;
+(BOOL) isCloseRoomMessage:(NSString*) msg;
+(BOOL) decodeMessage:(QBChatMessage*) message withDelegate:(NSObject<JsonMessageParserDelegate>*) delegate;
@end
