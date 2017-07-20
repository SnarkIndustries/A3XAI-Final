#include "\A3XAI\globaldefines.hpp"

/*
	_fnc_execEveryLoop = _dataArray select 0;
	_fnc_checkUnits = _dataArray select 1;
	_fnc_generateLoot = _dataArray select 2;
	_fnc_vehicleAmmoFuelCheck = _dataArray select 3;
	_fnc_antistuck = _dataArray select 4;
*/
	
private ["_unitGroup", "_unitType", "_groupVariables", "_dataArray", "_stuckCheckTime"];

_unitGroup = _this select 0;
_unitType =_this select 1;

_unitGroup setVariable ["unitType",_unitType];
_groupVariables = _unitGroup getVariable "GroupVariables";

_dataArray = [_unitGroup,_unitType] call A3XAI_getLocalFunctions;
_stuckCheckTime = _unitType call A3XAI_getAntistuckTime;
_dataArray pushBack _stuckCheckTime;

if (isNil "_groupVariables") then {
	_unitGroup setVariable ["GroupVariables",[]];
	_groupVariables = _unitGroup getVariable "GroupVariables";
	_groupVariables append _dataArray;
} else {
	_groupVariables deleteRange [0,(count _groupVariables)];
	_groupVariables append _dataArray;
};

_groupVariables
