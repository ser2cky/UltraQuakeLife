// 11.16.25
// WEAPON NOTES
// 1 - CROWBAR, SATCHEL, HANDGREN, TRIPMINE
// 2 - HANDGUN, .357, OP4 DEAGLE
// 3 - SHOTGUN, 
// 4 - MP5, TFCSNIPER AUTO, TFC NAILGUN
// 5 - CROSSBOW, TFC SNIPER, OP4 SNIPER, TFC SUPER NAILGUN
// 6 - HORNETGUN, SHOCK RIFLE, SNARK
// 7 - ROCKET LAUNCHER, TFC G-LAUNCHER
// 8 - TAU, GLUON, TFC FLAMETHROWER

// glock
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


//today's progress
// Finished MP5
// starting on conv. glock mdl
// fixed hl explosions ( mostly)
// added shell casings
// footsteps
// started on conv spas, crowbar

//11.17.25

//shotgun
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

// Finished SHOTGUN
// finished GLOCK

// 11.18.25

// changed dmg values
// glock: 8 -> 16
// shotgun: 5 - > 10
// shotgun (super): 5 - > 12
// added gibby corpses.

// 11.19.25
// fixed gibby corpses
// crowbar
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

// 11.22.25
// crossbow. fixes

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

// hornet gun
// 0 - 20 : deploy 20 fps
// 21 - 29 : fire 20 fps
// 30 - 60 : idle 1 loop 16 fps
// 61 - 101 : idle 2 16 fps
// 102 - 137 : idle 3 16 fps
// 138 - 156 : Holster 16 fps

// 11.23.25
// rpg
// anims 20 fps 'less stated otherwise
// 0 - 10 : draw loaded
// 11 - 21 : draw un loaded
// 22 - 38 : fire
// 39 - 79 : reload
// 80 - 128 : idle loaded  8fps
// 129 - 177 : idle unloaded 8fps
// 178 - 202 : fidget loaded 8fps
// 203 - 227 : fidget unloaded 8fps
// 228 - 238 : holster loaded 8fps
// 239 - 249 : holster unloaded 8fps

// Did :
// rpg
// gfx

//11.24.25
// fix to rpg
// Removed being able to select
// the same weapon over&over again.
// added python

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

// tfc nailgun
// 0 - 10 draw
// 11 - 18 shoot 1
// 19 - 25 shoot 2
// 26 - 31 shoot 3
// 32 - 52 idle

//11.25.25
// egon
// 0-10 draw
// 11-21 fire1 loop
// 22-32 fire2 loop
// 33-40 fire3 loop
// 41-51 fire4 loop
// 52-68 idle1 loop 8 fps
// 69-90 fidget1 8 fps
// 91-101 holster