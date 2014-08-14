//
//  MMShareView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShareView.h"
#import "MMShareManager.h"
#import "MMOpenInAppSidebarButton.h"
#import "UIView+Debug.h"
#import "Constants.h"

@implementation MMShareView{
    NSMutableArray* buttons;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self showDebugBorder];
        self.userInteractionEnabled = YES;
        buttons = [NSMutableArray array];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat loc = 0;
    NSArray* allCollectionViews = [[MMShareManager sharedInstance] allFoundCollectionViews];
    
    NSLog(@"checking on %d views", [allCollectionViews count]);
    for(UICollectionView* cv in allCollectionViews){
        
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        
        NSLog(@"checking on %d items", numberOfItems);
        
        for(NSInteger i=0;i<numberOfItems;i++){
            UICollectionViewCell* cell = [cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            CGPoint origin = CGPointMake(loc, loc);
            CGSize size = cell.bounds.size;
            CGRect fr;
            fr.origin = origin;
            fr.size = size;
            
            
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor redColor].CGColor);
            CGContextStrokeRect(UIGraphicsGetCurrentContext(), fr);
            
            [cell drawViewHierarchyInRect:fr afterScreenUpdates:NO];
            
            loc += 10;
        }
    }
}
 */

#pragma mark - MMShareManagerDelegate

-(void) shareItemsUpdated:(NSArray*)allCollectionViews{
    NSInteger columnCount = floor(self.bounds.size.width / self.buttonWidth);
    NSInteger section = 0;
    NSInteger totalNumberOfItems = 0;
    for(UICollectionView* cv in allCollectionViews){
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        
        for(int index=0;index<numberOfItems;index++){
            NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:section];
            [cv cellForItemAtIndexPath:path];
            
            NSInteger currentIndex = totalNumberOfItems+index;
            NSInteger row = floor(currentIndex / columnCount);
            NSInteger col = currentIndex % columnCount;
            
            CGRect buttonFr = CGRectMake(col * self.buttonWidth, row * self.buttonWidth,
                                          self.buttonWidth, self.buttonWidth);
            MMOpenInAppSidebarButton* button = nil;
            if([buttons count] > currentIndex) button = [buttons objectAtIndex:currentIndex];
            if(!button){
                button = [[MMOpenInAppSidebarButton alloc] initWithFrame:buttonFr andIndexPath:path];
                [buttons addObject:button];
                [self addSubview:button];
            }else{
                button.frame = buttonFr;
                button.indexPath = path;
            }
        }
        totalNumberOfItems += numberOfItems;
        section++;
    }
    
    CGRect fr = self.frame;
    fr.size.height = totalNumberOfItems * (kWidthOfSidebarButton + kWidthOfSidebarButtonBuffer);
    self.frame = fr;
    [self setNeedsDisplay];
}

#pragma mark - Redirect Touches

// the goal of this method is to direct the touch to
// the activity cell for the app we want to open

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    NSArray* allCollectionViews = [[MMShareManager sharedInstance] allFoundCollectionViews];
    for(UICollectionView* cv in allCollectionViews){
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        for(NSInteger i=0;i<numberOfItems;i++){
            UICollectionViewCell* cell = [cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [MMShareManager setShareTargetView:cell];
            return cell;
        }
    }
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    NSArray* allCollectionViews = [[MMShareManager sharedInstance] allFoundCollectionViews];
    for(UICollectionView* cv in allCollectionViews){
        NSInteger numberOfItems = [cv numberOfItemsInSection:0];
        if(numberOfItems > 1){
            return YES;
        }
    }
    return NO;
}



@end
