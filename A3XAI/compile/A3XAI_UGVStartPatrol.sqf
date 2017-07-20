#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup","_tooClose","_locationSelected"];
_unitGroup = _this select 0;

_tooClose = true;
_locationSelected = [0,0,0];

while {_tooClose} do {
	_locationSelected = (A3XAI_locationsLand call A3XAI_selectRandom) select 1;
	if (((waypointPosition [_unitGroup,0]) distance2D _locationSelected) > 300) then {
		_tooClose = false;
	} else {
		uiSleep 0.1;
	};
};

_locationSelected = [_locationSelected,random(300),random(360),0,[1,300]] call A3XAI_SHK_pos;
[_unitGroup,0] setWPPos _locationSelected;
[_unitGroup,1] setWPPos _locationSelected;
[_unitGroup,2] setWaypointPosition [_locationSelected,0];

true
