//
//  InfoViewController.h
//  Reflex
//
//  Created by André Crabb on 12/6/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import "ViewController.h"
#import "LQRModel.h"
#import "CorePlot-CocoaTouch.h"

@interface InfoViewController : ViewController <CPTPlotDataSource, CPTAxisDelegate>
{
    CPTXYGraph *graph;
    NSMutableArray *dataForPlot;
}
@property (weak, nonatomic) IBOutlet UIButton       *backButton;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForPlot;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphHostView;

- (IBAction)backButtonTapped:(id)sender;

@end
