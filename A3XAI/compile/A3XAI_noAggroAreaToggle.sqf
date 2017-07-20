#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_object", "_nearNoAggroAreas", "_inNoAggroArea", "_objectPos","_combatMode"];

_unitGroup = _this select 0;
_inNoAggroArea = _this select 1;

_combatMode = (combatMode _unitGroup);

if (_inNoAggroArea) then {
	if !(_unitGroup call A3XAI_getNoAggroStatus) then {
		[_unitGroup,true] call A3XAI_setNoAggroStatus;
		if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 set no-aggro status ON.",_unitGroup];};
	};
	if (_combatMode != "BLUE") then {
		[_unitGroup,"Nonhostile"] call A3XAI_forceBehavior;
		//if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 in no-aggro zone.",_unitGroup];};
	}
} else {
	if (_unitGroup call A3XAI_getNoAggroStatus) then {
		[_unitGroup,false] call A3XAI_setNoAggroStatus;
		if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 set no-aggro status OFF.",_unitGroup];};
	};
	if (_combatMode isEqualTo "BLUE") then {
		[_unitGroup,"Default"] call A3XAI_forceBehavior;
		[_unitGroup,false] call A3XAI_setNoAggroStatus;
		//if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 exited no-aggro zone.",_unitGroup];};
	};
};

true
