#import "Pock.h"

bool pockEnabled = false;

bool dockPaging = false;
bool disablePagingWhenEditing = false;

bool scrollToEndWhenEdit = false;
bool scrollBackFromEndAfterEdit = false;
bool animateScrollToEndWhenEdit = true;

bool verticalPage = false;//not use for now
bool doublePageRow = true;//vertical page only

int iconColumns = 4;
CGFloat infiniteSpacing = 27;//only reconmended for 4 icon columns or less (27 for stock ios look when at 4 col, 13 for 5 col)

bool showScrollingIndicator = false;
bool isScrollBounceEnabled = false;
bool snapToIcon = false;
bool disableSnapToIconWhenEdit = false;

// SBDockView *cSBDockView = nil;
UIScrollView *cPockIconScrollView = nil;
CGFloat touchableWidth = 375;
CGFloat touchableHeight = 92;
CGFloat iconSizeWidth = 0;
CGPoint oldScrollPosision = CGPointZero;
CGFloat iconWidthDivider = 0.73;
CGFloat indexThresholdThreshold = 80;
BOOL isEditingHomeScreen = false;

void prefThings(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.hoangdus.pockpref"];
	pockEnabled = (prefs && [prefs objectForKey:@"PockEnabled"] ? [[prefs valueForKey:@"PockEnabled"] boolValue] : false );

	dockPaging = (prefs && [prefs objectForKey:@"DockPagingEnabled"] ? [[prefs valueForKey:@"DockPagingEnabled"] boolValue] : false );
	disablePagingWhenEditing = (prefs && [prefs objectForKey:@"DisablePagingWhenEdit"] ? [[prefs valueForKey:@"DisablePagingWhenEdit"] boolValue] : false );
	iconColumns = (prefs && [prefs objectForKey:@"IconPerPage"] ? [[prefs valueForKey:@"IconPerPage"] integerValue] : 4 );

	if(iconColumns == 5){
		infiniteSpacing = 13;
		indexThresholdThreshold = 70;
	}

	scrollToEndWhenEdit = (prefs && [prefs objectForKey:@"ScrollToEndWhenEdit"] ? [[prefs valueForKey:@"ScrollToEndWhenEdit"] boolValue] : false );
	scrollBackFromEndAfterEdit = (prefs && [prefs objectForKey:@"ScrollBackAfterEdit"] ? [[prefs valueForKey:@"ScrollBackAfterEdit"] boolValue] : false );
	animateScrollToEndWhenEdit = (prefs && [prefs objectForKey:@"AnimateWhenAutoScroll"] ? [[prefs valueForKey:@"AnimateWhenAutoScroll"] boolValue] : false );

	showScrollingIndicator = (prefs && [prefs objectForKey:@"ShowIndicator"] ? [[prefs valueForKey:@"ShowIndicator"] boolValue] : false );	
	isScrollBounceEnabled = (prefs && [prefs objectForKey:@"ScrollBounce"] ? [[prefs valueForKey:@"ScrollBounce"] boolValue] : false );
	snapToIcon = (prefs && [prefs objectForKey:@"SnapToIcon"] ? [[prefs valueForKey:@"SnapToIcon"] boolValue] : false );
	disableSnapToIconWhenEdit = (prefs && [prefs objectForKey:@"DisableSnappingWhenEdit"] ? [[prefs valueForKey:@"DisableSnappingWhenEdit"] boolValue] : false );
}

%group Pock

@implementation PockIconScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if(disableSnapToIconWhenEdit && isEditingHomeScreen){
		return;
	}
	//thanks nepeta
	CGFloat iconWidth = iconSizeWidth + infiniteSpacing;
	NSInteger index = ceil((targetContentOffset->x - infiniteSpacing) / iconWidth);
	CGFloat indexThreshold = -((targetContentOffset->x - infiniteSpacing) - (ceil(targetContentOffset->x / iconWidth) * iconWidth));
	// NSLog(@"[Pock] index++: %f", indexThreshold);

	if (indexThreshold < iconWidth * iconWidthDivider) {
		targetContentOffset->x = index * iconWidth;
	}else if(indexThreshold < indexThresholdThreshold){
		targetContentOffset->x = (index - 1) * iconWidth;
	}else{
		targetContentOffset->x = index * iconWidth;
	}
}

@end

