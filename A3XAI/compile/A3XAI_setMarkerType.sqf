#include "\A3XAI\globaldefines.hpp"

/*
private ["_trigger", "_objectString", "_mapMarkerArray"];

_trigger = _this select 0;
_objectString = _this select 1;

if !(isNull _trigger) then {
	if !(_objectString in allMapMarkers) then {
		_objectString = createMarker [_objectString, _trigger];
		_objectString setMarkerType "mil_warning";
		_objectString setMarkerBrush "Solid";
		_mapMarkerArray = missionNamespace getVariable ["A3XAI_mapMarkerArray",[]];
		_mapMarkerArray pushBack _objectString;
	};

	_objectString setMarkerText "STATIC TRIGGER (ACTIVE)";
	_objectString setMarkerColor "ColorRed";
};

// diag_log format ["%1 %2",__FILE__,_this];

*/

true
