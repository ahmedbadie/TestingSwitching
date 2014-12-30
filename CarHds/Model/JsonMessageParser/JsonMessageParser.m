//
//  JsonMessageParser.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "JsonMessageParser.h"

@implementation JsonMessageParser


+(NSString *)loginMessageWithUsername:(NSString *)username
{
    
    NSDictionary* dictionary = @{
                                 MESSAGE_TARGET:MESSAGE_TARGET_HOST,
                                 MESSAGE_HOST_TYPE: MESSAGE_HOST_TYPE_LOGIN,
                                 MESSAGE_LOGIN_USERNAME: username
                                 };
    CJSONSerializer* json = [[CJSONSerializer alloc]init];
    NSData *jsonData = [json serializeDictionary:dictionary error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

+(NSString *)contributionMessageWithContributionIndex:(CONTRIBUTION_TYPE)contributionIndex withValue:(NSInteger)value
{
    
    NSDictionary* dictionary = @{MESSAGE_TARGET:MESSAGE_TARGET_HOST,
                                 MESSAGE_HOST_TYPE: MESSAGE_HOST_TYPE_CONCLUDE,
                                 MESSAGE_CONCLUDE_CONTRIBUTION_TYPE:@(contributionIndex),
                                 MESSAGE_CONCLUDE_CONTRIBUTION_VALUE:@(value)
                                 };
    CJSONSerializer* json = [[CJSONSerializer alloc]init];
    NSData* jsonData = [json serializeDictionary:dictionary error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(NSString *)cardVoteMessageForCard:(NSInteger)cardNo withValue:(NSInteger)value
{
    NSDictionary* dictionary = @{MESSAGE_TARGET:MESSAGE_TARGET_HOST,
                                 MESSAGE_HOST_TYPE: MESSAGE_HOST_TYPE_CARD_VOTE,
                                 MESSAGE_CARD_VOTE_CARD_NO:@(cardNo),
                                 MESSAGE_CARD_VOTE_VALUE:@(value)
                                 };
    CJSONSerializer* json = [[CJSONSerializer alloc]init];
    NSData* jsonData = [json serializeDictionary:dictionary error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];}

+(NSString*) broadcastContributionSignal
{
    NSDictionary* dictionary = @{MESSAGE_TARGET:MESSAGE_TARGET_BROADCAST,
                                 MESSAGE_BROADCAST_TYPE: MESSAGE_BROADCAST_TYPE_CONCLUDE};
    CJSONSerializer* json = [[CJSONSerializer alloc]init];
    NSData* jsonData = [json serializeDictionary:dictionary error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
@end
