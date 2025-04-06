// 玩家金币维护
// undefined4 __thiscall CVietnam_Player::GetCredits(CVietnam_Player *this)
// {
//   return *(undefined4 *)(this + 0x21d8);
// }
public int Native_GetMoney(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    if (MCV_IsClientValid(client))
    {
        int money = GetEntData(client, 0x21d8);
        return money;
    }
    return INVALID_ENT_REFERENCE;
}

public int Native_SetMoney(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    if (MCV_IsClientValid(client))
    {
        int money = GetNativeCell(2);
        SetEntData(client, 0x21d8, money);
    }
    return INVALID_ENT_REFERENCE;
}

public int Native_AddMoney(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    if (MCV_IsClientValid(client))
    {
        int money = GetEntData(client, 0x21d8);
        int add   = GetNativeCell(2);
        SetEntData(client, 0x21d8, money + add);
    }
    return INVALID_ENT_REFERENCE;
}

// 玩家重量维护
// undefined4 __thiscall CVietnam_Player::GetCarriedWeaponsWeight(CVietnam_Player *this)
//{
//  return *(undefined4 *)(this + 0x21dc);
//}
public int Native_GetWeight(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    if (MCV_IsClientValid(client))
    {
        int weight = GetEntData(client, 0x21dc);
        return weight;
    }
    return INVALID_ENT_REFERENCE;
}

public int Native_SetWeight(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    if (MCV_IsClientValid(client))
    {
        int weight = GetNativeCell(2);
        SetEntData(client, 0x21dc, weight);
    }
    return INVALID_ENT_REFERENCE;
}

public int Native_AddWeight(Handle plugin, int args)
{
    int client = GetNativeCell(1);
    if (MCV_IsClientValid(client))
    {
        int weight = GetEntData(client, 0x21dc);
        int add    = GetNativeCell(2);
        SetEntData(client, 0x21dc, weight + add);
    }
    return INVALID_ENT_REFERENCE;
}

// 僵尸列表维护及僵尸Spawn Forward
ArrayList g_aryZombies;

public int Native_GetZombieCount(Handle plugin, int args)
{
    return g_aryZombies.Length;
}

public int Native_GetZombieByIndex(Handle plugin, int args)
{
    int index = GetNativeCell(1);
    if (index >= g_aryZombies.Length)
        return INVALID_ENT_REFERENCE;
    int zombie = g_aryZombies.Get(index);
    return zombie;
}

GlobalForward g_pZombieSpawnForward;
GlobalForward g_pZombieDestoryForward;

public void ZombieSpawn_Post(int entity)
{
    Call_StartForward(g_pZombieSpawnForward);
    Call_PushCell(entity);
    Call_Finish();
}

public void ZombieDestory(int entity)
{
    Call_StartForward(g_pZombieDestoryForward);
    Call_PushCell(entity);
    Call_Finish();
}

