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
BBoxFlat

Competely stolen
from Half-Life...
============
*/

#ifdef 0

float() BBoxFlat =
{
	float xsize, ysize;
	float len1, len2;
	vector point;
	
	xsize = self.size_x / 2;
	ysize = self.size_y / 2;

	point_x = self.origin_x + xsize;
	point_y = self.origin_y + ysize;
	point_z = self.origin_z;
	
	traceline(point, point - '0 0 100', 1, self);
	len1 = vlen(point - trace_endpos);
	
	point_x = self.origin_x - xsize;
	point_y = self.origin_y - ysize;

	traceline(point, point - '0 0 100', 1, self);
	len2 = vlen(point - trace_endpos);
	
	if (len2 > len1)
	{
		return FALSE;
	}

	len1 = len2;
	
	point_x = self.origin_x - xsize;
	point_y = self.origin_y + ysize;
	
	traceline(point, point - '0 0 100', 1, self);
	len2 = vlen(point - trace_endpos);
	
	if (len2 > len1)
	{
		return FALSE;
	}
	
	len1 = len2;

	point_x = self.origin_x + xsize;
	point_y = self.origin_y - ysize;
	
	traceline(point, point - '0 0 100', 1, self);
	len2 = vlen(point - trace_endpos);
	
	if (len2 > len1)
	{
		return FALSE;
	}
	
	len1 = len2;

	return TRUE;
}

#endif

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
	
	//self.think = Corpse_Think;
	//self.nextthink = time;

	// if (!BBoxFlat())
	// {
		// setsize(self, '-8 -8 0', '8 8 1');
		// setorigin(self, self.origin);
	// }
	// else
	// {
		setsize(self, min, max);
	// }
}

/*
============
Corpse_Think
============
*/

void() Corpse_Think =
{
	if (!(self.flags & FL_ONGROUND) && self.solid != SOLID_BBOX)
	{
		self.solid = SOLID_BBOX;
		setorigin(self, self.origin);
	}
	else if ((self.flags & FL_ONGROUND) && self.solid != SOLID_TRIGGER)
	{
		self.solid = SOLID_TRIGGER;
		setorigin(self, self.origin);
	}
	self.nextthink = time;
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