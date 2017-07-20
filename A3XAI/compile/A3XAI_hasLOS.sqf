#include "\A3XAI\globaldefines.hpp"

private ["_begin", "_end", "_ignore1", "_ignore2"];

_begin = _this select 0;
_end = _this select 1;
_ignore1 = [_this,2,objNull] call A3XAI_param;
_ignore2 = [_this,3,objNull] call A3XAI_param;

if ((typeName _begin) == "OBJECT") then {
	_begin = getPosASL _begin;
	_begin set [2,(_begin select 2) + 1.7];
};

if ((typeName _end) == "OBJECT") then {
	_end = getPosASL _end;
	_end set [2,(_end select 2) + 1.7];
};

!(lineIntersects [_begin,_end,_ignore1,_ignore2])