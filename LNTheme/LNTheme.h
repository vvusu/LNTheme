//
//  LNTheme.h
//  LNTheme
//
//  Created by vvusu on 12/27/16.
//  Copyright © 2016 vvusu. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for LNTheme.
FOUNDATION_EXPORT double LNThemeVersionNumber;

//! Project version string for LNTheme.
FOUNDATION_EXPORT const unsigned char LNThemeVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LNTheme/PublicHeader.h>

#if __has_include(<LNTheme/LNTheme.h>)

#import <LNTheme/LNTheme.h>
#import <LNTheme/UIImage+Tint.h>
#import <LNTheme/LNThemePicker.h>
#import <LNTheme/NSObject+LNTheme.h>

#else

#import "LNTheme.h"
#import "UIImage+Tint.h"
#import "LNThemePicker.h"
#import "NSObject+LNTheme.h"

#endif
