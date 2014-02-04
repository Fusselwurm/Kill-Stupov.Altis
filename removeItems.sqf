//removes all items. nuff said.
_unit = _this select 0;


removeallweapons _unit; 
removeallassigneditems _unit;
Removeuniform _unit;
removeVest _unit;
removeHeadgear _unit;
removeGoggles _unit;

_unit addHeadgear "H_Cap_headphones";

_unit setIdentity "Stupov";