GlobalForward g_pPhaseChangedForward;
//僵尸状态维护
Action        Event_PhaseChange(Handle event, const char[] name, bool dontBroadcast)
{
    // 0 = buy time
    // 1 = fight time
    int phase = GetEventInt(event, "phase");

    Call_StartForward(g_pPhaseChangedForward);
    Call_PushCell(phase);
    Call_Finish();

    return Plugin_Continue;
}
// 僵尸死亡forward
GlobalForward g_pZombieKilledForward;
GlobalForward g_pZombieKilledPostForward;
Action        Event_ZombieKilled(Handle event, const char[] name, bool dontBroadcast)
{
    char othertype[64];
    GetEventString(event, "othertype", othertype, sizeof(othertype));
    if (!strncmp(othertype, "nb_zombie", 9))
    {
        int  zombie   = GetEventInt(event, "otherid");
        int  attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
        char weaponname[64];
        GetEventString(event, "weapon", weaponname, sizeof(weaponname));
        char weapon_itemid[64];
        GetEventString(event, "weapon_itemid", weapon_itemid, sizeof(weapon_itemid));
        int   damagebits   = GetEventInt(event, "damagetype");
        bool  headshot     = GetEventBool(event, "headshot");
        bool  backblast    = GetEventBool(event, "backblast");
        int   penetrated   = GetEventInt(event, "penetrated");
        float killdistance = GetEventFloat(event, "killdistance");

        Call_StartForward(g_pZombieKilledForward);
        Call_PushCell(zombie);
        Call_PushString(othertype);
        Call_PushCell(attacker);
        Call_PushString(weaponname);
        Call_PushString(weapon_itemid);
        Call_PushCell(damagebits);
        Call_PushCell(headshot);
        Call_PushCell(backblast);
        Call_PushCell(penetrated);
        Call_PushCell(killdistance);
        Call_Finish();

        Call_StartForward(g_pZombieKilledPostForward);
        Call_PushCell(zombie);
        Call_PushStringEx(othertype, sizeof(othertype), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
        Call_PushCell(attacker);
        Call_PushStringEx(weaponname, sizeof(weaponname), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
        Call_PushStringEx(weapon_itemid, sizeof(weapon_itemid), SM_PARAM_STRING_UTF8 | SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
        Call_PushCell(damagebits);
        Call_PushCell(headshot);
        Call_PushCell(backblast);
        Call_PushCell(penetrated);
        Call_PushCell(killdistance);
        Call_Finish();

        SetEventString(event, "othertype", othertype);
        SetEventString(event, "weapon", weaponname);
        SetEventString(event, "weapon_itemid", weapon_itemid);
    }
    return Plugin_Continue;
}

// 僵尸受伤forward
GlobalForward g_pZombieHurtForward;
Action        Event_ZombieHurt(Handle event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    if (userid == -1)
    {
        int  attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
        int  health   = GetEventInt(event, "health");
        int  armor    = GetEventInt(event, "armor");
        char weapon[64];
        GetEventString(event, "weapon", weapon, sizeof(weapon));
        int dmg_health = GetEventInt(event, "dmg_health");
        int dmg_armor  = GetEventInt(event, "dmg_armor");
        int hitgroup   = GetEventInt(event, "hitgroup");
        int damagetype = GetEventInt(event, "damagetype");

        Call_StartForward(g_pZombieHurtForward);
        Call_PushCell(attacker);
        Call_PushCell(health);
        Call_PushCell(armor);
        Call_PushString(weapon);
        Call_PushCell(dmg_health);
        Call_PushCell(dmg_armor);
        Call_PushCell(hitgroup);
        Call_PushCell(damagetype);
        Call_Finish();
    }
    return Plugin_Continue;
}

//金币创建及PickupForward
ArrayList g_aryCashes;

public int Native_GetCashCount(Handle plugin, int args)
{
    return g_aryCashes.Length;
}

public int Native_GetCashByIndex(Handle plugin, int args)
{
    int index = GetNativeCell(1);
    if (index >= g_aryCashes.Length)
        return INVALID_ENT_REFERENCE;
    int c = g_aryCashes.Get(index);
    return c;
}
GlobalForward g_pCashPickupForward;
GlobalForward g_pCashSpawnedForward;
Action        OnCashTouched(int entity, int other)
{
    if (MCV_IsClientValid(other))
    {
        Call_StartForward(g_pCashPickupForward);
        Call_PushCell(entity);
        Call_PushCell(other);
        Call_Finish();
    }
    return Plugin_Continue;
}

public void CashSpawn_Post(int entity)
{
    Call_StartForward(g_pCashSpawnedForward);
    Call_PushCell(entity);
    Call_Finish();
}

// native int ZM_CreateCash(int owner, int count, const float[] org,
//                           const float[] ang, const float[] vec)
public int Native_CreateCash(Handle plugin, int args)
{
    float org[3];
    GetNativeArray(1, org, 3);
    float ang[3];
    GetNativeArray(2, ang, 3);
    float vec[3];
    GetNativeArray(3, vec, 3);

    int cash = CreateEntityByName("item_money");
    DispatchSpawn(cash);
    TeleportEntity(cash, org, ang, vec);
    return cash;
}

// 僵尸wave
public int Native_GetWaveNum(Handle plugin, int args)
{
    return GameRules_GetProp("m_iWaveNum");
}

public int Native_SetWaveNum(Handle plugin, int args)
{
    int wave = GetNativeCell(1);
    GameRules_SetProp("m_iWaveNum", wave);
    return INVALID_ENT_REFERENCE;
}

//僵尸剩余
public int Native_GetReaminingEnemies(Handle plugin, int args)
{
    return GameRules_GetProp("m_iNumEnemiesRemaining");
}

public int Native_SetReaminingEnemies(Handle plugin, int args)
{
    int enemy = GetNativeCell(1);
    GameRules_SetProp("m_iNumEnemiesRemaining", enemy);
    return INVALID_ENT_REFERENCE;
}

// Basic forward
void ZM_ClearCache()
{
    for (int i = 0; i < g_aryZombies.Length; i++)
    {
        int z = g_aryZombies.Get(i);
        SDKUnhook(z, SDKHook_SpawnPost, ZombieSpawn_Post);
    }
    for (int i = 0; i < g_aryCashes.Length; i++)
    {
        int z = g_aryCashes.Get(i);
        SDKUnhook(z, SDKHook_Touch, OnCashTouched);
    }
    g_aryCashes.Clear();
    g_aryZombies.Clear();
}

void ZM_OnEntityCreated(int entity, const char[] classname)
{
    if (!strncmp(classname, "nb_zombie", 9, false))
    {
        int index = g_aryZombies.FindValue(entity);
        if (index != -1)
            g_aryZombies.Erase(index);
        g_aryZombies.Push(entity);
        SDKHook(entity, SDKHook_SpawnPost, ZombieSpawn_Post);
    }
    else if (!strcmp(classname, "item_money"))
    {
        int index = g_aryCashes.FindValue(entity);
        if (index != -1)
            g_aryCashes.Erase(index);
        g_aryCashes.Push(entity);
        SDKHook(entity, SDKHook_Touch, OnCashTouched);
        SDKHook(entity, SDKHook_SpawnPost, CashSpawn_Post);
    }
}

void ZM_OnEntityDestroyed(int entity)
{
    int z = g_aryZombies.FindValue(entity);
    if (z != -1)
    {
        SDKUnhook(entity, SDKHook_SpawnPost, ZombieSpawn_Post);
        g_aryZombies.Erase(z);
        ZombieDestory(entity);
    }

    int c = g_aryCashes.FindValue(entity);
    if (c != -1)
    {
        g_aryCashes.Erase(c);
        SDKUnhook(entity, SDKHook_Touch, OnCashTouched);
        SDKUnhook(entity, SDKHook_SpawnPost, CashSpawn_Post);
    }
}

void ZM_AskPluginLoad()
{
    CreateNative("ZM_GetMoney", Native_GetMoney);
    CreateNative("ZM_SetMoney", Native_SetMoney);
    CreateNative("ZM_AddMoney", Native_AddMoney);

    CreateNative("ZM_GetWeight", Native_GetWeight);
    CreateNative("ZM_SetWeight", Native_SetWeight);
    CreateNative("ZM_AddWeight", Native_AddWeight);

    CreateNative("ZM_GetZombieCount", Native_GetZombieCount);
    CreateNative("ZM_GetZombieByIndex", Native_GetZombieByIndex);

    CreateNative("ZM_GetCashCount", Native_GetCashCount);
    CreateNative("ZM_GetCashByIndex", Native_GetCashByIndex);
    CreateNative("ZM_CreateCash", Native_CreateCash);

    CreateNative("ZM_GetWaveNum", Native_GetWaveNum);
    CreateNative("ZM_SetWaveNum", Native_SetWaveNum);

    CreateNative("ZM_GetReaminingEnemies", Native_GetReaminingEnemies);
    CreateNative("ZM_SetReaminingEnemies", Native_SetReaminingEnemies);
}

void ZM_OnPluginStart()
{
    g_aryZombies               = new ArrayList();
    g_aryCashes                = new ArrayList();

    g_pZombieSpawnForward      = new GlobalForward("OnZombieSpawned", ET_Ignore, Param_Cell);
    g_pZombieDestoryForward    = new GlobalForward("OnZombieDestoryed", ET_Ignore, Param_Cell);

    g_pPhaseChangedForward     = new GlobalForward("OnZombiePhaseChanged", ET_Ignore, Param_Cell);

    g_pZombieHurtForward       = new GlobalForward("OnZombieHurt", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_String,
                                                   Param_Cell, Param_Cell, Param_Cell, Param_Cell);

    g_pZombieKilledForward     = new GlobalForward("OnZombieKilled", ET_Ignore, Param_Cell, Param_String, Param_Cell,
                                                   Param_String, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
    g_pZombieKilledPostForward = new GlobalForward("OnZombieKilledPost", ET_Ignore, Param_Cell, Param_String, Param_Cell,
                                                   Param_String, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
    g_pCashPickupForward       = new GlobalForward("OnMoneyPickup", ET_Ignore, Param_Cell, Param_Cell);
    g_pCashSpawnedForward      = new GlobalForward("OnMoneySpawned", ET_Ignore, Param_Cell);
    HookEvent("zm_phase_change", Event_PhaseChange, EventHookMode_Pre);
    HookEvent("other_death", Event_ZombieKilled, EventHookMode_Pre);
    HookEvent("character_hurt", Event_ZombieHurt, EventHookMode_Post);
}

void ZM_OnMapInit()
{
    ZM_ClearCache();
}

void ZM_OnPluginEnd()
{
    ZM_ClearCache();

    g_aryZombies.Close();
    g_aryCashes.Close();
    g_pZombieSpawnForward.Close();
    g_pZombieDestoryForward.Close();

    g_pPhaseChangedForward.Close();

    g_pZombieHurtForward.Close();

    g_pZombieKilledForward.Close();
    g_pZombieKilledPostForward.Close();

    g_pCashPickupForward.Close();
    g_pCashSpawnedForward.Close();

    UnhookEvent("zm_phase_change", Event_PhaseChange, EventHookMode_Pre);
    UnhookEvent("other_death", Event_ZombieKilled, EventHookMode_Pre);
    UnhookEvent("character_hurt", Event_ZombieHurt, EventHookMode_Post);
}