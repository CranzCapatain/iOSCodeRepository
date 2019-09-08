//
//  EPSegmentView.m
//  AlterDemo
//
//  Created by JinFeng on 2018/11/26.
//  Copyright © 2018年 Alter. All rights reserved.
//

#import "EPSegmentView.h"
#import "EPSegmentControl.h"

static const short kSlideItemTag = 100; // control的tag
static short kSlideMinItemSpace = 10;    // 默认items之间的最小距离 / 2
static const unsigned kIndicateHeight = 3; // 滑杆高度
static const unsigned kIndicateWidth = 10; // 滑杆默认宽度
static const unsigned kIndicateToControlMinHeight = 6;   // 滑杆到按钮的高度
static const unsigned kMinContentEdges = 16;    // 默认最小的左右内边距

@interface EPSegmentView ()
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIImageView *indicateView;
@property (nonatomic, strong) UIColor *indicateColor;
@property (nonatomic, assign) CGFloat indicateViewWidth; // 指示杆的宽度
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, assign) CGFloat realMinItemSpace; // |space[item]space,space[item]space|
@property (nonatomic, assign) CGFloat maxTitleHeight;  // 记录下最大的font的height
@property (nonatomic, strong) EPSegmentControl *selectedControl;
@property (nonatomic, assign) BOOL clickToScroll; // 点击滑动
@property (nonatomic, assign) BOOL adjustIndicateViewWidthToTitle;
@property (nonatomic, assign) BOOL addToNavigationTitleView;
@property (nonatomic, assign) BOOL isScrolling; // 正在进行滑动动画
@property (nonatomic, assign) BOOL isSetContentEdges;   // 是否设置了内边距
@property (nonatomic, assign) UIEdgeInsets contentInsets; // 内边距
@end

@implementation EPSegmentView

- (NSMutableArray *)itemViews {
    if (!_itemViews) {
        _itemViews = [NSMutableArray array];
    }
    return _itemViews;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupConfig];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupConfig];
    }
    return self;
}

- (void)setUpDelegateData {
    if (!self.delegate) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(isAdjustIndicateViewWidthToTitle)]) {
        _adjustIndicateViewWidthToTitle = [self.delegate isAdjustIndicateViewWidthToTitle];
    }
    if ([self.delegate respondsToSelector:@selector(indicateViewWidthIfNotAdjustToTitle)]) {
        _indicateViewWidth = [self.delegate indicateViewWidthIfNotAdjustToTitle];
    }
    if ([self.delegate respondsToSelector:@selector(minSpaceOfItems)]) {
        _realMinItemSpace = [self.delegate minSpaceOfItems] / 2;
        kSlideMinItemSpace = _realMinItemSpace;
    }
    if ([self.delegate respondsToSelector:@selector(contentEdgeInsets)]) {
        _contentInsets = [self.delegate contentEdgeInsets];
        _isSetContentEdges = YES;
    }
}

- (void)setupConfig {
    _selectedIndex = 0;
    _realMinItemSpace = kSlideMinItemSpace;
    _adjustIndicateViewWidthToTitle = NO;
    _addToNavigationTitleView = NO;
    _showBottomSingleLine = NO;
    _indicateViewWidth = kIndicateWidth;
    _isScrolling = NO;
    _openColorGraduallyChange = YES;
    _openFontGraduallyChange = YES;
    _isSetContentEdges = NO;
    _indicateLocationStyle = EPSegmentIndicateLocationStyleBottom;
    _contentInsets = UIEdgeInsetsMake(0, kMinContentEdges, 0, kMinContentEdges);
    
    [self setUpDelegateData];
    
    self.backgroundColor = [UIColor whiteColor];
    
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.bounces = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
    }
    if (!self.indicateView) {
        self.indicateView = [[UIImageView alloc] init];
        self.indicateView.layer.cornerRadius = kIndicateHeight * 0.5;
        self.indicateView.layer.masksToBounds = YES;
        self.indicateView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:self.indicateView];
    }
    
    if (!self.bottomLine) {
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = [UIColor lightGrayColor];
        self.bottomLine.hidden = !self.showBottomSingleLine;
        [self addSubview:self.bottomLine];
    }
    
    [self displayWithItems:self.items];
}

