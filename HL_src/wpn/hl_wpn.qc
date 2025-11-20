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
//
//======================================

/*
============
HL_PlayEmptySound
============
*/

void() HL_PlayEmptySound =
{
	if (!self.fuser5)
	{
		sound(self, CHAN_WEAPON, "hl_weapons/357_cock1.wav", 0.8, ATTN_NORM); 
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

float(float frame_start, float frame_end, float frame_reset, float framerate, float clipsize, float delay) HL_DefaultReload = 
{
	weaponclass_t weap = weaponsclass[W_GetWeapon(self.weapon)];

	if (self.(ammo_fields[W_GetAmmoField(weap.ammo1)]) < weap.ammo_usage)
		return FALSE;

	float clip = min(clipsize - self.(clip_fields[W_GetClipField(weap.name)]), self.(ammo_fields[W_GetAmmoField(weap.ammo1)]));
	
	if (clip <= 0)
		return FALSE;

	W_SetWeaponAnim2(frame_start, frame_end, frame_reset, framerate);
	
	self.attack_finished = time + delay;
	self.nextidle = time + 3;
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
			// TraceAttack if enemy is dead, we have a quad, or we can gib.
			if (HasBeenShotToDeath(trace_ent) || trace_ent.deadflag == DEAD_NO || has_quad(self) || can_gib)
			{
				TraceAttack (damage, dir);
			}
			else
			{
				ClearMultiDamage();
				TraceAttack (damage, dir);
			}
		}
		
		// Corpse checker!
		// Do this check on the final pellet so
		// things don't get to computationally intense!
		// - serecky 11.19.25
		if (shot == shots)
		{
			traceline(src, src + dir * distance, 0, self);
			
			if (HL_CorpseChecker(trace_endpos) != world)
			{
				trace_ent = HL_CorpseChecker(trace_endpos);
				TraceAttack (damage, dir);
			}
		}
		// Put bubble trail here...
	}
	
	// Check to prevent gibbing from bullet based weapons.
	if (can_gib)
	{
		ApplyMultiDamage();
	}
	else
	{
		if (trace_ent.deadflag == DEAD_NO || (has_quad(self)))
			ApplyMultiDamage();
	}
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
			sound (self, CHAN_WEAPON, "hl_weapons/pl_shell1.wav", 1, ATTN_NORM);
		else if (r < 0.666)
			sound (self, CHAN_WEAPON, "hl_weapons/pl_shell2.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "hl_weapons/pl_shell3.wav", 1, ATTN_NORM);	
	}
	else 
	{
		if (r < 0.333)
			sound (self, CHAN_WEAPON, "hl_weapons/sshell1.wav", 1, ATTN_NORM);
		else if (r < 0.666)
			sound (self, CHAN_WEAPON, "hl_weapons/sshell2.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_WEAPON, "hl_weapons/sshell3.wav", 1, ATTN_NORM);	
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
	precache_sound("hl_weapons/cbar_hit1.wav");
	precache_sound("hl_weapons/cbar_hit2.wav");
	precache_sound("hl_weapons/cbar_hitbod1.wav");
	precache_sound("hl_weapons/cbar_hitbod2.wav");
	precache_sound("hl_weapons/cbar_hitbod3.wav");
	precache_sound("hl_weapons/cbar_miss1.wav");
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
			sound(self, CHAN_WEAPON, "hl_weapons/cbar_miss1.wav", 1, ATTN_NORM);
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
				sound(self, CHAN_WEAPON, "hl_weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
			else if (r < 0.66)
				sound(self, CHAN_WEAPON, "hl_weapons/cbar_hitbod2.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_WEAPON, "hl_weapons/cbar_hitbod3.wav", 1, ATTN_NORM);
		}
		else
		{
			if (r < 0.5)
				sound(self, CHAN_ITEM, "hl_weapons/cbar_hit1.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_ITEM, "hl_weapons/cbar_hit2.wav", 1, ATTN_NORM);
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
	precache_sound("hl_items/9mmclip1.wav");
	precache_sound("hl_items/9mmclip2.wav");
	precache_sound ("hl_weapons/pl_gun3.wav");
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
	sound(self, CHAN_WEAPON, "hl_weapons/pl_gun3.wav", random(0.92, 1.0), ATTN_NORM);
	
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
		sound(self, CHAN_WEAPON, "hl_items/9mmclip2.wav", 1.0, ATTN_NORM);
	if (self.weaponframe == 62 || self.weaponframe == 104)
		sound(self, CHAN_WEAPON, "hl_items/9mmclip1.wav", 1.0, ATTN_NORM);
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
	//PRECACHE_MODEL("models/w_shotgun.mdl");
	precache_sound("hl_items/9mmclip1.wav");              
	precache_sound ("hl_weapons/dbarrel1.wav");
	precache_sound ("hl_weapons/sbarrel1.wav");
	precache_sound ("hl_weapons/reload1.wav");
	precache_sound ("hl_weapons/reload3.wav");
	precache_sound ("hl_weapons/357_cock1.wav");
	precache_sound ("hl_weapons/scock1.wav");
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

	sound(self, CHAN_WEAPON, "hl_weapons/sbarrel1.wav", random(0.95, 1.0), ATTN_NORM);
	
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

	sound(self, CHAN_WEAPON, "hl_weapons/dbarrel1.wav", random(0.98, 1.0), ATTN_NORM);
	
	vector src = self.origin + self.view_ofs;
	vector dir = aim (self, AUTOAIM_DIST);
	
	if (deathmatch)
		HL_FireBullets(8, src, dir, VECTOR_CONE_10DEGREES, 2048, 12, FALSE);
	else
		HL_FireBullets(12, src, dir, VECTOR_CONE_10DEGREES, 2048, 12, FALSE);
		
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
		sound(self, CHAN_WEAPON, "hl_weapons/scock1.wav", 1.0, ATTN_NORM);
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
				if ((self.button0) && (self.clip_shotgun >= 1)) // If we want to shoot..
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
							sound(self, CHAN_WEAPON, "hl_weapons/reload1.wav", 1.0, ATTN_NORM);
						else
							sound(self, CHAN_WEAPON, "hl_weapons/reload3.wav", 1.0, ATTN_NORM);
						
						self.ammo_shells -= 1;
						self.currentammo = self.clip_shotgun += 1;
						self.attack_finished = time + 0.5;
						
					}
					else // We're done with our reload!
					{
						W_SetWeaponAnim2(72, 82, 82, 13);

						sound(self, CHAN_WEAPON, "hl_weapons/scock1.wav", 1.0, ATTN_NORM);
						
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
	precache_sound("hl_items/9mmclip1.wav");
	precache_sound("hl_items/clipinsert1.wav");
	precache_sound("hl_items/cliprelease1.wav");
	precache_sound ("hl_weapons/hks1.wav");
	precache_sound ("hl_weapons/hks2.wav");
	precache_sound ("hl_weapons/hks3.wav");
	precache_sound( "hl_weapons/glauncher.wav" );
	precache_sound( "hl_weapons/glauncher2.wav" );
	precache_sound ("hl_weapons/357_cock1.wav");
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
		sound(self, CHAN_WEAPON, "hl_weapons/hks1.wav", 1.0, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "hl_weapons/hks2.wav", 1.0, ATTN_NORM);
	
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
		sound(self, CHAN_WEAPON, "hl_weapons/glauncher.wav", 0.8, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "hl_weapons/glauncher2.wav", 0.8, ATTN_NORM);
		
	W_CreateContactGren(self.origin + self.view_ofs + v_forward * 16, v_forward * 500);
		
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
		sound(self, CHAN_WEAPON, "hl_items/cliprelease1.wav", 1.0, ATTN_NORM);
	if (self.weaponframe == 69)
		sound(self, CHAN_WEAPON, "hl_items/clipinsert1.wav", 1.0, ATTN_NORM);
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

	precache_sound("hl_weapons/gauss2.wav");
	precache_sound("hl_weapons/electro4.wav");
	precache_sound("hl_weapons/electro5.wav");
	precache_sound("hl_weapons/electro6.wav");
	
	precache_sound("hl_weapons/charge.wav");
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
			sound(self, CHAN_WEAPON, "hl_weapons/electro4.wav", 1.0, ATTN_NORM);
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
			sound(self, CHAN_WEAPON, "hl_weapons/357_cock1.wav", 0.8, ATTN_NORM);
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
			sound(self, CHAN_WEAPON, "hl_weapons/charge.wav", 1.0, ATTN_NORM);
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
				sound(self, CHAN_WEAPON, "hl_weapons/electro4.wav", 1.0, ATTN_NORM);
				sound(self, CHAN_ITEM, "hl_weapons/electro6.wav", 1.0, ATTN_NORM);
				
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
	
	if (self.attack_phase != 3)
	{
		local float zvel = self.velocity_z;
		
		if (!primary)
		{
			self.velocity = self.velocity - v_forward * damage * 5;
		}
		
		if (deathmatch)
		{
			self.velocity_z = zvel;
		}
		
		W_SetWeaponAnim2(13, 40, 73, 20);
		player_shot1();
	}
	sound(self, CHAN_WEAPON, "hl_weapons/gauss2.wav", 0.5 + damage * (1.0 / 400.0), ATTN_NORM);
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
			self.noise = "hl_weapons/electro4.wav";
		if (rs == 2)
			self.noise = "hl_weapons/electro5.wav";
		if (rs == 3)
			self.noise = "hl_weapons/electro6.wav";
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