#import <Foundation/Foundation.h>
#import "pockprefRootListController.h"

@implementation pockprefRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
