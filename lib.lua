-----------------------------
--| oUF_Drk
--| Drakull 2010
--| UPDATED by myno
--
--TODO:
-- # altpowerbar on target
-- # raid/partyframes
-- # warklock resource bars
-- # monk chi bar update on talent change
-- # check if eclipse bar is working
-- combat icon target
-- phase icon
-- raid mark placement
-----------------------------
-- INIT
-----------------------------

local addon, ns = ...
local cfg = ns.cfg
local cast = ns.cast
local lib = CreateFrame("Frame")  
local _, playerClass = UnitClass("player")
oUF.colors.runes = {{0.87, 0.12, 0.23};{0.40, 0.95, 0.20};{0.14, 0.50, 1};{.70, .21, 0.94};}

-----------------------------
-- FUNCTIONS
-----------------------------

local retVal = function(f, val1, val2, val3)
	if f.mystyle == "player" or f.mystyle == "target" then
		return val1
	elseif f.mystyle == "raid" then
		return val3
	else
		return val2
	end
end
  
--backdrop table
local backdrop_tab = { 
	bgFile = cfg.backdrop_texture, 
	edgeFile = cfg.backdrop_edge_texture,
	tile = false,
	tileSize = 0, 
	edgeSize = 5, 
	insets = { 
		left = 3, 
		right = 3, 
		top = 3, 
		bottom = 3,
	},
}
local power_backdrop_tab = { 
	bgFile = cfg.backdrop_texture, 
	edgeFile = cfg.backdrop_edge_texture,
	tile = false,
	tileSize = 0, 
	edgeSize = 4, 
	insets = { 
		left = 2, 
		right = 2, 
		top = 2, 
		bottom = 2,
	},
}
-- backdrop func
lib.gen_backdrop = function(f)
	f:SetBackdrop(backdrop_tab);
	f:SetBackdropColor(0,0,0,1)
	f:SetBackdropBorderColor(0,0,0,0.8)
end
lib.gen_power_backdrop = function(f)
	f:SetBackdrop(power_backdrop_tab);
	f:SetBackdropColor(0,0,0,1)
	f:SetBackdropBorderColor(0,0,0,0.8)
end
  
-- Right Click Menu
lib.spawnMenu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("^%l", string.upper)

	if(cunit == 'Vehicle') then
		cunit = 'Pet'
	end

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

--fontstring func
lib.gen_fontstring = function(f, name, size, outline)
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(name, size, outline)
	fs:SetShadowColor(0,0,0,0.8)
	fs:SetShadowOffset(1,-1)
	return fs
end  
  
--gen healthbar func
lib.gen_hpbar = function(f)
	--statusbar
	local s = CreateFrame("StatusBar", nil, f)
	s:SetStatusBarTexture(cfg.statusbar_texture)
	s:GetStatusBarTexture():SetHorizTile(true)
	if f.mystyle=="boss" then
		s:SetHeight(37)
		s:SetWidth(250)
		s:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	else
		s:SetHeight(retVal(f,34,19,24))
		s:SetWidth(f:GetWidth())
		s:SetPoint("TOP",0,0)
	end
	--helper
	local h = CreateFrame("Frame", nil, s)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-4,4)
	if f.mystyle == "target" or f.mystyle == "player" or f.mystyle == "boss" then
		h:SetPoint("BOTTOMRIGHT",4,-4)
	elseif f.mystyle == "raid" then
		h:SetPoint("BOTTOMRIGHT", 5, -9) --NYI
	else
		h:SetPoint("BOTTOMRIGHT", 4, -10)
	end
	lib.gen_backdrop(h)
	--bg
	local b = s:CreateTexture(nil, "BACKGROUND")
	b:SetTexture(cfg.statusbar_texture)
	b:SetAllPoints(s)
	f.Health = s
	f.Health.bg = b
end

--gen hp strings func
lib.gen_hpstrings = function(f)
    --health/name text strings
	if f.mystyle=="boss" then
		local name = lib.gen_fontstring(f.Health, cfg.font, 14, "NONE")
		name:SetPoint("LEFT", f.Health, "TOPLEFT", 3, -10)
		name:SetJustifyH("LEFT")
		local hpval = lib.gen_fontstring(f.Health, cfg.font, 14, "NONE")
		hpval:SetPoint("RIGHT", f.Health, "TOPRIGHT", -3, -10)

		f:Tag(name,"[name]")
		f:Tag(hpval,"[drk:hp]")
	else
		local name = lib.gen_fontstring(f.Health, cfg.font, retVal(f,14,12,12), "NONE")
		name:SetPoint("LEFT", f.Health, "TOPLEFT", retVal(f,3,3,2), retVal(f,-10,-10,-7))
		name:SetJustifyH("LEFT")
		name.frequentUpdates = 0.1
		local powerval = lib.gen_fontstring(f.Health, cfg.font, 14, "THINOUTLINE")
		powerval:SetPoint("LEFT", f.Health, "BOTTOMRIGHT", 3, -16)
		local hpval = lib.gen_fontstring(f.Health, cfg.font, retVal(f,14,12,10), "NONE")
		hpval:SetPoint("RIGHT", f.Health, "TOPRIGHT", retVal(f,-3,-3,-3), retVal(f,-10,-10,-17))
		--this will make the name go "..." when its to long
		if f.mystyle == "raid" then
			name:SetPoint("RIGHT", f, "RIGHT", -1, 0) --NYI
		else
			name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
		end
		if f.mystyle == "player" then
			f:Tag(name, "[drk:color][my:power][drk:afkdnd]")
		elseif f.mystyle == "target" then
			f:Tag(name, "[drk:level] [drk:color][name][drk:afkdnd]")
			f:Tag(powerval, "[my:power]")
		elseif f.mystyle == "raid" then
			f:Tag(name, "[drk:color][name][drk:afkdnd]") --NYI
		else
			f:Tag(name, "[drk:color][name]")
		end
		f:Tag(hpval, retVal(f,"[drk:hp]","[drk:hp]","[drk:raidhp]"))
	end
