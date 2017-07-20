#include "\A3XAI\globaldefines.hpp"

private ["_trigger","_spawnParams","_result"];

_trigger = _this select 0;
_spawnParams = _this select 1;

_result = true;
if ((count _spawnParams) isEqualTo 4) then {
	_trigger setVariable ["minAI",_spawnParams select 0];
	_trigger setVariable ["addAI",_spawnParams select 1];
	_trigger setVariable ["unitLevel",_spawnParams select 2];
	_trigger setVariable ["spawnChance",_spawnParams select 3];
} else {
	_trigger setVariable ["minAI",1];
	_trigger setVariable ["addAI",1];
	_trigger setVariable ["unitLevel",1];
	_trigger setVariable ["spawnChance",1];
	_result = false;
};

_result
