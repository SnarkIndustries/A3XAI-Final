#include "\A3XAI\globaldefines.hpp"

private ["_action", "_unitGroup", "_result"];

_action = _this select 1;
_unitGroup = _this select 0;

_result = call {
	if (_action isEqualTo "Nonhostile") exitWith {
		_unitGroup setBehaviour "CARELESS";
		_unitGroup setCombatMode "BLUE";
		{_x doWatch objNull} forEach (units _unitGroup);
		
		true
	};

	if (_action isEqualTo "Default") exitWith {
		_unitGroup setBehaviour "AWARE";
		_unitGroup setCombatMode "YELLOW";

		false
	};

	if (_action isEqualTo "DefendOnly") exitWith {
		_unitGroup setBehaviour "AWARE";
		_unitGroup setCombatMode "GREEN";
		{_x doWatch objNull} forEach (units _unitGroup);

		false
	};

	false
};

_unitGroup setVariable ["EnemiesIgnored",_result];

if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Setting group %1 behavior mode to %2 (result: %3).",_unitGroup,_action,_result];};

_result
