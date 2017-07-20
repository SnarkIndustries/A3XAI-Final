#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle", "_unitsAlive", "_unitLevel", "_trigger", "_rearm" ,"_pos", "_posReflected", "_leader","_airEvacType"];
	
_unitGroup = _this select 0;
_vehicle = _this select 1;
_airEvacType = [_this,2,0] call A3XAI_param;

_leader = leader _unitGroup;
_pos = getPosATL _leader;
_pos set [2,0];
_unitsAlive = {alive _x} count (units _unitGroup);

try {
	if (_unitsAlive isEqualTo 0) then {
		throw format ["A3XAI Debug: %1 cannot create trigger area for empty group %2.",__FILE__,_unitGroup];
	};

	for "_i" from ((count (waypoints _unitGroup)) - 1) to 0 step -1 do {
		deleteWaypoint [_unitGroup,_i];
	};

	if ([_pos,NO_AGGRO_RANGE_LAND] call A3XAI_checkInNoAggroArea) then {
		_pos = [_pos,NO_AGGRO_RANGE_LAND] call A3XAI_getSafePosReflected;
		[_unitGroup,"Nonhostile"] call A3XAI_forceBehavior;
		if !(_pos isEqualTo []) then {
			_tempWP = [_unitGroup,_pos,format ["if !(local this) exitWith {}; [(group this),%1] call A3XAI_moveToPosAndPatrol;",PATROL_DIST_VEHICLEGROUP]] call A3XAI_addTemporaryWaypoint;
		};
	} else {
		_unitGroup setCombatMode "YELLOW";
		_unitGroup setBehaviour "AWARE";
		[_unitGroup,_pos] call A3XAI_setFirstWPPos;
		0 = [_unitGroup,_pos,PATROL_DIST_VEHICLEGROUP] spawn A3XAI_BIN_taskPatrol;
	};

	if (_pos isEqualTo []) then {
		_unitGroup setVariable ["GroupSize",-1];
		if !(local _unitGroup) then {
			A3XAI_updateGroupSizeManual_PVC = [_unitGroup,-1];
			A3XAI_HCObjectOwnerID publicVariableClient "A3XAI_updateGroupSizeManual_PVC";
		};
		
		deleteVehicle _vehicle;

		throw format ["A3XAI Debug: Vehicle group %1 inside no-aggro area at %2. Deleting group.",_unitGroup,_pos];
	};
	
	//new
	_unitLevel = _unitGroup getVariable ["unitLevel",1]; //A3EAI to-do - grab unitLevel value here
	
	if (_airEvacType > 0) then {
		_cargoAvailable = (_vehicle emptyPositions "cargo") min A3XAI_paraDropAmount; //To do: Replace A3XAI_paraDropAmount with Cargo amount
		if (_airEvacType isEqualTo 1) then {
			for "_i" from 1 to _cargoAvailable do {
				_unit = [_unitGroup,_unitLevel,[0,0,0]] call A3XAI_createUnit;
				_unit moveInCargo _vehicle;
				_unit action ["getOut",_vehicle];
				_unit call A3XAI_addTempNVG;
			};
		} else {
			for "_i" from 1 to _cargoAvailable do {
				_unit = [_unitGroup,_unitLevel,[0,0,0]] call A3XAI_createUnit;
				_vehiclePos = (getPosATL _vehicle);
				_parachute = createVehicle [PARACHUTE_OBJECT, [_vehiclePos select 0, _vehiclePos select 1, (_vehiclePos select 2)], [], (-10 + (random 10)), "FLY"];
				_unit moveInDriver _parachute;
				_unit call A3XAI_addTempNVG;

			};
		};
		_unitsAlive = {alive _x} count (units _unitGroup);
		if !(local _unitGroup) then {
			A3XAI_updateGroupSizeAuto_PVC = _unitGroup;
			A3XAI_HCObjectOwnerID publicVariableClient "A3XAI_updateGroupSizeAuto_PVC";
		};
	};
	
	_trigger = [_pos,(format ["AI Vehicle Group %1",mapGridPosition _leader])] call A3XAI_createTriggerArea;
	0 = [4,_trigger,[_unitGroup],PATROL_DIST_VEHICLEGROUP,_unitLevel,[_unitsAlive,0]] call A3XAI_initializeTrigger;

	_unitGroup setVariable ["GroupSize",_unitsAlive];
	_unitGroup setVariable ["trigger",_trigger];

	[_unitGroup,"vehiclecrew"] call A3XAI_setUnitType;
	[_trigger,"A3XAI_staticTriggerArray",true] call A3XAI_updateSpawnCount;
	A3XAI_staticSpawnObjects pushBackUnique _trigger;

	{
		if (alive _x) then {
			if ((_x getHit "legs") > 0) then {_x setHit ["legs",0]};
			unassignVehicle _x;
		};
	} count (units _unitGroup);
	
	if !(local _unitGroup) then {
		A3XAI_sendGroupTriggerVars_PVC = [_unitGroup,[_unitGroup],PATROL_DIST_VEHICLEGROUP,1,1,[_unitsAlive,0],0,"vehiclecrew",false,true];
		A3XAI_HCObjectOwnerID publicVariableClient "A3XAI_sendGroupTriggerVars_PVC";
	};
} catch {
	if (A3XAI_debugLevel > 0) then {
		diag_log _exception;
	};
};

true
