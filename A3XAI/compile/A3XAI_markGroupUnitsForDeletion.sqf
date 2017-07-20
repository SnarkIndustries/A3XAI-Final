#include "\A3XAI\globaldefines.hpp"
//NOTE: Needs to be made HC-compatible

private ["_unitGroup", "_respawn"];

_unitGroup = _this select 0;
_respawn = _this select 1;

if (isDedicated) then {
	_unitGroup setVariable ["RecycleGroup",_respawn];
	_unitGroup setVariable ["GroupSize",-1];
} else {
	diag_log format ["A3XAI Error: No HC handling implemented for %1",__FILE__];
};

true