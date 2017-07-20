#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle", "_inArea", "_result", "_trigger", "_maxDistance","_leader", "_assignedTarget"];

_unitGroup = _this select 0;
//_vehicle = _this select 1;

_leader = (leader _unitGroup);
_inArea = [_leader,NO_AGGRO_RANGE_MAN] call A3XAI_checkInActiveNoAggroArea;

if !(_inArea) then {
	_assignedTarget = (assignedTarget (vehicle _leader));
	if ((_assignedTarget distance _leader) < NO_AGGRO_RANGE_MAN) then {
		_inArea = [_assignedTarget,300] call A3XAI_checkInActiveNoAggroArea;
	};
};

if (_inArea) exitWith {
	[_unitGroup,objNull,""] call A3XAI_recycleGroup;
};

true
