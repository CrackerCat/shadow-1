#import "hooks.h"

%group shadowhook_NSArray
%hook NSArray
- (id)initWithContentsOfFile:(NSString *)path {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfFile:(NSString *)path {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfURL:(NSURL *)url {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if([_shadow isURLRestricted:url] && ![_shadow isCallerTweak:backtrace]) {
        return nil;
    }

    return %orig;
}
%end

%hook NSMutableArray
- (id)initWithContentsOfFile:(NSString *)path {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
        return nil;
    }

    return %orig;
}

- (id)initWithContentsOfURL:(NSURL *)url {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if([_shadow isURLRestricted:url] && ![_shadow isCallerTweak:backtrace]) {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfFile:(NSString *)path {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfURL:(NSURL *)url {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if([_shadow isURLRestricted:url] && ![_shadow isCallerTweak:backtrace]) {
        return nil;
    }

    return %orig;
}
%end
%end

void shadowhook_NSArray(void) {
    %init(shadowhook_NSArray);
}
