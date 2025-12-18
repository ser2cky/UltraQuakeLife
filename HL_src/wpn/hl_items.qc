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
//	11.30.25: Starting to streamline the
//	item creation process...
//	12.15.25: randomized pickups suck...
//	using crates now!!!
//
//======================================

float NUM_OF_ITEMS = 13;

enum 
{
	ITEMTYPE_WEAPON,
	ITEMTYPE_AMMO,
	ITEMTYPE_POWERUP
};

typedef struct 
{
	string model;
	float item_id;
	float type;
	string netname;
	string ammo;
	float ammogive;
} itemdef_t;

itemdef_t item_crowbar =
{
	"progs/w_crowbar.mdl", // mdl
	WPN_CROWBAR, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Crowbar", // netname
	"", // ammo type
	0 // ammo give
};

itemdef_t item_glock =
{
	"progs/w_9mmhandgun.mdl", // mdl
	WPN_GLOCK, // item it gives you
	ITEMTYPE_WEAPON, //type
	"9mm Handgun", // netname
	"nails", // ammo type
	8 // ammo give
};

itemdef_t item_357 =
{
	"progs/w_357.mdl", // mdl
	WPN_PYTHON, // item it gives you
	ITEMTYPE_WEAPON, //type
	".357 (slot 2)", // netname
	"nails", // ammo type
	6 // ammo give
};

itemdef_t item_shotgun =
{
	"progs/w_shotgun.mdl", // mdl
	WPN_SHOTGUN, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Shotgun", // netname
	"shells", // ammo type
	6 // ammo give
};

itemdef_t item_mp5 =
{
	"progs/w_9mmAR.mdl", // mdl
	WPN_MP5, // item it gives you
	ITEMTYPE_WEAPON, //type
	"9mm Assault Rifle", // netname
	"nails", // ammo type
	25 // ammo give
};

itemdef_t item_crossbow =
{
	"progs/w_crossbow.mdl", // mdl
	WPN_CROSSBOW, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Crossbow", // netname
	"nails", // ammo type
	5 // ammo give
};

itemdef_t item_rpg =
{
	"progs/w_rpg.mdl", // mdl
	WPN_RPG, // item it gives you
	ITEMTYPE_WEAPON, //type
	"R.P.G", // netname
	"rockets", // ammo type
	1 // ammo give
};

itemdef_t item_hornetgun =
{
	"progs/w_hgun.mdl", // mdl
	WPN_HORNETGUN, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Hornet-Gun", // netname
	"hornets", // ammo type
	8 // ammo give
};

itemdef_t item_gauss =
{
	"progs/w_gauss.mdl", // mdl
	WPN_GAUSS, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Tau Canon", // netname
	"cells", // ammo type
	5 // ammo give
};

itemdef_t item_egon =
{
	"progs/w_egon.mdl", // mdl
	WPN_EGON, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Gluon Gun (slot 8)", // netname
	"cells", // ammo type
	5 // ammo give
};

itemdef_t item_handgrenade =
{
	"progs/w_grenade.mdl", // mdl
	WPN_HANDGRENADE, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Hand-Grenades (slot 9)", // netname
	"hand_grenades", // ammo type
	1 // ammo give
};

itemdef_t item_tripmine =
{
	"progs/w_tripmine.mdl", // mdl
	WPN_TRIPMINE, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Tripmine (slot 9)", // netname
	"tripmines", // ammo type
	1 // ammo give
};

itemdef_t item_satchel =
{
	"progs/w_satchel.mdl", // mdl
	WPN_SATCHEL, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Satchel (slot 9)", // netname
	"satchels", // ammo type
	1 // ammo give
};

itemdef_t item_snark =
{
	"progs/w_sqknest.mdl", // mdl
	WPN_SNARK, // item it gives you
	ITEMTYPE_WEAPON, //type
	"Snarks (slot 9)", // netname
	"snarks", // ammo type
	3 // ammo give
};

//=========================

itemdef_t item_9mmclip =
{
	"progs/w_9mmclip.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"9mm Handgun Clip", // netname
	"nails", // ammo type
	17 // ammo give
};

itemdef_t item_9mmARclip =
{
	"progs/w_9mmARclip.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"9mm Assault Rifle Clip", // netname
	"nails", // ammo type
	50 // ammo give
};

itemdef_t item_9mmbox =
{
	"progs/w_suit.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"9mm Bullet Box", // netname
	"nails", // ammo type
	200 // ammo give
};

