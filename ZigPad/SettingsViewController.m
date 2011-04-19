//
//  SettingsViewController.m
//  ZigPad
//
//  Created by Markus Zimmermann on 4/19/11.
//  Copyright 2011 Ceesar. All rights reserved.
//

#import "SettingsViewController.h"



@implementation SettingsViewController


@synthesize simSwitch = _simSwitch;
@synthesize textfield = _textfield;


//called when return Button on Keybord is pressed (which event: see xib-file)
-(IBAction)changeConfigHost:(id)sender
{
    [_textfield resignFirstResponder]; //hide keyboard
    
    [ZigPadSettings sharedInstance].configuratorURL = _textfield.text;
}
//called if switch is switched
-(IBAction)switchSimulationMode:(id)sender
{
    [ZigPadSettings sharedInstance].simulationMode = _simSwitch.on;
    
    //set navigation bar to red if simulation is on (to warn user)
    if (_simSwitch.on == YES) {
        self.navigationController.navigationBar.tintColor = [UIColor redColor];
    }
    else {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0];
        
    }

}

//main entry
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    _simSwitch.on = [ZigPadSettings sharedInstance].simulationMode;
    _textfield.text = [ZigPadSettings sharedInstance].configuratorURL;
}



//generated Code.....

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
