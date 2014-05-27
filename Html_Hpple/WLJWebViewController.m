//
//  WLJWebViewController.m
//  Html_Hpple
//
//  Created by 王霖 on 14-5-27.
//  Copyright (c) 2014年 com.wangan. All rights reserved.
//

#import "WLJWebViewController.h"

@interface WLJWebViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>{
    BOOL isOpen;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIScrollView *imgScrollView;

@end

@implementation WLJWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isOpen = NO;
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    self.imgScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.imgScrollView.pagingEnabled = YES;
    self.imgScrollView.delegate = self;
    self.imgScrollView.backgroundColor = [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:0.7];
    self.imgScrollView.tag = 101;
    
//    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpImage:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    tapGestureRecognizer.delegate = self;

    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

//既然给view添加单指单击手势，webView的webBrowser也识别这手势，所以要两个手势同时识别，这样，view才能响应手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(void)touchUpImage:(UITapGestureRecognizer *)gestureRecognizer{

    if (!isOpen) {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
            NSString *imgURL  = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
            NSString *urlTOstring = [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:imgURL];
            NSLog(@"脚本执行后：%@",urlTOstring);
            if ([urlTOstring hasSuffix:@"jpg"]) {
                self.imgScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * [self.article.imageurls count], self.view.bounds.size.height);
                for (int j = 0; j < [self.article.imageurls count]; j++) {
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(j * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                    imgView.tag = j+1000;
                    imgView.contentMode = UIViewContentModeScaleAspectFit;
                    [self.imgScrollView addSubview:imgView];
                }
                [self.view addSubview:self.imgScrollView];
                
                NSInteger traceTag = -1;
                for (int i = 0; i < [self.article.imageurls count]; i++) {
                    //得到图片的相对位置
                    if ([[self.article.imageurls objectAtIndex:i] isEqualToString:urlTOstring]) {
                        traceTag = i;
                        self.imgScrollView.contentOffset = CGPointMake(self.view.bounds.size.width * i, 0);
                        break;
                    }
                }
#warning 这里是不是要判断一下traceTag的合法性
                //判断图片是否已经缓冲完成
                if (![[self.article.imgArray objectAtIndex:traceTag] isKindOfClass:[NSNull class]]) {
                    //已经存在，显示图片
                    UIImageView *imageView = (UIImageView *)[self.imgScrollView viewWithTag: traceTag + 1000];
                    imageView.image = self.article.imgArray[traceTag];
                }else{
                    //异步加载图片
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{
                        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlTOstring]];
                        UIImageView *imageView = (UIImageView *)[self.imgScrollView viewWithTag:traceTag + 1000];
                        //存储图片
                        [self.article.imgArray replaceObjectAtIndex:traceTag withObject:[UIImage imageWithData:imgData]];
//                        [article.imgArray addObject:[UIImage imageWithData:imgData]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = [UIImage imageWithData:imgData];
                        });
                    });
                }
                
//                UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
//                view.backgroundColor = [UIColor colorWithHue:0.3 saturation:0.3 brightness:0.3 alpha:0.7];
//                [self.view addSubview:view];
//                UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//                imgView.contentMode = UIViewContentModeScaleAspectFit;
//                imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlTOstring]]];
//                view.tag = 101;
//                [view addSubview:imgView];
                isOpen = YES;
            }
        }
    }else{
        UIView *view = [self.view viewWithTag:101];
        [view removeFromSuperview];
        isOpen = NO;
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger pageNum = scrollView.contentOffset.x / self.view.bounds.size.width;
    //判断图片是否已经缓冲完成
    if (![[self.article.imgArray objectAtIndex:pageNum] isKindOfClass:[NSNull class]]) {
        //已经存在，显示图片
        UIImageView *imageView = (UIImageView *)[self.imgScrollView viewWithTag: pageNum + 1000];
        imageView.image = self.article.imgArray[pageNum];
    }else{
        //异步加载图片
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.article.imageurls objectAtIndex:pageNum]]];
            UIImageView *imageView = (UIImageView *)[self.imgScrollView viewWithTag:pageNum + 1000];
            //存储图片
            [self.article.imgArray replaceObjectAtIndex:pageNum withObject:[UIImage imageWithData:imgData]];
            //                        [article.imgArray addObject:[UIImage imageWithData:imgData]];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = [UIImage imageWithData:imgData];
            });
        });
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
