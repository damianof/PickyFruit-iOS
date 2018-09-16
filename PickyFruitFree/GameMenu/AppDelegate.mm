//
//  AppDelegate.m
//  GameMenu
//
//  Created by Damiano Fusco on 4/9/11.
//  Copyright Shallow Waters Group LLC 2011. All rights reserved.
//

#import "AppDelegate.h"
#import "GameManager.h"
#import "RootViewController.h"
#import "LoadingScene.h"
#import "GameMenuPlayLayer.h"
#import "SimpleAudioEngine.h"


@implementation AppDelegate


@synthesize window,
    debugDrawEnabled = _debugDrawEnabled;

+(AppDelegate *)sharedDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

extern "C" CGImageRef UIGetScreenImage(void);

inline CGImageRef CreateCGImageWithContentsOfScreen(void) {
	return UIGetScreenImage(); /* already retained, so be sure to do a CGImageRelease() on the returned image later. */
}

- (void)removeStartupFlicker:(EAGLView *)glView
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	
    CC_ENABLE_DEFAULT_GL_STATES();
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCSprite *sprite = [[CCSprite alloc] initWithFile:@"Default.png"];
    sprite.position = ccp(size.width*0.5f, size.height*0.5f);
    sprite.rotation = -90;
    [sprite visit];
    [glView swapBuffers];
    CC_ENABLE_DEFAULT_GL_STATES();
    [sprite release];
    sprite = nil;
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444]; // add this line at the very beginning
	
//#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
    {
		//CCLOG(@"AppDelegate: setting CCDirector type to kCCDirectorTypeMainLoop");
        [CCDirector setDirectorType:kCCDirectorTypeMainLoop];
	}
	
	CCDirector *director = [CCDirector sharedDirector];
    
    // Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565 (kCCTexture2DPixelFormat_RGBA8888)
	// You can change anytime.
    
    // start with 8888 and then switch to 4444 at the end of removeStartupFlicker
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888]; 
	//[CCTexture2D setDepthBufferFormat:16];
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
	// Init the View Controller
	_viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	_viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT16_OES	// GL_DEPTH_COMPONENT16_OES
						];
    
    // set multiple touch (multi touch) enable on the window
    // make sure these are set before [director setOpenGLView] or [director attachInView: window]
    //[window setMultipleTouchEnabled:true];
	[glView setMultipleTouchEnabled:true];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    if( ! [director enableRetinaDisplay:YES] )
    {
		//CCLOG(@"Retina Display Not supported");
    }
    //else
    //{
    //	CCLOG(@"AppDelegate: enabling Retina Display");
    //}
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeRight];
#endif
	
	[director setAnimationInterval:kFloat1Over60]; // kFloat0Point02 = 1.0/50.0f
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[_viewController setView:glView];
	
	// make the View Controller a child of the main window
	[_window addSubview: _viewController.view];
	[_window makeKeyAndVisible];
    
    // Must add the root view controller for GameKitHelper to work!
	window.rootViewController = _viewController;
    
    // audio 
    // Play the background music in an endless loop.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:kUserDefaultsKeyMusicOn]) {
        [defaults setBool:YES forKey:kUserDefaultsKeyMusicOn];
	}
	if (![defaults objectForKey:kUserDefaultsKeySoundsOn]) {
        [defaults setBool:YES forKey:kUserDefaultsKeySoundsOn];
	}
	[defaults synchronize];
    
    // Preload the music and sound effects into memory so there's no delay when playing it the first time.
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"DFMichaelTheBird.mp3" loop:YES];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxLevelFailed];
    //[[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxLevelPassed];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxImprovedScore];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxSpinner];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxCounter];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxFruitFalling];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxFruitSmash];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kSoundEfxBugSquish];
    
    bool musicOn = [defaults boolForKey:kUserDefaultsKeyMusicOn];
    bool soundsOn = [defaults boolForKey:kUserDefaultsKeySoundsOn];
    [[SimpleAudioEngine sharedEngine] setMusicOn:musicOn];
    [[SimpleAudioEngine sharedEngine] setSoundsOn:soundsOn];
    defaults = nil;
    
    // Removes the startup flicker
    //[director setProjection:CCDirectorProjection2D];
    [director setDepthTest:NO];
	[self removeStartupFlicker:glView];
    
    ////[GameManager setAllLevelsUnlocked:true];
    
    // set GameKitHelper delegate to GameManager
    [[GameKitHelper sharedInstance] setDelegate:[GameManager sharedInstance]];
    [[GameKitHelper sharedInstance] authenticateLocalPlayer];
    
    // Run the intro Scene ( cannot use scene helper here)
	//GameMenuScene *scene = [LoadingScene sceneWithTargetScene:TargetSceneMenu
    //                                           andTargetLayer:TargetLayerMenuPlay]; //TargetLayerMenuPlay, TargetLayerMenuTest
    [director runWithScene:[GameMenuScene sceneWithTargetLayer:TargetLayerMenuPlay]];
}


- (void)applicationWillResignActive:(UIApplication *)application 
{
    //[[CCDirector sharedDirector] drainPool];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    // removes all textures... only use when you receive a memory warning signal
	[[CCDirector sharedDirector] purgeCachedData];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	CCDirector *director = [CCDirector sharedDirector];
    [director pause];
    [director stopAnimation];
	[[director openGLView] removeFromSuperview];
	
	[_viewController release];
	_viewController = nil;
	[_window release];
    _window = nil;
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application 
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc 
{
    CCLOG(@"AppDelegate dealloc");
    
    // Call clean up on sharedGameManager
    [GameManager cleanup];
    
	[[CCDirector sharedDirector] release]; 
    
	[_viewController release];
	_viewController = nil;
	[_window release];
    _window = nil;
    
	[super dealloc];
}

@end
