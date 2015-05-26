//
//  ControlChartViewController.m
//  QualityKit
//
//  Created by 秦昱博 on 15/5/12.
//  Copyright (c) 2015年 Qin Yubo. All rights reserved.
//

#import "ControlChartViewController.h"
#import "ALActionBlocks.h"
#import "QKControlChartView.h"
#import "QKDef.h"
#import "QKDataAnalyzer.h"
#import "MsgDisplay.h"
#import "QKStatisticalFoundations.h"
#import "ProcessCapabilityAnalysisViewController.h"
#import "QKExportManager.h"
#import <QuickLook/QuickLook.h>

@interface ControlChartViewController ()<ProcessCapabilityAnalysisDelegate, QLPreviewControllerDataSource>

@end

@implementation ControlChartViewController {
    QKControlChartView *chartView;
    QKControlChartView *subChartView;
    UITextView *errorMsgView;
    NSString *chartTitle;
    NSString *subChartTitle;
    NSString *chartRule;
    NSString *subChartRule;
    
    NSString *exportFileName;
    QLPreviewController *quickLookController;
}

@synthesize chartType;
@synthesize dataArr;
@synthesize usingSavedControlChart;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *processAnalysisBtn = [[UIBarButtonItem alloc] initWithTitle:@"过程能力分析" style:UIBarButtonItemStylePlain block:^(id weakSender) {
        if ((chartView != nil && chartView.indexesOfErrorPoints.count != 0) || (subChartView != nil && subChartView.indexesOfErrorPoints.count != 0)) {
            // 控制图不受控
            [MsgDisplay showErrorMsg:@"过程不受控\n无法进行过程能力分析"];
        } else if (chartView != nil && subChartView != nil) {
            // 有两个图
            if ([QKStatisticalFoundations shapiroWilkTest:chartView.dataArr] && [QKStatisticalFoundations shapiroWilkTest:subChartView.dataArr]) {
                [self processCapabilityAnalysis];
            } else {
                [MsgDisplay showErrorMsg:@"数据不满足正态分布"];
            }
        } else if (chartView != nil) {
            // 有一个图
            if ([QKStatisticalFoundations shapiroWilkTest:chartView.dataArr]) {
                [self processCapabilityAnalysis];
            } else {
                [MsgDisplay showErrorMsg:@"数据不满足正态分布"];
            }
        }
    }];
    UIBarButtonItem *exportChartBtn = [[UIBarButtonItem alloc] initWithTitle:@"导出控制图" style:UIBarButtonItemStylePlain block:^(id weakSender) {
        UIImage *image = [QKExportManager imageFromView:self.view];
        NSArray *activityItem = @[image];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItem applicationActivities:nil];
        activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        activityViewController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItems[0];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }];
    [self.navigationItem setRightBarButtonItems:@[exportChartBtn, processAnalysisBtn]];
    
    errorMsgView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    errorMsgView.translatesAutoresizingMaskIntoConstraints = NO;
    errorMsgView.font = [UIFont systemFontOfSize:14.0];
    errorMsgView.editable = NO;
    [self.view addSubview:errorMsgView];
    
    if ([chartType isEqualToString:QKControlChartTypeXBarR] || [chartType isEqualToString:QKControlChartTypeXBarS] || [chartType isEqualToString:QKControlChartTypeXMR]) {
        
        if ([chartType isEqualToString:QKControlChartTypeXBarR]) {
            chartTitle = @"XBar 控制图";
            subChartTitle = @"R 控制图";
            chartRule = QKControlChartTypeXBar;
            subChartRule = QKControlChartTypeR;
        } else if ([chartType isEqualToString:QKControlChartTypeXBarS]) {
            chartTitle = @"XBar 控制图";
            subChartTitle = @"S 控制图";
            chartRule = QKControlChartTypeXBarUsingS;
            subChartRule = QKControlChartTypeS;
        } else if ([chartType isEqualToString:QKControlChartTypeXMR]) {
            chartTitle = @"X 控制图";
            subChartTitle = @"MR 控制图";
            chartRule = QKControlChartTypeX;
            subChartRule = QKControlChartTypeMR;
        }
        
        if (usingSavedControlChart) {
            chartView = [[QKControlChartView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            chartView.translatesAutoresizingMaskIntoConstraints = NO;
            [QKDataAnalyzer getStatisticalValuesOfDoubleArray:dataArr checkRulesArray:[[NSUserDefaults standardUserDefaults] objectForKey:QKCheckRules] controlChartType:chartRule withBlock:^(float _UCLValue, float _LCLValue, float _CLValue, NSArray *_plotArr, NSArray *_indexesOfErrorPoints, NSString *_errDescription) {
                chartView.UCLValue = _UCLValue;
                chartView.LCLValue = _LCLValue;
                chartView.CLValue = _CLValue;
                chartView.dataArr = _plotArr;
                chartView.indexesOfErrorPoints = _indexesOfErrorPoints;
                errorMsgView.text = ([_errDescription isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"%@：\n%@", chartTitle, _errDescription];
            }];
            [self.view addSubview:chartView];
            
            subChartView = [[QKControlChartView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            subChartView.translatesAutoresizingMaskIntoConstraints = NO;
            [QKDataAnalyzer getStatisticalValuesOfDoubleArray:dataArr checkRulesArray:[[NSUserDefaults standardUserDefaults] objectForKey:QKCheckRules] controlChartType:subChartRule withBlock:^(float _UCLValue, float _LCLValue, float _CLValue, NSArray *_plotArr, NSArray *_indexesOfErrorPoints, NSString *_errDescription) {
                subChartView.UCLValue = _UCLValue;
                subChartView.LCLValue = _LCLValue;
                subChartView.CLValue = _CLValue;
                subChartView.dataArr = _plotArr;
                subChartView.indexesOfErrorPoints = _indexesOfErrorPoints;
                errorMsgView.text =  ([_errDescription isEqualToString:@""]) ? errorMsgView.text : [NSString stringWithFormat:@"%@\n%@：\n%@", errorMsgView.text, subChartTitle, _errDescription];
            }];
            [self.view addSubview:subChartView];
        } else {
            chartView = [[QKControlChartView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            chartView.translatesAutoresizingMaskIntoConstraints = NO;
            [QKDataAnalyzer getStatisticalValuesOfDoubleArray:dataArr checkRulesArray:[[NSUserDefaults standardUserDefaults] objectForKey:QKCheckRules] controlChartType:chartRule withBlock:^(float _UCLValue, float _LCLValue, float _CLValue, NSArray *_plotArr, NSArray *_indexesOfErrorPoints, NSString *_errDescription) {
                chartView.UCLValue = _UCLValue;
                chartView.LCLValue = _LCLValue;
                chartView.CLValue = _CLValue;
                chartView.dataArr = _plotArr;
                chartView.indexesOfErrorPoints = _indexesOfErrorPoints;
                errorMsgView.text = ([_errDescription isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"%@：\n%@", chartTitle, _errDescription];
            }];
            [self.view addSubview:chartView];
            
            subChartView = [[QKControlChartView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            subChartView.translatesAutoresizingMaskIntoConstraints = NO;
            [QKDataAnalyzer getStatisticalValuesOfDoubleArray:dataArr checkRulesArray:[[NSUserDefaults standardUserDefaults] objectForKey:QKCheckRules] controlChartType:subChartRule withBlock:^(float _UCLValue, float _LCLValue, float _CLValue, NSArray *_plotArr, NSArray *_indexesOfErrorPoints, NSString *_errDescription) {
                subChartView.UCLValue = _UCLValue;
                subChartView.LCLValue = _LCLValue;
                subChartView.CLValue = _CLValue;
                subChartView.dataArr = _plotArr;
                subChartView.indexesOfErrorPoints = _indexesOfErrorPoints;
                errorMsgView.text =  ([_errDescription isEqualToString:@""]) ? errorMsgView.text : [NSString stringWithFormat:@"%@\n%@：\n%@", errorMsgView.text, subChartTitle, _errDescription];
            }];
            [self.view addSubview:subChartView];
        }
        
        NSDictionary *views = NSDictionaryOfVariableBindings(chartView, subChartView, errorMsgView);
        NSDictionary *metrics = @{@"lowerDist": @240};
        NSString *vfl = @"|-16-[chartView]-16-|";
        NSString *vfl2 = @"V:|-64-[chartView]-32-[subChartView(chartView)]-16-[errorMsgView(180)]-16-|";
        NSString *vfl3 = @"|-16-[subChartView]-16-|";
        NSString *vfl4 = @"|-16-[errorMsgView]-16-|";
        for (NSString *tmpVFL in @[vfl, vfl2, vfl3, vfl4]) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:tmpVFL options:0 metrics:metrics views:views]];
        }
    } else {
        if ([chartType isEqualToString:QKControlChartTypeP]) {
            chartTitle = @"P 控制图";
            chartRule = QKControlChartTypeP;
        } else if ([chartType isEqualToString:QKControlChartTypePn]) {
            chartTitle = @"Pn 控制图";
            chartRule = QKControlChartTypePn;
        } else if ([chartType isEqualToString:QKControlChartTypeC]) {
            chartTitle = @"C 控制图";
            chartRule = QKControlChartTypeC;
        } else if ([chartType isEqualToString:QKControlChartTypeU]) {
            chartTitle = @"U 控制图";
            chartRule = QKControlChartTypeU;
        }
        
        if (usingSavedControlChart) {
            chartView = [[QKControlChartView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            chartView.translatesAutoresizingMaskIntoConstraints = NO;
            [QKDataAnalyzer getStatisticalValuesOfDoubleArray:dataArr checkRulesArray:[[NSUserDefaults standardUserDefaults] objectForKey:QKCheckRules] controlChartType:chartRule withBlock:^(float _UCLValue, float _LCLValue, float _CLValue, NSArray *_plotArr, NSArray *_indexesOfErrorPoints, NSString *_errDescription) {
                chartView.UCLValue = _UCLValue;
                chartView.LCLValue = _LCLValue;
                chartView.CLValue = _CLValue;
                chartView.dataArr = _plotArr;
                chartView.indexesOfErrorPoints = _indexesOfErrorPoints;
                errorMsgView.text = ([_errDescription isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"%@：%@", chartTitle, _errDescription];
            }];
            [self.view addSubview:chartView];
        } else {
            chartView = [[QKControlChartView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            chartView.translatesAutoresizingMaskIntoConstraints = NO;
            [QKDataAnalyzer getStatisticalValuesOfDoubleArray:dataArr checkRulesArray:[[NSUserDefaults standardUserDefaults] objectForKey:QKCheckRules] controlChartType:chartRule withBlock:^(float _UCLValue, float _LCLValue, float _CLValue, NSArray *_plotArr, NSArray *_indexesOfErrorPoints, NSString *_errDescription) {
                chartView.UCLValue = _UCLValue;
                chartView.LCLValue = _LCLValue;
                chartView.CLValue = _CLValue;
                chartView.dataArr = _plotArr;
                chartView.indexesOfErrorPoints = _indexesOfErrorPoints;
                errorMsgView.text = ([_errDescription isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"%@：%@", chartTitle, _errDescription];
            }];
            [self.view addSubview:chartView];
        }
        
        NSDictionary *views = NSDictionaryOfVariableBindings(chartView, errorMsgView);
        NSDictionary *metrics = @{@"lowerDist": @240};
        NSString *vfl = @"|-16-[chartView]-16-|";
        NSString *vfl2 = @"V:|-64-[chartView]-32-[errorMsgView(240)]-16-|";
        NSString *vfl4 = @"|-16-[errorMsgView]-16-|";
        for (NSString *tmpVFL in @[vfl, vfl2, vfl4]) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:tmpVFL options:0 metrics:metrics views:views]];
        }
    }
    
    self.title = [NSString stringWithFormat:@"%@ 控制图", chartType];
    
    // save shared instances
    
    [data shareInstance].chartView = chartView;
    [data shareInstance].subChartView = subChartView;
    [data shareInstance].title = self.title;
    [data shareInstance].chartTitle = chartTitle;
    [data shareInstance].subChartTitle = subChartTitle; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processCapabilityAnalysis {
    ProcessCapabilityAnalysisViewController *pcaController = [[ProcessCapabilityAnalysisViewController alloc] initWithNibName:@"ProcessCapabilityAnalysisViewController" bundle:nil];
    pcaController.controlChartType = chartType;
    pcaController.delegate = self;
    if (chartView != nil) {
        pcaController.dataArr = dataArr;
    }
    
    UINavigationController *pcaNav = [[UINavigationController alloc] initWithRootViewController:pcaController];
    pcaNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:pcaNav animated:YES completion:nil];
}

#pragma mark - QLPreviewController

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *pdfPath = [path stringByAppendingPathComponent:exportFileName];
    NSURL *pdfURL = [NSURL fileURLWithPath:pdfPath];
    return pdfURL;
}

#pragma mark - ProcessCapabilityAnalysisDelegate

- (void)pushPDFPreviewViewControllerWithFileName:(NSString *)fileName {
    exportFileName = [fileName stringByAppendingPathExtension:@"pdf"];
    quickLookController = [[QLPreviewController alloc]init];
    quickLookController.view.backgroundColor = [UIColor whiteColor];
    quickLookController.dataSource = self;
    [self.navigationController pushViewController:quickLookController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
