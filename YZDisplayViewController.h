//
//  YZDisplayViewController.h
//  BuDeJie
//
//  Created by yz on 15/12/1.
//  Copyright © 2015年 yz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UXSwipeCollectionView.h"
#import "ErWoBaseViewController.h"

// 颜色渐变样式
typedef enum : NSUInteger {
    YZTitleColorGradientStyleRGB , // RGB:默认RGB样式
    YZTitleColorGradientStyleFill, // 填充
} YZTitleColorGradientStyle;

typedef NS_ENUM(NSInteger, YZTitleBadgeType) {
    YZTitleBadgeTypeNone,
    YZTitleBadgeTypeRedDot,
    YZTitleBadgeTypeNumber
};

@interface YZDisplayViewController : ErWoBaseViewController

/**************************************【内容】************************************/
/**
    内容是否需要全屏展示
    YES :  全屏：内容占据整个屏幕，会有穿透导航栏效果，需要手动设置tableView额外滚动区域
    NO  :  内容从标题下展示
 */
@property (nonatomic, assign) BOOL isfullScreen;

@property (nonatomic, strong) UIView *redPoint;

/** 根据角标，选中对应的控制器 */
@property (nonatomic, assign) NSInteger selectIndex;

/** 标题间隔 */
@property (nonatomic, assign) CGFloat titleMargin;

/** 标题距左边的间距，不传默认居中 */
@property(nonatomic, assign) CGFloat leftLayoutMargin;

/** 当前选中角标 */
@property (nonatomic, assign) NSInteger currentIndex;

/** 标题滚动视图 */
@property (nonatomic, weak) UIScrollView *titleScrollView;

/** 内容滚动视图 */
@property (nonatomic, weak) UXSwipeCollectionView *contentScrollView2;

/** 是否使用自定义label宽度 */
@property (nonatomic, assign) BOOL customLabelWidth;

/** 是否显示返回按钮，默认隐藏 */
@property (nonatomic, assign) BOOL showBackButton;

/** 是否需要titleScrollView内部 水平居中，默认是有一定偏移量，当用于导航栏的时候 */
@property(nonatomic, assign) BOOL titleViewsHorizonCenter;

/** 自定义下划线的图片  此时setUpUnderLineEffect这个方法内不要再设置宽和高以及背景颜色 */
- (void) setUpCustomUnderLineImage:(NSString *)imageName size:(CGSize)size;

/**
    如果_isfullScreen = Yes，这个方法就不好使。
 
    设置整体内容的frame,包含（标题滚动视图和内容滚动视图）
 */
- (void)setUpContentViewFrame:(void(^)(UIView *contentView))contentBlock;

/**
 刷新标题和整个界面，在调用之前，必须先确定所有的子控制器。
 */
- (void)refreshDisplay;


/***********************************【顶部标题样式】********************************/
- (void)setUpTitleEffect:(void(^)(UIColor **titleScrollViewColor,UIColor **norColor,UIColor **selColor,UIFont **titleFont,UIFont **selTitleFont,CGFloat *titleHeight,CGFloat *titleWidth))titleEffectBlock;


/***********************************【下标样式】***********************************/
//默认宽度是标题长度，isUnderLineEqualTitleWidth为NO则取underLineW，如果underLineW没有设置就取Label的宽度
- (void)setUpUnderLineEffect:(void(^)(BOOL *isUnderLineDelayScroll,CGFloat *underLineH,UIColor **underLineColor, BOOL *isUnderLineEqualTitleWidth,CGFloat *underLineW))underLineBlock;

/**********************************【颜色渐变】************************************/
- (void)setUpTitleGradient:(void(^)(YZTitleColorGradientStyle *titleColorGradientStyle,UIColor **norColor,UIColor **selColor))titleGradientBlock;

/**********************************【遮盖】************************************/
- (void)setUpCoverEffect:(void(^)(UIColor **coverColor,CGFloat *coverCornerRadius))coverEffectBlock;

/**
 设置标题栏角标
 
 @param type 类型
 @param index 序号
 @param value 数值
 */
- (void)setTabIndex:(NSUInteger)index
          badgeType:(YZTitleBadgeType)type
              value:(NSUInteger)value;

- (void)backAction;

@end
