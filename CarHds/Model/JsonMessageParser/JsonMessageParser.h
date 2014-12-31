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
#import <Quickblox/Quickblox.h>
#define MESSAGE_TARGET @"target"
#define MESSAGE_TARGET_BROADCAST @"broadcast"
#define MESSAGE_TARGET_HOST @"host"
#define MESSAGE_BROADCAST_TYPE @"type"
#define MESSAGE_BROADCAST_TYPE_CONCLUDE @"conclude"
#define MESSAGE_HOST_TYPE @"type"
#define MESSAGE_HOST_TYPE_LOGIN @"login"
#define MESSAGE_HOST_TYPE_CARD_VOTE @"cardVote"
#define MESSAGE_HOST_TYPE_CONCLUDE @"conclude"
#define MESSAGE_CARD_VOTE_CARD_NO @"cardNo"
#define MESSAGE_CARD_VOTE_VALUE @"value"
#define MESSAGE_CONCLUDE_CONTRIBUTION_TYPE @"contributionType"
#define MESSAGE_CONCLUDE_CONTRIBUTION_VALUE @"value"
#define MESSAGE_LOGIN_USERNAME @"username"

typedef enum
{
    CONTRIBUTION_TYPE_MEETING=0,
    CONTRIBUTION_TYPE_PERSONAL,
}CONTRIBUTION_TYPE;

typedef enum{
    CONTRIBUTION_VALUE_FIRST=0,
    CONTRIBUTION_VALUE_SECOND,
    CONTRIBUTION_VALUE_THIRD
    
} CONTRIBUTION_VALUE;
typedef enum{
    MessageTragetBroadcast=0,
    MessageTragetHost
} MessageTraget;


@protocol JsonMessageParserDelegate <NSObject>

-(void) receivedLoginMessageForUsername:(NSString*) username  fromMsg:(QBChatMessage*) msg;
-(void) receivedConclusionSignal;
-(void) receivedCardVoteForCard:(NSInteger) cardNo withValue:(BOOL) val fromMsg:(QBChatMessage*) msg;
-(void) receivedContributionMessageForType:(CONTRIBUTION_TYPE) type withValue:(CONTRIBUTION_VALUE) val fromMsg:(QBChatMessage*)msg;

@end
@interface JsonMessageParser : NSObject

+(NSString*) loginMessageWithUsername:(NSString*)username;
+(NSString*) contributionMessageWithContributionIndex:(CONTRIBUTION_TYPE) contributionIndex withValue:(CONTRIBUTION_VALUE) value;
+(NSString*) broadcastContributionSignal;
+(NSString*) cardVoteMessageForCard:(NSInteger) cardNo withValue:(BOOL) value;
+(BOOL) decodeMessage:(QBChatMessage*) message withDelegate:(NSObject<JsonMessageParserDelegate>*) delegate;
@end
