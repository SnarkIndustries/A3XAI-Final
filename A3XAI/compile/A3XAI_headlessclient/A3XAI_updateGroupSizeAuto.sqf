#include "\A3XAI\globaldefines.hpp"

private ["_unitGroup", "_groupSize"];

_unitGroup = _this;

_groupSize = {alive _x} count (units _unitGroup);
_unitGroup setVariable ["GroupSize",_groupSize];

if (A3XAI_debugLevel > 1) then {diag_log format ["A3XAI Debug: Updated GroupSize variable for group %1 to %2",_unitGroup,_groupSize];};

_groupSize
