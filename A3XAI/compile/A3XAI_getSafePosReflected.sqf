#include "\A3XAI\globaldefines.hpp"

private ["_originPos", "_noAggroArea", "_posReflected", "_locationPos", "_locationSize", "_direction","_noAggroRange"];

_originPos = _this select 0; //origin
_noAggroRange = _this select 1;

if ((typeName _originPos) isEqualTo "OBJECT") then {_originPos = getPosATL _originPos};

_posReflected = [];
_noAggroArea = [_originPos,_noAggroRange] call A3XAI_returnNoAggroAreaAll;

if !(isNull _noAggroArea) then {
	// _locationPos = locationPosition _noAggroArea;
	_locationPos = getPosATL _noAggroArea;
	_locationSize = ((size _noAggroArea) select 0) + 300;
	_direction = [_locationPos,_originPos] call BIS_fnc_dirTo;
	_posReflected = [_locationPos, _locationSize,_direction] call BIS_fnc_relPos;
	if ((surfaceIsWater _posReflected) or {[_posReflected,_noAggroRange] call A3XAI_checkInNoAggroArea}) then {_posReflected = []};
};

_posReflected
