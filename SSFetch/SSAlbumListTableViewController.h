//
//  SSAlbumListTableViewController.h
//  SSFetch
//
//  Created by Boska Lee on 3/17/14.
//  Copyright (c) 2014 Boska. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSAlbumListTableViewController : UITableViewController <UIWebViewDelegate>
@property(nonatomic,strong) NSArray *albumList;
@property(nonatomic,strong) UIWebView *webView;
@property(nonatomic,assign) NSInteger *total;
@property(nonatomic,strong) NSString *gameUrl;
-(IBAction)loadMore:(id)sender;
@end
