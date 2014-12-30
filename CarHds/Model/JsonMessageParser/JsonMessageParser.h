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

@interface JsonMessageParser : NSObject

+(NSString*) loginMessageWithUsername:(NSString*)username;
+(NSString*) contributionMessageWithContributionIndex:(CONTRIBUTION_TYPE) contributionIndex withValue:(NSInteger) value;
+(NSString*) broadcastContributionSignal;
+(NSString*) cardVoteMessageForCard:(NSInteger) cardNo withValue:(NSInteger) value;

@end
