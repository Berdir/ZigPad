// For iOS
#import <GHUnitIOS/GHUnit.h>
#import "ZigPadSettings.h"


@interface SettingsTest : GHTestCase { }
@end

@implementation SettingsTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)testSimulationMode {
    
    ZigPadSettings *s = [ZigPadSettings sharedInstance];
    
    s.simulationMode = TRUE;
    
    GHAssertTrue(s.simulationMode, @"SimulationMode is on");
    
    s.simulationMode = FALSE;
    
    GHAssertFalse(s.simulationMode, @"SimulationMode is off");
}

- (void)testIPPort {
    
    ZigPadSettings *s = [ZigPadSettings sharedInstance];
    [s setIP:@"127.0.0.1" simulationMode:FALSE];
    [s setIP:@"127.0.0.2" simulationMode:TRUE];
    
    [s setPort:1234 simulationMode:FALSE];
    [s setPort:4321 simulationMode:TRUE];
    
    s.simulationMode = TRUE;
    GHAssertEqualStrings(s.ip, @"127.0.0.2", @"IP %@ is correct for Simulator", s.ip);
    GHAssertTrue(s.port == 4321, @"Port %d is correct for Simulator", s.port);
    
    s.simulationMode = FALSE;
    GHAssertEqualStrings(s.ip, @"127.0.0.1", @"IP %@ is correct for Simulator", s.ip);
    GHAssertTrue(s.port == 1234, @"Port %d is correct for Simulator", s.port);
}

@end