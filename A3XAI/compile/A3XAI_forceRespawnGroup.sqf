#include "\A3XAI\globaldefines.hpp"

private [];

_unitGroup = _this select 0;
_unitType = _this select 1;
_retryOnFail = _this select 2;

_fnc_respawnGroup = missionNamespace getVariable [format ["A3XAI_respawn_%1",_unitType],{}];
_vehicle = _unitGroup getVariable ["assignedVehicle",objNull];

if !(isNull _vehicle) then {
	_vehicle setVariable ["DeleteVehicle",true];
};

_result = [_unitType] call _fnc_respawnGroup;

_unitGroup setVariable ["GroupSize",-1];

true