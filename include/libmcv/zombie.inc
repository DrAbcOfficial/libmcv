#if defined _MCVLibraryZombie_included
    #endinput
#endif
#define _MCVLibraryZombie_included

/**
 * Get Client Money
 *
 * @param client Client index
 * @return client money
 * @error Invalid client.
 */
native int  ZM_GetMoney(int client);
/**
 * Set Client Money
 *
 * @param client Client index
 * @param money money
 * @error Invalid client.
 */
native void ZM_SetMoney(int client, int money);
/**
 * Add Client Money
 *
 * @param client Client index
 * @param money money
 * @error Invalid client.
 */
native void ZM_AddMoney(int client, int money);

/**
 * Get Client Weight
 *
 * @param client Client index
 * @return client weight
 * @error Invalid client.
 */
native int  ZM_GetWeight(int client);
/**
 * Set Client Money
 *
 * @param client Client index
 * @param Weight Weight
 * @error Invalid client.
 */
native void ZM_SetWeight(int client, int weight);
/**
 * Add Client Money
 *
 * @param client Client index
 * @param Weight Weight
 * @error Invalid client.
 */
native void ZM_AddWeight(int client, int weight);

/**
 * Get Zombie Count
 *
 * @return Zombie Count
 */
native int  ZM_GetZombieCount();

/**
 * Get Zombie By Index
 *
 * @param index zombie index
 * @return zombie entity index
 * @error Invalid index.
 */
native int  ZM_GetZombieByIndex(int index);

#define ZM_PHASE_WAITING 0
#define ZM_PHASE_COMBAT  1

forward void OnZombiePhaseChanged(int phase);

/**
 * Get now game phase
 *
 * @return phase ZM_PHASE_WAITING or ZM_PHASE_COMBAT
 */
stock int    ZM_GetCurrentPhase()
{
    return GameRules_GetProp("m_iZM_CurrentPhase");
}

/**
 * Get cash entity count
 *
 * @return zombie entity index
 */
native int   ZM_GetCashCount();
/**
 * Get Case entity By Index
 *
 * @param index Case index
 * @return cash entity index
 * @error Invalid index.
 */
native int   ZM_GetCashByIndex(int index);
/**
 * Create cash entity
 *
 * @param org origin
 * @param ang angles
 * @param vec velocity
 * @return cash entity index
 */
native int   ZM_CreateCash(const float org[3],
                           const float ang[3], const float vec[3]);

/**
 * Get current wave num
 *
 * @return wave num
 */
native int   ZM_GetWaveNum();
/**
 * Set current wave num
 *
 * @param num wave
 */
native void  ZM_SetWaveNum(int num);

/**
 * Get current enemies remaining
 *
 * @return enemies num
 */
native int   ZM_GetReaminingEnemies();
/**
 * Set current enemies remaining
 *
 * @param enemies wave
 */
native void  ZM_SetReaminingEnemies(int num);

forward void OnZombieSpawned(int zombie);

forward void OnZombieDestoryed(int zombie);

forward void OnZombieHurt(int attacker, int health, int armor, char[] weapon, int dmg_health, int dmg_armor, int hitgroup, int damagetype);

forward void OnZombieKilled(int zombie, char[] classname, int attacker, char[] weapon_name,
                            char[] weapon_id, int damagebits, bool headshot, bool backblast,
                            int penetrated, float killdistance);
forward void OnZombieKilledPost(int zombie, char[] classname, int attacker, char[] weapon_name,
                                char[] weapon_id, int damagebits, bool headshot, bool backblast,
                                int penetrated, float killdistance);
forward void OnMoneyPickup(int cash, int other);
forward void OnMoneySpawned(int cash);

#define ZOMBIE_TYPE_INVALID  -1
#define ZOMBIE_TYPE_CROW     0
#define ZOMBIE_TYPE_NORNAML  1
#define ZOMBIE_TYPE_ARMOR    2
#define ZOMBIE_TYPE_BLOAT    3
#define ZOMBIE_TYPE_DOG      4
#define ZOMBIE_TYPE_SLASHER  5
#define ZOMBIE_TYPE_BURNING  6
#define ZOMBIE_TYPE_RANGED   7
#define ZOMBIE_TYPE_BOMBER   8
#define ZOMBIE_TYPE_SCREAMER 9
#define ZOMBIE_TYPE_GUN      10
#define ZOMBIE_TYPE_BUFFALO  11
#define ZOMBIE_TYPE_ORANGE   12
#define ZOMBIE_TYPE_HAVOC    13

/**
 * get zombie type by entity
 *
 * @param zombie zombie index
 * @return zombie type, ZOMBIE_TYPE_INVALID for invalid
 */
// this is stupid
stock int ZM_GetZombieType(int zombie)
{
    if (!IsValidEntity(zombie))
        return ZOMBIE_TYPE_INVALID;
    // Get type
    //  vtable + 0xBB0
    //  uint64 CBaseZombieCharacter::GetZombieType()
    //  fuck, sdk call is invalid for mcv, i cant call virtual function directly
    char buffer[64];
    GetEntityClassname(zombie, buffer, sizeof(buffer));
    if (!strcmp(buffer, "nb_zombie"))
        return ZOMBIE_TYPE_NORNAML;
    else if (!strcmp(buffer, "nb_zombie_armor"))
        return ZOMBIE_TYPE_ARMOR;
    else if (!strcmp(buffer, "nb_zombie_bloat"))
        return ZOMBIE_TYPE_BLOAT;
    else if (!strcmp(buffer, "nb_zombie_bomber"))
        return ZOMBIE_TYPE_BOMBER;
    else if (!strcmp(buffer, "nb_zombie_buffalo"))
        return ZOMBIE_TYPE_BUFFALO;
    else if (!strcmp(buffer, "nb_zombie_burning"))
        return ZOMBIE_TYPE_BURNING;
    else if (!strcmp(buffer, "nb_zombie_crow"))
        return ZOMBIE_TYPE_CROW;
    else if (!strcmp(buffer, "nb_zombie_dog"))
        return ZOMBIE_TYPE_DOG;
    else if (!strcmp(buffer, "nb_zombie_gun"))
        return ZOMBIE_TYPE_GUN;
    else if (!strcmp(buffer, "nb_zombie_havoc"))
        return ZOMBIE_TYPE_HAVOC;
    else if (!strcmp(buffer, "nb_zombie_orange"))
        return ZOMBIE_TYPE_ORANGE;
    else if (!strcmp(buffer, "nb_zombie_ranged"))
        return ZOMBIE_TYPE_RANGED;
    else if (!strcmp(buffer, "nb_zombie_screamer"))
        return ZOMBIE_TYPE_SCREAMER;
    else if (!strcmp(buffer, "nb_zombie_slasher"))
        return ZOMBIE_TYPE_SLASHER;
    return ZOMBIE_TYPE_INVALID;
}