//TODO: icon snapping when dockPaging is off
%hook SBDockView
	
	%property (nonatomic, retain) UIScrollView *pockIconScrollView;
	%property (nonatomic, retain) PockIconScrollViewDelegate *pockIconScrollViewDelegate;

	-(id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2{
		%orig;

		[arg1 removeFromSuperview]; //remove original icon list view

		//init a UIScrollView
		CGFloat frameX = [arg1 frame].origin.x;
		CGFloat frameY = 0;
		CGFloat frameWidth = [arg1 frame].size.width;
		CGFloat frameHeight = 0;
		
		if(verticalPage){
			frameY = [arg1 frame].origin.y + 4;
		}else{
			frameY = [arg1 frame].origin.y;
		}

		if(doublePageRow && verticalPage){
			frameHeight = [arg1 frame].size.height * 1.75 + 3;
		}else{
			frameHeight = [arg1 frame].size.height;
		}
		
		// NSLog(@"[Pock] initWithDockListView arg1 Frame: %@", NSStringFromCGRect([arg1 frame]));
		self.pockIconScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frameX, frameY, frameWidth, frameHeight)];
		// self.pockIconScrollView.center = CGPointMake(frameWidth/2, frameHeight/2); //fix for RoundDock Remastered

		self.pockIconScrollView.pagingEnabled = dockPaging;
		self.pockIconScrollView.bounces = isScrollBounceEnabled;
		self.pockIconScrollView.showsHorizontalScrollIndicator = showScrollingIndicator;
		self.pockIconScrollView.showsVerticalScrollIndicator = showScrollingIndicator;
		self.pockIconScrollView.layer.masksToBounds = YES;
		self.pockIconScrollView.translatesAutoresizingMaskIntoConstraints = NO;
		
		if(snapToIcon && !dockPaging){
			self.pockIconScrollViewDelegate = [PockIconScrollViewDelegate alloc];
			self.pockIconScrollView.delegate = self.pockIconScrollViewDelegate;
		}

		//setup the views
		[self.pockIconScrollView addSubview: arg1];
		[self addSubview: self.pockIconScrollView];

		//make a pointer of the views to use outside of the class
		cPockIconScrollView = self.pockIconScrollView;
		// cSBDockView = self;

		return self;
	}

	-(double)dockHeight{
		// NSLog(@"[Pock] orig dock height: %f", %orig);
		if(doublePageRow && verticalPage){
			return %orig * 1.75;
		}
		return %orig;

	}
%end

