//
//  InfoViewController.h
//  Reflex
//
//  Created by André Crabb on 12/6/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import "ViewController.h"
#import "LQRModel.h"

@interface InfoViewController : ViewController
- (IBAction)backButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end
