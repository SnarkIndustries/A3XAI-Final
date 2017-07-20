#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup","_detectBase","_vehicle","_canParaDrop","_detectStartPos"];
_unitGroup = _this select 0;

if (_unitGroup getVariable ["IsDetecting",false]) exitWith {};
if (_unitGroup getVariable ["EnemiesIgnored",false]) then {[_unitGroup,"Default"] call A3XAI_forceBehavior};

_vehicle = _unitGroup getVariable ["assignedVehicle",objNull];

if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 %2 detection started.",_unitGroup,(typeOf (_vehicle))];};

_detectStartPos = getPosATL _vehicle;
_canParaDrop = ((diag_tickTime - (_unitGroup getVariable ["HeliLastParaDrop",-A3XAI_paraDropCooldown])) > A3XAI_paraDropCooldown);
_vehicle flyInHeight (FLYINHEIGHT_AIR_SEARCHING_BASE + (random FLYINHEIGHT_AIR_SEARCHING_VARIANCE));
_unitGroup setVariable ["IsDetecting",true];

while {!(_vehicle getVariable ["VehicleDisabled",false]) && {(_unitGroup getVariable ["GroupSize",-1]) > 0} && {local _unitGroup}} do {
	private ["_detected","_vehPos","_nearBlacklistAreas","_playerPos","_canReveal"];
	
	_vehPos = getPosATL _vehicle;
	_detected = _vehPos nearEntities [[PLAYER_UNITS,"LandVehicle"],DETECT_RANGE_AIR];
	
	{
		if !(isPlayer _x) then {
			_detected deleteAt _forEachIndex;
		};
		if (_forEachIndex > 4) exitWith {};
	} forEach _detected;
	
	_nearBlacklistAreas = if (_detected isEqualTo []) then {[]} else {nearestLocations [_vehPos,[BLACKLIST_OBJECT_GENERAL],1500]};
	
	if (_canParaDrop) then {
		{
			_playerPos = getPosATL _x;
			if ((isPlayer _x) && {isNull (objectParent _x)} && {({if (_playerPos in _x) exitWith {1}} count _nearBlacklistAreas) isEqualTo 0}) exitWith {
				_unitGroup setVariable ["HeliLastParaDrop",diag_tickTime];
				_nul = [_unitGroup,_vehicle,_x] spawn A3XAI_heliParaDrop;
				_canParaDrop = false;
			};
			uiSleep 0.1;
		} forEach _detected;
	} else {
		_canReveal = ((combatMode _unitGroup) in ["YELLOW","RED"]);
		{
			_playerPos = getPosATL _x;
			if ((isPlayer _x) && {isNull (objectParent _x)} && {({if (_playerPos in _x) exitWith {1}} count _nearBlacklistAreas) isEqualTo 0}) then {
				if (_canReveal && {(_unitGroup knowsAbout _x) < 2}) then {
					_heliAimPos = aimPos _vehicle;
					_playerEyePos = eyePos _x;
					if (((lineIntersectsSurfaces [_heliAimPos,_playerEyePos,_vehicle,_x,true,1]) isEqualTo []) && {A3XAI_airDetectChance call A3XAI_chance}) then {
						_unitGroup reveal [_x,2.5]; 
						if (({if (RADIO_ITEM in (assignedItems _x)) exitWith {1}} count (units (group _x))) > 0) then {
							[_x,[31+(floor (random 5)),[name (leader _unitGroup)]]] call A3XAI_radioSend;
						};
					};
				};
			};
			uiSleep 0.1;
		} forEach _detected;
	};
	
	if (((_vehicle distance2D _detectStartPos) > DETECT_LENGTH_AIR_2D) or {_vehicle getVariable ["VehicleDisabled",false]}) exitWith {};
	uiSleep 15;
};

_unitGroup setVariable ["IsDetecting",false];
_vehicle flyInHeight (FLYINHEIGHT_AIR_PATROLLING_BASE + (random FLYINHEIGHT_AIR_PATROLLING_VARIANCE));

if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Group %1 %2 detection end.",_unitGroup,(typeOf (_vehicle))];};