itemdef_t item_ARgrenades =
{
	"progs/w_ARgrenade.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"Assault Rifle Grenades", // netname
	"rockets", // ammo type
	2 // ammo give
};

itemdef_t item_sshells =
{
	"progs/w_shotbox.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"Shotgun Shells", // netname
	"shells", // ammo type
	8 // ammo give
};

itemdef_t item_357ammo =
{
	"progs/w_357ammobox.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	".44 Cal. Bullets", // netname
	"nails", // ammo type
	6 // ammo give
};

itemdef_t item_rpgclip =
{
	"progs/w_rpgammo.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"Rocket", // netname
	"rockets", // ammo type
	1 // ammo give
};

itemdef_t item_gaussclip =
{
	"progs/w_gaussammo.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"Uranium", // netname
	"cells", // ammo type
	20 // ammo give
};

itemdef_t item_crossbowclip =
{
	"progs/w_crossbow_clip.mdl", // mdl
	WPN_NONE, // item it gives you
	ITEMTYPE_AMMO, //type
	"Crossbow Clip", // netname
	"nails", // ammo type
	3 // ammo give
};

itemdef_t all_items[23] =
{
	item_crowbar,
	item_glock,
	item_357,
	item_shotgun,
	item_mp5,
	item_crossbow,
	item_rpg,
	item_hornetgun,
	item_gauss,
	item_egon,
	item_handgrenade,
	item_tripmine,
	item_satchel,
	item_snark,
	item_9mmclip,
	item_9mmARclip,
	item_9mmbox,
	item_ARgrenades,
	item_sshells,
	item_357ammo,
	item_rpgclip,
	item_gaussclip,
	item_crossbowclip
};

/*
=============
HL_GetItemIndexByName

Grab item index by it's classname.
=============
*/

float(string item_name) HL_GetItemIndexByName =
{
	switch (item_name)
	{
		case "weapon_crowbar":			return 0;
		case "weapon_9mmhandgun":		return 1;
		case "weapon_357":				return 2;
		case "weapon_shotgun":			return 3;
		case "weapon_9mmAR":			return 4;
		case "weapon_crossbow":			return 5;
		case "weapon_rpg":				return 6;
		case "weapon_hornetgun":		return 7;
		case "weapon_gauss":			return 8;
		case "weapon_egon":				return 9;
		case "weapon_handgrenade":		return 10;
		case "weapon_tripmine":			return 11;
		case "weapon_satchel":			return 12;
		case "weapon_snark":			return 13;
		case "ammo_9mmclip":		return 14;
		case "ammo_9mmAR":			return 15;
		case "ammo_9mmbox":			return 16;
		case "ammo_ARgrenades":		return 17;
		case "ammo_buckshot":		return 18;
		case "ammo_357":			return 19;
		case "ammo_rpgclip":		return 20;
		case "ammo_gaussclip":		return 21;
		case "ammo_crossbow":		return 22;
		default:					return 0;
	}
}

/*
=============
HL_SpawnItem
=============
*/

void(entity item, string item_name) HL_SpawnItem =
{
	itemdef_t my_item = all_items[HL_GetItemIndexByName(item_name)];
	
	if (!SUB_ShouldSpawn()) 
	{
		return;
	}
	
	setmodel (item, my_item.model);
	item.netname = my_item.netname;
	
	if (my_item.type == ITEMTYPE_WEAPON)
	{
		item.weapon = my_item.item_id;
		item.(ammo_fields[W_GetAmmoField(my_item.ammo)]) = my_item.ammogive;
		HL_FallInit(item);
	}
	else if (my_item.type == ITEMTYPE_AMMO)
	{
		item.(ammo_fields[W_GetAmmoField(my_item.ammo)]) = my_item.ammogive;
		HL_AmmoSpawn(item);
	}
};

/*
=============
HL_SpawnItem
=============
*/

entity(string item_name) HL_SpawnItem2 =
{
	entity item;

	itemdef_t my_item = all_items[HL_GetItemIndexByName(item_name)];
	
	if (!SUB_ShouldSpawn()) 
	{
		return item;
	}
	
	item = spawn();
	setmodel (item, my_item.model);
	item.netname = my_item.netname;
	item.classname = item_name;
	
	if (my_item.type == ITEMTYPE_WEAPON)
	{
		item.weapon = my_item.item_id;
		item.(ammo_fields[W_GetAmmoField(my_item.ammo)]) = my_item.ammogive;
		HL_FallInit(item);
	}
	else if (my_item.type == ITEMTYPE_AMMO)
	{
		item.(ammo_fields[W_GetAmmoField(my_item.ammo)]) = my_item.ammogive;
		HL_AmmoSpawn(item);
	}
	
	return item;
};

