#import "Pock.h"

bool pockEnabled = false;
bool isDockPagingEnabled = false;
bool showScrollingIndicator = true;
bool disablePagingWhenEditing = true;
bool isScrollBounceEnabled = false;
bool isVerticalPageEnabled = false;
bool isDoubleRowEnabled = true;//vertical scroll only
int iconColumns = 4;
CGFloat infiniteSpacing = 27;//only reconmended for 4 icon columns or less (27 for stock ios look when at 4 col, 13 for 5 col)

// SBDockView *cSBDockView = nil;
UIScrollView *cPockIconScrollView = nil;
CGFloat touchableWidth = 375;
CGFloat touchableHeight = 92;

void prefThings(){
	NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.hoangdus.pockpref"];
	pockEnabled = (prefs && [prefs objectForKey:@"isPockEnabled"] ? [[prefs valueForKey:@"isPockEnabled"] boolValue] : false );
	isDockPagingEnabled = (prefs && [prefs objectForKey:@"isPagingEnabled"] ? [[prefs valueForKey:@"isPagingEnabled"] boolValue] : false );
	showScrollingIndicator = (prefs && [prefs objectForKey:@"showIndicator"] ? [[prefs valueForKey:@"showIndicator"] boolValue] : false );
	isScrollBounceEnabled = (prefs && [prefs objectForKey:@"scrollBounce"] ? [[prefs valueForKey:@"scrollBounce"] boolValue] : false );
	disablePagingWhenEditing = (prefs && [prefs objectForKey:@"disablePagingWhenEdit"] ? [[prefs valueForKey:@"disablePagingWhenEdit"] boolValue] : false );
}

%group Pock
//TODO: icon snapping when dockPaging is off
%hook SBDockView
	
	%property (nonatomic, retain) UIScrollView *pockIconScrollView;

	-(id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2{
		%orig;

		[arg1 removeFromSuperview]; //remove original icon list view

		//init a UIScrollView
		CGFloat frameX = [arg1 frame].origin.x;
		CGFloat frameY = 0;
		CGFloat frameWidth = [arg1 frame].size.width;
		CGFloat frameHeight = 0;
		
		if(isVerticalPageEnabled){
			frameY = [arg1 frame].origin.y + 4;
		}else{
			frameY = [arg1 frame].origin.y;
		}

		if(isDoubleRowEnabled && isVerticalPageEnabled){
			frameHeight = [arg1 frame].size.height * 1.75 + 3;
		}else{
			frameHeight = [arg1 frame].size.height;
		}
		
		NSLog(@"[Pock] initWithDockListView arg1 Frame: %@", NSStringFromCGRect([arg1 frame]));
		self.pockIconScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frameX, frameY, frameWidth, frameHeight)];
		// self.pockIconScrollView.center = CGPointMake(frameWidth/2, frameHeight/2); //fix for RoundDock Remastered

		self.pockIconScrollView.pagingEnabled = isDockPagingEnabled;
		self.pockIconScrollView.bounces = isScrollBounceEnabled;
		self.pockIconScrollView.showsHorizontalScrollIndicator = showScrollingIndicator;
		self.pockIconScrollView.showsVerticalScrollIndicator = showScrollingIndicator;
		self.pockIconScrollView.layer.masksToBounds = YES;
		self.pockIconScrollView.translatesAutoresizingMaskIntoConstraints = NO;

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
		if(isDoubleRowEnabled && isVerticalPageEnabled){
			return %orig * 1.75;
		}
		return %orig;

	}
%end

