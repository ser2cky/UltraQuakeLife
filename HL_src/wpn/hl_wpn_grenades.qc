//======================================
//
//	hl_wpn_grenades.qc
//	Every Half-Life grenade in 1 file..
//	Code referenced from HLSDK1.0 Code..
//
//	History:
//	11.16.25: Started. Contact grenade &
//	sparks.
//
//======================================

// void(float count, vector newangles, vector org) HL_CreateSparks = 
// {
	// for (float i = 0; i < count; i++)
	// {
		// entity spark;
		// spark = spawn();
		// spark.velocity_x = random() * 400 * crandom();
		// spark.velocity_y = random() * 400 * crandom();
		// spark.velocity_z = random() * 400;
		// spark.movetype = MOVETYPE_BOUNCE;
		// //spark.gravity = 0.5;
		// spark.nextthink = time + 0.1;
		// spark.solid = SOLID_BBOX;
		// setsize(spark, VEC_ORIGIN, VEC_ORIGIN);
		// setorigin(spark, org);
		// spark.angles = newangles;
		// spark.think = HL_SparkThink;
		// spark.touch = HL_SparkTouch;
	// }
// }

// void() HL_SparkThink =
// {
	// particle(self.origin, '0 0 -250', 111, 6);
	// self.nextthink = time + 0.01;
// }

// void() HL_SparkTouch =
// {
	// self.think = SUB_Remove;
	// self.nextthink = time;
// }

void() HL_ExplosionThink =
{
	if (self.frame != 13) 
	{
		self.think = HL_ExplosionThink;
		self.nextthink = time + 0.067;
		self.frame += 1;
	}
	else 
	{
		self.think = SUB_Remove;
		self.nextthink = time + 0.067;
	}
}

void() HL_GrenadeExplode =
{
	entity myowner;
	
	if (!self.owner)
		myowner = world;
	else
		myowner = self.owner;
	self.owner = world;
	
	HL_RadiusDamage(self.origin, self, myowner, 100, "", DMGTYPE_EXPLOSION);
	
	float r;
	r = random();
	
	if (r < 0.333)
	{
		sound (self, CHAN_VOICE, "hl_weapons/debris1.wav", 0.55, ATTN_NORM);
		sound (self, CHAN_BODY, "hl_weapons/explode3.wav", 1.0, ATTN_NONE);
	}
	else if (r < 0.666)
	{
		sound (self, CHAN_VOICE, "hl_weapons/debris2.wav", 0.55, ATTN_NORM);
		sound (self, CHAN_BODY, "hl_weapons/explode4.wav", 1.0, ATTN_NONE);
	}
	else
	{
		sound (self, CHAN_VOICE, "hl_weapons/debris3.wav", 0.55, ATTN_NORM);
		sound (self, CHAN_BODY, "hl_weapons/explode5.wav", 1.0, ATTN_NONE);
	}
	
	// Turn into an explosion.
	
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.origin_z += 24;
	
	setorigin(self, self.origin);
	setmodel(self, "progs/hl_explode.spr");
	
	self.think = HL_ExplosionThink;
	self.touch = SUB_Null;
	
	self.frame = 0;
	self.effects |= EF_MUZZLEFLASH;
	self.nextthink = time;
}

void() HL_GrenadeExplodeTouch =
{
	vector spot = self.origin - normalize(self.velocity) * 32;
	traceline(spot, spot + normalize(self.velocity) * 64, 1, self);
	
	HL_GrenadeExplode();
}

void() HL_GrenadeDetonate =
{
	vector spot = self.origin + '0 0 8';
	traceline(spot, spot + '0 0 -40', 1, self);
	
	HL_GrenadeExplode();
}

entity(vector start, vector vel) W_CreateContactGren =
{
	entity gren;
	gren = spawn();
	gren.gravity = 0.5;
	gren.solid = SOLID_BBOX;
	gren.movetype = MOVETYPE_BOUNCE;
	setorigin(gren, start);
	setmodel(gren, "progs/hl_grenade.mdl");
	setsize(gren, VEC_ORIGIN, VEC_ORIGIN); 
	gren.velocity = vel;
	gren.angles = vectoangles(vel);
	gren.owner = gren.trueowner = self;
	gren.avelocity_x = random(-100, -500);
	gren.touch = HL_GrenadeExplodeTouch;
	gren.think = SUB_Null;
	return gren;
}