#include "\A3XAI\globaldefines.hpp"

private ["_trigger","_triggerType"];

_trigger = call {
	_triggerType = (typeName _this);
	if (_triggerType isEqualTo "OBJECT") exitWith {
		_this
	};
	if (_triggerType isEqualTo "GROUP") exitWith {
		_this getVariable ["trigger",objNull]
	};
	_this
};

if (A3XAI_enableDebugMarkers) then {
	deleteMarker (_trigger getVariable ["MarkerName",""]);
};
_trigger setTriggerStatements ["this","true","false"]; //Disable trigger from activating or deactivating while cleanup is performed
if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Deleting custom-defined AI spawn %1 at %2 in 30 seconds.",_trigger getVariable ["TriggerText","Unknown Trigger"], mapGridPosition _trigger];};

uiSleep 30;

{
	_x setVariable ["GroupSize",-1];
	if (A3XAI_HCIsConnected) then {
		A3XAI_updateGroupSizeManual_PVC = [_x,-1];
		A3XAI_HCObjectOwnerID publicVariableClient "A3XAI_updateGroupSizeManual_PVC";
	};
} forEach (_trigger getVariable ["GroupArray",[]]);

[_trigger,"A3XAI_staticTriggerArray",false] call A3XAI_updateSpawnCount;

if (_trigger in A3XAI_staticSpawnObjects) then {
	A3XAI_staticSpawnObjects = A3XAI_staticSpawnObjects - [_trigger,objNull];
};

if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Deleting custom-defined AI spawn %1 at %2.",_trigger getVariable ["TriggerText","Unknown Trigger"], mapGridPosition _trigger];};

deleteVehicle _trigger;

true