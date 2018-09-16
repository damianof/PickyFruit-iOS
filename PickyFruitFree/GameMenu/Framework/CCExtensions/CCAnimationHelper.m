#import "CCAnimationHelper.h"


@implementation CCAnimation (Helper)


// Creates an animation from sprite frames.
+(CCAnimation*) animationWithFrame:(NSString*)frameBaseName 
                        frameStart:(int)frameStart 
                          frameEnd:(int)frameEnd 
                             delay:(float)delay
                         direction:(int)d
{
	CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    // load the animation frames as textures and create a sprite frame
    int frameCount = frameEnd - frameStart;
	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:frameCount];
    if(d == 1)
    {
        // forward: 0,1,2 etc
        for (int i = frameStart; i <= frameEnd; i++)
        {
            // use local pool to avoid stringWithFormat leaks in loop
            //NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
            CCSpriteFrame *frame = [frameCache spriteFrameByName:[NSString stringWithFormat:kStringFormatAnimationFrameName, frameBaseName, i]];
            [frames addObject:frame];
            // drain local pool 
            //[loopPool drain];
        }
    }
    else
    {
        // reverse: 9,8,7 etc
        for (int i = frameEnd; i >= frameStart; i--)
        {
            // use local pool to avoid stringWithFormat leaks in loop
            //NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
            CCSpriteFrame *frame = [frameCache spriteFrameByName:[NSString stringWithFormat:kStringFormatAnimationFrameName, frameBaseName, i]];
            [frames addObject:frame];// drain local pool 
            //[loopPool drain];
        }      
    }
	
	// return an animation object from all the sprite animation frames
	//return [CCAnimation animationWithName:frame delay:delay frames:frames];
    return [CCAnimation animationWithFrames:frames delay:delay];
}

@end
