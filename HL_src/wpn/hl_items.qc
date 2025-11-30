//======================================
//
//	hl_items.qc
//	Weapon pickups. Modifed Copper code
//	basically.
//
//	TODO: Rewrite this to make it so that
//	adding pickups for new ammo types are
//	easier!!
//
//	History:
//	11.28.25: Started.
//
//======================================



/*
=============
HL_FallInit
=============
*/

void() HL_FallInit =
{
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;
	self.wad = self.model; // Restore on respawn.

	setorigin(self, self.origin);
	setsize(self, '-4 -4 0', '4 4 4');

	self.touch = HL_DefaultTouch;
	self.think = HL_FallThink;
	self.flags |= FL_ITEM;
	
	if (deathmatch == 1)
		self.wait = 30;
}

/*
=============
HL_FallThink
=============
*/

void() HL_FallThink =
{
	self.nextthink = time + 0.1;
	
	if (self.flags & FL_ONGROUND)
	{
		if (self.owner)
		{
			sound(self, CHAN_VOICE, "items/weapondrop1.wav", 1, ATTN_NORM);
		}
		
		self.angles_x = 0;
		self.angles_y = 0;
		
		HL_Materialize();
	}
}

/*
=============
HL_Materialize
=============
*/

void() HL_Materialize =
{
	if (self.model == string_null)
	{
		sound(self, CHAN_WEAPON, "items/suitchargeok1.wav", 1, ATTN_NONE);
		self.model = self.wad;
	}
	
	self.solid = SOLID_TRIGGER;
	setorigin(self, self.origin);
	self.think = SUB_Null;
	self.touch = HL_DefaultTouch;
}

/*
=============
HL_ItemTouched
=============
*/

void() HL_ItemTouched =
{
	// wait > 0 == item respawns, either from deathmatch rules or entity keyvalue
	if (self.wait > 0)
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		setorigin(self, self.origin);
		
		self.think = HL_Materialize;
		self.attack_finished = time + self.wait;
		self.nextthink = self.attack_finished - 2.45;
	}
	// wait -1 == respawn every time the item is triggered
	else if (self.wait < 0 || self.use == ItemSpawn || self.use == SUB_regen)	// maintain old respawn hacks
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		setorigin(self, self.origin);
		
		if (self.use != SUB_regen)
			self.use = ItemUse;
	}
	else
	{
		SUB_RemoveSoon();
	}
	
	playercount_convert(count);
	if (self.count > 0)		// only respawn 'count' more times
	{
		self.count = self.count - 1;
		if (self.count == 0)
			SUB_RemoveSoon();	// can't remove during c touch/movement code
	}
	
	activator = other;
	SUB_UseTargets();
}

/*
=============
HL_BoundAmmo
=============
*/

void(entity e) HL_BoundAmmo =
{
	e.ammo_shells = min(e.ammo_shells, MAX_AMMO_SHELLS);
	e.ammo_nails = min(e.ammo_nails, MAX_AMMO_NAILS);
	e.ammo_rockets = min(e.ammo_rockets, MAX_AMMO_ROCKETS);
	e.ammo_cells = min(e.ammo_cells, MAX_AMMO_CELLS);
	
	e.ammo_hornets = min(e.ammo_hornets, MAX_AMMO_HORNETS);
	e.ammo_handgrenades = min(e.ammo_handgrenades, MAX_AMMO_HANDGRENADES);
	e.ammo_satchels = min(e.ammo_satchels, MAX_AMMO_SATCHEL);
	e.ammo_tripmines = min(e.ammo_tripmines, MAX_AMMO_TRIPMINE);
	e.ammo_snarks = min(e.ammo_snarks, MAX_AMMO_SNARK);
}

/*
=============
HL_WeaponGive
=============
*/

void(entity to) HL_WeaponGive =
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
	
	to.ammo_hornets += self.ammo_hornets;
	to.ammo_handgrenades += self.ammo_handgrenades;
	to.ammo_satchels += self.ammo_satchels;
	to.ammo_tripmines += self.ammo_tripmines;
	to.ammo_snarks += self.ammo_snarks;
	
	HL_BoundAmmo(to);

	sprint (to, "You got the ");
	sprint (to, self.netname);
	sprint (to, "\n");

	sound(to, CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM);
	stuffcmd (to, "bf\n");
}

/*
=============
HL_DefaultTouch
=============
*/

void() HL_DefaultTouch =
{
	if (!CheckValidTouch()) 
		return;
	
	float	leave, nsw;

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
	
	if (self.items & other.items) 
		nsw = TRUE;

	HL_WeaponGive(other);// change to the weapon
	
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

	HL_ItemTouched();
}

/*
=============
=============
*/

