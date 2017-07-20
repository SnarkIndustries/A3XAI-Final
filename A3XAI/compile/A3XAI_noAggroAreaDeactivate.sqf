#include "\A3XAI\globaldefines.hpp"

private ["_trigger"];
_trigger = _this select 0;

if (_trigger in A3XAI_activeNoAggroAreas) then {
	A3XAI_activeNoAggroAreas = A3XAI_activeNoAggroAreas - [_trigger];
	_trigger setTriggerArea [NO_AGGRO_AREA_SIZE,NO_AGGRO_AREA_SIZE,0,false]; 
	if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Player exited no-aggro area at %1",(getPosATL _trigger)];};
};

true
