//======================================
//
//	wpn_util.qc
//	Helpful weapon code. Code is a
//	slightly modified version of the
//	Alkaline weapons handling code.
//
//	History:
//	11.13.25: Started.
//	11.14.25: Got regular Quake weapons
//	, idles, and deploys working.
//	11.15.25: Got Sec. fire, reloading
//	working!!
//	11.17.25: added check for special
//	reloads in weaponframe
//	11.22.25: fixed door traceattack bug,
//	changing weapons now properly
//	calls holster function !!!
//	11.24.25: Added check for firing
//	on empty.
//	11.28.25: changed deploy behaviour.
//	now sets weaponstate to ready once
//	attack_finish passes.
//
//======================================

typedef struct {
	float slot;
	float slotpos;
	string ammo1;
	string ammo2;
	float ammo_usage;
	float clip_size;
	string model;
	string name;
	float id;
	float wpn_flags;
	float() attack1;
	float() attack2;
	float() reload;
	void() postframe;
	void() deploy;
	float() holster;
	void() idle;
	void() precache;
} weaponclass_t;

.float ammo_fields[10] = {
	currentammo,
	ammo_shells,
	ammo_nails, 
	ammo_rockets,
	ammo_cells,
	ammo_hornets,
	ammo_handgrenades,
	ammo_satchels,
	ammo_tripmines,
	ammo_snarks
};

.float clip_fields[7] = {
	currentammo,
	clip_mp5,
	clip_glock,
	clip_shotgun,
	clip_crossbow,
	clip_rpg,
	clip_python
};

float() W_NullFunc = {return FALSE;};
float() W_NullTrue = {return TRUE;};
void() W_DefaultDeploy = {self.weaponstate = WS_DEPLOY; W_SetWeaponAnim(0, 0, 0, -1);};

weaponclass_t wpc_none =
{
	0, // Slot
	0, // Slot pos.
	"", // Ammo1
	"", // Ammo2
	0, // Ammo usage.
	0, // Clip size.
	"", // V_Model
	"", // Weapon name.
	WPN_NONE, // Weapon I.D
	0, // Weapon flags
	W_NullFunc, // Attack1
	W_NullFunc, // Attack2
	W_NullFunc, // Reload
	SUB_Null, // Post-Think function.
	W_DefaultDeploy, // Deploy.
	W_NullTrue, // Holster.
	SUB_Null, // Idle.
	SUB_Null // Precache.
};

weaponclass_t wpc_crowbar =
{
	1, // Slot
	0, // Slot pos.
	"", // Ammo1
	"", // Ammo2
	0, // Ammo usage.
	0, // Clip size.
	"progs/v_crowbar.mdl", // V_Model
	"Crowbar", // Weapon name.
	WPN_CROWBAR, // Weapon I.D
	0, // Weapon flags
	W_CrowbarPrimAttack, // Attack1
	W_NullFunc, // Attack2
	W_NullFunc, // Reload
	W_CrowbarPostFrame, // Post-Think function.
	W_CrowbarDeploy, // Deploy.
	W_NullTrue, // Holster.
	SUB_Null, // Idle.
	W_CrowbarPrecache // Precache.
};

weaponclass_t wpc_glock =
{
	2, // Slot
	0, // Slot pos.
	"nails", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	18, // Clip size.
	"progs/v_9mmhandgun.mdl", // V_Model
	"Glock", // Weapon name.
	WPN_GLOCK, // Weapon I.D
	0, // Weapon flags
	W_GlockPrimAttack, // Attack1
	W_GlockSecAttack, // Attack2
	W_GlockReload, // Reload
	W_GlockEvents, // Post-Think function.
	W_GlockDeploy, // Deploy.
	W_NullTrue, // Holster.
	W_GlockIdle, // Idle.
	W_GlockPrecache // Precache.
};

weaponclass_t wpc_python =
{
	2, // Slot
	1, // Slot pos.
	"nails", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	6, // Clip size.
	"progs/v_357.mdl", // V_Model
	"Python", // Weapon name.
	WPN_PYTHON, // Weapon I.D
	0, // Weapon flags
	W_PythonPrimAttack, // Attack1
	W_PythonSecAttack, // Attack2
	W_PythonReload, // Reload
	SUB_Null, // Post-Think function.
	W_PythonDeploy, // Deploy.
	W_PythonHolster, // Holster.
	W_PythonIdle, // Idle.
	W_PythonPrecache // Precache.
};

