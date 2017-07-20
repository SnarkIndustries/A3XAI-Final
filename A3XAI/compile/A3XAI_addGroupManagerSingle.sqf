#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_unitLevel", "_unitType", "_vehicle", "_stuckCheckTime", "_groupLeadMarker", "_groupWPMarker", "_currentTime", "_managerStartTime", "_updateServerLoot", 
"_pullRate", "_unitPos", "_unitMarker", "_result", "_groupVariables", "_assignedVehicle"];

_unitGroup = _this select 0;
_unitLevel = _this select 1;

scopeName "GroupManagerScope";

if (_unitGroup getVariable ["isManaged",false]) exitWith {};
_unitGroup setVariable ["isManaged",true];

_unitType = (_unitGroup getVariable ["unitType",""]);
_vehicle = objNull;

if (_unitType in ["air","land","aircustom","landcustom","air_reinforce","uav","ugv"]) then {
	_vehicle = _unitGroup getVariable ["assignedVehicle",objNull];
} else {
	call {
		_assignedVehicle = (assignedVehicle (leader _unitGroup));
		if (isNull _vehicle) exitWith {};
		if (_vehicle isKindOf "ParachuteBase") exitWith {};
		if (_vehicle isKindOf "StaticWeapon") exitWith {};
		_unitGroup setVariable ["assignedVehicle",_assignedVehicle];
		_vehicle = _assignedVehicle;
	};
};


if (isNil {_unitGroup getVariable "antistuckPos"}) then {_unitGroup setVariable ["antistuckPos",(getWPPos [_unitGroup,(currentWaypoint _unitGroup)])];};
if (isNil {_unitGroup getVariable "GroupSize"}) then {_unitGroup setVariable ["GroupSize",(count (units _unitGroup))]};
_stuckCheckTime = _unitType call A3XAI_getAntistuckTime;

//set up debug variables
_groupLeadMarker = format ["%1_Lead",_unitGroup];
_groupWPMarker = format ["%1_WP",_unitGroup];

//Get group variables
_groupVariables = _unitGroup getVariable "GroupVariables";
if (isNil "_groupVariables") then {
	_unitGroup setVariable ["GroupVariables",[]];
	_groupVariables = _unitGroup getVariable "GroupVariables";
	_groupVariables = [_unitGroup,_unitType] call A3XAI_setUnitType;
	_unitGroup setVariable ["GroupVariables",_groupVariables];
	if (A3XAI_debugLevel > 0) then {
		diag_log format ["A3XAI Debug: Group %1 variables not found. Setting them now.",_unitGroup];
	};
} else {
	if (A3XAI_debugLevel > 0) then {
		diag_log format ["A3XAI Debug: Group %1 variables check passed.",_unitGroup];
	};
};

//Set up timer variables
_currentTime = diag_tickTime;
_managerStartTime = _currentTime;
if (isNil {_unitGroup getVariable "lastRearmTime"}) then {_unitGroup setVariable ["lastRearmTime",_currentTime];};
if (isNil {_unitGroup getVariable "antistuckTime"}) then {_unitGroup setVariable ["antistuckTime",_currentTime];};
if (isNil {_unitGroup getVariable "lootGenTime"}) then {_unitGroup setVariable ["lootGenTime",_currentTime];};

//Setup loot variables
_updateServerLoot = (A3XAI_enableHC && {!isDedicated});
_pullRate = 30;

if (isDedicated) then {
	[_unitGroup,_unitType,_unitLevel] call A3XAI_setLoadoutVariables;
} else {
	waitUntil {uiSleep 0.25; (local _unitGroup)};
	[_unitGroup,_unitType,_unitLevel] call A3XAI_setLoadoutVariables_HC;
};

if (A3XAI_groupManageMode isEqualTo 1) exitWith {
	[_unitGroup, _vehicle, _groupVariables, _unitLevel] call A3XAI_addGroupManangerGlobal;
};

