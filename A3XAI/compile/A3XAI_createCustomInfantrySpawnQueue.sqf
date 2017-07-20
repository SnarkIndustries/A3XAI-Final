#include "\A3XAI\globaldefines.hpp"

if !((typeName _this) isEqualTo "ARRAY") exitWith {diag_log format ["Error: Wrong arguments sent to %1.",__FILE__]};
private ["_trigger", "_grpArray", "_infantryQueue","_triggerStatements"];

_trigger = _this select 3;
_grpArray = _trigger getVariable ["GroupArray",[]];	

if (_grpArray isEqualTo []) then {
	if (A3XAI_customInfantrySpawnQueue isEqualTo []) then {
		A3XAI_customInfantrySpawnQueue pushBack _this;
		_infantryQueue = [] spawn {
			//uiSleep 0.5;
			while {!(A3XAI_customInfantrySpawnQueue isEqualTo [])} do {
				if (A3XAI_currentFPS < A3XAI_minFPS) then {
					if (A3XAI_debugLevel > 0) then {
						diag_log format ["A3XAI Debug: Custom Infantry AI spawning paused. Waiting for server FPS to be above minimum set value (Current: %1. Minimum: %2)",A3XAI_currentFPS,A3XAI_minFPS];
					};
					waitUntil {uiSleep 15; A3XAI_currentFPS > A3XAI_minFPS};
				};
				private ["_args","_trigger"];
				_args = (A3XAI_customInfantrySpawnQueue select 0);
				_trigger = _args select 3;
				if (triggerActivated _trigger) then {
					_trigger setVariable ["isCleaning",false];
					_triggerStatements = (triggerStatements _trigger);
					_triggerStatements set [1,""];
					_trigger setTriggerStatements _triggerStatements;
					[_trigger,"A3XAI_staticTriggerArray",true] call A3XAI_updateSpawnCount;
					0 = _args call A3XAI_spawnInfantryCustom;
					if (A3XAI_enableDebugMarkers) then {
						_nul = [_trigger,str(_trigger)] call A3XAI_addMapMarker;
					};
				};
				A3XAI_customInfantrySpawnQueue deleteAt 0;
				uiSleep 1;
			};
		};
	} else {
		if !(_this in A3XAI_customInfantrySpawnQueue) then {
			A3XAI_customInfantrySpawnQueue pushBack _this;
		};
	};
} else {
	private ["_triggerStatements"];
	_triggerStatements = (triggerStatements _trigger);
	_triggerStatements set [1,""];
	_trigger setTriggerStatements _triggerStatements;
	_trigger setTriggerArea [TRIGGER_SIZE_EXPANDED,TRIGGER_SIZE_EXPANDED,0,false];
	[_trigger,"A3XAI_staticTriggerArray",true] call A3XAI_updateSpawnCount;
	if (A3XAI_enableDebugMarkers) then {
		_nul = [_trigger,str(_trigger)] call A3XAI_addMapMarker;
	};
	if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Maximum number of groups already spawned at custom %1. Exiting spawn script.",(_trigger getVariable ["TriggerText","Unknown Trigger"])];};
};

true