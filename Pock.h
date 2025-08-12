#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libroot.h>

typedef struct SBIconCoordinate {
	long long row;
	long long col;
} SBIconCoordinate;

@interface PockIconScrollViewDelegate : NSObject<UIScrollViewDelegate>
@end

@interface SBDockView : UIView
    @property (nonatomic, retain) UIScrollView *pockIconScrollView;
	@property (nonatomic, retain) PockIconScrollViewDelegate *pockIconScrollViewDelegate;

	-(UIView *)backgroundView;
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
    @property (nonatomic,readonly) CGSize alignmentIconSize;
	+(double)defaultHeight;
	-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1;	
	-(CGFloat)calculateDockFrameWidth:(CGFloat)iconSpacing iconCount:(NSInteger)iconCount dockPaging:(bool)dockPaging;
@end

@interface SBRootFolderDockIconListView : SBDockIconListView
@end

@interface SBIconListGridLayoutConfiguration : NSObject
@end
