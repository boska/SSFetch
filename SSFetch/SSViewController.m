//
//  SSViewController.m
//  SSFetch
//
//  Created by Boska Lee on 3/17/14.
//  Copyright (c) 2014 Boska. All rights reserved.
//

#import "SSViewController.h"
#import "SSAlbumListTableViewController.h"
#import <TFHpple.h>
@interface SSViewController ()

@end

@implementation SSViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated{
  [self getAlbumlist:nil];

}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)getAlbumlist:(id)sender {
#import "TFHpple.h"
  NSString *url = [NSString stringWithFormat:@"http://www.sportsnote.com.tw/running/%@",self.gameUrl];
  NSData  * data      = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

  TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
  NSArray * elements  = [doc searchWithXPathQuery:@"//option"];
  for ( TFHppleElement *e in elements){
    //e.attributes
    NSDictionary *attribute = e.attributes;
    NSLog (@"%@/%@",e.text,attribute[@"value"]);
  }
  [self performSegueWithIdentifier:@"albumlist" sender:elements];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"albumlist"]){
    SSAlbumListTableViewController *albumVC = (SSAlbumListTableViewController *)segue.destinationViewController;
    albumVC.albumList = (NSArray *)sender;
  }
}
@end
