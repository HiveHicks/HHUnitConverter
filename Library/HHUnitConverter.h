//
// Created by hivehicks on 10.05.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef struct {
    double multiplier;
    double summand;
} HHConversionRule;

extern HHConversionRule HHConversionRuleMake(double multiplier, double summand);
extern HHConversionRule HHConversionRuleMakeInverse(HHConversionRule rule);
extern HHConversionRule HHConversionRuleMakeFromNSValue(NSValue *value);
extern NSValue *HHConversionRuleToNSValue(HHConversionRule rule);


@interface HHUnitConverter : NSObject

- (void)setConversionRule:(HHConversionRule)rule fromUnit:(NSString *)srcUnit toUnit:(NSString *)targetUnit;

- (void)letUnit:(NSString *)srcUnit convertToUnit:(NSString *)targetUnit byMultiplyingBy:(double)multiplier;
- (void)letUnit:(NSString *)srcUnit convertToUnit:(NSString *)targetUnit byAdding:(double)summand;
- (void)letUnit:(NSString *)srcUnit convertToUnit:(NSString *)targetUnit byMultiplyingBy:(double)multiplier andAdding:(double)summand;

- (NSNumber *)value:(double)value convertedFromUnit:(NSString *)srcUnit toUnit:(NSString *)targetUnit;

@end