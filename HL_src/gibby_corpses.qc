//======================================
//
//	gibby_corpses.qc
//	Gibbable corpse handling code.
//	Unfortunately, this makes dying
//	enemies solid..
//
//	History:
//	11.18.25: Started.
//	11.19.25: made dead bodies
//	use solid_trigger instead of bbox.
// 	also got rid of BBoxFlat check.
//	12.15.25: removed unused code.
//
//======================================

/*
============
BecomeDead
============
*/

void() BecomeDead =
{
	self.takedamage = DAMAGE_AIM;
	self.deadflag = DEAD_DYING;
	self.health = self.max_health / 2;
	self.max_health = 5;
	self.movetype = MOVETYPE_BOUNCE;
	
	// Clear all of this stuff from here
	// so we can shoot corpses without them
	// calling pain functions!
	self.th_stand = SUB_Null;
	self.th_walk = SUB_Null;
	self.th_run = SUB_Null;
	self.th_missile = SUB_Null;
	self.th_pain = SUB_NullPain;
	self.th_die = Corpse_Die;
	self.th_checkattack = SUB_NullFloat;
}

/*
============
BecomeCorpse
============
*/

void(string gibname) BecomeCorpse =
{
	vector min;
	vector max;
	
	min_x = self.mins_x;
	min_y = self.mins_y;
	min_z = self.mins_z;
	
	max_x = self.maxs_x;
	max_y = self.maxs_y;
	max_z = self.mins_z + 8;

	self.deadflag = DEAD_DEAD;
	self.flags &= ~FL_MONSTER;
	self.flags |= FL_CORPSE;
	self.solid = SOLID_TRIGGER;
	setorigin(self, self.origin);
	
	self.noise = gibname;
	self.th_die = Corpse_Die;
	setsize(self, min, max);
}

/*
============
Corpse_Die
============
*/

void() Corpse_Die =
{
	Gib(self.noise, self.health);
}