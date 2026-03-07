--[[ ClassicPlus - AutoSellGreys ]]
local _, ns = ...
local f = CreateFrame("Frame")

-- Grey + prefix, grey text for junk (poor quality)
local Colors   = ns and ns.Private and ns.Private.Colors
local ColorPlus = Colors and Colors.gray and Colors.gray.colorCode or "|cffc8c8c8"
local ColorJunk = Colors and Colors.quality and Colors.quality[0] and Colors.quality[0].colorCode or "|cff9d9d9d"
local ColorWhite = Colors and Colors.white and Colors.white.colorCode or "|cffffffff"

local GoldIcon   = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t"
local silverIcon = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t"
local copperIcon = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t"

local function FormatMoney(amount)
    local amountColor = ColorWhite
    local gold   = floor(amount / 10000)
    local silver = floor((amount % 10000) / 100)
    local copper = amount % 100
    local str = ""
    if gold > 0 then
        str = str .. amountColor .. gold .. "|r " .. GoldIcon .. " "
    end
    if silver > 0 or gold > 0 then
        str = str .. amountColor .. silver .. "|r " .. silverIcon .. " "
    end
    str = str .. amountColor .. copper .. "|r " .. copperIcon
    return str
end

local function AddChatMessage(msg)
    local frame = DEFAULT_CHAT_FRAME
    if frame and frame.AddMessage then
        frame:AddMessage(msg, 1, 1, 1)
    else
        print(msg)
    end
end

f:RegisterEvent("MERCHANT_SHOW")

local function SellGreyItems()
    if _G["ClassicPlusDB"] and _G["ClassicPlusDB"].autoSellGreys == false then return end
    
    -- Don't sell if Shift is held
    if IsShiftKeyDown() then return end
    
    -- Handle API differences: Classic may not have C_Container
    local getNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
    local getItemInfo = (C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo
    local getItemLink = (C_Container and C_Container.GetContainerItemLink) or GetContainerItemLink
    local useContainerItem = UseContainerItem or (C_Container and C_Container.UseContainerItem)

    if not getNumSlots or not useContainerItem then return end

    local totalSold = 0
    local totalValue = 0

    for bag = 0, 4 do
        local numSlots = getNumSlots(bag)
        if numSlots and numSlots > 0 then
            for slot = 1, numSlots do
                local itemLink = getItemLink(bag, slot)
                if itemLink then
                    local _, _, quality = GetItemInfo(itemLink)
                    if quality == 0 then -- Poor quality (grey)
                        local info = getItemInfo(bag, slot)
                        if info and info.stackCount and info.stackCount > 0 and not info.hasNoValue then
                            -- Use the appropriate API to sell the item
                            if useContainerItem then
                                useContainerItem(bag, slot)
                                totalSold = totalSold + info.stackCount
                                -- Track the total vendor value of junk sold so we
                                -- can show an immediate, stable gold amount that
                                -- isn't affected by repairs or other purchases.
                                local _, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(itemLink)
                                if vendorPrice and vendorPrice > 0 then
                                    totalValue = totalValue + (vendorPrice * info.stackCount)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if totalSold > 0 then
        -- Mark that this merchant session auto-sold junk so ChatCleaner
        -- can suppress its net summary when the only change was junk sold.
        if not _G["ClassicPlus_MerchantState"] then _G["ClassicPlus_MerchantState"] = {} end
        local M = _G["ClassicPlus_MerchantState"]
        M.autoSoldJunk = true
        M.autoSoldAmount = totalValue
        if totalValue > 0 then
            AddChatMessage((ColorPlus .. "+|r ") .. ColorJunk .. "Sold junk items: " .. FormatMoney(totalValue) .. "|r")
        else
            AddChatMessage((ColorPlus .. "+|r ") .. ColorJunk .. "Sold junk items|r")
        end
    end
end

f:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        -- Defer so ChatCleaner's MERCHANT_SHOW runs first and clears flags;
        -- then we set merchantAutoSoldJunk/Amount for MERCHANT_CLOSED suppression.
        C_Timer.After(0, SellGreyItems)
    end
end)