weaponclass_t wpc_shotgun =
{
	3, // Slot
	0, // Slot pos.
	"shells", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	8, // Clip size.
	"progs/v_shotgun.mdl", // V_Model
	"Shotgun", // Weapon name.
	WPN_SHOTGUN, // Weapon I.D
	0, // Weapon flags
	W_ShotgunPrimAttack, // Attack1
	W_ShotgunSecAttack, // Attack2
	W_ShotgunReload, // Reload
	W_ShotgunPostThink, // Post-Think function.
	W_ShotgunDeploy, // Deploy.
	W_NullTrue, // Holster.
	W_ShotgunIdle, // Idle.
	W_ShotgunPrecache // Precache.
};

weaponclass_t wpc_mp5 =
{
	4, // Slot
	0, // Slot pos.
	"nails", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	50, // Clip size.
	"progs/v_9mmAR.mdl", // V_Model
	"MP5", // Weapon name.
	WPN_MP5, // Weapon I.D
	0, // Weapon flags
	W_MP5PrimAttack, // Attack1
	W_MP5SecAttack, // Attack2
	W_MP5Reload, // Reload
	W_MP5Events, // Post-Think function.
	W_MP5Deploy, // Deploy.
	W_NullTrue, // Holster.
	W_MP5Idle, // Idle.
	W_MP5Precache // Precache.
};

weaponclass_t wpc_crossbow =
{
	5, // Slot
	0, // Slot pos.
	"nails", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	5, // Clip size.
	"progs/v_crossbow.mdl", // V_Model
	"Crossbow", // Weapon name.
	WPN_CROSSBOW, // Weapon I.D
	0, // Weapon flags
	W_CrossbowPrimAttack, // Attack1
	W_CrossbowSecAttack, // Attack2
	W_CrossbowReload, // Reload
	SUB_Null, // Post-Think function.
	W_CrossbowDeploy, // Deploy.
	W_CrossbowHolster, // Holster.
	W_CrossbowIdle, // Idle.
	W_CrossbowPrecache // Precache.
};

weaponclass_t wpc_rpg =
{
	6, // Slot
	0, // Slot pos.
	"rockets", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	1, // Clip size.
	"progs/v_rpg.mdl", // V_Model
	"RPG", // Weapon name.
	WPN_RPG, // Weapon I.D
	0, // Weapon flags
	W_RPGPrimAttack, // Attack1
	W_RPGSecAttack, // Attack2
	W_RPGReload, // Reload
	SUB_Null, // Post-Think function.
	W_RPGDeploy, // Deploy.
	W_RPGHolster, // Holster.
	W_RPGIdle, // Idle.
	W_PrecacheRPG // Precache.
};

weaponclass_t wpc_hornetgun =
{
	7, // Slot
	0, // Slot pos.
	"hornets", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	0, // Clip size.
	"progs/v_hgun.mdl", // V_Model
	"Hornetgun", // Weapon name.
	WPN_HORNETGUN, // Weapon I.D
	WFL_USABLE_IF_EMPTY, // Weapon flags
	W_HGunPrimAttack, // Attack1
	W_HGunSecAttack, // Attack2
	W_HGunReload, // Reload
	SUB_Null, // Post-Think function.
	W_HGunDeploy, // Deploy.
	W_HGunHolster, // Holster.
	W_HGunIdle, // Idle.
	W_HGunPrecache // Precache.
};

weaponclass_t wpc_gauss =
{
	8, // Slot
	0, // Slot pos.
	"cells", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	0, // Clip size.
	"progs/v_gauss.mdl", // V_Model
	"Tau-Canon", // Weapon name.
	WPN_GAUSS, // Weapon I.D
	0, // Weapon flags
	W_GaussPrimFire, // Attack1
	W_GaussSecFire, // Attack2
	W_NullFunc, // Reload
	SUB_Null, // Post-Think function.
	W_GaussDeploy, // Deploy.
	W_NullTrue, // Holster.
	W_GaussIdle, // Idle.
	W_GaussPrecache // Precache.
};

weaponclass_t wpc_egon =
{
	8, // Slot
	1, // Slot pos.
	"cells", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	0, // Clip size.
	"progs/v_egon.mdl", // V_Model
	"Gluon-Gun", // Weapon name.
	WPN_EGON, // Weapon I.D
	0, // Weapon flags
	W_EgonPrimAttack, // Attack1
	W_NullFunc, // Attack2
	W_NullFunc, // Reload
	SUB_Null, // Post-Think function.
	W_EgonDeploy, // Deploy.
	W_EgonHolster, // Holster.
	W_EgonIdle, // Idle.
	W_EgonPrecache // Precache.
};

weaponclass_t wpc_handgrenades =
{
	9, // Slot
	0, // Slot pos.
	"hand_grenades", // Ammo1
	"", // Ammo2
	1, // Ammo usage.
	0, // Clip size.
	"progs/v_grenade.mdl", // V_Model
	"Hand-Grenade", // Weapon name.
	WPN_HANDGRENADE, // Weapon I.D
	0, // Weapon flags
	W_GrenadePrimAttack, // Attack1
	W_NullFunc, // Attack2
	W_NullFunc, // Reload
	SUB_Null, // Post-Think function.
	W_GrenadeDeploy, // Deploy.
	W_GrenadeHolster, // Holster.
	W_GrenadeIdle, // Idle.
	W_GrenadePrecache // Precache.
};

weaponclass_t wpc_tripmine =
{
	9, // Slot
	1, // Slot pos.
	"tripmines", // Ammo1
	"", // Ammo2
	1, //
	0, // Clip size.
	"progs/v_tripmine.mdl", // V_Model
	"Tripmine", // Weapon name.
	WPN_TRIPMINE, // Weapon I.D
	0, // Weapon flags
	W_TripminePrimAttack, // Attack1
	W_NullFunc, // Attack2
	W_NullFunc, // Reload
	SUB_Null, // Post-Think function.
	W_TripmineDeploy, // Deploy.
	W_TripmineHolster, // Holster.
	W_TripmineIdle, // Idle.
	W_TripminePrecache // Precache.
};

weaponclass_t wpc_satchel =
{
	9, // Slot
	2, // Slot pos.
	"satchels", // Ammo1
	"", // Ammo2
	1, // 
	0, // Clip size.
	"progs/v_satchel.mdl", // V_Model
	"Satchel", // Weapon name.
	WPN_SATCHEL, // Weapon I.D
	0, // Weapon flags
	W_SatchelPrimAttack, // Attack1
	W_SatchelSecAttack, // Attack2
	W_NullFunc, // Reload
	SUB_Null, // Post-Think function.
	W_SatchelDeploy, // Deploy.
	W_SatchelHolster, // Holster.
	W_SatchelIdle, // Idle.
	W_SatchelPrecache // Precache.
};

weaponclass_t wpc_snark =
{
	9, // Slot
	3, // Slot pos.
	"snarks", // Ammo1
	"", // Ammo2
	1, // 
	0, // Clip size.
	"progs/v_squeak.mdl", // V_Model
	"Snarks", // Weapon name.
	WPN_SNARK, // Weapon I.D
	0, // Weapon flags
	W_SnarkPrimAttack, // Attack1
	W_NullFunc, // Attack2
	W_NullFunc, // Reload
	SUB_Null, // Post-Think function.
	W_SnarkDeploy, // Deploy.
	W_SnarkHolster, // Holster.
	W_SnarkIdle, // Idle.
	W_SnarkPrecache // Precache.
};

weaponclass_t weaponsclass[15] = {
	wpc_none,
	wpc_crowbar,
	wpc_glock,
	wpc_python,
	wpc_shotgun,
	wpc_mp5,
	wpc_crossbow,
	wpc_rpg,
	wpc_hornetgun,
	wpc_gauss,
	wpc_egon,
	wpc_handgrenades,
	wpc_tripmine,
	wpc_satchel,
	wpc_snark,
};

typedef struct {
	weaponclass_t weaps[4];
	float qt;
} weaponslot_t;

weaponslot_t weaponslots[10] = {
	{{wpc_none}, 1},
	{{wpc_crowbar}, 1},
	{{wpc_glock, wpc_python}, 2},
	{{wpc_shotgun}, 1},
	{{wpc_mp5}, 1},
	{{wpc_crossbow}, 1},
	{{wpc_rpg}, 1},
	{{wpc_hornetgun}, 1},
	{{wpc_gauss, wpc_egon}, 2},
	{{wpc_handgrenades, wpc_tripmine, wpc_satchel, wpc_snark}, 4}
};

enum {
	WEAPONSTAT_NOWEAPON,
	WEAPONSTAT_NOAMMO,
	WEAPONSTAT_AVAILABLE
};

/*
============
W_GetWeapon

Add WeaponID here to get
the code to read all of it's
info.
============
*/

float(float weap) W_GetWeapon = 
{
	switch (weap) 
	{
		case WPN_CROWBAR:			return 1;
		case WPN_GLOCK:				return 2;
		case WPN_PYTHON:			return 3;
		case WPN_SHOTGUN:			return 4;
		case WPN_MP5:				return 5;
		case WPN_CROSSBOW:			return 6;
		case WPN_RPG:				return 7;
		case WPN_HORNETGUN:			return 8;
		case WPN_GAUSS:				return 9;
		case WPN_EGON:				return 10;
		case WPN_HANDGRENADE:		return 11;
		case WPN_TRIPMINE:			return 12;
		case WPN_SATCHEL:			return 13;
		case WPN_SNARK:				return 14;
		default:					return 0;
	}
}

/*
============
W_CheckWeapon
============
*/

float(float weap, entity cl) W_CheckWeapon = 
{
	weaponclass_t weapcl = weaponsclass[W_GetWeapon(weap)];

	if (weap == WPN_NONE) 
		return WEAPONSTAT_AVAILABLE;
		
	if (!(cl.weapons & weap)) 
		return WEAPONSTAT_NOWEAPON;
	
	if ((cl.(clip_fields[W_GetClipField(weapcl.name)]) <= 0) && (cl.(ammo_fields[W_GetAmmoField(weapcl.ammo1)]) < weapcl.ammo_usage) && (weapcl.clip_size > 0))
		return WEAPONSTAT_NOAMMO;
	
	if (cl.(ammo_fields[W_GetAmmoField(weapcl.ammo1)]) < weapcl.ammo_usage && weapcl.clip_size <= 0 && !(weapcl.wpn_flags & WFL_USABLE_IF_EMPTY))
	{
		// THIS TOOK SO FUKKEN LONG TO FIGURE OUT!!!!!
		if ( cl.weapon & WPN_SATCHEL && W_SatchelHack(cl) )
			return WEAPONSTAT_AVAILABLE;
		else
			return WEAPONSTAT_NOAMMO;
	}

	//dprint3("Ammo: ", ftos(cl.(weapcl.ammofield)), "\n");
	return WEAPONSTAT_AVAILABLE;
};

/*
============
W_GetAmmoField
============
*/

float(string ammo_name) W_GetAmmoField =
{
	switch (ammo_name)
	{
		case "shells":				return 1;
		case "nails":				return 2;
		case "rockets":				return 3;
		case "cells":				return 4;
		case "hornets":				return 5;
		case "hand_grenades": 		return 6;
		case "satchels":			return 7;
		case "tripmines":			return 8;
		case "snarks":				return 9;
		default:					return 0;
	}
}

/*
============
W_GetAmmoItem
============
*/

float(string ammo_name) W_GetAmmoItem =
{
	switch (ammo_name)
	{
		case "shells":		return IT_SHELLS;
		case "nails":		return IT_NAILS;
		case "rockets":		return IT_ROCKETS;
		case "cells":		return IT_CELLS;
		default:			return 0;
	}
}

/*
============
W_GetClipFields
============
*/

float(string gun_name) W_GetClipField =
{
	switch (gun_name)
	{
		case "MP5":			return 1;
		case "Glock":		return 2;
		case "Shotgun":		return 3;
		case "Crossbow":	return 4;
		case "RPG":			return 5;
		case "Python":		return 6;
		default:			return 0;
	}
}

/*
============
W_ResetClipFields
============
*/

void() W_ResetClipFields =
{
	for (float i = 0; i < NUMBER_OF_WEAPONS; i++)
	{
		weaponclass_t weap = weaponsclass[i];
		if (weap.clip_size != 0)
		{
			self.(clip_fields[W_GetClipField(weap.name)]) = weap.clip_size;
		}
	}
}

/*
============
W_SetCurrentAmmo
============
*/

void() W_SetCurrentAmmo =
{
	weaponclass_t weap = weaponsclass[W_GetWeapon(self.weapon)];
	if (weap.clip_size != 0)
		self.currentammo = self.(clip_fields[W_GetClipField(weap.name)]);
	else
		self.currentammo = self.(ammo_fields[W_GetAmmoField(weap.ammo1)]);
}

/*
============
W_BestWeaponParms
============
*/

float(float weapons, entity cl, float waterlevel) W_BestWeaponParms =
{
	if (W_CheckWeapon(WPN_EGON, cl) == WEAPONSTAT_AVAILABLE && waterlevel <= 1)
		return WPN_EGON;
	if (W_CheckWeapon(WPN_GAUSS, cl) == WEAPONSTAT_AVAILABLE && waterlevel <= 1)
		return WPN_GAUSS;
	if (W_CheckWeapon(WPN_HORNETGUN, cl) == WEAPONSTAT_AVAILABLE)
		return WPN_HORNETGUN;
	if (W_CheckWeapon(WPN_CROSSBOW, cl) == WEAPONSTAT_AVAILABLE)
		return WPN_CROSSBOW;
	if (W_CheckWeapon(WPN_SHOTGUN, cl) == WEAPONSTAT_AVAILABLE && waterlevel <= 1)
		return WPN_SHOTGUN;
	if (W_CheckWeapon(WPN_MP5, cl) == WEAPONSTAT_AVAILABLE && waterlevel <= 1)
		return WPN_MP5;
	if (W_CheckWeapon(WPN_PYTHON, cl) == WEAPONSTAT_AVAILABLE && waterlevel <= 1)
		return WPN_PYTHON;
	if (W_CheckWeapon(WPN_GLOCK, cl) == WEAPONSTAT_AVAILABLE)
		return WPN_GLOCK;
	if (W_CheckWeapon(WPN_SNARK, cl) == WEAPONSTAT_AVAILABLE)
		return WPN_SNARK;
	if (W_CheckWeapon(WPN_CROWBAR, cl) == WEAPONSTAT_AVAILABLE)
		return WPN_CROWBAR;

	return WPN_NONE; 
};

/*
============
W_BestWeapon
============
*/

float() W_BestWeapon = 
{
	return W_BestWeaponParms(self.weapons, self, self.waterlevel);
};

/*
============
W_ChangeWeapon
============
*/

float(float weap) W_ChangeWeapon = 
{
	float weapstat = W_CheckWeapon(weap, self);

	if (weapstat < WEAPONSTAT_AVAILABLE){
		return weapstat;
	}

	weaponclass_t weapcl = weaponsclass[W_GetWeapon(weap)];
	self.weapon = weap;
	if (weapcl.clip_size != 0)
		self.currentammo = self.(clip_fields[W_GetClipField(weapcl.name)]);
	else
		self.currentammo = self.(ammo_fields[W_GetAmmoField(weapcl.ammo1)]);
	self.items &~= (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
	self.items |= W_GetAmmoItem(weapcl.ammo1);

	if (weapcl.ammo_usage <= 0)
		self.currentammo = 0;

	self.weaponmodel = weapcl.model;
	self.think = SUB_Null;
	
	weapcl.deploy(); // Call deploy function here..

	return 1;
}

/*
============
W_ChangeSlot
============
*/

float(float imp) W_ChangeSlot = 
{
	weaponslot_t newSlot = weaponslots[imp];
	weaponclass_t currentWeapon = weaponsclass[W_GetWeapon(self.weapon)];
	
	float weaponstat, firstweaponstat;
	float startSlotPos;
	float i;
	
	float holster = currentWeapon.holster();

	if (currentWeapon.slot == imp)
		startSlotPos = wrap(currentWeapon.slotpos + 1, 0, newSlot.qt - 1);
	else
		startSlotPos = 0;

	while (i < newSlot.qt) 
	{
		weaponstat = W_CheckWeapon(newSlot.weaps[startSlotPos].id, self);
		if (i == 0 || weaponstat == WEAPONSTAT_NOAMMO) firstweaponstat = weaponstat;
		if (weaponstat == WEAPONSTAT_AVAILABLE && (newSlot.weaps[startSlotPos].id != currentWeapon.id) && (holster == TRUE))
		{
			W_ChangeWeapon(newSlot.weaps[startSlotPos].id);
			return weaponstat;
		}
		startSlotPos = wrap(startSlotPos + 1, 0, newSlot.qt - 1);
		i++;
	}

	return firstweaponstat;
}

/*
============
W_CycleWeapon
============
*/

void(float stp) W_CycleWeapon = 
{
	float currentWeapon = W_GetWeapon(self.weapon);
	float next = wrap(currentWeapon + stp, 1, MAX_WEAPON_NUM);
	float i;
	float holster = weaponsclass[W_GetWeapon(self.weapon)].holster();
	
	while (next != currentWeapon && i <= MAX_WEAPON_NUM) 
	{
		//dprint3("Testing slot ", ftos(next), "...\n");
		if ((W_CheckWeapon(weaponsclass[next].id, self) == WEAPONSTAT_AVAILABLE) && (holster == TRUE)) 
		{
		//	dprint3("Fund! slot ", ftos(next), "\n");
			W_ChangeWeapon(weaponsclass[next].id);
			return;
		}
		next = wrap(next + stp, 1, MAX_WEAPON_NUM);
		i++;
	}
	if (i > MAX_WEAPON_NUM) W_ChangeWeapon(WPN_NONE);
}

/*
============
W_Attack

An attack impulse can be triggered now
============
*/

void() W_Attack = 
{
	weaponclass_t weap = weaponsclass[W_GetWeapon(self.weapon)];
	
	if (W_CheckWeapon(self.weapon, self) != WEAPONSTAT_AVAILABLE)
	{
		dprint(weap.name);
		return;
	}

	makevectors(self.v_angle);			// calculate forward angle for velocity
	float fired = (self.firemode == 1) ? weap.attack2() : weap.attack1();

	if (fired) self.show_hostile = time + 1;	// wake monsters up
};

/*
============
W_SetWeaponAnim
============
*/

void(float frame_start, float frame_end, float frame_reset, float framerate) W_SetWeaponAnim =
{
	self.weaponframe = frame_start;
	self.startframe = frame_start;
	self.targetframe = frame_end;
	self.endframe = frame_reset;
	
	if (framerate > 0)
	{
		self.fps = framerate;
		self.nextanim = time + ( 1.0 / self.fps );
	}
	else
	{
		self.nextanim = time;
	}
	
	// sprint(self, "seq info: fps:");
	// sprint(self, ftos(framerate));
	// sprint(self, " start:");
	// sprint(self, ftos(frame_start));
	// sprint(self, " target:");
	// sprint(self, ftos(frame_end));
	// sprint(self, " end:");
	// sprint(self, ftos(frame_reset));
	// sprint(self, "\n");
}

void(float frame_start, float frame_end, float frame_reset, float framerate) W_SetWeaponAnim2 =
{
	W_SetWeaponAnim(frame_start, frame_end, frame_reset, framerate);
	self.nextanim = time;
}

/*
===============

BULLETS

sg:		6 * 4 = 24		/ 48 / 72 / 96 / 120
ssg:	14 * 4 = 56		/ 112 / 168 / 224 / 280

sg:		5 * 5 = 25		/ 50 / 75 / 100 / 125
ssg:	11 * 5 = 55		/ 110 / 165 / 220 / 275
ssg:	12 * 5 = 60		/ 120 / 180 / 240 / 300

===============
*/

vector(vector dir, vector spread) SpreadVector = 
{
	return dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
}

/*
================
TraceAttack
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
vector(float damage, vector dir) TraceAttack =
{
	vector vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		if (trace_ent.multi_dmg >= trace_ent.health && (trace_ent.flags & FL_MONSTER || trace_ent.flags & FL_CORPSE))
		{
			trace_ent.gravity = 0.5;
			trace_ent.flags &= ~FL_ONGROUND;
			
			trace_ent.origin_z += 1.0;
			trace_ent.velocity_x += dir_x * (trace_ent.multi_dmg * 2.5);
			trace_ent.velocity_y += dir_y * (trace_ent.multi_dmg * 2.5);
			trace_ent.velocity_z += trace_ent.multi_dmg / 2;
		}
	
		SpawnBlood (org, vel*40, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else gunshot(org);

	return org;
}

float(entity t) HasBeenShotToDeath =
{
	if (t.multi_dmg < t.health) return FALSE;
	if (DamageCanKill(t,t.multi_dmg)) return TRUE;
	return FALSE;
}

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	vector src, direction;
	entity ig;
	float s, lim;
	
	if (shotcount <= 0) return;
	
	makevectors(self.v_angle);

	if (trace_debug) dprint3("*** firing ", ftos(shotcount), " bullets *\n\n");
	for (s = 0; s < shotcount; s++)
	{
		src = self.origin + v_forward*10;
		src_z = self.absmin_z + self.size_z * 0.7;
		direction = SpreadVector(dir, spread);
		
		if (trace_debug) dprint("* firing a bullet *\n");
		
		lim = 0;
		// check for trace-through cases
		for (ig = self; ig != world; lim++)	// ig == world if we hit a wall or hit nothing
		{
			traceline2(src, src + direction*2048, ig, 0);
			
			if (trace_ent == self)
				return;	// some notrace shit happened
		
			// if we've already pelted a monster enough to kill it, let additional bullets add 
			// up for possible gibs (ala quake), but trace them again through the target for 
			// better crowd control feels (ala doom).
			// this is only noticeable with big hordes of weak guys, but it makes big hordes of
			// weak guys not feel like solid ammo-sponge walls.
			if (trace_ent.takedamage && 
				(trace_ent.flags & FL_MONSTER || trace_ent.classname == "player" ) && 
				// some id shootables are actually trigger_multiples with health and SOLID_BBOX, so this doesn't work (see e1m6):
				//( trace_ent.solid == SOLID_BBOX || trace_ent.solid == SOLID_SLIDEBOX ) &&	
				HasBeenShotToDeath(trace_ent) )
			{
				TraceAttack (2+2*random(), direction);

				// start 0.1 unit forward, or else when shooting an adjacent enemy we'll
				// just hit ourselves again
				src = trace_endpos + direction * 0.1;
				ig = trace_ent;
				if (trace_debug) dprint3("bullet hit ", ig.classname, ", continuing thru\n");
			}
			else
			{
				if (trace_debug) dprint("bullet reached world\n");
				ig = world;
			}
			if (lim > 8)
			{
				dprint("bullet pen limit exceeded\n");
				break;
			}
		}
		
		if (trace_fraction != 1.0)
		{
			TraceAttack (4, direction);
		}
		
		if (trace_debug) dprint("bullet is over\n\n");
	}
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/

void() W_PrintWeaponState =
{
	sprint(self, "WeaponState: ");
	switch (self.weaponstate)
	{
		case WS_RELOAD:
		{
			sprint(self, "Reload.\n");
			break;
		}
		case WS_READY:
		{
			sprint(self, "Ready.\n");
			break;
		}
		case WS_SPECIAL_RELOAD:
		{
			sprint(self, "Special reload.\n");
			break;
		}
		case WS_DEPLOY:
		{
			sprint(self, "Deploy\n");
			break;
		}
	}
	
}

void() W_WeaponFrame =
{
	if (self.impulse)
		ImpulseCommands();

	// Grand ol' animation thinker!
	if (time > self.nextanim)
	{
		if ((self.weaponframe < self.targetframe) && self.targetframe)
		{
			self.weaponframe += 1;
			self.nextanim = time + ( 1.0 / self.fps );
		}
		else
		{
			if (self.endframe != -1)
			{
				if (self.targetframe)
					self.weaponframe = self.endframe;
				self.targetframe = 0;
			}
			else // Looping mode.
			{
				self.weaponframe = self.startframe;
			}
		}
	}

	// Get our gun's info..
	weaponclass_t weap = weaponsclass[W_GetWeapon(self.weapon)];
	float clip = self.(clip_fields[W_GetClipField(weap.name)]);
	float ammo = self.(ammo_fields[W_GetAmmoField(weap.ammo1)]);
	
	weap.postframe(); // Call all "PostFrame" functions..
	
	// Set to ready once we're finished with our deploy.
	if (self.weaponstate == WS_DEPLOY && self.attack_finished < time)
	{
		//W_PrintWeaponState(); // dev thing..
		self.weaponstate = WS_READY;
	}
	
	// Finish our reload!!!
	if ((self.attack_finished <= time) && (self.weaponstate == WS_RELOAD))
	{
		float result = min(weap.clip_size - clip, ammo);

		self.(ammo_fields[W_GetAmmoField(weap.ammo1)]) = self.(ammo_fields[W_GetAmmoField(weap.ammo1)]) - result;
		self.currentammo = self.(clip_fields[W_GetClipField(weap.name)]) += result;
		
		//W_PrintWeaponState(); // dev thing..
		self.weaponstate = WS_READY;
	}
	
	// check for attack
	if (self.weaponstate == WS_READY)
	{
		if (self.button0)
		{
			if (self.firemode == 1 && self.attack2_finished <= time)
			{
				if ((weap.ammo_usage > 0) && (self.currentammo <= 0))
				{
					self.fuser6 = TRUE; // this is the fire on empty check!!
				}
				W_Attack ();
				//W_PrintWeaponState(); // dev thing..
			}
			else if (self.firemode == 0 && self.attack_finished <= time)
			{
				if ((weap.ammo_usage > 0) && (self.currentammo <= 0))
				{
					self.fuser6 = TRUE; // this is the fire on empty check!!
				}
				W_Attack ();
				//W_PrintWeaponState(); // dev thing..
			}
		}
		else
		{
			if ((ammo > 0) && (clip <= 0) && (self.attack_finished < time) && (self.weaponstate != WS_RELOAD || self.weaponstate != WS_SPECIAL_RELOAD))
			{
				weap.reload();
				//W_PrintWeaponState(); // dev thing..
				return;
			}
			weap.idle();
		}
	}
}

/*
========
SuperDamageSound
========
*/
void() SuperDamageSound =
{
	if (!has_quad(self)) return;
	if (self.super_damage_finished < time + 3) return;
	if (self.super_sound < time)
	{
		self.super_sound = time + 0.9;
		sound (self, CHAN_POWERUP, "items/damage3.wav", 1, ATTN_NORM);
	}
}

/*
========
W_Precache
========
*/

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");
	precache_sound ("weapons/rocket1i.wav");	// nailgun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");		// sg
	precache_sound ("weapons/ric1.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");		// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");		// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");		// super spikes
	precache_sound ("weapons/tink1.wav");		// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");		// ssg
	precache_model2 ("progs/k_spike.mdl");
	precache_model ("progs/lavaball.mdl");	
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
//	precache_sound ("items/damage3.wav");

// ax sounds	
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound2 ("weapons/axhit1.wav");		// ax hit meat
	precache_sound2 ("weapons/axhit2.wav");		// ax hit meat 2
	precache_sound ("player/axhit1.wav");		// ax hit me
	precache_sound ("player/axhit2.wav");		// ax hit world
	
	precache_sound ("zombie/z_hit.wav");
	
	precache_sound ("weapons/357_cock1.wav");
	
	precache_sound ("weapons/pl_shell1.wav");
	precache_sound ("weapons/pl_shell2.wav");
	precache_sound ("weapons/pl_shell3.wav");
	precache_sound ("weapons/sshell1.wav");
	precache_sound ("weapons/sshell2.wav");
	precache_sound ("weapons/sshell3.wav");
	precache_sound ("weapons/debris1.wav");
	precache_sound ("weapons/debris2.wav");
	precache_sound ("weapons/debris3.wav");
	precache_sound ("weapons/explode3.wav");
	precache_sound ("weapons/explode4.wav");
	precache_sound ("weapons/explode5.wav");
	precache_sound ("weapons/grenade_hit1.wav");
	precache_sound ("weapons/grenade_hit2.wav");
	precache_sound ("weapons/grenade_hit3.wav");
	precache_sound ("weapons/g_bounce1.wav");
	precache_sound ("weapons/g_bounce2.wav");
	precache_sound ("weapons/g_bounce3.wav");
	precache_sound ("player/pl_step1.wav");
	precache_sound ("player/pl_step2.wav");
	precache_sound ("player/pl_step3.wav");
	precache_sound ("player/pl_step4.wav");
	precache_model ("progs/shell.mdl");
	precache_model ("progs/hl_grenade.mdl");
	precache_model ("progs/hl_explode.spr");
	precache_model ("progs/hl_explode1.spr");
	precache_model ("progs/shotgunshell.mdl");
	precache_sound("items/weapondrop1.wav");
	precache_sound("items/suitchargeok1.wav");
	precache_sound("items/gunpickup2.wav");
	
	for (float i = 0; i < NUMBER_OF_WEAPONS; i++)
	{
		weaponclass_t weap = weaponsclass[i];
		weap.precache();
	}
	
	HL_PrecacheItems();
}

/*
========
W_ResetWeaponState
========
*/

void() W_ResetWeaponState =
{
	SUB_CallAsSelf(player_run, self.animcontroller);		// get out of any weapon firing states
}