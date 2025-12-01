//======================================
//
//	hl_wpn_grenades.qc
//	Every Half-Life grenade in 1 file..
//	Code referenced from HLSDK1.0 Code..
//
//	History:
//	11.16.25: Started. Contact grenade &
//	sparks.
//	11.27.25: satchel, handgrenade
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

/*
============
HL_ExplosionThink
============
*/

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

/*
============
HL_GrenadeExplode
============
*/

void() HL_GrenadeExplode =
{
	self.owner = world;
	
	HL_RadiusDamage(self.origin, self, self.trueowner, self.dmg, "", DMGTYPE_EXPLOSION);
	
	float r;
	r = random();
	
	if (r < 0.333)
	{
		sound (self, CHAN_VOICE, "weapons/debris1.wav", 0.55, ATTN_NORM);
		sound (self, CHAN_BODY, "weapons/explode3.wav", 1.0, ATTN_NONE);
	}
	else if (r < 0.666)
	{
		sound (self, CHAN_VOICE, "weapons/debris2.wav", 0.55, ATTN_NORM);
		sound (self, CHAN_BODY, "weapons/explode4.wav", 1.0, ATTN_NONE);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/debris3.wav", 0.55, ATTN_NORM);
		sound (self, CHAN_BODY, "weapons/explode5.wav", 1.0, ATTN_NONE);
	}
	
	// Turn into an explosion.
	
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.origin_z += 24;
	
	setorigin(self, self.origin);

	if (self.dmg >= 100)
		setmodel(self, "progs/hl_explode1.spr");
	else
		setmodel(self, "progs/hl_explode.spr");
	
	self.think = HL_ExplosionThink;
	self.touch = SUB_Null;
	
	self.frame = 0;
	self.effects |= EF_MUZZLEFLASH;
	self.nextthink = time;
}

/*
============
HL_ExplodeTouch
============
*/

void() HL_ExplodeTouch =
{
	vector spot = self.origin - normalize(self.velocity) * 32;
	traceline(spot, spot + normalize(self.velocity) * 64, 1, self);
	
	HL_GrenadeExplode();
}

/*
============
HL_GrenadeDetonate
============
*/

void() HL_GrenadeDetonate =
{
	vector spot = self.origin + '0 0 8';
	traceline(spot, spot + '0 0 -40', 1, self);
	
	HL_GrenadeExplode();
}

/*
============
HL_GrenadeBounceSound
============
*/

void() HL_GrenadeBounceSound =
{
	float r = random();
	
	if (r < 0.33)
		sound(self, CHAN_VOICE, "weapons/grenade_hit1.wav", 0.25, ATTN_NORM);
	else if (r < 0.66)
		sound(self, CHAN_VOICE, "weapons/grenade_hit2.wav", 0.25, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "weapons/grenade_hit3.wav", 0.25, ATTN_NORM);
}

/*
============
HL_GrenadeBounceTouch
============
*/

void() HL_GrenadeBounceTouch =
{
	if (other == self.trueowner)
		return;

	if ((self.owner) && (self.attack_finished < time) && (vlen(self.velocity) > 100) && (other != world))
	{
		ClearMultiDamage();
		trace_ent = other;
		TraceAttack(1, v_forward);
		ApplyMultiDamage();
		self.attack_finished = time + 1.0;
	}
	
	if (self.flags & FL_ONGROUND)
	{
		self.velocity = self.velocity * 0.8;
	}
	else
	{
		HL_GrenadeBounceSound();
	}
	
}

/*
============
HL_TumbleThink
============
*/

void() HL_TumbleThink =
{
	self.nextthink = time + 0.1;
	
	if (self.dmgtime <= time)
	{
		self.think = HL_GrenadeDetonate;
	}

	if (self.waterlevel != 0)
	{
		self.velocity_x = self.velocity_x * 0.5;
		self.velocity_y = self.velocity_y * 0.5;
		self.avelocity = self.avelocity * 0.8;
	}
}

/*
============
W_CreateBasicGrenade
============
*/

entity() W_CreateBasicGrenade =
{
	entity gren;
	gren = spawn();
	
	gren.movetype = MOVETYPE_BOUNCE;
	gren.classname = "grenade";
	gren.solid = SOLID_BBOX;
	gren.owner = gren.trueowner = self;
	
	setorigin(gren, gren.origin);
	setmodel(gren, "progs/hl_grenade.mdl");
	setsize(gren, VEC_ORIGIN, VEC_ORIGIN);
	
	gren.dmg = 100;
	return gren;
}

/*
============
W_CreateContactGren
============
*/

entity(vector start, vector vel) W_CreateContactGren =
{
	entity gren;
	gren = W_CreateBasicGrenade();
	
	gren.gravity = 0.5;
	setorigin(gren, start);
	
	gren.avelocity_x = random(-100, -500);
	gren.velocity = vel;
	gren.angles = vectoangles(vel);
	
	gren.touch = HL_ExplodeTouch;
	gren.think = SUB_Null;
	
	gren.dmg = 100;
	return gren;
}

/*
============
W_CreateTimedGren
============
*/

entity(vector start, vector vel, float mytime) W_CreateTimedGren =
{
	entity gren;
	gren = W_CreateBasicGrenade();
	setorigin(gren, start);
	
	setmodel(gren, "progs/w_grenade.mdl");
	gren.gravity = 0.5;
	gren.velocity = vel;
	gren.avelocity = '1 1 1' * 400;
	gren.angles = vectoangles(vel);
	
	gren.touch = HL_GrenadeBounceTouch;
	gren.think = HL_TumbleThink;
	gren.nextthink = time + 0.1;
	gren.dmgtime = time + mytime;
	
	if (mytime < 0.1)
	{
		gren.nextthink = time;
		gren.velocity = '0 0 0';
	}
	
	gren.dmg = 100;
	return gren;
}