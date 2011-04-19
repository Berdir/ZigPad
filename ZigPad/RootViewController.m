//
//  RootViewController.m
//  List
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "MBProgressHUD.h"
#import "Importer.h"
#import "Presentation.h"
#import "Database.h"
#import "Synchronizer.h"


@implementation RootViewController

@synthesize fetchedResultsController=__fetchedResultsController;

@synthesize managedObjectContext=__managedObjectContext;

Presentation *activePresentation = nil;

//dieser Codeanschnitt ist nur dummy und soll bald gelšscht werden
- (IBAction) sequences:(id)sender
{
    
    
    if (!activePresentation) {
        return;
    }

    SequenceChoiceViewController* chooser = [[SequenceChoiceViewController alloc] initWithNibName:@"SequenceChoiceView" bundle:[NSBundle mainBundle]];

    [chooser initWithPresentation: activePresentation]; 
    
	[self.navigationController pushViewController:chooser animated:YES];
	[chooser release]; 

}

- (IBAction) favorites:(id)sender
{
    
    FavoritesViewController* favorite = [[FavoritesViewController alloc] initWithNibName:@"FavoritesView" bundle:[NSBundle mainBundle]];
    
    
	[self.navigationController pushViewController:favorite animated:YES];
	[favorite release]; 

  
}
//dummycode bis hier

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [Database sharedInstance].managedObjectContext;
    
    Synchronizer *s = [[Synchronizer alloc] init];
    [s lookForDevice];
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
    bool success = [parser parseXMLFile:@"http://z.worldempire.ch/1/zigpad/config.xml"];
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
	
    activePresentation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"Selected Presentation %@.", activePresentation.name);
    Action *a;
    int i = 0;
    while ((a = [activePresentation getNextAction])) {
        NSLog(@"%d. Action: %@.", ++i, a.name);
    }
    
	/*Detail *dvController = [[Detail alloc] initWithNibName:@"Detail" bundle:[NSBundle mainBundle]];
	dvController.selectedPresentation = [NSString stringWithFormat:@"FÃ¼hrungsablauf %i", [indexPath row]];
    dvController.step = 1;
	[self.navigationController pushViewController:dvController animated:YES];
	[dvController release];
	dvController = nil;*/
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
    [__fetchedResultsController release];
    [__managedObjectContext release];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Presentation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
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

