//
//  RootViewController.h
//  List
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Synchronizer.h"

//temporär
#import "SequenceChoiceViewController.h"
#import "FavoritesViewController.h"
#import "SettingsViewController.h"


@interface RootViewController : UITableViewController <MBProgressHUDDelegate, NSFetchedResultsControllerDelegate> {
    MBProgressHUD *HUD;
    
    @private Synchronizer *sync;
}

- (IBAction) update:(id) sender;
- (IBAction) popupSettingView:(id)sender;


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;	
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (void)runUpdate;

@end



