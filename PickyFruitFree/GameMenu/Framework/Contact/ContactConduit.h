//
//  ContactConduit.h
//  GameMenu
//
//  Created by Damiano Fusco on 4/16/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "ContactListenizer.h"
#import "DevicePositionHelper.h"


class ContactConduit : public b2ContactListener
{
public:
    ContactConduit(id<ContactListenizer> listenizer);
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
	
	id<ContactListenizer> listener;
};
