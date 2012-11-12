//
//  ItemTableViewController.h
//  tabAppNib
//
//  Created by Benjamin Ignacio on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class iPhoneStreamingPlayerViewController;

@interface ItemTableViewController : UIViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
@private
    UITableView *itemTableView_;
    NSMutableArray *items_;
    NSMutableArray *searchResults_;
    NSString *savedSearchTerm_;
    iPhoneStreamingPlayerViewController *playerViewController_;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) iPhoneStreamingPlayerViewController *playerViewController;

- (void)handleSearchForTerm:(NSString *)searchTerm;

@end
