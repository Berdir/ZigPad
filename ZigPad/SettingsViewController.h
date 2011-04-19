//
//  SettingsViewController.h
//  ZigPad
//
//  Created by ceesar on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZigPadSettings.h"


@interface SettingsViewController : UIViewController {
    
    
    
}
@property (nonatomic, retain) IBOutlet UISwitch *simSwitch;
@property (nonatomic, retain) IBOutlet UITextField *textfield;

-(IBAction)changeConfigHost:(id)sender;
-(IBAction)switchSimulationMode:(id)sender;

@end
