//
// Created by hivehicks on 10.05.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "HHUnitConverter.h"
#import "PESGraph.h"
#import "PESGraphNode.h"
#import "PESGraphEdge.h"
#import "PESGraphRoute.h"
#import "PESGraphRouteStep.h"

HHConversionRule HHConversionRuleMake(double multiplier, double summand)
{
    HHConversionRule rule;
    rule.multiplier = multiplier;
    rule.summand = summand;
    return rule;
}

HHConversionRule HHConversionRuleMakeInverse(HHConversionRule rule)
{
    return HHConversionRuleMake(1 / rule.multiplier, -rule.summand / rule.multiplier);
}

HHConversionRule HHConversionRuleMakeFromNSValue(NSValue *value)
{
    HHConversionRule rule;
    [value getValue:&rule];
    return rule;
}

NSValue *HHConversionRuleToNSValue(HHConversionRule rule)
{
    return [NSValue value:&rule withObjCType:@encode(HHConversionRule)];
}


@implementation HHUnitConverter {
    PESGraph *_graph;
    NSMutableDictionary *_weights;
}

- (id)init
{
    if (self = [super init]) {
        _graph = [PESGraph new];
        _weights = [NSMutableDictionary new];
    }
    return self;
}

- (void)setConversionRule:(HHConversionRule)rule fromUnit:(NSString *)srcUnit toUnit:(NSString *)targetUnit
{
    PESGraphNode *node1 = [_graph nodeInGraphWithIdentifier:srcUnit];
    if (node1 == nil) {
        node1 = [PESGraphNode nodeWithIdentifier:srcUnit];
    }

    PESGraphNode *node2 = [_graph nodeInGraphWithIdentifier:targetUnit];
    if (node2 == nil) {
        node2 = [PESGraphNode nodeWithIdentifier:targetUnit];
    }

    NSString *directName = [NSString stringWithFormat:@"%@->%@", srcUnit, targetUnit];
    [_graph addEdge:[PESGraphEdge edgeWithName:directName] fromNode:node1 toNode:node2];
    [_weights setObject:HHConversionRuleToNSValue(rule) forKey:directName];

    NSString *inverseName = [NSString stringWithFormat:@"%@->%@", targetUnit, srcUnit];
    [_graph addEdge:[PESGraphEdge edgeWithName:inverseName] fromNode:node2 toNode:node1];
    [_weights setObject:HHConversionRuleToNSValue(HHConversionRuleMakeInverse(rule)) forKey:inverseName];
}

- (void)letUnit:(NSString *)srcUnit convertToUnit:(NSString *)targetUnit byMultiplyingBy:(double)multiplier
{
    [self letUnit:srcUnit convertToUnit:targetUnit byMultiplyingBy:multiplier andAdding:0];
}

- (void)letUnit:(NSString *)srcUnit convertToUnit:(NSString *)targetUnit byAdding:(double)summand
{
    [self letUnit:srcUnit convertToUnit:targetUnit byMultiplyingBy:1 andAdding:summand];
}

- (void)letUnit:(NSString *)srcUnit convertToUnit:(NSString *)targetUnit byMultiplyingBy:(double)multiplier andAdding:(double)summand
{
    [self setConversionRule:HHConversionRuleMake(multiplier, summand) fromUnit:srcUnit toUnit:targetUnit];
}

- (NSNumber *)value:(double)value convertedFromUnit:(NSString *)srcUnit toUnit:(NSString *)targetUnit
{
    if ([srcUnit isEqualToString:targetUnit]) {
        return [NSNumber numberWithDouble:value];
    }

    NSArray *srcUnitComps = [srcUnit componentsSeparatedByString:@"/"];
    NSArray *targetUnitComps = [targetUnit componentsSeparatedByString:@"/"];
    if (srcUnitComps.count != targetUnitComps.count) {
        return nil;
    }

    if (srcUnitComps.count == 1) {
		NSArray *rules = [self _conversionRulesFromUnit:srcUnit toUnit:targetUnit];
        if (rules) {
            return [NSNumber numberWithDouble:[self _valueByApplyingConversionRules:rules toValue:value]];
        }
	} else if (srcUnitComps.count > 1) {
		double result;
		for (int i = 0; i < srcUnitComps.count; i++) {
			if (i == 0) {	// First round
				result = [[self value:value convertedFromUnit:[srcUnitComps objectAtIndex:i] toUnit:[targetUnitComps objectAtIndex:i]] doubleValue];
			} else  {	// Everything else
				result = result / [[self value:1 convertedFromUnit:[srcUnitComps objectAtIndex:i] toUnit:[targetUnitComps objectAtIndex:i]] doubleValue];
			}
		}
		return [NSNumber numberWithDouble:result];
	}

    return nil;
}

#pragma mark -
#pragma mark Private

- (NSArray *)_conversionRulesFromUnit:(NSString *)srcUnit toUnit:(NSString *)targetUnit
{
    NSMutableArray *rules = [NSMutableArray new];

    PESGraphNode *srcNode = [_graph nodeInGraphWithIdentifier:srcUnit];
    PESGraphNode *targetNode = [_graph nodeInGraphWithIdentifier:targetUnit];

    if (srcNode && targetNode) {
        PESGraphRoute *route = [_graph shortestRouteFromNode:srcNode toNode:targetNode];
        if (route) {
            for (PESGraphRouteStep *routeStep in route.steps) {
                if (routeStep.edge) {
                    [rules addObject:[_weights objectForKey:routeStep.edge.name]];
                }
            }
            return [[rules reverseObjectEnumerator] allObjects];
        }
    }

    return nil;
}

- (double)_valueByApplyingConversionRules:(NSArray *)rules toValue:(double)value
{
    HHConversionRule resultingRule = { .multiplier = 1, .summand = 0 };

//    NSLog(@"Rules count: %u", rules.count);

    for (NSValue *ruleValue in rules) {
//    for (int i = 0; i < rules.count; i++) {
//        HHConversionRule *rule = [rules objectAtIndex:i];
//        printf("M%d * ", i + 1);
//        printf("%f * ", [rule multiplier]);
        HHConversionRule rule = HHConversionRuleMakeFromNSValue(ruleValue);
        resultingRule.multiplier *= rule.multiplier;
    }
//    printf("x");
//    printf("%f", value);

    for (int i = rules.count - 1; i >= 0; i--) {

//        printf(" + ");
        double iMultiplier = 1;
        for (int j = 0; j < i; j++) {
//            printf("M%d * ", j + 1);
//            printf("%f * ", [(HHConversionRule *)[rules objectAtIndex:j] multiplier]);
            iMultiplier *= HHConversionRuleMakeFromNSValue([rules objectAtIndex:j]).multiplier;
        }

//        printf("S%d", i + 1);
//        printf("%f", [(HHConversionRule *)[rules objectAtIndex:i] summand]);
        resultingRule.summand += HHConversionRuleMakeFromNSValue([rules objectAtIndex:i]).summand * iMultiplier;
    }

//    printf(";\r\n");
    return (value * resultingRule.multiplier + resultingRule.summand);
}

@end