//
//  YZDisplayViewController.m
//  BuDeJie
//
//  Created by yz on 15/12/1.
//  Copyright © 2015年 yz. All rights reserved.
//

#import "YZDisplayViewController.h"
#import "YZDisplayTitleLabel.h"
#import "YZDisplayViewHeader.h"
#import "UIViewExt.h"
#import "YZFlowLayout.h"

static NSString * const ID = @"CONTENTCELL";

@interface YZDisplayViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UIColor *_norColor;
    UIColor *_selColor;
}
/**
 *  下标宽度是否等于标题宽度
 */
@property (nonatomic, assign) BOOL isUnderLineEqualTitleWidth;
/**
 标题滚动视图背景颜色
 */
@property (nonatomic, strong) UIColor *titleScrollViewColor;


/**
 标题高度
 */
@property (nonatomic, assign) CGFloat titleHeight;

/**
 标题宽度
 */
@property (nonatomic, assign) CGFloat titleWidth;


/**
 正常标题颜色
 */
@property (nonatomic, strong) UIColor *norColor;

/**
 选中标题颜色
 */
@property (nonatomic, strong) UIColor *selColor;

/**
 标题字体
 */
@property (nonatomic, strong) UIFont *titleFont;

/** 选中标题字体 */
@property(nonatomic, strong) UIFont *selTitleFont;

/** 整体内容View 包含标题好内容滚动视图 */
@property (nonatomic, weak) UIView *contentView;

/** 所以标题数组 */
@property (nonatomic, strong) NSMutableArray *titleLabels;

/** 所以标题宽度数组 */
@property (nonatomic, strong) NSMutableArray *titleWidths;

/** 下标视图 */
@property (nonatomic, weak) UIView *underLine;

/** 下标的图片名 */
@property(nonatomic, copy) NSString *underLineImageName;

/**
 是否需要下标
 */
@property (nonatomic, assign) BOOL isShowUnderLine;
/**
 字体是否渐变
 */
@property (nonatomic, assign) BOOL isShowTitleGradient;

/**
 是否显示遮盖
 */
@property (nonatomic, assign) BOOL isShowTitleCover;

/** 标题遮盖视图 */
@property (nonatomic, weak) UIView *coverView;

/** 记录上一次内容滚动视图偏移量 */
@property (nonatomic, assign) CGFloat lastOffsetX;

/** 记录是否点击 */
@property (nonatomic, assign) BOOL isClickTitle;

/** 记录是否在动画 */
@property (nonatomic, assign) BOOL isAniming;

/* 是否初始化 */
@property (nonatomic, assign) BOOL isInitial;

///** 标题间距 */
//@property (nonatomic, assign) CGFloat titleMargin;

/**
 颜色渐变样式
 */
@property (nonatomic, assign) YZTitleColorGradientStyle titleColorGradientStyle;

/**
 字体缩放比例
 */
@property (nonatomic, assign) CGFloat titleScale;
/**
 是否延迟滚动下标
 */
@property (nonatomic, assign) BOOL isDelayScroll;
/**
 遮盖颜色
 */
@property (nonatomic, strong) UIColor *coverColor;

/**
 遮盖圆角半径
 */
@property (nonatomic, assign) CGFloat coverCornerRadius;

/**
 下标颜色
 */
@property (nonatomic, strong) UIColor *underLineColor;

/**
 下标高度
 */
@property (nonatomic, assign) CGFloat underLineH;

/**
 下标宽度
 */
@property(nonatomic, assign) CGFloat underLineW;


/**
 开始颜色,取值范围0~1
 */
@property (nonatomic, assign) CGFloat startR;

@property (nonatomic, assign) CGFloat startG;

@property (nonatomic, assign) CGFloat startB;

/**
 完成颜色,取值范围0~1
 */
@property (nonatomic, assign) CGFloat endR;

@property (nonatomic, assign) CGFloat endG;

@property (nonatomic, assign) CGFloat endB;

@property (nonatomic, assign) BOOL isScrollLeft;

@property (nonatomic, assign) CGFloat startOffset;

@end

@implementation YZDisplayViewController

