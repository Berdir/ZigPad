//
//  FlowCoverViewController.h
//  FlowCover
//
//  Created by William Woody on 12/13/08.
//  Copyright CEESAR 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlowCoverView.h"
#import "Presentation.h"

@interface SequenceChoiceViewController : UIViewController <FlowCoverViewDelegate>
{
  
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) Presentation *presentation;

@end

