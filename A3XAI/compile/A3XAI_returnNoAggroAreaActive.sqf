#include "\A3XAI\globaldefines.hpp"

private ["_noAggroArea", "_objectPos"];

_objectPos = _this select 0;
_noAggroRange = [_this,1,900] call A3XAI_param;

_noAggroArea = objNull;
if ((typeName _this) isEqualTo "OBJECT") then {_objectPos = getPosATL _this};

{
	if (((position _x) distance2D _objectPos) < _noAggroRange) exitWith {
		_noAggroArea = _x;
	};
} forEach A3XAI_activeNoAggroAreas;

_noAggroArea
