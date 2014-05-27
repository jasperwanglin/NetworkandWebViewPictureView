//
//  WLJWebViewController.h
//  Html_Hpple
//
//  Created by 王霖 on 14-5-27.
//  Copyright (c) 2014年 com.wangan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLJArticle.h"

@interface WLJWebViewController : UIViewController

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) WLJArticle *article;
@end
