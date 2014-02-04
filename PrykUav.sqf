///////////////////////////////////////
//		UAV marker script by prykpryk
//		Shows corresponding markers for spotted units by UAV.
//		Scans for UAVs automaticly.
//		Script can be added to any vehicle or unit by putting "this spawn PrykUavInit" in its init line.
//		Put " execVM "PrykUav.sqf" " in init.sqf
//		PrykUav.sqf is free to use and edit. Send me your enhacements or issues in a PM at forums.bistudio.com or olikow.pl
//
//	v1.1 - 	Changed marker colors and shapes
//	v1.2 - 	Added: range based on fog
//	v1.3 - 	Added: Search for UAVs only on given (PrykUav_side) side. No idea how was it missing.
//			Fixed: Undef. variable errors for UAV range marker.
//			Fixed: Semi-transparent markers will be able turn opaque again.
//			Changed: Marker get transparent proportionally to age.
//	v1.4 -	Added: PrykUav_maxRange
///////////////////////////////////////
//Private ["_uav","_delay","_range","_UavInSight","_UavGetInSight"];
PrykUav_delay = 6;  			//Check for new targets every x sec				//co ile sek. sprawdzać nowości
PrykUav_refreshrate = 2; 		//Refresh markers every x sec. Should be divisible by PrykUav_delay	//co ile sek. odświeżać markery. Powinno byc podzielne przez PrykUav_delay
PrykUav_side = WEST; 			//Side of Uav (Script isn't suitable for TvT)	//Zmienić zależnie którą stroną gramy tj: WEST EAST RESISTANCE
PrykUav_recogEnemy = true;		//False for not to color enemy targets			//False aby wrogowie nie byli zaznaczani innym kolorem
PrykUav_disappear = 600;		//Marker will disappear after x sec				//Po tylu sekundach marker zniknie całkiem
PrykUav_Scan = true;			//Look for new deployed Uavs?					//Czy szukać nowych Uavów (złożonych z plecaka)?
PrykUav_maxRange = 6000;		//Maximal range									

//Don't edit below

PrykUav_range = 100;
PrykUavInit = {
Private ["_Uav"];
_Uav = _this;
if (isNil "PrykUavFogLoop") then {PrykUavFogLoop = _Uav spawn PrykUavGetRange};
_uav setVariable ["UavInSight",[],true];  // Tablica znanych celi Uava
_Uav spawn PrykUavPosition;
While {Alive _Uav} do
	{ _script = _Uav spawn PrykUavGetInSight;
	sleep PrykUav_delay;
	}
	
};
		

PrykUavGetInSight = {
	Private ["_Uav","_UavInSight","_UavInSightBefore"];
	_Uav = _this;
	_UavInSight = _Uav getVariable "UavInSight";
	{
		If ( !(lineintersects [aimpos _uav, getposASL _x, _uav, _x]) && !(terrainIntersectASL [getposASL _uav, getposASL _x]) && ((_uav distance _x) < PrykUav_range) && alive _x && vehicle _x == _x && !(_x isKindOf "Animal") && _x != _uav)
			then {
				If (!(_x in _UavInSight)) then {_UavInSight set [count _UavInSight, _x]};
				_x setVariable ["UavLastSeen", [time, _Uav]];}
	} foreach (_uav nearObjects ["AllVehicles", PrykUav_range]);		//if experiencing freezes try to change (_uav nearObjects ["AllVehicles", PrykUav_range]) to (Allunits + vehicles)
	_Uav setVariable ["UavInSight",_UavInSight]; 
	{
	If ((time -((_x getVariable "UavLastSeen")select 0)) <  PrykUav_delay) then{
	[_x,_Uav] spawn PrykUavMarker}} foreach _UavInSight
};

