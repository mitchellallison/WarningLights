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
        if (transitionTime)
        {
            // Prevents the operation from completing until the transition has occured succesfully.
            self.timer = [NSTimer timerWithTimeInterval:roundf(([transitionTime floatValue] * kTransitionTimeFactor)) target:self selector:@selector(finish) userInfo:nil repeats:NO];
        }
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
        [self.delegate hueStateDidChangeWithDictionary:results];
    }
    else
    {
        [self.delegate errorConnectingToBridge];
    }

    if (self.timer)
    {
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
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
