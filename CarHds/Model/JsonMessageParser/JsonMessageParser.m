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

+(NSString *)contributionMessageWithContributionIndex:(CONTRIBUTION_TYPE)contributionIndex withValue:(CONTRIBUTION_VALUE)value
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

+(NSString *)cardVoteMessageForCard:(NSInteger)cardNo withValue:(BOOL)value
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

+(BOOL)decodeMessage:(QBChatMessage *)message withDelegate:(NSObject<JsonMessageParserDelegate> *)delegate
{
    NSData *theData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dict = [[CJSONDeserializer deserializer] deserialize:theData error:nil];
    
    NSString* target = [dict objectForKey:MESSAGE_TARGET];
    if([target isEqualToString:MESSAGE_TARGET_BROADCAST])
    {
        NSString* type = [dict objectForKey:MESSAGE_BROADCAST_TYPE];
        if([type isEqualToString:MESSAGE_BROADCAST_TYPE_CONCLUDE])
        {
            [delegate receivedConclusionSignal];
            return YES;
        }
    }else if ([target isEqualToString:MESSAGE_HOST_TYPE])
    {
        
        NSString* type = [dict objectForKey:MESSAGE_HOST_TYPE];
        if([type isEqualToString:MESSAGE_HOST_TYPE_LOGIN])
        {
            [delegate receivedLoginMessageForUsername:[dict objectForKey:MESSAGE_LOGIN_USERNAME] andUserID:message.senderID];
            return YES;
        }else if ([type isEqualToString:MESSAGE_HOST_TYPE_CONCLUDE])
        {
            
            CONTRIBUTION_TYPE subType = (CONTRIBUTION_TYPE)[dict objectForKey:MESSAGE_CONCLUDE_CONTRIBUTION_TYPE];
            CONTRIBUTION_VALUE value = (CONTRIBUTION_VALUE) [dict objectForKey:MESSAGE_CONCLUDE_CONTRIBUTION_VALUE];
            [delegate receivedContributionMessageForType:subType withValue:value fromUserID:message.senderID];
            return YES;
        }else if ([type isEqualToString:MESSAGE_HOST_TYPE_CARD_VOTE])
        {
           NSInteger number =  [[dict objectForKey:MESSAGE_CARD_VOTE_CARD_NO] integerValue];
            BOOL val = [[dict objectForKey:MESSAGE_CARD_VOTE_VALUE] boolValue];
            [delegate receivedCardVoteForCard:number withValue:val];
            return YES;
        }
        
    }


    return NO;
}
@end
