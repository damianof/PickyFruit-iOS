//
//  QueryCallback.h
//  TestBox2D
//
//  Created by Damiano Fusco on 4/1/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"


class QueryCallback : public b2QueryCallback
{
public:
    QueryCallback(const b2Vec2& p)
    {
        point = p;
        body = nil;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        if (fixture->IsSensor()) return true; //ignore sensors
        
        bool inside = fixture->TestPoint(point);
        if (inside)
        {
            // We are done, terminate the query.
            fixture = fixture;
            body = fixture->GetBody();
            return false;
        }
        
        // Continue the query.
        return true;
    }
    
    b2Vec2  point;
    b2Body* body;
    b2Fixture* fixture;
};