end

--gen powerbar func
lib.gen_ppbar = function(f)
    --statusbar
    local s = CreateFrame("StatusBar", nil, f)
    s:SetStatusBarTexture(cfg.powerbar_texture)
	s:GetStatusBarTexture():SetHorizTile(true)
	s:SetFrameLevel(2)
	if f.mystyle=="boss" then
		s:SetWidth(250)
		s:SetHeight(8)
		s:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
		s:SetStatusBarColor(165/255, 73/255, 23/255, 1)
	else
		s:SetHeight(retVal(f,13,5,3))
		s:SetWidth(f:GetWidth())
		s:SetPoint("BOTTOM",f,"BOTTOM",0,0)
	end
	s.frequentUpdates = true
    --helper
	if f.mystyle == "target" or f.mystyle == "player" or f.mystyle=="boss" then
		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(1)
		h:SetPoint("TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",4,-4)
		lib.gen_backdrop(h)
	end
    --bg
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.powerbar_texture)
    b:SetAllPoints(s)
    f.Power = s
    f.Power.bg = b
end

--gen altpowerbar func
lib.gen_altppbar = function(f)
  	local s = CreateFrame("StatusBar", nil, f)
	s:SetFrameLevel(0)
	s:SetSize(f:GetWidth(), 2)
	s:SetPoint("BOTTOM", f, "BOTTOM", 0, -7)

	s:SetStatusBarTexture(cfg.powerbar_texture)
	s:GetStatusBarTexture():SetHorizTile(false)
	s:SetStatusBarColor(235/255, 235/255, 235/255)
	f.AltPowerBar = s
	
	local h = CreateFrame("Frame", nil, s)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-5,5)
	h:SetPoint("BOTTOMRIGHT",5,-5)
	lib.gen_backdrop(h)
	
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.powerbar_texture)
    b:SetAllPoints(s)
	b:SetVertexColor(65/255, 65/255, 65/255)
    f.AltPowerBar.bg = b
end
  
--gen altpowerbar strings func
lib.gen_altppbartext = function(f)
	local altpphelpframe = CreateFrame("Frame",nil,s)
	if f.mystyle == "player" then
		altpphelpframe:SetPoint("CENTER", PlayerPowerBarAlt, "TOP", 0, -5)
	else
		altpphelpframe:SetPoint("RIGHT", f.AltPowerBar, "RIGHT", 0, 0)
	end
	altpphelpframe:SetFrameLevel(7)
	altpphelpframe:SetSize(30,10)
	local altppbartext
	if f.mystyle == "player" then
		altppbartext = lib.gen_fontstring(altpphelpframe, cfg.font, 12, "OUTLINE")
		altppbartext:SetPoint("CENTER", altpphelpframe, "CENTER", 0, 0)
	else
		altppbartext = lib.gen_fontstring(altpphelpframe, cfg.font, 11, "NONE")
		altppbartext:SetPoint("RIGHT", altpphelpframe, "RIGHT", 0, 0)	
	end
	f:Tag(altppbartext,"[Drk:AltPowerBar]")
end
  
--gen portrait func
lib.gen_portrait = function(f)
    local p = CreateFrame("PlayerModel", nil, f)
    p:SetFrameLevel(4)
    p:SetHeight(19.8)
    p:SetWidth(f:GetWidth()-17.55)
    p:SetPoint("BOTTOM", f, "BOTTOM", 0, 8)
    --helper
    local h = CreateFrame("Frame", nil, p)
    h:SetFrameLevel(3)
    h:SetPoint("TOPLEFT",-4,4)
    h:SetPoint("BOTTOMRIGHT",4,-4)
    lib.gen_backdrop(h)
	
    f.Portrait = p

    local hl = f.Portrait:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Portrait)
    hl:SetTexture(cfg.portrait_texture)
    hl:SetVertexColor(.5,.5,.5,.8)
    hl:SetBlendMode("ALPHAKEY")
    hl:Hide()
end

