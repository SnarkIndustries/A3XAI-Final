#include "\A3XAI\globaldefines.hpp"

private["_trigger"];
_trigger = _this;

A3XAI_dynamicTriggerArray = A3XAI_dynamicTriggerArray - [_trigger];
_playerUID = _trigger getVariable "targetplayerUID";
if (!isNil "_playerUID") then {A3XAI_failedDynamicSpawns pushBack _playerUID};
if (A3XAI_enableDebugMarkers) then {
	deleteMarker (_trigger getVariable ["MarkerName",""]);
};

deleteVehicle _trigger;

false
