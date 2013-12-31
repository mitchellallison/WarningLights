//
//  HueStateChangeOperation.m
//  WarningLightsXcodePlugin
//
//  Created by Mitchell Allison.
//
//

#import "HueStateChangeOperation.h"
#import "HueConstants.h"
#import "HueLight.h"

@interface HueStateChangeOperation () <NSURLConnectionDataDelegate>

@property (strong) NSMutableURLRequest *request;
@property (strong) NSMutableData *responseData;
@property (assign) BOOL isFinished;
@property (assign) BOOL isExecuting;
@property (strong) NSURLConnection *connection;
@property (strong) NSTimer *timer;
@property (strong) NSNumber *transitionTime;

@end

@implementation HueStateChangeOperation

- (instancetype)initWithURL:(NSURL *)url state:(NSDictionary *)dictionary delegate:(id)delegate
{
    if (self = [super init])
    {
        NSError *error = nil;
        self.request = [NSMutableURLRequest requestWithURL:url];
        [self.request setHTTPMethod:@"PUT"];
        [self.request setHTTPBody:[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error]];
        self.delegate = delegate;
        NSNumber* transitionTime = [dictionary objectForKey:transitionTimeKey];
        self.transitionTime = transitionTime;
    }
    return self;
}

- (void)start
{
    if (![NSThread isMainThread])
    {
        // NSURLConnection methods do not fire if not on main thread.
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // KVO for superclass
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = NO;
    [self didChangeValueForKey:@"isFinished"];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection start];
}

- (void)finish
{
    // KVO for superclass
    [self willChangeValueForKey:@"isExecuting"];
    self.isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.isFinished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.responseData)
    {
        [self.responseData appendData:data];
    }
    else
    {
        self.responseData = [[NSMutableData alloc] initWithData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    if (!error && self.responseData)
    {
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
        NSLog(@"results: %@", results);
        [self.delegate hueStateDidChangeWithDictionary:results];
    }
    else
    {
        [self.delegate errorConnectingToBridge];
    }

    if (self.transitionTime)
    {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((NSTimeInterval)roundf(([self.transitionTime floatValue] * kTransitionTimeFactor)) * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self finish];
        });
    }
    else
    {
        [self finish];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate errorConnectingToBridge];
}


@end
