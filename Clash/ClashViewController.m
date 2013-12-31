//
//  ClashViewController.m
//  Clash
//
//  Created by 金谷 一朗 on 11/09/06.
//  Copyright (c) 2011 大阪大学. All rights reserved.
//

#import "ClashViewController.h"

@implementation ClashViewController

#define defaultViewRatio 0.1
#define defaultViewSizeX 1000.0
#define defalutViewSizeY 250.0
#define viewAspectRatio (defaultViewSizeX / defalutViewSizeY)


- (CGFloat) mmToPix: (CGFloat)x {
	NSRect currentViewFrame = [view frame];
	CGFloat currentViewSizeX = currentViewFrame.size.width;
	CGFloat currentViewSizeY = currentViewFrame.size.height;
	CGFloat currentViewSizeYMultipliedByAspectRatio = currentViewSizeY * viewAspectRatio;
	CGFloat viewRatio;
	if (currentViewSizeX >= currentViewSizeYMultipliedByAspectRatio) {
		viewRatio = defaultViewRatio * currentViewSizeY / defalutViewSizeY;
	}
	else {
		viewRatio = defaultViewRatio * currentViewSizeX / defaultViewSizeX;
	}
	return x * viewRatio;
}


- (id)init {
	self = [super init];
	if (self) {
		// Initialization code here.
		backgroundLayer = [[CALayer alloc] init];
		CGColorRef blackColor = CGColorCreateGenericGray(0, 1);
		backgroundLayer.backgroundColor = blackColor;
		CGColorRelease(blackColor);
		layers = nil;
	}
	return self;
}


- (void)awakeFromNib {	
	[view setLayer: backgroundLayer];
	[view setWantsLayer: YES];
}


- (IBAction)go: (id)sender {
	if (layers) {
		for (NSString *ident in layers) {
			CALayer *layer = [layers objectForKey: ident];
			[layer removeFromSuperlayer];
			layer = nil;
		}
		layers = nil;
	}
	layers = [NSMutableDictionary dictionaryWithCapacity: 100];
	
	// Verify given URL.
	NSString *address = [addressField stringValue];
	if ([address isEqualToString: @""]) {
		if ([eventMode state] == NSOnState) {
			address = @"http://localhost:8080/?time=now&person=1";
		}
		else {
			address = @"http://localhost:8080/?time=now";
		}
	}
	NSURL *url = [NSURL URLWithString: address];
	
	// Download XML.
	NSError *error;
	NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL: url
																																		options: 0
																																			error: &error];
	if (error) {
		NSLog(@"Error -> %@", [error localizedDescription]);
	}
		
	// Parse XML.
	NSXMLElement *rootElement = [xmlDocument rootElement];
	NSArray *frameElements = [rootElement elementsForName: @"frame"];
	NSXMLElement *frameElement = [frameElements objectAtIndex: 0];
	NSArray *imageElements = [frameElement elementsForName: @"image"];
	for (NSXMLElement *imageElement in imageElements) {
		// NSString *text = [imageElement stringValue];
		NSXMLNode *source = [imageElement attributeForName: @"source"];  // source must be a valid URL
		NSXMLNode *ident = [imageElement attributeForName: @"id"];
		NSXMLNode *position_x = [imageElement attributeForName: @"position_x"];
		NSXMLNode *position_y = [imageElement attributeForName: @"position_y"];
		NSXMLNode *size_x = [imageElement attributeForName: @"size_x"];
		NSXMLNode *size_y = [imageElement attributeForName: @"size_y"];
		NSXMLNode *alpha = [imageElement attributeForName: @"alpha"];
		// Download the image
		NSURL *bitmapImageURL = [NSURL URLWithString: [source stringValue]];
		NSBitmapImageRep *bitmapImage 
			= [NSBitmapImageRep imageRepWithContentsOfURL: bitmapImageURL];
		CGFloat positionX = [self mmToPix: [[position_x stringValue] floatValue]];
		CGFloat positionY = [self mmToPix: [[position_y stringValue] floatValue]];
		CGFloat sizeX = [self mmToPix: [[size_x stringValue] floatValue]];
		CGFloat sizeY = [self mmToPix: [[size_y stringValue] floatValue]]; 
		CGFloat alphaValue = [[alpha stringValue] floatValue];
		if (bitmapImage) {
			// Create a layer and set the image to the layer
			CGImageRef image = [bitmapImage CGImage];
			CALayer *layerToAdd = [CALayer layer];
			layerToAdd.contents = (id)CFBridgingRelease(image);  // ARC ready
			layerToAdd.frame = CGRectMake(positionX, positionY, sizeX, sizeY);
			layerToAdd.opacity = alphaValue;
			// must set up geometry and transformation and color etc.
			// Insert the layer to the view
			layerToAdd.hidden = NO;
			[backgroundLayer addSublayer: layerToAdd];
			// Register to the layer dictionary
			NSString *idString = [ident stringValue];
			[layers setObject: layerToAdd forKey: idString];
		}		
	}
}


- (IBAction)autoRun:(id)sender {
	if ([autoRunMode state] == NSOnState) {
		if (timer) {
			timer = nil;
		}
		timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 / 12.0
																						 target: self
																					 selector: @selector(fire:)
																					 userInfo: nil 
																						repeats: YES];
	}
	else {
		if (timer) {
			[timer invalidate];
			timer = nil;
		}
	}
}

- (void)fire: (id)userInfo {
	[self go: self];
}

@end
