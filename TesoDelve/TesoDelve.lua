
local function isempty(s)
    return s == nil or s == ''
end

local function loadTesoDelve(eventCode, addOnName)

    if(addOnName == "TesoDelve") then


        local defaults =
        {
            a_characters = {},
            inventory = {},
            smithing = {},
            itemStyles = {},
            settings = {},
            guilds = {},
            gMembers = {},
            skills = {},
        }

        local tdVersion = "1.0.12";

        local savedVars = ZO_SavedVars:NewAccountWide("TesoDelve", 1, nil, defaults)
        local characterId = GetCurrentCharacterId()
        local itemsExported = 0

        if(savedVars.a_characters == nil) then
            savedVars.a_caracters = {}
        end

        if(savedVars.smithing == nil) then
            savedVars.smithing = {}
        end

        if(savedVars.itemStyles == nil) then
            savedVars.itemStyles = {}
        end

        if(savedVars.guilds == nil) then
            savedVars.guilds = {}
        end

        if(savedVars.inventory[characterId] == nil) then
            savedVars.inventory[characterId] = {}
        end

        if(savedVars.skills[characterId] == nil) then
            savedVars.skills[characterId] = {}
        end

        if(savedVars.settings[characterId] == nil) then
            savedVars.settings[characterId] = {}
        end

        if(savedVars.settings['export-all-skills'] == nil)then
            savedVars.settings['export-all-skills'] = 0
        end

        if(savedVars.settings['mute'] == nil) then
            savedVars.settings['mute'] = 0
        end

        savedVars['td-version'] = "TD-VERSION;--;"..tdVersion..";--;";

        local isMuted = savedVars.settings['mute']

        local function exportGuilds()
            if(type(savedVars.gMembers) == 'table') then
                savedVars.gMembers = {}
            end

            local guilds = {}

            for i=1, GetNumGuilds(), 1 do
                local guild_id = GetGuildId(i)
                local guildInfo = {GetGuildInfo(guild_id)}

                local guild = {
                    GetGuildName(guild_id),
                    'null',
                    'null',
                    GetGuildFoundedDate(guild_id),
                    membersCount,
                    GetWorldName(),
                    GetDisplayName(),
                    guild_id,
                    GetGuildOwnedKioskInfo(guild_id),
                    guildInfo[3],
                    GetGuildAlliance(guild_id),
                }

                table.insert(guilds, "GUILD:;--;"..table.concat(guild, ';--;') .. ";--;")
            end

            savedVars.guilds = guilds
        end

        local function exportItemsStyle()

            local itemStyles = {}

            for i=1, GetNumSmithingStyleItems() do
                local styleInfo = {GetSmithingStyleItemInfo(i)}
                local smithingStyleItemCount = GetCurrentSmithingStyleItemCount()
                local export = false

                local chapters = {
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_ALL)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_AXE)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_BELTS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_BOOTS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_BOWS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_CHESTS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_DAGGERS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_GLOVES)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_HELMETS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_LEGS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_MACES)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_SHIELDS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_SHOULDERS)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_STAVES)),
                    tostring(IsSmithingStyleKnown(i, ITEM_STYLE_CHAPTER_SWORDS)),
                }

                for index, value in ipairs (chapters) do
                    if value == 'true' then
                        export = true
                    end
                end


                local itemStyleDump = {
                    characterId,
                    i,
                    styleInfo[1],
                    styleInfo[2],
                    styleInfo[5],
                    smithingStyleItemCount,
                    table.concat(chapters, '-'),
                    GetCVar("language.2"),
                }

                if(export) then
                    table.insert(itemStyles, 'ITEMSTYLE:;'..table.concat(itemStyleDump, ';'))
                end
            end

            if isMuted == 0 then
                d('TesoDelve: exported known motifs')
            end


            savedVars.itemStyles[characterId] = itemStyles
        end

        local function exportItem(bagSpace, index)
            local backPackNumber = bagSpace

            -- Merge the new BAG_SUBSCRIBER_BANK with the old bank bag per morrowind
            if(bagSpace == BAG_SUBSCRIBER_BANK) then
                backPackNumber = BAG_BANK
            end


            local itemName = GetItemName(bagSpace, index)
            if string.len(itemName) >= 1 then
                local uniqueId = GetItemUniqueId(bagSpace, index)
                local itemTrait = GetItemTrait(bagSpace, index)
                local itemStatValue = GetItemStatValue(bagSpace, index)
                local itemArmorType = GetItemArmorType(bagSpace, index)
                local itemType = {GetItemType(bagSpace, index)}
                local weaponType = GetItemWeaponType(bagSpace, index)
                local totalCount = GetSlotStackSize(bagSpace, index)
                local itemLink = GetItemLink(bagSpace, index)
                local itemInfo =  {GetItemInfo(bagSpace, index) }
                local itemPlayerLocked = IsItemPlayerLocked(bagSpace, index)
                local quality = GetItemLinkQuality(itemLink)
                local setInfo =  {GetItemLinkSetInfo(itemLink, true) }
                local enchantInfo = {GetItemLinkEnchantInfo(itemLink) }
                local championPoints = GetItemRequiredChampionPoints(bagSpace, index)
                local itemLevel = GetItemRequiredLevel(bagSpace, index)
                local itemBound = IsItemBound(bagSpace, index)
                local isJunk = IsItemJunk(bagSpace, index)
                local traitDescription =  {GetItemLinkTraitInfo(itemLink) }

                local item = {
                    uniqueId, -- Unique ID
                    itemName, -- Name
                    itemTrait, -- Trait
                    itemInfo[6], -- EquipType
                    setInfo[2], -- SetName
                    quality, -- Quality
                    itemArmorType, -- Heavy/Medium/Light armor
                    tostring(itemPlayerLocked), -- Locked?
                    enchantInfo[2], -- ItemLink enchant
                    itemInfo[1], -- icon,
                    itemType[1], -- Itemtype /armor/jewelry/weapon etc
                    championPoints, -- cp needed
                    itemLevel, -- level neeeded
                    weaponType, -- Weapontype axe/dagger/bow etc
                    characterId, -- characters unique id
                    backPackNumber, -- space enum, to see if it's a bank item
                    tostring(itemBound),
                    totalCount,
                    tostring(isJunk),
                    itemLink,
                    enchantInfo[3],
                    traitDescription[2],
                    itemStatValue,
                    i,
                    itemType[2], -- SpecializedItemType http://wiki.esoui.com/Globals#SpecializedItemType
                    itemInfo[7], -- ItemStyle
                    GetCVar("language.2"), -- Client language
                }

                return "ITEM:"..table.concat(item, ';')..";"
            end
        end

        local function exportSmithing()
            local smithingTypes = { CRAFTING_TYPE_BLACKSMITHING, CRAFTING_TYPE_CLOTHIER, CRAFTING_TYPE_WOODWORKING}

            local timers = {}
            for s=1,#smithingTypes do
                for i=1, GetNumSmithingResearchLines(smithingTypes[s]) do
                    local _,_, numTraits = GetSmithingResearchLineInfo(smithingTypes[s], i)
                    local researchLineInfo = {GetSmithingResearchLineInfo(smithingTypes[s], i)}
                    for t=1, numTraits do
                        local dur, remainig = GetSmithingResearchLineTraitTimes(smithingTypes[s], i, t)
                        local traitInfo = {GetSmithingResearchLineTraitInfo(smithingTypes[s], i, t) }
                        local export = false

                        local smithingDump = {
                            characterId,
                            tostring(remainig),
                            smithingTypes[s],
                            i,
                            t,
                            tostring(dur),
                            traitInfo[1],
                            tostring(traitInfo[2]),
                            tostring(traitInfo[3]),
                            tostring(researchLineInfo[1]),
                            tostring(researchLineInfo[2]),
                            tostring(researchLineInfo[4]),
                            GetTimeStamp(),
                            GetCVar("language.2"),
                        }

                        if not isempty(remainig) then
                            export = true
                        end

                        if traitInfo[3] then
                            export = true;
                        end

                        if export then
                            table.insert(timers, 'SMITHING:;'..table.concat(smithingDump, ';'))
                        end
                    end
                end
            end

            savedVars.smithing[characterId] = timers
        end

        local function exportInventory(bagSpace)
            local backPackSize = GetBagSize(bagSpace)
            local inventory = {}


            for i=0, backPackSize+1, 1 do
                itemsExported = itemsExported + 1
                inventory['BAG-' .. i] = exportItem(bagSpace, i)
            end


            if(bagSpace == BAG_BANK) then
                savedVars.inventory['bank'] = {}
                savedVars.inventory['bank'] = inventory
            elseif(bagSpace == BAG_SUBSCRIBER_BANK) then
                savedVars.inventory['sub-bank'] = {}
                savedVars.inventory['sub-bank'] = inventory
            else
                savedVars.inventory[characterId][bagSpace] = inventory
            end

        end

        local function exportCharacter()
            if(savedVars.a_characters == nil) then
                savedVars.a_characters = {}
            end

            local name = GetUnitName('player')
            local class = GetUnitClass('player')
            local classId = GetUnitClassId('player')
            local level = GetUnitLevel('player')
            local championLevel = GetUnitChampionPoints('player')
            local race = GetUnitRace('player')
            local raceId = GetUnitRaceId('player')
            local alliance = GetUnitAlliance('player')
            local ridingTime = GetTimeUntilCanBeTrained()
            local currentTime = GetTimeStamp()
            local playerRoles = {GetPlayerRoles() }
            local money = GetCarriedCurrencyAmount(CURT_MONEY)
            local maxResearch = {
                GetMaxSimultaneousSmithingResearch(CRAFTING_TYPE_BLACKSMITHING),
                GetMaxSimultaneousSmithingResearch(CRAFTING_TYPE_CLOTHIER),
                GetMaxSimultaneousSmithingResearch(CRAFTING_TYPE_WOODWORKING)
            }

            local skillPoints = GetAvailableSkillPoints()
            local numSkyshards = GetNumSkyShards()

            local characterDump = {
                characterId,
                name,
                class,
                classId,
                level,
                championLevel,
                race,
                raceId,
                alliance,
                ridingTime,
                currentTime,
                tostring(playerRoles[1]).."-"..tostring(playerRoles[2]).."-"..tostring(playerRoles[3]),
                money,
                table.concat(maxResearch, '-'),
                GetWorldName(),
                GetDisplayName(),
                GetBagSize(BAG_BACKPACK),
                GetBagSize(BAG_BANK),
                GetCVar("language.2"),
                table.concat({GetRidingStats()}, '-'),
                table.concat({GetAttributeSpentPoints(ATTRIBUTE_MAGICKA), GetAttributeSpentPoints(ATTRIBUTE_HEALTH), GetAttributeSpentPoints(ATTRIBUTE_STAMINA)}, '-'),
                skillPoints,
                numSkyshards,
            }

            savedVars.a_characters[characterId] = 'CHARACTER:'..table.concat(characterDump, ';')..';'
        end

        local function exportCraftingBag()
            if not HasCraftBagAccess then
                savedVars.inventory['craftBag'] = {}
                return true
            end

            local inventory = {}
            local bagSpace = BAG_VIRTUAL


            for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_VIRTUAL])do
                if data ~= nil then
                    local i = data.slotIndex
                    itemsExported = itemsExported + 1
                    inventory['BAG-' .. i] = exportItem(bagSpace, i)
                end
            end

            savedVars.inventory['craftBag'] = {}
            savedVars.inventory['craftBag'] = inventory

        end

        local function exportAbilities()
            savedVars.skills[characterId] = {}

            local nskilltypes = GetNumSkillTypes()
            for skilltype = 1, nskilltypes do
                local nskilllines = GetNumSkillLines(skilltype)

                for skillline = 1, nskilllines do
                    local skillname, skillrank = GetSkillLineInfo(skilltype, skillline)

                    local nabilities  = GetNumSkillAbilities(skilltype, skillline)
                    for ability = 1, nabilities do
                        local abilityname, abilitytexture, abilityrank, ispassive, isultimate, ispurchased, progression = GetSkillAbilityInfo(skilltype, skillline, ability)
                        local passivestring = " (passive)"

                        if(savedVars.settings['export-all-skills'] == 1 or ispurchased) then
                            if not progression then
                                progression = 0
                            end

                            local basename = nil
                            local morph = 0
                            local rank = nil

                            local basename, morph, rank = GetAbilityProgressionInfo(progression)
                            local abilityId = GetSkillAbilityId(skilltype, skillline, ability, false)
                            local castInfo = {GetAbilityCastInfo(abilityId) }
                            local roles = {GetAbilityRoles(abilityId)}

                            local abilityData = {
                                characterId,
                                skilltype,
                                skillline,
                                skillname,
                                skillrank,
                                ability,
                                abilityname,
                                abilitytexture,
                                abilityrank,
                                tostring(ispassive),
                                tostring(isultimate),
                                tostring(ispurchased),
                                progression,
                                passivestring,
                                basename,
                                morph,
                                rank,
                                GetAbilityDescriptionHeader(abilityId),
                                GetAbilityDescription(abilityId),
                                table.concat({tostring(castInfo[1]), castInfo[2], castInfo[3]}, '-'),
                                tostring(GetAbilityTargetDescription(abilityId)),
                                table.concat({GetAbilityRange(abilityId)}, '-'),
                                GetAbilityRadius(abilityId),
                                GetAbilityAngleDistance(abilityId),
                                GetAbilityDuration(abilityId),
                                table.concat({GetAbilityCost(abilityId)}, '-'),
                                table.concat({tostring(roles[1]), tostring(roles[2]), tostring(roles[3])}, '-'),
                                GetAbilityEffectDescription(abilityId),
                                tostring(DoesAbilityExist(abilityId)),
                                table.concat({GetSkillAbilityUpgradeInfo(skilltype, skillline, ability)}, '-'),
                                GetCVar("language.2"), -- Client language
                            }

                            savedVars.skills[characterId][skilltype .. '-' .. skillline .. '-' .. ability] = "ABILITY;--;"..table.concat(abilityData, ';--;')..";--;"
                        end
                    end
                end
            end
        end

        local function startExport()
            itemsExported = 0
            exportCharacter()
            exportSmithing()
            exportGuilds()
            exportInventory(BAG_BACKPACK)
            exportInventory(BAG_WORN)
            exportInventory(BAG_BANK)
            exportInventory(BAG_SUBSCRIBER_BANK)
            exportCraftingBag()
            exportAbilities()

            if isMuted == 0 then
                d('TesoDelve: ' .. itemsExported .. ' successfully exported')
            end
        end

        local function toggleMute()
            if(savedVars.settings['mute'] == 0) then
                d('TesoDelve: Muting export messages.')
            else
                d('TesoDelve: Enabling export messages.')
            end

            savedVars.settings['mute'] = 1 - savedVars.settings['mute']
            isMuted = savedVars.settings['mute']
        end

        local function enableSmithingStyles()
            if(savedVars.settings[characterId] == nil) then
                savedVars.settings[characterId] = {}
            end

            savedVars.settings[characterId]['export-smithingstyles'] = 1
        end

        local function disableSmithingStyle()
            if(savedVars.settings[characterId] == nil) then
                savedVars.settings[characterId] = {}
            end

            savedVars.settings[characterId]['export-smithingstyles'] = 0
        end

        local function exportAllSkills()
            savedVars.settings['export-all-skills'] = 1 - savedVars.settings['export-all-skills']
            if(savedVars.settings['export-all-skills'] == 1) then
                d('TesoDelve: Exporting all skills and abilities')
            else
                d('TesoDelve: Exporting only known skills and abilities')
            end
        end

        SLASH_COMMANDS["/tesodelve"] = startExport
        SLASH_COMMANDS["/enable-smithingstyles"] = enableSmithingStyles
        SLASH_COMMANDS["/disable-smithingstyles"] = disableSmithingStyle
        SLASH_COMMANDS["/td-skills"] = exportAllSkills
        SLASH_COMMANDS["/td-mute"] = toggleMute


        local inventoryScene = SCENE_MANAGER:GetScene("inventory")
        inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
            if(oldState == 'shown') then
                zo_callLater(startExport, 100)
            end
        end)

        EVENT_MANAGER:RegisterForEvent("TesoDelveStartExportBank", EVENT_CLOSE_BANK, startExport)
        EVENT_MANAGER:RegisterForEvent("TesoDelveStartExportGuildBank", EVENT_CLOSE_GUILD_BANK, startExport)
        EVENT_MANAGER:RegisterForEvent("TesoDelveStartExportGuildBank", EVENT_CLOSE_GUILD_BANK, startExport)
        EVENT_MANAGER:RegisterForEvent("TesoDelveStartExportItemStyles", EVENT_CRAFTING_STATION_INTERACT, exportItemsStyle)
        EVENT_MANAGER:RegisterForEvent("TesoDelveStartExportHorseTraining", EVENT_RIDING_SKILL_IMPROVEMENT, exportCharacter)

        if isMuted == 0 then
            d('Initializing TesoDelve version ' .. tdVersion)
        end


    end
end

EVENT_MANAGER:RegisterForEvent("TesoDelveLoaded", EVENT_ADD_ON_LOADED, loadTesoDelve)