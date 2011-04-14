//
//  Favorites.m
//  ZigPad
//
//  Created by MArkus Zimmermann 4/13/11.
//  Copyright 2011 ceesar. All rights reserved.
//

#import "FavoritesViewController.h"



@implementation FavoritesViewController

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
    LocalPicture* image = nil;
    for (Param* p in anAction.params)
    {
        if (p.localImage !=nil) 
        {
            image = p.localImage; break;
        }
        
    }
    return image;
}

//Draws all Favorites to view
-(void)initButtons
{
 
    favorites = [[self getSortedAndFilteredFavoritesFromDB] retain];
    
    int padding = 20; //buttonPadding
    int numOfcols = 4;//num of buttons per row on UIview
    int numOfFavorites = [favorites count];
    int buttonWith = 50;
    int buttonHeight = 50;
    int posX,posY = 0; 
    
    for (int i = 0; numOfcols*i < numOfFavorites ; i++) {
        for (int j = 0 ; j < numOfcols && i*numOfcols+j < numOfFavorites; j++) {
            
            int currentFavorite = i*numOfcols+j;
            Action* a = [favorites objectAtIndex:currentFavorite];
            
            posX = (padding+buttonWith)*j+padding; //buttonPosition
            posY = (padding+buttonHeight)*i+padding;
                
            UIButton *btn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
            btn.frame = CGRectMake(posX, posY, buttonWith, buttonHeight);
            [[btn layer] setBorderWidth:1.0];

            //fill Button with Text or LocalImage
            LocalPicture* image = [self findPictureInAction:a];            
            if (image !=nil)[btn setImage:[UIImage imageWithData:image.picture] forState:UIControlStateNormal];
            else [btn setTitle:a.name forState:UIControlStateNormal];
            
            //eventlistener
            [btn addTarget:self action:@selector(handleFavoriteAction:)forControlEvents:UIControlEventTouchUpInside];
            
            //mark the button
            btn.tag = currentFavorite;
            
            [self.view addSubview:btn];
            [btn release];

            
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
        
        //TODO aufruf nach commandmodul
        NSLog(@"klikk %@",a.name);
    }
   
}
//swipe eventhandler
-(void)handleSwipe:(id)sender
{
    [self.navigationController popViewControllerAnimated:true];
}


- (void)dealloc
{
    [favorites release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initButtons];
    
    UISwipeGestureRecognizer *recognicer;    
    recognicer = [[UISwipeGestureRecognizer alloc] initWithTarget: self action:@selector(handleSwipe:)];
    [recognicer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:recognicer];
    [recognicer release];
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
