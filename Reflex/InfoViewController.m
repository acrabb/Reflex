//
//  InfoViewController.m
//  Reflex
//
//  Created by André Crabb on 12/6/13.
//  Copyright (c) 2013 Andre Crabb. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

LQRModel *myModel;
CPTScatterPlot *scatterPlot;

@implementation InfoViewController

@synthesize backButton  = _backButton;
@synthesize dataForTopPlot;
@synthesize dataForBottomPlot;
@synthesize topGraphHostView = _topGraphHostView;
bool debugging = true;

CPTPlot *bottomPlot;
CPTPlot *topPlot;

int secondsPerDay = 1 * 60 * 60 * 24;

//-----------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-----------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@">> Info view controller loaded.");
    myModel = [LQRModel sharedInstance];
    [self.backButton.layer setCornerRadius:10.0];
    if (debugging && !self.myModel.history.count) {
        int hs;
        int rl;
        int rs;
        for (int i = 0; i < 10; i++) {
            hs = 1.2 * rand() / (float)RAND_MAX * 10;
            rl = 1.2 * rand() / (float)RAND_MAX * 10;
            rs = 1.2 * rand() / (float)RAND_MAX * 10;
            NSLog(@">>> hs: %d,,, rl: %d,,, rs: %d",hs, rl, rs);
            [self.myModel.history setObject:[[DataModel alloc] initWithHammerStrength:hs
                                                                        reflexLatency:rl
                                                                       reflexStrength:rs]
                                     forKey: [NSDate dateWithTimeIntervalSinceNow: -1 * secondsPerDay * i]];
        }
//        NSLog(@"Info> %@", [self.myModel.history description]);
    }
    NSLog(@"Array>>> %@", [self.myModel.history description]);
    [self setUpTopGraph];
    [self setUpBottomGraph];
}



//-----------------------------------------------------------------------
-(void)setUpTopGraph
{
    // Create graph from theme
    topGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTGraphHostingView *hostingView = self.topGraphHostView;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph     = topGraph;
    
    topGraph.paddingLeft   = 10.0;
    topGraph.paddingTop    = 5.0;
    topGraph.paddingRight  = 10.0;
    topGraph.paddingBottom = 5.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)topGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-secondsPerDay*0.5)
                                                                   length:CPTDecimalFromInt(secondsPerDay*6.0f)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.5)
                                                                   length:CPTDecimalFromFloat(12)];
    plotSpace.delegate = self;
    
    // Axes
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *)topGraph.axisSet;
    CPTXYAxis *x                    = axisSet.xAxis;
    x.majorIntervalLength           = CPTDecimalFromInt(secondsPerDay);
    x.orthogonalCoordinateDecimal   = CPTDecimalFromString(@"0");
    x.minorTicksPerInterval         = 0;
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle         = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate     = [LQRModel refDate];
    x.labelFormatter                = timeFormatter;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength           = CPTDecimalFromString(@"1");
    y.minorTicksPerInterval         = 0;
    y.orthogonalCoordinateDecimal   = CPTDecimalFromString(@"0");
    y.labelFormatter                = [[NSNumberFormatter alloc] init];
    NSArray *exclusionRanges               = [NSArray arrayWithObjects:
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.99) length:CPTDecimalFromFloat(-0.02)],
                                 nil];
    y.labelExclusionRanges = exclusionRanges;
    y.delegate             = self;
    
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot   = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle  = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit            = 1.0f;
    lineStyle.lineWidth             = 3.0f;
    lineStyle.lineColor             = [CPTColor whiteColor];
    boundLinePlot.dataLineStyle     = lineStyle;
    boundLinePlot.identifier        = @"Top Line Plot";
    boundLinePlot.dataSource        = self;
    topPlot = boundLinePlot;
    CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [CPTColor whiteColor];
    topGraph.titleTextStyle = whiteText;
    [topGraph setTitle:@"Reflex Strength"];
    [topGraph addPlot:boundLinePlot];
    
    self.dataForTopPlot = [self.myModel getHistoryAsArrayFor:kLQROptionReflexStrength];
    
