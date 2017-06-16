//
//  SLArtworkCache.h
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "SLStream.h"

typedef enum {
    SLArtworkSmall,
    SLArtworkLarge
} SLArtworkSize;

typedef void (^SLLoadArtworkCallback)(UIImage *artwork);

@interface SLArtworkCache : NSObject

+(instancetype)sharedInstance;
-(void)loadArtwork:(SLSong *)song size:(SLArtworkSize)size completion:(SLLoadArtworkCallback)completion;

@end
