global function GamemodeSpeedIL_Init

struct {
	bool testmode // allows playing 1 player: no way to win
} file

void function GamemodeSpeedIL_Init()
{
    SetSpawnpointGamemodeOverride( FFA )

	SetShouldUseRoundWinningKillReplay( true )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetWeaponDropsEnabled( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	SetRespawnsEnabled( false )

	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( SpeedInitPlayer )
	AddCallback_OnPlayerKilled( SpeedOnPlayerKilled )
	AddCallback_OnPlayerRespawned( SpeedOnPlayerRespawned )

	AddCallback_GameStateEnter( eGameState.Prematch, PlayViperIntro )
	AddCallback_GameStateEnter( eGameState.Playing, TrackPlayerSpeed )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )

	if ( GetConVarString( "sil_mode" ) == "testing" )
	{
		file.testmode = true
	}
}

void function SpeedInitPlayer( entity player )
{
	thread SpeedInitPlayer_Threaded( player )
}

void function SpeedOnPlayerRespawned( entity player )
{
	UpdateLoadout( player )
	player.SetMaxHealth( 2000 )
	player.SetHealth( 2000 )
}

void function SpeedInitPlayer_Threaded( entity player )
{
	// bit of a hack, need to rework earnmeter code to have better support for completely disabling it
	// rn though this just waits for earnmeter code to set the mode before we set it back
	WaitFrame()
	if ( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
}

void function TrackPlayerSpeed()
{
	thread TrackPlayerSpeed_Threaded()
	thread KillLowestScorer_Threaded()
}

void function TrackPlayerSpeed_Threaded()
{
	while( true )
	{
		wait 0.1
		array<entity> players = GetPlayerArray()

		int alive = 0

		foreach (entity player in players)
		{

			if ( IsAlive( player ) )
			{
				player.SetMaxHealth( 2000 )
				player.SetHealth( 2000 )
				// score tracking
				vector velocity = player.GetVelocity() // tricky math stuffs i half understand
				float playerVel = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
				float velNormal = playerVel * 0.068544 // kph

				player.SetPlayerGameStat( PGS_ASSAULT_SCORE, velNormal )

				// hacky way to set team score
				int score = GameRules_GetTeamScore( player.GetTeam() )
				AddTeamScore(player.GetTeam(), -score )
				AddTeamScore(player.GetTeam(), velNormal.tointeger())
				//////////

				alive += 1 // check for total alive players


			}
			else
			{
				player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 )

				// hacky way to set team score
				int score = GameRules_GetTeamScore( player.GetTeam() )
				AddTeamScore(player.GetTeam(), -score )
				AddTeamScore(player.GetTeam(), 0)
			}

		}

		if (!file.testmode)
		{
			if ( alive == 1 )
			{
				entity winner
				foreach (entity player in players)
				{
					if ( IsAlive( player ) )
					{
						winner = player
						break
					}
				}

				// hacky way to set team score
				int score = GameRules_GetTeamScore( winner.GetTeam() )
				AddTeamScore(winner.GetTeam(), -score )
				AddTeamScore(winner.GetTeam(), 150)
			}
		}

	}
}

void function KillLowestScorer_Threaded()
{
	while (true)
	{
		wait 20

		// find lowest scoring player
		int lowestScore = 150 // max score
		entity lowestPlayer

		int alive = 0
		foreach ( player in GetPlayerArray() )
		{
			if ( IsAlive( player ) )
			{
				alive += 1
				if ( GameRules_GetTeamScore( player.GetTeam() ) < lowestScore )
				{
					lowestScore = GameRules_GetTeamScore( player.GetTeam() )
					lowestPlayer = player
				}
			}
		}

		if (alive > 1)
		{
			lowestPlayer.SetHealth(0)
		}
	}
}

void function SpeedOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	string message = victim.GetPlayerName() + " couldn't take the heat."
			foreach ( entity player in GetPlayerArray() )
				SendHudMessage( player, message, -1, 0.4, 255, 0, 0, 0, 0, 3, 0.15 )
		EmitSoundOnEntityOnlyToPlayer (victim, victim, "diag_sp_bossFight_STS676_32_01_imc_viper")


	return
}

void function UpdateLoadout( entity player )
{
	// remove weapons
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	foreach ( entity weapon in player.GetOffhandWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	player.GiveWeapon("mp_weapon_epg",["jump_kit","pas_run_and_gun"])

	foreach ( entity weapon in player.GetMainWeapons() )
	{
		 weapon.SetWeaponPrimaryAmmoCount(0)
	}

	player.GiveWeapon("mp_weapon_semipistol",["silencer"])
	player.GiveOffhandWeapon( "mp_weapon_satchel", OFFHAND_ORDNANCE )
	player.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_SPECIAL )

}

void function OnWinnerDetermined()
{
	SetRespawnsEnabled( false )
	SetKillcamsEnabled( false )
	PlayViperIntro()
}

void function PlayViperIntro()
{
	foreach ( entity player in GetPlayerArray() )
	{
		EmitSoundOnEntityOnlyToPlayer(player,player,"diag_sp_bossFight_STS676_02_01_imc_viper")
	}
}