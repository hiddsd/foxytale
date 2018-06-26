//
//  SearchForFriendViewController.h
//  Foxytale
//
//  Created by Chris on 21.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchForFriendViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *UserTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *UserSearchBar;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

