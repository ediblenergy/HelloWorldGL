//
//  AppDelegate.h
//  HelloWorldGL
//
//  Created by SamK on 8/8/13.
//  Copyright (c) 2013 Samuel Kaufman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    OpenGLView *_glView;
}
@property (nonatomic, retain) IBOutlet OpenGLView *glView;




@property (strong, nonatomic) UIWindow *window;

@end
