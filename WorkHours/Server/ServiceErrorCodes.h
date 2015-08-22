//
//  ServiceErrorCodes.h
//  WalkItOff
//
//  Created by Donald Pae on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#ifndef ServiceErrorCodes_h
#define ServiceErrorCodes_h

#define ServiceSuccess  0

NS_ENUM(NSInteger, ServiceErrorCode) {
    ServiceErrorNetwork = 1,
    ServiceErrorNoResponse
};

#endif
