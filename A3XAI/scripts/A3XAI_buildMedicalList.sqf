#include "\A3XAI\globaldefines.hpp"

private ["_startTime", "_list0", "_items", "_itemPrice"];

_startTime = diag_tickTime;

_list0 = [missionConfigFile >> "CfgTraderCategories" >> "FirstAid","items",[]] call BIS_fnc_returnConfigEntry;

_items = [];

{
	_items append _x;
} forEach [_list0];

if !(A3XAI_dynamicMedicalBlacklist isEqualTo []) then {
	_items = _items - A3XAI_dynamicMedicalBlacklist;
};

{
	_itemPrice = getNumber(missionConfigFile >> "CfgExileArsenal" >> _x >> "price");
	if (_itemPrice > A3XAI_itemPriceLimit) then {
		_items deleteAt _forEachIndex;
		if (A3XAI_debugLevel > 0) then {diag_log format ["A3XAI Debug: Item %1 exceeds price limit of %2.",_x,A3XAI_itemPriceLimit];};
	};
} forEach _items;

if !(_items isEqualTo []) then {
	A3XAI_medicalLoot = _items;
	if (A3XAI_debugLevel > 0) then {
		diag_log format ["A3XAI Debug: Generated %1 medical classnames in %2 seconds.",(count _items),diag_tickTime - _startTime];
		if (A3XAI_debugLevel > 1) then {
			diag_log format ["A3XAI Debug: Contents of A3XAI_medicalLoot: %1",A3XAI_medicalLoot];
		};
	};
} else {
	diag_log "A3XAI Error: Could not dynamically generate medical classname list. Classnames from A3XAI_config.sqf used instead.";
};

//Cleanup global vars
A3XAI_dynamicMedicalBlacklist = nil;
