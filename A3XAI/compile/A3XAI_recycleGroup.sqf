#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle", "_unitType", "_trigger", "_respawn", "_vehicleType"];

_unitGroup = _this select 0;
_vehicle = _this select 1;
_vehicleType = _this select 2;

if (_unitGroup getVariable ["isRecycling",false]) exitWith {};
_unitGroup setVariable ["isRecycling",true];

_unitGroup setCombatMode "BLUE";
[_unitGroup,true] call A3XAI_setNoAggroStatus;

_unitType = _unitGroup getVariable ["unitType",""];
_respawn = true;

// diag_log format ["%1: %2",__FILE__,_this];

if (isDedicated) then {
	if !(isNull _vehicle) then {
		_vehicle setVariable ["DeleteVehicle",true];
		_vehicle setVariable ["VehicleDisabled",true];
	};
	
	call {
		if (_unitType isEqualTo "static") exitWith {
			_trigger = _unitGroup getVariable ["trigger",A3XAI_defaultTrigger]; //This block is non-HC compatible.
			[0,_trigger,_unitGroup,true] call A3XAI_addRespawnQueue; 
		};
		if (_unitType isEqualTo "random") exitWith {
			_trigger = _unitGroup getVariable ["trigger",A3XAI_defaultTrigger];
			[0,_trigger,_unitGroup,true] call A3XAI_addRespawnQueue; 
		};
		if (_unitType isEqualTo "dynamic") exitWith {
			_trigger = _unitGroup getVariable ["trigger",A3XAI_defaultTrigger];
			[0,_trigger,_unitGroup,true] call A3XAI_addRespawnQueue; 
		};
		if (_unitType isEqualTo "air") exitWith {
			[2,_vehicleType,true] call A3XAI_addRespawnQueue;
			A3XAI_curHeliPatrols = A3XAI_curHeliPatrols - 1;
		};
		if (_unitType isEqualTo "land") exitWith {
			[2,_vehicleType,true] call A3XAI_addRespawnQueue;
			A3XAI_curLandPatrols = A3XAI_curLandPatrols - 1;
		};
		if (_unitType isEqualTo "uav") exitWith {
			[3,_vehicleType,true] call A3XAI_addRespawnQueue;
			A3XAI_curUAVPatrols = A3XAI_curUAVPatrols - 1;
		};
		if (_unitType isEqualTo "ugv") exitWith {
			[3,_vehicleType,true] call A3XAI_addRespawnQueue;
			A3XAI_curUGVPatrols = A3XAI_curUGVPatrols - 1;
		};
		if (_unitType isEqualTo "air_reinforce") exitWith {
			_respawn = false;
		};
		if (_unitType isEqualTo "infantry_reinforce") exitWith {
			_trigger = _unitGroup getVariable ["trigger",A3XAI_defaultTrigger]; //This block is non-HC compatible.
			0 = [_trigger] spawn A3XAI_despawn_static;
			_respawn = false;
		};
		if (_unitType isEqualTo "vehiclecrew") exitWith {
			_trigger = _unitGroup getVariable ["trigger",A3XAI_defaultTrigger]; //This block is non-HC compatible.
			0 = [_trigger] spawn A3XAI_despawn_static;
			_respawn = false;
		};
		if (_unitType isEqualTo "staticcustom") exitWith {
			_trigger = _unitGroup getVariable ["trigger",A3XAI_defaultTrigger]; //This block is non-HC compatible.
			[0,_trigger,_unitGroup,true] call A3XAI_addRespawnQueue; 
		};
		if (_unitType isEqualTo "aircustom") exitWith {
			[1,_vehicleType,true] call A3XAI_addRespawnQueue;
			A3XAI_curHeliPatrols = A3XAI_curHeliPatrols - 1;
		};
		if (_unitType isEqualTo "landcustom") exitWith {
			[1,_vehicleType,true] call A3XAI_addRespawnQueue;
			A3XAI_curLandPatrols = A3XAI_curLandPatrols - 1;
		};
	};
} else {
	diag_log format ["A3XAI Error: No HC handling implemented for %1",__FILE__];
};

[_unitGroup,_respawn] call A3XAI_markGroupUnitsForDeletion;

true
