#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: BadGuy, joko // Jonas, NetFusion

    Description:
    Initializes treatment system

    Parameter(s):
    None

    Returns:
    None
*/

/*
 * WEAPON SWITCHING
 */
[QGVAR(SwitchWeapon), {
    params ["_item"];

    // Restore old action
    [QGVAR(RestoreWeapon)] call CFUNC(localEvent);

    // Move the weapon on back
    PRA3_Player action ["SwitchWeapon", PRA3_Player, PRA3_Player, 99];

    // Create a simple object
    private _modelName = getText (configFile >> "CfGWeapons" >> _item >> "model");
    if ((_modelName select [0, 1]) == "\") then {
        _modelName = _modelName select [1, count _modelName - 1];
    };
    if ((_modelName select [count _modelName - 4, 3]) != "p3d") then {
        _modelName = _modelName + ".p3d";
    };
    private _fakeWeapon = createSimpleObject [_modelName, [0, 0, 0]];

    // Attach it to the right hand
    _fakeWeapon attachTo [PRA3_Player, [0, 0, -0.2], "rwrist"];
    if (_item != "medikit") then {
        ["setVectorDirAndUp", [_fakeWeapon, [[0, 0, -1], [0, 1, 0]]]] call CFUNC(globalEvent);
    };

    // Store the weapon holder to remove it on restoring real weapon.
    PRA3_Player setVariable [QGVAR(fakeWeapon), _fakeWeapon];
    PRA3_Player setVariable [QGVAR(fakeWeaponName), _item];

    // Create an action to restore main weapon. Use the vanilla switch weapon action data.
    private _actionConfig = configFile >> "CfgActions" >> "SwitchWeapon";
    if ((primaryWeapon PRA3_Player != "") && getNumber (_actionConfig >> "show") == 1) then {
        // Add the action and store the id to remove it on grenade mode exit.
        private _restoreWeaponActionId = PRA3_Player addAction [format [getText (_actionConfig >> "text"), getText (configFile >> "CfgWeapons" >> (primaryWeapon PRA3_Player) >> "displayName")], {
            // Switch back to the primary weapon.
            PRA3_Player action ["SwitchWeapon", PRA3_Player, PRA3_Player, 0];
        }, nil, getNumber (_actionConfig >> "priority"), getNumber (_actionConfig >> "showWindow") == 1, getNumber (_actionConfig >> "hideOnUse") == 1, getText (_actionConfig >> "shortcut")];
        PRA3_Player setVariable [QGVAR(restoreWeaponAction), _restoreWeaponActionId];
    };

    // If player lose the item by scripts
    [{
        params ["_item", "_id"];

        if (PRA3_Player getVariable [QGVAR(fakeWeaponName), ""] == "") exitWith {
            _id call CFUNC(removePerFrameHandler);
        };

        if (!(_item in (items PRA3_Player))) then {
            PRA3_Player action ["SwitchWeapon", PRA3_Player, PRA3_Player, 0];
        };
    }, 0, _item] call CFUNC(addPerFrameHandler);
}] call CFUNC(addEventHandler);

[QGVAR(RestoreWeapon), {
    PRA3_Player setVariable [QGVAR(fakeWeaponName), ""];

    // Get the weapon holder and delete it.
    private _fakeWeapon = PRA3_Player getVariable [QGVAR(fakeWeapon), objNull];
    deleteVehicle _fakeWeapon;

    // Remove the exit action if it exists.
    private _restoreWeaponActionId = PRA3_Player getVariable [QGVAR(restoreWeaponAction), -1];
    if (_restoreWeaponActionId > -1) then {
        PRA3_Player removeAction _restoreWeaponActionId;
    };
}] call CFUNC(addEventHandler);

// Reset values on death
[QGVAR(Killed), {
    (_this select 0) params ["_unit"];

    PRA3_Player setVariable [QGVAR(fakeWeapon), nil];
    PRA3_Player setVariable [QGVAR(fakeWeaponName), nil];
    PRA3_Player setVariable [QGVAR(restoreWeaponAction), nil];

    PRA3_Player setVariable [QGVAR(medicalActionRunning), ""];
}] call CFUNC(addEventHandler);

// To restore default behaviour if the weapon is changed use currentWeaponChanged EH.
["currentWeaponChanged", {
    (_this select 0) params ["_currentWeapon", "_oldWeapon"];

    if (_currentWeapon != "") then {
        [QGVAR(RestoreWeapon)] call CFUNC(localEvent);
    };
}] call CFUNC(addEventHandler);

["vehicleChanged", {
    [QGVAR(RestoreWeapon)] call CFUNC(localEvent);
}] call CFUNC(addEventHandler);

/*
 * MEDICAL ACTIONS
 */
GVAR(medicalActionRunning) = "";
GVAR(medicalActionTarget) = objNull;
[QGVAR(StartMedicalAction), {
    (_this select 0) params ["_action", "_target"];

    GVAR(medicalActionRunning) = _action;
    GVAR(medicalActionTarget) = _target;
    _target setVariable [QGVAR(medicalActionRunning), _action, true];

    // Publish time
    _target setVariable [QGVAR(treatmentStartTime), serverTime, true];

    [QGVAR(RegisterTreatment), _target, [PRA3_Player, _action]] call CFUNC(targetEvent);
}] call CFUNC(addEventHandler);

[QGVAR(StopMedicalAction), {
    (_this select 0) params ["_finished"];

    [QGVAR(DeregisterTreatment), GVAR(medicalActionTarget), [PRA3_Player, GVAR(medicalActionRunning), _finished]] call CFUNC(targetEvent);

    GVAR(medicalActionRunning) = "";
    GVAR(medicalActionTarget) = objNull;
}] call CFUNC(addEventHandler);

GVAR(currentTreatingUnits) = [];
[QGVAR(RegisterTreatment), {
    (_this select 0) params ["_unit"];

    GVAR(currentTreatingUnits) pushBackUnique _unit;

    [QGVAR(PrepareTreatment), _this select 0] call CFUNC(localEvent);
}] call CFUNC(addEventHandler);

[QGVAR(DeregisterTreatment), {
    (_this select 0) params ["_unit"];

    GVAR(currentTreatingUnits) = GVAR(currentTreatingUnits) - [_unit];
    if (GVAR(currentTreatingUnits) isEqualTo []) then {
        PRA3_Player setVariable [QGVAR(medicalActionRunning), "", true];
    };
    PRA3_Player setVariable [QGVAR(treatmentStartTime), serverTime, true];
    [QGVAR(PrepareTreatment), _this select 0] call CFUNC(localEvent);
}] call CFUNC(addEventHandler);