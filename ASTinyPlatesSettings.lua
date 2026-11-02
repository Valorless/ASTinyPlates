-- Settings window and minimap button.
-- Options live in ASTinyPlatesDB; the minimap button angle is saved in ASTinyPlatesDB.minimapAngle.
-- ASTinyPlatesOption(key) is read by ASTinyPlates.lua on every update, so changes apply live.
local window;
local mmButton;
local checkboxes = {};
local DEFAULT_ANGLE = 140;
local DEFAULTS = {
	showDebuffs = true,
	hideShrunkPlates = false,
	hideBossName = false,
	showShrunkName = false,
};

-- Keeps our named frames above the Azeroth Survivors level-up/jewelry cards, as ASDrops does.
function ASTinyPlatesKeepOnTop(frame)
	if ( AZS_SetOnTopOfScreens and frame ) then
		pcall(AZS_SetOnTopOfScreens, frame, true);
	end
end

local function MainDB()
	if ( type(ASTinyPlatesDB) ~= "table" ) then ASTinyPlatesDB = {}; end
	return ASTinyPlatesDB;
end

function ASTinyPlatesOption(key)
	local db = ASTinyPlatesDB;
	if ( type(db) == "table" and db[key] ~= nil ) then return db[key] and true or false; end
	return DEFAULTS[key];
end

local OPTIONS = {
	{ key = "showDebuffs", label = "Show debuffs",
		tip = "Show the debuff icons below boss and guardian plates." },
	{ key = "hideBossName", label = "Hide name",
		tip = "Hide the name shown above boss and guardian nameplates." },
	{ key = "hideShrunkPlates", 	label = "Hide nameplates", gap = true,
			tip = "Hide the regular mob nameplates completely, leaving only boss and guardian plates.",
		note = "Requires Overlapping nameplates." },
	{ key = "showShrunkName", 	label = "Show name", disabledBy = "hideShrunkPlates",
			tip = "Show the regular mob's name above nameplates. Not used while 'Hide regular plates' is on." },
};

local function UpdateCheckboxes()
	if ( not window ) then return; end
	for i = 1, table.getn(OPTIONS) do
		local option = OPTIONS[i];
		local box = checkboxes[option.key];
		box:SetChecked(ASTinyPlatesOption(option.key) and 1 or nil);
		local text = getglobal(box:GetName() .. "Text");
		if ( option.disabledBy and ASTinyPlatesOption(option.disabledBy) ) then
			box:Disable();
			if ( text ) then text:SetTextColor(0.5, 0.5, 0.5); end
		else
			box:Enable();
			if ( text ) then text:SetTextColor(1, 0.82, 0); end
		end
	end
end

local function CreateCheckbox(option, index, y)
	local box = CreateFrame("CheckButton", "ASTinyPlatesSettingsCheck" .. index, window, "UICheckButtonTemplate");
	if ( ASTinyPlatesKeepOnTop ) then ASTinyPlatesKeepOnTop(box); end
	box:SetWidth(26);
	box:SetHeight(26);
	box:SetPoint("TOPLEFT", window, "TOPLEFT", 16, y);
	local text = getglobal(box:GetName() .. "Text");
	if ( text ) then text:SetText(option.label); end
	box.option = option;
	box:SetScript("OnClick", function()
		MainDB()[this.option.key] = this:GetChecked() and true or false;
		UpdateCheckboxes();
	end);
	box:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
		GameTooltip:SetText(this.option.label, 1, 0.82, 0);
		GameTooltip:AddLine(this.option.tip, 0.9, 0.9, 0.9, 1);
		if ( this.option.note ) then GameTooltip:AddLine(this.option.note, 1, 0.3, 0.3, 1); end
		GameTooltip:Show();
	end);
	box:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	checkboxes[option.key] = box;
end

local function CreateWindow()
	window = CreateFrame("Frame", "ASTinyPlatesSettingsFrame", UIParent);
	if ( ASTinyPlatesKeepOnTop ) then ASTinyPlatesKeepOnTop(window); end
	window:SetWidth(320);
	window:SetHeight(200);
	window:SetPoint("CENTER", UIParent, "CENTER", 0, 60);
	window:SetFrameStrata("DIALOG");
	window:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	});
	window:SetMovable(true);
	window:EnableMouse(true);
	window:SetClampedToScreen(true);
	window:RegisterForDrag("LeftButton");
	window:SetScript("OnDragStart", function() this:StartMoving(); end);
	window:SetScript("OnDragStop", function() this:StopMovingOrSizing(); end);
	window:Hide();
	table.insert(UISpecialFrames, "ASTinyPlatesSettingsFrame");
	window:SetScript("OnShow", UpdateCheckboxes);

	local title = window:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	title:SetPoint("TOP", window, "TOP", 0, -16);
	title:SetText("ASTinyPlates Settings");
	local close = CreateFrame("Button", "ASTinyPlatesSettingsClose", window, "UIPanelCloseButton");
	if ( ASTinyPlatesKeepOnTop ) then ASTinyPlatesKeepOnTop(close); end
	close:SetPoint("TOPRIGHT", window, "TOPRIGHT", -6, -6);

	local bossLabel = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
	bossLabel:SetPoint("TOPLEFT", window, "TOPLEFT", 20, -42);
	bossLabel:SetText("Boss & Guardian Plates");
	local y = -54;
	for i = 1, table.getn(OPTIONS) do
		local option = OPTIONS[i];
		if ( option.gap ) then
			y = y - 10;
			local shrunkLabel = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
			shrunkLabel:SetPoint("TOPLEFT", window, "TOPLEFT", 20, y - 2);
			shrunkLabel:SetText("Regular Plates");
			y = y - 14;
		end
		CreateCheckbox(option, i, y);
		y = y - 28;
	end
	window:SetHeight(-y + 22);
	UpdateCheckboxes();
