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
@synthesize startIndex = _startIndex;
@synthesize favoritesLabel = _favoritesLabel;

NSArray* favorites; //favorite cache

int favoritesCount;

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
    
    favoritesCount = [favorites count];
    
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
    
    CGRect cgRect =[[UIScreen mainScreen] bounds];
    CGSize cgSize = cgRect.size;
    
    int padding = 10; //buttonPadding
    int numOfcols = 3;//num of buttons per row on UIview
    int numOfFavorites = favoritesCount > _startIndex + 9 ? 9 : favoritesCount - _startIndex;
    int buttonWith = cgSize.width / 4;
    int buttonHeight = cgSize.width / 4;
    int labelWith = cgSize.width / 4;
    int labelHeight = cgSize.width / 16;
    int btnPosX,btnPosY,labPosX, labPosY = 0; 
    
    for (int i = 0; numOfcols*i < numOfFavorites ; i++) {
        for (int j = 0 ; j < numOfcols && i*numOfcols+j < numOfFavorites; j++) {
            
            int currentFavorite = _startIndex + (i * numOfcols) + j;
            Action* a = [favorites objectAtIndex: currentFavorite];
            
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
            
            btn.contentMode = UIViewContentModeScaleToFill;

            //fill Button with Text or LocalImage
            LocalPicture* image = [self findPictureInAction:a];            
            if (image !=nil)
            {
                [btn setBackgroundImage:[UIImage imageWithData:image.picture] forState:UIControlStateNormal];
            }
            else {
                [btn setTitle:@"?" forState:UIControlStateNormal];
            }

            
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
-(void)handleSwipe: (UISwipeGestureRecognizer *) recogniser
{
    switch (recogniser.direction) {
        case UISwipeGestureRecognizerDirectionDown:
        {
            [AnimatorHelper slideWithAnimation:-2 :self :nil :true:false:true];
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft:
        {
            FavoritesViewController* favorite = [[FavoritesViewController alloc] initWithNibName:@"FavoritesView" bundle:[NSBundle mainBundle]];
            
            // Either increase by 9 or set back to 0 if of last page.
            favorite.startIndex = favoritesCount > _startIndex + 9 ? _startIndex + 9 : 0;
            NSLog(@"left: startIndex: %d", favorite.startIndex);
            
            [AnimatorHelper slideWithAnimation:-1 :self :favorite :true:true:true];
            [favorite release];
            break;
        }
        case UISwipeGestureRecognizerDirectionRight:
        {
            FavoritesViewController* favorite = [[FavoritesViewController alloc] initWithNibName:@"FavoritesView" bundle:[NSBundle mainBundle]];
            
            // Either decrease by 9 or set back to max if of first page.
            favorite.startIndex = _startIndex > 0 ? _startIndex - 9 : favoritesCount / 9 * 9;
            NSLog(@"right: startIndex: %d", favorite.startIndex);
            
            [AnimatorHelper slideWithAnimation:1 :self :favorite :true:true:true];
            [favorite release];
            break;
        }
    }
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
    
    // Only enable left/right swiping if there are more than 9 favorites
    if ([favorites count] > 9) {
        recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipe:)];
        [recognicer setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.view addGestureRecognizer:recognicer];
        [recognicer release];
    
        recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipe:)];
        [recognicer setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.view addGestureRecognizer:recognicer];
        [recognicer release];
        
        // Update title to indicate the page we are on.
        _favoritesLabel.text = [NSString stringWithFormat:@"Favorites #%d", (_startIndex / 9) + 1];
    }
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
