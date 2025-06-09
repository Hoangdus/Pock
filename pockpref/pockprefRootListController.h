#import <Preferences/PSListController.h>
#import <Preferences/PSSwitchTableCell.h>
#import "spawn.h"

@interface pockprefRootListController : PSListController

@end

@interface PockHeaderCell : UITableViewCell
@end

@interface PockSwitchCell : PSSwitchTableCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
@end
