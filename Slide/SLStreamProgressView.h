//
//  SLStreamProgressView.h
//  Slide
//
//  Created by Rooz Mahdavian on 5/29/17.
//  Copyright © 2017 Rooz Mahdavian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLStream.h"

@class SLStreamProgressView;

@protocol SLStreamProgressManager <NSObject>

-(void)progressView:(SLStreamProgressView *)progressView changedElapsed:(NSTimeInterval)elapsed;
-(void)progressViewDidFinish:(SLStreamProgressView *)progressView;

-(void)progressViewWillBeginInteraction:(SLStreamProgressView *)progressView;
-(void)progressViewWillEndInteraction:(SLStreamProgressView *)progressView;

@end

@interface SLStreamProgressView : UIControl

@property (nonatomic, weak) id<SLStreamProgressManager> delegate;
@property (nonatomic) SLSong *song;
@property (nonatomic, readonly) NSTimeInterval elapsed;
@property (nonatomic) UIColor *tintColor;
@property (nonatomic) CGFloat size;

-(void)updateElapsed:(NSTimeInterval)elapsed;

@end
