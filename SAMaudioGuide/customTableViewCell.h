//
//  customTableViewCell.h
//  SAMaudioGuide
//
//  Created by Benjamin Ignacio on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customTableViewCell : UITableViewCell {

}

@property(strong, nonatomic) IBOutlet UIImageView *artImage;
@property(strong, nonatomic) IBOutlet UILabel *artTitle;
@property(strong, nonatomic) IBOutlet UILabel *artist;

@end
