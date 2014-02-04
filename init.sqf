X39_MedSys_var_Pain_MorphineHealValue = 3; // Default 1
X39_MedSys_BandageBleedingHeal = 2; // Default 1
X39_MedSys_Healing_MedKitValue = 5; // Default ?
X39_MedSys_PreventGuiOpening = false;
X39_MedSys_Display_TimeBeforeRespawnAvailable_Death = 30;
execVM "PrykUav.sqf";
hornet1path = compile preprocessFile "hornet1.sqf";
hornet2path = compile preprocessFile "hornet2.sqf";
[[.2, .01], 0.2, 26, 40] execVM "setFog.sqf";
respawn = base;
respawndelay = 5;