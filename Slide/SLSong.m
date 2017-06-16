//
//  SLSong.m
//  Slide
//
//  Created by Rooz Mahdavian on 5/26/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import "SLSong.h"

@implementation SLSong

+(SLSong *)songWithTitle:(NSString *)title
                  artist:(NSString *)artist
                   album:(NSString *)album
                 artwork:(UIImage *)artwork
                duration:(NSTimeInterval)duration {
    SLSong *song = [SLSong new];
    song.title = title;
    song.artist = artist;
    song.album = album;
    song.artwork = artwork;
    song.duration = duration;
    return song;
}

@end
