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

#import <QuartzCore/QuartzCore.h>
#import "TATabBar.h"

const NSUInteger maxItems = 5;
const CGFloat cTabBarHeight = 49.0f;

@interface TATabBar (PrivateMethods)

- (void)_handleTap:(UIGestureRecognizer*)gestureRecognizer;
- (UIImage*)_selectedTabBarLikeIconWith:(UIImage*)tabBarIconImage;
- (UIImage*)_tabBarImage:(UIImage*)tabBarImage withGradient:(UIImage*)gradientImage;
- (void)_fireDidSelectItem;

@end

@implementation TATabBar

@synthesize delegate, items = items_, selectedItem = selectedItem_, selectedImageMask = selectedImageMask_, unselectedImageMask = unselectedImageMask_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
	[self setBackgroundColor:[UIColor blackColor]];
	[self setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin)];
	
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
	UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
	[longPressGestureRecognizer setMinimumPressDuration:0.3f];
	[self addGestureRecognizer:tapGestureRecognizer];
	[self addGestureRecognizer:longPressGestureRecognizer];
	
	[self addObserver:self forKeyPath:@"selectedItem" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"selectedItem"])
	{
		[self setNeedsDisplay];
		[self _fireDidSelectItem];
	}
}

- (void)dealloc
{
	items_ = nil;
	selectedImageMask_ = nil;
	unselectedImageMask_ = nil;
    [self removeObserver:self forKeyPath:@"selectedItem"];
}

- (void)setItems:(NSArray*)items
{
	items_ = items;
	[self setNeedsDisplay];
}

- (void)setItems:(NSArray*)items animated:(BOOL)animated
{
	[self setItems:items];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];

	CGRect frame = [self frame];
	CGFloat widthPerItem = frame.size.width / (CGFloat)[[self items] count];
	CGFloat x = 0.0f;
	CGFloat y = 3.0f;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	
	//draw 2 pixel gray line below 1 pixel of background
	[[UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f] set];
	UIRectFill(CGRectMake(0, 1, frame.size.width, 1));
	
	//apply tint
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 0.5 };
	CGFloat components[8] = {  0.176, 0.176, 0.176, 1.0, 0.078, 0.078, 0.078, 1.0 };
	
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = 0.0f;
	myStartPoint.y = y;
	myEndPoint.x = 0.0f;
	myEndPoint.y = (frame.size.height - y) / 2.0f + frame.size.height * 0.05f;
	CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
	
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);

	//draw items
	for(UITabBarItem *barItem in [self items])
	{
		UIImage *image = [barItem image];
		NSString *text = [barItem title];
		CGSize imageSize = CGSizeMake(32.0f, 32.0f);
		
		if(barItem == selectedItem_)
		{
			image = [self _tabBarImage:image withGradient:selectedImageMask_];
			
			//draw rounded selection rectangle
			CGMutablePathRef retPath = CGPathCreateMutable();
			
			CGFloat radius = 4.0f;
			CGRect rect = CGRectMake(x + 2.0f, y + 1.0f, widthPerItem - 3.0f, frame.size.height - y - 1.0f);
			CGRect innerRect = CGRectInset(rect, radius, radius);
			
			CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
			CGFloat outside_right = rect.origin.x + rect.size.width;
			CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
			CGFloat outside_bottom = rect.origin.y + rect.size.height;
			
			CGFloat inside_top = innerRect.origin.y;
			CGFloat outside_top = rect.origin.y;
			CGFloat outside_left = rect.origin.x;
			
			CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
			
			CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
			CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
			CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
			CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
			
			CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
			CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
			CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
			CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
			
			CGPathCloseSubpath(retPath);
			
			[[UIColor colorWithRed:0.52f green:0.52f blue:0.52f alpha:0.2f] set];
			CGContextAddPath(context, retPath);
			CGContextFillPath(context);
			
			CGPathRelease(retPath);
		}
		else
			image = [self _tabBarImage:image withGradient:unselectedImageMask_];
		
		CGPoint imagePosition = CGPointMake(x + (widthPerItem - 32.0f)/2.0f, 3+(cTabBarHeight - imageSize.height - y) / 2.0f - imageSize.height*0.2f);

		//turn on shadows if this is the selected item
		if(barItem == selectedItem_)
			CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 3, [[UIColor blackColor] CGColor]);

		[image drawInRect:CGRectMake(imagePosition.x, imagePosition.y, 32.0f, 32.0f)
                blendMode:kCGBlendModeNormal alpha:1.0f];
              //drawAtPoint:imagePosition blendMode:kCGBlendModeNormal alpha:1.0f];

		if(barItem == selectedItem_)
			[[UIColor whiteColor] set];
		else
			[[UIColor grayColor] set];

		[text drawInRect:CGRectMake(x, cTabBarHeight - 14.0f, widthPerItem, 14.0f) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
		
		//turn off shadows if we were drawing the selected item
		if(barItem == selectedItem_)
			CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
		
		x += widthPerItem;
	}
	
	UIGraphicsPopContext();
}