#pragma mark - 初始化方法
- (instancetype)init
{
    if (self = [super init]) {
        [self initial];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initial];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self contentView];
    [self titleScrollView];
}

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initial
{
    //    // 初始化标题高度
    //    _titleHeight = __MainScreen_Status_Height + __MainScreen_NavigationBar_Height + Safe_Top_Space;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - 懒加载

- (UIFont *)titleFont
{
    if (_titleFont == nil) {
        _titleFont = YZTitleFont;
    }
    return _titleFont;
}

- (UIFont *)selTitleFont
{
    if (_selTitleFont == nil) {
        _selTitleFont = YZTitleFont;
    }
    return _selTitleFont;
}


- (NSMutableArray *)titleWidths
{
    if (_titleWidths == nil) {
        _titleWidths = [NSMutableArray array];
    }
    return _titleWidths;
}

- (UIColor *)norColor
{
    if (_norColor == nil) self.norColor = [UIColor blackColor];
    
    return _norColor;
}

- (UIColor *)selColor
{
    if (_selColor == nil) self.selColor = [UIColor redColor];
    
    return _selColor;
}

- (UIView *)coverView
{
    if (_coverView == nil) {
        UIView *coverView = [[UIView alloc] init];
        
        coverView.backgroundColor = _coverColor?_coverColor:[UIColor lightGrayColor];
        
        coverView.layer.cornerRadius = _coverCornerRadius;
        
        [self.titleScrollView insertSubview:coverView atIndex:0];
        
        _coverView = coverView;
    }
    return _isShowTitleCover?_coverView:nil;
}

- (UIView *)underLine
{
    if (_underLine == nil) {
        
        UIView *underLineView = [[UIView alloc] init];
        
        underLineView.backgroundColor = _underLineColor?_underLineColor:[UIColor redColor];
        underLineView.layer.cornerRadius = 1;
        
        [self.titleScrollView addSubview:underLineView];
        
        _underLine = underLineView;
        
        if (_underLineImageName.length > 0) {
            underLineView.layer.contents = (__bridge id)([UIImage imageNamed:_underLineImageName].CGImage);
            underLineView.layer.contentsGravity = kCAGravityResizeAspect;
            underLineView.backgroundColor = [UIColor clearColor];
        }
    }
    return _isShowUnderLine?_underLine : nil;
}

- (NSMutableArray *)titleLabels
{
    if (_titleLabels == nil) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}


// 懒加载标题滚动视图
- (UIScrollView *)titleScrollView
{
    if (_titleScrollView == nil) {
        
        UIScrollView *titleScrollView = [[UIScrollView alloc] init];
        titleScrollView.scrollsToTop = NO;
        titleScrollView.backgroundColor = _titleScrollViewColor?_titleScrollViewColor:RGBWhite;
        
        [self.contentView addSubview:titleScrollView];
        
        _titleScrollView = titleScrollView;
        
    }
    return _titleScrollView;
}

// 懒加载内容滚动视图
- (UIScrollView *)contentScrollView2
{
    if (_contentScrollView2 == nil) {
        
        // 创建布局
        YZFlowLayout *layout = [[YZFlowLayout alloc] init];
        
        UXSwipeCollectionView *contentScrollView = [[UXSwipeCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentScrollView2 = contentScrollView;
        // 设置内容滚动视图
        _contentScrollView2.pagingEnabled = YES;
        _contentScrollView2.showsHorizontalScrollIndicator = NO;
        _contentScrollView2.bounces = NO;
        _contentScrollView2.delegate = self;
        _contentScrollView2.dataSource = self;
        _contentScrollView2.scrollsToTop = NO;
        // 注册cell
        [_contentScrollView2 registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ID];
        
        _contentScrollView2.backgroundColor = self.view.backgroundColor;
        [self.contentView insertSubview:contentScrollView belowSubview:self.titleScrollView];
        
    }
    return _contentScrollView2;
}

// 懒加载整个内容view
- (UIView *)contentView
{
    if (_contentView == nil) {
        
        UIView *contentView = [[UIView alloc] init];
        _contentView = contentView;
        [self.view addSubview:contentView];
        
    }
    
    return _contentView;
}

#pragma mark - 属性setter方法

- (void)setIsShowUnderLine:(BOOL)isShowUnderLine
{
    _isShowUnderLine = isShowUnderLine;
}

- (void)setTitleScrollViewColor:(UIColor *)titleScrollViewColor
{
    _titleScrollViewColor = titleScrollViewColor;
    
    self.titleScrollView.backgroundColor = titleScrollViewColor;
}

- (void)setIsfullScreen:(BOOL)isfullScreen
{
    _isfullScreen = isfullScreen;
    
    self.contentView.frame = CGRectMake(0, 0, YZScreenW, YZScreenH);
    
}

// 设置整体内容的尺寸
- (void)setUpContentViewFrame:(void (^)(UIView *))contentBlock
{
    if (contentBlock) {
        contentBlock(self.contentView);
    }
}

// 一次性设置所有颜色渐变属性
- (void)setUpTitleGradient:(void(^)(YZTitleColorGradientStyle *titleColorGradientStyle,UIColor **norColor,UIColor **selColor))titleGradientBlock;
{
    _isShowTitleGradient = YES;
    UIColor *norColor;
    UIColor *selColor;
    if (titleGradientBlock) {
        titleGradientBlock(&_titleColorGradientStyle,&norColor,&selColor);
        if (norColor) {
            self.norColor = norColor;
        }
        if (selColor) {
            self.selColor = selColor;
        }
    }
    
    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill && _titleWidth > 0) {
        @throw [NSException exceptionWithName:@"YZ_ERROR" reason:@"标题颜色填充不需要设置标题宽度" userInfo:nil];
    }
}

// 一次性设置所有遮盖属性
- (void)setUpCoverEffect:(void (^)(UIColor **, CGFloat *))coverEffectBlock
{
    UIColor *color;
    
    _isShowTitleCover = YES;
    
    if (coverEffectBlock) {
        
        coverEffectBlock(&color,&_coverCornerRadius);
        
        if (color) {
            _coverColor = color;
        }
        
    }
}

// 一次性设置所有下标属性
- (void)setUpUnderLineEffect:(void(^)(BOOL *isUnderLineDelayScroll,CGFloat *underLineH,UIColor **underLineColor,BOOL *isUnderLineEqualTitleWidth,CGFloat *underLineW))underLineBlock
{
    _isShowUnderLine = YES;
    _isDelayScroll = NO;//是否延迟滚动下标，就是是否需要动画效果
    _isUnderLineEqualTitleWidth = YES;//默认等于标题的宽度 如果设为NO并且设置underLineW，则以underLineW为准
    
    UIColor *underLineColor;
    
    if (underLineBlock) {
        underLineBlock(&_isDelayScroll,&_underLineH,&underLineColor,&_isUnderLineEqualTitleWidth,&_underLineW);
        
        if (underLineColor) {
            _underLineColor = underLineColor;
        }
    }
}

// 一次性设置所有标题属性
- (void)setUpTitleEffect:(void(^)(UIColor **titleScrollViewColor,UIColor **norColor,UIColor **selColor,UIFont **titleFont,UIFont **selTitleFont,CGFloat *titleHeight,CGFloat *titleWidth))titleEffectBlock{
    // 初始化标题高度
    _titleHeight = 64 + Safe_Top_Space;
    
    UIColor *titleScrollViewColor;
    UIColor *norColor;
    UIColor *selColor;
    UIFont *titleFont;
    UIFont *selTitleFont;
    if (titleEffectBlock) {
    titleEffectBlock(&titleScrollViewColor,&norColor,&selColor,&titleFont,&selTitleFont,&_titleHeight,&_titleWidth);
        if (norColor) {
            self.norColor = norColor;
        }
        if (selColor) {
            self.selColor = selColor;
        }
        if (titleScrollViewColor) {
            self.titleScrollViewColor = titleScrollViewColor;
        }
        _titleFont = titleFont;
        if (selTitleFont) {
            _selTitleFont = selTitleFont;
        }else
        {
            _selTitleFont = titleFont;
        }
    }
    
    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill && _titleWidth > 0) {
        @throw [NSException exceptionWithName:@"YZ_ERROR" reason:@"标题颜色填充不需要设置标题宽度" userInfo:nil];
    }
}

- (void)setUpCustomUnderLineImage:(NSString *)imageName size:(CGSize)size
{
    _underLineImageName = imageName;
    _underLineH = size.height;
    _underLineW = size.width;
}

#pragma mark - 控制器view生命周期方法
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_isInitial == NO) {
        self.selectIndex = self.selectIndex;
        
        _isInitial = YES;
        
        CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        CGFloat titleY = self.navigationController.navigationBarHidden == NO ?YZNavBarH:statusH;
        
        UIButton *backButton = nil;
        if (self.navigationController.viewControllers.firstObject != self) {//tb_all_return_n
            //tb_all_return_dark_n
            UIImage *backImage = [[UIImage imageNamed:@"home_all_back_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIImage *highlightBackImage = [[UIImage imageNamed:@"home_all_back_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            backButton = [UIButton buttonWithType:UIButtonTypeSystem];
            backButton.frame = CGRectMake(-3, 20 + Safe_Top_Space, 44, 44);
            if (self.titleViewsHorizonCenter) {
                backButton.frame = CGRectMake(-3, 0, 44, self.titleHeight);
            }
            [backButton setImage:backImage forState:UIControlStateNormal];
            [backButton setImage:highlightBackImage forState:UIControlStateHighlighted];
            backButton.adjustsImageWhenHighlighted = NO;
            if ([self respondsToSelector:@selector(backAction)]) {
                [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            }
            if (self.showBackButton) {
                [self.titleScrollView addSubview:backButton];
            }
        }
        // 是否占据全屏
        if (_isfullScreen) {
            if (backButton) {
                UIImage *backImage = [[UIImage imageNamed:@"home_all_back_bai_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                UIImage *highlightBackImage = [[UIImage imageNamed:@"home_all_back_bai_pre"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                [backButton setImage:backImage forState:UIControlStateNormal];
                [backButton setImage:highlightBackImage forState:UIControlStateHighlighted];
            }
            // 整体contentView尺寸
            self.contentView.frame = CGRectMake(0, 0, YZScreenW, YZScreenH);
            
            // 顶部标题View尺寸
            self.titleScrollView.frame = CGRectMake(0, titleY, YZScreenW, self.titleHeight);
            
            // 顶部内容View尺寸
            self.contentScrollView2.frame = self.contentView.bounds;
            
            return;
        }
        
        if (self.contentView.frame.size.height == 0) {
            self.contentView.frame = CGRectMake(0, titleY, YZScreenW, YZScreenH - titleY);
        }
        
        // 顶部标题View尺寸
        self.titleScrollView.frame = CGRectMake(0, 0, YZScreenW, self.titleHeight);
        
        // 顶部内容View尺寸
        CGFloat contentY = CGRectGetMaxY(self.titleScrollView.frame);
        CGFloat contentH = self.contentView.uxheight - contentY;
        self.contentScrollView2.frame = CGRectMake(0, contentY, YZScreenW, contentH);
    }
}

- (void)backAction {
    //由子类实现
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isInitial == NO) {
        
        [self refreshDisplay];
    }
}

#pragma mark - 添加标题方法
// 计算所有标题宽度
//- (void)setUpTitleWidth
//{
//    // 判断是否能占据整个屏幕
//    NSUInteger count = self.childViewControllers.count;
//
//    NSArray *titles = [self.childViewControllers valueForKeyPath:@"title"];
//
//    CGFloat totalWidth = 0;
//
//    // 计算所有标题的宽度
//    for (NSString *title in titles) {
//
//        if ([title isKindOfClass:[NSNull class]]) {
//            // 抛异常
//            NSException *excp = [NSException exceptionWithName:@"YZDisplayViewControllerException" reason:@"没有设置Controller.title属性，应该把子标题保存到对应子控制器中" userInfo:nil];
//            [excp raise];
//
//        }
//
//        CGRect titleBounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
//
//        CGFloat width = titleBounds.size.width;
//
//        [self.titleWidths addObject:@(width)];
//
//        totalWidth += width;
//    }
//
//    if (totalWidth > YZScreenW) {
//
//        _titleMargin = margin;
//
//        self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
//
//        return;
//    }
//
//    CGFloat titleMargin = (YZScreenW - totalWidth) / (count + 1);
//
//    _titleMargin = titleMargin < margin? margin: titleMargin;
//
//    self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
//}


// 设置所有标题
- (void)setUpAllTitle
{
    // 遍历所有的子控制器
    NSUInteger count = self.childViewControllers.count;
    
    // 添加所有的标题
    CGFloat labelW = _titleWidth;
    CGFloat labelH = self.titleHeight;
    CGFloat labelX = __MainScreen_Width/self.titleLabels.count;
    CGFloat labelY = 10;
    if (IS_Bangs_Screen) {
        labelY = 22;
    }
    
    if (self.titleViewsHorizonCenter) {
        labelY = 0;
    }
    
    for (int i = 0; i < count; i++) {
        
        UIViewController *vc = self.childViewControllers[i];
        
        UILabel *label = [[YZDisplayTitleLabel alloc] init];
        
        label.tag = i;
        
        // 设置按钮的文字颜色
        label.textColor = self.norColor;
        
        label.font = self.titleFont;
        
        // 设置按钮标题
        label.text = vc.title;
        
        if (_titleColorGradientStyle == YZTitleColorGradientStyleFill || _titleWidth == 0) { // 填充样式才需要
            labelW = [self.titleWidths[i] floatValue];
            
            // 设置按钮位置
            UILabel *lastLabel = [self.titleLabels lastObject];
            
            labelX = _titleMargin + CGRectGetMaxX(lastLabel.frame);
        } else {
            
            labelX = i * labelW;
        }
        CGFloat width = 40;
        if (self.customLabelWidth) {
            width = labelW;
        }
        CGFloat x = (__MainScreen_Width - (width * count) - (self.titleMargin * (count - 1)))/2;
        if (self.leftLayoutMargin != 0) {
            x = self.leftLayoutMargin;
        }
        label.frame = CGRectMake(x  + width * i + self.titleMargin * i, labelY, width, labelH);
        
        
        // 监听标题的点击
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        
        // 保存到数组
        [self.titleLabels addObject:label];
        
        [self.titleScrollView addSubview:label];
        
        if (i == _selectIndex) {
            [self titleClick:tap];
        }
        
        UIView *numberView = [[UIView alloc] init];
        numberView.backgroundColor = RGBHex(@"FC4F4F");
        numberView.layer.cornerRadius = 7.5;
        numberView.tag = 1000 + i;
        numberView.hidden = YES;
        [label addSubview:numberView];
        [numberView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(22+(IS_Bangs_Screen ? 10:0));
            make.left.equalTo(label.right).offset(-1);
            make.width.greaterThanOrEqualTo(15);
            make.height.equalTo(15);
        }];
        
        UILabel *numberLabel = [[UILabel alloc] init];
        numberLabel.textColor = RGBWhite;
        numberLabel.font = ErWoFont(10);
        numberLabel.tag = 2000 + i;
        [numberView addSubview:numberLabel];
        [numberLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(0);
            make.centerY.equalTo(0);
        }];
        
        UIView *redDotView = [[UIView alloc] init];
        redDotView.backgroundColor = RGBHex(@"FC4F4F");
        redDotView.layer.cornerRadius = 4;
        redDotView.tag = 3000 + i;
        redDotView.hidden = YES;
        [label addSubview:redDotView];
        [redDotView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(22+(IS_Bangs_Screen ? 10:0));
            make.left.equalTo(label.right).offset(-5);
            make.width.height.equalTo(8);
        }];
    }
    
    // 设置标题滚动视图的内容范围
    UILabel *lastLabel = self.titleLabels.lastObject;
    _titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame), 0);
    _titleScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView2.contentSize = CGSizeMake(count * YZScreenW, 0);
    
}

