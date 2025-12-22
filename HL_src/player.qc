/*
==============================================================================

PLAYER

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

// running 0-11
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6
$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

// standing 12-28
$frame stand1 stand2 stand3 stand4 stand5
$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12

// pain 13-40
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6
$frame pain1 pain2 pain3 pain4 pain5 pain6

// death 41-102
$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6 axdeth7 axdeth8 axdeth9
$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8 deatha9 deatha10 deatha11
$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8 deathb9
$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8 deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15
$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7 deathd8 deathd9
$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7 deathe8 deathe9

// gun attacks 103-118
$frame nailatt1 nailatt2
$frame light1 light2
$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6
$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

// ax attax 119-142
$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6
$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6
$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6
$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_stand1 =[	$axstnd1,	player_stand1	] 
{
	self.owner.frame = self.frame;

	if (self.owner.velocity_x || self.owner.velocity_y) 
	{
		self.owner.walkframe = 0;
		player_run();
		return;
	}
	

	if (self.owner.weapon == WPN_CROWBAR) 
	{
		if (self.owner.walkframe >= 12)
			self.owner.walkframe = 0;
		self.owner.frame = $axstnd1 + self.owner.walkframe;
	}
	else 
	{
		if (self.owner.walkframe >= 5)
			self.owner.walkframe = 0;
		self.owner.frame = $stand1 + self.owner.walkframe;
	}
	self.owner.walkframe = self.owner.walkframe + 1;	
};

void()	player_run =[	$rockrun1,	player_run	]
{
	self.owner.frame = self.frame;

	if (!self.owner.velocity_x && !self.owner.velocity_y)
	{
		self.owner.walkframe = 0;
		player_stand1();
		return;
	}


	if (self.owner.weapon == WPN_CROWBAR) 
	{
		if (self.owner.walkframe == 6)
			self.owner.walkframe = 0;
		self.owner.frame = $axrun1 + self.owner.walkframe;
	}
	else 
	{
		if (self.owner.walkframe == 6)
			self.owner.walkframe = 0;
		self.owner.frame = self.owner.frame + self.owner.walkframe;
	}

	self.owner.walkframe = self.owner.walkframe + 1;
}


void()	player_shot1 =	[$shotatt1, player_shot2	] {self.owner.frame = self.frame;};
void()	player_shot2 =	[$shotatt2, player_shot3	] {self.owner.frame = self.frame;};
void()	player_shot3 =	[$shotatt3, player_shot4	] {self.owner.frame = self.frame;};
void()	player_shot4 =	[$shotatt4, player_shot5	] {self.owner.frame = self.frame;};
void()	player_shot5 =	[$shotatt5, player_shot6	] {self.owner.frame = self.frame;};
void()	player_shot6 =	[$shotatt6, player_run		] {self.owner.frame = self.frame;};

void() player_nail1   =[$nailatt1, player_nail2 ] {self.owner.frame = self.frame;};
void() player_nail2   =[$nailatt2, player_run ] {self.owner.frame = self.frame;};

void() player_rockatt1	=[$rockatt1, player_rockatt2 ] {self.owner.frame = self.frame;};
void() player_rockatt2	=[$rockatt2, player_rockatt3 ] {self.owner.frame = self.frame;};
void() player_rockatt3	=[$rockatt3, player_rockatt4 ] {self.owner.frame = self.frame;};
void() player_rockatt4	=[$rockatt4, player_rockatt5 ] {self.owner.frame = self.frame;};
void() player_rockatt5	=[$rockatt5, player_rockatt6 ] {self.owner.frame = self.frame;};
void() player_rockatt6	=[$rockatt6, player_run ] {self.owner.frame = self.frame;};


void() player_light1 = [$light1, player_light2  ] {self.owner.frame = self.frame;}
void() player_light2 = [$light2, player_light1  ] {self.owner.frame = self.frame;}

void() player_axe1 = [ $axatt1, player_axe2 ] {self.owner.frame = self.frame;};
void() player_axe2 = [ $axatt2, player_axe3 ] {self.owner.frame = self.frame;};
void() player_axe3 = [ $axatt3, player_axe4 ] {self.owner.frame = self.frame;};
void() player_axe4 = [ $axatt4, player_run ] {self.owner.frame = self.frame;};

void() player_axeb1 = [ $axattb1, player_axeb2 ] {self.owner.frame = self.frame;};
void() player_axeb2 = [ $axattb2, player_axeb3 ] {self.owner.frame = self.frame;};
void() player_axeb3 = [ $axattb3, player_axeb4 ] {self.owner.frame = self.frame;};
void() player_axeb4 = [ $axattb4, player_run ] {self.owner.frame = self.frame;};

void() player_axec1 = [ $axattc1, player_axec2 ] {self.owner.frame = self.frame;};
void() player_axec2 = [ $axattc2, player_axec3 ] {self.owner.frame = self.frame;};
void() player_axec3 = [ $axattc3, player_axec4 ] {self.owner.frame = self.frame;};
void() player_axec4 = [ $axattc4, player_run ] {self.owner.frame = self.frame;};

void() player_axed1 = [ $axattd1, player_axed2 ] {self.owner.frame = self.frame;};
void() player_axed2 = [ $axattd2, player_axed3 ] {self.owner.frame = self.frame;};
void() player_axed3 = [ $axattd3, player_axed4 ] {self.owner.frame = self.frame;};
void() player_axed4 = [ $axattd4, player_run ] {self.owner.frame = self.frame;};

void() player_nail = {};
void() player_light = {};

void() PainSound = {
	float		rs;

	if (self.health < 0)
		return;
	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (self.modelindex == modelindex_player)
	{
		// water pain sounds
		if (self.watertype == CONTENT_WATER && self.waterlevel >= 3 && !has_biosuit(self))
		{
			DeathBubbles(1);
			if (random() > 0.5)
				sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
			return;
		}

		// slime/lava pain sounds
		if (( (self.watertype == CONTENT_SLIME || self.watertype == CONTENT_LAVA) && damage_attacker == world) || 
			damage_attacker.classname == "fireball")
		{
			if (random() > 0.5)
				sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
			return;
		}

		// don't make multiple pain sounds right after each other
		if (self.pain_finished > time)
		{
			self.customflags = not(self.customflags, CFL_AXEHITME );
			return;
		}
		self.pain_finished = time + 0.5;


	// ax pain sound
		if (self.customflags & CFL_AXEHITME)
		{
			self.customflags = not(self.customflags, CFL_AXEHITME );
			sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
			return;
		}
	
	}

	self.noise = string_null;
	
	if (self.modelindex == modelindex_player)
	{
		rs = rint((random() * 5) + 1);
		
		if (rs == 1)
			self.noise = "player/pain1.wav";
		else if (rs == 2)
			self.noise = "player/pain2.wav";
		else if (rs == 3)
			self.noise = "player/pain3.wav";
		else if (rs == 4)
			self.noise = "player/pain4.wav";
		else if (rs == 5)
			self.noise = "player/pain5.wav";
		else
			self.noise = "player/pain6.wav";
	}
	else
	{
		rs = rint((random() * 4) + 1);
	
		if (rs == 1)
			self.noise = "player/pl_pain2.wav";
		else if (rs == 2)
			self.noise = "player/pl_pain4.wav";
		else if (rs == 3)
			self.noise = "player/pl_pain5.wav";
		else if (rs == 4)
			self.noise = "player/pl_pain6.wav";
		else
			self.noise = "player/pl_pain7.wav";
	}

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	return;
}

void()	player_pain1 =	[	$pain1,	player_pain2	] {self.owner.frame = self.frame;}
void()	player_pain2 =	[	$pain2,	player_pain3	] {self.owner.frame = self.frame;}
void()	player_pain3 =	[	$pain3,	player_pain4	] {self.owner.frame = self.frame;}
void()	player_pain4 =	[	$pain4,	player_pain5	] {self.owner.frame = self.frame;}
void()	player_pain5 =	[	$pain5,	player_pain6	] {self.owner.frame = self.frame;}
void()	player_pain6 =	[	$pain6,	player_run	] {self.owner.frame = self.frame;}

void()	player_axpain1 =	[	$axpain1,	player_axpain2	] {self.owner.frame = self.frame;}
void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {self.owner.frame = self.frame;}
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {self.owner.frame = self.frame;}
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {self.owner.frame = self.frame;}
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {self.owner.frame = self.frame;}
void()	player_axpain6 =	[	$axpain6,	player_run	] {self.owner.frame = self.frame;}

void(entity attacker, float damage) player_pain =
{
	PainSound();

	if (has_invis(self))
		return;		// eyes don't have pain frames

	if (self.weapon == IT_AXE )
		SUB_CallAsSelf(player_axpain1, self.animcontroller);
	else
		SUB_CallAsSelf(player_pain1, self.animcontroller);
}

void() DeathBubblesSpawn =
{
	entity	bubble;
	if (self.owner.waterlevel < 3)
		return;
	bubble = bubble_spawn(self.owner.origin + '0 0 24');

	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished += 1;
	if (self.air_finished >= self.bubble_count)
		remove(self);
}

void(float num_bubbles) DeathBubbles =
{
local entity	bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	return;
}


void() DeathSound =
{
local float		rs;

	// water death sounds
	if (self.waterlevel >= 3 && !has_biosuit(self))
	{
		if (self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME)
		{
			DeathBubbles(20);
			sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
			return;
		}
	}
	
	
	if (self.modelindex == modelindex_player)
	{
		rs = rint ((random() * 4) + 1);
		if (rs == 1)
			self.noise = "player/death1.wav";
		if (rs == 2)
			self.noise = "player/death2.wav";
		if (rs == 3)
			self.noise = "player/death3.wav";
		if (rs == 4)
			self.noise = "player/death4.wav";
		if (rs == 5)
			self.noise = "player/death5.wav";
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	}
	
	return;
}


void(entity cl) PlayerDead = 
{
	cl.nextthink = -1;
// allow respawn after a certain time
	cl.deadflag = DEAD_DEAD;
};

void() GibPlayer =
{
	if (damage_attacker.classname == "trigger_void" || damage_attacker.classname == "func_void" )
	{
		sound (self, CHAN_VOICE, damage_attacker.owner.noise2, 1, ATTN_NONE);
		TintScreenColor(self, 255, '32 0 0');
		//stuffcmd( self, "\nv_cshift 16 0 0 255\n");
		return;
	}
	
	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
	}
	else if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
	}
	else
	{
		if (random() < 0.5)
			sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
		else
			sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
	}	
	GibSpray ("progs/h_player.mdl", self.health);	
}

void() PlayerDie =
{
	local	float	i;
	
	self.items = self.items - (self.items & IT_INVISIBILITY);
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.modelindex = self.player_modelindex;	// don't use eyes

	self.items = not(self.items, IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD);
	self.effects = 0;

	clientsAlive -= 1;

	set_respawn_delay();	// coop 1 respawn lockout
	
	if ((deathmatch || coop) && mapname != "start")
		DropBackpack();
	if (coop) // save the keys
		TransferKeys();
	
	self.weaponmodel = string_null;
	self.view_ofs = '0 0 0';
//	self.deadflag = DEAD_DYING;	// moved to Killed() so I can use this flag on monsters
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	//setsize(self, '-16 -16 -16', '16 16 8');
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	player_spawn_void_monitor();
	
	if (self.health < -40)
	{
		GibPlayer ();
		return;
	}

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;
	
	if (self.weapon == IT_AXE )
	{
		SUB_CallAsSelf(player_die_ax1, self.animcontroller);
		return;
	}
	
	i = 1 + floor(random()*6);
	
	if (i == 1)
		SUB_CallAsSelf(player_diea1, self.animcontroller);
	else if (i == 2)
		SUB_CallAsSelf(player_dieb1, self.animcontroller);
	else if (i == 3)
		SUB_CallAsSelf(player_diec1, self.animcontroller);
	else if (i == 4)
		SUB_CallAsSelf(player_died1, self.animcontroller);
	else
		SUB_CallAsSelf(player_diee1, self.animcontroller);
		
	// HLMOD
	self.satchel_ready = -1;
	W_DeactivatePlayerSatchels(self);
	// HLMOD

}

void() set_suicide_frame =
{	// used by kill command and disconnect command
	if (self.model != "progs/player.mdl")
		return;	// already gibbed
	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
}


void()	player_diea1	=	[	$deatha1,	player_diea2	] {self.owner.frame = self.frame;}
void()	player_diea2	=	[	$deatha2,	player_diea3	] {self.owner.frame = self.frame;}
void()	player_diea3	=	[	$deatha3,	player_diea4	] {self.owner.frame = self.frame;}
void()	player_diea4	=	[	$deatha4,	player_diea5	] {self.owner.frame = self.frame;}
void()	player_diea5	=	[	$deatha5,	player_diea6	] {self.owner.frame = self.frame;}
void()	player_diea6	=	[	$deatha6,	player_diea7	] {self.owner.frame = self.frame;}
void()	player_diea7	=	[	$deatha7,	player_diea8	] {self.owner.frame = self.frame;}
void()	player_diea8	=	[	$deatha8,	player_diea9	] {self.owner.frame = self.frame;}
void()	player_diea9	=	[	$deatha9,	player_diea10	] {self.owner.frame = self.frame;}
void()	player_diea10	=	[	$deatha10,	player_diea11	] {self.owner.frame = self.frame;}
void()	player_diea11	=	[	$deatha11,	player_diea11 ] {PlayerDead(self.owner);self.owner.frame = self.frame;}

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {self.owner.frame = self.frame;}
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {self.owner.frame = self.frame;}
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {self.owner.frame = self.frame;}
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {self.owner.frame = self.frame;}
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {self.owner.frame = self.frame;}
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {self.owner.frame = self.frame;}
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {self.owner.frame = self.frame;}
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {self.owner.frame = self.frame;}
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerDead(self.owner);self.owner.frame = self.frame;}

void()	player_diec1	=	[	$deathc1,	player_diec2	] {self.owner.frame = self.frame;}
void()	player_diec2	=	[	$deathc2,	player_diec3	] {self.owner.frame = self.frame;}
void()	player_diec3	=	[	$deathc3,	player_diec4	] {self.owner.frame = self.frame;}
void()	player_diec4	=	[	$deathc4,	player_diec5	] {self.owner.frame = self.frame;}
void()	player_diec5	=	[	$deathc5,	player_diec6	] {self.owner.frame = self.frame;}
void()	player_diec6	=	[	$deathc6,	player_diec7	] {self.owner.frame = self.frame;}
void()	player_diec7	=	[	$deathc7,	player_diec8	] {self.owner.frame = self.frame;}
void()	player_diec8	=	[	$deathc8,	player_diec9	] {self.owner.frame = self.frame;}
void()	player_diec9	=	[	$deathc9,	player_diec10	] {self.owner.frame = self.frame;}
void()	player_diec10	=	[	$deathc10,	player_diec11	] {self.owner.frame = self.frame;}
void()	player_diec11	=	[	$deathc11,	player_diec12	] {self.owner.frame = self.frame;}
void()	player_diec12	=	[	$deathc12,	player_diec13	] {self.owner.frame = self.frame;}
void()	player_diec13	=	[	$deathc13,	player_diec14	] {self.owner.frame = self.frame;}
void()	player_diec14	=	[	$deathc14,	player_diec15	] {self.owner.frame = self.frame;}
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerDead(self.owner);self.owner.frame = self.frame;}

void()	player_died1	=	[	$deathd1,	player_died2	] {self.owner.frame = self.frame;}
void()	player_died2	=	[	$deathd2,	player_died3	] {self.owner.frame = self.frame;}
void()	player_died3	=	[	$deathd3,	player_died4	] {self.owner.frame = self.frame;}
void()	player_died4	=	[	$deathd4,	player_died5	] {self.owner.frame = self.frame;}
void()	player_died5	=	[	$deathd5,	player_died6	] {self.owner.frame = self.frame;}
void()	player_died6	=	[	$deathd6,	player_died7	] {self.owner.frame = self.frame;}
void()	player_died7	=	[	$deathd7,	player_died8	] {self.owner.frame = self.frame;}
void()	player_died8	=	[	$deathd8,	player_died9	] {self.owner.frame = self.frame;}
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerDead(self.owner);self.owner.frame = self.frame;}

void()	player_diee1	=	[	$deathe1,	player_diee2	] {self.owner.frame = self.frame;}
void()	player_diee2	=	[	$deathe2,	player_diee3	] {self.owner.frame = self.frame;}
void()	player_diee3	=	[	$deathe3,	player_diee4	] {self.owner.frame = self.frame;}
void()	player_diee4	=	[	$deathe4,	player_diee5	] {self.owner.frame = self.frame;}
void()	player_diee5	=	[	$deathe5,	player_diee6	] {self.owner.frame = self.frame;}
void()	player_diee6	=	[	$deathe6,	player_diee7	] {self.owner.frame = self.frame;}
void()	player_diee7	=	[	$deathe7,	player_diee8	] {self.owner.frame = self.frame;}
void()	player_diee8	=	[	$deathe8,	player_diee9	] {self.owner.frame = self.frame;}
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerDead(self.owner);self.owner.frame = self.frame;}

void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {self.owner.frame = self.frame;}
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {self.owner.frame = self.frame;}
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {self.owner.frame = self.frame;}
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {self.owner.frame = self.frame;}
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {self.owner.frame = self.frame;}
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {self.owner.frame = self.frame;}
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {self.owner.frame = self.frame;}
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {self.owner.frame = self.frame;}
void()	player_die_ax9	=	[	$axdeth9,	player_die_ax9	] {PlayerDead(self.owner);self.owner.frame = self.frame;}
