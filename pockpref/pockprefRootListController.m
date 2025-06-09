#import <Foundation/Foundation.h>
#import "pockprefRootListController.h"

@implementation pockprefRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)respring:(id)sender{ //handle the "respring" button
    pid_t pid;
    // const char *args[] = {"killall", "-9", "backboardd", NULL};
    posix_spawn(&pid, "/var/jb/usr/bin/sbreload", NULL, NULL, NULL, NULL); 
}

- (void)github{
  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://www.youtube.com/watch?v=dQw4w9WgXcQ"]options:@{} completionHandler:nil];
}

- (void)twitter{
  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://twitter.com/Hoangdev23"]options:@{} completionHandler:nil];
}

- (void)paypal{
  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://ko-fi.com/hoangdus"]options:@{} completionHandler:nil];
}

@end

@implementation PockSwitchCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:arg3];
    if (self) {
        [((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed: 0.97 green: 0.91 blue: 0.01 alpha: 1.00]]; 
    }
    return self;
}
@end


@implementation PockHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

  if (self) {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 60)];
    title.numberOfLines = 1;
    title.font = [UIFont systemFontOfSize:50];
    title.text = @"Pock";
    title.textColor = [UIColor colorWithRed: 0.97 green: 0.91 blue: 0.01 alpha: 1.00];
    title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:title];

    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, self.frame.size.width, 30)];
    subtitle.numberOfLines = 1;
    subtitle.font = [UIFont systemFontOfSize:20];
    subtitle.text = @"By HoangDus";
    subtitle.textColor = [UIColor grayColor];
    subtitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:subtitle];
  }
  return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  return 150.0;
}
@end