%hook SBRootFolderDockIconListView

	-(void)didMoveToWindow{
		%orig;
		NSInteger iconCount = [[self icons] count];
		if(verticalPage){
			touchableHeight = 750;
			cPockIconScrollView.contentSize = CGSizeMake(375, touchableHeight);
			return;
		}
		touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount dockPaging:dockPaging]; //hacky way to set SBDockView width		
		cPockIconScrollView.contentSize = CGSizeMake(touchableWidth, 92);
		// [self setFrame:CGRectZero];
	}

	//not very ideal, needs improve later
	-(void)setFrame:(CGRect)arg1{
		// NSLog(@"[Pock] setFrame arg 1: %@", NSStringFromCGRect(arg1));
		// NSLog(@"[Pock] is dock: %d", [self isDock]);
		%orig;
		if(verticalPage){
			if(arg1.origin.y == 4 && (arg1.size.height == 92 || arg1.size.height == 164)){
				CGRect newFrame = CGRectMake(arg1.origin.x , arg1.origin.y - 4, arg1.size.width, touchableHeight); // hacky way to set width 
				// NSLog(@"[Pock] arg 1: %@", NSStringFromCGRect(arg1));
				// NSLog(@"[Pock] new frame: %@", NSStringFromCGRect(newFrame));
				%orig(newFrame);
				return;
			}
		}

		if(arg1.size.height == 92){
			CGRect newFrame = CGRectMake(arg1.origin.x , arg1.origin.y, touchableWidth, arg1.size.height); // hacky way to set width 
			// NSLog(@"[Pock] new frame: %@", NSStringFromCGRect(newFrame));
			%orig(newFrame);
			return;
		}
	}

	//set touchable area width and UIScrollView contentWidth after finish editting homescreen
	-(void)setEditing:(BOOL)arg1{
		NSInteger iconCount = [[self icons] count];
		%orig;
		isEditingHomeScreen = arg1;

		if(verticalPage){
			return;
		}

		if(arg1 && dockPaging && disablePagingWhenEditing){
			cPockIconScrollView.pagingEnabled = false;
		}else if(dockPaging && disablePagingWhenEditing){
			cPockIconScrollView.pagingEnabled = true;
		}

		//hacky way to set SBDockView width
		if(arg1){
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount+1 dockPaging:dockPaging];
		}else{
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount dockPaging:dockPaging]; 
		}

		cPockIconScrollView.contentSize = CGSizeMake(touchableWidth, 92);

		if(arg1 && scrollToEndWhenEdit){
			oldScrollPosision = cPockIconScrollView.contentOffset;
			[cPockIconScrollView setContentOffset:CGPointMake(touchableWidth-375, 0) animated:animateScrollToEndWhenEdit];			
		}else if(!arg1 && scrollToEndWhenEdit && scrollBackFromEndAfterEdit && [[self icons] count] != iconColumns){
			[cPockIconScrollView setContentOffset:oldScrollPosision animated:animateScrollToEndWhenEdit];			
		}

		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, touchableWidth, self.frame.size.height)];
	}

	//recalculate touchable area width and UIScrollView contentWidth after adding icon when editting homescreen 
	//also fixes jailbreak only app icon reappearing after rejailbreak 
	-(void)iconList:(id)arg1 didAddIcon:(id)arg2{
		%orig;
		NSInteger iconCount = [[self icons] count];
		if([self isEditing]){
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount+1 dockPaging:dockPaging]; 
		}else{
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount dockPaging:dockPaging]; 
		}

		cPockIconScrollView.contentSize = CGSizeMake(touchableWidth, 92);
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, touchableWidth, self.frame.size.height)];
	}

	// -(void)setIconSpacing:(CGSize)arg1{
	// 	if(verticalPage || !dockPaging){
	// 		%orig(CGSizeMake(20, arg1.height));
	// 	}else{
	// 		%orig;
	// 	}
	// }

	//column(icon) position when editting homescreem
	-(unsigned long long)columnAtPoint:(CGPoint)arg1 metrics:(id)arg2 fractionOfDistanceThroughColumn:(double*)arg3{
		if (verticalPage){
			return %orig;	
		}
		CGSize iconSize = [self alignmentIconSize];
		unsigned long long columnPoint = (arg1.x - infiniteSpacing)/(iconSize.width + infiniteSpacing);
		if(dockPaging){
			int pageNumber = ceil(arg1.x/cPockIconScrollView.frame.size.width);
			CGFloat offset = (cPockIconScrollView.frame.size.width - (iconSize.width + infiniteSpacing) * iconColumns)/2;
			CGFloat newX = offset * ((pageNumber - 1) * 2 -1);
			columnPoint = (arg1.x - newX - infiniteSpacing/2) / (iconSize.width + infiniteSpacing);
			// NSLog(@"[Pock] point: %llu", columnPoint);
			return columnPoint;
		}
		return columnPoint;
	}

	// -(unsigned long long)rowAtPoint:(CGPoint)arg1 metrics:(id)arg2{
	// 	return 0;
	// }

	// column(icon) position(spacing)
	-(CGPoint)originForIconAtCoordinate:(SBIconCoordinate)arg1 metrics:(id)arg2{
		if(verticalPage){
			return %orig;	
		}

		CGSize iconSize = [self alignmentIconSize];
		iconSizeWidth = iconSize.width;
		// CGFloat top = [%c(SBDockIconListView) defaultHeight]/2 - size.height;
		CGFloat x = ((iconSize.width + infiniteSpacing) * (arg1.col - 1)) + infiniteSpacing;
		// NSLog(@"[Pock] x point: %f", [self horizontalIconPadding]);
		CGFloat y = %orig.y;
		if(dockPaging){
			//thanks Nepeta for the math 
			CGFloat offset = (cPockIconScrollView.frame.size.width - (iconSize.width + infiniteSpacing) * iconColumns)/2;//add an offset for every 4 icons (big space every 4 icons)
			x = offset * (ceil((arg1.col - 1) / iconColumns) * 2 + 1);
			CGFloat newX = ((iconSize.width + infiniteSpacing) * (arg1.col - 1)) + x + infiniteSpacing * 0.5;
			return CGPointMake(newX, y);
		}

		return CGPointMake(x, y);
	}

	%new
	-(CGFloat)calculateDockFrameWidth:(CGFloat)iconSpacing iconCount:(NSInteger)iconCount dockPaging:(bool)dockPaging{
		CGSize iconSize = [self alignmentIconSize];
		if(!dockPaging){
			return iconCount * (iconSize.width + iconSpacing) + iconSpacing;
		}
		if (iconCount % iconColumns == 0){
			return cPockIconScrollView.frame.size.width * ceil(iconCount / iconColumns);
		}
		return cPockIconScrollView.frame.size.width * (ceil(iconCount / iconColumns) + 1);
	}

%end

%hook SBIconListGridLayoutConfiguration

	//set the number of icons aka iconColumns
	-(unsigned long long)numberOfPortraitColumns{
		NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
		if (rows == 1 && !verticalPage){
			return(1000);
		}
		return %orig;
	}

	//vertical scrolling later
	// set number of rows
	-(unsigned long long)numberOfPortraitRows{
		NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
		if (rows == 1 && verticalPage){
			return(1000);
		}
		return %orig;
	}

%end 
%end

%ctor{
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefThings, CFSTR("com.hoangdus.pockpref-updated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	prefThings();

	if(pockEnabled){
		%init(Pock);
	}
}