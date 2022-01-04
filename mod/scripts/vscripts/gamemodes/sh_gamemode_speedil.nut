global function Sh_GamemodeSpeedIL_Init;

global const string GAMEMODE_SPEEDIL = "speedil"


void function Sh_GamemodeSpeedIL_Init()
{
    // create custom gamemode
    AddCallback_OnCustomGamemodesInit( CreateGamemodeSpeedIL )
}

void function CreateGamemodeSpeedIL()
{
    GameMode_Create( GAMEMODE_SPEEDIL )
    GameMode_SetName( GAMEMODE_SPEEDIL, "#GAMEMODE_SPEEDIL" )
	GameMode_SetDesc( GAMEMODE_SPEEDIL, "#PL_speedil_desc" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_SPEEDIL, "ffa_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_SPEEDIL, 10, 0.0 )
	GameMode_AddScoreboardColumnData( GAMEMODE_SPEEDIL, "#SCOREBOARD_SCORE", PGS_ASSAULT_SCORE, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_SPEEDIL, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2 )
	GameMode_SetColor( GAMEMODE_SPEEDIL, [147, 204, 57, 255] )

    AddPrivateMatchMode( GAMEMODE_SPEEDIL )
	AddPrivateMatchModeSettingEnum( "#GAMEMODE_SPEEDIL", "sil_select_mode", [ "MinSpeed", "LastStanding" ], "1" )

	GameMode_SetDefaultScoreLimits( GAMEMODE_SPEEDIL, 150, 0 )

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_SPEEDIL, GamemodeSpeedIL_Init )
		GameMode_AddServerInit( GAMEMODE_SPEEDIL, GamemodeFFAShared_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_SPEEDIL, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_SPEEDIL, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_SPEEDIL, ClGamemodeSpeedIL_Init )
		GameMode_AddClientInit( GAMEMODE_SPEEDIL, GamemodeFFAShared_Init )
		GameMode_AddClientInit( GAMEMODE_SPEEDIL, ClGamemodeSpeedIL_Init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_SPEEDIL, CompareAssaultScore )
		GameMode_AddSharedInit( GAMEMODE_SPEEDIL, GamemodeFFA_Dialogue_Init )
	#endif
}