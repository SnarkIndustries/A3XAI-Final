#include "\A3XAI\globaldefines.hpp"

_unitGroup = _this select 0;
_vehicle = _this select 1;

_vehicleType = (typeOf _vehicle);
_isAirVehicle = (_vehicleType isKindOf "Air");
_vehiclePosition = [];
_spawnMode = "NONE";
_keepLooking = true;
_isStandard = (((_unitGroup getVariable ["unitType",""]) find "custom") isEqualTo -1);

if (_isStandard) then {
	call {
		if (_vehicleType isKindOf "Air") exitWith {
			_vehiclePosition = [(getMarkerPos "A3XAI_centerMarker"),300 + (random((getMarkerSize "A3XAI_centerMarker") select 0)),random(360),1] call A3XAI_SHK_pos;
			_vehiclePosition set [2,200];
			_spawnMode = "FLY";
		};
		if (_vehicleType isKindOf "LandVehicle") exitWith {
			while {_keepLooking} do {
				_vehiclePosition = [(getMarkerPos "A3XAI_centerMarker"),300 + random((getMarkerSize "A3XAI_centerMarker") select 0),random(360),0,[2,750],[25,_vehicleType]] call A3XAI_SHK_pos;
				if ((count _vehiclePosition) > 1) then {
					if ({isPlayer _x} count (_vehiclePosition nearEntities [[PLAYER_UNITS,"AllVehicles"], PLAYER_DISTANCE_SPAWN_AUTONOMOUS]) isEqualTo 0) then {
						_keepLooking = false;	//Found road position, stop searching
					};
				} else {
					if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Unable to find road position to spawn AI %1. Retrying in 15 seconds.",_vehicleType]};
					uiSleep 15;
				};
			};
		};
	};
} else {
};

_vehicle setPos _vehiclePosition;

call {
	if (_vehicle isKindOf "Plane") exitWith {
		_direction = (random 360);
		_velocity = velocity _vehicle;
		_vehicle setDir _direction;
		_vehicle setVelocity [(_velocity select 1)*sin _direction - (_velocity select 0)*cos _direction, (_velocity select 0)*sin _direction + (_velocity select 1)*cos _direction, _velocity select 2];
	};
	if (_vehicle isKindOf "Helicopter") exitWith {
		_vehicle setDir (random 360);
	};
	if (_vehicle isKindOf "LandVehicle") exitWith {
		_nearRoads = _vehiclePosition nearRoads 100;
		if !(_nearRoads isEqualTo []) then {
			_nextRoads = roadsConnectedTo (_nearRoads select 0);
			if !(_nextRoads isEqualTo []) then {
				_direction = [_vehicle,(_nextRoads select 0)] call BIS_fnc_relativeDirTo;
				_vehicle setDir _direction;
				//diag_log format ["Debug: Reoriented vehicle %1 to direction %2.",_vehicle,_direction];
			};
		} else {
			_vehicle setDir (random 360);
		};
	};
};

true