/*
=============
HL_FallInit
=============
*/

void(entity new) HL_FallInit =
{
	new.movetype = MOVETYPE_TOSS;
	new.solid = SOLID_TRIGGER;
	new.wad = new.model; // Restore on respawn.

	setorigin(new, new.origin);
	setsize(new, '-4 -4 0', '4 4 4');

	new.touch = HL_DefaultTouch;
	new.think = HL_FallThink;
	new.flags |= FL_ITEM;
	
	if (deathmatch == 1)
		new.wait = 30;
}

/*
=============
HL_AmmoSpawn
=============
*/

void(entity new) HL_AmmoSpawn =
{
	new.movetype = MOVETYPE_TOSS;
	new.solid = SOLID_TRIGGER;
	setsize(new, '-16 -16 0', '16 16 16');
	setorigin(new, new.origin);
	

	new.wad = new.model; // Restore on respawn.
	new.touch = HL_AmmoTouch;
	new.flags |= FL_ITEM;
	
	if (deathmatch == 1)
		new.wait = 30;
	if (deathmatch == 3)
		new.wait = 15;
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
============
HL_AmmoTouch
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

//==================================================================
//
//							WEAPON SPAWN FUNCS!!!
//
//==================================================================

void() weapon_crowbar = {HL_SpawnItem(self, self.classname);};
void() weapon_9mmhandgun = {HL_SpawnItem(self, self.classname);};
void() weapon_357 = {HL_SpawnItem(self, self.classname);};
void() weapon_shotgun = {HL_SpawnItem(self, self.classname);};
void() weapon_9mmAR = {HL_SpawnItem(self, self.classname);};
void() weapon_crossbow = {HL_SpawnItem(self, self.classname);};
void() weapon_hornetgun = {HL_SpawnItem(self, self.classname);};
void() weapon_rpg = {HL_SpawnItem(self, self.classname);};
void() weapon_gauss = {HL_SpawnItem(self, self.classname);};
void() weapon_egon = {HL_SpawnItem(self, self.classname);};
void() weapon_handgrenade = {HL_SpawnItem(self, self.classname);};
void() weapon_tripmine = {HL_SpawnItem(self, self.classname);};
void() weapon_satchel = {HL_SpawnItem(self, self.classname);};
void() weapon_snark = {HL_SpawnItem(self, self.classname);};

void() ammo_9mmclip = {HL_SpawnItem(self, self.classname);};
void() ammo_9mmAR = {HL_SpawnItem(self, self.classname);};
void() ammo_9mmbox = {HL_SpawnItem(self, self.classname);};
void() ammo_ARgrenades = {HL_SpawnItem(self, self.classname);};
void() ammo_buckshot = {HL_SpawnItem(self, self.classname);};
void() ammo_357 = {HL_SpawnItem(self, self.classname);};
void() ammo_rpgclip = {HL_SpawnItem(self, self.classname);};
void() ammo_gaussclip = {HL_SpawnItem(self, self.classname);};
void() ammo_crossbow = {HL_SpawnItem(self, self.classname);};


//==================================================================
//
//							CRATE DOOHICKEY!!!
//
//==================================================================

/*
============
WoodGibs
============
*/

entity() WoodGibs =
{
	entity shrapnel;
	shrapnel = spawn();
	
	shrapnel.movetype = MOVETYPE_BOUNCE;
	shrapnel.solid = SOLID_TRIGGER;
	setorigin(shrapnel, shrapnel.origin);
	setsize (shrapnel, '0 0 0', '0 0 0');

	float r;
	r = random();
	if ( r < 0.333 )
		setmodel( shrapnel, "progs/woodgibs.mdl");
	else if ( r < 0.666 )
		setmodel( shrapnel, "progs/woodgibs1.mdl");
	else
		setmodel( shrapnel, "progs/woodgibs2.mdl");
	
	shrapnel.velocity_x = random() * 400 * crandom();
	shrapnel.velocity_y = random() * 400 * crandom();
	shrapnel.velocity_z = random() * 400;

	shrapnel.avelocity_x = random() * -255 + 255;
	shrapnel.avelocity_y = random() * -255 + 255;
	shrapnel.avelocity_z = random() * -255 + 255;
	

	shrapnel.think = WoodDissolve;
	shrapnel.touch = WoodSound;
	shrapnel.nextthink = time + 0.1;
	
	return shrapnel;
}

/*
============
WoodDissolve
============
*/

void() WoodDissolve =
{
	self.alpha = min(self.alpha + 0.1, 0.9);
	
	if (self.alpha >= 0.9)
		self.think = SUB_Remove;
		
	self.nextthink = time + 0.1;
}

/*
============
WoodSound
============
*/

void() WoodSound =
{
	if (vlen(self.velocity) >= 60.0)
	{
		float snd;
		snd = random();
		if ( snd < 0.33 )
			sound(self, CHAN_ITEM, "debris/wood1.wav", 0.25, ATTN_NORM);
		else if ( snd < 0.66 )
			sound(self, CHAN_ITEM, "debris/wood2.wav", 0.25, ATTN_NORM);
		else
			sound(self, CHAN_ITEM, "debris/wood3.wav", 0.25, ATTN_NORM);
	}
}

/*
============
BecomeCrate
============
*/

void(string type, string new_classname) BecomeCrate =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_TOSS;
	setorigin(self, self.origin);
	setsize(self, '-4 -4 0', '4 4 4');

	self.noise = new_classname;
	self.netname = type;
	self.health = 50;
	self.takedamage = DAMAGE_AIM;
	self.skin = random(0, 7);
	
	self.classname = "crate";
	self.th_stand = SUB_Null;
	self.th_walk = SUB_Null;
	self.th_run = SUB_Null;
	self.th_missile = SUB_Null;
	self.th_pain = Crate_Pain;
	self.th_die = Crate_Die;
	self.th_checkattack = SUB_NullFloat;
	
	if (self.noise == "weapon_crate")
	{
		setmodel(self, "progs/crate.mdl");
		self.wad = self.model;
		if (deathmatch == 1)
			self.wait = 10;
	}
	
	if (self.noise == "ammo_crate")
	{
		setmodel(self, "progs/crate1.mdl");
		self.wad = self.model;
		if (deathmatch == 1)
			self.wait = 30;
		if (deathmatch == 3)
			self.wait = 15;
	}
}

