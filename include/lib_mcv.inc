#if defined _MCVLibrary_included
    #endinput
#endif
#define _MCVLibrary_included

#include <sdktools>
#include <libmcv/zombie>

/**
 * Is player valid?
 *
 * @param client client index
 * @return true or false
 */
stock bool MCV_IsClientValid(int client)
{
    if (!IsValidEntity(client))
        return false;
    if (client <= 0 || client > MaxClients)
        return false;
    if (!IsClientInGame(client))
        return false;
    return true;
}

/**
 * SetParent
 * @param entity entity
 * @param parent parent
 */
stock void MCV_SetParent(int entity, int parent)
{
    SetEntDataEnt2(entity, 0x168, parent);
}
/**
 * GetParent
 * @param entity entity
 * @return parent
 */
stock int MCV_GetParent(int entity)
{
    return GetEntData(entity, 0x168);
}
/**
 * GetParent
 * @param entity entity
 * @return model index
 */
stock int MCV_GetModelIndex(int entity)
{
    return GetEntData(entity, 0x14a);
}
/**
 * SetParentAttachment
 * @param entity entity
 * @param szInputName input name
 * @param szAttachment point
 * @param bMaintainOffset mantian offset
 */
native void MCV_SetParentAttachment(int entity, char[] szInputName, char[] szAttachment, bool bMaintainOffset);

/**
 * SetParentAttachment
 * @param player player
 * @param view view model idnex, 0~2
 * @return vietnam_view model entity index
 */
native int  MCV_GetPlayerViewModel(int player, int view);

/**
 * CreateParentAttachment
 * @param player player
 * @param view view model idnex, 0~2
 */
native void MCV_CreatePlayerViewModel(int player, int view);

/**
 * CBaseEntity::FollowEntity
 * @param entity entity
 * @param follow follow
 * @param mergebone merge bone
 */
native void MCV_FollowEntity(int entity, int follow, bool mergebone);

/**
 * CBaseEntity::GetFollowedEntity
 * @param entity entity
 * @return followed entity
 */
native int  MCV_GetFollowedEntity(int entity);

/**
 * CBaseEntity::IsFollowingEntity
 * @param entity entity
 * @return yes or no
 */
native bool MCV_IsFollowingEntity(int entity);

/**
 * CBaseEntity::StopFollowingEntity
 * @param entity entity
 */
native void MCV_StopFollowingEntity(int entity);

/**
 * CVietnam_Player::SetModel
 * @param entity entity
 */
native void MCV_PlayerSetModel(int client, char[] model);

public SharedPlugin __pl_lib_mcv = {
    name = "Lib MCV",
    file = "lib_mcv.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};
