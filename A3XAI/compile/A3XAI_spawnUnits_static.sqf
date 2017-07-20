#include "\A3XAI\globaldefines.hpp"

private ["_minAI","_addAI","_patrolDist","_trigger","_unitLevel","_numGroups","_grpArray","_triggerPos","_startTime","_totalSpawned","_groupsActive","_spawnChance","_result"];

_minAI = _this select 0;									//Mandatory minimum number of AI units to spawn
_addAI = _this select 1;									//Maximum number of additional AI units to spawn
_patrolDist = _this select 2;								//Patrol radius from trigger center.
_trigger = _this select 3;									//The trigger calling this script.
_unitLevel = if ((count _this) > 4) then {_this select 4} else {1};		//(Optional) Select the item probability table to use
_numGroups = if ((count _this) > 5) then {_this select 5} else {1};		//(Optional) Number of groups of x number of units each to spawn

_startTime = diag_tickTime;

_grpArray = _trigger getVariable ["GroupArray",[]];	
_groupsActive = count _grpArray;
_triggerPos = getPosATL _trigger;
_result = true;

//If trigger already has defined spawn points, then reuse them instead of recalculating new ones.
_locationArray = _trigger getVariable ["locationArray",[]];	
_totalSpawned = 0;

//Spawn groups
if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Trigger %1 is spawning units...",_trigger getVariable ["TriggerText","Unknown Spawn"]]};
for "_j" from 1 to (_numGroups - _groupsActive) do {
	private ["_unitGroup","_spawnPos","_totalAI"];
	_totalAI = 0;
	_spawnPos = [];
	_spawnChance = ((_trigger getVariable ["spawnChance",1]) * A3XAI_spawnChanceMultiplier);
	if ((_trigger getVariable ["spawnChance",1]) call A3XAI_chance) then {
		_totalAI = ((_minAI + round(random _addAI)) min MAX_UNITS_PER_STATIC_SPAWN);
		_spawnPos = if !(_locationArray isEqualTo []) then {_locationArray call A3XAI_findSpawnPos} else {[(getPosATL _trigger),random (_patrolDist),random(360),0] call A3XAI_SHK_pos};
	};

	//If non-zero unit amount and valid spawn position, spawn group, otherwise add it to respawn queue.
	_unitGroup = grpNull;
	try {
		if ((count _spawnPos) > 1) then {
			if (_totalAI > 0) then {
				_unitGroup = [_totalAI,_unitGroup,"static",_spawnPos,_trigger,_unitLevel] call A3XAI_spawnGroup;
				if (isNull _unitGroup) then {
					throw [true, format ["A3XAI Debug: No units spawned for static spawn at %1. Added group to respawn queue with fast mode.",(_trigger getVariable ["TriggerText","Unknown Spawn"])]];
				};
				_totalSpawned = _totalSpawned + _totalAI;
				if (_patrolDist > 1) then {
					0 = [_unitGroup,_triggerPos,_patrolDist] spawn A3XAI_BIN_taskPatrol;
				} else {
					[_unitGroup, 0] setWaypointType "GUARD";
				};
				if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Spawned group %1 (unitLevel: %2) with %3 units.",_unitGroup,_unitLevel,_totalAI];};
			} else {
				throw [false, format ["A3XAI Debug: No units spawned for static spawn at %1.",(_trigger getVariable ["TriggerText","Unknown Spawn"])]];
			};
		} else {
			throw [true, format ["A3XAI Debug: Unable to find spawn position for static spawn at %1. Added group to respawn queue with fast mode.",(_trigger getVariable ["TriggerText","Unknown Spawn"])]];
		};
	} catch {
		private ["_result","_logText"];
		
		_result 	= _exception select 0; //true: no lockout (position-based failure), false: lockout (probability-based failure)
		_logText 	= _exception select 1;
		
		if (_result) then{
			_unitGroup = ["static",true] call A3XAI_createGroup;
			_unitGroup setVariable ["GroupSize",0];
			_unitGroup setVariable ["trigger",_trigger];
			0 = [0,_trigger,_unitGroup,true] call A3XAI_addRespawnQueue;
		};
		if (A3XAI_debugLevel > 1) then {diag_log _logText;};
	};
	
	if !(isNull _unitGroup) then {
		_grpArray pushBack _unitGroup;
	};
};

if (A3XAI_debugLevel > 0) then {
	diag_log format["A3XAI Debug: Spawned %1 new AI groups (%2 units total) in %3 seconds at %4.",_numGroups,_totalSpawned,(diag_tickTime - _startTime),(_trigger getVariable ["TriggerText","Unknown Spawn"])];
	if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Trigger %1 group array updated to: %2.",_trigger getVariable ["TriggerText","Unknown Spawn"],_trigger getVariable "GroupArray"]};
};

_result