--gen combat and LFD icons
lib.gen_InfoIcons = function(f)
    local h = CreateFrame("Frame",nil,f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
    --combat icon
	if f.mystyle=="player" then
		f.Combat = h:CreateTexture(nil, 'OVERLAY')
		f.Combat:SetSize(15,15)
		f.Combat:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		f.Combat:SetTexCoord(0.58, 0.90, 0.08, 0.41)
		f.Combat:SetPoint('BOTTOMRIGHT', 7, -7)
	end
	--	PVP Icon
	if f.mystyle == 'player' then
		f.PvP = f.Health:CreateTexture(nil, "OVERLAY")
		local faction = PvPCheck
		if faction == "Horde" then
			f.PvP:SetTexCoord(0.08, 0.58, 0.045, 0.545)
		elseif faction == "Alliance" then
			f.PvP:SetTexCoord(0.07, 0.58, 0.06, 0.57)
		else
			f.PvP:SetTexCoord(0.05, 0.605, 0.015, 0.57)
		end
		f.PvP:SetHeight(20)
		f.PvP:SetWidth(20)
		f.PvP:SetPoint("TOPRIGHT", 10, 10)
	elseif f.mystyle == 'target' then
		f.PvP = h:CreateTexture(nil, "OVERLAY")
		local faction = PvPCheck
		if faction == "Horde" then
			f.PvP:SetTexCoord(0.08, 0.58, 0.045, 0.545)
		elseif faction == "Alliance" then
			f.PvP:SetTexCoord(0.07, 0.58, 0.06, 0.57)
		else
			f.PvP:SetTexCoord(0.05, 0.605, 0.015, 0.57)
		end
		f.PvP:SetHeight(12)
		f.PvP:SetWidth(12)
		f.PvP:SetPoint("BOTTOMRIGHT", -11, 9)
	end
	-- rest icon
    if f.mystyle == 'player' then
		f.Resting = h:CreateTexture(nil, 'OVERLAY')
		f.Resting:SetSize(15,15)
		f.Resting:SetPoint('BOTTOMRIGHT', -12, -8)
		f.Resting:SetTexture('Interface\\CharacterFrame\\UI-StateIcon')
		f.Resting:SetTexCoord(0.09, 0.43, 0.08, 0.42)
	end
    --LFDRole icon
	if f.mystyle == 'player' then
		f.LFDRole = h:CreateTexture(nil, 'OVERLAY')
		f.LFDRole:SetSize(15,15)
		f.LFDRole:SetAlpha(0.9)
		f.LFDRole:SetPoint('BOTTOMLEFT', -6, -8)
	elseif f.mystyle == 'target' then
		f.LFDRole = h:CreateTexture(nil, 'OVERLAY')
		f.LFDRole:SetSize(15,15)
		f.LFDRole:SetAlpha(0.9)
		f.LFDRole:SetPoint('BOTTOMRIGHT', 5, -8)
    elseif f.mystyle == 'raid' then 
		f.LFDRole = f.Power:CreateTexture(nil, 'OVERLAY')
		f.LFDRole:SetSize(12,12)
		f.LFDRole:SetPoint('CENTER', f, 'BOTTOM', 0, 0)
    end
    --Leader icon
    li = h:CreateTexture(nil, "OVERLAY")
    li:SetPoint("TOPLEFT", f, 0, 8)
    li:SetSize(12,12)
    f.Leader = li
    --Assist icon
    ai = h:CreateTexture(nil, "OVERLAY")
    ai:SetPoint("TOPLEFT", f, 0, 8)
    ai:SetSize(12,12)
    f.Assistant = ai
    --ML icon
    local ml = h:CreateTexture(nil, 'OVERLAY')
    ml:SetSize(10,10)
    ml:SetPoint('LEFT', f.Leader, 'RIGHT')
    f.MasterLooter = ml
end

-- phase icon 
lib.addPhaseIcon = function(self)
	local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	picon:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 8, 8)
	picon:SetSize(16, 16)
	self.PhaseIcon = picon
end

-- quest icon
lib.addQuestIcon = function(self)
	local qicon = self.Health:CreateTexture(nil, 'OVERLAY')
	qicon:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 8)
	qicon:SetSize(16, 16)
	self.QuestIcon = qicon
end

--gen raid mark icons
lib.gen_RaidMark = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
    h:SetAlpha(0.8)
    local ri = h:CreateTexture(nil,'OVERLAY',h)
    ri:SetPoint("CENTER", f, "TOP", 0, 2)
	local size = retVal(f, 28, 18, 10)
    ri:SetSize(size, size)
    f.RaidIcon = ri
end

-- Create Target Border
function lib.CreateTargetBorder(self)
	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1}
	self.TargetBorder = CreateFrame("Frame", nil, self)
	self.TargetBorder:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 1)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
	self.TargetBorder:SetBackdrop(glowBorder)
	self.TargetBorder:SetFrameLevel(5)
	self.TargetBorder:SetBackdropBorderColor(.7,.7,.7,1)
	self.TargetBorder:Hide()
end

-- Raid Frames Target Highlight Border
function lib.ChangedTarget(self, event, unit)
	if UnitIsUnit('target', self.unit) then
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end
	
-- Create Raid Threat Status Border
function lib.CreateThreatBorder(self)
	local glowBorder = {edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 2}
	self.Thtborder = CreateFrame("Frame", nil, self)
	self.Thtborder:SetPoint("TOPLEFT", self, "TOPLEFT", -2, 2)
	self.Thtborder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 2, -2)
	self.Thtborder:SetBackdrop(glowBorder)
	self.Thtborder:SetFrameLevel(4)
	self.Thtborder:Hide()	
end
  
-- Raid Frames Threat Highlight
function lib.UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then return end
	
	local status = UnitThreatSituation(unit)
	unit = unit or self.unit
	if status and status > 1 then
		local r, g, b = GetThreatStatusColor(status)
		self.Thtborder:Show()
		self.Thtborder:SetBackdropBorderColor(r, g, b, 1)
	else
		self.Thtborder:SetBackdropBorderColor(r, g, b, 0)
		self.Thtborder:Hide()
	end
