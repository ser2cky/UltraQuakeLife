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
const float FL_ALMOST_DEAD = 32768;

.float player_modelindex;
.float player_modelnumber;

float modelindex_hgrunt;
float modelindex_gordon;

/*
============
Basic weapon fields.
============
*/

.float firemode;	// don't mess
.float weapons;		// don't mess

.float nextidle;
.float attack2_finished;
.float attack_phase;

// WEAPON SPECIFIC!!!
// MUST NOT BE CLEARED!!
.float satchel_ready;

// Weapon state stuff.
.float weaponstate;
float WS_DEPLOY = 0;
float WS_READY = 1;
float WS_RELOAD = 2;
float WS_HOLSTER = 3;
float WS_SPECIAL_RELOAD = 4;

// Weapon flags.
float WFL_USABLE_IF_EMPTY = 1;

/*
============
Extra floats available
to ents.
============
*/

.float nextstep;

// Reuseable weapon floats.
.float fuser1;
.float fuser2;
.float fuser3;
.float fuser4;

// These are reserved!!
.float fuser5;
.float fuser6;

// Used for controlling ents
// attached to the player and
// others.

.entity ent1;
.entity ent2;
.entity animcontroller;

// extra vectors
.vector vuser1;
.vector vuser2;
.vector vuser3;
.vector vuser4;

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
.float ammo_handgrenades;
.float ammo_satchels;
.float ammo_tripmines;
.float ammo_snarks;

.float clip_mp5;
.float clip_glock;
.float clip_shotgun;
.float clip_crossbow;
.float clip_rpg;
.float clip_python;

const float	MAX_AMMO_SHELLS			= 125;
const float	MAX_AMMO_NAILS			= 250;
const float	MAX_AMMO_ROCKETS		= 50;
const float	MAX_AMMO_CELLS			= 100;

const float	MAX_AMMO_HORNETS		= 8;
const float	MAX_AMMO_HANDGRENADES	= 15;
const float	MAX_AMMO_SATCHEL		= 10;
const float	MAX_AMMO_TRIPMINE		= 10;
const float	MAX_AMMO_SNARK			= 10;

/*
============
Weapon bit stuff
============
*/

const float MAX_WEAPON_NUM = 14;
const float NUMBER_OF_WEAPONS = 15;

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
const float WPN_HANDGRENADE			= 512;
const float WPN_TRIPMINE			= 1024;
const float WPN_SATCHEL				= 2048;
const float WPN_SNARK				= 8192;

// T.B.D IN THE FUTURE!!!
// const float WPN_DEAGLE				= 16384;
// const float WPN_SNIPER				= 32768;
// const float WPN_M249				= 65536;
// const float WPN_SPORE				= 131072;
// const float WPN_SHOCK_ROACH			= 262144;
// const float WPN_DISPLACER			= 524288;
// const float WPN_WRENCH				= 1048576;
// const float WPN_KNIFE				= 2097152;
// const float WPN_BARNACLE			= 4194304;
// const float WPN_ASSAULT_CANON		= 8388608; // tfc gun!!!
const float WPN_NONE 				= 16777216;
const float PI 						= 3.14159265358979323846;

// I wanted to add a few more T.F.C weapons like the
// 12.gauge or Nailguns, but I'd probably have to use
// the hack where you give the player a .weapons2 field..
// ehhhhh


const float	WPN_WEAPONS				= 127 + 4096;

const float HUD_WPNS = WPN_CROWBAR + WPN_GLOCK + WPN_SHOTGUN + WPN_MP5 + WPN_CROSSBOW
					+ WPN_RPG + WPN_HORNETGUN + WPN_GAUSS;
					
const float ALL_WPNS = WPN_CROWBAR + WPN_GLOCK + WPN_SHOTGUN + WPN_MP5 + WPN_CROSSBOW
					+ WPN_RPG + WPN_HORNETGUN + WPN_GAUSS + WPN_PYTHON + WPN_EGON + 
					WPN_HANDGRENADE + WPN_SATCHEL + WPN_TRIPMINE + WPN_SNARK;

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