PrykUavMarker = {
	Private ["_target","_marker","_timestamp","_UavInSight"];
	_target = (_this select 0);
	If (!(_target getVariable ["UavHasMarker",false])) then {

	_target setVariable ["UavHasMarker",true];
	_timestamp = ((_target getVariable "UavLastSeen")select 0);
	_UavInSight = (_this select 1) getVariable "UavInSight";
	// 0: obiekt 1: Uav
	_marker = createMarker [str _target + str random 1, position _target];
	/*if ((_this select 1)== _target) then {_isUav = true;
	_marker SetMarkerShape "ELLIPSE";
	_marker setMarkerBrush "Border";
	_marker setMarkerSize [PrykUav_range,PrykUav_range]}*/
	if (vehicle _target isKindOf "Land" && !(vehicle _target isKindOf "Man")) then {
		_marker setmarkershape "ICON";
		_marker setmarkertype "c_car";};
	if (vehicle _target isKindOf "Helicopter") then { 
		_marker setmarkershape "ICON";
		_marker setmarkertype "c_air";};
	if (vehicle _target isKindOf "Plane") then {
		_marker setmarkershape "ICON";
		_marker setmarkertype "c_plane";};
	_marker setMarkerColor "ColorGreen";
	if ( ((side _target) getfriend (side (_this select 1))) < 0.6 AND PrykUav_recogEnemy) then {_marker setMarkerColor "ColorRed"} else {_marker setmarkersize [0.75,0.75]};
	if (!(PrykUav_recogEnemy)) then {_marker setMarkerColor "ColorOrange";};
	if (_target isKindOf "Man") then {
		_marker setmarkershape "ICON";
		_marker setmarkertype "mil_triangle_noShadow";
		_marker setMarkerSize [0.6,0.8]};
	
While {(_target in _UavInSight) AND (time - _timestamp) < PrykUav_disappear} 
	do{
	While {(_target in _UavInSight) AND ((time - _timestamp) < PrykUav_delay)} 
		do{
		sleep PrykUav_refreshrate;
		//if (_isUav) then {_marker setMarkerSize [PrykUav_range,PrykUav_range]}; 
		_marker setMarkerDir (getDir _target);
		_marker setMarkerPos (getPos _target);
		_timestamp = ((_target getVariable "UavLastSeen")select 0);
		_marker setMarkerAlpha 1;};
	_marker setMarkerAlpha ((-(time - _timestamp)+PrykUav_disappear)/PrykUav_disappear);
	_timestamp = ((_target getVariable "UavLastSeen")select 0);
	sleep PrykUav_refreshrate;};
	deleteMarker _marker;
	_target setVariable ["UavHasMarker",false];
	}
	};
	
PrykUavGetRange={ While {true} do{
sleep PrykUav_refreshrate;				//lub sleep PrykUav_delay
Private ["_fog","_fogcalc"];
_fogcalc = 0;
_fog = fog;
If (_fog < 0.2 AND _fog >= 0) then { _fogcalc = -23000 * _fog + 6000};
If (_fog >= 0.2 AND _fog < 0.5) then { _fogcalc = -4000 * _fog + 2200};
If (_fog >= 0.5 ) then { _fogcalc = -400 * _fog + 400};
If (_fog < 0) then { _fogcalc = 6000};
If (_fogcalc > PrykUav_maxRange) then { _fogcalc = PrykUav_maxRange};
PrykUav_range = _fogcalc}};

PrykUavPosition = {
Private ["_uav","_marker"];
_uav = _this;
_marker = createMarker [str _uav + str random 1, position _uav];
_marker SetMarkerShape "ELLIPSE";
_marker setMarkerBrush "Border";
_marker setMarkerSize [PrykUav_range,PrykUav_range];
While {alive _uav} do {
	sleep PrykUav_refreshrate;
	_marker setMarkerPos (getPos _uav);
	_marker setMarkerSize [PrykUav_range,PrykUav_range];
};
deleteMarker _marker;
};
	
	
	If (isServer AND PrykUav_Scan) then {
While {true} do
{ sleep 10;
{If (((str(_x getVariable ["UavInSight","Dupa"])) == """Dupa""") AND side _x == PrykUav_side) then{ _x spawn PrykUavInit} } foreach AllUnitsUav;
sleep 10;
};};

