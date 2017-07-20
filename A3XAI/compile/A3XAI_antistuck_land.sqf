#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_vehicle", "_stuckCheckTime", "_checkPos", "_allWP", "_currentWP", "_nextWP","_leader"];

_unitGroup = _this select 0;
_vehicle = _this select 1;
_stuckCheckTime = _this select 2;

if (isNull _vehicle) exitWith {};

_checkPos = (getPosATL _vehicle);
_leader = (leader _unitGroup);
if ((((_leader distance (_leader findNearestEnemy _vehicle)) > NEAREST_ENEMY_LAND) or {[_checkPos,NO_AGGRO_RANGE_LAND] call A3XAI_checkInActiveNoAggroArea}) && {((_unitGroup getVariable ["antistuckPos",[0,0,0]]) distance _checkPos) < ANTISTUCK_MIN_TRAVEL_DIST_LAND}) then {
	if (canMove _vehicle) then {
		[_unitGroup] call A3XAI_fixStuckGroup;
		if ((count (waypoints _unitGroup)) isEqualTo 1) then {
			_tooClose = true;
			_wpSelect = [];
			while {_tooClose} do {
				_wpSelect = (A3XAI_locationsLand call A3XAI_selectRandom) select 1;
				if (((waypointPosition [_unitGroup,0]) distance2D _wpSelect) < ANTISTUCK_LAND_MIN_WP_DIST) then {
					_tooClose = false;
				} else {
					uiSleep 0.1;
				};
			};
			_wpSelect = [_wpSelect,ANTISTUCK_LAND_WP_DIST_BASE+(random ANTISTUCK_LAND_WP_DIST_VARIANCE),(random 360),0] call A3XAI_SHK_pos;
			[_unitGroup,0] setWaypointPosition [_wpSelect,0];
			_unitGroup setCurrentWaypoint [_unitGroup,0];
			if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Antistuck triggered for AI land vehicle %1 (Group: %2). Forcing next waypoint.",(typeOf _vehicle),_unitGroup];};
		};
		_unitGroup setVariable ["antistuckPos",_checkPos];
		_unitGroup setVariable ["antistuckTime",diag_tickTime + (_stuckCheckTime/2)];
	} else {
		if (!(_vehicle getVariable ["VehicleDisabled",false])) then {
			[_vehicle,false] call A3XAI_vehDestroyed;
			if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: AI vehicle %1 (Group: %2) is immobilized. Respawning vehicle patrol group. Damage: %3. WaterPos: %4.",(typeOf _vehicle),_unitGroup,(damage _vehicle),(surfaceIsWater _checkPos)];};
			if (A3XAI_enableDebugMarkers) then {_checkPos call A3XAI_debugMarkerLocation;};
		};
	};
} else {
	_unitGroup setVariable ["antistuckPos",_checkPos];
	_unitGroup setVariable ["antistuckTime",diag_tickTime];
};

true