#pragma mark - 标题效果渐变方法
// 设置标题颜色渐变
- (void)setUpTitleColorGradientWithOffset:(CGFloat)offsetX rightLabel:(YZDisplayTitleLabel *)rightLabel leftLabel:(YZDisplayTitleLabel *)leftLabel
{
    if (_isShowTitleGradient == NO) return;
    
    // 获取右边缩放
    CGFloat rightSacle = offsetX / YZScreenW - leftLabel.tag;
    
    // 获取左边缩放比例
    CGFloat leftScale = 1 - rightSacle;
    
    // RGB渐变
    if (_titleColorGradientStyle == YZTitleColorGradientStyleRGB) {
        
        CGFloat r = _endR - _startR;
        CGFloat g = _endG - _startG;
        CGFloat b = _endB - _startB;
        
        // rightColor
        // 1 0 0
        UIColor *rightColor = [UIColor colorWithRed:_startR + r * rightSacle green:_startG + g * rightSacle blue:_startB + b * rightSacle alpha:1];
        
        // 0.3 0 0
        // 1 -> 0.3
        // leftColor
        UIColor *leftColor = [UIColor colorWithRed:_startR +  r * leftScale  green:_startG +  g * leftScale  blue:_startB +  b * leftScale alpha:1];
        
        // 右边颜色
        rightLabel.textColor = rightColor;
        
        // 左边颜色
        leftLabel.textColor = leftColor;
        return;
    }
    
    // 填充渐变
    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill) {
        
        // 获取移动距离
        CGFloat offsetDelta = offsetX - _lastOffsetX;
        
        if (offsetDelta > 0) { // 往右边
            rightLabel.textColor = self.norColor;
            rightLabel.fillColor = self.selColor;
            rightLabel.progress = rightSacle;
            
            leftLabel.textColor = self.selColor;
            leftLabel.fillColor = self.norColor;
            leftLabel.progress = rightSacle;
            
        } else if(offsetDelta < 0){ // 往左边
            
            rightLabel.textColor = self.norColor;
            rightLabel.fillColor = self.selColor;
            rightLabel.progress = rightSacle;
            
            leftLabel.textColor = self.selColor;
            leftLabel.fillColor = self.norColor;
            leftLabel.progress = rightSacle;
            
        }
    }
}