void() weapon_crowbar =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_crowbar.mdl");
	setmodel (self, "progs/w_crowbar.mdl");
	self.weapon = WPN_CROWBAR;
	self.netname = "Crowbar";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_9mmhandgun =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_9mmhandgun.mdl");
	setmodel (self, "progs/w_9mmhandgun.mdl");
	self.weapon = WPN_GLOCK;
	self.ammo_nails = 17;
	self.netname = "9mm Handgun";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_357 =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_357.mdl");
	setmodel (self, "progs/w_357.mdl");
	self.weapon = WPN_PYTHON;
	self.ammo_nails = 25;
	self.netname = ".357 (slot 2)";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_shotgun =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_shotgun.mdl");
	setmodel (self, "progs/w_shotgun.mdl");
	self.weapon = WPN_SHOTGUN;
	self.ammo_shells = 12;
	self.netname = "Shotgun";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_9mmAR =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_9mmAR.mdl");
	setmodel (self, "progs/w_9mmAR.mdl");
	self.weapon = WPN_MP5;
	self.ammo_nails = 25;
	self.netname = "9mm Assault Rifle";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_crossbow =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_crossbow.mdl");
	setmodel (self, "progs/w_crossbow.mdl");
	self.weapon = WPN_CROSSBOW;
	self.ammo_nails = 5;
	self.netname = "Crossbow";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_hornetgun =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_hgun.mdl");
	setmodel (self, "progs/w_hgun.mdl");
	self.weapon = WPN_HORNETGUN;
	self.ammo_hornets = 5;
	self.netname = "Hornet-Gun";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_rpg =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_rpg.mdl");
	setmodel (self, "progs/w_rpg.mdl");
	self.weapon = WPN_RPG;
	self.ammo_rockets = 1;
	self.netname = "R.P.G";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_gauss =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_gauss.mdl");
	setmodel (self, "progs/w_gauss.mdl");
	self.weapon = WPN_GAUSS;
	self.ammo_cells = 20;
	self.netname = "Tau Canon";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_egon =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_egon.mdl");
	setmodel (self, "progs/w_egon.mdl");
	self.weapon = WPN_EGON;
	self.ammo_cells = 20;
	self.netname = "Gluon Gun (slot 8)";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_handgrenade =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_grenade.mdl");
	setmodel (self, "progs/w_grenade.mdl");
	self.weapon = WPN_HANDGRENADE;
	self.ammo_handgrenades = 5;
	self.netname = "Hand Grenade (slot 9)";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_tripmine =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_tripmine.mdl");
	setmodel (self, "progs/w_tripmine.mdl");
	self.weapon = WPN_TRIPMINE;
	self.ammo_tripmines = 1;
	self.netname = "Trip-Mine (slot 9)";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_satchel =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_satchel.mdl");
	setmodel (self, "progs/w_satchel.mdl");
	self.weapon = WPN_SATCHEL;
	self.ammo_satchels = 1;
	self.netname = "Satchel (slot 9)";
	HL_FallInit();
}

/*
=============
=============
*/

void() weapon_snark =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_sqknest.mdl");
	setmodel (self, "progs/w_sqknest.mdl");
	self.weapon = WPN_SNARK;
	self.ammo_rockets = 3;
	self.netname = "Snarks (slot 9)";
	HL_FallInit();
}

/*
=============
=============
*/

void() HL_AmmoSpawn =
{
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;
	setsize(self, '-16 -16 0', '16 16 16');
	setorigin(self, self.origin);
	

	self.wad = self.model; // Restore on respawn.
	self.touch = HL_AmmoTouch;
	self.flags |= FL_ITEM;
	
	if (deathmatch == 1)
		self.wait = 30;
	if (deathmatch == 3)
		self.wait = 15;
}

/*
============
ammo_touch
============
*/
void() HL_AmmoTouch =
{
	if (!CheckValidTouch()) 
		return;

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

	HL_BoundAmmo(other);
	
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");

	sound(self, CHAN_VOICE, "items/9mmclip1.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	// if changed current ammo, update it
	SUB_CallAsSelf(W_SetCurrentAmmo, other);

	HL_ItemTouched();
}

/*
=============
=============
*/

void() ammo_9mmclip =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_9mmclip.mdl");
	setmodel (self, "progs/w_9mmclip.mdl");
	self.ammo_nails = 17;
	self.netname = "9mm Handgun Clip";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_9mmAR =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_9mmARclip.mdl");
	setmodel (self, "progs/w_9mmARclip.mdl");
	self.ammo_nails = 50;
	self.netname = "9mm Assault Rifle Clip";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_9mmbox =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_suit.mdl");
	setmodel (self, "progs/w_suit.mdl");
	self.ammo_nails = 200;
	self.netname = "Box of 9mm Bullets";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_ARgrenades =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_ARgrenade.mdl");
	setmodel (self, "progs/w_ARgrenade.mdl");
	self.ammo_rockets = 2;
	self.netname = "M203 Grenades";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_buckshot =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_shotbox.mdl");
	setmodel (self, "progs/w_shotbox.mdl");
	self.ammo_shells = 12;
	self.netname = "Shells";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_357 =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_357ammobox.mdl");
	setmodel (self, "progs/w_357ammobox.mdl");
	self.ammo_nails = 6;
	self.netname = ".44 Cal. Rounds";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_rpgclip =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_rpgammo.mdl");
	setmodel (self, "progs/w_rpgammo.mdl");
	self.ammo_rockets = 1;
	self.netname = "Rockets";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_gaussclip =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_gaussammo.mdl");
	setmodel (self, "progs/w_gaussammo.mdl");
	self.ammo_cells = 20;
	self.netname = "Uranium";
	HL_AmmoSpawn();
}

/*
=============
=============
*/

void() ammo_crossbow =
{
	if (!SUB_ShouldSpawn()) return;
	precache_model3 ("progs/w_crossbow_clip.mdl");
	setmodel (self, "progs/w_crossbow_clip.mdl");
	self.ammo_nails = 5;
	self.netname = "Darts";
	HL_AmmoSpawn();
}