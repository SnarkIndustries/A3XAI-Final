#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle", "_leader", "_inArea", "_assignedTarget"];

_unitGroup = _this select 0;
_vehicle = _this select 1;

_leader = (leader _unitGroup);
_inArea = [_vehicle,NO_AGGRO_RANGE_AIR] call A3XAI_checkInActiveNoAggroArea;

if !(_inArea) then {
	_assignedTarget = (assignedTarget (vehicle _leader));
	if ((_assignedTarget distance _leader) < NO_AGGRO_RANGE_AIR) then {
		_inArea = [_assignedTarget,300] call A3XAI_checkInActiveNoAggroArea;
	};
};

if (_inArea) exitWith {
	[_unitGroup,_vehicle,(typeOf _vehicle)] call A3XAI_recycleGroup;
};

if (((_unitGroup getVariable ["unitType",""]) == "air") && {!(_unitGroup getVariable ["IsDetecting",false])} && {[_vehicle,BEGIN_DETECT_DIST_AIR] call A3XAI_checkInActiveStaticSpawnArea}) then {
	[_unitGroup] spawn A3XAI_heliDetection;
	
	if (A3XAI_debugLevel > 1) then {
		diag_log format ["A3XAI Debug: %1 %2 is scanning for players in active trigger area at %3.",_unitGroup,(typeOf _vehicle),(getPosATL _vehicle)];
	};
};
	
true