// 标题缩放
- (void)setUpTitleScaleWithOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    // 获取右边缩放
    CGFloat rightSacle = offsetX / YZScreenW - leftLabel.tag;
    
    CGFloat leftScale = 1 - rightSacle;
    
    CGFloat titleFont = self.titleFont.pointSize;
    CGFloat selTitleFont = self.selTitleFont.pointSize;

    CGFloat font = 0;
    if (titleFont != selTitleFont)
    {
        font = selTitleFont - titleFont;
        leftLabel.font =  [self.titleFont fontWithSize:(titleFont + leftScale * font)];
        rightLabel.font = [self.titleFont fontWithSize:(titleFont + rightSacle *font)];
    }else
    {
        return;
    }
}

// 获取两个标题按钮宽度差值
- (CGFloat)widthDeltaWithRightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    CGRect titleBoundsR = [rightLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGRect titleBoundsL = [leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    return titleBoundsR.size.width - titleBoundsL.size.width;
}

// 设置下标偏移
- (void)setUpUnderLineOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel
{
    if (_isClickTitle) return;
    
    //左边label对应line的宽度
    CGFloat leftLabelUnderLineW = 0;
    CGRect titleBounds = [leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    if (_isUnderLineEqualTitleWidth) {
        leftLabelUnderLineW = titleBounds.size.width;
    } else {
        leftLabelUnderLineW = _underLineW > 0?_underLineW:leftLabel.uxwidth;
    }
    
    //右边label对应line的宽度
    CGFloat rightLabelUnderLineW = 0;
    CGRect rightTitleBounds = [rightLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    if (_isUnderLineEqualTitleWidth) {
        rightLabelUnderLineW = rightTitleBounds.size.width;
    } else {
        rightLabelUnderLineW = _underLineW > 0?_underLineW:rightLabel.uxwidth;
    }
    
    // 获取两个标题之间距离
    CGFloat centerDelta = (rightLabel.uxcenterX - leftLabel.uxcenterX) - rightLabelUnderLineW/2.0 - leftLabelUnderLineW/2.0;
    
    int tem = round(offsetX);
    int result = abs(tem%((int)__MainScreen_Width));
    if (result) {
        if (_isScrollLeft) {
            //左滑
            if (result <= YZScreenW/2) {
                self.underLine.uxwidth =  fabs(result/YZScreenW) * 2 * (centerDelta + rightLabelUnderLineW) + leftLabelUnderLineW;
            } else {
                self.underLine.uxwidth = (1-fabs(result/YZScreenW))*2*(centerDelta + leftLabelUnderLineW) + rightLabelUnderLineW;
                // 右边角标
                NSInteger rightIndex = self.currentIndex + 1;
                // 右边按钮
                YZDisplayTitleLabel *temLabel = nil;
                if (rightIndex < self.titleLabels.count) {
                    temLabel = self.titleLabels[rightIndex];
                }
                self.underLine.uxright = temLabel.uxcenterX + rightLabelUnderLineW/2.0;
            }
        } else {
            if (abs(tem%((int)__MainScreen_Width)) >= YZScreenW/2) {
                self.underLine.uxwidth = (1 - fabs(result/YZScreenW))*2*(centerDelta + leftLabelUnderLineW) + rightLabelUnderLineW;
                NSInteger rightIndex = self.currentIndex;
                // 右边按钮
                YZDisplayTitleLabel *temLabel = nil;
                temLabel = self.titleLabels[rightIndex];
                self.underLine.uxright = temLabel.uxcenterX + rightLabelUnderLineW/2.0;
                
            } else {
                
                self.underLine.uxwidth = fabs(result/YZScreenW) * 2 * (centerDelta + leftLabelUnderLineW) + rightLabelUnderLineW;
                // 右边角标
                NSInteger rightIndex = self.currentIndex - 1;
                // 右边按钮
                YZDisplayTitleLabel *temLabel = nil;
                if (rightIndex >= 0) {
                    temLabel = self.titleLabels[rightIndex];
                }
                self.underLine.uxleft = temLabel.uxcenterX - leftLabelUnderLineW/2.0;
            }
        }
    }
}

// 设置遮盖偏移
- (void)setUpCoverOffset:(CGFloat)offsetX rightLabel:(UILabel *)rightLabel leftLabel:(UILabel *)leftLabel {
    if (_isClickTitle) return;
    
    // 获取两个标题中心点距离
    CGFloat centerDelta = rightLabel.uxleft - leftLabel.uxleft;
    
    // 标题宽度差值
    CGFloat widthDelta = [self widthDeltaWithRightLabel:rightLabel leftLabel:leftLabel];
    
    // 获取移动距离
    CGFloat offsetDelta = offsetX - _lastOffsetX;
    
    // 计算当前下划线偏移量
    CGFloat coverTransformX = offsetDelta * centerDelta / YZScreenW;
    
    // 宽度递增偏移量
    CGFloat coverWidth = offsetDelta * widthDelta / YZScreenW;
    
    self.coverView.uxwidth += coverWidth;
    self.coverView.uxleft += coverTransformX;
    
}

#pragma mark - 标题点击处理
- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    
    if (self.titleLabels.count && selectIndex < self.titleLabels.count) {
        
        UILabel *label = self.titleLabels[selectIndex];
        
        if (_selectIndex >= self.titleLabels.count) {
            @throw [NSException exceptionWithName:@"YZ_ERROR" reason:@"选中控制器的角标越界" userInfo:nil];
        }
        
        [self titleClick:[label.gestureRecognizers firstObject]];
    }
}

// 标题按钮点击
- (void)titleClick:(UITapGestureRecognizer *)tap
{
    // 记录是否点击标题
    _isClickTitle = YES;
    
    // 获取对应标题label
    UILabel *label = (UILabel *)tap.view;
    
    // 获取当前角标
    NSInteger i = label.tag;
    
    // 选中label
    [self selectLabel:label withAnimation:YES];
    
    // 内容滚动视图滚动到对应位置
    CGFloat offsetX = i * YZScreenW;
    
    self.contentScrollView2.contentOffset = CGPointMake(offsetX, 0);
    
    // 记录上一次偏移量,因为点击的时候不会调用scrollView代理记录，因此需要主动记录
    _lastOffsetX = offsetX;
    
    // 添加控制器
    UIViewController *vc = self.childViewControllers[i];
    
    // 判断控制器的view有没有加载，没有就加载，加载完在发送通知
    if (vc.view) {
        
        // 发出通知点击标题通知
        [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewClickOrScrollDidFinshNote  object:vc userInfo:@{@"selectindex":@(i)}];
        
        // 发出重复点击标题通知
        if (_currentIndex == i) {
            [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewClickOrScrollDidFinshNote  object:vc userInfo:@{@"selectindex":@(i)}];
        }
    }
    
    _currentIndex = i;
    
    // 点击事件处理完成
    _isClickTitle = NO;
}

- (void)selectLabel:(UILabel *)label withAnimation:(BOOL)isNeed
{
    for (YZDisplayTitleLabel *labelView in self.titleLabels) {
        
        if (label == labelView) continue;
        
        if (_isShowTitleGradient) {
            
            labelView.transform = CGAffineTransformIdentity;
        }
        
        labelView.textColor = self.norColor;
        labelView.font = self.titleFont;
        
        if (_isShowTitleGradient && _titleColorGradientStyle == YZTitleColorGradientStyleFill) {
            labelView.fillColor = self.norColor;
            labelView.progress = 1;
        }
    }
    
    // 修改标题选中颜色
    label.textColor = self.selColor;
    
    label.font = self.selTitleFont;
    
    // 设置标题居中
    [self setLabelTitleCenter:label];
    
    // 设置下标的位置
    if (_isShowUnderLine) {
        [self setUpUnderLine:label withAnimation:isNeed];
    }
    
    // 设置cover
    if (_isShowTitleCover) {
        [self setUpCoverView:label];
    }
    
}

// 设置蒙版
- (void)setUpCoverView:(UILabel *)label
{
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGFloat border = 5;
    CGFloat coverH = titleBounds.size.height + 2 * border;
    CGFloat coverW = titleBounds.size.width + 2 * border;
    
    self.coverView.uxtop = (label.uxheight - coverH) * 0.5;
    self.coverView.uxheight = coverH;
    
    
    // 最开始不需要动画
    if (self.coverView.uxleft == 0) {
        self.coverView.uxwidth = coverW;
        
        self.coverView.uxleft = label.uxleft - border;
        return;
    }
    
    // 点击时候需要动画
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.uxwidth = coverW;
        
        self.coverView.uxleft = label.uxleft - border;
    }];
    
    
    
}

