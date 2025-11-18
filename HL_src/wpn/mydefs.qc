//======================================
//
//	mydefs.qc
//	yes.. i do like me some defs...
//
//	History:
//	11.12.25: Started.
//
//======================================

.float weapons;
.float attack_phase;
.float firemode;

// extra timers for ents.
.float nextstep;
.float nextidle;
.float attack2_finished;
.float fuser1;
.float fuser2;
.float fuser3;
.float fuser4;
.float fuser5;
.float fuser6;

// weapon state defs
.float weaponstate;
float WS_DEPLOY = 0;
float WS_READY = 1;
float WS_RELOAD = 2;
float WS_HOLSTER = 3;

// animation stuff
.float fps;
.float nextanim;
.float targetframe;
.float startframe;
.float endframe;

.float clip_mp5;
.float clip_glock;

float MAX_WEAPON_NUM = 8;

const float WPN_NONE 				= 16777216;
const float	WPN_AXE					= 4096;
const float	WPN_SHOTGUN				= 1;
const float	WPN_SUPER_SHOTGUN		= 2;
const float	WPN_NAILGUN				= 4;
const float	WPN_SUPER_NAILGUN		= 8;
const float	WPN_GRENADE_LAUNCHER	= 16;
const float	WPN_ROCKET_LAUNCHER		= 32;
const float	WPN_LIGHTNING			= 64;
const float WPN_GAUSS				= 128;
const float WPN_MP5					= 256;
const float	WPN_WEAPONS				= 127 + 4096;

const float HUD_WPNS = WPN_AXE + WPN_SHOTGUN + WPN_SUPER_SHOTGUN + WPN_NAILGUN + WPN_SUPER_NAILGUN
					+ WPN_GRENADE_LAUNCHER + WPN_ROCKET_LAUNCHER + WPN_LIGHTNING;
					
const float ALL_WPNS = WPN_AXE + WPN_SHOTGUN + WPN_SUPER_SHOTGUN + WPN_NAILGUN + WPN_SUPER_NAILGUN
					+ WPN_GRENADE_LAUNCHER + WPN_ROCKET_LAUNCHER + WPN_LIGHTNING + WPN_MP5 + WPN_GAUSS;

float WFL_HAS_CLIP = 1;

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