//#ifdef PERFORMANCE_TEST
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
//#endif
}



//-----------------------------------------------------------------------
-(void)setUpBottomGraph
{
    // Create graph from theme
    bottomGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTGraphHostingView *hostingView = self.bottomGraphHostView;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph     = bottomGraph;
    
    bottomGraph.paddingLeft   = 10.0;
    bottomGraph.paddingTop    = 5.0;
    bottomGraph.paddingRight  = 10.0;
    bottomGraph.paddingBottom = 5.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)bottomGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-secondsPerDay*0.5)
                                                                   length:CPTDecimalFromInt(secondsPerDay*6.0f)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.5)
                                                                   length:CPTDecimalFromFloat(12)];
    plotSpace.delegate = self;
    
    // Axes
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *)bottomGraph.axisSet;
    CPTXYAxis *x                    = axisSet.xAxis;
    x.majorIntervalLength           = CPTDecimalFromInt(secondsPerDay);
    x.orthogonalCoordinateDecimal   = CPTDecimalFromString(@"0");
    x.minorTicksPerInterval         = 0;
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle         = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate     = [LQRModel refDate];
    x.labelFormatter                = timeFormatter;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength           = CPTDecimalFromString(@"1");
    y.minorTicksPerInterval         = 0;
    y.orthogonalCoordinateDecimal   = CPTDecimalFromString(@"0");
    y.labelFormatter                = [[NSNumberFormatter alloc] init];
    NSArray *exclusionRanges               = [NSArray arrayWithObjects:
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.99) length:CPTDecimalFromFloat(-0.02)],
                                 nil];
    y.labelExclusionRanges = exclusionRanges;
    y.delegate             = self;
    
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot   = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle  = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit            = 1.0f;
    lineStyle.lineWidth             = 3.0f;
    lineStyle.lineColor             = [CPTColor whiteColor];
    boundLinePlot.dataLineStyle     = lineStyle;
    boundLinePlot.identifier        = @"Bottom Line Plot";
    boundLinePlot.dataSource        = self;
    bottomPlot = boundLinePlot;
    [bottomGraph addPlot:boundLinePlot];
    CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [CPTColor whiteColor];
    bottomGraph.titleTextStyle = whiteText;
    [bottomGraph setTitle:@"Reflex Latency"];
    
    self.dataForBottomPlot = [self.myModel getHistoryAsArrayFor:kLQROptionReflexLatency];
    
//#ifdef PERFORMANCE_TEST
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
//#endif
}






//-----------------------------------------------------------------------
-(void)changePlotRange
{
    NSLog(@"CPT> Changing Plot Range");
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)topGraph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (plot == topPlot) {
        return [dataForTopPlot count];
    } else {
        return [dataForBottomPlot count];
    }
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num;
    if (plot == topPlot) {
        num = [[dataForTopPlot objectAtIndex:index] valueForKey:key];
    } else {
        num = [[dataForBottomPlot objectAtIndex:index] valueForKey:key];
    }
    return num;
}


#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)displacement
{
    return CGPointMake(displacement.x, 0);
}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    if (coordinate == CPTCoordinateY) {
        newRange = ((CPTXYPlotSpace*)space).yRange;
//        newRange = [[CPTPlotRange alloc] initWithLocation:[[NSNumber 0.0] decimal] length:newRange.length];
    }
    return newRange;
}


#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;
    
    NSFormatter *formatter = axis.labelFormatter;
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            if ( !positiveStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                positiveStyle  = newStyle;
            }
            theLabelTextStyle = positiveStyle;
        }
        else {
            if ( !negativeStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle  = newStyle;
            }
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringForObjectValue:tickLocation];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    
    return NO;
}



//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//-----------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-----------------------------------------------------------------------
- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
