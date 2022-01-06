global function ClGamemodeSpeedIL_Init;
global function ServerCallback_SILRegisterUILabel;
global function ServerCallback_SILRegisterUIIndicator;
global function ServerCallback_SILUpdateUIColor

void function ClGamemodeSpeedIL_Init()
{

    // add ffa gamestate asset
	ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_ffa.rpak" )
	// "music_s2s_00b_unidentifiedbogey"
	// "diag_sp_gibraltar_STS105_03_01_mcor_radCom"
	// "diag_sp_bossFight_STS676_02_01_imc_viper"
	// "diag_sp_bossFight_STS676_09_01_imc_viper" -- Viper's got you in the pipe, 5x5
	// "diag_sp_bossFight_STS676_02_01_imc_viper" -- I've got good tone
	// add music for mode, this is copied directly from the ffa/fra music registered in cl_music.gnut

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_s2s_00b_unidentifiedbogey", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_INTRO, "music_s2s_00b_unidentifiedbogey", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_WIN, "music_mp_freeagents_outro_win", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_DRAW, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LOSS, "music_mp_freeagents_outro_lose", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_THREE_MINUTE, "music_mp_freeagents_almostdone", TEAM_MILITIA )

	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_IMC )
	RegisterLevelMusicForTeam( eMusicPieceID.LEVEL_LAST_MINUTE, "music_mp_freeagents_lastminute", TEAM_MILITIA )

	thread ruiInit()
}

var labelRui
var indicatorRui

void function ruiInit()
{
	WaitFrame()
	if (!labelRui)
	{
		labelRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
		RuiSetInt(labelRui, "maxLines", 1)
		RuiSetInt(labelRui, "lineNum", 1)
		RuiSetFloat2(labelRui, "msgPos", Vector(0.65, 0.25, 0.0))
		RuiSetString(labelRui, "msgText", "ERR")
		RuiSetFloat(labelRui, "msgFontSize", 50)
		RuiSetFloat(labelRui, "msgAlpha", 1.0)
		RuiSetFloat(labelRui, "thicken", 0.0)
		RuiSetFloat3(labelRui, "msgColor", Vector(1.0, 0.55, 0.0))
	}

	if (!indicatorRui)
	{
		indicatorRui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, -1 )
		RuiSetInt(indicatorRui, "maxLines", 1)
		RuiSetInt(indicatorRui, "lineNum", 1)
		RuiSetFloat2(indicatorRui, "msgPos", Vector(0.78, 0.25, 0.0))
		RuiSetString(indicatorRui, "msgText", "ERR")
		RuiSetFloat(indicatorRui, "msgFontSize", 50)
		RuiSetFloat(indicatorRui, "msgAlpha", 1.0)
		RuiSetFloat(indicatorRui, "thicken", 0.0)
		RuiSetFloat3(indicatorRui, "msgColor", Vector(1.0, 0.55, 0.0))
	}
}

void function ServerCallback_SILRegisterUILabel( int data )
{

	string parse

	if ( data == 1 )
	{
		parse = "Min Speed"
	}
	else
	{
		parse = "Next Kill"
	}

	RuiSetString(labelRui, "msgText", parse)
}

void function ServerCallback_SILRegisterUIIndicator( int data )
{

	string parse

	if (data == 420)
		parse = ""
	else
		parse = data.tostring()

	RuiSetString(indicatorRui, "msgText", parse)
}

void function ServerCallback_SILUpdateUIColor( bool isRed )
{
	if (isRed)
		RuiSetFloat3(indicatorRui, "msgColor", Vector(1.0, 0.1, 0.1))
	else
		RuiSetFloat3(indicatorRui, "msgColor", Vector(1.0, 0.55, 0.0))
}