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

@interface InfoViewController : ViewController <CPTPlotDataSource, CPTAxisDelegate, CPTPlotSpaceDelegate>
{
    CPTXYGraph *topGraph;
    CPTXYGraph *bottomGraph;
    NSMutableArray *dataForTopPlot;
    NSMutableArray *dataForBottomPlot;
}
@property (weak, nonatomic) IBOutlet UIButton       *backButton;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForTopPlot;
@property (readwrite, strong, nonatomic) NSMutableArray *dataForBottomPlot;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *topGraphHostView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *bottomGraphHostView;

- (IBAction)backButtonTapped:(id)sender;

@end
