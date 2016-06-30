#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas, NetFusion

    Description:
    Init for rally system

    Parameter(s):
    None

    Returns:
    None
*/
// Create a global namespace and publish it
GVAR(pointStorage) = true call CFUNC(createNamespace);
publicVariable QGVAR(pointStorage);

// Add the bases as default points
["missionStarted", {
    {
        private _markerName = "respawn_" + (toLower str _x);
        private _markerPosition = getMarkerPos _markerName;
        if (!(_markerPosition isEqualTo [0, 0, 0])) then {
            ["BASE", _markerPosition, _x, -1, "a3\ui_f\data\map\Markers\Military\box_ca.paa"] call FUNC(addPoint);
        };
        nil
    } count EGVAR(Mission,competingSides);
}] call CFUNC(addEventHandler);
