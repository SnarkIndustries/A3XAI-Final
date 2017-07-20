#include "\A3XAI\globaldefines.hpp"

private ["_trigger","_grpArray","_grpCount","_permDelete"];

_trigger = _this select 0;							//Get the trigger object

_grpArray = _trigger getVariable ["GroupArray",[]];	//Find the groups spawned by the trigger.
_grpCount = count _grpArray;

if (A3XAI_debugLevel > 0) then {
	diag_log format["A3XAI Debug: No players remain in trigger area at %1. Deleting %2 AI groups.", (_trigger getVariable ["TriggerText","Unknown Trigger"]),_grpCount]; //replace trigger text with function suitable for non-triggers
	if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Trigger %1 Group Array: %2. In static trigger array: %3",_trigger getVariable ["TriggerText","Unknown Trigger"],_grpArray,(_trigger in A3XAI_staticTriggerArray)];};
};

_permDelete = _trigger getVariable ["permadelete",false];

{
	if (!isNull _x) then {
		_groupSize = (_x getVariable ["GroupSize",0]);
		if ((_groupSize > 0) or {_permDelete}) then { //If trigger is not set to permanently despawn, then ignore empty groups.
			if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Despawning group %1 with %2 active units.",_x,(_x getVariable ["GroupSize",0])];};
			_x setVariable ["GroupSize",-1];
			if (A3XAI_HCIsConnected) then {
				A3XAI_updateGroupSizeManual_PVC = [_x,-1];
				A3XAI_HCObjectOwnerID publicVariableClient "A3XAI_updateGroupSizeManual_PVC";
			};
			_grpArray set [_forEachIndex,grpNull];
		};
	};
} forEach _grpArray;

if !(_permDelete) then {
	//Cleanup variables attached to trigger
	_trigger setVariable ["GroupArray",_grpArray - [grpNull]];
	_trigger setVariable ["isCleaning",false];
	_trigger setVariable ["unitLevelEffective",(_trigger getVariable ["unitLevel",1])];
	if !((_trigger getVariable ["respawnLimitOriginal",-1]) isEqualTo -1) then {_trigger setVariable ["respawnLimit",_trigger getVariable ["respawnLimitOriginal",-1]];};
	if (A3XAI_enableDebugMarkers) then {
		_marker = _trigger getVariable ["MarkerName",""];
		call {
			if (_trigger in A3XAI_staticSpawnObjects) exitWith {
				if (_marker in allMapMarkers) then {
					_marker setMarkerText "STATIC TRIGGER (INACTIVE)";
					_marker setMarkerColor "ColorGreen";
				};
			};
			
			if (_trigger in A3XAI_randomTriggerArray) exitWith {
				deleteMarker _marker;
			};
			
			if (_trigger in A3XAI_dynamicTriggerArray) exitWith {
				deleteMarker _marker;
			};
			
			deleteMarker _marker;
			diag_log format ["Debug: Unhandled case for static spawn %1 in %2.",_trigger getVariable ["TriggerText","Unknown Spawn"],__FILE__];
		};
	};

	if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Despawned AI units at %1. Reset trigger's group array to: %2.",(_trigger getVariable ["TriggerText","Unknown Trigger"]),_trigger getVariable "GroupArray"];};
} else {
	if (A3XAI_enableDebugMarkers) then {
		_marker = str (_trigger);
		if (_marker in allMapMarkers) then {
			deleteMarker _marker;
		};
	};
	
	//Replace trigger-specific functions
	if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Permanently deleting a static spawn at %1.",_trigger getVariable ["TriggerText","Unknown Trigger"]]};
	deleteVehicle _trigger;
};

true
