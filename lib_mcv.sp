#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smmem>
#include <lib_mcv>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME        "Lib MCV"
#define PLUGIN_DESCRIPTION "全新MCV运行库王二代"

public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = "Dr.Abc",
    description = PLUGIN_DESCRIPTION,
    version     = PLUGIN_DESCRIPTION,
    url         = PLUGIN_DESCRIPTION
};

#include "libmcv/zombie.sp"

DynLib g_pServerLib;

// ViewModel
Handle g_hCBaseViewModelGetOwningWeapon;

public int Native_CBaseViewModelGetOwningWeapon(Handle plugin, int args)
{
    int entity = GetNativeCell(1);
    int weapon = SDKCall(g_hCBaseViewModelGetOwningWeapon, entity);
    return weapon;
}
Handle g_hCBasePlayerCreateViewModel;

public int Native_CreatePlayerViewModel(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    int pass   = GetNativeCell(2);
    SDKCall(g_hCBasePlayerCreateViewModel, client, pass);
    return INVALID_ENT_REFERENCE;
}
Handle g_hCBasePlayerGetViewModel;

public int Native_GetPlayerViewModel(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    int pass   = GetNativeCell(2);
    int view   = SDKCall(g_hCBasePlayerGetViewModel, client, pass);
    return view;
}

// Player
Handle g_hCVietnam_PlayerSetModel;

public int Native_CVietnam_PlayerSetModel(Handle plugin, int args)
{
    int clinet = GetNativeCell(1);
    int cmd_length;
    GetNativeStringLength(2, cmd_length);
    cmd_length++;
    char[] cmd = new char[cmd_length];
    GetNativeString(2, cmd, cmd_length);
    SDKCall(g_hCVietnam_PlayerSetModel, clinet, cmd);
    return INVALID_ENT_REFERENCE;
}
Handle g_hCVietnam_PlayerWeapon_Hide;

public int Native_CVietnam_PlayerWeapon_Hide(Handle plugin, int args)
{
    int clinet = GetNativeCell(1);
    int cmd_length;
    GetNativeStringLength(2, cmd_length);
    cmd_length++;
    char[] cmd = new char[cmd_length];
    GetNativeString(2, cmd, cmd_length);
    SDKCall(g_hCVietnam_PlayerWeapon_Hide, clinet, cmd);
    return INVALID_ENT_REFERENCE;
}
Handle g_hCVietnam_PlayerWeapon_Unhide;

public int Native_CVietnam_PlayerWeapon_Unhide(Handle plugin, int args)
{
    int clinet = GetNativeCell(1);
    int cmd_length;
    GetNativeStringLength(2, cmd_length);
    cmd_length++;
    char[] cmd = new char[cmd_length];
    GetNativeString(2, cmd, cmd_length);
    SDKCall(g_hCVietnam_PlayerWeapon_Unhide, clinet, cmd);
    return INVALID_ENT_REFERENCE;
}
// Follow
Handle g_hSetParentAttachment;

public int Native_SetParentAttachment(Handle plugin, int args)
{
    int entity = GetNativeCell(1);
    int cmd_length;
    GetNativeStringLength(2, cmd_length);
    cmd_length++;
    char[] cmd = new char[cmd_length];
    GetNativeString(2, cmd, cmd_length);
    int attach_length;
    GetNativeStringLength(3, attach_length);
    attach_length++;
    char[] attach = new char[attach_length];
    GetNativeString(3, attach, attach_length);
    bool offset = GetNativeCell(4);
    SDKCall(g_hSetParentAttachment, entity, cmd, attach, offset);
    return INVALID_ENT_REFERENCE;
}
Handle g_hCBaseEntityFollowEntity;

public int Native_FollowEntity(Handle plugin, int args)
{
    int  entity = GetNativeCell(1);
    int  follow = GetNativeCell(2);
    bool merge  = GetNativeCell(3);
    SDKCall(g_hCBaseEntityFollowEntity, entity, follow, merge);
    return INVALID_ENT_REFERENCE;
}
Handle g_hCBaseEntityGetFollowedEntity;

public int Native_GetFollowedEntity(Handle plugin, int args)
{
    int entity   = GetNativeCell(1);
    int followed = SDKCall(g_hCBaseEntityGetFollowedEntity, entity);
    return followed;
}
Handle g_hCBaseEntityIsFollowingEntity;

public int Native_IsFollowingEntity(Handle plugin, int args)
{
    int  entity = GetNativeCell(1);
    bool yes    = SDKCall(g_hCBaseEntityIsFollowingEntity, entity);
    return yes;
}
Handle g_hCBaseEntityStopFollowingEntity;

