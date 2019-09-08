//
//  EPSegmentControl.m
//  AlterDemo
//
//  Created by JinFeng on 2018/11/26.
//  Copyright © 2018年 Alter. All rights reserved.
//

#import "EPSegmentControl.h"
#import "EPColorHelper.h"

static const unsigned kTitleToImageSpace = 5;

@interface EPSegmentControl ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, assign) CGFloat fontChange;
@end

@implementation EPSegmentControl

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selected"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setupViews {
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    
    if  (!self.rightImageView) {
        self.rightImageView = [[UIImageView alloc] init];
        [self addSubview:self.rightImageView];
    }
    
    if (!self.leftImageView) {
        self.leftImageView = [[UIImageView alloc] init];
        [self addSubview:self.leftImageView];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setNormalFont:(UIFont *)normalFont {
    _normalFont = normalFont;
    self.titleLabel.font = normalFont;
}

- (UIFont *)selectFont {
    return _selectFont? _selectFont : self.normalFont;
}

- (void)setRightImage:(UIImage *)rightImage {
    _rightImage = rightImage;
    self.rightImageView.image = rightImage;
}

- (void)setLeftImage:(UIImage *)leftImage {
    _leftImage = leftImage;
    self.leftImageView.image = leftImage;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"]) {
        BOOL selected = [change[NSKeyValueChangeNewKey] boolValue];
        if (selected) {
            self.titleLabel.textColor = self.selectedColor;
            CGFloat fontChange = (self.selectFont.pointSize - self.normalFont.pointSize) / self.normalFont.pointSize;
            self.transform = CGAffineTransformMakeScale(1 + fontChange, 1 + fontChange);
        } else {
            self.titleLabel.textColor = self.normalColor;
            self.transform = CGAffineTransformMakeScale(1, 1);
        }
    }
}

- (void)setColorChangeScale:(CGFloat)colorChangeScale {
    if (colorChangeScale < 0) {
        colorChangeScale = -colorChangeScale;
    }
    _colorChangeScale = colorChangeScale;
    
    EPRgb rgb0,rgb1;
    if (self.selected) { // 此时是选中的，那么需要从选中颜色渐变到默认
        rgb0 = [EPColorHelper readFromColor:self.selectedColor];
        rgb1 = [EPColorHelper readFromColor:self.normalColor];
    } else { // 从默认渐变到选中
        rgb0 = [EPColorHelper readFromColor:self.normalColor];
        rgb1 = [EPColorHelper readFromColor:self.selectedColor];
    }
    // 渐变过程中的RGB
    CGFloat c_red = rgb0.red + (rgb1.red - rgb0.red) * colorChangeScale;
    CGFloat c_green = rgb0.green + (rgb1.green - rgb0.green) * colorChangeScale;
    CGFloat c_blue = rgb0.blue + (rgb1.blue - rgb0.blue) * colorChangeScale;
    
    self.titleLabel.textColor = [UIColor colorWithRed:c_red green:c_green blue:c_blue alpha:rgb0.alpha];
}

- (void)setFontChangeScale:(CGFloat)fontChangeScale {
    if (fontChangeScale < 0) {
        fontChangeScale = -fontChangeScale;
    }
    _fontChangeScale = fontChangeScale;
    // 计算倍数
    CGFloat fontChange = [self getFontChangeScale] - 1;
    if (self.selected) {
        self.transform = CGAffineTransformMakeScale(fontChange + 1 - fontChange * fontChangeScale, fontChange + 1 - fontChange * fontChangeScale);
    } else {
       self.transform = CGAffineTransformMakeScale(1 + fontChange * fontChangeScale, 1 + fontChange * fontChangeScale);
    }
}

- (void)layoutSubviews {
    CGSize size = [self getTitleSize];
    
    self.titleLabel.frame = CGRectMake(self.leftImage ? CGRectGetMaxX(self.leftImageView.frame) + kTitleToImageSpace : 0, (CGRectGetHeight(self.frame) - size.height) / 2, size.width, size.height);
    
    if (self.leftImage) {
        self.leftImageView.frame = CGRectMake(0, (size.height - self.leftImage.size.height) / 2, self.leftImage.size.width, self.leftImage.size.height);
    }
    
    if (self.rightImage) {
        self.rightImageView.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + kTitleToImageSpace, (size.height - self.rightImage.size.height) / 2, self.rightImage.size.width, self.rightImage.size.height);
    }
}

- (CGSize)getTitleSize {
    UIFont *font = self.normalFont;
    CGSize size = [self.title boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    return size;
}

- (CGSize)getSize {
    CGSize size = [self getTitleSize];
    CGFloat maxWidth = size.width;
    
    if (self.leftImage) {
        maxWidth += (self.leftImage.size.width + kTitleToImageSpace);
    }
    if (self.rightImage) {
        maxWidth += (self.rightImage.size.width + kTitleToImageSpace);
    }
    
    size.width = maxWidth;
    
    return size;
}

- (CGFloat)getFontChangeScale {
    if (self.fontChange != 0) {
        return self.fontChange + 1;
    }
    CGFloat fontChange = (self.selectFont.pointSize - self.normalFont.pointSize) / self.normalFont.pointSize;
    self.fontChange = fontChange;
    return (fontChange + 1);
}

@end
