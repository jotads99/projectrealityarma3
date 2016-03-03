#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas

    Description:
    [Description]

    Parameter(s):
    0: Event ID <String>
    1: Functions <Code>
    2: Arguments <Any>

    Returns:
    None
*/
params [["_event", "", [""]], ["_function", {}, [{}]], ["_args", []]];

_event = format ["PRA3_Event_%1", _event];
private _eventArray = [GVAR(EventNamespace), _event, []] call FUNC(getVariableLoc);
_eventArray pushBack [_function, _args];
GVAR(EventNamespace) setVariable [_event, _eventArray];