/*
===============================================================================

WEAPONS

===============================================================================
*/

float	ITEM_AMMO_BIG = 1;


void(entity e) bound_ammo =
{
	e.ammo_shells = min(e.ammo_shells, MAX_AMMO_SHELLS);
	e.ammo_nails = min(e.ammo_nails, MAX_AMMO_NAILS);
	e.ammo_rockets = min(e.ammo_rockets, MAX_AMMO_ROCKETS);
	e.ammo_cells = min(e.ammo_cells, MAX_AMMO_CELLS);
}

/*
=============
weapon_touch_coop
=============
*/
void() weapon_touch_coop =
{
	if (!coop) return;
	activator = other;
	SUB_UseTargets();
	self.killtarget = string_null;
	self.target = string_null;
	self.target2 = string_null;
	self.target3 = string_null;
	self.target4 = string_null;
}

void(entity to) weapon_give =
{
	if (HUD_WPNS & self.weapon)
	{
		to.items |= self.weapon;
	}
	to.weapons |= self.weapon;
	to.ammo_shells += self.ammo_shells;
	to.ammo_nails += self.ammo_nails;
	to.ammo_rockets += self.ammo_rockets;
	to.ammo_cells += self.ammo_cells;
		
	bound_ammo(to);

	sprint (to, "You got the ");
	sprint (to, self.netname);
	sprint (to, "\n");

	sound (to, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (to, "bf\n");
}

/*
=============
weapon_touch
=============
*/
void() weapon_touch =
{
	float	leave, nsw;

	if (!CheckValidTouch()) return;

	if (deathmatch == 2 || deathmatch == 3 || coop > 1)
		leave = 1;
	else
		leave = 0;
	
	if (leave)
	{
		if (other.items & self.items == self.items)	// already have it
		{
			weapon_touch_coop();
			return;
		}
	}
	
	if (self.items & other.items) nsw = TRUE;

	weapon_give(other);
	// change to the weapon
	entity	stemp;
	stemp = self;
	self = other;
	self = stemp;
	
	if (nsw)
		W_ResetWeaponState();

	if (coop == 1)
	{
		entity pl = get_next_client(other);
		while (pl != other)
		{
			weapon_give(pl);
			pl = get_next_client(pl);
		}
	}
	
	if (leave)
	{
		weapon_touch_coop();
		return;
	}

	ItemTouched();
}


/*
============
StartWeapon
============
*/
void() StartWeapon =
{
	self.type = "weapon";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	if (deathmatch == 1)
		self.wait = 30;
	StartItem ();
}


// ===============================================================================

/*FGD
@baseclass size(-16 -16 0, 16 16 56) color(0 0 200) base(Item) = Weapon []
*/


void() weapon_supershotgun =
{
	HL_RandomWeapon();
}

void() weapon_nailgun =
{
	HL_RandomWeapon();
}

void() weapon_supernailgun =
{
	HL_RandomWeapon();
}


void() weapon_grenadelauncher =
{
	HL_RandomWeapon();
}

void() weapon_rocketlauncher =
{
	HL_RandomWeapon();
}

void() weapon_lightning =
{
	HL_RandomWeapon();
}

void() weapon_axe =
{
	weapon_crowbar();
}


// ===============================================================================

/*
============
ammo_touch
============
*/
void() ammo_touch =
{
	if (!CheckValidTouch()) return;

	// structured in dual if's instead of using && to preserve ammo_touch maphacks
	if (self.ammo_shells)
	{
		if (other.ammo_shells < MAX_AMMO_SHELLS)
			other.ammo_shells += self.ammo_shells;
		else return;
	}
	else if (self.ammo_nails)
	{
		if (other.ammo_nails < MAX_AMMO_NAILS)
			other.ammo_nails += self.ammo_nails;
		else return;
	}
	else if (self.ammo_rockets)
	{
		if (other.ammo_rockets < MAX_AMMO_ROCKETS)
			other.ammo_rockets += self.ammo_rockets;
		else return;
	}
	else if (self.ammo_cells)
	{
		if (other.ammo_cells < MAX_AMMO_CELLS)
			other.ammo_cells += self.ammo_cells;
		else return;
	}
	//else return;	

	bound_ammo(other);
	
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");

	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// if changed current ammo, update it
	SUB_CallAsSelf(W_SetCurrentAmmo, other);

	ItemTouched();
}

/*
============
StartAmmo
============
*/
void() StartAmmo =
{
	self.type = "ammo";
	setsize (self, '0 0 0', '32 32 56');
	self.touch = ammo_touch;
	if (deathmatch == 1)
		self.wait = 30;
	if (deathmatch == 3)
		self.wait = 15;
	StartItem ();
	//ItemRotateAndSize('32 32 56');
}

/*FGD
@baseclass size(0 0 0, 32 32 32) color(0 160 160) base(Item) = Ammo [ spawnflags(flags) =  [ 1 : "Large box (2x)" : 0 ] ]
*/

void() item_shells =
{
	HL_RandomAmmo();
}

void() item_spikes =
{
	HL_RandomAmmo();
}

void() item_rockets =
{
	HL_RandomAmmo();
}


void() item_cells =
{
	HL_RandomAmmo();
}

// ================================


// still used in a few id maps, bleh
void() item_weapon =
{
	float WEAPON_SHOTGUN = 1;
	float WEAPON_ROCKET = 2;
	float WEAPON_SPIKES = 4;
	float WEAPON_BIG = 8;
	
	float oldflags;
	oldflags = self.spawnflags & 15;
	self.spawnflags = not(self.spawnflags, 15);
	
	if (oldflags & WEAPON_BIG)
		self.spawnflags = self.spawnflags | ITEM_AMMO_BIG;
	
	if (oldflags & WEAPON_SHOTGUN)
		item_shells();
	else if (oldflags & WEAPON_SPIKES)
		item_spikes();
	else if (oldflags & WEAPON_ROCKET)
		item_rockets();
};