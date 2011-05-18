//
//  Favorites.m
//  ZigPad
//
//  Created by Markus Zimmermann 4/13/11.
//  Copyright 2011 ceesar. All rights reserved.
//

#import "FavoritesViewController.h"



@implementation FavoritesViewController
@synthesize mySubview = _mySubview;

NSArray* favorites; //favorite cache

//grab Database
-(NSArray*)getSortedAndFilteredFavoritesFromDB
{
    //get Favorites from Database
    //init db
    NSManagedObjectContext* context =  [[Database sharedInstance] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Action" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
    [request setEntity:entityDescription];
    
    //and sort
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"favorite" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];    
    [request setSortDescriptors:sortDescriptors]; 
  
    //and filter
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"favorite > 0"];
    [request setPredicate:filter];
    
    //read db
    NSError* error = nil;
    NSArray *favorites = [context executeFetchRequest:request error:&error]; 
    
    [sortDescriptors release];
    [sortDescriptor release];
    [request release];
    
    return favorites;
}

//grab action Object for a Local Picture
-(LocalPicture*)findPictureInAction:(Action*)anAction
{
    // First, look for a favorite icon, if found, returned.
    Param *p = [anAction getParamForKey:@"favorite_icon"];
    if (p != nil) {
        return p.localPicture;
    }
    // If any param has an attached local Picture, return that.
    for (Param* p in anAction.params) {
        if (p.localPicture) {
            return p.localPicture;
        }
    }
    return nil;
}

//Draws all Favorites to view
-(void)initButtons
{
 
    favorites = [[self getSortedAndFilteredFavoritesFromDB] retain];
    
    int padding = 10; //buttonPadding
    int numOfcols = 3;//num of buttons per row on UIview
    int numOfFavorites = [favorites count];
    int buttonWith = 80;
    int buttonHeight = 80;
    int labelWith = 80;
    int labelHeight = 20;
    int btnPosX,btnPosY,labPosX, labPosY = 0; 
    
    for (int i = 0; numOfcols*i < numOfFavorites ; i++) {
        for (int j = 0 ; j < numOfcols && i*numOfcols+j < numOfFavorites; j++) {
            
            int currentFavorite = i*numOfcols+j;
            Action* a = [favorites objectAtIndex:currentFavorite];
            
            btnPosX = (2*padding+buttonWith)*j+2*padding; //buttonPosition
            btnPosY = (3*padding+buttonHeight+labelHeight)*i+2*padding;
            
            labPosX = (2*padding+buttonWith)*j+2*padding; //labelPosition
            labPosY = (3*padding+buttonHeight+labelHeight)*i+3*padding+buttonHeight;
            
            //alloc buttons and labels

            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(labPosX, labPosY, labelWith, labelHeight)];
            label.adjustsFontSizeToFitWidth = true;
            label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            label.text = a.name;  //fill label with favorite name
            
            
            UIButton *btn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
            btn.frame = CGRectMake(btnPosX, btnPosY, buttonWith, buttonHeight);
            // Make buttons rounded.
            [btn.layer setBorderWidth:1.0];
            [btn.layer setCornerRadius:7.0f];
            [btn.layer setMasksToBounds:YES];

            
            //fill Button with Text or LocalImage
            //[btn setImage:[UIImage imageNamed:@"testpic2.png"]  forState:UIControlStateNormal];
            LocalPicture* image = [self findPictureInAction:a];            
            if (image !=nil)[btn setImage:[UIImage imageWithData:image.picture] forState:UIControlStateNormal];
            else [btn setTitle:@"?" forState:UIControlStateNormal];

            
            //eventlistener
            [btn addTarget:self action:@selector(handleFavoriteAction:)forControlEvents:UIControlEventTouchUpInside];
            
            //mark the button
            btn.tag = currentFavorite;
            
            [self.mySubview addSubview:btn];
            [self.mySubview addSubview:label];
            [btn release];
            [label release];
            

            
        }
    }

}


//Button eventhandler
-(void)handleFavoriteAction:(id)sender
{
    UIButton* b;
    if([sender isKindOfClass:[UIButton class]])
    {
        b = (UIButton*)sender;
        Action* a = [favorites objectAtIndex:b.tag];
        
        //send to gira server
        [[Commander defaultCommander]sendAction:a];
    }
   
}
//swipe eventhandler
-(void)handleSwipe:(id)sender
{
    [AnimatorHelper slideWithAnimation:-2 :self :nil :true:false:true];
    //[self.navigationController popViewControllerAnimated:true];
}


- (void)dealloc
{
    [_mySubview release];
    [favorites release];
    [super dealloc];
}
//main entry to build the GUI
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initButtons];
    
    NSLog(@"Favoriten geladen");
    UISwipeGestureRecognizer *recognicer;    
    recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipe:)];
    [recognicer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognicer];
    [recognicer release];
}

// Show navigation bar when the view appeared.
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    self.navigationController.navigationBar.topItem.title = @"Favorites";
    [super viewWillAppear:animated];
}


//generated code..

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
