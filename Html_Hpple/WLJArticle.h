//
//  WLJArticle.h
//  Html_Hpple
//
//  Created by 王 霖 on 14-5-26.
//  Copyright (c) 2014年 com.wangan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLJArticle : NSObject

@property (nonatomic, strong) NSString *articleTitle;
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *atricleContent;
@property (nonatomic, strong) NSArray *imageurls;

@end