#pragma mark -
#pragma mark TATabBar (PrivateMethods)

- (void)_handleTap:(UIGestureRecognizer *)gestureRecognizer
{
	if(([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [gestureRecognizer state] == UIGestureRecognizerStateBegan) ||
	   ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [gestureRecognizer state] == UIGestureRecognizerStateEnded))
	{
		CGPoint location = [gestureRecognizer locationInView:self];
		CGRect frame = [self frame];
		CGFloat widthPerItem = frame.size.width / (CGFloat)[[self items] count];
		NSUInteger itemIndex = floor(location.x / widthPerItem);
		
		if([items_ count] == 0)
			return;
		
		[self setSelectedItem:[items_ objectAtIndex:itemIndex]];
	}
}

- (UIImage*)_tabBarImage:(UIImage*)tabBarImage withGradient:(UIImage*)gradientImage
{
	CGSize size = CGSizeMake(tabBarImage.size.width, tabBarImage.size.height);
	CGRect bounds = CGRectMake(0, 0, size.width, size.height);
	CGFloat scale = [tabBarImage scale];

	//invert colors for tab bar image (at the same time removes the alpha channel thats not supported by image masks)
	UIGraphicsBeginImageContextWithOptions(size, NO, scale);
	CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
	[tabBarImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
	CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeDifference);
	CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(),[UIColor whiteColor].CGColor);
	CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
	tabBarImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//clip the background image to size of the tab bar icon image
	UIGraphicsBeginImageContextWithOptions(size, YES, scale);
	[gradientImage drawAtPoint:CGPointMake(( size.width - gradientImage.size.width) / 2, ( size.height - gradientImage.size.height ) / 2)];
	UIImage* backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	//convert image mask to grayscale
	CGColorSpaceRef grayscaleColorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
													   size.width*scale,
													   size.height*scale,
													   8,
													   8 * size.width * scale,
													   grayscaleColorSpace,
													   0
													   );
	
	CGRect scaledBounds = CGRectApplyAffineTransform(bounds, CGAffineTransformMakeScale(scale, scale));
	CGContextDrawImage(bitmapContext, scaledBounds, tabBarImage.CGImage);
	CGImageRef maskImageRef = CGBitmapContextCreateImage(bitmapContext);
	
	UIImage *maskImage = [UIImage imageWithCGImage:maskImageRef];
	
	CGContextRelease(bitmapContext);
	CGImageRelease(maskImageRef);
	CGColorSpaceRelease(grayscaleColorSpace);

	//apply image mask
	CGImageRef maskRef = maskImage.CGImage; 
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, true);

	CGImageRef masked = CGImageCreateWithMask([backgroundImage CGImage], mask);
	
	maskImage = [UIImage imageWithCGImage:masked scale:scale orientation:UIImageOrientationUp];
	
	CGImageRelease(mask);
	CGImageRelease(masked);
	
	return maskImage;
}

- (void)_fireDidSelectItem
{
	SEL selector = @selector(taTabBar:didSelectItem:);
	if(delegate != nil && [delegate conformsToProtocol:@protocol(TATabBarDelegate)] &&
	   [delegate respondsToSelector:selector])
	{
		[delegate taTabBar:self didSelectItem:selectedItem_];
	}
}

@end
