#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle", "_leader", "_inArea", "_assignedTarget", "_lastAggro"];

_unitGroup = _this select 0;
_vehicle = _this select 1;

_inArea = false;

if ((combatMode _unitGroup) == "YELLOW") then {
	_leader = (leader _unitGroup);
	_inArea = [_leader,NO_AGGRO_RANGE_UGV] call A3XAI_checkInActiveNoAggroArea;
	
	if !(_inArea) then {
		_assignedTarget = (assignedTarget (vehicle _leader));
		if ((_assignedTarget distance _leader) < NO_AGGRO_RANGE_UGV) then {
			_inArea = [_assignedTarget,300] call A3XAI_checkInActiveNoAggroArea;
		};	
	};
	
	if (_inArea) exitWith {
		[_unitGroup,_vehicle,(typeOf _vehicle)] call A3XAI_recycleGroup;
	};
	
	_lastAggro = _vehicle getVariable "AggroTime";
	if (!(isNil "_lastAggro") && {diag_tickTime > _lastAggro}) then {
		_vehicle setVariable ["AggroTime",nil];
		[_unitGroup,"Nonhostile"] call A3XAI_forceBehavior;
		if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Reset Group %1 %2 UGV to non-hostile mode.",_unitGroup,(typeOf _vehicle)]};
	};
};

if (_inArea) exitWith {};

if (((_unitGroup getVariable ["unitType",""]) == "ugv") && {!(_unitGroup getVariable ["IsDetecting",false])} && {[_vehicle,BEGIN_DETECT_DIST_UGV] call A3XAI_checkInActiveStaticSpawnArea}) then {
	[_unitGroup] spawn A3XAI_UGVDetection;
	
	if (A3XAI_debugLevel > 1) then {
		diag_log format ["A3XAI Debug: %1 %2 is scanning for players in active trigger area at %3.",_unitGroup,(typeOf _vehicle),(getPosATL _vehicle)];
	};
};

true
