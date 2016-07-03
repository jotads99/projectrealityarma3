#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: BadGuy

    Description:
    Converts a Position from MapGraphicsPosition into a position

    Parameter(s):
    0: position <MapGraphicsPosition>
    1: map <Control>

    Returns:
    0: position <Position>

    TYPE <MapGraphicsPosition>:
    OBJECT | POSITION3D | POSITION2D | [OBJECT | POSITION3D | POSITION2D,[ScreenOffsetX,ScreenOffsetY]]
*/
params ["_position"];

if (_position isEqualType [] && {(_position select 1) isEqualType []}) then {
    private _pos = _position select 0;
    private _offset = _position select 1;
    if (_pos isEqualType objNull) then {
        _pos = getPosVisual _pos;
    };
    _pos = _map ctrlMapWorldToScreen _pos;
    _pos = [(_pos select 0) + (_offset select 0)/640, (_pos select 1) + (_offset select 1)/480];
    _pos = _map ctrlMapScreenToWorld _pos;
    _position = _pos;
};

if (_position isEqualType objNull) then {
    _position getPosVisual _position;
};

_position
