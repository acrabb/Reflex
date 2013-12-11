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
@synthesize dataForPlot;
@synthesize graphHostView = _graphHostView;
bool debugging = true;


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
    if (debugging) {
        int hs = rand();
        int rl = rand();
        int rs = rand();
        for (int i = 0; i < 10; i++) {
            [self.myModel.history setObject:[[DataModel alloc] initWithHammerStrength:hs
                                                                        reflexLatency:rl
                                                                       reflexStrength:rs]
                                     forKey: [NSDate dateWithTimeIntervalSinceNow: -1 * [self secondsPerDay] * i]];
        }
    }
    [self setUpGraph];
}
//-----------------------------------------------------------------------
-(void)setUpGraph
{
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
//    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
//    [graph applyTheme:theme];
    CPTGraphHostingView *hostingView = self.graphHostView;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph     = graph;
    
    graph.paddingLeft   = 10.0;
    graph.paddingTop    = 10.0;
    graph.paddingRight  = 10.0;
    graph.paddingBottom = 10.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.15) length:CPTDecimalFromFloat(2.0)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.15) length:CPTDecimalFromFloat(2.0)];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromString(@"0.5");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.minorTicksPerInterval       = 2;
    NSArray *exclusionRanges = [NSArray arrayWithObjects:
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)],
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(2.99) length:CPTDecimalFromFloat(0.02)],
                                nil];
    x.labelExclusionRanges = exclusionRanges;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromString(@"0.5");
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    exclusionRanges               = [NSArray arrayWithObjects:
                                     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)],
                                     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
                                     [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(3.99) length:CPTDecimalFromFloat(0.02)],
                                     nil];
    y.labelExclusionRanges = exclusionRanges;
    y.delegate             = self;
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot  = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit        = 1.0f;
    lineStyle.lineWidth         = 3.0f;
    lineStyle.lineColor         = [CPTColor whiteColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier    = @"Blue Plot";
    boundLinePlot.dataSource    = self;
    [graph addPlot:boundLinePlot];
    
    
    // Do a blue gradient
   /*
    CPTColor *areaColor1       = [CPTColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
    areaGradient1.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill      = areaGradientFill;
    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    
    // Add plot points
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;
     */
    
    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    NSUInteger i;
    for ( i = 0; i < 60; i++ ) {
        id x = [NSNumber numberWithFloat:i * 0.05];
        id y = [NSNumber numberWithFloat:1.2 * rand() / (float)RAND_MAX];
        [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
    self.dataForPlot = contentArray;
    
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}




//-----------------------------------------------------------------------
-(void)changePlotRange
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(3.0 + 2.0 * rand() / RAND_MAX)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [dataForPlot count];
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = [[dataForPlot objectAtIndex:index] valueForKey:key];
    
//    // Green plot gets shifted above the blue
//    if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
//        if ( fieldEnum == CPTScatterPlotFieldY ) {
//            num = [NSNumber numberWithDouble:[num doubleValue] + 1.0];
//        }
//    }
    return num;
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
-(int)secondsPerDay
{
    return 1 * 60 * 60 * 24;
}
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