end
	
  
--gen castbar
lib.gen_castbar = function(f)
	if not cfg.Castbars then return end
    local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..f.mystyle, f)

    if f.mystyle == "player" or f.mystyle == "target" then
		s:SetPoint("TOPLEFT",f.Portrait,"TOPLEFT",21,0)
		s:SetHeight(f.Portrait:GetHeight()+.5)
		s:SetWidth(f:GetWidth()-39.45)
	elseif f.mystyle=="boss" then
		s:SetPoint("TOP",f.Power,"TOP",13,0)
		s:SetHeight(20)
		s:SetWidth(f:GetWidth()-26)
   else
		s:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,28)
		s:SetHeight(20)
		s:SetWidth(f:GetWidth()-24)
    end
    s:SetStatusBarTexture(cfg.statusbar_texture)
    s:SetStatusBarColor(.5, .5, 1,1)
    s:SetFrameLevel(9)
    --color
    s.CastingColor = {.5, .5, 1}
    s.CompleteColor = {0.5, 1, 0}
    s.FailColor = {1.0, 0.05, 0}
    s.ChannelingColor = {.5, .5, 1}
    --helper
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",-5,5)
    h:SetPoint("BOTTOMRIGHT",5,-5)
    lib.gen_backdrop(h)
    --backdrop
    if f.mystyle~="player" or f.mystyle~="target" then
	local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.statusbar_texture)
    b:SetAllPoints(s)
    b:SetVertexColor(.5*0.2,.5*0.2,1*0.2,0.7)
	end
    --spark
    sp = s:CreateTexture(nil, "OVERLAY")
    sp:SetBlendMode("ADD")
    sp:SetAlpha(0.5)
    sp:SetHeight(s:GetHeight()*2.5)
    --spell text
    local txt = lib.gen_fontstring(s, cfg.font, 12, "NONE")
    txt:SetPoint("LEFT", 4, 0)
    txt:SetJustifyH("LEFT")
    --time
    local t = lib.gen_fontstring(s, cfg.font, 12, "NONE")
    t:SetPoint("RIGHT", -2, 0)
    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
    --icon
    local i = s:CreateTexture(nil, "ARTWORK")
    i:SetSize(s:GetHeight(),s:GetHeight())
	if f.mystyle=='player' or f.mystyle=='target' then
		i:SetPoint("RIGHT", s, "LEFT", 0, 0)
	else
		i:SetPoint("RIGHT",s,"LEFT",-5.5,0)
	end
    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    --helper2 for icon
    local h2 = CreateFrame("Frame", nil, s)
    h2:SetFrameLevel(0)
    h2:SetPoint("TOPLEFT",i,"TOPLEFT",-5,5)
    h2:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",5,-5)
    lib.gen_backdrop(h2)
    if f.mystyle == "player" then
		--latency only for player unit
		local z = s:CreateTexture(nil,"OVERLAY")
		z:SetTexture(cfg.statusbar_texture)
		z:SetVertexColor(1,0,0,.6)
		z:SetPoint("TOPRIGHT")
		z:SetPoint("BOTTOMRIGHT")
		s:SetFrameLevel(10)
		s.SafeZone = z
		--custom latency display
		local l = lib.gen_fontstring(s, cfg.font, 10, "THINOUTLINE")
		l:SetPoint("CENTER", -2, 17)
		l:SetJustifyH("RIGHT")
		l:Hide()
		s.Lag = l
		f:RegisterEvent("UNIT_SPELLCAST_SENT", cast.OnCastSent)
    end
    s.OnUpdate = cast.OnCastbarUpdate
    s.PostCastStart = cast.PostCastStart
    s.PostChannelStart = cast.PostCastStart
    s.PostCastStop = cast.PostCastStop
    s.PostChannelStop = cast.PostChannelStop
    s.PostCastFailed = cast.PostCastFailed
    s.PostCastInterrupted = cast.PostCastFailed

	
    f.Castbar = s
    f.Castbar.Text = txt
    f.Castbar.Time = t
    f.Castbar.Icon = i
    f.Castbar.Spark = sp
  end
  
-- mirror castbar!
lib.gen_mirrorcb = function(f)
	for _, bar in pairs({'MirrorTimer1','MirrorTimer2','MirrorTimer3',}) do   
		for i, region in pairs({_G[bar]:GetRegions()}) do
			if (region.GetTexture and region:GetTexture() == 'SolidTexture') then
			  region:Hide()
			end
		end
		_G[bar..'Border']:Hide()
		_G[bar]:SetParent(UIParent)
		_G[bar]:SetScale(1)
		_G[bar]:SetHeight(16)
		_G[bar]:SetWidth(280)
		_G[bar]:SetBackdropColor(.1,.1,.1)
		_G[bar..'Background'] = _G[bar]:CreateTexture(bar..'Background', 'BACKGROUND', _G[bar])
		_G[bar..'Background']:SetTexture(cfg.statusbar_texture)
		_G[bar..'Background']:SetAllPoints(bar)
		_G[bar..'Background']:SetVertexColor(.15,.15,.15,.75)
		_G[bar..'Text']:SetFont(cfg.font, 14)
		_G[bar..'Text']:ClearAllPoints()
		_G[bar..'Text']:SetPoint('CENTER', MirrorTimer1StatusBar, 0, 1)
		_G[bar..'StatusBar']:SetAllPoints(_G[bar])
		--glowing borders
		local h = CreateFrame("Frame", nil, _G[bar])
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT",-5,5)
		h:SetPoint("BOTTOMRIGHT",5,-5)
		lib.gen_backdrop(h)
	end
end
  
  
-- Post Create Icon Function
local myPostCreateIcon = function(self, button)

	self.showDebuffType = true
	self.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.icon:SetTexCoord(.07, .93, .07, .93)
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button.overlay:SetTexture(border)
	button.overlay:SetTexCoord(0,1,0,1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.3, 0.3, 0.3) end
	
	
	button.time = lib.gen_fontstring(button, cfg.smallfont, 8, "OUTLINE")
	button.time:SetPoint("BOTTOMLEFT", button, -2, -2)
	button.time:SetJustifyH('CENTER')
	button.time:SetVertexColor(1,1,1)
	
	button.count = lib.gen_fontstring(button, cfg.smallfont, 8, "OUTLINE")
	button.count:ClearAllPoints()
	button.count:SetPoint("TOPRIGHT", button, 2, 2)
	button.count:SetVertexColor(1,1,1)	
	
	--helper
	local h = CreateFrame("Frame", nil, button)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-5,5)
	h:SetPoint("BOTTOMRIGHT",5,-5)
	lib.gen_backdrop(h)
end
  
-- Post Update Icon Function
local myPostUpdateIcon = function(self, unit, icon, index, offset, filter, isDebuff)

	local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
	
	if duration and duration > 0 then
		icon.time:Show()
		icon.timeLeft = expirationTime	
		icon:SetScript("OnUpdate", CreateBuffTimer)			
	else
		icon.time:Hide()
		icon.timeLeft = math.huge
		icon:SetScript("OnUpdate", nil)
	end
		
	-- Desaturate non-Player Debuffs
	if(icon.debuff) then
		if(unit == "target") then	
			if (unitCaster == 'player' or unitCaster == 'vehicle') then
				icon.icon:SetDesaturated(false)                 
			elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don't desaturate debuffs
				icon:SetBackdropColor(0, 0, 0)
				icon.overlay:SetVertexColor(0.3, 0.3, 0.3)      
				icon.icon:SetDesaturated(true)  
			end
		end
	end
	
	-- Right Click Cancel Buff/Debuff
	icon:SetScript('OnMouseUp', function(self, mouseButton)
		if mouseButton == 'RightButton' then
			CancelUnitBuff('player', index)
		end
	end)
	
	icon.first = true
