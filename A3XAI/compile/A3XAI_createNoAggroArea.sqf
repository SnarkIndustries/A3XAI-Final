#include "\A3XAI\globaldefines.hpp"

private ["_size", "_trigger"];

_areaPos = _this select 0;
_size = _this select 1;

_trigger = createTrigger [SENSOR_OBJECT,_areaPos,false];
_trigger setTriggerArea [_size,_size,0,false];
_trigger setTriggerActivation ["ANY", "PRESENT", true];
_trigger setTriggerTimeout [TRIGGER_TIMEOUT_NOAGGROAREA,true];
_trigger setTriggerStatements ["{if (isPlayer _x) exitWith {1}} count thisList > 0;", "0 = [thisTrigger] call A3XAI_noAggroAreaActivate;", "0 = [thisTrigger] call A3XAI_noAggroAreaDeactivate;"];

_trigger setVariable ["TriggerText",format ["No-Aggro Area %1",_areaPos]];

A3XAI_noAggroAreas pushBack _trigger;

/*
diag_log format ["Debug: Trigger object %1",_trigger];
diag_log format ["Debug: Trigger area %1",triggerArea _trigger];
diag_log format ["Debug: Trigger activation %1",triggerActivation _trigger];
diag_log format ["Debug: Trigger timeout %1",triggerTimeout _trigger];
diag_log format ["Debug: Trigger text %1",_trigger getVariable ["TriggerText","Unknown Trigger"]];
diag_log format ["Debug: Trigger statements %1",triggerStatements _trigger];
diag_log format ["Debug: A3XAI_noAggroAreas: %1",A3XAI_noAggroAreas];
*/

_trigger