end

function ASTinyPlatesToggleSettings()
	if ( not window ) then CreateWindow(); end
	if ( window:IsShown() ) then window:Hide(); else window:Show(); end
end

local function SquareMinimap()
	if ( type(IsAddOnLoaded) ~= "function" ) then return false; end
	local ok, loaded = pcall(IsAddOnLoaded, "SurvivorsDragonUi");
	return ok and loaded and true or false;
end

local function PlaceMinimapButton()
	local angle = tonumber(MainDB().minimapAngle) or DEFAULT_ANGLE;
	local a = math.rad(angle);
	local c, s = math.cos(a), math.sin(a);
	local half = (Minimap:GetWidth() or 140) / 2;
	local x, y;
	if ( SquareMinimap() ) then
		local r = half + 6;
		local m = math.max(math.abs(c), math.abs(s));
		x, y = c * r / m, s * r / m;
	else
		local r = half + 10;
		x, y = c * r, s * r;
	end
	mmButton:ClearAllPoints();
	mmButton:SetPoint("CENTER", Minimap, "CENTER", x, y);
end

local function CreateMinimapButton()
	if ( not Minimap ) then return; end
	mmButton = CreateFrame("Button", "ASTinyPlatesMinimapButton", Minimap);
	if ( ASTinyPlatesKeepOnTop ) then ASTinyPlatesKeepOnTop(mmButton); end
	mmButton:SetWidth(31);
	mmButton:SetHeight(31);
	mmButton:SetFrameStrata("MEDIUM");
	mmButton:SetFrameLevel((Minimap:GetFrameLevel() or 1) + 8);
	mmButton:RegisterForClicks("LeftButtonUp");
	mmButton:RegisterForDrag("LeftButton");
	local icon = mmButton:CreateTexture(nil, "ARTWORK");
	icon:SetWidth(20);
	icon:SetHeight(20);
	icon:SetPoint("CENTER", mmButton, "CENTER", 0, 1);
	icon:SetTexture("Interface\\Icons\\INV_Misc_Head_Dragon_01");
	local border = mmButton:CreateTexture(nil, "OVERLAY");
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
	border:SetWidth(53);
	border:SetHeight(53);
	border:SetPoint("TOPLEFT", mmButton, "TOPLEFT", 0, 0);
	mmButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");
	mmButton:SetScript("OnClick", function()
		GameTooltip:Hide();
		ASTinyPlatesToggleSettings();
	end);
	mmButton:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_LEFT");
		GameTooltip:AddLine("ASTinyPlates", 1, 0.82, 0);
		GameTooltip:AddLine("Click: open or close the settings", 0.9, 0.9, 0.9);
		GameTooltip:AddLine("Drag: move round the minimap", 0.6, 0.6, 0.6);
		GameTooltip:Show();
	end);
	mmButton:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	mmButton:SetScript("OnDragStart", function()
		GameTooltip:Hide();
		this.dragging = true;
	end);
	mmButton:SetScript("OnDragStop", function() this.dragging = nil; end);
	mmButton:SetScript("OnUpdate", function()
		if ( not this.dragging ) then return; end
		local x, y = GetCursorPosition();
		local scale = Minimap:GetEffectiveScale();
		local cx, cy = Minimap:GetCenter();
		local dx, dy = x / scale - cx, y / scale - cy;
		local deg = math.deg((math.atan2 or math.atan)(dy, dx));
		if ( deg < 0 ) then deg = deg + 360; end
		MainDB().minimapAngle = deg;
		PlaceMinimapButton();
	end);
	PlaceMinimapButton();
	mmButton:Show();
end

SLASH_ASTINYPLATES1 = "/astp";
SLASH_ASTINYPLATES2 = "/astinyplates";
SlashCmdList["ASTINYPLATES"] = function(message)
	local command = string.lower(message or "");
	if ( command == "" or command == "settings" or command == "options" or command == "config" ) then
		ASTinyPlatesToggleSettings();
		return;
	end
	DEFAULT_CHAT_FRAME:AddMessage("ASTinyPlates: /astp opens the settings; /astpdebug inspects boss/guardian plates.", 1, 0.8, 0.2);
end

local starter = CreateFrame("Frame", "ASTinyPlatesSettingsEvents");
if ( ASTinyPlatesKeepOnTop ) then ASTinyPlatesKeepOnTop(starter); end
starter:RegisterEvent("PLAYER_ENTERING_WORLD");
starter:SetScript("OnEvent", function()
	if ( not mmButton ) then CreateMinimapButton(); end
	if ( window ) then UpdateCheckboxes(); end
end);
