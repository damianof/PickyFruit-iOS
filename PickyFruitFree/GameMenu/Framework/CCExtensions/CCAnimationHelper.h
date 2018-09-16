#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface CCAnimation (Helper)


+(CCAnimation*) animationWithFrame:(NSString*)frameBaseName 
                        frameStart:(int)frameStart 
                          frameEnd:(int)frameEnd 
                             delay:(float)delay
                         direction:(int)d;

@end
