//
//  RootViewController.h
//  List
//
//  Created by ceesar on 16/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

//temporär
#import "SequenceChoiceViewController.h"


@interface RootViewController : UITableViewController <MBProgressHUDDelegate, NSFetchedResultsControllerDelegate> {
    MBProgressHUD *HUD;
}

- (IBAction) update:(id) sender;
- (IBAction) sequences:(id) sender; //Temporär


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;	
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


- (void)runUpdate;

@end