// 设置下标的位置
- (void)setUpUnderLine:(UILabel *)label withAnimation:(BOOL)isNeed
{
    // 获取文字尺寸
    CGRect titleBounds = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleFont} context:nil];
    
    CGFloat underLineH = _underLineH?_underLineH:YZUnderLineH;
    
    self.underLine.uxtop = label.uxheight - underLineH - 4;
    self.underLine.uxheight = underLineH;
    self.underLine.layer.cornerRadius = underLineH/2.0;
    
    // 最开始不需要动画
    if (self.underLine.uxleft == 0) {
        if (_isUnderLineEqualTitleWidth) {
            self.underLine.uxwidth = titleBounds.size.width;
        } else {
            self.underLine.uxwidth = _underLineW > 0?_underLineW:label.uxwidth;
        }
        
        self.underLine.uxcenterX = label.uxcenterX;
        return;
    }
    
    // 点击时候需要动画
    CGFloat lineW = self.underLine.uxwidth;
    if (_isUnderLineEqualTitleWidth) {
        lineW = titleBounds.size.width;
    } else {
        lineW = _underLineW?_underLineW:label.uxwidth;
    }
    if (isNeed) {
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0
                                    relativeDuration:1/2.0                                           animations:^{
                                        self.underLine.uxwidth = lineW + 20;
                                        CGFloat x = (self.underLine.uxcenterX+label.uxcenterX)/2;
                                        self.underLine.uxcenterX = x;
                                        
                                    }];
            
            [UIView addKeyframeWithRelativeStartTime:1/2.0
                                    relativeDuration:1/2.0                                           animations:^{
                                        self.underLine.uxwidth = lineW;
                                        self.underLine.uxcenterX = label.uxcenterX;
                                        
                                    }];
            
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.underLine.uxwidth = lineW;
        self.underLine.uxcenterX = label.uxcenterX;
    }
}