end

local FormatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		if s <= minute * 5 then
			return format("%d:%02d", floor(s/60), s % minute), s - floor(s)
		end
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

-- Create Buff/Debuff Timer Function 
function CreateBuffTimer(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = FormatTime(self.timeLeft)
					self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, 0.5, 0.5)
				else
					self.time:SetTextColor(.7, .7, .7)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end
  
lib.createBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
    b.num = 20
    b.spacing = 5
    b.onlyShowPlayer = false
    b:SetHeight(b.size*2)
    b:SetWidth(f:GetWidth())

	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Buffs = b
end

lib.createDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 10
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight((b.size+b.spacing)*4)
    b:SetWidth(f:GetWidth())
	
    b:SetPoint("TOPLEFT", f.Power, "BOTTOMLEFT", 0, -5)
    b.initialAnchor = "TOPLEFT"
    b["growth-x"] = "RIGHT"
    b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Debuffs = b
end
  
lib.createTotAuras = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 5
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
	if (cfg.totBuffs) then f.Buffs = b end
	if (cfg.totDebuffs and not cfg.totBuffs) then f.Debuffs = b end
end  

lib.createFocusAuras = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 5
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -1)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon
	if (cfg.focusBuffs) then f.Buffs = b end
	if (cfg.focusDebuffs and not cfg.focusBuffs) then f.Debuffs = b end
end

lib.createBossBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 4
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, 0)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Buffs = b
end  

lib.createBossDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.num = 4
	b.onlyShowPlayer = false
    b.spacing = 5
    b:SetHeight(b.size)
    b:SetWidth(f:GetWidth())
	b:SetPoint("BOTTOMLEFT", f, "BOTTOMRIGHT", 5, 0)
	b.initialAnchor = "TOPLEFT"
	b["growth-x"] = "RIGHT"
	b["growth-y"] = "DOWN"
    b.PostCreateIcon = myPostCreateIcon
    b.PostUpdateIcon = myPostUpdateIcon

    f.Debuffs = b
end
 
-- portrait update
lib.PortraitPostUpdate = function(element, unit)
	if not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit) then
		element:Hide()
	else
		element:Show()
		element:SetPortraitZoom(1)
	end
end

-- raid post update
lib.PostUpdateRaidFrame = function(Health, unit, min, max)

	local disconnnected = not UnitIsConnected(unit)
	local dead = UnitIsDead(unit)
	local ghost = UnitIsGhost(unit)
	
	if disconnnected or dead or ghost then
		Health:SetValue(max)
		
		if(disconnnected) then
			Health:SetStatusBarColor(0,0,0,0.6)
		elseif(ghost) then
			Health:SetStatusBarColor(1,1,1,0.6)
		elseif(dead) then
			Health:SetStatusBarColor(1,0,0,0.7)
		end
	else
		Health:SetValue(min)
		if(unit == 'vehicle') then
			Health:SetStatusBarColor(143/255, 194/255, 32/255)
		end
	end
end

lib.addEclipseBar = function(self)
	if playerClass ~= "DRUID" then return end
	local eclipseBar = CreateFrame('Frame', nil, self)
	eclipseBar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -12)
	eclipseBar:SetFrameLevel(4)
	eclipseBar:SetHeight(6)
	eclipseBar:SetWidth(self:GetWidth())
	local h = CreateFrame("Frame", nil, eclipseBar)
	h:SetPoint("TOPLEFT",-5,5)
	h:SetPoint("BOTTOMRIGHT",5,-5)
	lib.gen_backdrop(h)
	eclipseBar.eBarBG = h

	local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
	lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
	lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
	lunarBar:SetStatusBarTexture(cfg.statusbar_texture)
	lunarBar:SetStatusBarColor(0, .1, .7)
	lunarBar:SetFrameLevel(5)

	local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
	solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
	solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
	solarBar:SetStatusBarTexture(cfg.statusbar_texture)
	solarBar:SetStatusBarColor(1,1,.13)
	solarBar:SetFrameLevel(5)
	
	
	eclipseBar.SolarBar = solarBar
	eclipseBar.LunarBar = lunarBar
	self.EclipseBar = eclipseBar
	self.EclipseBar.PostUnitAura = eclipseBarBuff
    
	local EBText = lib.gen_fontstring(solarBar, cfg.font, 14, "OUTLINE")
	EBText:SetPoint('CENTER', eclipseBar, 'CENTER', 0,0)
	local EBText2 = lib.gen_fontstring(solarBar, cfg.font, 18, "OUTLINE")
	EBText2:SetPoint('CENTER', eclipseBar, 'CENTER', 0,-15)

	self.EclipseBar.PostDirectionChange = function(element, unit)
	 EBText:SetText("")
	 EBText2:SetText("")
	end
	
	
	--self:Tag(EBText, '[pereclipse]')
	self.EclipseBar.PostUpdatePower = function(unit)
	 
	 local eclipsePowerMax = UnitPowerMax('player', SPELL_POWER_ECLIPSE)
	 local eclipsePower = math.abs(UnitPower('player', SPELL_POWER_ECLIPSE)/eclipsePowerMax*100)
	 

     if ( GetEclipseDirection() == "sun" ) then
        EBText:SetText(eclipsePower .. "  >>")
        EBText2:SetText("|cff004accSTARFIRE|r")
     elseif ( GetEclipseDirection() == "moon" ) then
        EBText:SetText("<<  " .. eclipsePower)
        EBText2:SetText("|cffcec500WRATH|r")
     else
        EBText:SetText("")
        EBText2:SetText("")
     end
	end
	
	self.EclipseBar.PostUpdateVisibility = function(unit)
	 local eclipsePowerMax = UnitPowerMax('player', SPELL_POWER_ECLIPSE)
	 local eclipsePower = math.abs(UnitPower('player', SPELL_POWER_ECLIPSE)/eclipsePowerMax*100)
	 

     if ( GetEclipseDirection() == "sun" ) then
        EBText:SetText(eclipsePower .. "  >>")
        EBText2:SetText("|cff004accSTARFIRE|r")
     elseif ( GetEclipseDirection() == "moon" ) then
        EBText:SetText("<<  " .. eclipsePower)
        EBText2:SetText("|cffcec500WRATH|r")
     else
        EBText:SetText("")
        EBText2:SetText("")
     end
	end

