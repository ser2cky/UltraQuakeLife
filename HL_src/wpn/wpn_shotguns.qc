/*
===============

wpn_shotguns.qc

===============
*/

/*
================
W_FireShotgun
================
*/
float() W_FireShotgun =
{
	if (self.currentammo <= 0)
		return FALSE;

	local vector dir;
	
	W_SetWeaponAnim(1, 6, 0, 10);
	
	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x = -2;
	makevectors(self.v_angle);
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, AUTOAIM_DIST);

	ClearMultiDamage ();
	FireBullets (6, dir, '0.04 0.04 0');
	self.attack_finished = time + 0.5;
	
	ApplyMultiDamage ();
	return TRUE;
}


/*
================
W_FireSuperShotgun
================
*/
float() W_FireSuperShotgun =
{
	if (self.currentammo <= 0)
		return FALSE;

	local vector dir;

	if (self.currentammo == 1)
	{
		if (self.items & IT_SHOTGUN)
			W_FireShotgun ();
		return TRUE;
	}

	W_SetWeaponAnim(1, 6, 0, 10);
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, AUTOAIM_DIST);

	ClearMultiDamage ();

	FireBullets (14, dir, '0.14 0.08 0');
	self.attack_finished = time + 0.7;
	
	ApplyMultiDamage ();
	return FALSE;
}
