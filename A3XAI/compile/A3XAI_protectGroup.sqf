#include "\A3XAI\globaldefines.hpp"

private ["_dummy"]; //_this = group

_dummy = _this getVariable ["dummyUnit",objNull];

if (isNull _dummy) then {
	_dummy = _this createUnit ["Logic",[0,0,0],[],0,"FORM"];
	[_dummy] joinSilent _this;
	_this setVariable ["dummyUnit",_dummy];
	if !(isDedicated) then {
		A3XAI_protectGroup_PVS = [_unitGroup,_dummy];
		publicVariableServer "A3XAI_protectGroup_PVS";
	};

	if (A3XAI_debugLevel > 1) then {diag_log format["A3XAI Debug: Spawned 1 dummy AI unit to preserve group %1.",_this];};
} else {
	if (A3XAI_debugLevel > 1) then {diag_log format["A3XAI Debug: Group %1 already has a dummy unit assigned.",_this];};
};

_dummy