//
//  WLJArticleTableViewCell.m
//  Html_Hpple
//
//  Created by 王 霖 on 14-5-26.
//  Copyright (c) 2014年 com.wangan. All rights reserved.
//

#import "WLJArticleTableViewCell.h"
#define CellImgViewWidth 66.0f
#define BetweenLength 10.0f
#define LabelHeight 40.0f

@implementation WLJArticleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CellImgViewWidth, self.bounds.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imgView];
        
        self.articleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CellImgViewWidth + BetweenLength, self.bounds.size.height / 2 - LabelHeight / 2, self.bounds.size.width - CellImgViewWidth - BetweenLength, LabelHeight)];
        [self.contentView addSubview:self.articleLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
