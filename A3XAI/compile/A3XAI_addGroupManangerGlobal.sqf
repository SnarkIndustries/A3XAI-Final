#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle", "_groupVariables", "_unitLevel"];

//Expected input:
// _unitGroup = _this select 0;
// _vehicle = _this select 1;
// _groupVariables = _this select 2;
// _unitLevel = _this select 3;

if (A3XAI_debugLevel > 1) then {
	diag_log format ["A3XAI Debug: %1 groups in global group manager.",(count A3XAI_managedGroups)];
};

A3XAI_managedGroups pushBack _this;

if (A3XAI_managedGroups isEqualTo [_this]) then {
	diag_log "Starting new global group manager.";
	_nul = [] spawn {
		while {!(A3XAI_managedGroups isEqualTo [])} do {
			// diag_log "DEBUG: Global group manager is checking groups.";
			{
				_unitGroup 		= _x select 0;
				_vehicle 		= _x select 1;
				_groupVariables = _x select 2;
				_unitLevel 		= _x select 3;
				
				if ((!isNull _unitGroup) && {(_unitGroup getVariable ["GroupSize",-1]) > 0}) then {
					call {
						if (A3XAI_HCIsConnected && {local _unitGroup}) exitWith {
							_result = _unitGroup call A3XAI_transferGroupToHC;
							if (_result) then {
								if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Transferred ownership of %1 group %2 to HC %3.",(_unitGroup getVariable ["unitType",_unitType]),_unitGroup,A3XAI_HCObjectOwnerID];};
							};
						};
						
						[_unitGroup,_vehicle] call (_groupVariables select 0);
						[_unitGroup] call (_groupVariables select 1);
						if ((diag_tickTime - (_unitGroup getVariable ["lootGenTime",diag_tickTime])) > LOOT_PULL_RATE) then {
							[_unitGroup,_unitLevel] call (_groupVariables select 2);
						};
						if ((alive _vehicle) && {(diag_tickTime - (_unitGroup getVariable ["lastRearmTime",0])) > CHECK_VEHICLE_AMMO_FUEL_TIME}) then {	//If _vehicle is objNull (if no vehicle was assigned to the group) then nothing in this bracket should be executed
							[_unitGroup,_vehicle] call (_groupVariables select 3);
						};
						if ((diag_tickTime - (_unitGroup getVariable ["antistuckTime",diag_tickTime])) > (_groupVariables select 5)) then {
							[_unitGroup,_vehicle,(_groupVariables select 5)] call (_groupVariables select 4);
						};
					};
				} else {
					// diag_log format ["DEBUG: Global group manager is removing group %1.",_unitGroup];
					
					if (A3XAI_enableDebugMarkers) then {
						deleteMarker format ["%1_Lead",_unitGroup];
						deleteMarker format ["%1_WP",_unitGroup];
					};

					_nul = [_unitGroup,_vehicle] spawn {
						_unitGroup 	= _this select 0;
						_vehicle 	= _this select 1;
						
						while {(_unitGroup getVariable ["GroupSize",-1]) isEqualTo 0} do {	//Wait until group is either respawned or marked for deletion. A dummy unit should be created to preserve group.
							uiSleep 5;
						};
						
						if ((_unitGroup getVariable ["GroupSize",-1]) < 0) then {	//GroupSize value of -1 marks group for deletion
							if (!isNull _unitGroup) then {
								if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Deleting %2 group %1.",_unitGroup,(_unitGroup getVariable ["unitType","unknown"])]};
								_result = _unitGroup call A3XAI_deleteGroup;
							};
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
					};
					
					A3XAI_managedGroups deleteAt _forEachIndex;
				};
				uiSleep 0.1;
			} forEach A3XAI_managedGroups;
			
			uiSleep 10;
		};
		
		if (A3XAI_debugLevel > 1) then {
			diag_log format ["A3XAI Debug: %1 groups in global group manager. Exiting.",(count A3XAI_managedGroups)];
		};
	};
};

true
