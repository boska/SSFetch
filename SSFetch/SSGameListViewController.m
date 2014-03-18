//
//  SSGameListViewController.m
//  SSFetch
//
//  Created by Boska Lee on 3/17/14.
//  Copyright (c) 2014 Boska. All rights reserved.
//

#import "SSGameListViewController.h"
#import "SSAlbumListTableViewController.h"
#import <UIColor+HexString.h>
@interface SSGameListViewController ()
@property (nonatomic, strong) NSMutableArray *games;
@property (nonatomic, strong) NSMutableArray *gamesId;

@end

@implementation SSGameListViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"097EC6"]];
  TFHpple *doc = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.sportsnote.com.tw/running/album_list.aspx"]]];
  self.games = [NSMutableArray arrayWithArray:[doc searchWithXPathQuery:@"//div[@class='album_new']/a/b"]];
  self.gamesId = [NSMutableArray arrayWithArray:[doc searchWithXPathQuery:@"//div[@class='album_new']/a"]];

  [self.tableView reloadData];
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return self.games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

  TFHppleElement *game = self.games[indexPath.row];

  cell.textLabel.text = game.text;
  // Configure the cell...

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TFHppleElement *gameId  = self.gamesId[indexPath.row];
  [self performSegueWithIdentifier:@"albumlist" sender:gameId.attributes[@"href"]
  ];
}

 #pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"albumlist"]) {
    SSAlbumListTableViewController *destVc = (SSAlbumListTableViewController *)segue.destinationViewController;
    destVc.gameUrl = sender;

  }
}

/*
 * // Override to support conditional editing of the table view.
 * - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Return NO if you do not want the specified item to be editable.
 *  return YES;
 * }
 */

/*
 * // Override to support editing the table view.
 * - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  if (editingStyle == UITableViewCellEditingStyleDelete) {
 *      // Delete the row from the data source
 *      [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 *  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 *      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 *  }
 * }
 */

/*
 * // Override to support rearranging the table view.
 * - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 * {
 * }
 */

/*
 * // Override to support conditional rearranging of the table view.
 * - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 * {
 *  // Return NO if you do not want the item to be re-orderable.
 *  return YES;
 * }
 */

/*
 * #pragma mark - Navigation
 *
 * // In a storyboard-based application, you will often want to do a little preparation before navigation
 * - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 * {
 *  // Get the new view controller using [segue destinationViewController].
 *  // Pass the selected object to the new view controller.
 * }
 */

@end
