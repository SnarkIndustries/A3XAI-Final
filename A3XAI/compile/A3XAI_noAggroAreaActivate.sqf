#include "\A3XAI\globaldefines.hpp"

private ["_trigger"];
_trigger = _this select 0;

// if ((A3XAI_activeNoAggroAreas find _trigger) isEqualTo -1) then {
if !(_trigger in A3XAI_activeNoAggroAreas) then {
	A3XAI_activeNoAggroAreas pushBack _trigger;
	_trigger setTriggerArea [NO_AGGRO_AREA_EXPANDED_SIZE,NO_AGGRO_AREA_EXPANDED_SIZE,0,false]; 
	if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Player entered no-aggro area at %1",(getPosATL _trigger)];};
};

true
