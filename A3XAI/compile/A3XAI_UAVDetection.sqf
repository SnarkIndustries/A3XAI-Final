#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup","_canCall","_vehicle","_detectStartPos"];
_unitGroup = _this select 0;

if (_unitGroup getVariable ["IsDetecting",false]) exitWith {};
if (_unitGroup getVariable ["EnemiesIgnored",false]) then {[_unitGroup,"Default"] call A3XAI_forceBehavior};

_vehicle = _unitGroup getVariable ["assignedVehicle",objNull];
_canCall = true;

if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 %2 detection started.",_unitGroup,(typeOf (_vehicle))];};

if ((diag_tickTime - (_unitGroup getVariable ["UVLastCall",-A3XAI_UAVCallReinforceCooldown])) > A3XAI_UAVCallReinforceCooldown) then {
	_detectStartPos = getPosATL _vehicle;
	_vehicle flyInHeight (FLYINHEIGHT_UAV_SEARCHING_BASE + (random FLYINHEIGHT_UAV_SEARCHING_VARIANCE));
	_unitGroup setVariable ["IsDetecting",true];
	
	while {!(_vehicle getVariable ["VehicleDisabled",false]) && {(_unitGroup getVariable ["GroupSize",-1]) > 0} && {local _unitGroup}} do {
		private ["_detected","_vehPos","_nearBlacklistAreas","_playerPos","_canReveal"];
		_vehPos = getPosATL _vehicle;
		_canReveal = ((combatMode _unitGroup) in ["YELLOW","RED"]);
		_detected = (getPosATL _vehicle) nearEntities [[PLAYER_UNITS,"LandVehicle"],DETECT_RANGE_UAV];
		
		{
			if !(isPlayer _x) then {
				_detected deleteAt _forEachIndex;
			};
			if (_forEachIndex > 4) exitWith {};
		} forEach _detected;
		
		_nearBlacklistAreas = if (_detected isEqualTo []) then {[]} else {nearestLocations [_vehPos,[BLACKLIST_OBJECT_GENERAL],1500]};
		{
			_playerPos = getPosATL _x;
			if ((isPlayer _x) && {({if (_playerPos in _x) exitWith {1}} count _nearBlacklistAreas) isEqualTo 0}) then {
				if (((lineIntersectsSurfaces [(aimPos _vehicle),(eyePos _x),_vehicle,_x,true,1]) isEqualTo []) && {A3XAI_UAVDetectChance call A3XAI_chance}) then {
					if (_canCall) then {
						if (isDedicated) then {
							_nul = [_playerPos,_x,_unitGroup getVariable ["unitLevel",0]] spawn A3XAI_spawn_reinforcement;
						} else {
							A3XAI_spawnReinforcements_PVS = [_playerPos,_x,_unitGroup getVariable ["unitLevel",0]];
							publicVariableServer "A3XAI_spawnReinforcements_PVS";
						};
						_unitGroup setVariable ["UVLastCall",diag_tickTime];
						_canCall = false;
					};
					if !(isNull (objectParent _x)) then { //Reveal vehicles
						_unitGroup reveal [_x,2.5]; 
						if (({if (RADIO_ITEM in (assignedItems _x)) exitWith {1}} count (units (group _x))) > 0) then {
							[_x,[41+(floor (random 5)),[_unitGroup,[configFile >> "CfgVehicles" >> (typeOf _vehicle),"displayName",""] call BIS_fnc_returnConfigEntry]]] call A3XAI_radioSend;
						};
					};
				};
			};
			uiSleep 0.1;
		} forEach _detected;
		if (((_vehicle distance2D _detectStartPos) > DETECT_LENGTH_UAV_2D) or {_vehicle getVariable ["VehicleDisabled",false]}) exitWith {};
		uiSleep 15;
	};
	
	_vehicle flyInHeight (FLYINHEIGHT_UAV_PATROLLING_BASE + (random FLYINHEIGHT_UAV_PATROLLING_VARIANCE));
};

_unitGroup setVariable ["IsDetecting",false];
[_unitGroup,"Nonhostile"] call A3XAI_forceBehavior;

if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 %2 detection end.",_unitGroup,(typeOf (_vehicle))];};