// 让选中的按钮居中显示
- (void)setLabelTitleCenter:(UILabel *)label
{
    
    // 设置标题滚动区域的偏移量
    CGFloat offsetX = label.center.x - YZScreenW * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    // 计算下最大的标题视图滚动区域
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - YZScreenW + _titleMargin;
    
    if (maxOffsetX < 0) {
        maxOffsetX = 0;
    }
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    // 滚动区域
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}

#pragma mark - 刷新界面方法
// 更新界面
- (void)refreshDisplay
{
    if (self.childViewControllers.count == 0) {
        @throw [NSException exceptionWithName:@"YZ_ERROR" reason:@"请确定添加了所有子控制器" userInfo:nil];
    }
    
    // 清空之前所有标题
    [self.titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    
    // 刷新表格
    [self.contentScrollView2 reloadData];
    
    // 重新设置标题
//    if (_titleColorGradientStyle == YZTitleColorGradientStyleFill || _titleWidth == 0) {
//
//        [self setUpTitleWidth];
//    }
    
    [self setUpAllTitle];
    // 默认选中标题
    self.selectIndex = self.selectIndex;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childViewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    // 移除之前的子控件
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 添加控制器
    UIViewController *vc = self.childViewControllers[indexPath.row];
    
    vc.view.frame = CGRectMake(0, 0, self.contentScrollView2.uxwidth, self.contentScrollView2.uxheight);
    
    CGFloat bottom = self.tabBarController == nil?0:49;
//    CGFloat top = _isfullScreen?CGRectGetMaxY(self.titleScrollView.frame):0;
    CGFloat top = 0;
    if ([vc isKindOfClass:[UITableViewController class]]) {
        UITableViewController *tableViewVc = (UITableViewController *)vc;
        tableViewVc.tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
    }
    [cell.contentView addSubview:vc.view];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!scrollView.isDecelerating) {
        _startOffset = scrollView.contentOffset.x;
    }
}

