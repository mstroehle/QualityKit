//
//  ControlChartViewController.h
//  QualityKit
//
//  Created by 秦昱博 on 15/5/12.
//  Copyright (c) 2015年 Qin Yubo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QKSavedControlChart.h"

@interface ControlChartViewController : UIViewController

@property (strong, nonatomic) NSString *chartType;
@property (strong, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) QKSavedControlChart *savedControlChart;
@property (nonatomic) BOOL usingSavedControlChart;

@end
