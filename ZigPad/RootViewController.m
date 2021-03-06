//
//  RootViewController.m
//  ZigPad
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import "RootViewController.h"
#import "ActionViewController.h"
#import "MBProgressHUD.h"
#import "Importer.h"
#import "Database.h"
#import "Synchronizer.h"
#import "ZigPadSettings.h"
#import "SyncEvent.h"
#import "AnimatorHelper.h"


@implementation RootViewController

@synthesize fetchedResultsController=__fetchedResultsController;

@synthesize activePresentation = _activePresentation;

#pragma mark -
#pragma mark View lifecycle

- (void) registerNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSyncEvent:) 
                                                 name:@"ZigPadSyncReceive"
                                               object:nil];
}

- (void) unregisterNotificationCenter {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) receiveSyncEvent: (NSNotification *) notification {
    SyncEvent *event = [notification object];
    
    switch (event.command) {
        case ANSWER:
        case SELECT:
        {
            // Only act when no presentation is currently running.
            if ([self.navigationController.viewControllers count] != 1) {
                return;
            }
            
            //get Presentation with selected refId from Database.
            NSManagedObjectContext* context =  [[Database sharedInstance] managedObjectContext];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Presentation" inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
            [request setEntity:entityDescription];
            
            // Add a corresponding filter.
            NSPredicate *filter = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"refId = %d", event.argument]];
            [request setPredicate:filter];
            
            // Read db
            NSError* error = nil;
            NSArray *presentations = [context executeFetchRequest:request error:&error];
            
            if ([presentations count] == 0) {
                NSLog(@"No presentation for the given refId (%d) found", event.argument);
                [request release];
                return;
            }
            
            self.activePresentation = [presentations objectAtIndex:0];
            [request release];
            
            NSLog(@"Selected Presentation through sync event %@.", self.activePresentation.name);
            
            // Only jump to the first action of this presentation if this is a SELECT
            // command.
            if (event.command == SELECT) { 
                [self.activePresentation resetPresentation];
                Action *a = [self.activePresentation getNextAction];    
                ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
                nextPage.presentation = self.activePresentation;
                
                [AnimatorHelper slideWithAnimation:-1 :self :nextPage :false :true :true];
            }
            break;
        }
        case JUMP:
            // Only act on jump commands if no presentation is active and a presentation was
            // already selected with the ANSWER command.
            if ([self.navigationController.viewControllers count] == 1 && self.activePresentation) {
                Action *a = [self.activePresentation jumpToAction:event.argument_lowerByte sequenceIndex:event.argument_upperByte];
            
                if (a) {
                    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
                    nextPage.presentation = self.activePresentation;
                    [AnimatorHelper slideWithAnimation:-1 :self :nextPage :false :true :true];
                }
            }
            break;
        case CONNECTED:
            self.navigationController.navigationBar.topItem.title = @"ZigPad (Synced)";
            
            // Send a REQUEST if no presentation is running.
            if ([self.navigationController.viewControllers count] == 1) {
                SyncEvent *request_event = [[SyncEvent alloc] init];
                request_event.command = REQUEST;
                
                [event.connection send: request_event];
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncFire" object:request_event];
                
                [request_event release];
            }
            break;
        case LOST_CONNECTION:
            self.navigationController.navigationBar.topItem.title = @"ZigPad";
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNotificationCenter];
    
    // Set navigation bar to corresponding color.
    self.navigationController.navigationBar.tintColor = [ZigPadSettings sharedInstance].modeColor;
    
    // Start synchronization if enabled.
    if ([ZigPadSettings sharedInstance].synchronizationMode) {
        sync = [[Synchronizer alloc] init];
        [sync lookForDevice];
    }
}

// Show navigation and toolbar when the view appears.
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (IBAction)popupSettingView:(id)sender
{
    
    SettingsViewController* settings = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:[NSBundle mainBundle]];
    
	[self.navigationController pushViewController:settings animated:YES];
	[settings release];     

}

- (IBAction)update:(id)sender {
    
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	
    // Add HUD to screen
    [self.navigationController.view addSubview:HUD];
	
    // Regisete for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
	
    HUD.labelText = @"Updating";
    //HUD.detailsLabelText = @"Downloading...";
	
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(runUpdate) onTarget:self withObject:nil animated:YES];
}


//Called by HUD
- (void) runUpdate {
    Importer* parser = [[Importer alloc]init];
    //NSString * configURL = @"http://z.worldempire.ch/1/zigpad/config.xml";
    NSString * configURL = [ZigPadSettings sharedInstance].configuratorURL;
    bool success = [parser parseXMLFile:configURL ];
    [parser release];
    parser = nil;
    
    if (success) {
        // The sample image is based on the work by www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
        // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Completed";
    }
    else {
        // The sample image is based on the work by www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
        // Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
        HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Failure.png"]] autorelease];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"Failure";
    }
    sleep(1);
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
      
    // Configure the cell.
    Presentation *p = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = p.name;
    return cell;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    self.activePresentation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Selected Presentation %@.", self.activePresentation.name);
    [self.activePresentation resetPresentation];
  
    Action *a = [self.activePresentation getNextAction];    
    ActionViewController *nextPage = [ActionViewController getViewControllerFromAction:a];
    nextPage.presentation = self.activePresentation;
    nextPage.isMaster = TRUE;
    
    self.navigationController.navigationBar.hidden = TRUE;
    
    
    [AnimatorHelper slideWithAnimation:-1 :self :nextPage :false :true :false];

    SyncEvent *syncEvent = [[SyncEvent alloc] init];
    syncEvent.command = SELECT; 
    syncEvent.argument = [self.activePresentation.refId unsignedIntValue];    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigPadSyncFire" object:syncEvent];
    
    [syncEvent release];

}

#pragma mark -
#pragma mark Table view delegate

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

- (void)dealloc {
    [self unregisterNotificationCenter];
    [_activePresentation release];
    [__fetchedResultsController release];
    [sync release];
    [super dealloc];
}

#pragma mark -
#pragma mark - Fetched results controller
- (NSFetchedResultsController*) fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Set up the fetched result controlEler.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Presentation" inManagedObjectContext: [Database sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext: [Database sharedInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [sortDescriptor release];
    [sortDescriptors release];
    [fetchRequest release];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __fetchedResultsController;
    
}

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath	 	
{
    UITableView *tableView = self.tableView;
    switch(type) {
      case NSFetchedResultsChangeInsert:
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
      case NSFetchedResultsChangeDelete:
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
      case NSFetchedResultsChangeUpdate:
        //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        break;
      case NSFetchedResultsChangeMove:
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
        break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end

