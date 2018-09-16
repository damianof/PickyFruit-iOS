//
//  ContactConduit.mm
//
//  Created by Damiano Fusco on 4/16/11.
//  Copyright 2011 Shallow Waters Group LLC. All rights reserved.
//

#import "ContactConduit.h"


ContactConduit::ContactConduit(id<ContactListenizer> listenizer)
{
	// save the physics listener
	listener = listenizer;
}

void ContactConduit::BeginContact(b2Contact* contact)
{
	// extract the bodynodes from the contact
    b2Fixture *f1 = contact->GetFixtureA();
    b2Fixture *f2 = contact->GetFixtureB();
	BodyNodeWithSprite *bn1 = (BodyNodeWithSprite *)f1->GetBody()->GetUserData();
	BodyNodeWithSprite *bn2 = (BodyNodeWithSprite *)f2->GetBody()->GetUserData();
    
    if(bn1.collisionCheckOn || bn2.collisionCheckOn || !bn1 || !bn2)
	{
        // notify the physics sprites
        if(bn1.collisionCheckOn || !bn2){
            [bn1 onOverlapBody:bn2 fixt:f2];
        }
        if(bn2.collisionCheckOn || !bn1){ 
            [bn2 onOverlapBody:bn1 fixt:f1];
        }
	
        // notify the physics listener
        [listener onOverlapBody:bn1 andBody:bn2];
    }
}

void ContactConduit::EndContact(b2Contact* contact)
{
	// extract the bodynodes from the contact
	b2Fixture *f1 = contact->GetFixtureA();
    b2Fixture *f2 = contact->GetFixtureB();
	BodyNodeWithSprite *bn1 = (BodyNodeWithSprite *)f1->GetBody()->GetUserData();
	BodyNodeWithSprite *bn2 = (BodyNodeWithSprite *)f2->GetBody()->GetUserData();
    
	if(bn1.collisionCheckOn || bn2.collisionCheckOn || !bn1 || !bn2)
	{
        // notify the physics sprites
        if(bn1.collisionCheckOn || !bn2)    
            [bn1 onSeparateBody:bn2 fixt:f2];
        if(bn2.collisionCheckOn || !bn1)    
            [bn2 onSeparateBody:bn1 fixt:f2];
	
        // notify the physics listener;
        [listener onSeparateBody:bn1 andBody:bn2];
    }
}

void ContactConduit::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
	// extract the bodynodes from the contact
	b2Fixture *f1 = contact->GetFixtureA();
    b2Fixture *f2 = contact->GetFixtureB();
	BodyNodeWithSprite *bn1 = (BodyNodeWithSprite *)f1->GetBody()->GetUserData();
	BodyNodeWithSprite *bn2 = (BodyNodeWithSprite *)f2->GetBody()->GetUserData();
    
    if(bn1.collisionCheckOn || bn2.collisionCheckOn)
	{
        // get the forces involved
        float force = 0.0f;
        float frictionForce = 0.0f;
        
        // for each contact point
        for (int i = 0; i < b2_maxManifoldPoints; i++)
        {
            // add the impulse to the total force
            force += impulse->normalImpulses[i];
            frictionForce += impulse->tangentImpulses[i];
        }
        
        // adjust the force units
        float ptmRatio = [DevicePositionHelper pixelsToMeterRatio];
        force *= ptmRatio / 1000; // GTKG_RATIO is 1000
        frictionForce *= ptmRatio / 1000; // GTKG_RATIO is 1000
        
        // notify the physics sprites
        if(bn1.collisionCheckOn)    
            [bn1 onCollideBody:bn2 fixt:f2 withForce:force withFrictionForce:frictionForce];
        if(bn2.collisionCheckOn)    
            [bn2 onCollideBody:bn1 fixt:f1 withForce:force withFrictionForce:frictionForce];
        
        // notify the physics listener
        [listener onCollideBody:bn1 andBody:bn2 withForce:force withFrictionForce:frictionForce];
    }
}

