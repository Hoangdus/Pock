#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct SBIconCoordinate {
	long long row;
	long long col;
} SBIconCoordinate;

@interface SBDockView : UIView
    @property (nonatomic, retain) UIScrollView *pockIconScrollView;
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
@end

@interface SBDockIconListView : SBIconListView
	+(double)defaultHeight;
	-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1;	
@end

@interface SBRootFolderDockIconListView : SBDockIconListView
    @property (nonatomic,readonly) CGSize alignmentIconSize;
	-(CGFloat)calculateDockWidth:(CGFloat)iconSpacing dockPaging:(bool)dockPaging;
@end

@interface SBIconListGridLayoutConfiguration : NSObject
@end
