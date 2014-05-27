

#import <UIKit/UIKit.h>

#define ImageViewWidth 300.0f
#define ImageViewHeight 450.0f
#define TitleLabelHeight 60.0f


@interface HomeViewController : UITableViewController

@property (strong, nonatomic)NSArray *urlArray;//所有文章的url数组
@property (strong, nonatomic)NSMutableArray *articlesArray;//所有文章的数组


@end
