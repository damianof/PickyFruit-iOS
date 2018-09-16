//
//  ContactListener.h
//  TestBox2D
//
//  Created by Damiano Fusco on 3/30/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>
#import "Box2D.h"

#import "ChainRingNode.h"
#import "FruitNode.h"

//@class ChainRingNode;
//@class FruitNode;

struct MyContact 
{
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
        
    bool operator==(const MyContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};


class ContactListener : public b2ContactListener
{

public:
    std::vector<MyContact>_contacts;
    
	//void BeginContact(b2Contact* contact);
	//void EndContact(b2Contact* contact);
    
    ContactListener();
    ~ContactListener();
    
    virtual void BeginContact(b2Contact* contact);
    virtual void EndContact(b2Contact* contact);
    virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
    virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
};