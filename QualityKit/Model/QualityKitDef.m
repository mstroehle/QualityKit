//
//  QualityKitDef.m
//  QualityKit
//
//  Created by 秦昱博 on 15/5/12.
//  Copyright (c) 2015年 Qin Yubo. All rights reserved.
//

#import "QualityKitDef.h"

@implementation QualityKitDef

/**
 *  注意
 *
 *  以下所有常数在 n=1 时均不应有值。为方便计算，使之为 0
 *  在 n>=10 的情况并不为 0，需要进行调整
 *
 */

+ (float)QKConstant_d3:(NSInteger)n {
    NSArray *d3Arr = @[@0, @0.893, @0.888, @0.880, @0.864, @0.848, @0.833, @0.820, @0.808, @0.797];
    if (n <= 10) {
        return [d3Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

+ (float)QKConstantD3:(NSInteger)n {
    NSArray *D3Arr = @[@0, @0, @0, @0, @0, @0, @0.076, @1.136, @0.184, @0.223];
    if (n <= 10) {
        return [D3Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

+ (float)QKConstantD4:(NSInteger)n {
    NSArray *D4Arr = @[@0, @3.267, @2.579, @2.282, @2.115, @2.004, @1.924, @1.864, @1.816, @1.777];
    if (n <= 10) {
        return [D4Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

+ (float)QKConstantA2:(NSInteger)n {
    NSArray *A2Arr = @[@0, @1.88, @1.023, @0.729, @0.577, @0.483, @0.419, @0.373, @0.337, @0.308];
    if (n <= 10) {
        return [A2Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

+ (float)QKConstantA3:(NSInteger)n {
    NSArray *A3Arr = @[@0, @2.659, @1.954, @1.628, @1.427, @1.287, @1.182, @1.099, @1.032, @0.973];
    if (n <= 10) {
        return [A3Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

+ (float)QKConstantB3:(NSInteger)n {
    NSArray *B3Arr = @[@0, @0, @0, @0, @0, @0.03, @0.118, @0.185, @0.239, @0.284];
    if (n <= 10) {
        return [B3Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

+ (float)QKConstantB4:(NSInteger)n {
    NSArray *B4Arr = @[@0, @3.267, @2.568, @2.266, @2.089, @1.97, @1.882, @1.815, @1.761, @1.716];
    if (n <= 10) {
        return [B4Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

+ (float)QKConstantE2:(NSInteger)n {
    NSArray *E2Arr = @[@0, @2.66, @1.77, @1.46, @1.29, @1.18, @1.11, @1.05, @1.01, @0.98];
    if (n <= 10) {
        return [E2Arr[n - 1] floatValue];
    } else {
        return 0;
    }
}

@end
