
#import "HomeViewController.h"
#import "TFHpple.h"
#import "WLJArticle.h"
#import "WLJArticleTableViewCell.h"
#import "WLJWebViewController.h"


@interface HomeViewController ()

@property (strong, nonatomic)UIActivityIndicatorView *activityIndicatorView;

@end

static NSString *reusedCellIdentifier = @"ReusedCellIdentifier";
@implementation HomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.urlArray = @[@"http://vjianke.com/Y9A0A.clip?InApp=2", @"http://vjianke.com/YB0GG.clip?InApp=2", @"http://vjianke.com/YB0G4.clip?InApp=2", @"http://vjianke.com/YAVXP.clip?InApp=2", @"http://vjianke.com/Y9OEN.clip?InApp=2", @"http://vjianke.com/Y9FMT.clip?InApp=2", @"http://vjianke.com/YLAE0.clip?InApp=2"];
        self.articlesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[WLJArticleTableViewCell class] forCellReuseIdentifier:reusedCellIdentifier];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.navigationItem.titleView = self.activityIndicatorView;
    self.navigationItem.prompt = @"列表加载...";
        self.navigationItem.title = @"文章列表";
    [self.activityIndicatorView startAnimating];

}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"我被调用了");
    [super viewDidAppear:animated];
    static BOOL isLoad = NO;
    if (!isLoad) {
        
        isLoad = YES;
        NSString *url = nil;
        NSData *data = nil;
        NSArray *imagesUrl = nil;
        NSData *imgData = nil;
        
        for (int i = 0; i < [self.urlArray count]; i++) {
            NSLog(@"获得数据");
            WLJArticle *article = [[WLJArticle alloc] init];
            article.imgArray = [[NSMutableArray alloc] init];
            
            url = self.urlArray[i];
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            
            article.articleTitle = [self articleTitle:data value:@"//title"];
            
            imagesUrl = [self getImagesWithData:data rangFirst:@"<body>" rangsecnd:@"</body>" value:@"//img" Value:@"real_src"];//获得某篇文章的所有图片urls
            article.imageurls = imagesUrl;
            
            //使用NULL占着空间，方便将来存放对应位置的图片
            for (int j = 0; j < [imagesUrl count]; j ++) {
                NSNull *null = [[NSNull alloc] init];
                [article.imgArray addObject:null];
            }
            
            //在文章列表中只要请求一张图片，较少网络请求，只是文章的索引
            for (int j = 0; j < 1; j++) {
                imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagesUrl[j]]];
                [article.imgArray replaceObjectAtIndex:j withObject:[UIImage imageWithData:imgData]];
            }
      
            [self.articlesArray addObject:article];
        }
        [self.tableView reloadData];
        [self.activityIndicatorView stopAnimating];
        self.navigationItem.titleView = nil;
        self.navigationItem.prompt = nil;
    }

}

- (NSString *)articleTitle:(NSData *)data value:(NSString *)titleValue{
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [xpathParser searchWithXPathQuery:titleValue];
    TFHppleElement *element = [elements objectAtIndex:0];
    return [element content];
}
- (NSMutableArray *)articleContent:(NSData *)data rangFirst:(NSString *)range rangsecnd:(NSString *) range2 value:(NSString *)contentValue{
    NSMutableArray *contentArray = nil;
    
    NSString *contentStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange rang = [contentStr rangeOfString:range];
    NSMutableString *contentStr2 = [[NSMutableString alloc] initWithString:[contentStr substringFromIndex:rang.location + rang.length]];
    
    NSRange rang2 = [contentStr2 rangeOfString:range2];
    NSMutableString *contentStr3 = [[NSMutableString alloc] initWithString:[contentStr2 substringToIndex:rang2.location]];
    
    NSData *dataContent = [contentStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:dataContent];
    NSArray *elements = [xpathParser searchWithXPathQuery:contentValue];
    contentArray = [elements mutableCopy];
    
    return contentArray;
}

- (NSMutableArray *)getImagesWithData:(NSData *)data rangFirst:(NSString *)range rangsecnd:(NSString *)range2 value:(NSString *)imgValue Value:(NSString *)prefixValue{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    
    NSString *imageStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange rang = [imageStr rangeOfString:range];
    NSMutableString *imageStr2 = [[NSMutableString alloc] initWithString:[imageStr substringFromIndex:rang.location +rang.length]];
    
    NSRange rang2 =[imageStr2 rangeOfString:range2];
    NSMutableString *imageStr3 = [[NSMutableString alloc] initWithString:[imageStr2 substringToIndex:rang2.location]];
    
    NSData *dataStr = [imageStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:dataStr];
    NSArray *elements = [xpathParser searchWithXPathQuery:imgValue];
    for (TFHppleElement *element in elements) {
        NSDictionary *elementContent = [element attributes];
        [imagesArray addObject:[elementContent objectForKey:prefixValue]];
    }
    
    return imagesArray;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.articlesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WLJArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellIdentifier];

    cell.imgView.image = [[(WLJArticle *)[self.articlesArray objectAtIndex:indexPath.row] imgArray] objectAtIndex:0];
    cell.articleLabel.text = [(WLJArticle *)[self.articlesArray objectAtIndex:indexPath.row] articleTitle];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //采用自排版
    
    WLJArticle *article = (WLJArticle *)[self.articlesArray objectAtIndex:indexPath.row];
    

    
    //采用UIWebView
    WLJWebViewController *webView = [[WLJWebViewController alloc] init];
    webView.urlString = self.urlArray[indexPath.row];
    webView.article = article;
    
    [self.navigationController pushViewController:webView animated:YES];
    
}

@end
