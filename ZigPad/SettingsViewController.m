//
//  SettingsViewController.m
//  ZigPad
//
//  Created by Markus Zimmermann on 4/19/11.
//  Copyright 2011 Ceesar. All rights reserved.
//

#import "SettingsViewController.h"
#import "Commander.h"

@implementation SettingsViewController


@synthesize simSwitch = _simSwitch;
@synthesize vibrationSwitch = _vibrationSwitch;
@synthesize synchronizeSwitch = _synchronizeSwitch;

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
    
    // Set navigation bar to corresponding color.
    self.navigationController.navigationBar.tintColor = [ZigPadSettings sharedInstance].modeColor;
    
    // Close eventually existing Commander instance.
    [Commander close];
    
}

- (IBAction) switchSynchronizationMode:(id)sender 
{
    [ZigPadSettings sharedInstance].synchronizationMode = _synchronizeSwitch.on;
    
    // Also issue visual alert
	UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Restart required"
                          message:@"A restart of this application is required to active the synchronization mode change."
                          delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
	[alert show];
}

- (IBAction) switchVibrationMode:(id)sender
{
    [ZigPadSettings sharedInstance].vibrationMode = _vibrationSwitch.on;
}

//main entry
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    _simSwitch.on = [ZigPadSettings sharedInstance].simulationMode;
    _vibrationSwitch.on = [ZigPadSettings sharedInstance].vibrationMode;
    _synchronizeSwitch.on = [ZigPadSettings sharedInstance].synchronizationMode;
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
    [_simSwitch release];
    [_textfield release];
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
