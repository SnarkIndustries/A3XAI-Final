#include "\A3XAI\globaldefines.hpp"

private ["_expireTime", "_startTime", "_cfgWorldName"];

_expireTime = diag_tickTime + SERVER_START_TIMEOUT;
waitUntil {uiSleep 3; !isNil "A3XAI_locations_ready" && {(!isNil SERVER_STARTED_INDICATOR) or {diag_tickTime > _expireTime}}};

if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: %1 is generating static spawns.",__FILE__];};

_startTime = diag_tickTime;
_cfgWorldName = configFile >> "CfgWorlds" >> worldName >> "Names";

{
	private ["_placeName","_placePos","_placeType","_trigger"];
	_placeName = _x select 0;
	_placePos = _x select 1;
	_placeType = _x select 2;
	_trigger = _x select 3;
	
	try {
		if (isNull _trigger) then {
			throw format ["A3XAI Debug: Static spawn not created at %1 due to null trigger object.",_placeName];
		};
		if (surfaceIsWater _placePos) then {
			throw format ["A3XAI Debug: Static spawn not created at %1 due to water position.",_placeName];
		};
		
		if !((_placePos nearObjects [PLOTPOLE_OBJECT,PLOTPOLE_RADIUS]) isEqualTo []) then {
			throw format ["A3XAI Debug: Static spawn not created at %1 due to nearby Frequency Jammer.",_placeName];
		};
		
		_nearbldgs = _placePos nearObjects ["HouseBase",STATIC_SPAWN_OBJECT_RANGE];
		_nearBlacklistedAreas = nearestLocations [_placePos,[BLACKLIST_OBJECT_GENERAL],1500];
		_spawnPoints = 0;
		_aiCount = [0,0];
		_unitLevel = 0;
		_radiusA = getNumber (_cfgWorldName >> (_x select 0) >> "radiusA");
		_radiusB = getNumber (_cfgWorldName >> (_x select 0) >> "radiusB");
		_patrolRadius = (((_radiusA min _radiusB) max STATIC_SPAWN_MIN_PATROL_RADIUS) min STATIC_SPAWN_MAX_PATROL_RADIUS);
		_spawnChance = 0;
		_respawnLimit = -1;
		
		{
			_objType = (typeOf _x);
			_objPos = (getPosATL _x);
			if (!(surfaceIsWater _objPos) && {(sizeOf _objType) > STATIC_SPAWN_OBJECT_SIZE_REQ}) then {
				if ((({_objPos in _x} count _nearBlacklistedAreas) > 0) or {([_objPos,SPAWN_DIST_FROM_NO_AGGRO_AREA] call A3XAI_checkInNoAggroArea)}) then {
					if ((_objPos distance2D _placePos) < _patrolRadius) then {
						throw format ["A3XAI Debug: Static spawn not created at %1. A spawn position is within %2 m of a blacklisted area.",_placeName,_objPos distance2D _placePos];
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
				throw format ["A3XAI Debug: Static spawn not created at %1. Acceptable positions: %2, Total: %3",_placeName,_spawnPoints,(count _nearbldgs)];
			};
		};
		
		call {
			if (_placeType isEqualTo "namecitycapital") exitWith {
				_aiCount = [A3XAI_minAI_capitalCity,A3XAI_addAI_capitalCity];
				_unitLevel = A3XAI_unitLevel_capitalCity;
				_spawnChance = A3XAI_spawnChance_capitalCity;
				_respawnLimit = A3XAI_respawnLimit_capitalCity;
			};
			if (_placeType isEqualTo "namecity") exitWith {
				_aiCount = [A3XAI_minAI_city,A3XAI_addAI_city];
				_unitLevel = A3XAI_unitLevel_city;
				_spawnChance = A3XAI_spawnChance_city;
				_respawnLimit = A3XAI_respawnLimit_city;
			};
			if (_placeType isEqualTo "namevillage") exitWith {
				_aiCount = [A3XAI_minAI_village,A3XAI_addAI_village];
				_unitLevel = A3XAI_unitLevel_village;
				_spawnChance = A3XAI_spawnChance_village;
				_respawnLimit = A3XAI_respawnLimit_village;
			};
			if (_placeType isEqualTo "namelocal") exitWith {
				_aiCount = [A3XAI_minAI_remoteArea,A3XAI_addAI_remoteArea];
				_unitLevel = A3XAI_unitLevel_remoteArea;
				_spawnChance = A3XAI_spawnChance_remoteArea;
				_respawnLimit = A3XAI_respawnLimit_remoteArea;
			};
		};
		
		if ((_spawnChance <= 0) or {(_aiCount isEqualTo [0,0])}) then {
			throw format ["A3XAI Debug: Static spawn not created at %1. Spawn chance zero or AI count zero.",_placeName];
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
// } forEach A3XAI_locations;
} forEach A3XAI_locations;

if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: %1 has finished generating %2 static spawns in %3 seconds.",__FILE__,(count A3XAI_staticSpawnObjects),(diag_tickTime - _startTime)];};
