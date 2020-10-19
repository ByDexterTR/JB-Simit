#include <sourcemod>
#include <warden>
#include <voiceannounce_ex>
#include <multicolors>
#include <emitsoundany>
#include <cstrike>
#pragma semicolon 1
#pragma newdecls required
public Plugin myinfo = 
{
	name = "Simit", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};
ConVar g_Komutcucan;
bool SimitAktif, Konusuyor;
public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStartEnd);
	HookEvent("round_end", Event_RoundStartEnd);
	HookEvent("player_death", Event_OnPlayerDeath);
	RegConsoleCmd("sm_simit", SimitOyun);
	g_Komutcucan = CreateConVar("sm_simit_can", "100", "Yaşayan T sayısına göre çarpılıp verilecek can");
	AutoExecConfig(true, "Simit", "ByDexter");
}
public void OnMapStart()
{
	PrecacheSoundAny("dexter/simit/godaktif.mp3");
	AddFileToDownloadsTable("sound/dexter/simit/godaktif.mp3");
	PrecacheSoundAny("dexter/simit/godkapat.mp3");
	AddFileToDownloadsTable("sound/dexter/simit/godkapat.mp3");
}
public Action Event_RoundStartEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (SimitAktif)
	{
		CPrintToChatAll("{darkred}[ByDexter] {default}Tur başladığı/sona erdiği için {green}oyun bitti");
		SimitAktif = false;
		Konusuyor = false;
	}
}
public Action Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (SimitAktif)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if (warden_iswarden(client))
		{
			CPrintToChatAll("{darkred}[ByDexter] {default}Komutçunun yaşamına son verildiği için {green}oyunu kaybetti!");
			SimitAktif = false;
			Konusuyor = false;
		}
	}
}
public Action SimitOyun(int client, int args)
{
	if (warden_iswarden(client))
	{
		if (!SimitAktif)
		{
			int T_Sayisi = 0;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
				{
					if (GetClientTeam(i) == CS_TEAM_T)
					{
						T_Sayisi++;
					}
				}
			}
			SetEntityHealth(client, g_Komutcucan.IntValue * T_Sayisi);
			SimitAktif = true;
			Konusuyor = false;
			CPrintToChatAll("{darkred}[ByDexter] {darkblue}%N {default}tarafından simit oyunu {green}başladı!", client);
			return Plugin_Handled;
		}
		else
		{
			if (IsPlayerAlive(client))
			{
				SetEntityHealth(client, 100);
			}
			SimitAktif = false;
			Konusuyor = false;
			CPrintToChatAll("{darkred}[ByDexter] {darkblue}%N {default}tarafından simit oyunu {green}iptal edildi!", client);
			return Plugin_Handled;
		}
	}
	else if (!warden_iswarden(client))
	{
		CReplyToCommand(client, "{darkred}[ByDexter] {default}Bu komuta erişiminiz yok!");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}
public void OnClientSpeakingEx(int client)
{
	if (SimitAktif && warden_iswarden(client) && !Konusuyor)
	{
		Konusuyor = true;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
			{
				EmitSoundToClientAny(i, "dexter/simit/godaktif.mp3", SOUND_FROM_PLAYER, 1, 100);
			}
		}
		SetEntityRenderMode(client, RENDER_GLOW);
		SetEntityRenderColor(client, 0, 255, 0, 255);
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		CPrintToChatAll("{darkred}[ByDexter] {default}Komutçu artık {green}ölümsüz {darkblue}KAÇIN !!!");
	}
}
public void OnClientSpeakingEnd(int client)
{
	if (SimitAktif && warden_iswarden(client) && Konusuyor)
	{
		Konusuyor = false;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && !IsFakeClient(i))
			{
				EmitSoundToClientAny(i, "dexter/simit/godkapat.mp3", SOUND_FROM_PLAYER, 1, 100);
			}
		}
		SetEntityRenderMode(client, RENDER_NORMAL);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		CPrintToChatAll("{darkred}[ByDexter] {default}Komutçu artık {green}ölümsüz değil {darkblue}SALDIRIN !!!");
	}
}
