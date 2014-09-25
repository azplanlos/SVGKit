#import "SVGLength.h"

#import "SVGKCSSPrimitiveValue.h"
#import "SVGKCSSPrimitiveValue_ConfigurablePixelsPerInch.h"

#import "SVGUtils.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@interface SVGLength()
@property(nonatomic,retain) SVGKCSSPrimitiveValue* internalCSSPrimitiveValue;
@end

@implementation SVGLength

@synthesize unitType;
@synthesize value;
@synthesize valueInSpecifiedUnits;
@synthesize valueAsString;
@synthesize internalCSSPrimitiveValue;

- (void)dealloc {
    self.valueAsString = nil;
    self.internalCSSPrimitiveValue = nil;
    [super dealloc];
}

- (id)init
{
    NSAssert(FALSE, @"This class must not be init'd. Use the static hepler methods to instantiate it instead");
    return nil;
}

- (id)initWithCSSPrimitiveValue:(SVGKCSSPrimitiveValue*) pv
{
    self = [super init];
    if (self) {
        self.internalCSSPrimitiveValue = pv;
    }
    return self;
}

-(float)value
{
	return [self.internalCSSPrimitiveValue getFloatValue:self.internalCSSPrimitiveValue.primitiveType];
}

-(SVG_LENGTH_TYPE)unitType
{
	switch( self.internalCSSPrimitiveValue.primitiveType )
	{
		case CSS_CM:
			return SVG_LENGTHTYPE_CM;
		case CSS_EMS:
			return SVG_LENGTHTYPE_EMS;
		case CSS_EXS:
			return SVG_LENGTHTYPE_EXS;
		case CSS_IN:
			return SVG_LENGTHTYPE_IN;
		case CSS_MM:
			return SVG_LENGTHTYPE_MM;
		case CSS_PC:
			return SVG_LENGTHTYPE_PC;
		case CSS_PERCENTAGE:
			return SVG_LENGTHTYPE_PERCENTAGE;
		case CSS_PT:
			return SVG_LENGTHTYPE_PT;
		case CSS_PX:
			return SVG_LENGTHTYPE_PX;
		case CSS_NUMBER:
		case CSS_DIMENSION:
			return SVG_LENGTHTYPE_NUMBER;
		default:
			return SVG_LENGTHTYPE_UNKNOWN;
	}
}

-(void) newValueSpecifiedUnits:(SVG_LENGTH_TYPE) unitType valueInSpecifiedUnits:(float) valueInSpecifiedUnits
{
	NSAssert(FALSE, @"Not supported yet");
}

-(void) convertToSpecifiedUnits:(SVG_LENGTH_TYPE) unitType
{
	NSAssert(FALSE, @"Not supported yet");
}

/** Apple calls this method when the class is loaded; that's as good a time as any to calculate the device / screen's PPI */
+(void)initialize
{
	cachedDevicePixelsPerInch = [self pixelsPerInchForCurrentDevice];
}

+(SVGLength*) svgLengthZero
{
	SVGLength* result = [[[SVGLength alloc] initWithCSSPrimitiveValue:nil] autorelease];
	
	return result;
}

static float cachedDevicePixelsPerInch;
+(SVGLength*) svgLengthFromNSString:(NSString*) s
{
	SVGKCSSPrimitiveValue* pv = [[[SVGKCSSPrimitiveValue alloc] init] autorelease];
	
	pv.pixelsPerInch = cachedDevicePixelsPerInch;
	pv.cssText = s;
	
	SVGLength* result = [[[SVGLength alloc] initWithCSSPrimitiveValue:pv] autorelease];
	
	return result;
}

-(float) pixelsValue
{
	return [self.internalCSSPrimitiveValue getFloatValue:CSS_PX];
}

-(float) numberValue
{
	return [self.internalCSSPrimitiveValue getFloatValue:CSS_NUMBER];
}

#pragma mark - secret methods needed to provide an implementation on ObjectiveC

+(float) pixelsPerInchForCurrentDevice
{
	/** Using this as reference: http://en.wikipedia.org/wiki/Retina_Display 
      */
	
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	
	if( [platform hasPrefix:@"iPhone1"]
	|| [platform hasPrefix:@"iPhone2"]
	|| [platform hasPrefix:@"iPhone3"])
		return 163.0f;
	
    if( [platform hasPrefix:@"iPhone4"]
       || [platform hasPrefix:@"iPhone5"]
       || [platform hasPrefix:@"iPhone6"]
       || [platform hasPrefix:@"iPhone7,2"]) {
        return 326.0f;
    }
    
    if ( [platform hasPrefix:@"iPhone7,1"]) {
        return 401.0f;
    }
	
	if( [platform hasPrefix:@"iPhone"]) // catch-all for higher-end devices not yet existing
	{
		NSAssert(FALSE, @"Not supported yet: you are using an iPhone that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
		return 401.0f;
	}
	
	if( [platform hasPrefix:@"iPod1"]
	   || [platform hasPrefix:@"iPod2"]
	   || [platform hasPrefix:@"iPod3"])
		return 163.0f;
	
	if( [platform hasPrefix:@"iPod4"]
	   || [platform hasPrefix:@"iPod5"])
		return 326.0f;
	
	if( [platform hasPrefix:@"iPod"]) // catch-all for higher-end devices not yet existing
	{
		NSAssert(FALSE, @"Not supported yet: you are using an iPod that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
		return 326.0f;
	}
	
	if( [platform hasPrefix:@"iPad1"]
	|| [platform hasPrefix:@"iPad2"])
		return 132.0f;
	if( [platform hasPrefix:@"iPad3"]
	|| [platform hasPrefix:@"iPad4"])
		return 264.0f;
	if( [platform hasPrefix:@"iPad"]) // catch-all for higher-end devices not yet existing
	{
		NSAssert(FALSE, @"Not supported yet: you are using an iPad that didn't exist when this code was written, we have no idea what the pixel count per inch is!");
		return 264.0f;
	}
	
	if( [platform hasPrefix:@"x86_64"])
	{
		DDLogCWarn(@"[%@] WARNING: you are running on the simulator; it's impossible for us to calculate centimeter/millimeter/inches units correctly", [self class]);
		return 132.0f; // Simulator, running on desktop machine
	}
	
	NSAssert(FALSE, @"Cannot determine the PPI values for current device; returning 0.0f - hopefully this will crash your code (you CANNOT run SVG's that use CM/IN/MM etc until you fix this)" );
	return 0.0f; // Bet you'll get a divide by zero here...
}

@end
