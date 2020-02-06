
local Frame = CreateFrame("Frame");
Frame:RegisterEvent("CINEMATIC_START")
LoadAddOn("Blizzard_MacroUI")
local _, Class = UnitClass("player");
local _,race = UnitRace("player")

if L1QS_macroPlacement == nil and L1QS_Bindings == nil and L1QS_characterMacros == nil then
	L1QS_macroPlacement = {}
	L1QS_Bindings = {}
	L1QS_characterMacros = {}
	--race = "default"
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


--[[
L1QS_macroPlacement["default"] = {
		"as", -- [1]
		"rap", -- [2]
		"3auto", -- [3]
		14290, -- [4]
		"clip", -- [5]
		"disengage", -- [6]
		14295, -- [7]
		"frost", -- [8]
		14305, -- [9]
		"C", -- [10]
		14327, -- [11]
		nil, -- [12]
		19883, -- [13]
		nil, -- [14]
		nil, -- [15]
		19884, -- [16]
		19878, -- [17]
		nil, -- [18]
		1494, -- [19]
		nil, -- [20]
		19879, -- [21]
		19880, -- [22]
		nil, -- [23]
		nil, -- [24]
		"mm", -- [25]
		"ee", -- [26]
		13163, -- [27]
		818, -- [28]
		nil, -- [29]
		883, -- [30]
		nil, -- [31]
		"as1", -- [32]
		"growl", -- [33]
		"0tlt", -- [34]
		nil, -- [35]
		nil, -- [36]
		nil, -- [37]
		nil, -- [38]
		20906, -- [39]
		nil, -- [40]
		"mendpet", -- [41]
		"pet", -- [42]
		10662, -- [43]
		11611, -- [44]
		"01PA", -- [45]
		"01PF", -- [46]
		"pet2", -- [47]
		nil, -- [48]
		"0unstuck", -- [49]
		2481, -- [50]
		19263, -- [51]
		20903, -- [52]
		nil, -- [53]
		nil, -- [54]
		2641, -- [55]
		nil, -- [56]
		14325, -- [57]
		19883, -- [58]
		20594, -- [59]
		19885, -- [60]
		19503, -- [61]
		"feign", -- [62]
		"stomp", -- [63]
		3045, -- [64]
		2643, -- [65]
		"cheetah", -- [66]
		5116, -- [67]
		14277, -- [68]
		"serp", -- [69]
		11611, -- [70]
		"viper", -- [71]
		3044, -- [72]
		[99] = "immo",
		[108] = "strip",
		[117] = 19880,
		[100] = 14264,
		[109] = 13159,
		[97] = 15631,
		[116] = 1494
}
L1QS_Bindings["default"] = {
		["NUMPAD7"] = "RAIDTARGET4",
		["NUMPAD3"] = "RAIDTARGET6",
		["SHIFT-P"] = "TOGGLECHARACTER3",
		["SHIFT-Z"] = "ACTIONBUTTON11",
		["SHIFT-I"] = "TOGGLEPETBOOK",
		["F2"] = "MULTIACTIONBAR3BUTTON2",
		["SHIFT-X"] = "ACTIONBUTTON8",
		["DOWN"] = "FRIENDNAMEPLATES",
		["ALT-C"] = "MULTIACTIONBAR3BUTTON4",
		["BUTTON4"] = "MULTIACTIONBAR3BUTTON9",
		["LEFT"] = "BONUSACTIONBUTTON3",
		["CTRL-MOUSEWHEELUP"] = "MULTIACTIONBAR3BUTTON11",
		["SHIFT-S"] = "MULTIACTIONBAR1BUTTON6",
		["NUMPAD4"] = "RAIDTARGET5",
		["CTRL-PAGEDOWN"] = "COMBATLOGPAGEDOWN",
		["CTRL-Q"] = "MULTIACTIONBAR4BUTTON7",
		["CTRL-F"] = "MULTIACTIONBAR2BUTTON5",
		["SHIFT-3"] = "MULTIACTIONBAR1BUTTON3",
		["ALT-SHIFT-S"] = "TOGGLESOUND",
		["END"] = "NEXTVIEW",
		["CTRL-F9"] = "SHAPESHIFTBUTTON9",
		["ALT-SHIFT-MOUSEWHEELUP"] = "CAMERAZOOMIN",
		["MOUSEWHEELDOWN"] = "MULTIACTIONBAR4BUTTON10",
		["NUMPADMULTIPLY"] = "TOGGLEAUTORUN",
		["'"] = "MULTIACTIONBAR2BUTTON2",
		["SHIFT-4"] = "MULTIACTIONBAR1BUTTON4",
		["-"] = "SITORSTAND",
		[","] = "OPENALLBAGS",
		["BUTTON5"] = "MULTIACTIONBAR3BUTTON8",
		["NUMPADDIVIDE"] = "TOGGLERUN",
		["1"] = "ACTIONBUTTON1",
		["0"] = "TOGGLESHEATH",
		["3"] = "ACTIONBUTTON3",
		["2"] = "ACTIONBUTTON2",
		["5"] = "MULTIACTIONBAR1BUTTON9",
		["4"] = "ACTIONBUTTON4",
		["7"] = "MOVEANDSTEER",
		["6"] = "ACTIONBUTTON7",
		["9"] = "MULTIACTIONBAR3BUTTON1",
		["CTRL-F5"] = "SHAPESHIFTBUTTON5",
		["ALT-SHIFT-MOUSEWHEELDOWN"] = "CAMERAZOOMOUT",
		["A"] = "STRAFELEFT",
		["SHIFT-PAGEDOWN"] = "CHATBOTTOM",
		["C"] = "ACTIONBUTTON10",
		["B"] = "MULTIACTIONBAR2BUTTON9",
		["E"] = "MULTIACTIONBAR1BUTTON1",
		["D"] = "STRAFERIGHT",
		["G"] = "MULTIACTIONBAR1BUTTON11",
		["F"] = "MULTIACTIONBAR1BUTTON12",
		["CTRL-F6"] = "SHAPESHIFTBUTTON6",
		["ALT-F"] = "MULTIACTIONBAR4BUTTON3",
		["M"] = "TOGGLEWORLDMAP",
		["CTRL-BUTTON3"] = "MULTIACTIONBAR2BUTTON10",
		["O"] = "TOGGLESOCIAL",
		["N"] = "ACTIONBUTTON9",
		["Q"] = "MULTIACTIONBAR1BUTTON7",
		["P"] = "TOGGLESPELLBOOK",
		["S"] = "MULTIACTIONBAR1BUTTON5",
		["R"] = "ACTIONBUTTON5",
		["U"] = "TOGGLECHARACTER2",
		["T"] = "ACTIONBUTTON12",
		["F7"] = "TURNLEFT",
		["V"] = "ACTIONBUTTON6",
		["Y"] = "MULTIACTIONBAR4BUTTON5",
		["X"] = "MULTIACTIONBAR1BUTTON8",
		["Z"] = "MULTIACTIONBAR1BUTTON2",
		["CTRL-S"] = "MULTIACTIONBAR2BUTTON6",
		["\\"] = "MULTIACTIONBAR1BUTTON2",
		["CTRL-LEFT"] = "BONUSACTIONBUTTON9",
		["CTRL-B"] = "OPENALLBAGS",
		["NUMPAD1"] = "RAIDTARGET8",
		["SHIFT-LEFT"] = "BONUSACTIONBUTTON10",
		["CTRL-F3"] = "SHAPESHIFTBUTTON3",
		["SHIFT-1"] = "MULTIACTIONBAR2BUTTON3",
		["BACKSPACE"] = "INTERACTTARGET",
		["CTRL-6"] = "BONUSACTIONBUTTON6",
		["CTRL-PAGEUP"] = "COMBATLOGPAGEUP",
		["F12"] = "MULTIACTIONBAR3BUTTON10",
		["F10"] = "MULTIACTIONBAR3BUTTON4",
		["ENTER"] = "OPENCHAT",
		["ALT-S"] = "MULTIACTIONBAR4BUTTON4",
		["SHIFT-\\"] = "ACTIONBUTTON11",
		["F1"] = "MULTIACTIONBAR3BUTTON1",
		["SPACE"] = "JUMP",
		["CTRL-F8"] = "SHAPESHIFTBUTTON8",
		["ALT-E"] = "MULTIACTIONBAR4BUTTON2",
		["HOME"] = "PREVVIEW",
		["NUMPAD5"] = "RAIDTARGET2",
		["UP"] = "NAMEPLATES",
		["CTRL-SPACE"] = "MULTIACTIONBAR2BUTTON7",
		["NUMPAD6"] = "RAIDTARGET7",
		["PRINTSCREEN"] = "SCREENSHOT",
		["CTRL--"] = "MASTERVOLUMEDOWN",
		["SHIFT-F2"] = "MULTIACTIONBAR3BUTTON6",
		["CTRL-F1"] = "SHAPESHIFTBUTTON1",
		["CTRL-TAB"] = "TARGETNEARESTFRIEND",
		["CTRL-5"] = "BONUSACTIONBUTTON5",
		["NUMPADPLUS"] = "MINIMAPZOOMIN",
		["SHIFT-M"] = "TOGGLEBATTLEFIELDMINIMAP",
		["NUMPAD2"] = "RAIDTARGET1",
		["CTRL-F4"] = "SHAPESHIFTBUTTON4",
		["L"] = "TOGGLEQUESTLOG",
		["SHIFT-F3"] = "TARGETPARTYPET2",
		["F3"] = "INTERACTTARGET",
		["CTRL-V"] = "MULTIACTIONBAR4BUTTON6",
		["CTRL-SHIFT-PAGEDOWN"] = "COMBATLOGBOTTOM",
		["K"] = "TOGGLECHARACTER1",
		["ESCAPE"] = "TOGGLEGAMEMENU",
		["F9"] = "MOVEBACKWARD",
		["F8"] = "TURNRIGHT",
		["CTRL-N"] = "TOGGLETALENTS",
		["SHIFT-TAB"] = "MULTIACTIONBAR2BUTTON8",
		["SHIFT-UP"] = "PREVIOUSACTIONPAGE",
		["SHIFT-F1"] = "MULTIACTIONBAR3BUTTON5",
		["CTRL-8"] = "BONUSACTIONBUTTON8",
		["CTRL-F7"] = "SHAPESHIFTBUTTON7",
		["SHIFT-RIGHT"] = "ALLNAMEPLATES",
		["NUMPAD8"] = "RAIDTARGET3",
		["ALT-Q"] = "MULTIACTIONBAR4BUTTON1",
		["NUMPADMINUS"] = "MINIMAPZOOMOUT",
		["TAB"] = "TARGETNEARESTENEMY",
		["CTRL-F2"] = "SHAPESHIFTBUTTON2",
		["PAGEDOWN"] = "MULTIACTIONBAR4BUTTON12",
		["NUMPAD9"] = "MULTIACTIONBAR1BUTTON1",
		["SHIFT-N"] = "MULTIACTIONBAR2BUTTON1",
		["CTRL-SHIFT-TAB"] = "TARGETPREVIOUSFRIEND",
		["SHIFT-2"] = "MULTIACTIONBAR2BUTTON4",
		["MOUSEWHEELUP"] = "MULTIACTIONBAR4BUTTON9",
		["BUTTON3"] = "MULTIACTIONBAR2BUTTON12",
		["/"] = "OPENCHATSLASH",
		["CTRL-="] = "MASTERVOLUMEUP",
		["CTRL-E"] = "MULTIACTIONBAR4BUTTON8",
		["CTRL-MOUSEWHEELDOWN"] = "MULTIACTIONBAR3BUTTON12",
		["F4"] = "MULTIACTIONBAR3BUTTON7",
		["SHIFT-DOWN"] = "NEXTACTIONPAGE",
		["CTRL-M"] = "TOGGLEMUSIC",
		["ALT-X"] = "MULTIACTIONBAR3BUTTON3",
		["SHIFT-BUTTON3"] = "MULTIACTIONBAR2BUTTON11",
		["CTRL-F10"] = "SHAPESHIFTBUTTON10",
		["INSERT"] = "PITCHUP",
		["RIGHT"] = "BONUSACTIONBUTTON2",
		["PAGEUP"] = "MULTIACTIONBAR4BUTTON11",
		["W"] = "MOVEFORWARD",
		["CTRL-7"] = "BONUSACTIONBUTTON7"
}

L1QS_characterMacros["default"] = {
		{
			"01PA", -- [1]
			134400, -- [2]
			"/petattack [@mouseover,exists,nomod] [nomod]\n/petautocaston Claw(Rank 7)\n//petautocaston [nomod] screech\n/petautocastoff [nomod] growl(rank 6)\n/cast [mod] dive\n/petautocaston [mod] dive\n", -- [3]
		}, -- [1]
		{
			"01PF", -- [1]
			134400, -- [2]
			"/petfollow [mod]\n/petautocaston [nomod] growl(rank 6)\n/petautocastoff [nomod] Claw(rank 7)\n//petautocastoff [nomod] screech\n/petautocastoff dive\n/cast [@mouseover,harm,nomod][nomod,@pettarget] growl(rank 6)\n", -- [3]
		}, -- [2]
		{
			"mm", -- [1]
			134400, -- [2]
			"/tar pepsine\n/cast [harm] hunter's mark\n", -- [3]
		}, -- [3]
		{
			"rap", -- [1]
			132223, -- [2]
			"#show Raptor Strike\n//cast !raptor strike\n/cast !auto shot\n/startattack\n/stopmacro [@pettarget,exists]\n/petattack\n", -- [3]
		}, -- [4]
		{
			"tar", -- [1]
			132101, -- [2]
			"/tar broken tooth\n/stopcasting\n", -- [3]
		}, -- [5]
		{
			"2rap", -- [1]
			132223, -- [2]
			"#show [bar:1] Raptor Strike; Attack\n/cast [bar:1] auto shot\n/cast [bar:1] !raptor strike\n/stopcasting [bar:2]\n/startattack\n/stopmacro [@pettarget,exists]\n/petattack\n", -- [3]
			true, -- [4]
		}, -- [6]
		{
			"3auto", -- [1]
			132271, -- [2]
			"#show auto shot\n/cast [@mouseover,help][help] Strong Anti-Venom\n/cast !auto shot\n//cast furious howl\n", -- [3]
			true, -- [4]
		}, -- [7]
		{
			"aimed", -- [1]
			135130, -- [2]
			"/cast aimed shot \n//cast auto shot\n", -- [3]
			true, -- [4]
		}, -- [8]
		{
			"as", -- [1]
			132218, -- [2]
			"//dismount\n/cast arcane shot\n/cast !auto shot\n", -- [3]
			true, -- [4]
		}, -- [9]
		{
			"as1", -- [1]
			136076, -- [2]
			"/cast [mod:ctrl] aspect of the beast; [mod:shift] aspect of the monkey; aspect of the hawk\n/cancelaura aspect of the cheetah\n/cancelaura aspect of the pack\n/click BattlefieldFrameJoinButton\n", -- [3]
			true, -- [4]
		}, -- [10]
		{
			"AV2", -- [1]
			134400, -- [2]
			"/click MiniMapBattlefieldFrame RightButton\n/click DropDownList1Button3\n", -- [3]
			true, -- [4]
		}, -- [11]
		{
			"AVm", -- [1]
			132089, -- [2]
			"/run SetSelectedBattlefield(GetNumBattlefields())\n/click BattlefieldFrameJoinButton\n", -- [3]
			true, -- [4]
		}, -- [12]
		{
			"bandage", -- [1]
			132198, -- [2]
			"/use !first aid\n/click TradeSkillCreateAllButton\n/tar prince\n", -- [3]
			true, -- [4]
		}, -- [13]
		{
			"bar", -- [1]
			132156, -- [2]
			"/click [mod,bar:1][bar:2,nomod] ActionBarUpButton\n/cast prowl\n/run --SetSelectedBattlefield(GetNumBattlefields())\n//click MiniMapBattlefieldFrame\n//click DropDownList1Button3\n", -- [3]
			true, -- [4]
		}, -- [14]
		{
			"C", -- [1]
			135815, -- [2]
			"#show flare\n/petstay [mod,combat]\n/petpassive [combat,mod]\n/cast [mod,combat] feign death\n/cast [mod:shift] freezing trap; [mod:ctrl] Explosive Trap; !flare\n", -- [3]
			true, -- [4]
		}, -- [15]
		{
			"cheetah", -- [1]
			132242, -- [2]
			"/cast aspect of the cheetah\n/cancelaura aspect of the cheetah\n/cancelaura aspect of the pack\n", -- [3]
			true, -- [4]
		}, -- [16]
		{
			"clip", -- [1]
			132309, -- [2]
			"/dismount\n/stopcasting\n//cast Wing Clip(Rank 2)\n/cast [nomod] Wing Clip; Wing Clip(Rank 1)\n/startattack\n//cast Iron Grenade\n", -- [3]
			true, -- [4]
		}, -- [17]
		{
			"d", -- [1]
			134400, -- [2]
			"/targetlasttarget [mod]\n//cast Distracting shot\n/cast [nomod] Iron Grenade\n/targetlasttarget [mod]\n/equip [mod] Lok'delar, Stave of the Ancient Keepers\n/cancelaura Flee\n", -- [3]
			true, -- [4]
		}, -- [18]
		{
			"disengage", -- [1]
			132294, -- [2]
			"#show disengage\n/cast [combat] Disengage;\n/cast !Shadowmeld\n//cast !prowl\n/stopcasting [channeling]\n", -- [3]
			true, -- [4]
		}, -- [19]
		{
			"dshot", -- [1]
			135736, -- [2]
			"/targetexact [mod] Cho'Rush the Observer\n/cast distracting shot\n/targetlasttarget [mod]\n", -- [3]
			true, -- [4]
		}, -- [20]
		{
			"ee", -- [1]
			132172, -- [2]
			"/cast [@cursor] !eagle eye\n", -- [3]
			true, -- [4]
		}, -- [21]
		{
			"feign", -- [1]
			132293, -- [2]
			"/dismount\n/stopcasting\n/stopcasting\n/stopattack\n//petstay [combat]\n/petpassive [combat]\n/cast !feign death\n", -- [3]
			true, -- [4]
		}, -- [22]
		{
			"frost", -- [1]
			135840, -- [2]
			"#show frost trap\n/stopattack\n/stopcasting\n/petpassive [combat]\n/cast [combat] feign death\n/cast frost trap  \n", -- [3]
			true, -- [4]
		}, -- [23]
		{
			"growl", -- [1]
			136056, -- [2]
			"/petautocasttoggle [nomod] Screech; claw\n", -- [3]
			true, -- [4]
		}, -- [24]
		{
			"immo", -- [1]
			135813, -- [2]
			"#show immolation trap\n/cast immolation trap\n/stopmacro\n/petstay [combat]\n/petpassive [combat]\n/cast [combat] feign death\n", -- [3]
			true, -- [4]
		}, -- [25]
		{
			"mendpet", -- [1]
			132179, -- [2]
			"/cast [nomod] Mend Pet; [mod:ctrl] Mend Pet(Rank 3); Mend Pet(Rank 1)\n", -- [3]
			true, -- [4]
		}, -- [26]
		{
			"ms", -- [1]
			132330, -- [2]
			"/dismount\n/cast multi-shot\n", -- [3]
			true, -- [4]
		}, -- [27]
		{
			"npc", -- [1]
			132100, -- [2]
			"/tar wand\n", -- [3]
			true, -- [4]
		}, -- [28]
		{
			"p0", -- [1]
			136222, -- [2]
			"/target player\n/click [bar:2] ActionBarUpButton\n", -- [3]
			true, -- [4]
		}, -- [29]
		{
			"p1", -- [1]
			136222, -- [2]
			"/target party1\n/click [bar:2] ActionBarUpButton\n", -- [3]
			true, -- [4]
		}, -- [30]
		{
			"p2", -- [1]
			136222, -- [2]
			"/target party2\n/click [bar:2] ActionBarUpButton\n", -- [3]
			true, -- [4]
		}, -- [31]
		{
			"p3", -- [1]
			136222, -- [2]
			"/target party3\n/click [bar:2] ActionBarUpButton\n", -- [3]
			true, -- [4]
		}, -- [32]
		{
			"p4", -- [1]
			136222, -- [2]
			"/target party4\n/click [bar:2] ActionBarUpButton\n", -- [3]
			true, -- [4]
		}, -- [33]
		{
			"pet", -- [1]
			132163, -- [2]
			"#showtooltip\n/cast [@pet,exists,nodead] Eyes of the Beast; Revive pet\n", -- [3]
			true, -- [4]
		}, -- [34]
		{
			"pet2", -- [1]
			132117, -- [2]
			"/cast [nopet] Call Pet\n/stopmacro [nopet]\n/castsequence reset=1.5 Feed pet, nil\n/use Roasted Quail\n", -- [3]
			true, -- [4]
		}, -- [35]
		{
			"Pouch", -- [1]
			134400, -- [2]
			"#show Furbolg Medicine Pouch\n/equip Furbolg Medicine Pouch\n/equip Bone Slicing Hatchet\n/stopmacro [mounted]\n/use Furbolg Medicine Pouch\n", -- [3]
			true, -- [4]
		}, -- [36]
		{
			"Q", -- [1]
			135860, -- [2]
			"#showtooltip\n/dismount\n/cast concussive shot\n/cast !auto shot\n", -- [3]
			true, -- [4]
		}, -- [37]
		{
			"r1", -- [1]
			132218, -- [2]
			"/cast [nomod] Arcane Shot(Rank 1)\n/stopmacro [nomod]\n/targetexact [mod] Cho'Rush the Observer\n/cast distracting shot\n/targetlasttarget [mod]\n", -- [3]
			true, -- [4]
		}, -- [38]
		{
			"rap", -- [1]
			132223, -- [2]
			"#show Raptor Strike\n/cast auto shot\n/cast [@mouseover,harm][] !raptor strike\n/cast mongoose bite\n/startattack\n/stopmacro [@pettarget,exists]\n/stopmacro [combat]\n", -- [3]
			true, -- [4]
		}, -- [39]
		{
			"rh", -- [1]
			133073, -- [2]
			"/use 1\n/cast furious howl\n", -- [3]
			true, -- [4]
		}, -- [40]
		{
			"sb", -- [1]
			132118, -- [2]
			"/cast [@mouseover,harm,nodead][] scare beast\n", -- [3]
			true, -- [4]
		}, -- [41]
		{
			"serp", -- [1]
			132204, -- [2]
			"#showtooltip\n/dismount\n/cast [nomod] serpent sting; Serpent Sting(Rank 1)\n/stopattack\n", -- [3]
			true, -- [4]
		}, -- [42]
		{
			"stay", -- [1]
			132093, -- [2]
			"/petstay\n/cancelaura eyes of the beast\n", -- [3]
			true, -- [4]
		}, -- [43]
		{
			"stomp", -- [1]
			136040, -- [2]
			"/cast [@pettarget] growl\n/petattack [target=healing ward]\n/petattack [target=mana tide totem]\n/petattack [target=tremor totem]\n/petattack [target=grounding totem]\n/petattack [target=windfury totem]\n/petattack [target=Poison Cleansing Totem]\n", -- [3]
			true, -- [4]
		}, -- [44]
		{
			"strip", -- [1]
			135977, -- [2]
			"/run t={16,17,18,5,7,1,3,6,8,9,10} for b=0,3 do n=GetContainerNumFreeSlots(b) for _,x in pairs(t) do if n>0 then PickupInventoryItem(x)    if CursorHasItem() then PutItemInBag(b+19) PutItemInBackpack() n=n-1 end else break end end end\n", -- [3]
			true, -- [4]
		}, -- [45]
		{
			"trinket", -- [1]
			135228, -- [2]
			"/use [nomod] 13; 14\n", -- [3]
			true, -- [4]
		}, -- [46]
		{
			"viper", -- [1]
			132157, -- [2]
			"/dismount\n/cast [nomod] viper sting; Viper Sting(Rank 1)\n", -- [3]
			true, -- [4]
		}, -- [47]
		{
			"zzzz", -- [1]
			134400, -- [2]
			"/run local q,a,b,c=unitscan_targets,\"DEVILSAUR\",\"TYRANT DEVILSAUR\",\"IRONHIDE DEVILSAUR\" local function z(x) if not q[x] then SlashCmdList.UNITSCAN(x) end end z(a) z(b) z(c)\n", -- [3]
			true, -- [4]
		}, -- [48]
		{
			"zzzzTRIB", -- [1]
			135996, -- [2]
			"/2 WTS DM Tribute loot -|cff0070dd|Hitem:18500::::::::60:::::::|h[Tarnished Elven Ring]|h|r|cff0070dd|Hitem:18534::::::::60:::::::|h[Rod of the Ogre Magi]|h|r|cff0070dd|Hitem:18495::::::::60:::::::|h[Redoubt Cloak]|h|r and more - pst for more info\n", -- [3]
			true, -- [4]
		}, -- [49]
		{
			"zzzzzM", -- [1]
			134400, -- [2]
			"/run ManualWho()\n", -- [3]
			true, -- [4]
		}, -- [50]
}
]]