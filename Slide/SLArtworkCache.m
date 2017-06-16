//
//  SLArtworkCache.m
//  Slide
//
//  Created by Rooz Mahdavian on 6/11/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLArtworkCache.h"

@interface SLArtworkCache () {
}

@property (nonatomic, strong) NSURLSession *network;

@end

@implementation SLArtworkCache

+(instancetype)sharedInstance {
    static SLArtworkCache *sharedArtworkCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedArtworkCache = [self new];
    });
    return sharedArtworkCache;
}

-(instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.network = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

-(void)loadArtwork:(SLSong *)song size:(SLArtworkSize)size completion:(SLLoadArtworkCallback)completion {
    NSURL *resource = (size == SLArtworkLarge)? song.largeArtworkURI : song.smallArtworkURI;
    if (resource != nil) {
        // NSLog(@"Starting to load %@ artwork at %@", song.title, resource.absoluteString);
        [[self.network dataTaskWithURL:resource
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        // NSLog(@"Finished loading %@ artwork at %@", song.title, resource.absoluteString);
                        UIImage *artwork = [UIImage imageWithData:data];
                        dispatch_async(dispatch_get_main_queue(), ^{
                           completion(artwork);
                        });
                    }] resume];
    } else NSLog(@"ERROR: No link provided for artwork");
}

@end
