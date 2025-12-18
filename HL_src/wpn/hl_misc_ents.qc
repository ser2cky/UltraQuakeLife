//======================================
//
//	hl_misc_ents.qc
//	Where random map-specific Half-Life
//	ents go.
//
//	History:
//	12.17.25: starte.d
//
//======================================

//============================================
//
//				ARMOR CHARGER
//
//============================================

void() recharge_precache =
{
	precache_sound("items/suitcharge1.wav");
	precache_sound("items/suitchargeno1.wav");
	precache_sound("items/suitchargeok2.wav");
}

void() func_recharge =
{
	recharge_precache();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
	
	// juice
	if (deathmatch)
		self.cnt = 30;
	else
		self.cnt = 50;

	//self.use = button_use;
	self.touch = recharge_touch;
}

void() recharge_touch =
{
	if (other.classname != "player")
		return;
		
	// Juice
	if (self.cnt <= 0)
	{
		self.frame = 1;
		recharge_off();
	}
	
	if (self.cnt <= 0)
	{
		// Nextsound timer
		if (self.fuser1 <= time)
		{
			self.fuser1 = time + 0.62;
			sound(self, CHAN_ITEM, "items/suitchargeno1.wav", 0.85, ATTN_NORM);
		}
		return;
	}
	
	self.nextthink = self.ltime + 0.25;
	self.think = recharge_off;
	
	// Next charge.
	if (self.fuser2 >= time)
		return;
		
	if (!self.fuser3)
	{
		self.fuser3 += 1;
		sound(self, CHAN_ITEM, "items/suitchargeok2.wav", 0.85, ATTN_NORM);
		self.fuser1 = 0.56 + time;
	}
	
	if ((self.fuser3 == 1) && (self.fuser1 <= time))
	{
		self.fuser3 += 1;
		sound(self, CHAN_VOICE, "items/suitcharge1.wav", 0.85, ATTN_NORM);
	}
		
	if (other.armorvalue < 200)
	{
		self.cnt -= 1;
		other.armorvalue = min(other.armorvalue + 1, 200);
		
		if (other.armorvalue <= 100)
		{
			other.items |= IT_ARMOR1;
			other.armortype = ARMORTYPE_GREEN;
		}
		else if (other.armorvalue <= 150)
		{
			other.items |= IT_ARMOR2;
			other.armortype = ARMORTYPE_YELLOW;
		}
		else if (other.armorvalue <= 200)
		{
			other.items |= IT_ARMOR3;
			other.armortype = ARMORTYPE_RED;
		}
	}
	
	// Next charge.
	self.fuser2 = time + 0.1;
}

void() recharge_fill_up =
{
	// juice
	if (deathmatch)
		self.cnt = 30;
	else
		self.cnt = 50;
	self.frame = 0;		
	self.think = SUB_Null;
}

void() recharge_off =
{
	if (self.fuser3 > 1)
		sound( self, CHAN_VOICE, "misc/null.wav", 1.0, ATTN_NORM );
		
	self.fuser3 = 0;
	
	if (!self.cnt && (deathmatch || coop))
	{
		self.nextthink = self.ltime + 30.0;
		self.think = recharge_fill_up;
	}
	else
	{
		self.think = SUB_Null;
	}
}

//============================================
//
//				HEALTH CHARGER
//
//============================================

void() healthcharger_precache =
{
	precache_sound("items/medshot4.wav");
	precache_sound("items/medshotno1.wav");
	precache_sound("items/medcharge4.wav");
}

void() func_healthcharger =
{
	healthcharger_precache();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);
	
	// juice
	self.cnt = 50;

	//self.use = button_use;
	self.touch = healthcharger_touch;
}

void() healthcharger_touch =
{
	if (other.classname != "player")
		return;
		
	// Juice
	if (self.cnt <= 0)
	{
		self.frame = 1;
		healthcharger_off();
	}
	
	if (self.cnt <= 0)
	{
		// Nextsound timer
		if (self.fuser1 <= time)
		{
			self.fuser1 = time + 0.62;
			sound(self, CHAN_ITEM, "items/medshotno1.wav", 0.85, ATTN_NORM);
		}
		return;
	}
	
	self.nextthink = self.ltime + 0.25;
	self.think = healthcharger_off;
	
	// Next charge.
	if (self.fuser2 >= time)
		return;
		
	if (!self.fuser3)
	{
		self.fuser3 += 1;
		sound(self, CHAN_ITEM, "items/medshot4.wav", 0.85, ATTN_NORM);
		self.fuser1 = 0.56 + time;
	}
	
	if ((self.fuser3 == 1) && (self.fuser1 <= time))
	{
		self.fuser3 += 1;
		sound(self, CHAN_VOICE, "items/medcharge4.wav", 0.85, ATTN_NORM);
	}
		
	if (T_Heal(other, 1, FALSE))
	{
		self.cnt -= 1;
	}
	
	// Next charge.
	self.fuser2 = time + 0.1;
}

void() healthcharger_fill_up =
{
	// juice
	self.cnt = 50;
	self.frame = 0;		
	self.think = SUB_Null;
}

void() healthcharger_off =
{
	if (self.fuser3 > 1)
		sound( self, CHAN_VOICE, "misc/null.wav", 1.0, ATTN_NORM );
		
	self.fuser3 = 0;
	
	if (!self.cnt && (deathmatch || coop))
	{
		self.nextthink = self.ltime + 30.0;
		self.think = recharge_fill_up;
	}
	else
	{
		self.think = SUB_Null;
	}
}