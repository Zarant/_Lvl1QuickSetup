
local Frame = CreateFrame("Frame");
Frame:RegisterEvent("CINEMATIC_START")
LoadAddOn("Blizzard_MacroUI")
local _, Class = UnitClass("player");
local _,race = UnitRace("player")

if L1QS_macroPlacement == nil and L1QS_Bindings == nil and L1QS_characterMacros == nil then
	L1QS_macroPlacement = {}
	L1QS_Bindings = {}
	L1QS_characterMacros = {}
end

function createMacros(arg)
	local profile = Class
	if arg ~= nil then
		profile = arg
	end
	local i,j = GetNumMacros()
	if not(L1QS_characterMacros[profile]) then return end
	for index,macro in pairs(L1QS_characterMacros[profile]) do 
		local characterMacro = 1
		if macro[4] ~= nil then
			characterMacro = nil
		end
		if GetMacroInfo(macro[1]) == nil and (profile ~= Class or characterMacro ~= nil) then 
			CreateMacro(macro[1], macro[2], macro[3], characterMacro)
		end
	end
end



if UnitLevel('player') == 1 then
	GuidelimeDataChar = {}
	GuidelimeDataChar["mainFrameFontSize"] = 12
	GuidelimeDataChar["mainFrameWidth"] = 320
	
	if  race == "NightElf" then
		GuidelimeDataChar["currentGuide"] = "Zarant 1-11 Teldrassil"
	elseif race == "Dwarf" or race == "Gnome" then
		GuidelimeDataChar["currentGuide"] = "Zarant 1-11 Dun Morogh"
	end
end
	
Frame:SetScript("OnEvent",function(self,event,arg1,arg2,arg3,arg4)
	if UnitLevel('player') == 1 then
		local a=true SetActionBarToggles(a,a,a,a,0) SHOW_MULTI_ACTIONBAR_1=a SHOW_MULTI_ACTIONBAR_2=a SHOW_MULTI_ACTIONBAR_3=a SHOW_MULTI_ACTIONBAR_4 = a MultiActionBar_Update()
		createMacros()
		local consoleVariables = {
			["cameraPivot"]="0",
			["showTargetOfTarget"]="1",
			["instantQuestText"]="1",
			["cameraSmoothStyle"]="0",
			["cameraDistanceMaxZoomFactor"]="2.6",
			["statusText"]="1",
			["nameplateShowEnemies"]="1",
			["statusTextDisplay"]="BOTH",
			["showTutorials"]="0",
			["deselectOnClick"]="1",
			["autoLootDefault"]="1",
			["weatherDensity"]="0"

		}

		for var,value in pairs(consoleVariables) do 
			SetCVar(var,value)
		end
		
		StopCinematic()
		CameraZoomOut(50)
		
		loadKeyBinds()
		
		loadActionButtons()
		
		
	end
end)


-- Fast loot function
--[[
local tDelay = 0
local function FastLoot()
    if GetTime() - tDelay >= 0.3 then
        tDelay = GetTime()
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
            tDelay = GetTime()
        end
    end
end

-- event frame
local faster = CreateFrame("Frame")
faster:RegisterEvent("LOOT_READY")
faster:SetScript("OnEvent", FastLoot)]]

function reportActionButtons()
	local lActionSlot = 0;
	for lActionSlot = 1, 120 do
		local lActionText = GetActionText(lActionSlot);
		local lActionTexture = GetActionTexture(lActionSlot);
		if lActionTexture then
			local lMessage = "Slot " .. lActionSlot .. ": [" .. lActionTexture .. "]";
			if lActionText then
				lMessage = lMessage .. " \"" .. lActionText .. "\"";
			end
			DEFAULT_CHAT_FRAME:AddMessage(lMessage);
		end
	end
end

function loadActionButtons(arg)
	local profile = Class
	if arg ~= nil then
		profile = arg
	end
	if L1QS_macroPlacement[profile] then
		for slot,macro in pairs(L1QS_macroPlacement[profile]) do 
			local spellId = tonumber(macro)
			if GetMacroIndexByName(macro) > 0 then
				PickupMacro(macro) 
				if GetCursorInfo() == "macro" then PlaceAction(slot) end
				ClearCursor()
			elseif spellId then 
				PickupSpell(spellId)
				if GetCursorInfo() == "spell" then PlaceAction(slot) end
				ClearCursor()
			end
		end
	end
end



function saveActionButtons(arg)
	local profile = Class
	if arg ~= nil then
		profile = arg
	end
	L1QS_macroPlacement[profile] = {}
	local lActionSlot = 0;
	for lActionSlot = 1, 120 do
		local actionType,Id = GetActionInfo(lActionSlot)
		local lActionText = GetActionText(lActionSlot);
		local lActionTexture = GetActionTexture(lActionSlot);
		if lActionText ~= nil and actionType == "macro" then
			L1QS_macroPlacement[profile][lActionSlot] = lActionText
		elseif actionType == "spell" then 
			L1QS_macroPlacement[profile][lActionSlot] = Id
		end
	end
end


function saveKeyBinds(arg)
	local profile = Class
	if arg ~= nil then
		profile = arg
	end
	L1QS_Bindings[profile] = {}
	for index = 1, GetNumBindings() do
	  local command,_,key1,key2 = GetBinding(index)
	  if key1 then
		L1QS_Bindings[profile][key1] = command;
	  end
	  if key2 then
		L1QS_Bindings[profile][key2] = command;
	  end
	end
end

function loadKeyBinds(arg)
	local profile = Class
	if arg ~= nil then
		profile = arg
	end
	if L1QS_Bindings[profile] then
		AttemptToSaveBindings(2) --characer specific keybinds
		LoadBindings(2)
		for index = 1, GetNumBindings() do
			local command,_,key1,key2 = GetBinding(index)
			if key1 then
				SetBinding(key1);
			end
			if key2 then
				SetBinding(key2);
			end
		end
		for key,command in pairs(L1QS_Bindings[profile]) do 
			SetBinding(key,command)
		end
		AttemptToSaveBindings(2)
	end
end

function saveMacros(arg)
	local profile = Class
	if arg ~= nil then
		profile = arg
	end
	
	local i,j = GetNumMacros()
	if i == 0 and j == 0 then return end
	L1QS_characterMacros[profile] = {}
	local globalMacro = true
	for index = 1, i do
		local name,icon,body = GetMacroInfo(index)
		L1QS_characterMacros[profile][index] = {name,icon,body,globalMacro}
	end
	globalMacro = nil
	for index = 1, j do
		local name,icon,body = GetMacroInfo(index+120)
		L1QS_characterMacros[profile][index] = {name,icon,body,globalMacro}
	end
end

function saveAll(arg)
saveMacros(arg)
saveKeyBinds(arg)
saveActionButtons(arg)
end

function loadAll(arg)
--createMacros(arg)
loadKeyBinds(arg)
loadActionButtons(arg)
end

