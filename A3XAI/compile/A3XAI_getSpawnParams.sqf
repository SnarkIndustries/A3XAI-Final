#include "\A3XAI\globaldefines.hpp"

private ["_position","_nearestLocations", "_nearestLocationType", "_spawnParams","_locationName","_nearestLocation"];

_position = _this;
_nearestLocations = nearestLocations [_position,["NameCityCapital","NameCity","NameVillage","NameLocal"],1000];

if !(_nearestLocations isEqualTo []) then {
	_nearestLocation = (_nearestLocations select 0);
	_nearestLocationType = type _nearestLocation;
	_locationName = (text _nearestLocation) + " " + str (_position);
} else {
	_nearestLocationType = "wilderness";
	_locationName = format ["Wilderness %1",_position];
};
_spawnParams = call {
	if (_nearestLocationType isEqualTo "NameCityCapital") exitWith {[A3XAI_minAI_capitalCity,A3XAI_addAI_capitalCity,A3XAI_unitLevel_capitalCity,A3XAI_spawnChance_capitalCity]};
	if (_nearestLocationType isEqualTo "NameCity") exitWith {[A3XAI_minAI_city,A3XAI_addAI_city,A3XAI_unitLevel_city,A3XAI_spawnChance_city]};
	if (_nearestLocationType isEqualTo "NameVillage") exitWith {[A3XAI_minAI_village,A3XAI_addAI_village,A3XAI_unitLevel_village,A3XAI_spawnChance_village]};
	if (_nearestLocationType isEqualTo "NameLocal") exitWith {[A3XAI_minAI_remoteArea,A3XAI_addAI_remoteArea,A3XAI_unitLevel_remoteArea,A3XAI_spawnChance_remoteArea]};
	
	[A3XAI_minAI_wilderness,A3XAI_addAI_wilderness,A3XAI_unitLevel_wilderness,A3XAI_spawnChance_wilderness] //Default
};

_spawnParams pushBack _locationName;
_spawnParams pushBack _nearestLocationType;

// diag_log format ["%1 got spawn params %2",__FILE__,_spawnParams];

_spawnParams