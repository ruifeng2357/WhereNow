//
//  EditReceiverIDViewController.h
//  WhereNow
//
//  Created by Admin on 12/2/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditReceiverIDDelegate <NSObject>
@required
- (void) didGetReceiverID:(NSString *)receiverID;

@end

@interface EditReceiverIDViewController : UIViewController
{    
}
@property (nonatomic, retain) NSString *receiverID;
@property (nonatomic, retain) id<EditReceiverIDDelegate> delegate;

@end