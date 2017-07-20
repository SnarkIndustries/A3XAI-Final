#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle"];

_unitGroup = _this;

{
	if (alive _x) then {
		deleteVehicle _x;
	} else {
		[_x] joinSilent grpNull;
	};
} count (units _unitGroup);

if (_unitGroup getVariable ["RecycleGroup",false]) then {
	_vehicle = _unitGroup getVariable ["assignedVehicle",objNull]; //If infantry AI have vehicle assigned, will need to change this line
	if (isNull _vehicle) then { //Groups with assigned vehicles do not need to be preserved
		_unitGroup call A3XAI_protectGroup;
	} else {
		deleteGroup _unitGroup;
		A3XAI_activeGroups = A3XAI_activeGroups - [_unitGroup,grpNull];
	};
} else {
	A3XAI_activeGroups = A3XAI_activeGroups - [_unitGroup,grpNull];
	deleteGroup _unitGroup;
};

true