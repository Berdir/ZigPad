//
//  FlowCoverViewController.h
//  FlowCover
//
//  Created by William Woody on 12/13/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlowCoverView.h"
#import "Presentation.h"

@interface SequenceChoiceViewController : UIViewController <FlowCoverViewDelegate>
{

}

-(void) initWithPresentation:(Presentation*) p;


@end

