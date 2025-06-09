#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct SBIconCoordinate {
	long long row;
	long long col;
} SBIconCoordinate;

@interface PockIconScrollViewDelegate : NSObject<UIScrollViewDelegate>
@end

@interface SBDockView : UIView
    @property (nonatomic, retain) UIScrollView *pockIconScrollView;
	@property (nonatomic, retain) PockIconScrollViewDelegate *pockIconScrollViewDelegate;
@end

@interface SBIconListView : UIView
	@property (nonatomic,copy,readonly) NSArray * icons;
	@property (nonatomic,copy,readonly) NSArray * visibleIcons;
	@property (nonatomic,readonly) unsigned long long iconRowsForCurrentOrientation;
	@property (nonatomic,readonly) unsigned long long iconColumnsForCurrentOrientation;
	@property (assign,nonatomic) NSRange visibleRowRange;

	-(CGSize)defaultIconSize;
	-(double)verticalIconPadding;
	-(double)horizontalIconPadding;
	-(double)sideIconInset;
	-(BOOL)isEditing;
@end

@interface SBDockIconListView : SBIconListView
	+(double)defaultHeight;
	-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1;	
@end

@interface SBRootFolderDockIconListView : SBDockIconListView
    @property (nonatomic,readonly) CGSize alignmentIconSize;
	-(CGFloat)calculateDockFrameWidth:(CGFloat)iconSpacing iconCount:(NSInteger)iconCount dockPaging:(bool)dockPaging;
@end

@interface SBIconListGridLayoutConfiguration : NSObject
@end
