//
//  CCDefine.h
//  kidpower
//
//  Created by Donald Pae on 4/12/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#ifndef CCDefine_h
#define CCDefine_h

#ifdef DEBUG
    #ifndef CCLog
        #define CCLog     NSLog
    #else
    #endif

    #ifndef CCLogForStatic
        #define CCLogForStatic(tag, format, ...)     NSLog(@"%@: %@", tag, [NSString stringWithFormat: format, ##__VA_ARGS__])
    #endif

#else
    #define CCLog
    #define CCLogForStatic
#endif

#ifndef DEFINE_SINGLETON
#define DEFINE_SINGLETON        + (instancetype)sharedInstance;
#endif


#ifndef IMPLEMENT_SINGLETON     
#define IMPLEMENT_SINGLETON         + (instancetype)sharedInstance \
                                    { \
                                        static dispatch_once_t once; \
                                        static id sharedInstance; \
                                        dispatch_once(&once, ^ \
                                                      { \
                                                          sharedInstance = [self new]; \
                                                      }); \
                                        return sharedInstance; \
                                    }
#endif


#endif
