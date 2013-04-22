//
// Copyright 2010-2011 Toad Away Limited
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#import "TATabBarController.h"
#import "TATabHolderView.h"

@interface TATabBarController (PrivateMethods)

- (void)_displayViewController:(id)viewController;

@end

@implementation TATabBarController

@synthesize viewControllers = viewControllers_, selectedViewController = selectedViewController_, selectedIndex = selectedIndex_;
@dynamic selectedImageMask, unselectedImageMask;

- (id)init
{
	self = [super init];
	
	if(self != nil)
	{
		[self awakeFromNib];
	}
	
	return self;
}

- (void)dealloc
{
	holderView_ = nil;
	tabBar_ = nil;
	viewControllers_ = nil;
	selectedViewController_ = nil;
    [self removeObserver:self forKeyPath:@"selectedViewController"];
}

- (void)awakeFromNib
{
	[self setWantsFullScreenLayout:YES];
	selectedIndex_ = -1;
	
	tabBar_ = [[TATabBar alloc] initWithFrame:CGRectZero];
	[tabBar_ setDelegate:self];
	[self addObserver:self forKeyPath:@"selectedViewController" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)loadView
{
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	
	holderView_ = [[TATabHolderView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
	[self setView:holderView_];
	
	[holderView_ addSubview:tabBar_];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selectedViewController"])
	{
		if([change objectForKey:NSKeyValueChangeOldKey] == [NSNull null])
		{
			[self _displayViewController:[change objectForKey:NSKeyValueChangeNewKey]];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if(selectedViewController_ == nil && viewControllers_ != nil && [viewControllers_ count] > 0)
	{
		[tabBar_ setSelectedItem:[[viewControllers_ objectAtIndex:0] tabBarItem]];
	}
}

/*We don't really need the "animated" parameter but keeping it here so this component is as similar as possible
 to the UITabBarController class.*/
- (void)setViewControllers:(NSArray*)vcs animated:(BOOL)animated
{
	[self setViewControllers:vcs];
}

- (void)setViewControllers:(NSArray *)vcs
{
	viewControllers_ = vcs;
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	for(UIViewController *vc in viewControllers_)
	{
		UITabBarItem *barItem = [vc tabBarItem];
		[items addObject:barItem];
	}

	[tabBar_ setItems:items];
}

- (void)setUnselectedImageMask:(UIImage *)unselectedImageMask
{
	[tabBar_ setUnselectedImageMask:unselectedImageMask];
}

- (UIImage*)unselectedImageMask
{
	return [tabBar_ unselectedImageMask];
}

- (void)setSelectedImageMask:(UIImage *)selectedImageMask
{
	[tabBar_ setSelectedImageMask:selectedImageMask];
}

- (UIImage*)selectedImageMask
{
	return [tabBar_ selectedImageMask];
}

#pragma mark -
#pragma mark TATabBarDelegate methods

- (void)taTabBar:(TATabBar*)tabBar didSelectItem:(UIBarItem*)item
{
	int i = 0;
	for(UIViewController *vc in viewControllers_)
	{
		UITabBarItem *barItem = [vc tabBarItem];
		if(barItem == item)
		{
			selectedIndex_ = i;
			[self _displayViewController:vc];
			break;
		}
		
		i++;
	}
}

#pragma mark -
#pragma mark TATabBarController (PrivateMethods)

- (void)_displayViewController:(id)viewController
{
	if([selectedViewController_ modalViewController] != nil)
		[selectedViewController_ dismissModalViewControllerAnimated:NO];
	
	[selectedViewController_ viewWillDisappear:NO];
	[[selectedViewController_ view] removeFromSuperview];
	[selectedViewController_ viewDidDisappear:NO];
	
	selectedViewController_ = viewController;
	
	//determine which tab bar item was pressed and if none wasn't (because selectedViewController was set programatically)
	//deselect all tabs
	BOOL vcInTab = NO;
	for(UIViewController *vc in viewControllers_)
		if(vc == viewController)
			vcInTab = YES;
	
	if(!vcInTab)
		[tabBar_ setSelectedItem:[viewController tabBarItem]];
	
	UIView *view = [viewController view];
	CGRect frame = [view frame];
    frame.origin.y = 20;
	frame.size.height = [holderView_ frame].size.height - cTabBarHeight - 20;
	
	if(frame.size.height < 0)
		frame.size.height = [[UIScreen mainScreen] bounds].size.height - cTabBarHeight;
	
	[view setFrame:frame];
	
	[selectedViewController_ viewWillAppear:NO];
	[[self view] insertSubview:view atIndex:0];
	[selectedViewController_ viewDidAppear:NO];}

#pragma mark - ListOfWatchlistsViewController delegate

- (void)listOfWatchlistsViewControllerFinishedWorking
{
//    [self dismissModalViewControllerAnimated:YES];
//    if ([self retainCount] == 1) 
//        [self dismissModalViewControllerAnimated:YES];                                
//    else {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
//    }
}

- (void)onTimer:(NSTimer*)theTimer {
    [self dismissModalViewControllerAnimated:YES];
    [theTimer invalidate];
}

@end
