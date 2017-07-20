#include "\A3XAI\globaldefines.hpp"

private ["_expireTime", "_startTime", "_cfgWorldName"];

_expireTime = diag_tickTime + SERVER_START_TIMEOUT;
waitUntil {uiSleep 3; !isNil "A3XAI_locations_ready" && {(!isNil SERVER_STARTED_INDICATOR) or {diag_tickTime > _expireTime}}};

if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: %1 is generating static spawns.",__FILE__];};

_startTime = diag_tickTime;
_cfgWorldName = configFile >> "CfgWorlds" >> worldName >> "Names";

{
	_placePos = _x;
	
	try {
		if ((typeName _placePos) != "ARRAY") then {
			throw format ["A3XAI Debug: %1 unable to create static spawn at non-array position %2",__FILE__,_placePos];
		};
		if ((count _placePos) < 2) then {
			throw format ["A3XAI Debug: %1 unable to create static spawn at position %1, position has fewer than 2 elements.",__FILE__,_placePos];
		};
		if (surfaceIsWater _placePos) then {
			throw format ["A3XAI Debug: Static spawn not created at %1 due to water position.",_placePos];
		};
		if !((_placePos nearObjects [PLOTPOLE_OBJECT,PLOTPOLE_RADIUS]) isEqualTo []) then {
			throw format ["A3XAI Debug: Static spawn not created at %1 due to nearby Frequency Jammer.",_placePos];
		};
		
		_nearbldgs 				= _placePos nearObjects ["HouseBase",STATIC_SPAWN_OBJECT_RANGE];
		_nearBlacklistedAreas 	= nearestLocations [_placePos,[BLACKLIST_OBJECT_GENERAL],1500];
		_spawnPoints 			= 0;
		_respawnLimit 			= -1;
		_spawnParams 			= _placePos call A3XAI_getSpawnParams;
		_aiCount 				= [_spawnParams select 0,_spawnParams select 1];
		_unitLevel 				= _spawnParams select 2;
		_spawnChance 			= _spawnParams select 3;
		_placeName 				= _spawnParams select 4;
		_placeType 				= _spawnParams select 5;
		_radiusA 				= getNumber (_cfgWorldName >> _placeName >> "radiusA");
		_radiusB 				= getNumber (_cfgWorldName >> _placeName >> "radiusB");
		_patrolRadius 			= (((_radiusA min _radiusB) max STATIC_SPAWN_MIN_PATROL_RADIUS) min STATIC_SPAWN_MAX_PATROL_RADIUS);
		
		{
			_objType = (typeOf _x);
			_objPos = (getPosATL _x);
			if (!(surfaceIsWater _objPos) && {(sizeOf _objType) > STATIC_SPAWN_OBJECT_SIZE_REQ}) then {
				if ((({_objPos in _x} count _nearBlacklistedAreas) > 0) or {([_objPos,SPAWN_DIST_FROM_NO_AGGRO_AREA] call A3XAI_checkInNoAggroArea)}) then {
					if ((_objPos distance2D _placePos) < _patrolRadius) then {
						throw format ["A3XAI Debug: Static spawn not created at %1. A spawn position is within %2 m of a blacklisted area.",_placePos,_objPos distance2D _placePos];
					} else {
						_nearbldgs deleteAt _forEachIndex;
					};
				} else {
					_spawnPoints = _spawnPoints + 1;
				};
			} else {
				_nearbldgs deleteAt _forEachIndex;
			};
		} forEach _nearbldgs;
		
		if (_spawnPoints < 6) then {
			if (A3XAI_enableExtraStaticSpawns) then {
				_nearbldgs = [];
			} else {
				throw format ["A3XAI Debug: Static spawn not created at %1. Acceptable positions: %2, Total: %3",_placePos,_spawnPoints,(count _nearbldgs)];
			};
		};
		
		_trigger = [_placePos,_placeName] call A3XAI_createTriggerArea;
		_result = [_trigger,_spawnParams] call A3XAI_setSpawnParams;

		if ((_spawnChance <= 0) or {(_aiCount isEqualTo [0,0])}) then {
			throw format ["A3XAI Debug: Static spawn not created at %1. Spawn chance zero or AI count zero.",_placeName];
		};
		
		call {
			if (_placeType isEqualTo "namecitycapital") exitWith {
				_respawnLimit = A3XAI_respawnLimit_capitalCity;
			};
			if (_placeType isEqualTo "namecity") exitWith {
				_respawnLimit = A3XAI_respawnLimit_city;
			};
			if (_placeType isEqualTo "namevillage") exitWith {
				_respawnLimit = A3XAI_respawnLimit_village;
			};
			if (_placeType isEqualTo "namelocal") exitWith {
				_respawnLimit = A3XAI_respawnLimit_remoteArea;
			};
		};
		
		_trigger setVariable ["respawnLimit",_respawnLimit];
		_trigger setVariable ["respawnLimitOriginal",_respawnLimit];
		_trigger setVariable ["A3XAI_static_spawn",true];
		0 = [0,_trigger,[],_patrolRadius,_unitLevel,_nearbldgs,_aiCount,_spawnChance] call A3XAI_initializeTrigger;
		A3XAI_staticSpawnObjects pushBack _trigger;
	} catch {
		if (A3XAI_debugLevel > 0) then {diag_log _exception;};
	};
	if ((_forEachIndex % 5) isEqualTo 0) then {uiSleep 0.25;};
} forEach A3XAI_manualStaticSpawnLocations;

if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: %1 has finished generating %2 static spawns in %3 seconds.",__FILE__,(count A3XAI_staticSpawnObjects),(diag_tickTime - _startTime)];};
