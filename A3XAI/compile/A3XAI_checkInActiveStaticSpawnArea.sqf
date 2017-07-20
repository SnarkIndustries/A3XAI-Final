#include "\A3XAI\globaldefines.hpp"

private ["_inArea", "_object", "_distance"];

_object = _this select 0;
_distance = [_this,1,750] call A3XAI_param;

if (((typeName _object) isEqualTo "OBJECT") &&  {_object isEqualTo objNull}) exitWith {false};
// if ((typeName _object) isEqualTo "OBJECT") then {_object = getPosATL _object};

_inArea = false;
{
	if ((_x distance2D _object) < _distance) exitWith {
		_inArea = true;
	};
} count A3XAI_activePlayerAreas;

_inArea
