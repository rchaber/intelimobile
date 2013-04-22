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

#import <UIKit/UIKit.h>

@protocol TATabBarDelegate;

extern const CGFloat cTabBarHeight;

@interface TATabBar : UIView {
	id __unsafe_unretained delegate;
	
	@private
	NSArray *items_;
	UITabBarItem *__unsafe_unretained selectedItem_;
}

@property (readwrite, nonatomic, unsafe_unretained) id<TATabBarDelegate> delegate;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, unsafe_unretained) UITabBarItem *selectedItem;

@property (readwrite, nonatomic, strong) UIImage *selectedImageMask;
@property (readwrite, nonatomic, strong) UIImage *unselectedImageMask;

//- (void)setItems:(NSArray*)items;
- (void)setItems:(NSArray*)items animated:(BOOL)animated;

@end

@protocol TATabBarDelegate <NSObject>

@optional
- (void)taTabBar:(TATabBar*)tabBar didSelectItem:(UIBarItem*)item;

@end
