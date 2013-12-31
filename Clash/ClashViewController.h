//
//  ClashViewController.h
//  Clash
//
//  Created by 金谷 一朗 on 11/09/06.
//  Copyright (c) 2011 大阪大学. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ClashViewController: NSObject {
	IBOutlet NSTextField *addressField;
	IBOutlet NSView *view;
	IBOutlet NSButton *goButton;
	IBOutlet NSButton *autoRunMode;
	IBOutlet NSButton *eventMode;
	CALayer *backgroundLayer;
	NSMutableDictionary *layers;
	NSTimer *timer;
}

- (IBAction)go: (id)sender;
- (IBAction)autoRun: (id)sender;

@end
