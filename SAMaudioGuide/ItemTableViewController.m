//
//  ItemTableViewController.m
//  tabAppNib
//
//  Created by Benjamin Ignacio on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemTableViewController.h"
#import "Item.h"
#import "customTableViewCell.h"
#import "MyStreamingMovieViewController.h"

@implementation ItemTableViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize items = items_;
@synthesize itemTableView = itemTableView_;
@synthesize searchResults = searchResults_;
@synthesize savedSearchTerm = savedSearchTerm_;
@synthesize playerViewController = playerViewController_;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Seattle Art Museum", @"Seattle Art Museum");
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
    //Get all the items
    //Core data loading...
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item"  inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) 
    {
        NSLog(@"Core data error!");  // Handle the error;
    }
    
    self.items = mutableFetchResults;
    
    // Restore search term
    if ([self savedSearchTerm])
        [[[self searchDisplayController] searchBar] setText:[self savedSearchTerm]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Save the state of the search UI so that it can be restored if the view is re-created.
    [self setSavedSearchTerm:[[[self searchDisplayController] searchBar] text]];
    [self setSearchResults:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    // Only support portrait orientation.
    return (NO);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
	
    //Which tableview is making the request?
    if (tableView == [[self searchDisplayController] searchResultsTableView])
        rows = [[self searchResults] count];
    else
        rows = [items_ count];
	
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = nil;
	
    if (tableView == [[self searchDisplayController] searchResultsTableView])
        item = [[self searchResults] objectAtIndex:indexPath.row];
    else
        item = [items_ objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"Cell";
    customTableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"customTableViewCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects)
        {
            if ([currentObject isKindOfClass:[customTableViewCell class]])
            {
                cell = (customTableViewCell *)currentObject;
                break;
            }
        }
    }
    
    cell.artImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", [item.id intValue]]];
    cell.artTitle.text = item.name;
    cell.artist.text = item.artist;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = nil;

    //Which tableview is making the request, search or main?
    if (tableView == [[self searchDisplayController] searchResultsTableView])
        item = [searchResults_ objectAtIndex:indexPath.row];
    else
        item = [items_ objectAtIndex:indexPath.row];
    
    //Present art in playerViewController
    if (!self.playerViewController) {
        self.playerViewController = [[MyStreamingMovieViewController alloc] initWithNibName:@"StreamingView" bundle:nil];
    }

    self.playerViewController.item = item;
    [self.navigationController pushViewController:self.playerViewController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 90;
}


- (void)handleSearchForTerm:(NSString *)searchTerm
{
    [self setSavedSearchTerm:searchTerm];
	
    if ([self searchResults] == nil)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self setSearchResults:array];
    }
	
    [[self searchResults] removeAllObjects];
	
    if ([[self savedSearchTerm] length] != 0)
    {
        for (Item *item in items_)
        {
            if (([item.name rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)||([item.artist rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)||([item.info rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound))
            {
                [[self searchResults] addObject:item];
            }
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self handleSearchForTerm:searchString];
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self setSavedSearchTerm:nil];
    [[self itemTableView] reloadData];
}

@end
