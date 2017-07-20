#include "\A3XAI\globaldefines.hpp"

private ["_currentTime", "_staticSpawnTime", "_randomSpawnTime", "_dynamicSpawnTime", "_trigger", "_spawnTriggered", 
"_noGroupsSpawned", "_aiCount", "_minAI", "_maxAI", "_patrolDist", "_unitLevel", "_numGroups", "_result", "_trigger", 
"_nearbyEntities", "_spawnChance"];

//Timers
_currentTime		= diag_tickTime;
_staticSpawnTime 	= _currentTime;
_randomSpawnTime 	= _currentTime;
_dynamicSpawnTime 	= _currentTime;

diag_log "Starting universal spawn manager.";

while {true} do {
	_currentTime = diag_tickTime;
	
	if ((_currentTime - _staticSpawnTime) > STATIC_SPAWN_CHECK_FREQ) then {
		diag_log "Debug: Checking static spawn areas.";
		{
			_scriptHandle = [_x,_forEachIndex] spawn {
				_trigger 		= _this select 0;
				_index 			= _this select 1;
				call {
					if (isNull _trigger) exitWith {
						A3XAI_staticSpawnObjects deleteAt _index;
					};
					
					_spawnTriggered = (({if (isPlayer _x) exitWith {1}} count (_trigger nearEntities [[PLAYER_UNITS,"LandVehicle","Air"],TRIGGER_SIZE_STATIC])) isEqualTo 1);
					_noGroupsSpawned = (_trigger getVariable ["GroupArray",[]] isEqualTo []);
					
					if (_spawnTriggered && {_noGroupsSpawned}) exitWith {
						//If spawn area triggered and no groups spawned yet... spawn a group
						if (A3XAI_currentFPS > A3XAI_minFPS) then {
							diag_log format ["Lockoutvar: %1, Lockoutcalc: %2, Lockouttime: %3",(_trigger getVariable ["LockoutTime",-A3XAI_staticLockoutTime]),(diag_tickTime - (_trigger getVariable ["LockoutTime",-A3XAI_staticLockoutTime])),A3XAI_staticLockoutTime];
							if ((diag_tickTime - (_trigger getVariable ["LockoutTime",-A3XAI_staticLockoutTime])) > A3XAI_staticLockoutTime) then {
								_aiCount = _trigger getVariable ["maxUnits",[1,0]];
								_patrolDist = _trigger getVariable ["patrolDist",125];
								_unitLevel = _trigger getVariable ["unitLevel",1];
								_numGroups = 1;
								_result = [_aiCount select 0,_aiCount select 1,_patrolDist,_trigger,_unitLevel,_numGroups] call A3XAI_spawnUnits_static;
								if (_result) then {
									[_trigger,"A3XAI_staticTriggerArray",true] call A3XAI_updateSpawnCount;
									A3XAI_activePlayerAreas pushBackUnique _trigger;
									if ("LockoutTime" in allVariables _trigger) then {
										_trigger setVariable ["LockoutTime",nil];
									};
									if (A3XAI_enableDebugMarkers) then {
										_nul = [_trigger,str(_trigger)] call A3XAI_addMapMarker;
										_marker = str(_trigger);
										_marker setMarkerColor "ColorRed";
										_marker setMarkerAlpha 0.9;
										// diag_log format ["Debug: Marker String %1",(str _trigger)];
									};
								} else {
									_trigger setVariable ["LockoutTime",diag_tickTime];
									diag_log format ["Lockout timer for static spawn %1 set to %2 seconds.",(_trigger getVariable ["TriggerText","Unknown Spawn"]),A3XAI_staticLockoutTime];
								};
							} else {
								diag_log format ["Static spawn %1 is still under lockdown timer.",_trigger getVariable ["TriggerText","Unknown Spawn"]];
							};
						} else {
							diag_log "Server FPS below required FPS for spawning AI groups.";
						};
					};
					if (!_spawnTriggered && {!_noGroupsSpawned}) exitWith {
						//If spawn area is not triggered and groups exist... despawn spawned groups
						_result = [_trigger] call A3XAI_despawnUniversal;
						if (_result) then {
							[_trigger,"A3XAI_staticTriggerArray",false] call A3XAI_updateSpawnCount;
							A3XAI_activePlayerAreas = A3XAI_activePlayerAreas - [_trigger,objNull];
						};
					};
				};
			};
			waitUntil {uiSleep 0.1; scriptDone _scriptHandle};
			_staticSpawnTime = _currentTime;
		} forEach A3XAI_staticSpawnObjects;
	};
	
	if ((_currentTime - _randomSpawnTime) > RANDOM_SPAWN_CHECK_FREQ) then {
		diag_log "Debug: Checking random spawn areas.";
		{
			_scriptHandle = [_x,_forEachIndex] spawn {
				_trigger 	= _this select 0;
				_index 		= _this select 1;
				call {
					if (isNull _trigger) exitWith {
						A3XAI_randomTriggerArray deleteAt _index;
					};
					
					_nearbyEntities = (_trigger nearEntities [[PLAYER_UNITS,"LandVehicle","Air"],TRIGGER_SIZE_RANDOM]);
					_spawnTriggered = (({if (isPlayer _x) exitWith {1}} count _nearbyEntities) isEqualTo 1);
					_noGroupsSpawned = (_trigger getVariable ["GroupArray",[]] isEqualTo []);

					if (_spawnTriggered && {_noGroupsSpawned}) exitWith {
						//If spawn area triggered and no groups spawned yet... spawn a group
						if ((A3XAI_currentFPS > A3XAI_minFPS) && {!(_trigger getVariable ["LockedOut",false])}) then {
							_aiCount = _trigger getVariable ["maxUnits",[1,0]];
							_patrolDist = _trigger getVariable ["patrolDist",125];
							_unitLevel = _trigger getVariable ["unitLevel",1];
							_numGroups = 1;
							_spawnChance = _trigger getVariable ["SpawnChance",1];
							_result = [_aiCount select 0,_aiCount select 1,_patrolDist,_trigger,_nearbyEntities,_spawnChance,_unitLevel,_numGroups] call A3XAI_spawnUnits_random; //Check if input is correct
							if (_result) then {
								[_trigger,"A3XAI_randomTriggerArray",true] call A3XAI_updateSpawnCount;
								_trigger setVariable ["LockedOut",true];
								if (A3XAI_enableDebugMarkers) then {
									_marker = str(_trigger);
									_marker setMarkerColor "ColorOrange";
									_marker setMarkerAlpha 0.9;
									diag_log format ["Debug:  Marker String %1",(str _trigger)];
								};
							} else {
								A3XAI_randomTriggerArray deleteAt _index;
							};
						} else {
							diag_log "Server FPS below required FPS for spawning AI groups.";
						};
					};
					if (!_spawnTriggered && {!_noGroupsSpawned}) exitWith {
						//If spawn area is not triggered and groups exist... despawn spawned groups
						_result = [_trigger] call A3XAI_despawnUniversal;
						if (_result) then {
							[_trigger,"A3XAI_randomTriggerArray",false] call A3XAI_updateSpawnCount;
						};
					};
				};
			};
			waitUntil {uiSleep 0.1; scriptDone _scriptHandle};
			_randomSpawnTime = _currentTime;
		} forEach A3XAI_randomTriggerArray;
	};
	
	if ((_currentTime - _dynamicSpawnTime) > DYNAMIC_SPAWN_CHECK_FREQ) then {
		diag_log "Debug: Checking dynamic spawn areas.";
		{
			_scriptHandle = [_x,_forEachIndex] spawn {
				_trigger 	= _this select 0;
				_index 		= _this select 1;
				call {
					if (isNull _trigger) exitWith {
						A3XAI_dynamicTriggerArray deleteAt _index;
					};

					_spawnTriggered = (({if (isPlayer _x) exitWith {1}} count (_trigger nearEntities [[PLAYER_UNITS,"LandVehicle","Air"],TRIGGER_SIZE_DYNAMIC])) isEqualTo 1);
					if !(_spawnTriggered) then {
						_result = [_trigger] call A3XAI_despawnUniversal;
						if (_result) then {
							[_trigger,"A3XAI_dynamicTriggerArray",false] call A3XAI_updateSpawnCount;
						};
					};
				};
			};
			waitUntil {uiSleep 0.1; scriptDone _scriptHandle};
			_dynamicSpawnTime = _currentTime;
		} forEach A3XAI_dynamicTriggerArray;
	};
	
	uiSleep 30;
};
