#include "\A3XAI\globaldefines.hpp"

private ["_size", "_trigger", "_areaName"];

_areaPos = _this select 0;
_areaName = _this select 1;

if (_areaPos isEqualTo [0,0,0]) exitWith {
	diag_log format ["A3XAI Error: Invalid parameters sent to %1: %2",__FILE__,_this];
	objNull
};

// _trigger = TRIGGER_OBJECT createVehicleLocal _areaPos;			//triggerless version
_trigger = createTrigger [TRIGGER_OBJECT,_areaPos,false];			//triggerless version
_trigger enableSimulation false;									//Disable to reduce performance impact
_trigger setVariable ["TriggerText",_areaName];
diag_log format ["Debug: Created trigger object %1 at %2",_trigger,_areaName];

_trigger
