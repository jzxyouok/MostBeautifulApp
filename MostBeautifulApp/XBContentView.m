//
//  XBContentView.m
//  MostBeautifulApp
//
//  Created by coder on 16/5/30.
//  Copyright © 2016年 coder. All rights reserved.
//
#define kSpace  10.f
#define kYTextSpace 15.f
#define kYImageSpace 5.f
#define kYTitleSpace 40.f
#define kYSeparatorSpace 40.f
#define kIconWH 52.f
#define kYIconSpace 20.f
#import "XBContentView.h"
#import "XMLParserUtils.h"
#import "XMLParserContent.h"
#import "NSString+Util.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
@interface XBContentView() <TTTAttributedLabelDelegate>
@property (strong, nonatomic) UIImageView  *iconImageView;
@end
@implementation XBContentView

- (instancetype)initWithFrame:(CGRect)frame content:(NSString *)text
{
    if (self = [super initWithFrame:frame]) {
        [XMLParserUtils parserWithContent:text complete:^(NSArray *datas) {
            [self buildView:datas];
        }];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [XMLParserUtils parserWithContent:text complete:^(NSArray *datas) {
        [self buildView:datas];
    }];
}

- (void)setIconURLString:(NSString *)iconURLString
{
    _iconURLString = iconURLString;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:_iconURLString]];
}

- (void)buildView:(NSArray *)datas
{
    [self layoutIfNeeded];
    
    UIFont *textFont  = [UIFont systemFontOfSize:16.f];
    UIColor *textColor = [UIColor colorWithHexString:@"#6D6D6D"];
    
    UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:17.f];
    UIColor *titleColor = [UIColor colorWithHexString:@"#6D6D6D"];
    
    CGFloat width = CGRectGetWidth(self.frame) - kSpace * 2;
    CGFloat height = CGRectGetHeight(self.frame) - kSpace * 2;
    
    NSString *linkText = @"点击下载";
    UIFont *linkFont = [UIFont fontWithName:@"Helvetica-Bold" size:15.f];
    
    for (XMLParserContent *content in datas) {
        UIView *lastView = [self.subviews lastObject];
        switch (content.contentType) {
            case XBParserContentTypeText:
            {
                CGFloat y = self.subviews.count == 0 ? 0 : CGRectGetMaxY(lastView.frame) + kYTextSpace;
                CGSize textSize = [content.content sizeWithFont:textFont maxSize:CGSizeMake(width, CGFLOAT_MAX)];
                TTTAttributedLabel *textLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kSpace,y, textSize.width, textSize.height)];
                textLabel.numberOfLines = 0;
                textLabel.font = textFont;
                textLabel.textColor = textColor;
                textLabel.text = content.content;
                [self addSubview:textLabel];
            }
                break;
            case XBParserContentTypeTitle:
            {
                CGSize textSize = [content.content sizeWithFont:titleFont maxSize:CGSizeMake(width, CGFLOAT_MAX)];
                TTTAttributedLabel *titleLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kSpace, CGRectGetMaxY(lastView.frame) + kYTitleSpace, textSize.width, textSize.height)];
                titleLabel.numberOfLines = 0;
                titleLabel.font = titleFont;
                titleLabel.textColor = titleColor;
                titleLabel.text = content.content;
                [self addSubview:titleLabel];
            }
                break;
            case XBParserContentTypeLink:
            {
            
                TTTAttributedLabel *linkLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(kSpace, CGRectGetMaxY(lastView.frame) + kYTextSpace, width, 20.f)];
                linkLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
                linkLabel.delegate = self;
                linkLabel.text = linkText;
                [self addSubview:linkLabel];
                
                NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
                [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
                [linkAttributes setValue:(__bridge id)[UIColor colorWithHexString:@"#69BAF2"].CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
                [linkAttributes setValue:linkFont forKey:(NSString *)kCTFontAttributeName];
                linkLabel.linkAttributes = linkAttributes;
                [linkLabel addLinkToURL:[NSURL URLWithString:content.content] withRange:NSMakeRange(0, linkText.length)];
            }
                
                break;
            case XBParserContentTypeImage:
            {
                NSString *suffix = (NSString *) [[[[content.content componentsSeparatedByString:@"v2/"] objectAtIndex:1] componentsSeparatedByString:@"imageMogr/"] objectAtIndex:0];
                
                if ([suffix hasPrefix:@"gravity"]) {
                    suffix = [suffix stringByAppendingString:@"imageMogr/v2/"];
                    content.content = [content.content stringByReplacingOccurrencesOfString:suffix withString:@""];
                    
                    NSString *dimension = (NSString *)[[[[suffix componentsSeparatedByString:@"/!"] objectAtIndex:1] componentsSeparatedByString:@"-0"] objectAtIndex:0];
                    
                    NSArray *dimensions = [dimension componentsSeparatedByString:@"x"];
                    
                    width  = [[dimensions firstObject] floatValue];
                    height = [[dimensions lastObject] floatValue];
                    
                    CGFloat scale = CGRectGetWidth(self.frame) / width;
                    
                    width  = width * scale - kSpace * 2;
                    height = height * scale - kYImageSpace;
                    
                } else {
                    width = CGRectGetWidth([UIScreen mainScreen].bounds) - kSpace * 2;
                    height = CGRectGetHeight([UIScreen mainScreen].bounds) - kSpace * 2;
                }
                
                CGFloat y = [lastView isKindOfClass:[UILabel class]] ? kYTextSpace : kYImageSpace;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSpace, CGRectGetMaxY(lastView.frame) + y, width, height)];
                imageView.backgroundColor = [UIColor whiteColor];
                [self addSubview:imageView];
                [imageView sd_setImageWithURL:[NSURL URLWithString:content.content]];
                
            }
                break;
              
        }
    }
    
    UIView *lastView = [self.subviews lastObject];
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(kSpace, CGRectGetMaxY(lastView.frame) + kYSeparatorSpace, width, 1.f)];
    separatorView.backgroundColor = [UIColor colorWithHexString:@"#D6D6D6"];
    [self addSubview:separatorView];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x - kIconWH / 2.f, CGRectGetMaxY(separatorView.frame) + kYIconSpace, kIconWH, kIconWH)];
    iconImageView.layer.masksToBounds = YES;
    iconImageView.layer.cornerRadius  = 11.f;
    self.iconImageView = iconImageView;
    [self addSubview:iconImageView];
    
    
    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(iconImageView.frame);
    self.frame = frame;
}


#pragma mark -- 
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    if ([self.delegate respondsToSelector:@selector(contentAttributedLabel:didSelectLinkWithURL:)]) {
        [self.delegate contentAttributedLabel:label didSelectLinkWithURL:url];
    }
}

@end
