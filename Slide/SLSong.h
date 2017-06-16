//
//  SLSong.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/26/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SLSong;

@protocol SLSongManager <NSObject>

- (void)songUpdated:(SLSong *)song;

@end

@interface SLSong : NSObject

@property (nonatomic, weak) id<SLSongManager> delegate;

// stream
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSURL *URI;
@property (nonatomic) NSUInteger upvotes;
@property (nonatomic) NSURL *largeArtworkURI;
@property (nonatomic) NSURL *smallArtworkURI;

// meta
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *album;
@property (nonatomic) UIImage *artwork;
@property (nonatomic) UIImage *thumbnail;
@property (nonatomic) NSTimeInterval duration;

+(SLSong *)songWithTitle:(NSString *)title
                  artist:(NSString *)artist
                   album:(NSString *)album
                 artwork:(UIImage *)artwork
                duration:(NSTimeInterval)duration;

@end
