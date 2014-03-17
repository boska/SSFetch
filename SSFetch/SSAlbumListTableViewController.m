//
//  SSAlbumListTableViewController.m
//  SSFetch
//
//  Created by Boska Lee on 3/17/14.
//  Copyright (c) 2014 Boska. All rights reserved.
//

#import "SSAlbumListTableViewController.h"
#import <MWPhotoBrowser.h>
#import <KINWebBrowserViewController.h>
#import <UIActionSheet+Blocks.h>
#import <SDWebImageDownloader.h>
#import <SVProgressHUD.h>
@interface SSAlbumListTableViewController () <MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) NSMutableArray *photoIds;
@property (nonatomic, strong) MWPhotoBrowser *browser;
@end

@implementation SSAlbumListTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.photos = [NSMutableArray array];
  self.selections = [NSMutableArray array];
  self.photoIds = [NSMutableArray array];
  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(loadMore:) userInfo:nil repeats:YES];
  [self fetchAlbumLists];
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated
{
  [self.webView removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)fetchAlbumLists {
  NSString *url = [NSString stringWithFormat:@"http://www.sportsnote.com.tw/running/%@", self.gameUrl];
  NSData *data      = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];

  TFHpple *doc       = [[TFHpple alloc] initWithHTMLData:data];
  NSArray *elements  = [doc searchWithXPathQuery:@"//option"];
  for (TFHppleElement *e in elements) {
    //e.attributes
    NSDictionary *attribute = e.attributes;
    NSLog(@"%@/%@", e.text, attribute[@"value"]);
  }
  self.albumList = elements;
  TFHppleElement *title = [doc searchWithXPathQuery:@"//title"].firstObject;
  self.title = title.text;

  [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return self.albumList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  TFHppleElement *e = self.albumList[indexPath.row];
  cell.textLabel.text = e.text;
  // Configure the cell...

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TFHppleElement *e = self.albumList[indexPath.row];
  NSDictionary *attribute = e.attributes;
  NSLog(@"%@/%@", e.text, attribute[@"value"]);
  //http://www.sportsnote.com.tw/running/album.aspx?id=5186224c-1b26-40eb-bd32-23c085b301b6&a=7718b5cb-ea55-4cef-934a-1766973c6541

  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.sportsnote.com.tw/running/%@&a=%@", self.gameUrl, attribute[@"value"]]];
  UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, 320, 568 - 64)];
  webView.delegate = self;
  webView.hidden = NO;
  [self.navigationController.view addSubview:webView];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  webView.scalesPageToFit = YES;
  [webView loadRequest:request];
  self.webView = webView;
  [SVProgressHUD showWithStatus:@"Expanding Album..." maskType:SVProgressHUDMaskTypeClear];
  // [webView stringByEvaluatingJavaScriptFromString:@"loadMore();loadMore();loadMore();loadMore();loadMore();loadMore();loadMore();loadMore();"];
  //[self.navigationController.view addSubview:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

- (IBAction)loadMore:(id)sender {
  if (![self.webView.superview isEqual:self.navigationController.view]) {
    return;
  }
  NSString *display = [self.webView stringByEvaluatingJavaScriptFromString:@"$('#loading').css('display')"];
  if ([display isEqualToString:@"block"]) {
    return;
  }
  [self.webView stringByEvaluatingJavaScriptFromString:@"loadMore();"];
  NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
  NSString *noMore = [self.webView stringByEvaluatingJavaScriptFromString:@"nomore"];
  NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];

  TFHpple *doc       = [[TFHpple alloc] initWithHTMLData:data];

  if ([noMore isEqualToString:@"true"]) {
    NSArray *elements  = [doc searchWithXPathQuery:@"//a[@class='fbox']/img"];
    NSArray *photoIds  = [doc searchWithXPathQuery:@"//a[@class='fbox']"];
    if (elements.count > 0) {
      [self.photos removeAllObjects];
      [self.photoIds removeAllObjects];

      for (TFHppleElement *e in elements) {
        NSDictionary *attribue = e.attributes;
        NSString *href = attribue[@"src"];
        //NSString *photoId = [[href componentsSeparatedByString:@"id="] lastObject];
        //http://www.sportsnote.com.tw/running/album_download.aspx?id=4b6f12ad-6830-423a-978a-1a8eb4853d33
        href = [href stringByReplacingOccurrencesOfString:@"w210" withString:@"s600"];
        NSURL *url = [NSURL URLWithString:href];
        MWPhoto *photo = [MWPhoto photoWithURL:url];
        [self.photos addObject:photo];
        [_selections addObject:@(NO)];
      }
      for (TFHppleElement *e in photoIds) {
        NSDictionary *attribue = e.attributes;
        NSString *href = attribue[@"href"];
        NSString *photoId = [[href componentsSeparatedByString:@"id="] lastObject];
        NSString *urlStrig = [NSString stringWithFormat:@"http://www.sportsnote.com.tw/running/album_download.aspx?id=%@", photoId];
        [self.photoIds addObject:urlStrig];
      }
      MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
      browser.displaySelectionButtons = NO;   // Whether selection
      [self.webView removeFromSuperview];
      [SVProgressHUD dismiss];
      // Present
      [self.navigationController pushViewController:browser animated:YES];
    }
  }
}

#pragma mark - MW PHOTO DELEGATE
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
  return self.photos.count;
}

- (id <MWPhoto> )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
  if (index < self.photos.count)
    return [self.photos objectAtIndex:index];
  return nil;
}

- (id <MWPhoto> )photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
  if (index < self.photos.count)
    return [self.photos objectAtIndex:index];
  return nil;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
  return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
  [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
  if (selected) {
  }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
  // Do your thing!
  [UIActionSheet showInView:photoBrowser.view withTitle:nil cancelButtonTitle:@"Cacel" destructiveButtonTitle:nil otherButtonTitles:@[@"Save to Camera Roll"] tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
    if (buttonIndex == 0) {
      NSString *url = [self.photoIds objectAtIndex:index];
      NSData *data      = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
      TFHpple *doc       = [[TFHpple alloc] initWithHTMLData:data];
      NSArray *elements  = [doc searchWithXPathQuery:@"//img[@id='imgPic']"];
      TFHppleElement *img = elements.firstObject;
      NSString *imgSrc = img.attributes[@"src"];

      if (img == nil) {

        self.webView.hidden = NO;
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
        [self.webView loadRequest:request];
        [SVProgressHUD showErrorWithStatus:@"Login to save!"];
        [self.navigationController.view addSubview:self.webView];
        
      } else {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imgSrc] options:SDWebImageDownloaderProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
          if (finished) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            [SVProgressHUD showSuccessWithStatus:@"Saved!"];
          }
        }];
      }
    }
  }];
}

@end
