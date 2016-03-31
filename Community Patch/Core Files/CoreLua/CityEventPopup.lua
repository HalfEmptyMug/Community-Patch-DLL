-------------------------------------------------
-- Goody Hut Popup
-------------------------------------------------
include("FLuaVector.lua")
local m_PopupInfo = nil;

-------------------------------------------------
-- On Display
-------------------------------------------------
local g_pCity = nil
local tChoiceOverrideStrings = {}
function OnPopup( popupInfo )

	if( popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_MODDER_7 ) then
		return;
	end

	m_PopupInfo = popupInfo;

    local iEventChoiceType = popupInfo.Data1;
	local cityID = popupInfo.Data2;
    local pEventChoiceInfo = GameInfo.CityEventChoices[iEventChoiceType];

	-- Top Art
	local pEventInfo = GameInfo.CityEvents[pEventChoiceInfo.ParentEvent];
	local pEventArt = pEventInfo.CityEventArt
	if pEventArt then
		Controls.EventArt:SetTexture(pEventArt);
		Controls.EventArt:SetSizeVal(350,100);
		Controls.EventArt:SetAlpha(0.2);
		Controls.EventArt:SetHide(false);
		Controls.EventArtFrame:SetHide(false);
	else
		Controls.EventArt:SetHide(true);
		Controls.EventArtFrame:SetHide(true);
	end
	
	-- Event Audio
	local pEventAudio = pEventInfo.CityEventAudio
	if pEventAudio then
		Events.AudioPlay2DSound(pEventAudio)
	end
	
	local playerID = Game.GetActivePlayer()
	local player = Players[playerID];
	local city = player:GetCityByID(cityID);
	g_pCity = city

	local cityName = city:GetNameKey();
	local localizedCityName = Locale.ConvertTextKey(cityName);

	local szTitleString;
	local szHelpString;
	szTitleString = Locale.Lookup("TXT_KEY_CITY_EVENT_TITLE", localizedCityName, pEventChoiceInfo.Description);
	szHelpString = Locale.Lookup("TXT_KEY_CITY_EVENT_HELP", localizedCityName, pEventChoiceInfo.Help);

	-- Test for any Override Strings
	tChoiceOverrideStrings = {}
	LuaEvents.EventChoice_OverrideTextStrings(playerID, cityID, pEventChoiceInfo, tChoiceOverrideStrings)
	for _,str in ipairs(tChoiceOverrideStrings) do
		szTitleString = str.Description or szTitleString
		szHelpString = str.Help or szHelpString
	end
	
	Controls.TitleLabel:SetText(szTitleString);
	Controls.DescriptionLabel:SetText(szHelpString);
		
	UIManager:QueuePopup( ContextPtr, PopupPriority.GoodyHut );
end
Events.SerialEventGameMessagePopup.Add( OnPopup );


----------------------------------------------------------------        
-- Input processing
----------------------------------------------------------------        
function OnCloseButtonClicked ()
    UIManager:DequeuePopup( ContextPtr );
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnCloseButtonClicked );


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyDown then
        if wParam == Keys.VK_ESCAPE or wParam == Keys.VK_RETURN then
            OnCloseButtonClicked();
            return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnFindOnMapButtonClicked()
	if (g_pCity) then
		local plot = g_pCity:Plot();
		if plot then
			UI.LookAt(plot, 0);
			local hex = ToHexFromGrid(Vector2(plot:GetX(), plot:GetY()))
			Events.GameplayFX(hex.x, hex.y, -1) 
		end
	end
end
Controls.FindOnMapButton:RegisterCallback( Mouse.eLClick, OnFindOnMapButtonClicked );
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )

    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();
        	Events.SerialEventGameMessagePopupShown(m_PopupInfo);
        else
            UI.decTurnTimerSemaphore();
            Events.SerialEventGameMessagePopupProcessed.CallImmediate(ButtonPopupTypes.BUTTONPOPUP_MODDER_7, 0);
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnActivePlayerChanged( iActivePlayer, iPrevActivePlayer )
	if (not ContextPtr:IsHidden()) then
		ContextPtr:SetHide(true);
	end
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged);