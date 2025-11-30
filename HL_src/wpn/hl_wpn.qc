//======================================
//
//	hl_wpn.qc
//	Code for basic Half-Life weapons.
// 	Based on Half-Life SDK 1.0 code..
//
//	History:
//	11.14.25: Started. I have a little
//	gauss gun now :)
//	11.15.25: Finished Gauss gun,
//	starting on MP5.
//	11.16.25: mp5 finished.
//	11.17.25: finished glock AND shotgun!!
//	11.19.25: corpse stuff, starting
//	on crowbar.
//	11.22.25: crossbow, HORNET!!
//	11.23.25 : rpg.
//	11.25.25 : egon, bugfixes
//	11.27.25 : satchel, tripmine, handgrenade
//	11.28.25: gave satchel,tripmine, handgrenade
//	proper models & fixed them all.
//
//======================================

/*
============
HL_RetireWeapon
============
*/

void() HL_RetireWeapon =
{
	self.weaponmodel = "";
	W_ChangeWeapon(W_BestWeapon());
}

/*
============
HL_PlayEmptySound
============
*/

void() HL_PlayEmptySound =
{
	if (!self.fuser5)
	{
		sound(self, CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM); 
		self.fuser5 = 1;
	}
};

void() HL_ResetEmptySound = {self.fuser5 = 0;};

/*
============
HL_DefaultDeploy
============
*/

void(float frame_start, float frame_end, float frame_reset, float framerate) HL_DefaultDeploy = 
{
	self.weaponstate = WS_DEPLOY;
	self.attack_finished = time + 0.5;
	self.nextidle = time + 1.0;
	self.fuser1 = self.fuser2 = self.fuser3 = self.fuser4 = self.fuser5 = self.fuser6 = 0.0;
	self.attack_phase = 0;
	W_SetWeaponAnim2(frame_start, frame_end, frame_reset, framerate);
};

/*
============
HL_DefaultReload
============
*/

float(float frame_start, float frame_end, float frame_reset, float framerate, float clipsize, float delay, optional float idle = 3.0) HL_DefaultReload = 
{
	weaponclass_t weap = weaponsclass[W_GetWeapon(self.weapon)];

	if (self.(ammo_fields[W_GetAmmoField(weap.ammo1)]) < weap.ammo_usage)
		return FALSE;

	float clip = min(clipsize - self.(clip_fields[W_GetClipField(weap.name)]), self.(ammo_fields[W_GetAmmoField(weap.ammo1)]));
	
	if (clip <= 0)
		return FALSE;

	W_SetWeaponAnim2(frame_start, frame_end, frame_reset, framerate);
	
	self.attack_finished = time + delay;
	self.nextidle = time + idle; // Altered to let .357 finish it's reload.
	self.weaponstate = WS_RELOAD;
	return TRUE;
};

/*
============
HL_CorpseChecker
============
*/

entity(vector endpos) HL_CorpseChecker =
{
	for (float i = 0; i < 3; i++)
	{
		entity ent = world;
		ent = findradius(endpos, 48);
		
		// Increase endpos height ever iteration
		// to account for diff. between endpos and
		// actual corpse BBOX.
		endpos_z += 4;
		
		while (ent)
		{
			if (ent.deadflag == DEAD_DEAD)
			{
				trace_ent = ent;
				sprint(self, "Hit something!\n");
				return ent;
			}
			ent = ent.chain;
		}
	}
	
	return world;
}

/*
============
HL_FireBullets
============
*/

void(float shots, vector src, vector dir, vector spread, float distance, float damage, float can_gib = FALSE) HL_FireBullets =
{
	ClearMultiDamage();
	for (float shot = 1; shot <= shots; shot++)
	{
		float x, y, z;
		do {
			x = random(-0.5, 0.5) + random(-0.5, 0.5);
			y = random(-0.5, 0.5) + random(-0.5, 0.5);
			z = x*x+y*y;
		} while ( z > 1 );
		
		vector newdir = dir + x * spread_x * v_right + y * spread_y * v_up;
		vector end = src + newdir * distance;
		
		traceline(src, end, 0, self);
		
		if (trace_fraction != 1.0)
		{
			TraceAttack (damage, dir);
		}
		
		// Corpse checker!
		// Do this check on the final pellet so
		// things don't get to computationally intense!
		// - serecky 11.19.25
		if (shot == shots)
		{
			traceline(src, src + dir * distance, 0, self);
			entity corpse = HL_CorpseChecker(trace_endpos);
			
			if (corpse != world)
			{
				trace_ent = corpse;
				TraceAttack (damage, dir);
			}
		}
		// Put bubble trail here...
	}

	// Basic gib check!
	if (!can_gib && (trace_ent.deadflag != DEAD_NO) && (trace_ent.multi_dmg > trace_ent.health))
	{
		trace_ent.multi_dmg = 0;
		trace_ent.health = 0;
	}
		
	ApplyMultiDamage();
}

/*
================
BrassSound
================
*/

void() BrassSound =
{
	if ((other != world))
		return;

	local float r;
	r = random();
	
	if (self.model != "progs/shotgunshell.mdl") 
	{
		if (r < 0.333)
			sound (self, CHAN_WEAPON, "weapons/pl_shell1.wav", 1, ATTN_NORM);
		else if (r < 0.666)
			sound (self, CHAN_WEAPON, "weapons/pl_shell2.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "weapons/pl_shell3.wav", 1, ATTN_NORM);	
	}
	else 
	{
		if (r < 0.333)
			sound (self, CHAN_WEAPON, "weapons/sshell1.wav", 1, ATTN_NORM);
		else if (r < 0.666)
			sound (self, CHAN_WEAPON, "weapons/sshell2.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "weapons/sshell3.wav", 1, ATTN_NORM);	
	}
};

/*
================
EjectBrass
================
*/

void(string shellmodel, vector org, vector vel) EjectBrass =
{
	local	entity new;

	new = spawn();
	setorigin (new, org);
	setmodel (new, shellmodel);
	setsize (new, '0 0 0', '0 0 0');

	new.velocity = vel;
	new.angles = '1 1 1' * random(-255, 255);
	new.angles_y = self.angles_y;
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_TRIGGER;
	new.owner = new.trueowner = self;
	new.touch = BrassSound;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 1.0;
	new.frame = 0;
	new.flags = 0;
};

/*
============
Crowbar

// 0 - 10 : deploy 20 fps
// 11 - 20 : attack 1 20 fps
// 21 - 30 : attack 1 strike 20 fps
// 31 - 43 : attack 2 20 fps
// 44 - 56 : attack 2 strike 20 fps
// 57 - 73 : attack 3 20 fps
// 74 - 89 : attack 3 strike 20 fps
// 90 - 105 : idle1 8 fps
// 106 - 149 : idle2 8 fps
// 150 - 193 : idle3 8 fps
// 194 - 204 : holster 20 fps

============
*/

/*
============
W_CrowbarPrecache
============
*/

void() W_CrowbarPrecache =
{
	precache_model("progs/v_crowbar.mdl");
	//precache_model("progs/w_crowbar.mdl");
	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hit2.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_hitbod2.wav");
	precache_sound("weapons/cbar_hitbod3.wav");
	precache_sound("weapons/cbar_miss1.wav");
}

/*
============
W_CrowbarDeploy
============
*/

void() W_CrowbarDeploy =
{
	HL_DefaultDeploy(0, 10, 10, 20);
}

/*
============
W_CrowbarPrimAttack
============
*/

float() W_CrowbarPrimAttack =
{
	if (!W_CrowbarSwing(1))
	{
		self.fuser1 = time + 0.1;
	}
	return TRUE;
}

/*
============
W_CrowbarSwing
============
*/

float(float first) W_CrowbarSwing =
{
	makevectors(self.v_angle);
	vector src = self.origin + self.view_ofs;
	vector end = src + v_forward * 64;
	float hit = FALSE;
	float r;
	
	traceline(src, end, 0, self);
	
	if (HL_CorpseChecker(trace_endpos) != world)
	{
		trace_ent = HL_CorpseChecker(trace_endpos);
		trace_fraction = 0.0;
	}
	
	if (trace_fraction >= 1.0)
	{
		if (first)
		{
			r = random();
			
			if (r < 0.33)
				W_SetWeaponAnim2(11, 20, 10, 20);
			else if (r < 0.66)
				W_SetWeaponAnim2(31, 43, 10, 20);
			else
				W_SetWeaponAnim2(57, 73, 10, 20);
				
			self.attack_finished = time + 0.5;
			sound(self, CHAN_WEAPON, "weapons/cbar_miss1.wav", 1, ATTN_NORM);
		}
	}
	else
	{
		hit = TRUE;
		
		r = random();
		
		if (r < 0.33)
			W_SetWeaponAnim2(21, 30, 10, 20);
		else if (r < 0.66)
			W_SetWeaponAnim2(44, 56, 10, 20);
		else
			W_SetWeaponAnim2(74, 89, 10, 20);
			
		ClearMultiDamage();
		if ( self.attack_finished + 1 < time || deathmatch )
		{
			TraceAttack(10, v_forward);
		}
		else
		{
			TraceAttack(5, v_forward);
		}
		ApplyMultiDamage();
		self.attack_finished = time + 0.25;
		
		if (trace_ent)
		{
			r = random();
		
			if (r < 0.33)
				sound(self, CHAN_WEAPON, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
			else if (r < 0.66)
				sound(self, CHAN_WEAPON, "weapons/cbar_hitbod2.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_WEAPON, "weapons/cbar_hitbod3.wav", 1, ATTN_NORM);
		}
		else
		{
			if (r < 0.5)
				sound(self, CHAN_ITEM, "weapons/cbar_hit1.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_ITEM, "weapons/cbar_hit2.wav", 1, ATTN_NORM);
		}
	}
	
	return hit;
}

/*
============
W_CrowbarPostFrame
============
*/

void() W_CrowbarPostFrame =
{
	if (self.fuser1 < time && self.fuser1)
	{
		W_CrowbarSwing(0);
		self.fuser1 = 0.0;
	}
}

/*
============
Glock

// 8 dmg
// 0 - 15 : 16 fps draw
// 16 - 27 : 20 fps shoot
// 28 - 39 : 20 fps shoot slideback
// 40 - 81 : 18 fps reload slideback
// 82 - 123 : 18 fps reload
// 124 - 154 : 8 fps idle1
// 155 - 175 : 8 fps idle2
// 176 - 201 : 7 fps idle3
// 202 - 217 : 16 fps holster

============
*/

/*
============
W_GlockPrecache
============
*/

void() W_GlockPrecache =
{
	precache_model("progs/v_9mmhandgun.mdl");
	//precache_model("progs/w_9mmhandgun.mdl");
	precache_sound("items/9mmclip1.wav");
	precache_sound("items/9mmclip2.wav");
	precache_sound ("weapons/pl_gun3.wav");
}

/*
============
W_GlockDeploy
============
*/

void() W_GlockDeploy = 
{
	HL_DefaultDeploy(0, 15, 15, 16);
};

/*
============
W_GlockPrimAttack
============
*/

float() W_GlockPrimAttack =
{
	return W_GlockFire('0.01 0.01 0.01', 0.3, AUTOAIM_DIST);
}

/*
============
W_GlockSecAttack
============
*/

float() W_GlockSecAttack =
{
	return W_GlockFire('0.1 0.1 0.1', 0.2, 0);
}

/*
============
W_GlockFire
============
*/

float(vector spread, float nextattack, float dist_autoaim) W_GlockFire =
{
	if (self.currentammo <= 0)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.2;
		return FALSE;
	}
	
	self.currentammo = self.clip_glock -= 1;
	
	self.effects |= EF_MUZZLEFLASH;
	
	if (self.currentammo != 0)
		W_SetWeaponAnim2(16, 27, 15, 20);
	else
		W_SetWeaponAnim2(28, 39, 39, 20);
		
	makevectors(self.v_angle + self.punchangle);
	
	vector shellvel = self.velocity + v_right * random(50,70) + v_up * random(100,150) + v_forward * 25;
	EjectBrass("progs/shell.mdl", self.origin + self.view_ofs + v_up * -12 + v_forward * 32 + v_right * 6, shellvel);
	sound(self, CHAN_WEAPON, "weapons/pl_gun3.wav", random(0.92, 1.0), ATTN_NORM);
	
	vector dir = aim (self, AUTOAIM_DIST);
	HL_FireBullets(1, self.origin + self.view_ofs, dir, spread, 8192, 16, FALSE);
	
	self.attack_finished = self.attack2_finished = time + nextattack;
	self.nextidle = time + random(10,15);
	self.punchangle_x -= 2;
	return TRUE;
}

/*
============
W_GlockReload
============
*/

float() W_GlockReload =
{
	float result;
	
	if (self.currentammo == 0)
		result = HL_DefaultReload(40, 81, 15, 18, 17, 1.5);
	else
		result = HL_DefaultReload(82, 123, 15, 18, 17, 1.5);
		
	if (result)
		self.nextidle = time + random(10,15);
	return result;
}

/*
============
W_GlockIdle
============
*/

void() W_GlockIdle = 
{
	HL_ResetEmptySound();
	if (self.nextidle > time)
		return;
		
	if (self.currentammo != 0)
	{
		float r = random();
		if (r < 0.3)
		{
			W_SetWeaponAnim2(124, 154, -1, 8);
			self.nextidle = time + 49.0 / 16.0;
		}
		else if (r < 0.6)
		{
			W_SetWeaponAnim2(155, 175, -1, 8);
			self.nextidle = time + 60.0 / 16.0;
		}
		else
		{
			W_SetWeaponAnim2(176, 201, -1, 8);
			self.nextidle = time + 40.0 / 16.0;
		}
	}
}

/*
============
W_GlockIdle
============
*/

void() W_GlockEvents =
{
	if (self.weaponframe == 44 || self.weaponframe == 86)
		sound(self, CHAN_WEAPON, "items/9mmclip2.wav", 1.0, ATTN_NORM);
	if (self.weaponframe == 62 || self.weaponframe == 104)
		sound(self, CHAN_WEAPON, "items/9mmclip1.wav", 1.0, ATTN_NORM);
}

/*
============
//python
// 20 fps = regular
// 8 fps = idle
// 0-10 draw
// 11 - 31 shoot
// 32 - 77 fidget loop
// 78 - 97 idle1 loop
// 98 - 114 idle2 loop
// 115 - 138 idle3 loop
// 139 - 200 reload
// 201 - 211 holster
============
*/

/*
============
W_PythonPrecache
============
*/

void() W_PythonPrecache =
{
	precache_model("progs/v_357.mdl");
	//precache_model("progs/w_357.mdl");
	//precache_model("progs/w_357ammobox.mdl");
	precache_sound("items/9mmclip1.wav");              
	precache_sound ("weapons/357_reload1.wav");
	precache_sound ("weapons/357_cock1.wav");
	precache_sound ("weapons/357_shot1.wav");
	precache_sound ("weapons/357_shot2.wav");
}

/*
============
W_PythonDeploy
============
*/

void() W_PythonDeploy = 
{
	HL_DefaultDeploy(0, 10, 10, 20);
};

/*
============
W_PythonDeploy
============
*/

float() W_PythonHolster =
{
	if (self.fuser2)
	{
		//sprint(self, "test\n");
		W_PythonSecAttack();
	}
	return TRUE;
}

/*
============
W_PythonPrimAttack
============
*/

float() W_PythonPrimAttack =
{
	if (self.waterlevel == 3)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.15;
		return FALSE;
	}

	if (self.currentammo <= 0)
	{
		if (!self.fuser6)
		{
			W_PythonReload();
		}
		else
		{
			sound(self, CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM);
			self.attack_finished = time + 0.15;
		}
		return FALSE;
	}

	self.currentammo = self.clip_python -= 1;
	W_SetWeaponAnim2(11, 31, 31, 20);
	
	self.effects |= EF_MUZZLEFLASH;
	
	if (random() < 0.5)
	{
		sound(self, CHAN_WEAPON, "weapons/357_shot1.wav", random(0.8, 0.9), ATTN_NORM);
	}
	else
	{
		sound(self, CHAN_WEAPON, "weapons/357_shot2.wav", random(0.8, 0.9), ATTN_NORM);
	}
	
	makevectors(self.v_angle + self.punchangle);
	vector src = self.origin + self.view_ofs;
	vector myaim = aim(self, AUTOAIM_DIST);
	
	HL_FireBullets(1, src, myaim, VECTOR_CONE_1DEGREES, 8192, 36, FALSE);
	
	self.attack_finished = time + 0.75;
	self.nextidle = time + random(10, 15);
	self.punchangle_x -= 10;
	return TRUE;
}

/*
============
W_PythonSecAttack
============
*/

float() W_PythonSecAttack =
{
	if (self.fuser2)
	{
		stuffcmd(self, "unzoom\n");
		self.fuser2 = 0;
	}
	else
	{
		stuffcmd(self, "zoom_python\n");
		self.fuser2 = 1;
	}
	
	self.attack2_finished = time + 0.5;
	return TRUE;
}


/*
============
W_PythonReload
============
*/

float() W_PythonReload =
{
	float result = HL_DefaultReload(139, 200, 200, 20, 6, 2.0, 3.1);
	
	if (self.fuser2)
	{
		//sprint(self, "test\n");
		W_PythonSecAttack();
	}
	
	if (result)
	{
		self.fuser1 = time + 1.5;
		self.nextidle = time + 4.0;
	}
	return result;
}

/*
============
W_PythonIdle
============
*/

void() W_PythonIdle =
{
	HL_ResetEmptySound();
	
	if (self.fuser1 != 0 && self.fuser1 <= time)
	{
		sound(self, CHAN_WEAPON, "weapons/357_reload1.wav", random(0.8, 0.9), ATTN_NORM);
		self.fuser1 = 0;
	}
	
	if (self.nextidle > time)
		return;
		
	float r = random();
	
	if (r <= 0.5)
	{
		W_SetWeaponAnim2(78, 97, -1, 8);
		self.nextidle = time + (20.0/8.0);
	}
	else if (r <= 0.7)
	{
		W_SetWeaponAnim2(98, 114, -1, 8);
		self.nextidle = time + (16.0/8.0);
	}
	else if (r <= 0.9)
	{
		W_SetWeaponAnim2(115, 138, -1, 8);
		self.nextidle = time + (23.0/8.0);
	}
	else
	{
		W_SetWeaponAnim2(32, 77, -1, 8);
		self.nextidle = time + (45.0/8.0);
	}
}

/*
============
Shotgun

// 0 - 10 : draw 20 fps
// 11 - 31 : shoot 20 fps
// 32 - 52 : big shoot 13 fps
// 53 - 61 : reload start 12 fps
// 62 - 71 : insert shell 16 fps
// 72 - 82 : finish reloading 13 fps
// 83 - 103 : idle1 fps 9
// 104 - 124 : idle2 fps 9
// 125 - 185 : idle3 fps 12
// 186 - 193 : holster 20 fps

============
*/

/*
============
W_ShotgunPrecache
============
*/

void() W_ShotgunPrecache =
{
	precache_model("progs/v_shotgun.mdl");
	precache_sound("items/9mmclip1.wav");              
	precache_sound ("weapons/dbarrel1.wav");
	precache_sound ("weapons/sbarrel1.wav");
	precache_sound ("weapons/reload1.wav");
	precache_sound ("weapons/reload3.wav");
	precache_sound ("weapons/357_cock1.wav");
	precache_sound ("weapons/scock1.wav");
}

/*
============
W_ShotgunDeploy
============
*/

void() W_ShotgunDeploy = 
{
	HL_DefaultDeploy(0, 10, 10, 20);
};

/*
============
W_ShotgunPrimAttack
============
*/

float() W_ShotgunPrimAttack =
{
	if (self.waterlevel == 3)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.15;
		return FALSE;
	}
	
	if (self.currentammo <= 0)
	{
		W_ShotgunReload();
		if (self.currentammo == 0)
			HL_PlayEmptySound();
		return FALSE;
	}
	
	self.currentammo = self.clip_shotgun -= 1;
	self.effects |= EF_MUZZLEFLASH;
	
	W_SetWeaponAnim2(11, 31, 31, 20);
	
	makevectors(self.v_angle + self.punchangle);
	
	vector shellvel = self.velocity + (v_right * random (50,70)) + (v_up * random(100,150)) + (v_forward * 25);
	EjectBrass("progs/shotgunshell.mdl", self.origin + self.view_ofs + (v_up * -12) + (v_forward * 20) + (v_right * 4), shellvel);

	sound(self, CHAN_WEAPON, "weapons/sbarrel1.wav", random(0.95, 1.0), ATTN_NORM);
	
	vector src = self.origin + self.view_ofs;
	vector dir = aim (self, AUTOAIM_DIST);
	
	if (deathmatch)
		HL_FireBullets(4, src, dir, VECTOR_CONE_10DEGREES, 2048, 10, FALSE);
	else
		HL_FireBullets(6, src, dir, VECTOR_CONE_10DEGREES, 2048, 10, FALSE);
		
	if (self.currentammo != 0)
	{
		self.fuser1 = time + 0.5;
		self.nextidle = time + 5.0;
	}
	
	self.attack_finished = time + 0.75;
	self.attack2_finished = time + 0.75;
	self.punchangle_x -= 5;
	return TRUE;
}

/*
============
W_ShotgunSecAttack
============
*/

float() W_ShotgunSecAttack =
{
	if (self.waterlevel == 3)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.15;
		return FALSE;
	}
	
	if (self.currentammo <= 1)
	{
		W_ShotgunReload();
		HL_PlayEmptySound();
		return FALSE;
	}
	
	self.currentammo = self.clip_shotgun -= 2;
	self.effects |= EF_MUZZLEFLASH;
	
	W_SetWeaponAnim2(32, 52, 31, 13);
	
	makevectors(self.v_angle + self.punchangle);
	
	for (float i = 0; i < 2; i++)
	{
		vector shellvel = self.velocity + (v_right * random (50,70)) + (v_up * random(100,150)) + (v_forward * 25);
		EjectBrass("progs/shotgunshell.mdl", self.origin + self.view_ofs + (v_up * -12) + (v_forward * 20) + (v_right * 4), shellvel);
	}

	sound(self, CHAN_WEAPON, "weapons/dbarrel1.wav", random(0.98, 1.0), ATTN_NORM);
	
	vector src = self.origin + self.view_ofs;
	vector dir = aim (self, AUTOAIM_DIST);
	
	if (deathmatch)
		HL_FireBullets(8, src, dir, VECTOR_CONE_10DEGREES, 2048, 12, TRUE);
	else
		HL_FireBullets(12, src, dir, VECTOR_CONE_10DEGREES, 2048, 12, TRUE);
		
	if (self.currentammo != 0)
	{
		self.fuser1 = time + 0.95;
		self.nextidle = time + 6.0;
	}
	
	self.attack_finished = time + 1.5;
	self.attack2_finished = time + 1.5;
	self.punchangle_x -= 10;
	return TRUE;
}

/*
============
W_ShotgunReload
============
*/

float() W_ShotgunReload =
{
	if (self.ammo_shells > 0 && self.clip_shotgun != 8)
	{
		self.attack_phase = 1;
		self.weaponstate = WS_SPECIAL_RELOAD;
		W_SetWeaponAnim2(53, 61, 61, 12); // set reload start from here..
		return TRUE;
	}
	return FALSE;
}

/*
============
W_ShotgunIdle
============
*/

void() W_ShotgunIdle =
{
	HL_ResetEmptySound();
	
	if (self.weaponstate != WS_READY)
		return;
	
	if (self.fuser1 && self.fuser1 < time)
	{
		sound(self, CHAN_WEAPON, "weapons/scock1.wav", 1.0, ATTN_NORM);
		self.fuser1 = 0;
	}
	
	if (self.nextidle > time)
		return;
		
	float r = random();
	
	if (r <= 0.8)
	{
		W_SetWeaponAnim2(125, 185, -1, 12);
		self.nextidle = time + (60.0/12.0);
	}
	else if (r <= 0.95)
	{
		W_SetWeaponAnim2(83, 103, -1, 9);
		self.nextidle = time + (20.0/9.0);
	}
	else
	{
		W_SetWeaponAnim2(104, 124, -1, 9);
		self.nextidle = time + (20.0/9.0);
	}
}

/*
============
W_ShotgunPostThink
============
*/

void() W_ShotgunPostThink =
{
	// Code reused from my old CSWEAPONS mod...
	// - serecky 11.17.25
	if (self.weaponstate == WS_SPECIAL_RELOAD)
	{
		switch (self.attack_phase) 
		{
			case 1:
			{
				if (self.weaponframe == 61)
					self.attack_phase = 2;
			}
			break;
			
			case 2:
			{
				if (((self.button0) && (self.clip_shotgun >= 1) && (self.firemode == 0))
				|| ((self.button0) && (self.clip_shotgun >= 2) && (self.firemode == 1))) // If we want to shoot..
				{
					self.attack_phase = 0;
					self.weaponstate = WS_READY;
				}
				else if (self.attack_finished <= time) 
				{
					if ((self.clip_shotgun < 8) && (self.ammo_shells >= 1)) // Refill our clip!!!
					{
						W_SetWeaponAnim2(62, 71, 62, 16);
						
						if (random() < 0.5)
							sound(self, CHAN_WEAPON, "weapons/reload1.wav", 1.0, ATTN_NORM);
						else
							sound(self, CHAN_WEAPON, "weapons/reload3.wav", 1.0, ATTN_NORM);
						
						self.ammo_shells -= 1;
						self.currentammo = self.clip_shotgun += 1;
						self.attack_finished = time + 0.5;
						
					}
					else // We're done with our reload!
					{
						W_SetWeaponAnim2(72, 82, 82, 13);

						sound(self, CHAN_WEAPON, "weapons/scock1.wav", 1.0, ATTN_NORM);
						
						self.currentammo = self.clip_shotgun;
						self.nextidle = time + 1.5;
						
						self.attack_phase = 0;
						self.weaponstate = WS_READY;
					}
				}
			}
			break;
		}
	}
}

/*
============
MP5

Frames:
0 - 8 : Deploy ( 20 fps )
9 - 15 : Shoot 1 ( 10 fps )
16 - 22 : Shoot 2 ( 10 fps )
23 - 29 : Shoot 3 ( 10 fps )
30 - 52 : Grenade ( 20 fps )
53 - 84 : Reload ( 20 fps )
85 - 116 : Idle1 ( 10 fps )
117 - 157 : Idle2 ( 8 fps )
158 - 166 : Holster ( 20 fps )

============
*/

/*
============
W_MP5Precache
============
*/

void() W_MP5Precache =
{
	precache_model("progs/v_9mmAR.mdl");
	//precache_model("models/w_9mmAR.mdl");
	//precache_model("models/w_9mmARclip.mdl");
	precache_sound("items/9mmclip1.wav");
	precache_sound("items/clipinsert1.wav");
	precache_sound("items/cliprelease1.wav");
	precache_sound ("weapons/hks1.wav");
	precache_sound ("weapons/hks2.wav");
	precache_sound ("weapons/hks3.wav");
	precache_sound( "weapons/glauncher.wav" );
	precache_sound( "weapons/glauncher2.wav" );
	precache_sound ("weapons/357_cock1.wav");
};

/*
============
W_MP5Deploy
============
*/

void() W_MP5Deploy = 
{
	HL_DefaultDeploy(0, 8, 8, 20);
};

/*
============
W_MP5PrimAttack
============
*/

float() W_MP5PrimAttack =
{
	if (self.waterlevel == 3)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.15;
		return FALSE;
	}
	
	if (self.currentammo <= 0)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.15;
		return FALSE;
	}
	
	self.currentammo = self.clip_mp5 = self.clip_mp5 - 1;
	self.effects |= EF_MUZZLEFLASH;
	
	local float r = random();
	
	if (r <= 0.33)
		W_SetWeaponAnim2(9, 15, 8, 10);
	else if (r <= 0.66)
		W_SetWeaponAnim2(16, 22, 8, 10);
	else
		W_SetWeaponAnim2(23, 29, 8, 10);
	
	if (random() < 0.5)
		sound(self, CHAN_WEAPON, "weapons/hks1.wav", 1.0, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "weapons/hks2.wav", 1.0, ATTN_NORM);
	
	makevectors(self.v_angle + self.punchangle);
	
	vector shellvel = self.velocity + (v_right * random (50,70)) + (v_up * random(100,150)) + (v_forward * 25);
	EjectBrass("progs/shell.mdl", self.origin + self.view_ofs + (v_up * -12) + (v_forward * 20)
				+ (v_right * 4), shellvel);
	
	vector src = self.origin + self.view_ofs;
	vector dir = aim (self, AUTOAIM_DIST);
	
	if (deathmatch)
		HL_FireBullets(1, src, dir, VECTOR_CONE_6DEGREES, 8192, 10, FALSE);
	else
		HL_FireBullets(1, src, dir, VECTOR_CONE_3DEGREES, 8192, 10, FALSE);
	// Buffed damage for single-player..
	
	if (!(self.items & IT_NAILS))
	{
		self.items &~= (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
		self.items |= IT_NAILS;
	}	

	self.attack_finished = time + 0.1;
	if (self.attack_finished < time)
		self.attack_finished = time + 0.1;
	
	self.nextidle = time + random(10, 15);
	self.punchangle_x = random(-2, 2);
	return TRUE;
};

