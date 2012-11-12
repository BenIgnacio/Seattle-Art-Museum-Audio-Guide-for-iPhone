//
//  Item.h
//  SAMaudioGuide
//
//  Created by Benjamin Ignacio on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * info;

@end
