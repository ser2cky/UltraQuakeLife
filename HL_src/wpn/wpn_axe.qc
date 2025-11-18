/*
===============

THE AXE

===============
*/

// SOUNDS

void() W_AxeWhiffSound =
{
		sound (self, CHAN_OTHER, "weapons/ax1.wav", 1, ATTN_NORM);
}

void() W_AxeHitSound =
{
	if (random() < 0.5)
		sound (self, CHAN_WEAPON, "weapons/axhit1.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "weapons/axhit2.wav", 1, ATTN_NORM);
}

/*
================
W_FireAxe
================
*/

void() W_FireAxe =
{
	vector	source, org;
	if (self.health <= 0)
		return;
	
	makevectors (self.v_angle);
	source = self.origin + self.view_ofs;//'0 0 16';
	traceline2(source, source + v_forward * (64), self, 0);
	if (trace_ent == self)
		return;	// some notrace shit happened
	if (trace_fraction == 1.0) 
		return;
	
	self.show_hostile = time + 1;	// wake monsters up
	
	org = trace_endpos - v_forward*4;
	
	if (trace_ent.takedamage)
	{
		trace_ent.customflags = trace_ent.customflags | CFL_AXEHITME;
		SpawnBlood (org, '0 0 0', 20);
		T_Damage (trace_ent, self, self, 24, DMGTYPE_MELEE);
		
		if (trace_ent.flags & FL_MONSTER)
		{
			if (trace_ent.type == "zombie")
				zombie_knockdown(trace_ent);
			W_AxeHitSound();
		}
		else
		{
			sound (self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_IDLE);
		}
		
		// do knockback with a quad
		if (has_quad(self))
		{
			if ((trace_ent.movetype == MOVETYPE_STEP || trace_ent.movetype == MOVETYPE_WALK) && 
				// don't swat bosses or other non-standard-sized enemies around
				trace_ent.maxs_x <= 32 && trace_ent.health > 0 && trace_ent.type != "boss")
			{
				local vector toss;
				toss = v_forward;
				toss_z = 0;
				toss = normalize(toss) * 400;
				toss_z = 100;
				//bprint(vtos(toss));
				//bprint("\n");
				//toss *=  - vlen(head.maxs - head.mins)
				trace_ent.origin_z = trace_ent.origin_z + 1;
				trace_ent.velocity = toss;
				trace_ent.flags = not(trace_ent.flags, FL_ONGROUND);
			}
		}
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		gunshot(org);
	}
}

/*
================
W_FireAnimatedAxe
================
*/

float()	W_FireAnimatedAxe =
{
	if (self.health <= 0)
		return FALSE;

	float r;
	r = random();
	if (r < 0.25)
	{
		W_SetWeaponAnim(1, 4, 0, 10);
		player_axe1();
	}
	else if (r<0.5)
	{
		W_SetWeaponAnim(5, 8, 0, 10);
		player_axeb1();
	}
	else if (r<0.75)
	{
		W_SetWeaponAnim(1, 4, 0, 10);
		player_axec1();
	}
	else
	{
		W_SetWeaponAnim(5, 8, 0, 10);
		player_axed1();
	}
	
	self.attack_finished = time + 0.5;
	return TRUE;
}