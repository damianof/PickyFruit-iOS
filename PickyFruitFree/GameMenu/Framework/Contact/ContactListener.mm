//
//  ContactListener.mm
//
//  Created by Damiano Fusco on 3/30/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ContactListener.h"
#import "cocos2d.h"
#import "BodyNodeWithSprite.h"


ContactListener::ContactListener() : _contacts() 
{
}

ContactListener::~ContactListener() 
{
}

void ContactListener::BeginContact(b2Contact* contact) 
{
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(myContact);
}

void ContactListener::EndContact(b2Contact* contact) 
{
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) 
    {
        _contacts.erase(pos);
    }
}

void ContactListener::PreSolve(b2Contact* contact, 
                                 const b2Manifold* oldManifold) 
{
}

void ContactListener::PostSolve(b2Contact* contact, 
                                  const b2ContactImpulse* impulse) 
{
}

/*
void ContactListener::BeginContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
    if(bodyA && bodyB)
    {
        BodyNodeWithSprite* bodyNodeA = (BodyNodeWithSprite*)bodyA->GetUserData();
        BodyNodeWithSprite* bodyNodeB = (BodyNodeWithSprite*)bodyB->GetUserData();
        
        if (bodyNodeA != NULL && bodyNodeB != NULL)
        {
            if (bodyNodeA.sprite != NULL && bodyNodeB.sprite != NULL)
            {
                bodyNodeA.sprite.color = ccMAGENTA;
                bodyNodeB.sprite.color = ccYELLOW;
            }
        }
    }
}


void ContactListener::EndContact(b2Contact* contact)
{
	b2Body* bodyA = contact->GetFixtureA()->GetBody();
	b2Body* bodyB = contact->GetFixtureB()->GetBody();
	if(bodyA && bodyB)
    {
        BodyNodeWithSprite* bodyNodeA = (BodyNodeWithSprite*)bodyA->GetUserData();
        BodyNodeWithSprite* bodyNodeB = (BodyNodeWithSprite*)bodyB->GetUserData();
        
        if (bodyNodeA != NULL && bodyNodeB != NULL)
        {
            if (bodyNodeA.sprite != NULL && bodyNodeB.sprite != NULL)
            {
                bodyNodeA.sprite.color = ccWHITE;
                bodyNodeB.sprite.color = ccWHITE;
            }
            
            BodyNodeWithSprite *chainRing;
            if([bodyNodeA isKindOfClass:[ChainRingNode class]]
               && [bodyNodeB isKindOfClass:[ChainRingNode class]] == false)
            {
                chainRing = bodyNodeA;
            }
            else if([bodyNodeB isKindOfClass:[ChainRingNode class]]
                    && [bodyNodeA isKindOfClass:[ChainRingNode class]] == false)
            {
                chainRing = bodyNodeB;
            }
            
            if(chainRing)
            {
                CCLOG(@"ChainRingNode contacted with other node");
                [chainRing destroyBody];
            }
        }
    }
}*/
