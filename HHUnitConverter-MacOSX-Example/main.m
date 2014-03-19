//
//  main.m
//  HHUnitConverter
//
//  Created by HiveHicks on 05/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HHUnitConverter.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        HHUnitConverter *converter = [HHUnitConverter new];

        // weight
        [converter letUnit:@"kg" convertToUnit:@"g" byMultiplyingBy:1000];

        // distances
        [converter letUnit:@"mi" convertToUnit:@"km" byMultiplyingBy:1.609344];
        [converter letUnit:@"km" convertToUnit:@"m" byMultiplyingBy:1000];
        [converter letUnit:@"m" convertToUnit:@"cm" byMultiplyingBy:100];

        // temperature
        [converter letUnit:@"K" convertToUnit:@"C" byAdding:-273];
		
		// time
		[converter letUnit:@"h" convertToUnit:@"min" byMultiplyingBy:60];
		[converter letUnit:@"min" convertToUnit:@"s" byMultiplyingBy:60];
		[converter letUnit:@"s" convertToUnit:@"ms" byMultiplyingBy:1000];

        // some imaginary units
        [converter letUnit:@"u1" convertToUnit:@"u2" byMultiplyingBy:10 andAdding:1];
        [converter letUnit:@"u2" convertToUnit:@"u3" byMultiplyingBy:20 andAdding:2];

        // simple unit conversion

        NSLog(@"1 kg = %@ g", [converter value:1 convertedFromUnit:@"kg" toUnit:@"g"]);
        NSLog(@"300 mi = %@ km", [converter value:300 convertedFromUnit:@"mi" toUnit:@"km"]);
        NSLog(@"300 km = %@ mi", [converter value:300 convertedFromUnit:@"km" toUnit:@"mi"]);
        NSLog(@"300 mi = %@ cm", [converter value:300 convertedFromUnit:@"mi" toUnit:@"cm"]);
        NSLog(@"482803.2 m = %@ mi", [converter value:482803.2 convertedFromUnit:@"m" toUnit:@"mi"]);
        NSLog(@"48280320 cm = %@ mi", [converter value:48280320 convertedFromUnit:@"cm" toUnit:@"mi"]);
        NSLog(@"48280320 cm = %@ K", [converter value:48280320 convertedFromUnit:@"cm" toUnit:@"K"]);
        NSLog(@"3 u1 = %@ u3", [converter value:3 convertedFromUnit:@"u1" toUnit:@"u3"]);
        NSLog(@"0 Celcius = %@ Kelvin", [converter value:0 convertedFromUnit:@"C" toUnit:@"K"]);

        // compound unit conversion
        NSLog(@"6 C/km = %@ K/mi", [converter value:6 convertedFromUnit:@"C/km" toUnit:@"K/mi"]);
        NSLog(@"6 C/km = %f K/100 mi", 100 * [[converter value:6 convertedFromUnit:@"C/km" toUnit:@"K/mi"] doubleValue]);
		NSLog(@"6 C/km/h = %f K/mi/min", [[converter value:6 convertedFromUnit:@"C/km/h" toUnit:@"K/mi/min"] doubleValue]);
    }

    return 0;
}