%hook SBRootFolderDockIconListView

	-(void)didMoveToWindow{
		%orig;
		NSInteger iconCount = [[self icons] count];
		if(isVerticalPageEnabled){
			touchableHeight = 750;
			cPockIconScrollView.contentSize = CGSizeMake(375, touchableHeight);
			return;
		}
		touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount dockPaging:isDockPagingEnabled]; //hacky way to set SBDockView width		
		cPockIconScrollView.contentSize = CGSizeMake(touchableWidth, 92);
		// [self setFrame:CGRectZero];
	}

	//not very ideal, needs improve later
	-(void)setFrame:(CGRect)arg1{
		// NSLog(@"[Pock] setFrame arg 1: %@", NSStringFromCGRect(arg1));
		// NSLog(@"[Pock] is dock: %d", [self isDock]);
		if(isVerticalPageEnabled){
			if(arg1.origin.y == 4 && (arg1.size.height == 92 || arg1.size.height == 164)){
				CGRect newFrame = CGRectMake(arg1.origin.x , arg1.origin.y - 4, arg1.size.width, touchableHeight); // hacky way to set width 
				// NSLog(@"[Pock] arg 1: %@", NSStringFromCGRect(arg1));
				NSLog(@"[Pock] new frame: %@", NSStringFromCGRect(newFrame));
				%orig(newFrame);
				return;
			}
		}

		if(arg1.size.height == 92){
			CGRect newFrame = CGRectMake(arg1.origin.x , arg1.origin.y, touchableWidth, arg1.size.height); // hacky way to set width 
			NSLog(@"[Pock] new frame: %@", NSStringFromCGRect(newFrame));
			%orig(newFrame);
			return;
		}
		%orig;
	}

	//set touchable area width and UIScrollView contentWidth after finish editting homescreen
	-(void)setEditing:(BOOL)arg1{
		NSInteger iconCount = [[self icons] count];
		%orig;
		if(isVerticalPageEnabled){
			return;
		}
		if(arg1 && isDockPagingEnabled && disablePagingWhenEditing){
			cPockIconScrollView.pagingEnabled = false;
			return;
		}
		if(!arg1 && isDockPagingEnabled && disablePagingWhenEditing){
			cPockIconScrollView.pagingEnabled = true;
		}

		//hacky way to set SBDockView width
		if(arg1){
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount+1 dockPaging:isDockPagingEnabled];
		}else{
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount dockPaging:isDockPagingEnabled]; 
		}

		cPockIconScrollView.contentSize = CGSizeMake(touchableWidth, 92);
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, touchableWidth, self.frame.size.height)];
	}

	//recalculate touchable area width and UIScrollView contentWidth after adding icon when editting homescreen 
	//also fixes jailbreak only app icon reappearing after rejailbreak 
	-(void)iconList:(id)arg1 didAddIcon:(id)arg2{
		%orig;
		NSInteger iconCount = [[self icons] count];
		if([self isEditing]){
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount+1 dockPaging:isDockPagingEnabled]; 
		}else{
			touchableWidth = [self calculateDockFrameWidth:infiniteSpacing iconCount:iconCount dockPaging:isDockPagingEnabled]; 
		}

		cPockIconScrollView.contentSize = CGSizeMake(touchableWidth, 92);
		[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, touchableWidth, self.frame.size.height)];
	}

	// -(void)setIconSpacing:(CGSize)arg1{
	// 	if(isVerticalPageEnabled || !isDockPagingEnabled){
	// 		%orig(CGSizeMake(20, arg1.height));
	// 	}else{
	// 		%orig;
	// 	}
	// }

	//column(icon) position when editting homescreem
	-(unsigned long long)columnAtPoint:(CGPoint)arg1 metrics:(id)arg2 fractionOfDistanceThroughColumn:(double*)arg3{
		if (isVerticalPageEnabled){
			return %orig;	
		}
		CGSize iconSize = [self alignmentIconSize];
		unsigned long long columnPoint = (arg1.x - infiniteSpacing)/(iconSize.width + infiniteSpacing);
		if(isDockPagingEnabled){
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
		if(isVerticalPageEnabled){
			return %orig;	
		}

		CGSize iconSize = [self alignmentIconSize];
		// CGFloat top = [%c(SBDockIconListView) defaultHeight]/2 - size.height;
		CGFloat x = ((iconSize.width + infiniteSpacing) * (arg1.col - 1)) + infiniteSpacing;
		// NSLog(@"[Pock] x point: %f", [self horizontalIconPadding]);
		CGFloat y = %orig.y;
		if(isDockPagingEnabled){
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
		if (rows == 1 && !isVerticalPageEnabled){
			return(1000);
		}
		return %orig;
	}

	//vertical scrolling later
	// set number of rows
	-(unsigned long long)numberOfPortraitRows{
		NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
		if (rows == 1 && isVerticalPageEnabled){
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