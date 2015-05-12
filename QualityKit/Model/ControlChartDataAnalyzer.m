//
//  ControlChartDataAnalyzer.m
//  QualityKit
//
//  Created by 秦昱博 on 15/5/12.
//  Copyright (c) 2015年 Qin Yubo. All rights reserved.
//

#import "ControlChartDataAnalyzer.h"
#import "QualityKitDef.h"

@implementation ControlChartDataAnalyzer

+ (void)getStatisticalValuesOfDoubleArray:(NSArray *)dataArr checkRulesArray:(NSArray *)rulesArr controlChartType:(NSString *)type withBlock:(void (^)(float, float, float, NSArray *, NSArray *, NSString *))block {
    
    __block float UCLValue;
    __block float LCLValue;
    __block float CLValue;
    __block NSMutableArray *plotArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *indexesOfErrorPoints = [[NSMutableArray alloc] init];
    __block NSString *errorDescription = @"";
    
    [self calculateControlLineValuesOfData:dataArr controlChartType:type block:^(float _UCLValue, float _LCLValue, float _CLValue, NSArray *_plotArr) {
        UCLValue = _UCLValue;
        LCLValue = _LCLValue;
        CLValue = _CLValue;
        plotArr = [_plotArr mutableCopy];
    }];
    
    for (NSString *rule in rulesArr) {
        [self checkData:dataArr UCLValue:UCLValue LCLValue:LCLValue CLValue:CLValue rule:rule block:^(NSArray *_indexesOfErrorPoints, NSString *_errorDescription) {
            for (id tmp in _indexesOfErrorPoints) {
                if (![indexesOfErrorPoints containsObject:tmp]) {
                    [indexesOfErrorPoints addObject:tmp];
                }
            }
            errorDescription = [NSString stringWithFormat:@"%@\n%@", errorDescription, _errorDescription];
        }];
    }
    
    block(UCLValue, LCLValue, CLValue, plotArr, indexesOfErrorPoints, errorDescription);
}

+ (void)calculateControlLineValuesOfData:(NSArray *)dataArray controlChartType:(NSString *)type block:(void (^)(float, float, float, NSArray *))block {
    
    if ([type isEqualToString:QKControlChartTypeXBar]) {
        NSMutableArray *xBarArr = [[NSMutableArray alloc] init];
        
        for (NSArray *rowArr in dataArray) {
            float xSum = 0;
            for (NSNumber *item in rowArr) {
                xSum = xSum + [item floatValue];
            }
            [xBarArr addObject:[NSNumber numberWithFloat:xSum/(rowArr.count)]];
        }
        
        float xBarSum = 0;
        for (NSNumber *xBar in xBarArr) {
            xBarSum = xBarSum + [xBar floatValue];
        }
        float CLValue = xBarSum/(xBarArr.count);
        
        __block float rBar;
        [self calculateControlLineValuesOfData:dataArray controlChartType:QKControlChartTypeR block:^(float _UCLR, float _LCLR, float _CLR, NSArray *_rArr) {
            rBar = _CLR;
        }];
        
        float A2 = [QualityKitDef QKConstantA2:xBarArr.count];
        float UCLValue = CLValue + A2 * rBar;
        float LCLValue = CLValue - A2 * rBar;
        
        block(UCLValue, LCLValue, CLValue, xBarArr);
    }
    
    if ([type isEqualToString:QKControlChartTypeR]) {
        NSMutableArray *rArr = [[NSMutableArray alloc] init];
        for (NSArray *rowArr in dataArray) {
            float minValue = [rowArr[0] floatValue];
            float maxValue = [rowArr[0] floatValue];
            for (NSNumber *tmpNum in rowArr) {
                float tmpFloat = [tmpNum floatValue];
                if (tmpFloat >= maxValue) {
                    maxValue = tmpFloat;
                }
                if (tmpFloat <= minValue) {
                    minValue = tmpFloat;
                }
            }
            [rArr addObject:[NSNumber numberWithFloat:maxValue - minValue]];
        }
        
        float rSum = 0;
        for (NSNumber *tmpR in rArr) {
            rSum = rSum + [tmpR floatValue];
        }
        float CLValue = rSum/(rArr.count);
        
        float D4 = [QualityKitDef QKConstantD4:rArr.count];
        float UCLValue = D4 * CLValue;
        float D3 = [QualityKitDef QKConstantD3:rArr.count];
        float LCLValue = D3 * CLValue;
        
        block(UCLValue, LCLValue, CLValue, rArr);
    }
}

+ (void)checkData:(NSArray *)dataArray UCLValue:(float)UCL LCLValue:(float)LCL CLValue:(float)CL rule:(NSString *)checkRule block:(void (^)(NSArray *, NSString *))block {
    
    if ([checkRule isEqualToString:QKCheckRuleOutsideControlLine]) {
        
    }
}

@end
