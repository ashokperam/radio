//
//  FavoriteViewController.m
//  MediaStation
//
//  Created by CODERLAB on 03.12.13.
//  Copyright (c) 2013 stidio76. All rights reserved.
//

#import "FavoriteViewController.h"
#import "MPDStartCell.h"
#import "UIImageView+WebCache.h"
#import "PlayerViewController.h"
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController
@synthesize favorite;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *filePathDocArray = [DOCUMENTS stringByAppendingPathComponent:@"favorite.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePathDocArray]) {
        NSLog(@"The file exists");
        
        favorite = [NSMutableArray arrayWithContentsOfFile:filePathDocArray];
        NSLog(@"The array: %i",(int) [favorite count]);
        
        [self.tableView reloadData];
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                            init];
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(changeSorting) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor redColor];
    [refreshControl addTarget:self action:@selector(changeSorting) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
   // self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                       //              [UIImage imageNamed:@"back2-t"]];
    
   UINavigationController* more =
    self.tabBarController.moreNavigationController;
    UIViewController* list = more.viewControllers[0];
    list.title = @"";
     UIBarButtonItem* b = [UIBarButtonItem new];
     b.title = @"Back";
    list.navigationItem.backBarButtonItem = b; // so user can navigate back
    more.navigationBar.barStyle = UIBarStyleBlack;
    more.navigationBar.tintColor = [UIColor whiteColor];
}



- (void)changeSorting
{
    NSString *filePathDocArray = [DOCUMENTS stringByAppendingPathComponent:@"favorite.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePathDocArray]) {
        NSLog(@"The file exists");
        
        favorite = [NSMutableArray arrayWithContentsOfFile:filePathDocArray];
    }
    [self performSelector:@selector(updateTable) withObject:nil
               afterDelay:2];
}

- (void)updateTable
{
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favorite.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *Cellidentifier = @"DataTableCellId";
    MPDStartCell *cell = (MPDStartCell *) [tableView dequeueReusableCellWithIdentifier:Cellidentifier];
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"StartCellView" owner:self options:nil];
        cell = nib[0];
        
        NSDictionary *newsItem = [self.favorite objectAtIndex:indexPath.row];
        NSURL * imageURL = [NSURL URLWithString:[newsItem objectForKey:@"image"]];
        NSString *titlez = [newsItem objectForKey:@"title"];
        titlez = [titlez stringByReplacingOccurrencesOfString:@"&amp;"
                                                   withString:@"&"];
        titlez = [titlez stringByReplacingOccurrencesOfString:@"&quot;"
                                                   withString:@"\""];
        cell.customLable.text =titlez;
        
      //  cell.imageCustom.layer.cornerRadius = 160; // 160 is just a guess
     //   cell.imageCustom.clipsToBounds = YES;
        
        [cell.imageCustom setImageWithURL:imageURL
                         placeholderImage:[UIImage imageNamed:@"120_icon.png"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
        
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:@"Plz" sender:indexPath];
    NSLog(@"tap");
    
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.favorite removeObjectAtIndex:indexPath.row];
        [self writeToPlist:@"favorite.plist" withData:favorite];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [favorite exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self writeToPlist:@"favorite.plist" withData:favorite];
}

- (void) writeToPlist: (NSString*)fileName withData:(NSMutableArray *)data
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    [data writeToFile:finalPath atomically: YES];
    
}

-(IBAction)edit:(id)sender{
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"Plz"])
    {
        PlayerViewController *player = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerViewController"];
        player = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //  NSInteger row = indexPath.row;
        NSString *linz = [favorite[indexPath.row] objectForKey: @"url"];
        NSString *imgs = [favorite[indexPath.row] objectForKey: @"image"];
        NSString *title = [favorite[indexPath.row] objectForKey: @"title"];
        [[segue destinationViewController] setUrlString:linz];
        [[segue destinationViewController] setUrlImage:imgs];
        [[segue destinationViewController] setRadioTitle:title];
        
    }
}

-(IBAction)reloadFav:(id)sender{
    
    NSString *filePathDocArray = [DOCUMENTS stringByAppendingPathComponent:@"favorite.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePathDocArray]) {
        NSLog(@"The file exists");
        
        favorite = [NSMutableArray arrayWithContentsOfFile:filePathDocArray];
        NSLog(@"The array: %i",(int) [favorite count]);
        

    
        [self.tableView reloadData];
    }
    NSLog(@"Reload");
}

@end