//Main loop
while {(!isNull _unitGroup) && {(_unitGroup getVariable ["GroupSize",-1]) > 0}} do {
	//Every-loop check
	[_unitGroup,_vehicle] call (_groupVariables select 0);
	
	//Check units
	[_unitGroup] call (_groupVariables select 1);

	//Generate loot
	if ((diag_tickTime - (_unitGroup getVariable ["lootGenTime",diag_tickTime])) > _pullRate) then {
		[_unitGroup,_unitLevel] call (_groupVariables select 2);
	};
	
	//Vehicle ammo/fuel check
	if ((alive _vehicle) && {(diag_tickTime - (_unitGroup getVariable ["lastRearmTime",0])) > 180}) then {	//If _vehicle is objNull (if no vehicle was assigned to the group) then nothing in this bracket should be executed
		[_unitGroup,_vehicle] call (_groupVariables select 3);
	};
	
	//Antistuck 
	if ((diag_tickTime - (_unitGroup getVariable ["antistuckTime",diag_tickTime])) > (_groupVariables select 5)) then {
		[_unitGroup,_vehicle,(_groupVariables select 5)] call (_groupVariables select 4);
	};

	if (A3XAI_HCIsConnected && {_unitGroup getVariable ["HC_Ready",false]} && {(diag_tickTime - _managerStartTime) > 30}) then {
		private ["_result"];
		_result = _unitGroup call A3XAI_transferGroupToHC;
		if (_result) then {
			waitUntil {sleep 1.5; (!(local _unitGroup) or {isNull _unitGroup})};
			if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Transferred ownership of %1 group %2 to HC %3.",(_unitGroup getVariable ["unitType",_unitType]),_unitGroup,A3XAI_HCObjectOwnerID];};
			//breakOut "GroupManagerScope"; //To-do add "Local" EH to group units first!
			waitUntil {sleep 15; ((local _unitGroup) or {isNull _unitGroup})};
			if ((_unitGroup getVariable ["GroupSize",-1]) > 0) then {
				_currentTime = diag_tickTime;
				// _unitGroup call A3XAI_initNoAggroStatus;
				_unitGroup setVariable ["lastRearmTime",_currentTime];
				_unitGroup setVariable ["antistuckTime",_currentTime];
				_unitGroup setVariable ["lootGenTime",_currentTime];
			};
			if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: %1 group %2 ownership was returned to server.",(_unitGroup getVariable ["unitType",_unitType]),_unitGroup];};
		} else {
			if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Waiting to transfer %1 group %2 ownership to headless client (ID: %3).",(_unitGroup getVariable ["unitType",_unitType]),_unitGroup,A3XAI_HCObjectOwnerID];};
		};
	};
	
	if (isDedicated) then {
		if !((groupOwner _unitGroup) in [2,A3XAI_HCObjectOwnerID]) then {
			_unitGroup setGroupOwner 2;
			diag_log format ["[A3XAI] Returned improperly transferred group %1 to server.",_unitGroup];
		};
	};

	if ((_unitGroup getVariable ["GroupSize",0]) > 0) then {uiSleep 15};
};

if (A3XAI_enableDebugMarkers) then {
	deleteMarker _groupLeadMarker;
	deleteMarker _groupWPMarker;
};

if !(isNull _unitGroup) then {
	_unitGroup setVariable ["isManaged",false]; //allow group manager to run again on group respawn.

	if !(isDedicated) exitWith {
		A3XAI_transferGroup_PVS = _unitGroup;
		publicVariableServer "A3XAI_transferGroup_PVS";	//Return ownership to server.
		A3XAI_HCGroupsCount = A3XAI_HCGroupsCount - 1;
		if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Returned ownership of AI %1 group %2 to server.",_unitType,_unitGroup];};
	};

	while {(_unitGroup getVariable ["GroupSize",-1]) isEqualTo 0} do {	//Wait until group is either respawned or marked for deletion. A dummy unit should be created to preserve group.
		uiSleep 5;
	};

	if ((_unitGroup getVariable ["GroupSize",-1]) < 0) then {	//GroupSize value of -1 marks group for deletion
		if (!isNull _unitGroup) then {
			if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Deleting %2 group %1.",_unitGroup,(_unitGroup getVariable ["unitType","unknown"])]};
			_result = _unitGroup call A3XAI_deleteGroup;
		};
	};
} else {
	diag_log "A3XAI Error: An A3XAI-managed group was deleted unexpectedly!";
};

if (local _vehicle) then {
	call {
		if (_vehicle getVariable ["DeleteVehicle",false]) exitWith {
			_vehicle setPosATL [0,0,100];
			deleteVehicle _vehicle;
		};
		if (isEngineOn _vehicle) exitWith {
			_vehicle engineOn false;
		};
	};
};

true
