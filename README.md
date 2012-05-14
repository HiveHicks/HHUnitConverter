HHUnitConverter
===============

Unit conversion library for Objective-C

Usage
---------------

Conversions in the library are based on formula _y = A * x + B_, where _x_ is a source value, _y_ is a target value, _A_ is a multiplier and _B_ is a summand in a conversion rule.

For instance, miles can be converted to kilometers by multiplying _x_ by 1.6. So, in this case _A_ = 1.6 and _B_ = 0. Kelvin value is converted to Celcius by subtracting 273, so for Kelvin-to-Celsius conversion: _A_ = 1, _B_ = -273. To specify the rule you have a generic `setConversionRule:fromUnit:toUnit:` method, but you are more likely to use convenience methods that start with `letUnit:convertToUnit:...`

To use conversion library you first need to create an instance of `HHUnitConverter` and set convertion rules that you need:

	HHUnitConverter *converter = [HHUnitConverter new];
	[converter letUnit:@"mi" convertToUnit:@"km" byMultiplyingBy:1.609344];
	[converter letUnit:@"km" convertToUnit:@"m" byMultiplyingBy:1000];
	[converter letUnit:@"m" convertToUnit:@"cm" byMultiplyingBy:100];
	
Then you can use converter object to convert values however you like. Converter is clever enough to find out dependencies between units that you've registered conversion rules with (as well as backward dependencies), so when you say that miles can be converted to kilometers, and kilometers can be converted to meters, it knows how to convert miles to meters correctly (and vice versa), so it's OK to have a call like that:

	[converter value:482803.2 convertedFromUnit:@"m" toUnit:@"mi"]
	
Of course, it will handle the simplest cases like that:

	[converter value:300 convertedFromUnit:@"mi" toUnit:@"km"]

Also, the library can handle compound units conversion, so, for instance, you can convert "litres per kilometer" to "gallons per mile" using code like that:

	[converter letUnit:@"mi" convertToUnit:@"km" byMultiplyingBy:1.609344];
	[converter letUnit:@"gal" convertToUnit:@"L" byMultiplyingBy:3.78541178];
	[converter value:20 convertedFromUnit:@"L/km" toUnit:@"gal/mi"];