/*
============
W_MP5SecAttack
============
*/

float() W_MP5SecAttack =
{
	if (self.waterlevel == 3)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.15;
		return FALSE;
	}
	
	if (self.ammo_rockets <= 0)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.15;
		return FALSE;
	}
	
	W_SetWeaponAnim2(30, 52, 8, 20);
	
	if (random() < 0.5)
		sound(self, CHAN_WEAPON, "weapons/glauncher.wav", 0.8, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "weapons/glauncher2.wav", 0.8, ATTN_NORM);
		
	W_CreateContactGren(self.origin + self.view_ofs + v_forward * 16, v_forward * 800);
		
	self.currentammo = self.ammo_rockets -= 1;
		
	if (!(self.items & IT_ROCKETS))
	{
		self.items &~= (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS);
		self.items |= IT_ROCKETS;
	}
		
	self.attack_finished = time + 1.0;
	self.attack2_finished = time + 1.0;
	self.nextidle = time + 5.0;
		
	self.punchangle_x -= 10;
	return TRUE;
}

/*
============
W_MP5Reload
============
*/

float() W_MP5Reload =
{
	return HL_DefaultReload(53, 84, 8, 20, 50, 1.5);
}

/*
============
W_MP5Idle
============
*/

void() W_MP5Idle =
{
	HL_ResetEmptySound();
	
	if (self.nextidle > time)
		return;
		
	if (random() < 0.5)
		W_SetWeaponAnim2(85, 116, 8, 10);
	else
		W_SetWeaponAnim2(117, 157, 8, 8);
		
	self.nextidle = time + random(10,15);
}

/*
============
W_MP5Idle
============
*/

void() W_MP5Events =
{
	if (self.weaponframe == 56)
		sound(self, CHAN_WEAPON, "items/cliprelease1.wav", 1.0, ATTN_NORM);
	if (self.weaponframe == 69)
		sound(self, CHAN_WEAPON, "items/clipinsert1.wav", 1.0, ATTN_NORM);
}

/*
============
// CROSSBOW
// uses up all possible
// frames for mdl
// 0 - 10 : deploy 20 fps
// 11- 21 : deploy empty 20 fps
// 22 - 59 : fire 20 fps
// 60 - 70 : fire empty 20 fps
// 71 - 139 : reload 15 fps
// 140 - 170 : idle1 8 fps
// 171 - 191 : idle2  8 fps
// 192 - 212 : fidget 1 8 fps 
// 213 - 233 : fidget 2 8 fps
// 234 - 244 : holster 20 fps
// 245 - 254 : empty holster 20 fps
============
*/

/*
============
W_BoltSpawn
============
*/

entity() W_BoltSpawn =
{
	entity bolt;
	bolt = spawn();
	
	bolt.classname = "bolt";
	bolt.movetype = MOVETYPE_FLYMISSILE;
	bolt.solid = SOLID_BBOX;
	bolt.touch = W_BoltTouch;
	
	setmodel(bolt, "progs/xbolt.mdl");
	setorigin(bolt, bolt.origin);
	setsize(bolt, VEC_ORIGIN, VEC_ORIGIN);
	return bolt;
}

/*
============
W_BoltTouch
============
*/

