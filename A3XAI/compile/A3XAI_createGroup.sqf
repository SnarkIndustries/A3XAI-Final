#include "\A3XAI\globaldefines.hpp"

private["_unitGroup","_protect","_unitType"];
_unitType = _this select 0;

_unitGroup = createGroup A3XAI_side;
if ((count _this) > 1) then {_unitGroup call A3XAI_protectGroup};
[_unitGroup,_unitType] call A3XAI_setUnitType;
A3XAI_activeGroups pushBack _unitGroup;

_unitGroup