end

--lib.PostUpdateHarmonyBar = function(unit)
	--local maxChi = UnitPowerMax('player', SPELL_POWER_LIGHT_FORCE)
	--self.Harmony[i]:SetWidth(self.Harmony:GetWidth()/maxChi-2)
--end
--Monk harmony bar
lib.genHarmony = function(self)
	if playerClass ~= "MONK" then return end
		
	self.Harmony = CreateFrame("Frame", nil, self)
	self.Harmony:SetPoint('CENTER', self.Health, 'TOP', 0, 0)
	self.Harmony:SetHeight(5)
	self.Harmony:SetWidth(self.Health:GetWidth()/2+75)
	
	local maxChi = UnitPowerMax('player', SPELL_POWER_LIGHT_FORCE)
	
	for i = 1,maxChi do
		self.Harmony[i] = CreateFrame("StatusBar", self:GetName().."_Harmony"..i, self)
		self.Harmony[i]:SetHeight(5)
		self.Harmony[i]:SetWidth(self.Harmony:GetWidth()/maxChi-2)
		self.Harmony[i]:SetStatusBarTexture(cfg.statusbar_texture)
		self.Harmony[i]:SetStatusBarColor(.90,.99,.90)
		self.Harmony[i]:SetFrameLevel(11)
		self.Harmony[i].bg = self.Harmony[i]:CreateTexture(nil, "BORDER")
		self.Harmony[i].bg:SetTexture(cfg.statusbar_texture)
		self.Harmony[i].bg:SetPoint("TOPLEFT", self.Harmony[i], "TOPLEFT", 0, 0)
		self.Harmony[i].bg:SetPoint("BOTTOMRIGHT", self.Harmony[i], "BOTTOMRIGHT", 0, 0)
		self.Harmony[i].bg.multiplier = 0.3
		
		--helper backdrop
		local h = CreateFrame("Frame", nil, self.Harmony[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.gen_power_backdrop(h)
		
		if (i == 1) then
			self.Harmony[i]:SetPoint('LEFT', self.Harmony, 'LEFT', 1, 0)
		else
			self.Harmony[i]:SetPoint('TOPLEFT', self.Harmony[i-1], 'TOPRIGHT', 2, 0)
		end
	end
	
end

--Shadow Orbs bar
lib.genShadoworbs = function(self)
	if playerClass ~= "PRIEST" then return end
	
	self.ShadowOrbs = CreateFrame("Frame", nil, self)
	self.ShadowOrbs:SetPoint('CENTER', self.Health, 'TOP', 0, 0)
	self.ShadowOrbs:SetHeight(5)
	self.ShadowOrbs:SetWidth(self.Health:GetWidth()/2)
	
	local maxShadowOrbs = UnitPowerMax('player', SPELL_POWER_SHADOW_ORBS)
	
	for i = 1,maxShadowOrbs do
		self.ShadowOrbs[i] = CreateFrame("StatusBar", self:GetName().."_ShadowOrbs"..i, self)
		self.ShadowOrbs[i]:SetHeight(5)
		self.ShadowOrbs[i]:SetWidth(self.ShadowOrbs:GetWidth()/3-2)
		self.ShadowOrbs[i]:SetStatusBarTexture(cfg.statusbar_texture)
		self.ShadowOrbs[i]:SetStatusBarColor(.86,.22,1)
		self.ShadowOrbs[i]:SetFrameLevel(11)
		self.ShadowOrbs[i].bg = self.ShadowOrbs[i]:CreateTexture(nil, "BORDER")
		self.ShadowOrbs[i].bg:SetTexture(cfg.statusbar_texture)
		self.ShadowOrbs[i].bg:SetPoint("TOPLEFT", self.ShadowOrbs[i], "TOPLEFT", 0, 0)
		self.ShadowOrbs[i].bg:SetPoint("BOTTOMRIGHT", self.ShadowOrbs[i], "BOTTOMRIGHT", 0, 0)
		self.ShadowOrbs[i].bg.multiplier = 0.3
		
		--helper backdrop
		local h = CreateFrame("Frame", nil, self.ShadowOrbs[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.gen_power_backdrop(h)
		
		if (i == 1) then
			self.ShadowOrbs[i]:SetPoint('LEFT', self.ShadowOrbs, 'LEFT', 1, 0)
		else
			self.ShadowOrbs[i]:SetPoint('TOPLEFT', self.ShadowOrbs[i-1], 'TOPRIGHT', 2, 0)
		end
	end
end

-- SoulShard bar

lib.genShards = function(self)
--[[	
if playerClass ~= "WARLOCK" then return end
	
	self.SoulShards = CreateFrame("Frame", nil, self)
	self.SoulShards:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', -1, -3)
	self.SoulShards:SetHeight(4)
	self.SoulShards:SetWidth(self.Health:GetWidth())
		
	for i = 1, 3 do
		self.SoulShards[i] = CreateFrame("StatusBar", self:GetName().."_SoulShards"..i, self)
		self.SoulShards[i]:SetHeight(4)
		self.SoulShards[i]:SetWidth((self.Health:GetWidth() / 3)-1)
		self.SoulShards[i]:SetStatusBarTexture(cfg.statusbar_texture)
		self.SoulShards[i]:SetStatusBarColor(.86,.44, 1)
		self.SoulShards[i]:SetFrameLevel(11)
		self.SoulShards[i].bg = self.SoulShards[i]:CreateTexture(nil, "BORDER")
		self.SoulShards[i].bg:SetTexture(cfg.statusbar_texture)
		self.SoulShards[i].bg:SetPoint("TOPLEFT", self.SoulShards[i], "TOPLEFT", 0, 0)
		self.SoulShards[i].bg:SetPoint("BOTTOMRIGHT", self.SoulShards[i], "BOTTOMRIGHT", 0, 0)
		self.SoulShards[i].bg.multiplier = 0.3

		local h = CreateFrame("Frame", nil, self.SoulShards[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",4,-4)
		lib.gen_backdrop(h)
		
		if (i == 1) then
			self.SoulShards[i]:SetPoint('LEFT', self.SoulShards, 'LEFT', 1, 0)
		else
			self.SoulShards[i]:SetPoint('TOPLEFT', self.SoulShards[i-1], "TOPRIGHT", 2, 0)
		end

	end
--]]
end


-- HolyPowerbar
lib.genHolyPower = function(self)
	if playerClass ~= "PALADIN" then return end
	
	self.HolyPower = CreateFrame("Frame", nil, self)
	self.HolyPower:SetPoint('CENTER', self.Power, 'TOP', 0, 0)
	self.HolyPower:SetHeight(5)
	self.HolyPower:SetWidth(self.Health:GetWidth()/2+75)
	
	for i = 1, 5 do
		self.HolyPower[i] = CreateFrame("StatusBar", self:GetName().."_Holypower"..i, self)
		self.HolyPower[i]:SetHeight(5)
		self.HolyPower[i]:SetWidth((self.HolyPower:GetWidth()/5)-2)
		self.HolyPower[i]:SetStatusBarTexture(cfg.statusbar_texture)
		self.HolyPower[i]:SetStatusBarColor(.9,.95,.33)
		self.HolyPower[i]:SetFrameLevel(11)
		self.HolyPower[i].bg = self.HolyPower[i]:CreateTexture(nil, "BORDER")
		self.HolyPower[i].bg:SetTexture(cfg.statusbar_texture)
		self.HolyPower[i].bg:SetPoint("TOPLEFT", self.HolyPower[i], "TOPLEFT", 0, 0)
		self.HolyPower[i].bg:SetPoint("BOTTOMRIGHT", self.HolyPower[i], "BOTTOMRIGHT", 0, 0)
		self.HolyPower[i].bg.multiplier = 0.3

		local h = CreateFrame("Frame", nil, self.HolyPower[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.gen_power_backdrop(h)
		
		if (i == 1) then
			self.HolyPower[i]:SetPoint('LEFT', self.HolyPower, 'LEFT', 1, 0)
		else
			self.HolyPower[i]:SetPoint('TOPLEFT', self.HolyPower[i-1], "TOPRIGHT", 2, 0)
		end

	end
end

-- runebar
lib.genRunes = function(self)
	if playerClass ~= "DEATHKNIGHT" then return end

	self.Runes = CreateFrame("Frame", nil, self)
	self.Runes:SetPoint('CENTER', self.Health, 'TOP', 0, 0)
	self.Runes:SetHeight(5)
	self.Runes:SetWidth(self.Health:GetWidth()-15)

	
	for i= 1, 6 do
		self.Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
		self.Runes[i]:SetHeight(5)
		self.Runes[i]:SetWidth((self.Health:GetWidth() / 6)-5)
		self.Runes[i]:SetStatusBarTexture(cfg.statusbar_texture)
		self.Runes[i]:SetFrameLevel(11)
		self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, "BORDER")
		self.Runes[i].bg:SetTexture(cfg.statusbar_texture)
		self.Runes[i].bg:SetPoint("TOPLEFT", self.Runes[i], "TOPLEFT", 0, 0)
		self.Runes[i].bg:SetPoint("BOTTOMRIGHT", self.Runes[i], "BOTTOMRIGHT", 0, 0)
		self.Runes[i].bg.multiplier = 0.3
		
		local h = CreateFrame("Frame", nil, self.Runes[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-3,3)
		h:SetPoint("BOTTOMRIGHT",3,-3)
		lib.gen_power_backdrop(h)
		
		if (i == 1) then
			self.Runes[i]:SetPoint('LEFT', self.Runes, 'LEFT', 1, 0)
		else
			self.Runes[i]:SetPoint('TOPLEFT', self.Runes[i-1], 'TOPRIGHT', 2, 0)
		end
	end
end

-- combo points
lib.genCPoints = function(self)
	if (playerClass == "ROGUE" or playerClass == "DRUID") then
		self.CPoints = CreateFrame("Frame", nil, self)
		self.CPoints:SetPoint('CENTER', self.Health, 'TOP', 0, 0)
		self.CPoints:SetHeight(5)
		self.CPoints:SetWidth(self.Health:GetWidth()/2+75)

		for i= 1, 5 do
			self.CPoints[i] = CreateFrame("StatusBar", self:GetName().."_CPoints"..i, self)
			self.CPoints[i]:SetHeight(5)
			self.CPoints[i]:SetWidth((self.Health:GetWidth()/5)-2)
			self.CPoints[i]:SetStatusBarTexture(cfg.statusbar_texture)
			self.CPoints[i]:SetFrameLevel(11)
			self.CPoints[i].bg = self.CPoints[i]:CreateTexture(nil, "BORDER")
			self.CPoints[i].bg:SetTexture(cfg.statusbar_texture)
			self.CPoints[i].bg:SetPoint("TOPLEFT", self.CPoints[i], "TOPLEFT", 0, 0)
			self.CPoints[i].bg:SetPoint("BOTTOMRIGHT", self.CPoints[i], "BOTTOMRIGHT", 0, 0)
			self.CPoints[i].bg.multiplier = 0.3
			
			local h = CreateFrame("Frame", nil, self.CPoints[i])
			h:SetFrameLevel(10)
			h:SetPoint("TOPLEFT",-3,3)
			h:SetPoint("BOTTOMRIGHT",3,-3)
			lib.gen_power_backdrop(h)
			
			if (i == 1) then
				self.CPoints[i]:SetPoint('LEFT', self.CPoints, 'LEFT', 1, 0)
			else
				self.CPoints[i]:SetPoint('TOPLEFT', self.CPoints[i-1], 'TOPRIGHT', 2, 0)
			end
		end
		self.CPoints[1]:SetStatusBarColor(.3,.9,.9)
		self.CPoints[2]:SetStatusBarColor(.3,.9,.9)
		self.CPoints[3]:SetStatusBarColor(.3,.9,.3)
		self.CPoints[4]:SetStatusBarColor(.3,.9,.3)
		self.CPoints[5]:SetStatusBarColor(.9,.3,.3)	
	end
end

-- ReadyCheck
lib.ReadyCheck = function(self)
	rCheck = self.Health:CreateTexture(nil, "OVERLAY")
	rCheck:SetSize(14, 14)
	rCheck:SetPoint("BOTTOMLEFT", self.Health, "TOPRIGHT", -13, -12)
	self.ReadyCheck = rCheck
end

-- oUF_HealPred
lib.HealPred = function(self)
	if not cfg.ShowIncHeals then return end
	
	local mhpb = CreateFrame('StatusBar', nil, self.Health)
	mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	mhpb:SetWidth(self:GetWidth())
	mhpb:SetStatusBarTexture(cfg.statusbar_texture)
	mhpb:SetStatusBarColor(0, 200/255, 0, 0.8)
	mhpb:SetFrameLevel(2)

	local ohpb = CreateFrame('StatusBar', nil, self.Health)
	--if mhpb:GetStatusBarTexture()==nil then
	--ohpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	--ohpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	--else
	ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	--end
	ohpb:SetWidth(self:GetWidth())
	ohpb:SetStatusBarTexture(cfg.statusbar_texture)
	ohpb:SetStatusBarColor(0, 200/255, 0, 0.8)
	ohpb:SetFrameLevel(2)

	self.HealPrediction = {
		-- status bar to show my incoming heals
		myBar = mhpb,

		-- status bar to show other peoples incoming heals
		otherBar = ohpb,

		-- amount of overflow past the end of the health bar
		maxOverflow = 1.01,
	}
end


-- Addons -------------------------------------------

lib.gen_Exp = function(self)
	--if UnitLevel("self") ~= MAX_PLAYER_LEVEL then
	self.Experience = CreateFrame('StatusBar', nil, self)
	self.Experience:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', ((self.Health:GetWidth()-self.Portrait:GetWidth())/2), 29)
	self.Experience:SetWidth(self.Portrait:GetWidth())
	self.Experience:SetHeight(3)
	self.Experience:SetFrameLevel(6)
	self.Experience:SetStatusBarTexture(cfg.statusbar_texture)
	self.Experience:GetStatusBarTexture():SetHorizTile(false)
	self.Experience:SetStatusBarColor(.407, .13, .545)
	
	self.Experience.Rested = CreateFrame('StatusBar',nil,self.Experience)
	self.Experience.Rested:SetAllPoints(self.Experience)
	self.Experience.Rested:SetStatusBarTexture(cfg.statusbar_texture)
	self.Experience.Rested:SetStatusBarColor(.117,.55,1)

	self.Experience.Rested.bg = self.Experience.Rested:CreateTexture(nil, 'BACKGROUND')
	self.Experience.Rested.bg:SetAllPoints(self.Experience)
	self.Experience.Rested.bg:SetTexture(cfg.statusbar_texture)
	self.Experience.Rested.bg:SetVertexColor(0,0,0)

	local h = CreateFrame("Frame", nil, self.Experience.Rested)
	h:SetFrameLevel(5)
	h:SetPoint("TOPLEFT",-3,3)
	h:SetPoint("BOTTOMRIGHT",3,-3)
		local backdrop_tab = {
			bgFile = cfg.backdrop_texture,
			edgeFile = cfg.backdrop_edge_texture,
			tile = false,
			tileSize = 0,
			edgeSize = 4,
			insets = {
			  left = 2,
			  right = 2,
			  top = 2,
			  bottom = 2,
			},
		  }
	h:SetBackdrop(backdrop_tab);
	h:SetBackdropColor(0,0,0,1)
	h:SetBackdropBorderColor(0,0,0,0.8)
	
	self.Experience.Text = lib.gen_fontstring(self.Experience,cfg.smallfont,9,'OUTLINE')
	self.Experience.Text:SetPoint("CENTER",self.Experience,"TOP",10,2)
	self:Tag(self.Experience.Text,"[drk:xp]")
			
	self.Experience.Text:SetAlpha(0)
	self.Experience.PostUpdate = ExpOverrideText
		
	--end
end


--gen hilight texture
lib.gen_highlight = function(f)
    local OnEnter = function(f)
		UnitFrame_OnEnter(f)
		f.Highlight:Show()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0.9)
		end
    end
    local OnLeave = function(f)
		UnitFrame_OnLeave(f)
		f.Highlight:Hide()
		if f.Experience ~= nil then
			f.Experience.Text:SetAlpha(0)
		end
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)
    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture(cfg.highlight_texture)
    hl:SetVertexColor(.5,.5,.5,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
end


-----------------------------
-- HANDOVER
-----------------------------

--hand the lib to the namespace for further usage...this is awesome because you can reuse functions in any of your layout files
ns.lib = lib