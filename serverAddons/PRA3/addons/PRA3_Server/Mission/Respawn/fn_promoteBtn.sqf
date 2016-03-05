#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: BadGuy

    Description:
    Handles "Promote"-Button Events

    Parameter(s):
    0: Button <Control>

    Returns:
    None
*/
(_this select 0) params ["_btn"];
disableSerialization;

private _unit = missionNamespace getVariable [lnbData [209,[lnbCurSelRow 209,0]], objNull];
hint format ["%1", _unit];
if (!isNull _unit && PRA3_player == leader PRA3_player) then {
    ["selectLeader", units group _unit, [group PRA3_player, _unit]] call CFUNC(targetEvent);
};