/*
============
Crate_Pain
============
*/

void(entity attacker, float damage) Crate_Pain =
{
	float snd;
	snd = random();
	if ( snd < 0.33 )
		sound(self, CHAN_VOICE, "debris/wood1.wav", 1.0, ATTN_NORM);
	else if ( snd < 0.66 )
		sound(self, CHAN_VOICE, "debris/wood2.wav", 1.0, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "debris/wood3.wav", 1.0, ATTN_NORM);
}

/*
============
Crate_Weapon_Drop

This is really ugly, but I don't give
a hoot!!!
============
*/

void() Crate_Weapon_Drop =
{
	string newitem[6];
	float arraysize = 4;

	switch (self.netname)
	{
		case "weapon_supershotgun":
		{
			newitem[0] = "weapon_357";
			newitem[1] = "weapon_shotgun";
			arraysize = 2;
			break;
		}
	
		case "weapon_nailgun":
		{
			newitem[0] = "weapon_9mmAR";
			arraysize = 1;
			break;
		}
	
		case "weapon_supernailgun":
		{
			newitem[0] = "weapon_crossbow";
			newitem[1] = "weapon_snark";
			arraysize = 2;
			break;
		}
		
		case "weapon_grenadelauncher":
		{
			newitem[0] = "weapon_handgrenade";
			newitem[1] = "weapon_satchel";
			newitem[2] = "weapon_tripmine";
			arraysize = 3;
			break;
		}
		
		case "weapon_rocketlauncher":
		{
			newitem[0] = "weapon_rpg";
			newitem[1] = "weapon_hornetgun";
			arraysize = 2;
			break;
		}
	
		case "weapon_lightning":
		{
			newitem[0] = "weapon_gauss";
			newitem[1] = "weapon_egon";
			arraysize = 2;
			break;
		}
	
		case "item_shells":
		{
			newitem[0] = "ammo_buckshot";
			newitem[1] = "ammo_357";
			arraysize = 2;
			break;
		}
		
		case "item_spikes":
		{
			newitem[0] = "ammo_9mmclip";
			newitem[1] = "ammo_9mmAR";
			newitem[2] = "ammo_crossbow";
			arraysize = 3;
			break;
		}
		
		case "item_cells":
		{
			newitem[0] = "ammo_gaussclip";
			newitem[1] = "ammo_gaussclip";
			newitem[2] = "ammo_gaussclip";
			arraysize = 3;
			break;
		}
		
		case "item_rockets": // holy bloat
		{
			newitem[0] = "ammo_rpgclip";
			newitem[1] = "ammo_ARgrenades";
			newitem[2] = "weapon_satchel";
			newitem[3] = "weapon_handgrenade";
			newitem[4] = "weapon_satchel";
			newitem[5] = "weapon_tripmine";
			arraysize = 6;
			break;
		}
	}
	
	for (float i = 0; i < arraysize; i++)
	{
		entity item;
		item = HL_SpawnItem2(newitem[i]);
		item.origin = self.origin;
		setsize(item, '0 0 0', '0 0 0');
		item.avelocity_y = random(-100.0, 100.0);
		item.velocity_x = 150 * crandom();
		item.velocity_y = 150 * crandom();
		item.velocity_z = 150 + 150 * random();
		item.wait = -1;
		item.use = SUB_Null;
	}
}

