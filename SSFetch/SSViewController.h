//
//  SSViewController.h
//  SSFetch
//
//  Created by Boska Lee on 3/17/14.
//  Copyright (c) 2014 Boska. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSViewController : UIViewController
@property (nonatomic,strong)NSString *gameUrl;
- (IBAction)getAlbumlist:(id)sender;
@end