// 减速完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger offsetXInt = offsetX;
    NSInteger screenWInt = YZScreenW;
    
    NSInteger extre = offsetXInt % screenWInt;
    if (extre > YZScreenW * 0.5) {
        // 往右边移动
        offsetX = offsetX + (YZScreenW - extre);
        _isAniming = YES;
        [self.contentScrollView2 setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }else if (extre < YZScreenW * 0.5 && extre > 0){
        _isAniming = YES;
        // 往左边移动
        offsetX =  offsetX - extre;
        [self.contentScrollView2 setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    
    // 获取角标
    NSInteger i = offsetX / YZScreenW;
    
    // 选中标题
    [self selectLabel:self.titleLabels[i] withAnimation:NO];
    
    // 取出对应控制器发出通知
    UIViewController *vc = self.childViewControllers[i];
    
    // 发出通知
    _currentIndex = i;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YZDisplayViewClickOrScrollDidFinshNote  object:vc userInfo:@{@"selectindex":@(i)}];
}


// 监听滚动动画是否完成
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _isAniming = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 点击和动画的时候不需要设置
    if (_isAniming || self.titleLabels.count == 0) return;
    
    // 获取偏移量
    CGFloat offsetX = scrollView.contentOffset.x;
    
    
    
    if (offsetX > _startOffset && !_isScrollLeft) {
        _isScrollLeft = YES;
    }
    if (offsetX < _startOffset && _isScrollLeft) {
        _isScrollLeft = NO;
    }
    
    // 获取左边角标
    NSInteger leftIndex = offsetX / YZScreenW;
    
    // 左边按钮
    YZDisplayTitleLabel *leftLabel = self.titleLabels[leftIndex];
    
    // 右边角标
    NSInteger rightIndex = leftIndex + 1;
    
    // 右边按钮
    YZDisplayTitleLabel *rightLabel = nil;
    
    if (rightIndex < self.titleLabels.count) {
        rightLabel = self.titleLabels[rightIndex];
    }
    
    // 字体放大
    [self setUpTitleScaleWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 设置下标偏移
    if (_isDelayScroll == NO) { // 延迟滚动，不需要移动下标
        
        [self setUpUnderLineOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    }
    
    // 设置遮盖偏移
    [self setUpCoverOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 设置标题渐变
    [self setUpTitleColorGradientWithOffset:offsetX rightLabel:rightLabel leftLabel:leftLabel];
    
    // 记录上一次的偏移量
    _lastOffsetX = offsetX;
    
    if (fabs(_lastOffsetX - _startOffset)/YZScreenW > 1) {
        [scrollView setScrollEnabled:NO];
        [self scrollViewDidEndDecelerating:scrollView];
    }
    [scrollView setScrollEnabled:YES];
}

#pragma mark - 颜色操作

- (void)setNorColor:(UIColor *)norColor
{
    _norColor = norColor;
    [self setupStartColor:norColor];
    
}

- (void)setSelColor:(UIColor *)selColor
{
    _selColor = selColor;
    [self setupEndColor:selColor];
}

- (void)setupStartColor:(UIColor *)color
{
    CGFloat components[3];
    
    [self getRGBComponents:components forColor:color];
    
    _startR = components[0];
    _startG = components[1];
    _startB = components[2];
}

- (void)setupEndColor:(UIColor *)color
{
    CGFloat components[3];
    
    [self getRGBComponents:components forColor:color];
    
    _endR = components[0];
    _endG = components[1];
    _endB = components[2];
}



/**
 *  指定颜色，获取颜色的RGB值
 *
 *  @param components RGB数组
 *  @param color      颜色
 */
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 1);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

- (void)setTabIndex:(NSUInteger)index
          badgeType:(YZTitleBadgeType)type
              value:(NSUInteger)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *numberView = [self.titleScrollView viewWithTag:index + 1000];
        UILabel *numberLabel = (UILabel *)[self.titleScrollView viewWithTag:index + 2000];
        UIView *redDotView = [self.titleScrollView viewWithTag:index + 3000];
        
        [self.titleScrollView bringSubviewToFront:numberView];
        
        CGFloat topSpace = 8;
        CGFloat leftSpace = 3;
        CGFloat offsetForX = 0;
        
        if (value == 0) {
            numberView.hidden = YES;
            redDotView.hidden = YES;
        } else {
            switch (type) {
                case YZTitleBadgeTypeRedDot: {
                    numberView.hidden = YES;
                    redDotView.hidden = NO;
                }
                    break;
                case YZTitleBadgeTypeNumber: {
                    numberView.hidden = NO;
                    redDotView.hidden = YES;
                    if (value > 99) {
                        numberLabel.text = @"99+";
                        if (numberView.superview) {
                            [numberView remakeConstraints:^(MASConstraintMaker *make) {
                                make.size.equalTo(CGSizeMake(26, 15));
                                make.top.equalTo(topSpace+(IS_Bangs_Screen ? offsetForX:0));
                                make.left.equalTo(numberView.superview.right).offset(-leftSpace);
                            }];
                        }
                    } else {
                        if (value > 9) {
                            if (numberView.superview) {
                                [numberView remakeConstraints:^(MASConstraintMaker *make) {
                                    make.size.equalTo(CGSizeMake(21, 15));
                                    make.top.equalTo(topSpace+(IS_Bangs_Screen ? offsetForX:0));
                                    make.left.equalTo(numberView.superview.right).offset(-leftSpace);
                                }];
                            }
                        } else {
                            if (numberView.superview) {
                                [numberView remakeConstraints:^(MASConstraintMaker *make) {
                                    make.size.equalTo(CGSizeMake(15, 15));
                                    make.top.equalTo(topSpace+(IS_Bangs_Screen ? offsetForX:0));
                                    make.left.equalTo(numberView.superview.right).offset(-leftSpace);
                                }];
                            }
                        }
                        
                        numberLabel.text = [@(value) stringValue];
                    }
                }
                    break;
                case YZTitleBadgeTypeNone: {
                    numberView.hidden = YES;
                    redDotView.hidden = YES;
                }
                    break;
                default:
                    break;
            }
        }
    });
}

@end