void() W_BoltTouch =
{
	self.touch = SUB_Null;
	
	if (other && other.takedamage)
	{
		vector dir1 = self.angles; // change if we have an owmer
	
		if (self.owner)
		{
			makevectors(self.owner.v_angle);
			dir1 = v_forward;
		}
		
		ClearMultiDamage();
		
		trace_ent = other;
		trace_endpos = self.origin;
		TraceAttack(50, dir1);
		
		ApplyMultiDamage();
		
		self.velocity = '0 0 0';
		
		if (random() < 0.5)
			sound(self, CHAN_WEAPON, "weapons/xbow_hitbod1.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "weapons/xbow_hitbod2.wav", 1, ATTN_NORM);
		
		if (!deathmatch)
			remove(self);
	}
	else
	{
		sound(self, CHAN_WEAPON, "weapons/xbow_hit1.wav", random(0.95, 1), ATTN_NORM);
		particle(self.origin, '0 0 -0.5', 111, 20);
	
		self.think = SUB_Remove;
		self.nextthink = time;
		
		if (other == world)
		{
			vector dir = normalize(self.velocity);
			
			self.angles = vectoangles(dir);
			self.solid = SOLID_NOT;
			self.movetype = MOVETYPE_NONE;
			self.velocity = '0 0 0';
			self.avelocity_z = 0;
			self.angles_z = random(0, 360);
			self.nextthink = time + 10;
			
			setorigin(self, self.origin - dir * 12);
		}
	}
	
	if (deathmatch)
	{
		self.think = W_BoltExplode;
		self.nextthink = time + 0.1;
	}
}

/*
============
W_BoltExplode
============
*/

void() W_BoltExplode =
{
	entity myowner;
	
	if (!self.owner)
		myowner = world;
	else
		myowner = self.owner;
	self.owner = world;
	
	HL_RadiusDamage(self.origin, self, myowner, 40, "", DMGTYPE_EXPLOSION);
	
	float r;
	r = random();
	
	if (r < 0.333)
	{
		sound (self, CHAN_BODY, "weapons/explode3.wav", 1.0, ATTN_NONE);
	}
	else if (r < 0.666)
	{
		sound (self, CHAN_BODY, "weapons/explode4.wav", 1.0, ATTN_NONE);
	}
	else
	{
		sound (self, CHAN_BODY, "weapons/explode5.wav", 1.0, ATTN_NONE);
	}
	
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

/*
============
W_CrossbowPrecache
============
*/

void() W_CrossbowPrecache = 
{
	//precache_model("progs/w_crossbow.mdl");
	precache_model("progs/v_crossbow.mdl");
	precache_model("progs/xbolt.mdl");
	precache_sound("weapons/xbow_fire1.wav");
	precache_sound("weapons/xbow_reload1.wav");
	precache_sound("weapons/xbow_hitbod1.wav");
	precache_sound("weapons/xbow_hitbod2.wav");
	precache_sound("weapons/xbow_hit1.wav");
}

/*
============
W_CrossbowDeploy
============
*/

void() W_CrossbowDeploy =
{
	if (self.clip_crossbow)
		HL_DefaultDeploy(0, 10, 10, 20);
	else
		HL_DefaultDeploy(11, 21, 21, 20);
}

/*
============
W_CrossbowHolster
============
*/

float() W_CrossbowHolster =
{
	if (self.fuser1)
	{
		//sprint(self, "test\n");
		W_CrossbowSecAttack();
	}
	return TRUE;
}

/*
============
W_CrossbowPrimAttack
============
*/

float() W_CrossbowPrimAttack =
{
	if (self.fuser1)
	{
		return W_CrossbowFireSniperBolt();
	}

	return W_CrossbowFireBolt();
}

/*
============
W_CrossbowFireBolt
============
*/

float() W_CrossbowFireSniperBolt =
{
	self.attack_finished = time + 0.75;

	if (self.currentammo == 0)
	{
		HL_PlayEmptySound();
		return FALSE;
	}
	
	self.currentammo = self.clip_crossbow -= 1;
	
	sound(self, CHAN_WEAPON, "weapons/xbow_fire1.wav", random(0.95, 1.0), ATTN_NORM);
	
	if (self.clip_crossbow)
	{
		sound(self, CHAN_ITEM, "weapons/xbow_reload1.wav", random(0.95, 1.0), ATTN_NORM);
		W_SetWeaponAnim2(22, 59, 10, 20);
	}
	else
	{
		W_SetWeaponAnim2(60, 70, 70, 20);
	}
	
	vector myaim = self.v_angle + self.punchangle;
	
	makevectors(myaim);
	myaim_x *= -1;
	
	vector src = (self.origin + self.view_ofs) - v_up * 2;
	vector dir = v_forward;
	
	traceline(src, src + dir * 8192, 0, self);
	
	if (trace_ent.takedamage)
	{
		if (random() < 0.5)
			sound(self, CHAN_WEAPON, "weapons/xbow_hitbod1.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "weapons/xbow_hitbod2.wav", 1, ATTN_NORM);
			
		ClearMultiDamage();
		TraceAttack(120, dir);
		ApplyMultiDamage();
	}
	else
	{
		entity mybolt = W_BoltSpawn();
		mybolt.origin = trace_endpos - dir * 10;
		mybolt.angles = vectoangles(dir);
		mybolt.solid = SOLID_NOT;
		mybolt.touch = SUB_Null;
		mybolt.think = SUB_Remove;

		sound(mybolt, CHAN_WEAPON, "weapons/xbow_hit1.wav", random(0.95, 1), ATTN_NORM);
		particle(mybolt.origin, '0 0 -0.5', 111, 20);

		if (trace_ent == world)
			mybolt.nextthink = time + 5.0;
		else
			mybolt.nextthink = time;
	}
	
	return TRUE;
}

/*
============
W_CrossbowFireBolt
============
*/

float() W_CrossbowFireBolt =
{
	if (self.currentammo == 0)
	{
		HL_PlayEmptySound();
		return FALSE;
	}
	
	self.currentammo = self.clip_crossbow -= 1;
	
	sound(self, CHAN_WEAPON, "weapons/xbow_fire1.wav", random(0.95, 1.0), ATTN_NORM);
	
	if (self.clip_crossbow)
	{
		sound(self, CHAN_ITEM, "weapons/xbow_reload1.wav", random(0.95, 1.0), ATTN_NORM);
		W_SetWeaponAnim2(22, 59, 10, 20);
	}
	else
	{
		W_SetWeaponAnim2(60, 70, 70, 20);
	}
	
	vector myaim = self.v_angle + self.punchangle;
	
	makevectors(myaim);
	myaim_x *= -1;
	
	vector src = (self.origin + self.view_ofs) - v_up * 2;
	vector dir = v_forward;
	
	entity mybolt = W_BoltSpawn();
	mybolt.origin = src;
	mybolt.angles = myaim;
	mybolt.owner = self;
	
	if (self.waterlevel == 3)
		mybolt.velocity = dir * 1000;
	else
		mybolt.velocity = dir * 2000;
		
	mybolt.avelocity_z = 10;
	
	self.punchangle_x -= 2;
	
	self.attack_finished = time + 0.75;
	self.attack2_finished = time + 0.75;
	
	if (self.clip_crossbow != 0)
		self.nextidle = time + 5.0;
	else
		self.nextidle = 0.75;
		
	return TRUE;
}

/*
============
W_CrossbowReload
============
*/

float() W_CrossbowReload = 
{
	float result = HL_DefaultReload(71, 139, 139, 15, 5, 4.5, 3.5);
	
	if (self.fuser1)
	{
		//sprint(self, "test\n");
		W_CrossbowSecAttack();
	}
	
	if (result)
	{
		sound(self, CHAN_ITEM, "weapons/xbow_reload1.wav", random(0.95, 1.0), ATTN_NORM);
		return result;
	}
	
	return FALSE;
}

/*
============
W_CrossbowSecAttack
============
*/

float() W_CrossbowSecAttack =
{
	if (self.fuser1)
	{
		stuffcmd(self, "unzoom\n");
		self.fuser1 = 0;
	}
	else
	{
		stuffcmd(self, "zoom_crossbow\n");
		self.fuser1 = 1;
	}
	
	self.attack2_finished = time + 1.0;
	return TRUE;
}

/*
============
W_CrossbowIdle
============
*/

void() W_CrossbowIdle =
{
	HL_ResetEmptySound();
	
	if (self.nextidle < time)
	{
		if (random() < 0.75)
		{
			if (self.clip_crossbow)
			{
				W_SetWeaponAnim2(140, 170, -1, 8);
			}
			else
			{
				W_SetWeaponAnim2(171, 191, -1, 8);
			}
			self.nextidle = time + random(10,15);
		}
		else
		{
			if (self.clip_crossbow)
			{
				W_SetWeaponAnim2(192, 212, 212, 8);
				self.nextidle = time + (20.0/8.0);
			}
			else
			{
				W_SetWeaponAnim2(213, 233, 233, 8);
				self.nextidle = time + (20.0/8.0);
			}
		}
	}
}

/*
============
// rpg
// anims 20 fps 'less stated otherwise
// 0 - 10 : draw loaded
// 11 - 21 : draw un loaded
// 22 - 38 : fire
// 39 - 79 : reload
// 80 - 104 : idle loaded  8fps
// 105 - 129 : idle unloaded 8fps
// 130 - 154 : fidget loaded 8fps
// 155 - 179 : fidget unloaded 8fps
// 180 - 190 : holster unloaded 8fps
// 191 - 201 : holster loaded 8 fps
============
*/

/*
============
W_CreateLaser
============
*/

entity() W_CreateLaser =
{
	entity spot;
	spot = spawn();
	spot.classname = "laser_spot";
	spot.movetype = MOVETYPE_NONE;
	spot.movetype = SOLID_NOT;
	setmodel(spot, "progs/s_bubble.spr");
	setorigin(spot, spot.origin);
	return spot;
}

/*
============
W_SuspendLaser
============
*/

void(entity spot, float next_revive) W_SuspendLaser =
{
	setmodel(spot, "");
	spot.think = W_LaserRevive;
	spot.nextthink = time + next_revive;
}

/*
============
W_LaserRevive
============
*/

void() W_LaserRevive =
{
	setmodel(self, "progs/s_bubble.spr");
	self.think = SUB_Null;
}

entity(vector org, vector myangles, entity myowner, entity launcher) W_CreateRocket =
{
	entity rocket;
	rocket = spawn();
	
	rocket.classname = "rpg_rocket";
	rocket.angles = myangles;
	rocket.movetype = MOVETYPE_BOUNCE;
	rocket.solid = SOLID_BBOX;
	
	setmodel(rocket, "progs/rpgrocket.mdl");
	setsize(rocket, '0 0 0', '0 0 0');
	setorigin(rocket, org);
	
	rocket.angles_x -= 30;
	makevectors(rocket.angles);
	rocket.angles_x = -(rocket.angles_x + 30);
	
	rocket.velocity = v_forward * 250;
	rocket.gravity = 0.5;
	
	rocket.think = W_RocketIgnite;
	rocket.touch = W_RocketTouch;
	
	rocket.ent1 = launcher;
	rocket.ent1.fuser2 += 1;
	rocket.owner = rocket.trueowner = myowner;
	
	rocket.dmg = 120;
	
	rocket.nextthink = time + 0.4;
	return rocket;
}

void() W_RocketTouch =
{
	if (other == self.trueowner)
		return;

	if (self.ent1)
	{
		self.ent1.fuser2 -= 1;
		sound(self, CHAN_VOICE, "misc/null.wav", 1, 0.5);
	}
	
	self.touch = SUB_Null;
	self.think = SUB_Null;
	self.effects = 0;
	
	HL_ExplodeTouch();
}

void() W_RocketIgnite =
{
	self.movetype = MOVETYPE_FLYMISSILE;
	self.effects |= EF_DIMLIGHT;
	
	sound(self, CHAN_VOICE, "weapons/rocket1.wav", 1, 0.5);
	setmodel(self, "progs/rpgrocket1.mdl");
	
	self.fuser1 = time;
	self.think = W_RocketFollowLaser;
	self.nextthink = time + 0.1;
}

void() W_RocketFollowLaser =
{
	entity ent = world;
	vector dir, mytarget;
	float dist, max, dot;

	vector myangles = self.angles;
	myangles_x = -myangles_x;

	makevectors(myangles);

	mytarget = v_forward;
	max = 4096;
	
	ent = find(ent, classname, "laser_spot");
		
	while (ent)
	{
		traceline(self.origin, ent.origin, 0, self);
		if (trace_fraction >= 0.90)
		{
			dir = ent.origin - self.origin;
			dist = vlen(dir);
			dir = normalize(dir);
			dot = DotProduct(v_forward, dir);
			if ((dot > 0) && (dist * (1 - dot) < max))
			{
				max = dist * (1 - dot);
				mytarget = dir;
			}
		}
		ent = ent.chain;
	}
	
	self.angles = vectoangles(mytarget);
	
	float speed = vlen(self.velocity);
	if ((time - self.fuser1) < 1.0)
	{
		self.velocity = self.velocity * 0.2 + mytarget * (speed * 0.8 + 400);
		if (self.waterlevel == 3)
		{
			if (vlen(self.velocity) > 300)
			{
				self.velocity = normalize(self.velocity) * 300;
			}
		}
		else
		{
			if (vlen(self.velocity) > 2000)
			{
				self.velocity = normalize(self.velocity) * 2000;
			}
		}
	}
	else
	{
		if (self.effects & EF_DIMLIGHT)
		{
			self.effects = 0;
			sound(self, CHAN_VOICE, "misc/null.wav", 1, 0.5);
		}
		self.velocity = self.velocity * 0.2 + mytarget * speed * 0.798;
		if (self.waterlevel == 0 && vlen(self.velocity) < 1500)
		{
			if (self.ent1)
			{
				self.ent1.fuser2 -= 1;
			}
			HL_GrenadeDetonate();
		}
	}
	
	self.nextthink = time + 0.1;
}

/*
============
W_PrecacheRPG
============
*/

// fuser1 == Is my laser spot active?
// fuser2 == active rocket counter.

void() W_PrecacheRPG =
{
	//precache_model("models/w_rpg.mdl");
	precache_model("progs/v_rpg.mdl");
	precache_model("progs/rpgrocket.mdl");
	precache_model("progs/rpgrocket1.mdl");
	precache_sound("items/9mmclip1.wav");
	precache_sound("weapons/rocketfire1.wav");
	precache_sound("weapons/rocket1.wav");
	precache_sound("weapons/glauncher.wav");
}

/*
============
W_RPGUpdateSpot
============
*/

void() W_RPGUpdateSpot =
{
	if (self.fuser1)
	{
		if (!self.ent1 || self.ent1 == world)
		{
			self.ent1 = W_CreateLaser();
		}
		
		makevectors(self.v_angle);
		
		vector src = self.origin + self.view_ofs;
		vector dir = v_forward;
		
		traceline(src, src + dir * 8192, 0, self);
		setorigin(self.ent1, trace_endpos);
		
		//sprint(self, vtos(self.ent1.origin));
		//sprint(self, "\n");
	}
}

/*
============
W_RPGDeploy
============
*/

void() W_RPGDeploy =
{
	if (self.clip_rpg)
		HL_DefaultDeploy(0, 10, 10, 20);
	else
		HL_DefaultDeploy(11, 21, 21, 20);
	self.fuser1 = TRUE;
}

/*
============
W_RPGHolster
============
*/

//ENT1 = laser
float() W_RPGHolster =
{
	if (self.ent1 != world || self.ent1)
	{
		remove(self.ent1);
		self.ent1 = world;
	}
	return TRUE;
}

/*
============
W_RPGPrimAttack
============
*/

float() W_RPGPrimAttack =
{
	if (self.clip_rpg)
	{
		W_SetWeaponAnim2(22, 38, 38, 20);
		
		makevectors(self.v_angle);
		vector src = self.origin + self.view_ofs + v_forward * 16 + v_right * 8 + v_up * -8;
		
		entity rocket = W_CreateRocket(src, self.v_angle, self, self);
		
		makevectors(self.v_angle); // Remake makevectors again.
		rocket.velocity = rocket.velocity + v_forward * DotProduct(self.velocity, v_forward);
		
		sound(self, CHAN_WEAPON, "weapons/rocketfire1.wav", 0.9, ATTN_NORM);
		sound(self, CHAN_ITEM, "weapons/glauncher.wav", 0.7, ATTN_NORM);
		
		self.currentammo = self.clip_rpg -= 1;
		
		self.attack_finished = time + 1.5;
		self.nextidle = time + 1.5;
		self.punchangle_x -= 5;
	}
	else
	{
		HL_PlayEmptySound();
	}
	
	W_RPGUpdateSpot();
	
	return TRUE;
}

/*
============
W_RPGSecAttack
============
*/

float() W_RPGSecAttack =
{
	self.fuser1 = !self.fuser1;
	
	if (!self.fuser1 && (self.ent1 != world || self.ent1))
	{
		remove(self.ent1);
		self.ent1 = world;
	}
	
	self.attack2_finished = time + 0.2;
	return TRUE;
}

/*
============
W_RPGReload
============
*/

float() W_RPGReload =
{
	float result;
	
	if (self.clip_rpg == 1)
	{
		return FALSE;
	}
	
	self.attack_finished = time + 0.5;
	
	if ( self.fuser2 && self.fuser1 )
	{
		return FALSE;
	}	
		
	if (self.ent1 && self.fuser1)
	{
		W_SuspendLaser(self.ent1, 2.1);
		self.attack2_finished = time + 2.1;
	}
	
	if (self.clip_rpg == 0)
	{
		result = HL_DefaultReload(39, 79, 79, 20, 1, 2.0);
	}
	
	if (result)
	{
		self.nextidle = time + random(10, 15);
	}

	return result;
}

/*
============
W_RPGIdle
============
*/

void() W_RPGIdle =
{
	W_RPGUpdateSpot();

	HL_ResetEmptySound();
	
	if (self.nextidle < time)
	{
		if (random() < 0.75)
		{
			if (self.clip_rpg)
			{
				W_SetWeaponAnim2(80, 104, -1, 8);
			}
			else
			{
				W_SetWeaponAnim2(105, 129, -1, 8);
			}
		}
		else
		{
			if (self.clip_rpg)
			{
				W_SetWeaponAnim2(130, 154, -1, 8);
			}
			else
			{
				W_SetWeaponAnim2(155, 179, -1, 8);
			}
		}
		self.nextidle = time + (25.0/8.0);
	}
}

/*
============
// hornet gun
// 0 - 20 : deploy 20 fps
// 21 - 29 : fire 20 fps
// 30 - 60 : idle 1 loop 16 fps
// 61 - 101 : idle 2 16 fps
// 102 - 137 : idle 3 16 fps
// 138 - 156 : Holster 16 fps
============
*/

/*
============
W_CreateHornet
============
*/

entity() W_CreateHornet =
{
	entity hornet;
	hornet = spawn();
	
	hornet.movetype = MOVETYPE_FLYMISSILE;
	hornet.solid = SOLID_BBOX;
	hornet.takedamage = DAMAGE_YES;
	hornet.health = 1;
	
	if (deathmatch)
	{
		hornet.ltime = time + 3.5;
	}
	else
	{
		hornet.ltime = time + 5.0;
	}
	
	if (random(1, 5) <= 2)
	{
		// RED HORNET
		hornet.fuser2 = TRUE;
		hornet.fuser1 = 600;
	}
	else
	{
		// ORANGE HORNET
		hornet.fuser2 = FALSE;
		hornet.fuser1 = 800;
	}
	
	entity soundent = self.trueowner;
	
	if (!soundent)
		soundent = self;
	
	float r = random();
	
	if (r < 0.33)
		sound(self, CHAN_WEAPON, "agrunt/ag_fire1.wav", 1.0, ATTN_NORM);
	else if (r < 0.66)
		sound(self, CHAN_WEAPON, "agrunt/ag_fire2.wav", 1.0, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "agrunt/ag_fire3.wav", 1.0, ATTN_NORM);
	
	setmodel(hornet, "progs/hornet.mdl");
	setsize(hornet, VEC_ORIGIN, VEC_ORIGIN);
	
	hornet.touch = W_HornetTouch;
	hornet.think = W_HornetTrack;
	
	hornet.th_stand = SUB_Null;
	hornet.th_walk = SUB_Null;
	hornet.th_run = SUB_Null;
	hornet.th_missile = SUB_Null;
	hornet.th_pain = SUB_NullPain;
	hornet.th_die = SUB_Null;
	hornet.th_checkattack = SUB_NullFloat;
	
	hornet.frame = 0;
	hornet.nextthink = time + 0.1;
	return hornet;
}

/*
============
W_HornetTrack
============
*/

void() W_HornetTrack =
{
	vector enemy_lastpos;
	vector dir_to_enemy, flight_dir;
	float delta, r;
	entity ent;
	
	self.frame = (self.frame + 1) % 4;
	
	if (time > self.ltime)
	{
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
		return;
	}
	
	if (!self.enemy)
	{
		ent = findradius(self.origin, 8192);
		
		while (ent)
		{
			if (ent.takedamage != DAMAGE_NO && ent != self.trueowner && ent != world && (ent.flags & FL_MONSTER))
			{
				if (visible(ent))
				{	
					sprint(self.trueowner, ent.classname);
					sprint(self.trueowner, "\n");
					self.enemy = ent;
				}
			}
			ent = ent.chain;
		}
	}
	
	if (self.enemy && visible(self.enemy))
	{
		enemy_lastpos = self.enemy.origin;
	}
	else
	{
		enemy_lastpos = enemy_lastpos + self.velocity * self.fuser1 * 0.1;
	}
	
	dir_to_enemy = normalize(enemy_lastpos - self.origin);
	
	if (vlen(self.velocity) < 0.1)
		flight_dir = dir_to_enemy;
	else
		flight_dir = normalize(self.velocity);
		
	delta = DotProduct(flight_dir, dir_to_enemy);
	
	if (delta < 0.5)
	{
		r = random();
		
		if (r < 0.33)
			sound(self, CHAN_WEAPON, "hornet/ag_buzz1.wav", 1.0, ATTN_NORM);
		else if (r < 0.66)
			sound(self, CHAN_WEAPON, "hornet/ag_buzz2.wav", 1.0, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "hornet/ag_buzz3.wav", 1.0, ATTN_NORM);
	}
	
	// self.fuser2 == am a red hornet or not????
	// self.fuser1 == fly speed
	
	if (delta <= 0 && self.fuser2)
		delta = 0.25;
		
	self.velocity = normalize(flight_dir + dir_to_enemy);
		
	if (self.trueowner && (self.trueowner.flags & FL_MONSTER))
	{
		self.velocity_x += random( -0.10, 0.10);
		self.velocity_y += random( -0.10, 0.10);
		self.velocity_z += random( -0.10, 0.10);
	}
	
	if (self.fuser2)
	{
		self.velocity = self.velocity * (self.fuser1 * delta);
		self.nextthink = time + random(0.1, 0.3);
		particle(self.origin, '0 0 0', 228, 5);
	}
	else
	{
		self.velocity = self.velocity * self.fuser1;
		self.nextthink = time + 0.1;
		particle(self.origin, '0 0 0', 108, 5);
	}
	
	self.angles = vectoangles(self.velocity);
	
	if (self.enemy && !deathmatch)
	{
		if (delta >= 0.4 && vlen(self.origin - enemy_lastpos) <= 300)
		{
			r = random();
			
			if (r < 0.33)
				sound(self, CHAN_VOICE, "hornet/ag_buzz1.wav", 1.0, ATTN_NORM);
			else if (r < 0.66)
				sound(self, CHAN_VOICE, "hornet/ag_buzz2.wav", 1.0, ATTN_NORM);
			else
				sound(self, CHAN_VOICE, "hornet/ag_buzz3.wav", 1.0, ATTN_NORM);
				
			self.velocity = self.velocity * 2;
			self.nextthink = time + 1.0;
			self.ltime = time;
		}
	}
}

/*
============
W_HornetTrailThink
============
*/

void() W_HornetTrailThink =
{
	if (self.ltime < time)
		remove(self);

	self.frame = (self.frame + 1) % 4;

	if (self.fuser2)
	{
		particle(self.origin, '0 0 0', 228, 5);
	}
	else
	{
		particle(self.origin, '0 0 0', 108, 5);
	}
	self.nextthink = time + 0.01;
}

/*
============
W_HornetTouch
============
*/

void() W_HornetTouch =
{
	if (other == self.trueowner)
		return;

	if (other.takedamage)
	{
		float r = random();
		
		if (r < 0.33)
			sound(self, CHAN_VOICE, "hornet/ag_hornethit1.wav", 1.0, ATTN_NORM);
		else if (r < 0.66)
			sound(self, CHAN_VOICE, "hornet/ag_hornethit2.wav", 1.0, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "hornet/ag_hornethit3.wav", 1.0, ATTN_NORM);
		
		if (deathmatch)
			T_Damage (other, self, self.trueowner, 20, DMGTYPE_MELEE);
		else
			T_Damage (other, self, self.trueowner, 16, DMGTYPE_MELEE);
	}
	
	if (self.fuser2)
	{
		particle(self.origin, '0 0 0', 228, 20);
	}
	else
	{
		particle(self.origin, '0 0 0', 108, 20);
	}
	
	setmodel(self, "");
	self.solid = SOLID_NOT;
	
	self.think = SUB_Remove;
	self.nextthink = time + 1.0;
}

/*
============
W_HGunPrecache
============
*/

void() W_HGunPrecache =
{
	precache_model("progs/v_hgun.mdl");
	precache_model("progs/hornet.mdl");

	precache_sound( "agrunt/ag_fire1.wav" );
	precache_sound( "agrunt/ag_fire2.wav" );
	precache_sound( "agrunt/ag_fire3.wav" );

	precache_sound( "hornet/ag_buzz1.wav" );
	precache_sound( "hornet/ag_buzz2.wav" );
	precache_sound( "hornet/ag_buzz3.wav" );

	precache_sound( "hornet/ag_hornethit1.wav" );
	precache_sound( "hornet/ag_hornethit2.wav" );
	precache_sound( "hornet/ag_hornethit3.wav" );
}

/*
============
W_HGunDeploy
============
*/

void() W_HGunDeploy =
{
	HL_DefaultDeploy(0, 20, 20, 20);
}

/*
============
W_HGunHolster
============
*/

float() W_HGunHolster = 
{
	if (!self.ammo_hornets)
		self.ammo_hornets = 1;
	return TRUE;
}

/*
============
W_HGunPrimAttack
============
*/

float() W_HGunPrimAttack = 
{
	W_HGunReload();
	
	if (self.ammo_hornets <= 0)
	{
		return FALSE;
	}

	makevectors(self.v_angle);
	
	entity hornet = W_CreateHornet();
	hornet.owner = hornet.trueowner = self;
	hornet.origin = self.origin + self.view_ofs + v_forward * 16 + v_right * 16 + v_up * -12;
	hornet.velocity = v_forward * 300;
	hornet.angles = vectoangles(hornet.velocity);
	
	self.currentammo = self.ammo_hornets -= 1;
	self.fuser1 = time + 0.5;
	
	W_SetWeaponAnim2(21, 29, 29, 20);
	
	self.attack_finished = time + 0.25;
	if (self.attack_finished < time)
	{
		self.attack_finished = time + 0.25;
	}
	self.nextidle = time + random(10,15);
	return TRUE;
}

/*
============
W_HGunSecAttack
============
*/

float() W_HGunSecAttack = 
{
	W_HGunReload();
	
	if (self.ammo_hornets <= 0)
	{
		return FALSE;
	}

	vector src;
	float firephase;

	makevectors(self.v_angle);
	
	src = self.origin + self.view_ofs + v_forward * 16 + v_right * 16 + v_up * -12;
	
	firephase++;
	switch (firephase)
	{
		case 1: 
			src = src + v_up * 8; 	
			break;
		case 2: 
			src = src + v_up * 8; 	
			src = src + v_right * 8;
			break;
		case 3: 
			src = src + v_right * 8; 	
			break;
		case 4: 
			src = src + v_up * -8; 	
			src = src + v_right * 8;
			break;
		case 5: 
			src = src + v_up * -8;
			break;
		case 6: 
			src = src + v_up * -8; 	
			src = src + v_right * -8;
			break;
		case 7: 
			src = src + v_right * -8;
			break;
		case 8: 
			src = src + v_up * 8; 	
			src = src + v_right * -8;
			firephase = 0;
			break;
		default: 
			firephase = 0;
			break;
	}
	
	entity hornet = W_CreateHornet();
	hornet.owner = hornet.trueowner = self;
	hornet.velocity = v_forward * 1200;
	hornet.angles = vectoangles(hornet.velocity);
	hornet.origin = src;
	hornet.think = W_HornetTrailThink;
	hornet.ltime = time + 4;
	
	W_SetWeaponAnim2(21, 29, 29, 20);
	
	self.currentammo = self.ammo_hornets -= 1;
	self.fuser1 = time + 0.5;
	
	self.attack_finished = self.attack2_finished = time + 0.1;
	self.nextidle = time + random(10, 15);
	self.punchangle_x = random(0, 2);
	return TRUE;
}

/*
============
W_HGunReload
============
*/

float() W_HGunReload =
{
	if (self.ammo_hornets >= 8)
		return FALSE;
	
	while ((self.ammo_hornets < 8) && (self.fuser1 < time))
	{
		self.currentammo = self.ammo_hornets += 1;
		self.fuser1 += 0.5;
	}
	
	return TRUE;
}

/*
============
W_HGunIdle
============
*/

void() W_HGunIdle = 
{
	W_HGunReload();
	
	if (self.nextidle > time)
		return;
		
	float r = random();
	
	if (r <= 0.75)
	{
		W_SetWeaponAnim2(30, 60, -1, 16);
		self.nextidle = time + 3.75;
	}
	else if (r <= 0.875)
	{
		W_SetWeaponAnim2(61, 101, 101, 16);
		self.nextidle = time + (40.0/16.0);
	}
	else
	{
		W_SetWeaponAnim2(102, 137, 137, 16);
		self.nextidle = time + (35.0/16.0);
	}
}

/*
============
Gauss

Frames:
0 - 12 : Deploy ( 20 fps )
13 - 40 : Fire Anim ( 20 fps )
41 - 61 : Spin up ( 20 fps )
62 - 72 : Spin cycle ( 20 fps )
73 - 93 : Idle1 ( 5 fps )
94 - 114 : Idle2 ( 5 fps )
115 - 175 : Idle3 ( 20 fps )
176 - 189 : Holster ( 20 fps )

============
*/

/*
============
W_GaussGetChargeTime
============
*/

float() W_GaussGetChargeTime =
{
	if (deathmatch)
		return 1.5;
	return 4;
};

/*
============
W_GaussPrecache
============
*/

void() W_GaussPrecache =
{
	precache_model("progs/v_gauss.mdl");
	//precache_model("progs/p_gauss.mdl");

	//precache_sound("items/9mmclip1.wav");

	precache_sound("weapons/gauss2.wav");
	precache_sound("weapons/electro4.wav");
	precache_sound("weapons/electro5.wav");
	precache_sound("weapons/electro6.wav");
	
	precache_sound("weapons/charge.wav");
}

/*
============
W_GaussDeploy
============
*/

void() W_GaussDeploy = 
{
	HL_DefaultDeploy(0, 12, 73, 20);
};

/*
============
W_GaussPrimFire
============
*/

float() W_GaussPrimFire =
{
	if (self.waterlevel == 3)
	{
		HL_PlayEmptySound();
		self.attack2_finished = self.attack_finished = time + 0.15;
		return FALSE;
	}

	if (self.currentammo < 2)
	{
		HL_PlayEmptySound();
		self.attack_finished = time + 0.5;
		return FALSE;
	}
	
	W_GaussStartFire(TRUE);
	
	self.currentammo = self.ammo_cells = self.ammo_cells - 2;
	self.attack_phase = 0;
	self.attack_finished = time + 0.2;
	self.nextidle = time + 1.0;
	return TRUE;
};

/*
============
W_GaussSecFire
============
*/

// fuser1 = start of charge..
// fuser2 = ammo eaten per sec.
float() W_GaussSecFire =
{
	if (self.waterlevel == 3)
	{
		if (self.attack_phase != 0)
		{
			sound(self, CHAN_WEAPON, "weapons/electro4.wav", 1.0, ATTN_NORM);
			W_SetWeaponAnim2(73, 93, 73, 5);
			self.attack_phase = 0;
		}
		else
		{
			HL_PlayEmptySound();
		}
		
		self.attack2_finished = self.attack_finished = time + 0.5;
		return FALSE;
	}
	
	if (self.attack_phase == 0)
	{
		if (self.ammo_cells <= 0)
		{
			sound(self, CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM);
			self.attack_finished = time + 0.5;
			return FALSE;
		}
		
		self.currentammo = self.ammo_cells = self.ammo_cells - 1;
		self.fuser2 = time; // Next ammo charge!!
		
		W_SetWeaponAnim2(41, 61, 73, 20);
		self.attack_phase = 1;
		self.fuser1 = time; // Start of charge.
		self.nextidle = time + 0.5;
	}
	else if (self.attack_phase == 1)
	{
		if (self.nextidle < time)
		{
			W_SetWeaponAnim2(62, 72, -1, 20);
			self.attack_phase = 2;
			sound(self, CHAN_WEAPON, "weapons/charge.wav", 1.0, ATTN_NORM);
		}
	}
	else
	{
		if ( self.ammo_cells == 0 )
		{
			W_GaussStartFire(FALSE);
			self.attack_phase = 0;
			self.nextidle = time + 1.0;
			self.attack_finished = time + 1.0;
			return TRUE;
		}
		
		if (time > self.fuser2 && self.fuser2 != -1)
		{
			if (deathmatch)
			{
				self.currentammo = self.ammo_cells = self.ammo_cells - 1;
				self.fuser2 = time + 0.1;
			}
			else
			{
				self.currentammo = self.ammo_cells = self.ammo_cells - 1;
				self.fuser2 = time + 0.3;
			}
			
			if ( time - self.fuser2 >= W_GaussGetChargeTime() )
			{
				self.fuser2 = -1;
			}
			
			// TODO: Find a way to play a pitchy sound here...
			// - serecky 11.14.25
			
			if (self.fuser1 < time - 10)
			{
				sound(self, CHAN_WEAPON, "weapons/electro4.wav", 1.0, ATTN_NORM);
				sound(self, CHAN_ITEM, "weapons/electro6.wav", 1.0, ATTN_NORM);
				
				self.attack_phase = 0;
				self.nextidle = time + 1.0;
				self.attack_finished = time + 1.0;
				
				stuffcmd(self, "bf\nbf\nbf\n");
				W_SetWeaponAnim2(73, 93, 73, 5);
				
				return FALSE;
			}
		}
	}
	return TRUE;
};

/*
============
W_GaussStartFire
============
*/

void(float primary) W_GaussStartFire =
{
	local float damage;
	
	makevectors( self.v_angle + self.punchangle );
	local vector aiming = v_forward;
	local vector src = self.origin + self.view_ofs;
	
	if (time - self.fuser1 > W_GaussGetChargeTime())
	{
		damage = 200;
	}
	else
	{
		damage = 200 * ((time - self.fuser1) / W_GaussGetChargeTime());
	}
	
	if (primary)
	{
		damage = 20;
		self.punchangle_x -= 2;
	}
	
	// Removed the piece of code that prevents you
	// from doing crazy jumps with the gauss
	// -serecky 11.28.25
	if (self.attack_phase != 3)
	{
		if (!primary)
		{
			self.velocity = self.velocity - v_forward * damage * 5;
		}
		
		W_SetWeaponAnim2(13, 40, 73, 20);
		player_shot1();
	}
	sound(self, CHAN_WEAPON, "weapons/gauss2.wav", 0.5 + damage * (1.0 / 400.0), ATTN_NORM);
	self.fuser3 = time + random(0.3, 0.8); // Aftershock sound timer..
	
	W_GaussFire(src, aiming, damage, primary);
};

/*
============
W_GaussFire
============
*/

void(vector origsrc, vector dir, float dmg, float primary) W_GaussFire =
{
	local vector src = origsrc;
	local vector dest = src + dir * 8192;
	local entity ignore;
	local float maxfrac = 1.0;
	
	local float haspunched = 0;
	local float maxhits = 10;
	local float first = TRUE;
	local vector tr_endpos;
	
	ignore = self;
	
	while (dmg > 10 && maxhits > 0)
	{
		maxhits -= 1;
		
		traceline(src, dest, 0, ignore);
		tr_endpos = trace_endpos;
		
		if (trace_allsolid)
			break;
		
		if (first)
		{
			first = FALSE;
			self.effects |= EF_MUZZLEFLASH;
			
			local vector tmpsrc = src + v_up * -8 + v_right * 3;
			
			if (primary)
				fx_trail2(tmpsrc, tr_endpos, 237);
			else
				fx_trail2(tmpsrc, tr_endpos, 13);
		}
		else
		{
			if (primary)
				fx_trail2(src, tr_endpos, 237);
			else
				fx_trail2(src, tr_endpos, 13);
		}
		
		if (trace_ent.takedamage)
		{
			ClearMultiDamage();
			TraceAttack(dmg, dir);
			ApplyMultiDamage();
		}
		
		entity corpse = HL_CorpseChecker(trace_endpos);
		
		if (corpse != world)
		{
			trace_ent = corpse;
			ClearMultiDamage();
			TraceAttack(dmg, dir);
			ApplyMultiDamage();
		}
		
		if (trace_ent.solid == SOLID_BSP && !trace_ent.takedamage)
		{
			local float n;
			//ignore = world;
			
			n = -DotProduct(trace_plane_normal, dir);
			
			if (n < 0.5)
			{
				local vector r;
				
				sprint(self, "reflect\n");
				
				r = 2.0 * trace_plane_normal * n + dir;
				maxfrac = maxfrac - trace_fraction;
				dir = r;
				src = tr_endpos + dir * 8;
				dest = src + dir * 8192;
			
				HL_RadiusDamage(tr_endpos, self, self, dmg * n, "", DMGTYPE_EXPLOSION);
				
				particle(tr_endpos, '0 0 50', 237, 6);
				
				n = (n == 0 ) ? n = 0.1 : n = n;
				dmg = dmg * ( 1 - n );
			}
			else
			{
				particle(tr_endpos, '0 0 50', 237, 6);
				
				if (haspunched)
					break;
				haspunched = 1;
				
				if (!primary)
				{
					traceline(tr_endpos + dir * 8, dest, 0, self);
					local vector beam_endpos = trace_endpos;
					
					sprint(self, "trace endpos 1:");
					sprint(self, vtos(tr_endpos));
					sprint(self, "\n");
					
					sprint(self, "beam endpos 1:");
					sprint(self, vtos(beam_endpos));
					sprint(self, "\n");
					
					
					if (!trace_allsolid)
					{
						traceline(beam_endpos, tr_endpos, 0, self);
						beam_endpos = trace_endpos;
						
						sprint(self, "beam endpos 2:");
						sprint(self, vtos(beam_endpos));
						sprint(self, "\n");
						
						n = vlen(beam_endpos - tr_endpos);
						
						sprint(self, ftos(n));
						sprint(self, "\n");
						
						if ( n < dmg )
						{
							n = (n == 0 ) ? n = 1 : n = n;
							dmg -= n;
							
							HL_RadiusDamage(beam_endpos + dir * 8, self, self, dmg, "", DMGTYPE_EXPLOSION);
							
							particle(beam_endpos, '0 0 50', 237, 6);
							
							src = beam_endpos + dir;
						}
					}
					else
					{
						dmg = 0;
					}
				}
				else
				{
					if (primary)
						particle(tr_endpos, '0 0 50', 237, 6);
					dmg = 0;
				}
			}
		}
		else
		{
			src = tr_endpos + dir;
			ignore = trace_ent;
		}
	}
};

/*
============
W_GaussIdle
============
*/

void() W_GaussIdle =
{
	HL_ResetEmptySound();

	if (self.fuser3 && self.fuser3 < time)
	{
		local float rs;
		rs = rint ((random() * 3) + 1);
		if (rs == 1)
			self.noise = "weapons/electro4.wav";
		if (rs == 2)
			self.noise = "weapons/electro5.wav";
		if (rs == 3)
			self.noise = "weapons/electro6.wav";
		sound (self, CHAN_WEAPON, self.noise, 1, ATTN_NONE);
		self.fuser3 = 0.0;
	}
	
	if (time < self.nextidle)
		return;

	if (self.attack_phase != 0)
	{
		W_GaussStartFire(FALSE);
		self.attack_phase = 0;
		self.nextidle = time + 2.0;
	}
	else
	{
		local float rand = random();
		if (rand <= 0.5)
		{
			W_SetWeaponAnim2(73, 93, -1, 10);
			self.nextidle = time + random( 10, 15 );
		}
		else if (rand <= 0.75)
		{
			W_SetWeaponAnim2(94, 114, -1, 10);
			self.nextidle = time + random( 10, 15 );
		}
		else
		{
			W_SetWeaponAnim2(115, 175, -1, 20);
			self.nextidle = time + 3;
		}
	}
};

/*
============
// egon
// 0-10 draw
// 11-21 fire1 loop
// 22-32 fire2 loop
// 33-40 fire3 loop
// 41-51 fire4 loop
// 52-68 idle1 loop 8 fps
// 69-90 fidget1 8 fps
// 91-101 holster
============
*/

// fuser2 == firestate
// fuser3 == ammo use time
// fuser4 == shoottime

void() W_EgonPrecache =
{
	//precache_model("models/w_egon.mdl");
	precache_model("progs/v_egon.mdl");
	precache_sound("weapons/egon_run3.wav");
	precache_sound("weapons/egon_off1.wav");
	precache_sound("weapons/egon_windup2.wav");
}

/*
============
W_EgonDeploy
============
*/

enum egon_firestates
{
	FIRE_OFF,
	FIRE_CHARGE
};

void() W_EgonDeploy = 
{
	HL_DefaultDeploy(0, 10, 10, 20);
};

/*
============
W_EgonHolster
============
*/

float() W_EgonHolster =
{
	if (self.fuser2 != FIRE_OFF)
		W_EgonEndAttack();
		
	if (self.ent1)
	{
		self.ent1 = world;
	}
	return TRUE;
}

/*
============
W_EgonPrimAttack
============
*/

float() W_EgonPrimAttack =
{
	if (self.waterlevel == 3)
	{
		if (self.ent1)
		{
			W_EgonEndAttack();
		}
		else
		{
			HL_PlayEmptySound();
		}
		return FALSE;
	}
	
	makevectors(self.v_angle + self.punchangle);
	vector myaim = v_forward;
	vector src = self.origin + self.view_ofs;
	
	switch (self.fuser2)
	{
		case FIRE_OFF:
		{
			if (self.currentammo <= 0)
			{
				self.attack_finished = time + 0.25;
				HL_PlayEmptySound();
				return FALSE;
			}
			
			float r = random();
			
			if (r < 0.25)
				W_SetWeaponAnim2(11, 21, -1, 20);
			else if (r < 0.50)
				W_SetWeaponAnim2(22, 32, -1, 20);
			else if (r < 0.75)
				W_SetWeaponAnim2(33, 40, -1, 20);
			else
				W_SetWeaponAnim2(41, 51, -1, 20);
			
			sound(self, CHAN_WEAPON, "weapons/egon_windup2.wav", 0.98, ATTN_NORM);
			
			self.fuser3 = time; // Ammo use time.
			self.fuser4 = time + 2.0; // shoot time
			self.nextidle = time + 0.1;
			self.dmgtime = time + 0.1; // pulse time
			self.fuser2 = FIRE_CHARGE;
			break;
		}
		case FIRE_CHARGE:
		{
			W_EgonFire(src, myaim);
		
			if (self.fuser4 != 0 && time > self.fuser4)
			{
				sound(self, 7, "weapons/egon_run3.wav", 0.98, ATTN_NORM);
				self.fuser4 = 0;
			}
		
			if (self.currentammo <= 0)
			{
				W_EgonEndAttack();
				self.fuser2 = FIRE_OFF;
				self.attack_finished = time + 1.0;
				return FALSE;
			}
			break;
		}
	}
	
	return TRUE;
}

/*
============
W_EgonFire
============
*/

.float ammo_consume; // ok WHATEVER
void(vector src, vector dir) W_EgonFire =
{
	vector dest = src + dir * 2048;
	vector tmpsrc = src + v_up * -8 + v_right * 3 + v_forward * 16;
	
	traceline(src, dest, 0, self);
	
	if (trace_allsolid)
		return;
		
	if (self.dmgtime < time)
	{
		ClearMultiDamage();
		if (trace_ent && trace_ent.takedamage)
			TraceAttack(20, dir);
		ApplyMultiDamage();
		
		entity corpse = HL_CorpseChecker(trace_endpos);
		
		if (corpse != world)
		{
			trace_ent = corpse;
			ClearMultiDamage();
			TraceAttack(20, dir);
			ApplyMultiDamage();
		}
		
		if (deathmatch)
		{
			if (time >= self.ammo_consume)
			{
				self.currentammo = self.ammo_cells -= 1;
				self.ammo_consume = time + 0.2;
			}
		}
		else
		{
			if (time >= self.ammo_consume)
			{
				self.currentammo = self.ammo_cells -= 1;
				self.ammo_consume = time + 0.1;
			}
		}
		
		if (self.deadflag != DEAD_NO)
			return;
	}
	
	particle (trace_endpos, '0 0 100', 208, 20);
	
	if (!self.ent1)
	{
		self.ent1 = spawn();
		setorigin(self.ent1, tmpsrc);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
		WriteEntity (MSG_BROADCAST, self.ent1);
		WriteCoord (MSG_BROADCAST, tmpsrc_x);
		WriteCoord (MSG_BROADCAST, tmpsrc_y);
		WriteCoord (MSG_BROADCAST, tmpsrc_z);
		WriteCoord (MSG_BROADCAST, trace_endpos_x);
		WriteCoord (MSG_BROADCAST, trace_endpos_y);
		WriteCoord (MSG_BROADCAST, trace_endpos_z);
	}
}

/*
============
W_EgonEndAttack
============
*/

void() W_EgonEndAttack =
{
	if (self.ent1)
	{
		self.ent1 = world;
	}

	sound(self, 7, "weapons/egon_off1.wav", 0.98, ATTN_NORM);
	sound(self, CHAN_WEAPON, "weapons/egon_off1.wav", 0.98, ATTN_NORM);
	self.fuser2 = FIRE_OFF;
	self.nextidle = time + 2.0;
	self.attack_finished = time + 0.5;
}

/*
============
W_EgonIdle
============
*/

void() W_EgonIdle =
{
	HL_ResetEmptySound();

	if (self.ent1)
	{
		self.ent1 = world;
	}

	if (self.nextidle > time)
		return;
		
	if (self.fuser2 != FIRE_OFF)
		W_EgonEndAttack();

	if (random() < 0.5)
	{
		W_SetWeaponAnim2(52, 68, -1, 8);
		self.nextidle = time + random(10, 15);
	}
	else
	{
		W_SetWeaponAnim2(69, 90, -1, 8);
		self.nextidle = time + 3.0;
	}
}

/*
============
W_GrenadePrecache
============
*/

//fuser1 = startthrow
//fuser2 = release

void() W_GrenadePrecache =
{
	precache_model("progs/v_grenade.mdl");
	precache_model("progs/w_grenade.mdl");
}

/*
============
W_GrenadeDeploy
============
*/

void() W_GrenadeDeploy =
{
	HL_DefaultDeploy(0, 10, 10, 20);
	self.fuser2 = -1;
}

/*
============
W_GrenadeHolster
============
*/

float() W_GrenadeHolster =
{
	if (self.ammo_handgrenades <= 0)
	{
		self.weapons &= ~WPN_HANDGRENADE;
	}
	
	if (self.fuser1 != 0)
		return FALSE;
	
	return TRUE;
}

/*
============
W_GrenadePrimAttack
============
*/

float() W_GrenadePrimAttack =
{
	if (!self.fuser1 && self.currentammo > 0)
	{
		self.fuser1 = time;
		self.fuser2 = 0;
		
		W_SetWeaponAnim2(11, 22, 22, 20);
		
		self.nextidle = time + 0.5;
		return TRUE;
	}
	return FALSE;
}

/*
============
W_GrenadeIdle
============
*/

void() W_GrenadeIdle =
{
	if (self.fuser2 == 0)
		self.fuser2 = time;
		
	if (self.nextidle > time)
		return;
		
	if (self.fuser1)
	{
		vector angthrow = self.v_angle + self.punchangle;
		
		if (angthrow_x < 0)
			angthrow_x = -10 + angthrow_x * ((90-10)/90.0);
		else
			angthrow_x = -10 + angthrow_x * ((90+10)/90.0);
			
		float vel = (90 - angthrow_x) * 4;
		if (vel > 500)
			vel = 500;
			
		makevectors(angthrow);
		
		vector src = self.origin + self.view_ofs + v_forward * 16;
		vector throw = v_forward * vel + self.velocity;
		
		float mytime = self.fuser1 - time + 3.0;
		
		if (mytime < 0)
			mytime = 0;
			
		W_CreateTimedGren(src, throw, mytime);
		
		if (vel < 500)
		{
			W_SetWeaponAnim2(23, 41, 41, 13);
		}
		else if (vel < 1000)
		{
			W_SetWeaponAnim2(42, 60, 60, 20);
		}
		else
		{
			W_SetWeaponAnim2(61, 79, 79, 30);
		}
		
		self.fuser1 = 0;
		self.attack_finished = time + 0.5;
		self.nextidle = time + 0.5;
		
		self.currentammo = self.ammo_handgrenades -= 1;
		
		if (!self.ammo_handgrenades)
		{
			self.attack_finished = self.attack2_finished = self.nextidle = time + 0.5;
		}
		return;
	}
	else if (self.fuser2 > 0)
	{
		self.fuser1 = 0;
	
		if (self.ammo_handgrenades)
		{
			W_SetWeaponAnim2(0, 10, 10, 20);
		}
		else
		{
			HL_RetireWeapon();
			return;
		}
	
		self.nextidle = time + random(10, 15);
		self.fuser2 = -1;
		return;
	}
	
	if (self.ammo_handgrenades)
	{
		if (random() <= 0.75)
		{
			W_SetWeaponAnim2(80, 104, -1, 8);
			self.nextidle = time + random(10, 15);
		}
		else
		{
			W_SetWeaponAnim2(105, 125, -1, 8);
			self.nextidle = time + 2.5;
		}
	}
}

/*
============
W_CreateSatchel
============
*/

entity(vector start, vector vel) W_CreateSatchel =
{
	entity gren;
	gren = W_CreateBasicGrenade();
	
	gren.classname = "monster_satchel";
	setmodel(gren, "progs/w_satchel.mdl");
	setsize(gren, '-4 -4 -4', '4 4 4');
	setorigin(gren, start);
	
	gren.velocity = vel;
	gren.angles = VEC_ORIGIN;
	
	gren.think = W_SatchelThink;
	gren.touch = W_SatchelSlide;
	gren.nextthink = time + 0.1;
	gren.dmg = 150;
	
	gren.gravity = 0.5;
	gren.frame = 1;
	return gren;
}

/*
============
W_SatchelDeactivate
============
*/

void() W_SatchelDeactivate =
{
	self.solid = SOLID_NOT;
	remove(self);
}

/*
============
W_SatchelSlide
============
*/

void() W_SatchelSlide =
{
	self.gravity = 1;
	
	traceline(self.origin, self.origin - '0 0 10', 1, self);
	
	if (trace_fraction < 1.0)
	{
		self.velocity = self.velocity * 0.95;
		self.avelocity = self.avelocity * 0.9;
	}
	
	if (!(self.flags & FL_ONGROUND) && vlen2d(self.velocity) > 10)
	{
		W_SatchelBounceSound();
	}
}

/*
============
W_SatchelThink
============
*/

void() W_SatchelThink =
{
	self.nextthink = time + 0.1;
	
	if (self.waterlevel == 3)
	{
		self.movetype = MOVETYPE_FLY;
		self.velocity = self.velocity * 0.8;
		self.avelocity = self.avelocity * 0.9;
		self.velocity.z += 8;
	}
	else if (self.waterlevel == 0)
	{
		self.movetype = MOVETYPE_BOUNCE;
	}
	else
	{
		self.velocity_z -= 8;
	}
}

/*
============
W_SatchelBounceSound
============
*/

void() W_SatchelBounceSound =
{
	float r = random();
	
	if (r < 0.33)
		sound(self, CHAN_VOICE, "weapons/g_bounce1.wav", 0.25, ATTN_NORM);
	else if (r < 0.66)
		sound(self, CHAN_VOICE, "weapons/g_bounce2.wav", 0.25, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "weapons/g_bounce3.wav", 0.25, ATTN_NORM);
}

/*
============
W_SatchelPrecache
============
*/

void() W_SatchelPrecache =
{
	precache_model("progs/v_satchel.mdl");
	precache_model("progs/v_satchel_radio.mdl");
	precache_model("progs/w_satchel.mdl");
}

/*
============
W_SatchelDeploy
============
*/

float(entity cl) W_SatchelHack =
{
	if (cl.ammo_satchels >= 0)
	{
		dprint("ready\n");
		return TRUE;
	}
	
	if (cl.satchel_ready)
	{
		dprint("ready\n");
		return TRUE;
	}	
		
	dprint("not ready\n");
	return FALSE;
}

void() W_SatchelDeploy =
{
	if (self.satchel_ready)
	{
		HL_DefaultDeploy(0, 40, 40, 20);
		self.weaponmodel = "progs/v_satchel_radio.mdl";
	}
	else
	{
		HL_DefaultDeploy(0, 40, 40, 20);
		self.weaponmodel = "progs/v_satchel.mdl";
	}
}

/*
============
W_SatchelHolster
============
*/

float() W_SatchelHolster =
{
	if ((self.ammo_satchels <= 0) && (!self.satchel_ready))
	{
		dprint("No satchel\n");
		self.weapon &= ~WPN_SATCHEL;
	}
	return TRUE;
}

/*
============
W_SatchelPrimAttack
============
*/

float() W_SatchelPrimAttack =
{
	switch (self.satchel_ready)
	{
		case 0:
		{
			W_SatchelThrow();
			break;
		}
		case 1:
		{
			W_SetWeaponAnim2(13, 33, 33, 20);
			
			entity satchel;
			
			satchel = findradius(self.origin, 4096);
			
			while (satchel)
			{
				if (satchel.classname == "monster_satchel")
				{
					if (satchel.owner == self)
					{
						satchel.think = HL_GrenadeDetonate;
						satchel.nextthink = time;
						self.satchel_ready = 2;
					}
				}
				satchel = satchel.chain;
			}
			
			self.satchel_ready = 2;
			self.attack_finished = time + 0.5;
			self.attack2_finished = time + 0.5;
			self.nextidle = time + 0.5;
			break;
		}
		case 2:
		{
			break;
		}
	}
	return TRUE;
}

/*
============
W_SatchelSecAttack
============
*/

float() W_SatchelSecAttack =
{
	if (self.satchel_ready != 2)
		W_SatchelThrow();
	return TRUE;
}

/*
============
W_SatchelThrow
============
*/

void() W_SatchelThrow =
{
	if (self.ammo_satchels)
	{
		vector src = self.origin;
		vector throw = v_forward * 274 + self.velocity;
		
		entity satchel = W_CreateSatchel(src, throw);
		satchel.avelocity_y = 400;
		
		self.satchel_ready = 1;
		self.currentammo = self.ammo_satchels -= 1;
		
		self.weaponmodel = "progs/v_satchel_radio.mdl";
		W_SetWeaponAnim2(0, 12, 12, 20);
		
		self.attack_finished = time + 1.0;
		self.attack2_finished = time + 0.5;
	}
}

/*
============
W_SatchelIdle
============
*/

void() W_SatchelIdle =
{
	if (self.nextidle > time)
		return;
	
	switch (self.satchel_ready)
	{
		case 0:
		{// Satchel
			W_SetWeaponAnim2(41, 57, 57, 8);
			break;
		}
		case 1:
		{// Radio
			W_SetWeaponAnim2(34, 63, 63, 8);
			break;
		}
		case 2:
		{
			if (self.ammo_satchels <= 0)
			{
				self.satchel_ready = 0;
				HL_RetireWeapon();
				return;
			}
			
			self.weaponmodel = "progs/v_satchel.mdl";
			W_SetWeaponAnim2(0, 40, 40, 20);
			
			self.attack_finished = time + 0.5;
			self.attack2_finished = time + 0.5;
			self.satchel_ready = 0;
			break;
		}
	}
	self.nextidle = time + random(10,15);
}

/*
============
W_DeactivatePlayerSatchels
============
*/

void(entity myowner) W_DeactivatePlayerSatchels =
{
	entity satchels;
	
	satchels = find(satchels, classname, "monster_satchel");
	
	while (satchels)
	{
		if (satchels.owner == myowner)
		{
			satchels.think = W_SatchelDeactivate;
		}
		satchels = satchels.chain;
	}
}

/*
============
W_TripminePrecache
============
*/

void() W_TripminePrecache =
{
	precache_sound("weapons/mine_deploy.wav");
	precache_sound("weapons/mine_activate.wav");
	precache_sound("weapons/mine_charge.wav");
	precache_model("progs/v_tripmine.mdl");
	precache_model("progs/w_tripmine.mdl");
}

/*
============
W_CreateTripmine
============
*/

entity(vector org, vector ang) W_CreateTripmine =
{
	entity mine;
	
	mine = spawn();
	
	mine.movetype = MOVETYPE_FLY;
	mine.solid = SOLID_NOT;
	mine.classname = "monster_tripmine";
	
	setmodel(mine, "progs/w_tripmine.mdl");
	setsize(mine, '-8 -8 -8', '8 8 8');
	setorigin(mine, org);
	
	mine.think = W_TripminePowerup;
	mine.nextthink = time + 0.2;
	mine.fuser1 = time + 2.5;// powerup time
	
	mine.takedamage = DAMAGE_AIM;
	mine.health = 1;
	mine.dmg = 150;
	mine.owner = mine.trueowner = self;
	
	sound(mine, CHAN_VOICE, "weapons/mine_deploy.wav", 1.0, ATTN_NORM);
	sound(mine, CHAN_BODY, "weapons/mine_charge.wav", 0.2, ATTN_NORM);

	mine.angles = ang;
	vector myangles = mine.angles;
	myangles_x = -myangles_x;
		
	makevectors(myangles);
	
	mine.vuser3 = v_forward; // dir
	mine.vuser4 = mine.origin + mine.vuser3 * 2048; // end
	
	mine.th_pain = W_TripminePain;
	mine.th_die = W_TripmineKilled;
	mine.frame = 1;

	return mine;
}

/*
============
W_TripminePowerup
============
*/

void() W_TripminePowerup =
{
	//self.owner = world;
	
	traceline(self.origin + self.vuser3 * 8, self.origin - self.vuser3 * 32, 0, self);
	
	if (trace_startsolid || ((self.trueowner) && (trace_ent == self.trueowner)))
	{
		self.owner = self.trueowner;
		self.fuser1 += 0.1;
		self.nextthink = time + 0.1;
		return;
	}
	
	if (trace_fraction < 1.0)
	{
		self.owner = trace_ent;
	}
	else
	{
		sound(self, CHAN_VOICE, "misc/null.wav", 1.0, ATTN_NORM);
		sound(self, CHAN_BODY, "misc/null.wav", 0.2, ATTN_NORM);
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
		return;
	}

	if (time > self.fuser1)
	{
		self.solid = SOLID_BBOX;
		setorigin(self, self.origin);
		
		W_TripmineStartBeam();
		
		sound(self, CHAN_VOICE, "weapons/mine_activate.wav", 0.5, ATTN_NORM);
	}
	
	self.nextthink = time + 0.2;
}

/*
============
W_TripmineStartBeam
============
*/

void() W_TripmineStartBeam =
{
	traceline(self.origin, self.vuser4, 0, self);
	self.fuser2 = trace_fraction; // Initial trace_fraction
	
	self.think = W_TripmineBeamBreak;
	self.nextthink = time + 0.1;
}

/*
============
W_TripmineBeamBreak
============
*/

void() W_TripmineBeamBreak =
{
	float blowup = FALSE;
	
	traceline(self.origin, self.vuser4, 0, self);
	
	if (fabs(self.fuser2 - trace_fraction) > 0.001)
	{
		blowup = TRUE;
	}
	else
	{
		if (self.trueowner == world)
			blowup = TRUE;
	}
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	
	if (blowup)
	{
		sound(self, CHAN_VOICE, "player/pain5.wav", 0.5, ATTN_NORM);
		self.owner = self.trueowner;// real owner
		self.health = 0;
		W_TripmineKilled();
		return;
	}
	
	self.nextthink = time + 0.1;
}

/*
============
W_TripminePain
============
*/

void(entity attacker, float damage) W_TripminePain =
{
	if (time < self.fuser1 && damage < self.health)
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		return;
	}
}

/*
============
W_TripmineKilled
============
*/

void() W_TripmineKilled =
{
	self.takedamage = DAMAGE_NO;
	
	if (self.dmg_inflictor && (self.dmg_inflictor.flags & FL_CLIENT))
	{
		self.owner = self.dmg_inflictor;// Set owner to dmg inflictor.
	}
	
	self.think = W_TripmineDeathThink;
	self.nextthink = time + random(0.1, 0.3);
}

/*
============
W_TripmineDeathThink
============
*/

void() W_TripmineDeathThink =
{
	self.think = SUB_Null;
	HL_GrenadeExplode();
}

/*
============
W_TripmineDeploy
============
*/

void() W_TripmineDeploy =
{
	HL_DefaultDeploy(0, 10, 10, 20);
}

/*
============
W_TripmineHolster
============
*/

float() W_TripmineHolster =
{
	if (self.ammo_tripmines <= 0)
	{
		self.weapons &= ~WPN_TRIPMINE;
	}
	return TRUE;
}

/*
============
W_TripminePrimAttack
============
*/

float() W_TripminePrimAttack =
{
	if (self.ammo_tripmines <= 0)
		return FALSE;
		
	makevectors(self.v_angle + self.punchangle);
	vector src = self.origin + self.view_ofs;
	vector dir = v_forward;
	
	traceline( src, src + dir * 128, 0, self);
	
	if (trace_fraction < 1.0)
	{
		vector ang = vectoangles(trace_plane_normal);
		
		entity tripmine = W_CreateTripmine(trace_endpos + trace_plane_normal * 8, ang);
		
		self.currentammo = self.ammo_tripmines -= 1;

		if (self.ammo_tripmines > 0)
		{
			W_SetWeaponAnim2(0, 10, 10, 20);
		}
		else
		{
			HL_RetireWeapon();
			return FALSE;
		}
	}
	
	self.attack_finished = time + 0.3;
	self.nextidle = time + random(10, 15);
	return TRUE;
}

/*
============
W_TripmineIdle
============
*/

void() W_TripmineIdle =
{
	if (self.nextidle > time)
		return;
	
	if (self.ammo_tripmines > 0)
	{
		W_SetWeaponAnim2(0, 10, 10, 20);
	}
	else
	{
		return;
	}
	
	float r = random();
	
	if (r <= 0.25)
	{
		W_SetWeaponAnim2(11, 35, -1, 8);
		self.nextidle = time + 3.0;
	}
	else if (r <= 0.75)
	{
		W_SetWeaponAnim2(36, 52, -1, 8);
		self.nextidle = time + 2.0;
	}
	else
	{
		W_SetWeaponAnim2(53, 80, -1, 8);
		self.nextidle = time + 3.375;
	}
}

entity() W_CreateSnark =
{
	entity snark;
	snark = spawn();
	
	snark.movetype = MOVETYPE_BOUNCE;
	snark.solid = SOLID_BBOX;
	
	setmodel(snark, "progs/w_squeak.mdl");
	setsize(snark, '-4 -4 0', '4 4 8');
	setorigin(snark, snark.origin);
	
	snark.classname = "monster_snark";
	snark.owner = snark.trueowner = self;
	snark.touch = Snark_BounceTouch;
	snark.think = Snark_HuntThink;
	snark.nextthink = time + 0.1;
	
	snark.flags |= FL_MONSTER;
	snark.takedamage = DAMAGE_AIM;
	snark.health = 2;
	snark.gravity = 0.5;
	snark.dmg = 10;
	
	snark.fuser1 = time + 15.0;// m_flDie
	snark.fuser2 = time;// Bounce sound time
	
	snark.th_die = SUB_Null;
	snark.th_pain = Snark_Pain;
	
	return snark;
}

void() Snark_HuntThink =
{
	self.nextthink = time + 0.1;
	
	if (time >= self.fuser1)
	{
		self.health = -1;
		self.th_die();
		return;
	}
	
	if (self.waterlevel != 0)
	{
		if (self.movetype == MOVETYPE_BOUNCE)
		{
			self.movetype = MOVETYPE_FLY;
		}
		self.velocity = self.velocity * 0.9;
		self.velocity_z += 8.0;
	}
	else if (self.movetype == MOVETYPE_FLY)
	{
		self.movetype = MOVETYPE_BOUNCE;
		self.origin_z += 1.0;
	}
	
	//nexthunt
	if (self.fuser4 > time)
		return;
	
	self.fuser4 = time + 2.0;
	
	vector dir, mytarget;
	
	makevectors(self.angles);
	
	if (!self.enemy || self.enemy.deadflag != DEAD_NO)
	{
		entity ent = findradius(self.origin, 512);
		
		while (ent)
		{
			if (ent.takedamage != DAMAGE_NO && ent != world && (ent.flags & FL_MONSTER) && ent.classname != "monster_snark")
			{
				if (visible(ent))
				{	
					dprint(ent.classname);
					dprint("\n");
					self.enemy = ent;
				}
			}
			ent = ent.chain;
		}
	}
	
	if ((self.fuser1 - time <= 0.5) && (self.fuser1 - time <= 0.3))
	{
		sound(self, CHAN_VOICE, "squeek/sqk_die1.wav", 1, ATTN_NORM);
	}
	
	if (self.enemy)
	{
		if (visible(self.enemy))
		{
			dir = (self.enemy.origin + self.enemy.view_ofs) - self.origin;
			mytarget = normalize(dir);
		}
		
		float vel = vlen(self.velocity);
		float adj = 50.0 / (vel + 10.0);
		
		if (adj > 1.2)
			adj = 1.2;
			
		self.velocity = self.velocity * adj + mytarget * 300;
	}
	
	if (self.flags & FL_ONGROUND)
	{
		self.avelocity = '0 0 0';
	}
	else
	{
		if (self.avelocity == '0 0 0')
		{
			self.avelocity_x = random(-100, 100);
			self.avelocity_y = random(-100, 100);
		}
	}
	
	if (vlen(self.origin - self.vuser1) < 1.0)
	{
		self.velocity_x = random(-100, 100);
		self.velocity_y = random(-100, 100);
	}
	self.vuser1 = self.origin;
	
	self.angles = vectoangles(self.velocity);
	self.angles.z = 0;
	self.angles.x = 0;
}

void() Snark_BounceTouch =
{
	float pitch;
	
	if (self.owner && other == self.owner)
		return;
	
	self.owner = world;
	
	self.angles_x = 0;
	self.angles_z = 0;
	
	if (self.fuser3 > time)
		return;
		
	pitch = 155.0 - 60.0 * ((self.fuser1 - time) / 15.0);
	
	if (other.takedamage && self.attack_finished < time)
	{
		T_Damage (other, self, self.trueowner, self.dmg, DMGTYPE_MELEE);
		sound(self, CHAN_WEAPON, "squeek/sqk_deploy1.wav", 1, ATTN_NORM);
		self.attack_finished = time + 0.5;
	}

	self.fuser3 = time + 0.1; // Nexthit
	self.fuser4 = time;

	if (deathmatch)
	{
		if (time < self.fuser2)
			return;
	}
	
	if (!(self.flags & FL_ONGROUND))
	{
		float r = random();
		
		if (r <= 0.33)
			sound(self, CHAN_VOICE, "squeek/sqk_hunt1.wav", 1, ATTN_NORM);
		else if (r <= 0.66)
			sound(self, CHAN_VOICE, "squeek/sqk_hunt2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "squeek/sqk_hunt3.wav", 1, ATTN_NORM);
	}
	
	self.fuser2 = time + 0.5;
}

void(entity attacker, float damage) Snark_Pain =
{
	
}

void() W_SnarkPrecache =
{
	precache_model("progs/v_squeak.mdl");
	precache_model("progs/w_squeak.mdl");
	precache_sound("squeek/sqk_blast1.wav");
	precache_sound("squeek/sqk_die1.wav");
	precache_sound("squeek/sqk_hunt1.wav");
	precache_sound("squeek/sqk_hunt2.wav");
	precache_sound("squeek/sqk_hunt3.wav");
	precache_sound("squeek/sqk_deploy1.wav");
}

void() W_SnarkDeploy =
{
	HL_DefaultDeploy(0, 33, 33, 20);
}

float() W_SnarkHolster =
{
	if (self.ammo_snarks <= 0)
	{
		self.weapons &= ~WPN_SNARK;
	}
	return TRUE;
}

float() W_SnarkPrimAttack =
{
	if (self.ammo_snarks > 0)
	{
		makevectors(self.v_angle);
		
		traceline(self.origin + v_forward * 16, self.origin + v_forward * 64, 0, self);
		
		if (trace_allsolid == 0 && trace_startsolid == 0 && trace_fraction > 0.25)
		{
			W_SetWeaponAnim2(34, 45, 45, 20);
			
			entity snark = W_CreateSnark();
			
			setorigin(snark, trace_endpos);
			snark.angles = self.v_angle;
			snark.velocity = v_forward * 200 + self.velocity;
			
			if (random() <= 0.5)
				sound(self, CHAN_VOICE, "squeek/sqk_hunt2.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_VOICE, "squeek/sqk_hunt3.wav", 1, ATTN_NORM);
				
			self.currentammo = self.ammo_snarks -= 1;
			self.fuser1 = 1; // Just thrown.
			
			self.attack_finished = time + 0.3;
			self.nextidle = time + 1.0;
		}
	}
	return TRUE;
}

void() W_SnarkIdle =
{
	if (self.nextidle > time)
		return;

	if (self.fuser1)
	{
		self.fuser1 = 0;
		
		if (self.ammo_snarks <= 0)
		{
			HL_RetireWeapon();
			return;
		}
		
		W_SetWeaponAnim2(0, 33, 33, 20);
		self.nextidle = time + random(10, 15);
		return;
	}
	
	float r = random();
	
	if (r <= 0.75)
	{
		W_SetWeaponAnim2(46, 61, -1, 8);
		self.nextidle = time + (15.0/8.0);
	}
	else if (r <= 0.875)
	{
		W_SetWeaponAnim2(62, 132, -1, 16);
		self.nextidle = time + (70.0/16.0);
	}
	else
	{
		W_SetWeaponAnim2(133, 213, -1, 16);
		self.nextidle = time + (80.0/16.0);
	}
}