public int Native_StopFollowingEntity(Handle plugin, int args)
{
    int entity = GetNativeCell(1);
    SDKCall(g_hCBaseEntityStopFollowingEntity, entity);
    return INVALID_ENT_REFERENCE;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("MCV_SetParentAttachment", Native_SetParentAttachment);

    CreateNative("MCV_GetPlayerViewModel", Native_GetPlayerViewModel);
    CreateNative("MCV_CreatePlayerViewModel", Native_CreatePlayerViewModel);
    CreateNative("MCV_ViewmodelGetOwningWeapon", Native_CBaseViewModelGetOwningWeapon);

    CreateNative("MCV_FollowEntity", Native_FollowEntity);
    CreateNative("MCV_GetFollowedEntity", Native_GetFollowedEntity);
    CreateNative("MCV_IsFollowingEntity", Native_IsFollowingEntity);
    CreateNative("MCV_StopFollowingEntity", Native_StopFollowingEntity);

    CreateNative("MCV_PlayerSetModel", Native_CVietnam_PlayerSetModel);
    CreateNative("MCV_PlayerWeapon_Hide", Native_CVietnam_PlayerWeapon_Hide);
    CreateNative("MCV_PlayerWeapon_Unhide", Native_CVietnam_PlayerWeapon_Unhide);

    ZM_AskPluginLoad();

    RegPluginLibrary("Lib MCV");
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_pServerLib                = new DynLib("./vietnam/bin/linux64/server");
    Address setparentattachment = g_pServerLib.ResolveSymbol("_ZN11CBaseEntity19SetParentAttachmentEPKcS1_b");
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetAddress(setparentattachment);
    PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
    g_hSetParentAttachment = EndPrepSDKCall();

    Address getviewmodel   = g_pServerLib.ResolveSymbol("_ZNK15CVietnam_Player19GetVietnamViewmodelEi");
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetAddress(getviewmodel);
    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
    PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
    g_hCBasePlayerGetViewModel = EndPrepSDKCall();

    Address getowningweapon    = g_pServerLib.ResolveSymbol("_ZN14CBaseViewModel15GetOwningWeaponEv");
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetAddress(getowningweapon);
    PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
    g_hCBaseViewModelGetOwningWeapon = EndPrepSDKCall();

    Address createviewmodel          = g_pServerLib.ResolveSymbol("_ZN15CVietnam_Player15CreateViewModelEi");
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetAddress(createviewmodel);
    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
    g_hCBasePlayerCreateViewModel = EndPrepSDKCall();

    Address followentity          = g_pServerLib.ResolveSymbol("_ZN11CBaseEntity12FollowEntityEPS_b");
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetAddress(followentity);
    PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
    g_hCBaseEntityFollowEntity = EndPrepSDKCall();

    Address getfollowentity    = g_pServerLib.ResolveSymbol("_ZN11CBaseEntity17GetFollowedEntityEv");
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetAddress(getfollowentity);
    PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
    g_hCBaseEntityGetFollowedEntity = EndPrepSDKCall();

    Address isfollowedentity        = g_pServerLib.ResolveSymbol("_ZN11CBaseEntity17IsFollowingEntityEv");
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetAddress(isfollowedentity);
    PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
    g_hCBaseEntityIsFollowingEntity = EndPrepSDKCall();

    Address stopfollowingentity     = g_pServerLib.ResolveSymbol("_ZN11CBaseEntity19StopFollowingEntityEv");
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetAddress(stopfollowingentity);
    g_hCBaseEntityStopFollowingEntity = EndPrepSDKCall();

    Address cvietname_playersetmodel  = g_pServerLib.ResolveSymbol("_ZN15CVietnam_Player8SetModelEPKc");
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetAddress(cvietname_playersetmodel);
    PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
    g_hCVietnam_PlayerSetModel         = EndPrepSDKCall();

    Address cvietname_playerweaponhide = g_pServerLib.ResolveSymbol("_ZN15CVietnam_Player11Weapon_HideEPKc");
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetAddress(cvietname_playerweaponhide);
    PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
    g_hCVietnam_PlayerWeapon_Hide        = EndPrepSDKCall();

    Address cvietname_playerweaponunhide = g_pServerLib.ResolveSymbol("_ZN15CVietnam_Player13Weapon_UnhideEPKc");
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetAddress(cvietname_playerweaponunhide);
    PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
    g_hCVietnam_PlayerWeapon_Unhide = EndPrepSDKCall();

    ZM_OnPluginStart();
}

public void OnPluginEnd()
{
    g_pServerLib.Close();

    g_hCBaseViewModelGetOwningWeapon.Close();
    g_hCBasePlayerCreateViewModel.Close();
    g_hCBasePlayerGetViewModel.Close();
    g_hCVietnam_PlayerSetModel.Close();
    g_hCVietnam_PlayerWeapon_Hide.Close();
    g_hCVietnam_PlayerWeapon_Unhide.Close();
    g_hSetParentAttachment.Close();
    g_hCBaseEntityFollowEntity.Close();
    g_hCBaseEntityGetFollowedEntity.Close();
    g_hCBaseEntityIsFollowingEntity.Close();
    g_hCBaseEntityStopFollowingEntity.Close();

    ZM_OnPluginEnd();
}

public void OnMapInit(const char[] mapName)
{
    ZM_OnMapInit();
}

public void OnEntityCreated(int entity, const char[] classname)
{
    ZM_OnEntityCreated(entity, classname);
}

public void OnEntityDestroyed(int entity)
{
    ZM_OnEntityDestroyed(entity);
}