/*
============
Crate_Die
============
*/

void() Crate_Die =
{
	float snd;
	snd = random();
	
	if ( snd < 0.333 )
		sound(self, CHAN_VOICE, "debris/bustcrate1.wav", 1.0, ATTN_NORM);
	else if ( snd < 0.666 )
		sound(self, CHAN_VOICE, "debris/bustcrate2.wav", 1.0, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "debris/bustcrate3.wav", 1.0, ATTN_NORM);
	
	self.solid = SOLID_NOT;
	self.model = "";
	
	Crate_Weapon_Drop();
	
	for (float j = 0; j < 16; j++) 
	{
		entity gibs;
		gibs = WoodGibs();
		
		gibs.origin = self.origin;
	}
	
	CrateRespawn();
}

/*
=============
ReviveCrate
=============
*/

void() ReviveCrate =
{
	entity ent;
	ent = findradius(self.origin, 32);
	
	// Make sure nothing's standing on us.
	if ((ent.flags & FL_CLIENT) || (ent.flags & FL_MONSTER))
	{
		T_Damage (ent, self, self, 50000, DMGTYPE_TELEFRAG);
		sound (ent, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
	}
		
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_TOSS;
	setorigin(self, self.origin);
	
	if (self.noise == "weapon_crate")
		setsize(self, '-4 -4 0', '4 4 8');
	else
		setsize (self, '0 0 0', '32 32 24');

	setmodel(self, self.wad);

	self.health = 50;
	self.takedamage = DAMAGE_AIM;
	self.th_pain = Crate_Pain;
	self.th_die = Crate_Die;
	
	sound(self, CHAN_WEAPON, "items/suitchargeok1.wav", 1, ATTN_NONE);
}

/*
=============
CrateRespawn
=============
*/

void() CrateRespawn =
{
	// wait > 0 == item respawns, either from deathmatch rules or entity keyvalue
	if (self.wait > 0)
	{
		self.think = ReviveCrate;
		self.attack_finished = time + self.wait;
		self.nextthink = self.attack_finished - 2.45;
		
#ifdef DEV
		bprint("respawn:");
		bprint(ftos(self.wait));
		bprint("curtime:");
		bprint(ftos(time));
		bprint("\n");
#endif
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
}

/*
=============
HL_PrecacheItems
=============
*/

void() HL_PrecacheItems =
{
	for (float i = 0; i < 23; i++)
	{
		itemdef_t my_item = all_items[i];
		precache_model(my_item.model);
	}
	
	precache_model("progs/crate.mdl");
	precache_model("progs/crate1.mdl");
	precache_model("progs/woodgibs.mdl");
	precache_model("progs/woodgibs1.mdl");
	precache_model("progs/woodgibs2.mdl");
	
	precache_sound("debris/wood1.wav");
	precache_sound("debris/wood2.wav");
	precache_sound("debris/wood3.wav");

	precache_sound("debris/bustcrate1.wav");
	precache_sound("debris/bustcrate2.wav");
	precache_sound("debris/bustcrate3.wav");
}