//======================================
//
//	mydefs.qc
//	yes.. i do like me some defs...
//
//	History:
//	11.12.25: Started.
//
//======================================

const float FL_CORPSE = 16384;

/*
============
Basic weapon fields.
============
*/

.float weapons;
.float attack_phase;
.float firemode;
.float nextidle;
.float attack2_finished;

// Weapon state stuff.
.float weaponstate;
float WS_DEPLOY = 0;
float WS_READY = 1;
float WS_RELOAD = 2;
float WS_HOLSTER = 3;
float WS_SPECIAL_RELOAD = 4;

// Weapon flags.
float WFL_HAS_CLIP = 1;

/*
============
Extra floats available
to ents.
============
*/

.float nextstep;
.float fuser1;
.float fuser2;
.float fuser3;
.float fuser4;
.float fuser5;
.float fuser6;

// Used for controlling ents
// attached to the player and
// others.
.entity ent1;
.entity ent2;

/*
============
Animation defs.
============
*/

.float fps;
.float nextanim;
.float targetframe;
.float startframe;
.float endframe;

/*
============
New ammo defs.
============
*/

.float ammo_hornets;
.float clip_mp5;
.float clip_glock;
.float clip_shotgun;
.float clip_crossbow;
.float clip_rpg;
.float clip_python;

/*
============
Weapon bit stuff
============
*/

const float MAX_WEAPON_NUM = 8;
const float NUMBER_OF_WEAPONS = 11;

const float WPN_NONE 				= 16777216;

const float	WPN_CROWBAR				= 4096;
const float	WPN_GLOCK				= 1;
const float	WPN_SHOTGUN				= 2;
const float	WPN_MP5					= 4;
const float	WPN_CROSSBOW			= 8;
const float	WPN_RPG					= 16;
const float	WPN_HORNETGUN			= 32;
const float	WPN_GAUSS				= 64;
const float WPN_PYTHON				= 128;
const float WPN_EGON				= 256;

const float	WPN_WEAPONS				= 127 + 4096;

const float HUD_WPNS = WPN_CROWBAR + WPN_GLOCK + WPN_SHOTGUN + WPN_MP5 + WPN_CROSSBOW
					+ WPN_RPG + WPN_HORNETGUN + WPN_GAUSS;
					
const float ALL_WPNS = WPN_CROWBAR + WPN_GLOCK + WPN_SHOTGUN + WPN_MP5 + WPN_CROSSBOW
					+ WPN_RPG + WPN_HORNETGUN + WPN_GAUSS + WPN_PYTHON + WPN_EGON;

/*
============
Stupid Vector_CONE
stuff.
============
*/

vector VECTOR_CONE_1DEGREES = '0.00873 0.00873 0.00873';
vector VECTOR_CONE_2DEGREES = '0.01745 0.01745 0.01745';
vector VECTOR_CONE_3DEGREES = '0.02618 0.02618 0.02618';
vector VECTOR_CONE_4DEGREES = '0.03490 0.03490 0.03490';
vector VECTOR_CONE_5DEGREES = '0.04362 0.04362 0.04362';
vector VECTOR_CONE_6DEGREES = '0.05234 0.05234 0.05234';
vector VECTOR_CONE_7DEGREES = '0.06105 0.06105 0.06105';
vector VECTOR_CONE_8DEGREES = '0.06976 0.06976 0.06976';
vector VECTOR_CONE_9DEGREES = '0.07846 0.07846 0.07846';
vector VECTOR_CONE_10DEGREES = '0.08716 0.08716 0.08716';
vector VECTOR_CONE_15DEGREES = '0.13053 0.13053 0.13053';
vector VECTOR_CONE_20DEGREES = '0.17365 0.17365 0.17365';

#pragma noref 0