//
//  RootViewController.h
//  ZigPad
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 CEESAR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Synchronizer.h"
#import "Presentation.h"
#import "SettingsViewController.h"

/**
 * The view controller for the initial table view.
 */
@interface RootViewController : UITableViewController <MBProgressHUDDelegate, NSFetchedResultsControllerDelegate> {
    
    /**
     * Reference of the MBProgressHUD for progress display during import.
     */
    MBProgressHUD *HUD;
    
    /**
     * Reference to the synchronizer instance.
     */
    @private Synchronizer *sync;
}

/**
 * Starts the configuration import.
 *
 * @param sender Indicates the button that is executing this action.
 */
- (IBAction) update:(id) sender;

/**
 * Displays the settings screen.
 *
 * @param sender Indicates the button that is executing this action.
 */
- (IBAction) popupSettingView:(id)sender;

/**
 * Delegate callback for running the import.
 */
- (void)runUpdate;

/**
 * Reference to the results controller for the presentations.
 */
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

/**
 * Reference to the active presentation.
 */
@property (nonatomic, retain) Presentation* activePresentation;

@end



