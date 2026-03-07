--[[ ClassicPlus - AutoRepair ]]
local _, ns = ...
local f = CreateFrame("Frame")

-- Grey + prefix, warm muted red‑orange text for repair (loss)
local Colors = ns and ns.Private and ns.Private.Colors
local ColorPlus   = Colors and Colors.gray and Colors.gray.colorCode or "|cffc8c8c8"
local ColorRepair = Colors and Colors.palered and Colors.palered.colorCode or "|cffd97a5c"
local ColorWhite  = Colors and Colors.white and Colors.white.colorCode or "|cffffffff"

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

f:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_SHOW" then
        -- Defer so ChatCleaner's MERCHANT_SHOW runs first; then we set repair flags.
        C_Timer.After(0, function()
            if not _G["ClassicPlusDB"] or not _G["ClassicPlusDB"].autoRepair or IsShiftKeyDown() or not CanMerchantRepair() then return end
            local repairCost, canRepair = GetRepairAllCost()
            if canRepair and repairCost > 0 and GetMoney() >= repairCost then
                RepairAllItems()
                if not _G["ClassicPlus_MerchantState"] then _G["ClassicPlus_MerchantState"] = {} end
                local M = _G["ClassicPlus_MerchantState"]
                M.autoRepaired = true
                M.autoRepairAmount = -repairCost
                AddChatMessage((ColorPlus .. "-|r ") .. ColorRepair .. "Gear repaired: " .. FormatMoney(repairCost) .. "|r")
            end
        end)
    end
end)
