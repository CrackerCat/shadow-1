#import "hooks.h"

%group shadowhook_libc
%hookf(int, access, const char *pathname, int mode) {
    NSArray* backtrace = [NSThread callStackSymbols];
    int result = %orig;

    if(result == 0 && pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return result;
}

%hookf(int, chdir, const char *pathname) {
    NSArray* backtrace = [NSThread callStackSymbols];
    int result = %orig;

    if(result == 0 && pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return result;
}

%hookf(int, chroot, const char *pathname) {
    NSArray* backtrace = [NSThread callStackSymbols];
    int result = %orig;

    if(result == 0 && pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return result;
}

%hookf(int, statfs, const char *pathname, struct statfs *buf) {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    int ret = %orig;

    if(ret == 0 && pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }

        // Modify flags
        if(buf) {
            if([path hasPrefix:@"/var"]
            || [path hasPrefix:@"/private/var"]) {
                buf->f_flags |= MNT_NOSUID | MNT_NODEV;
            } else {
                buf->f_flags |= MNT_RDONLY | MNT_ROOTFS;
            }
        }
    }

    return ret;
}

%hookf(int, stat, const char *pathname, struct stat *statbuf) {
    NSArray* backtrace = [NSThread callStackSymbols];

    struct stat st;
    int result = %orig(pathname, &st);
    
    if(result == 0 && pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}

%hookf(int, lstat, const char *pathname, struct stat *statbuf) {
    NSArray* backtrace = [NSThread callStackSymbols];

    struct stat st;
    int result = %orig(pathname, &st);

    if(result == 0 && pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}

%hookf(FILE *, fopen, const char *pathname, const char *mode) {
    NSArray* backtrace = [NSThread callStackSymbols];

    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return NULL;
        }
    }

    return %orig;
}

%hookf(FILE *, freopen, const char *pathname, const char *mode, FILE *stream) {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return NULL;
        }
    }

    return %orig;
}

%hookf(char *, getenv, const char *name) {
    if(name) {
        NSString *env = [NSString stringWithUTF8String:name];

        if([env isEqualToString:@"DYLD_INSERT_LIBRARIES"]
        || [env isEqualToString:@"_MSSafeMode"]
        || [env isEqualToString:@"_SafeMode"]
        || [env isEqualToString:@"SHELL"]) {
            return NULL;
        }
        /*
        if([env isEqualToString:@"SIMULATOR_MODEL_IDENTIFIER"]) {
            struct utsname systemInfo;
            uname(&systemInfo);

            return (char *)[@(systemInfo.machine) UTF8String];
        }
        */
    }

    return %orig;
}

%hookf(char *, realpath, const char *pathname, char *resolved_path) {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return NULL;
        }
    }

    return %orig;
}

%hookf(ssize_t, readlink, const char* pathname, char* buf, size_t bufsize) {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}

%hookf(DIR *, opendir, const char *pathname) {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return NULL;
        }
    }

    return %orig;
}

%hookf(DIR *, __opendir2, const char *pathname, size_t bufsize) {
    NSArray* backtrace = [NSThread callStackSymbols];

    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return NULL;
        }
    }

    return %orig;
}

// %hookf(int, fstat, int fd, struct stat *buf) {
//     char fdpath[PATH_MAX];

//     if(fcntl(fd, F_GETPATH, fdpath) != -1) {
//         NSString *fd_path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:fdpath length:strlen(fdpath)];

//         if([_shadow isPathRestricted:fd_path]) {
//             errno = EBADF;
//             return -1;
//         }
//     }

//     return %orig;
// }

// %hookf(int, open, const char *pathname, int oflag, ...) {
//     if(pathname) {
//         NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

//         if([_shadow isPathRestricted:path]) {
//             errno = ENOENT;
//             return -1;
//         }
//     }

//     if(oflag & O_CREAT) {
//         mode_t mode;
//         va_list args;
//         va_start(args, oflag);
//         mode = (mode_t) va_arg(args, int);
//         va_end(args);

//         return %orig(pathname, oflag, mode);
//     }

//     return %orig(pathname, oflag);
// }

%hookf(int, csops, pid_t pid, unsigned int ops, void *useraddr, size_t usersize) {
    int ret = %orig;

    if(ops == CS_OPS_STATUS && (ret & CS_PLATFORM_BINARY) == CS_PLATFORM_BINARY && pid == getpid()) {
        // Ensure that the platform binary flag is not set.
        ret &= ~CS_PLATFORM_BINARY;
    }

    return ret;
}

%hookf(int, sysctl, int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if(namelen == 4
    && name[0] == CTL_KERN
    && name[1] == KERN_PROC
    && name[2] == KERN_PROC_ALL
    && name[3] == 0) {
        // Running process check.
        *oldlenp = 0;
        return 0;
    }

    int ret = %orig;

    if(ret == 0
    && name[0] == CTL_KERN
    && name[1] == KERN_PROC
    && name[2] == KERN_PROC_PID
    && name[3] == getpid()) {
        // Remove trace flag.
        if(oldp) {
            struct kinfo_proc *p = ((struct kinfo_proc *) oldp);

            if((p->kp_proc.p_flag & P_TRACED) == P_TRACED) {
                p->kp_proc.p_flag &= ~P_TRACED;
            }
        }
    }

    return ret;
}

%hookf(pid_t, getppid) {
    return 1;
}

%hookf(int, execve, const char *pathname, char *const argv[], char *const envp[]) {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}

%hookf(int, execvp, const char *pathname, char *const argv[]) {
    NSArray* backtrace = [NSThread callStackSymbols];
    
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}
%end

// static DIR* (*original_opendir2)(const char* pathname, size_t bufsize);
// static DIR* replaced_opendir2(const char* pathname, size_t bufsize) {
//     NSArray* backtrace = [NSThread callStackSymbols];
    
//     if(pathname) {
//         NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

//         if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
//             errno = ENOENT;
//             return NULL;
//         }
//     }

//     return original_opendir2(pathname, bufsize);
// }

static int (*original_open)(const char *pathname, int oflag, ...);
static int replaced_open(const char *pathname, int oflag, ...) {
    NSArray* backtrace = [NSThread callStackSymbols];

    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if([_shadow isPathRestricted:path] && ![_shadow isCallerTweak:backtrace]) {
            errno = ENOENT;
            return -1;
        }
    }

    if(oflag & O_CREAT) {
        mode_t mode;
        va_list args;
        va_start(args, oflag);
        mode = (mode_t) va_arg(args, int);
        va_end(args);

        return original_open(pathname, oflag, mode);
    }

    return original_open(pathname, oflag);
}
/*
static int (*original_syscall)(int number, ...);
static int replaced_syscall(int number, ...) {
    HBLogDebug(@"%@: %d", @"syscall", number);

    char* stack[8];
	va_list args;
	va_start(args, number);

    #if defined __arm64__ || defined __arm64e__
	memcpy(stack, args, 64);
    #endif

    #if defined __armv7__ || defined __armv7s__
	memcpy(stack, args, 32);
    #endif

    // Get pathname from arguments for later

    va_end(args);

    int result = original_syscall(number, stack[0], stack[1], stack[2], stack[3], stack[4], stack[5], stack[6], stack[7]);

    if(result == 0) {
        // Handle if syscall is successful
    }

    return result;
}
*/

void shadowhook_libc(void) {
    %init(shadowhook_libc);

    // Manual hooks
    MSHookFunction(open, replaced_open, (void **) &original_open);
    // MSHookFunction(syscall, replaced_syscall, (void **) &original_syscall);
    // MSHookFunction(__opendir2, replaced_opendir2, (void **) &original_opendir2);
}