- (void)reset {
    if (self.itemViews.count == 0) {
        return;
    }
    [self.itemViews enumerateObjectsUsingBlock:^(EPSegmentControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.itemViews removeAllObjects];
}

- (void)displayWithItems:(NSArray<EPSegmentItem *> *)items {
    _items = items;
    
    if (items.count == 0) {
        return;
    }
    
    [self reset];
    
    UIFont *maxFont;
    for (NSUInteger i = 0; i < _items.count; ++i) {
        EPSegmentItem *item = _items[i];
        EPSegmentControl *control = [[EPSegmentControl alloc] init];
        control.title = item.title;
        control.normalFont = item.font;
        control.selectFont = item.seletFont;
        control.normalColor = item.normalColor;
        control.selectedColor = item.selectedColor;
        control.rightImage = item.rightImage;
        control.leftImage = item.leftImage;
        control.selected = NO;
        control.tag = i + kSlideItemTag;
        [self.scrollView addSubview:control];
        [self.itemViews addObject:control];
        [control addTarget:self action:@selector(actionForControlClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (item.font.pointSize > maxFont.pointSize) {
            maxFont = item.font;
        }
    }
    
    self.maxTitleHeight = [self getHeightWithFont:maxFont];
    
    [self updateRealItemSpace];
}

- (CGFloat)getAllItemsWidth {
    CGFloat totalWidth = 0;
    for (EPSegmentControl *control in self.itemViews) {
        totalWidth += [control getSize].width;
    }
    return totalWidth;
}

- (void)updateRealItemSpace {
    if (self.itemViews.count == 0) return;
    CGFloat totalWidth = [self getAllItemsWidth];
    if (self.addToNavigationTitleView) {
        CGFloat edges = (CGRectGetWidth(self.frame) - totalWidth - (self.items.count - 1) * 2 * _realMinItemSpace) / 2;
        if (edges < 0) {
            edges = 0;
        }
        self.contentInsets = UIEdgeInsetsMake(0, edges, 0, edges);
        return;
    }
    // 根据当前的item计算出需要展示的目标item之间的space
    if (self.isSetContentEdges) { // 如果设置了内边距，那么此时内边距是固定的
        CGFloat needChangeToSpace = (CGRectGetWidth(self.frame) - totalWidth - self.contentInsets.left - self.contentInsets.right) / ((self.items.count - 1) * 2);
        if (needChangeToSpace < kSlideMinItemSpace) {
            _realMinItemSpace = kSlideMinItemSpace;
        } else {
            _realMinItemSpace = needChangeToSpace;
        }
    } else {
        CGFloat needChangeEdges = (CGRectGetWidth(self.frame) - totalWidth - (self.items.count - 1) * 2 * _realMinItemSpace) / 2;
        if (needChangeEdges < kMinContentEdges) {
            _contentInsets = UIEdgeInsetsMake(0, kMinContentEdges, 0, kMinContentEdges);
        } else {
            _contentInsets = UIEdgeInsetsMake(0, needChangeEdges, 0, needChangeEdges);
        }
    }
}

- (void)reloadData {
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [self setUpDelegateData];
    [self updateRealItemSpace];
    [self updateLayouts];
}

- (void)updateLayouts {
    if (self.itemViews.count == 0) return;
    CGFloat currentX = 0;
    currentX = self.contentInsets.left;
    CGFloat setHeight = CGRectGetHeight(self.frame);
    CGFloat segmentHeight = self.maxTitleHeight + kIndicateToControlMinHeight + kIndicateHeight;
    if (setHeight != 0 && (segmentHeight < setHeight)) {
        segmentHeight = setHeight;
    }
    BOOL addToNavigation = self.addToNavigationTitleView;
    for (EPSegmentControl *control in self.itemViews) {
        CGSize size = CGSizeMake([control getSize].width, self.maxTitleHeight);
        NSUInteger index = control.tag - kSlideItemTag;
        CGFloat y = 0;
        if (!addToNavigation) {
            y = (segmentHeight - size.height) / 2;
        }
        control.frame = CGRectMake(currentX, y, size.width, size.height);
        control.originRect = control.frame;
        if (index == self.itemViews.count - 1) {
            if (self.addToNavigationTitleView) {
                currentX = currentX + size.width;
            } else {
                currentX = currentX + size.width + self.contentInsets.right;
            }
        } else {
            currentX = currentX + self.realMinItemSpace * 2 + size.width;
        }
    }
    self.scrollView.contentSize = CGSizeMake(currentX, segmentHeight);
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        self.scrollView.frame = CGRectMake(0, 0, currentX > [UIScreen mainScreen].bounds.size.width ? [UIScreen mainScreen].bounds.size.width : currentX, segmentHeight);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
    else {
        self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height < segmentHeight ? segmentHeight : self.bounds.size.height);
    }
    
    self.bottomLine.frame = CGRectMake(0, segmentHeight - 0.5, self.bounds.size.width, 0.5);
    
    [self slideIndicateToSelectedIndex];
    EPSegmentControl *selectedControl = self.itemViews[self.selectedIndex];
    self.selectedControl = selectedControl;
    self.selectedControl.selected = YES;
}

- (CGFloat)getHeightWithFont:(UIFont *)font {
    CGSize size = [@"" boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    return size.height;
}

// 当items出现增减时，需要重新设置它的tag值
- (void)resetItemViewTag {
    NSUInteger maxCount = self.itemViews.count;
    for (int i = 0; i < maxCount; ++i) {
        EPSegmentControl *control = self.itemViews[i];
        control.tag = i + kSlideItemTag;
    }
}

- (void)setSelectedAtIndex:(NSUInteger)index animate:(BOOL)animate {
    if (index == self.selectedIndex) return;
    if (index >= self.itemViews.count) return;
    if (self.isScrolling) {
        return;
    }
    EPSegmentControl *control = self.itemViews[index];
    self.selectedIndex = index;
    [UIView animateWithDuration:animate ? 0.3 : 0 animations:^{
        self.isScrolling = YES;
        [self slideIndicateToSelectedIndex];
    } completion:^(BOOL finished) {
        self.isScrolling = NO;
        self.selectedControl.selected = NO;
        control.selected = YES;
        self.selectedControl = control;
        [self adjustPositionToSegementView];
    }];
}

- (void)slideIndicateToSelectedIndex {
    if (self.itemViews.count == 0) return;
    EPSegmentControl *selectedControl = self.itemViews[self.selectedIndex];
    CGSize titleSize = [selectedControl getTitleSize];
    CGFloat indicateX = self.adjustIndicateViewWidthToTitle ? CGRectGetMinX(selectedControl.frame) + (selectedControl.leftImage ? selectedControl.leftImage.size.width : 0) : CGRectGetMinX(selectedControl.frame) + (titleSize.width - self.indicateViewWidth) / 2;
    CGFloat indicateWidth = self.adjustIndicateViewWidthToTitle ? titleSize.width : self.indicateViewWidth;
    CGRect rect = CGRectZero;
    CGFloat y = 0;
    if (self.addToNavigationTitleView) {
        y = self.indicateLocationStyle == EPSegmentIndicateLocationStyleDefault ? CGRectGetMaxY(selectedControl.originRect) + kIndicateToControlMinHeight : CGRectGetHeight(self.frame) - kIndicateHeight - 0.5;
        if (y + kIndicateHeight > CGRectGetHeight(self.frame)) {
            y = CGRectGetHeight(self.frame) - kIndicateHeight - 0.5;
        }
    } else {
        y = self.indicateLocationStyle == EPSegmentIndicateLocationStyleDefault ? CGRectGetMaxY(selectedControl.originRect) + kIndicateToControlMinHeight : CGRectGetHeight(self.frame) - kIndicateHeight - 0.5;
    }
    rect = CGRectMake(indicateX, y, indicateWidth, kIndicateHeight);
    self.indicateView.frame = rect;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.scrollView.bounces = bounces;
}

- (void)setAddToNavigationItemView:(BOOL)addToNavigationItemView {
    _addToNavigationItemView = addToNavigationItemView;
    self.addToNavigationTitleView = addToNavigationItemView;
}

- (void)setShowBottomSingleLine:(BOOL)showBottomSingleLine {
    _showBottomSingleLine = showBottomSingleLine;
    self.bottomLine.hidden = !showBottomSingleLine;
}

#pragma mark - 调整选中item的显示位置

- (void)adjustPositionToSegementView {
    CGFloat selectedWidth = [self.selectedControl getSize].width;
    CGFloat segemntWidth = CGRectGetWidth(self.frame);
    CGFloat offsetX = (segemntWidth - selectedWidth) / 2;
    
    if (CGRectGetMinX(self.selectedControl.originRect) <= segemntWidth / 2) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (CGRectGetMaxX(self.selectedControl.originRect) >= (self.scrollView.contentSize.width - segemntWidth / 2)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width - segemntWidth, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(CGRectGetMinX(self.selectedControl.originRect) - offsetX, 0) animated:YES];
    }
}

#pragma mark - 指示杆滑动

- (void)scrollIndicateViewWithOffset:(CGFloat)offsetX relativeWidth:(CGFloat)relativeWidth {
    [self p_scrollIndicateViewWithOffset:offsetX relativeWidth:relativeWidth];
}

- (void)p_scrollIndicateViewWithOffset:(CGFloat)offsetX relativeWidth:(CGFloat)relativeWidth {
    if (self.clickToScroll || relativeWidth == 0) {
        return;
    }
    NSInteger currentIndex = self.selectedIndex; // 当前的index
    
    // 当当前的偏移量大于被选中index的偏移量的时候，就是在右侧
    BOOL direction = offsetX < self.selectedIndex * relativeWidth;
    CGFloat moved = 0; // 相对偏移量
    NSInteger targetIndex = currentIndex; // 将要前往的index
    if (direction) { // 左移
        moved = offsetX - currentIndex * relativeWidth;
        targetIndex -= 1;
        if (targetIndex < 0) {
            targetIndex = 0;
            currentIndex = 0;
        }
    } else { // 右移
        moved = offsetX - currentIndex * relativeWidth;
        targetIndex += 1;
        if (targetIndex >= self.itemViews.count) {
            targetIndex = self.itemViews.count - 1;
        }
    }
    if (ABS(moved) >= relativeWidth) {
        self.selectedIndex = targetIndex;
        self.selectedControl.selected = NO;
        EPSegmentControl *selectedControl = self.itemViews[self.selectedIndex];
        self.selectedControl = selectedControl;
        self.selectedControl.selected = YES;
        [self adjustPositionToSegementView];
    }
    
    CGFloat originMovedX = 0;   // 原始x
    CGFloat targetMovedWidth = 0; // 需要移动的长度
    CGFloat targetButtonWidth = 0; // 目标宽度
    CGFloat originButtonWidth = 0; // 原始宽度
    if (self.adjustIndicateViewWidthToTitle) {
        EPSegmentControl *originControl = self.itemViews[currentIndex];
        EPSegmentControl *targetControl = self.itemViews[targetIndex];
        originMovedX = CGRectGetMinX([originControl frame]);
        targetMovedWidth = CGRectGetWidth([originControl frame]) + self.realMinItemSpace * 2;//需要移动的距离
        targetButtonWidth = CGRectGetWidth([targetControl originRect]) * targetControl.getFontChangeScale;
        originButtonWidth = CGRectGetWidth([originControl frame]);
    } else {
        EPSegmentControl *originControl = self.itemViews[currentIndex];
        EPSegmentControl *targetControl = self.itemViews[targetIndex];
        originMovedX = CGRectGetMinX([originControl originRect]) + (CGRectGetWidth([originControl originRect]) - self.indicateViewWidth) / 2;
        targetMovedWidth = (CGRectGetWidth([originControl originRect]) + self.indicateViewWidth) / 2 + self.realMinItemSpace * 2 + (CGRectGetWidth([targetControl originRect]) - self.indicateViewWidth) / 2;//需要移动的距离
        targetButtonWidth = self.indicateViewWidth;
        originButtonWidth = self.indicateViewWidth;
    }
    
    self.indicateView.frame = CGRectMake(originMovedX + targetMovedWidth / relativeWidth * moved, _indicateView.frame.origin.y,  originButtonWidth + (targetButtonWidth - originButtonWidth) / relativeWidth * moved, _indicateView.frame.size.height);
    
    // 滑动的细节实现
    CGFloat changeScale = ABS(moved / relativeWidth);
    if (changeScale == 1.0) changeScale = 0;
    
    if (self.openColorGraduallyChange) {
        EPSegmentControl *originControl = self.itemViews[currentIndex];
        EPSegmentControl *targetControl = self.itemViews[targetIndex];
        originControl.colorChangeScale = changeScale;
        targetControl.colorChangeScale = changeScale;
    }
    if (self.openFontGraduallyChange) {
        EPSegmentControl *originControl = self.itemViews[currentIndex];
        EPSegmentControl *targetControl = self.itemViews[targetIndex];
        originControl.fontChangeScale = changeScale;
        targetControl.fontChangeScale = changeScale;
    }
}

#pragma mark - item点击

- (void)actionForControlClick:(EPSegmentControl *)control {
    NSUInteger index = control.tag - kSlideItemTag;
    self.clickToScroll = YES;
    [self setSelectedAtIndex:index animate:YES];
    self.clickToScroll = NO;
    
    if ([self.delegate respondsToSelector:@selector(segmentView:didSelectedWithItem:atIndex:)]) {
        [self.delegate segmentView:self didSelectedWithItem:self.items[index] atIndex:index];
    }
}

@end
