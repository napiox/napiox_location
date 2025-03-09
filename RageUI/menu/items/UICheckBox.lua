
local SettingsButton = {
    Rectangle = { Y = 5, Width = 500, Height = 43 },
    Text = { X = 25, Y = 12, Scale = 0.28 },
    LeftBadge = { Y = 3, Width = 40, Height = 40 },
    RightBadge = { X = 375, Y = 5, Width = 40, Height = 40 },
    SelectedSprite = { Dictionary = "commonmenu", Texture = "gradient_nav", Y = 5, Width = 431, Height = 38 },
}


local SettingsCheckbox = {
    Dictionary = "commonmenu",
    Textures = {
        "shop_box_blankb", 
        "shop_box_tickb", 
        "shop_box_blank", 
        "shop_box_tick", 
        "shop_box_crossb", 
        "shop_box_cross", 
    },
    X = 375, 
    Y = 2, 
    Width = 40, 
    Height = 40
}

RageUI.CheckboxStyle = {
    Tick = 1,
    Cross = 2
}








local function StyleCheckBox(Selected, Checked, Box, BoxSelect, OffSet)
    
    local CurrentMenu = RageUI.CurrentMenu;
    if OffSet == nil then
        OffSet = 0
    end

    if Checked then
        RenderSprite(SettingsCheckbox.Dictionary, SettingsCheckbox.Textures[BoxSelect], CurrentMenu.X + SettingsCheckbox.X + CurrentMenu.WidthOffset - OffSet, CurrentMenu.Y + SettingsCheckbox.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsCheckbox.Width, SettingsCheckbox.Height)
    else
        RenderSprite(SettingsCheckbox.Dictionary, SettingsCheckbox.Textures[3], CurrentMenu.X + SettingsCheckbox.X + CurrentMenu.WidthOffset - OffSet, CurrentMenu.Y + SettingsCheckbox.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsCheckbox.Width, SettingsCheckbox.Height)
    end
end

local progressValue = 0
local isStarted = false
local canInteract = true
local isThreadCreateded = false
local alpha = 100

function RageUI.Checkbox(Label, Description, Checked, Style, Actions)
    
    local CurrentMenu = RageUI.CurrentMenu;
    if CurrentMenu ~= nil then
        if CurrentMenu() then

            
            local Option = RageUI.Options + 1
            if CurrentMenu.Pagination.Minimum <= Option and CurrentMenu.Pagination.Maximum >= Option then
                
                local Selected = CurrentMenu.Index == Option
                local LeftBadgeOffset = ((Style.LeftBadge == RageUI.BadgeStyle.None or Style.LeftBadge == nil) and 0 or 27)
                local RightBadgeOffset = ((Style.RightBadge == RageUI.BadgeStyle.None or Style.RightBadge == nil) and 0 or 32)
                local BoxOffset = 0
                RageUI.ItemsSafeZone(CurrentMenu)


                if Selected then
                   RenderRectangle(CurrentMenu.X + 15, CurrentMenu.Y + SettingsButton.SelectedSprite.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButton.SelectedSprite.Width + CurrentMenu.WidthOffset - 30, SettingsButton.SelectedSprite.Height + 1, 16, 82, 186, 255)
                else
                    RenderRectangle(CurrentMenu.X + 15, CurrentMenu.Y + SettingsButton.SelectedSprite.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButton.SelectedSprite.Width + CurrentMenu.WidthOffset - 30, SettingsButton.SelectedSprite.Height + 1, 0, 0, 0, 128)
                end
                if not isThreadCreateded then
                    isThreadCreateded = true
                    Citizen.CreateThread(function() 
                        while true do
                            if progressValue <= 5 then 
                                progressValue = progressValue + 2
                            else
                                progressValue = progressValue + 7
                            end
                            
                            alpha = alpha - 3,5
    
                            if progressValue >= 300 then 
                                progressValue = 0
                                alpha = 100
                                canInteract = false
                            end
    
                            if not RageUI.CurrentMenu then 
                                isThreadCreateded = false
                                canInteract = true
                                return
                            end
    
                            Wait(10)
                        end
                    end)
                end

                if Selected and canInteract then
                    local rectangle_anim = RenderRectangle(CurrentMenu.X + 15 + progressValue, CurrentMenu.Y + SettingsButton.SelectedSprite.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButton.SelectedSprite.Width + CurrentMenu.WidthOffset - 300, SettingsButton.SelectedSprite.Height + 1, 255, 255, 255, alpha) 
                end 

                if type(Style) == "table" then
                    if Style.Enabled == true or Style.Enabled == nil then
                        if Selected then
                            RenderText(Label, CurrentMenu.X + SettingsButton.Text.X + LeftBadgeOffset, CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButton.Text.Scale, 255, 255, 255, 255)
                        else
                            RenderText(Label, CurrentMenu.X + SettingsButton.Text.X + LeftBadgeOffset, CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButton.Text.Scale, 255, 255, 255, 255)
                        end
                        if type(Style) == 'table' then
                            if Style.LeftBadge ~= nil then
                                if Style.LeftBadge ~= RageUI.BadgeStyle.None then
                                    local BadgeData = Style.LeftBadge(Selected)
                                    RenderSprite(BadgeData.BadgeDictionary or "commonmenu", BadgeData.BadgeTexture or "", CurrentMenu.X, CurrentMenu.Y + SettingsButton.LeftBadge.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButton.LeftBadge.Width, SettingsButton.LeftBadge.Height, 0, BadgeData.BadgeColour and BadgeData.BadgeColour.R or 255, BadgeData.BadgeColour and BadgeData.BadgeColour.G or 255, BadgeData.BadgeColour and BadgeData.BadgeColour.B or 255, BadgeData.BadgeColour and BadgeData.BadgeColour.A or 255)
                                end
                            end
                            if Style.RightBadge ~= nil then
                                if Style.RightBadge ~= RageUI.BadgeStyle.None then
                                    local BadgeData = Style.RightBadge(Selected)
                                    RenderSprite(BadgeData.BadgeDictionary or "commonmenu", BadgeData.BadgeTexture or "", CurrentMenu.X + SettingsButton.RightBadge.X + CurrentMenu.WidthOffset, CurrentMenu.Y + SettingsButton.RightBadge.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButton.RightBadge.Width, SettingsButton.RightBadge.Height, 0, BadgeData.BadgeColour and BadgeData.BadgeColour.R or 255, BadgeData.BadgeColour and BadgeData.BadgeColour.G or 255, BadgeData.BadgeColour and BadgeData.BadgeColour.B or 255, BadgeData.BadgeColour and BadgeData.BadgeColour.A or 255)
                                end
                            end
                        end
                    else
                        
                        local LeftBadge = RageUI.BadgeStyle.Lock
                        
                        local LeftBadgeOffset = ((LeftBadge == RageUI.BadgeStyle.None or LeftBadge == nil) and 0 or 27)

                        if Selected then
                            RenderText(Label, CurrentMenu.X + SettingsButton.Text.X + LeftBadgeOffset, CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 8, SettingsButton.Text.Scale, 0, 0, 0, 255)
                        else
                            RenderText(Label, CurrentMenu.X + SettingsButton.Text.X + LeftBadgeOffset, CurrentMenu.Y + SettingsButton.Text.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 8, SettingsButton.Text.Scale, 163, 159, 148, 255)
                        end

                        if LeftBadge ~= RageUI.BadgeStyle.None and LeftBadge ~= nil then
                            local BadgeData = LeftBadge(Selected)

                            RenderSprite(BadgeData.BadgeDictionary or "commonmenu", BadgeData.BadgeTexture or "", CurrentMenu.X, CurrentMenu.Y + SettingsButton.LeftBadge.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, SettingsButton.LeftBadge.Width, SettingsButton.LeftBadge.Height, 0, BadgeData.BadgeColour.R or 255, BadgeData.BadgeColour.G or 255, BadgeData.BadgeColour.B or 255, BadgeData.BadgeColour.A or 255)
                        end
                    end

                    if Style.Enabled == true or Style.Enabled == nil then
                        if Selected then
                            if Style.RightLabel ~= nil and Style.RightLabel ~= "" then

                                RenderText(Style.RightLabel, CurrentMenu.X + SettingsButton.RightText.X - RightBadgeOffset + CurrentMenu.WidthOffset, CurrentMenu.Y + SettingsButton.RightText.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButton.RightText.Scale, 0, 0, 0, 255, 2)
                                BoxOffset = MeasureStringWidth(Style.RightLabel, 0, 0.35)
                            end
                        else
                            if Style.RightLabel ~= nil and Style.RightLabel ~= "" then
                                RenderText(Style.RightLabel, CurrentMenu.X + SettingsButton.RightText.X - RightBadgeOffset + CurrentMenu.WidthOffset, CurrentMenu.Y + SettingsButton.RightText.Y + CurrentMenu.SubtitleHeight + RageUI.ItemOffset, 0, SettingsButton.RightText.Scale, 245, 245, 245, 255, 2)
                                BoxOffset = MeasureStringWidth(Style.RightLabel, 0, 0.35)
                            end
                        end
                    end

                    BoxOffset = RightBadgeOffset + BoxOffset
                    if Style.Style ~= nil then
                        if Style.Style == RageUI.CheckboxStyle.Tick then
                            StyleCheckBox(Selected, Checked, 2, 4, BoxOffset)
                        elseif Style.Style == RageUI.CheckboxStyle.Cross then
                            StyleCheckBox(Selected, Checked, 5, 6, BoxOffset)
                        else
                            StyleCheckBox(Selected, Checked, 2, 4, BoxOffset)
                        end
                    else
                        StyleCheckBox(Selected, Checked, 2, 4, BoxOffset)
                    end

                    if Selected and (CurrentMenu.Controls.Select.Active or (Hovered and CurrentMenu.Controls.Click.Active)) and (Style.Enabled == true or Style.Enabled == nil) and not (isWaitingForServer) then
                        local Audio = RageUI.Settings.Audio
                        TriggerEvent("InteractSound_CL:PlayOnOne", "selected", 0.2)
                        Checked = not Checked
                        if (Checked) then
                            if (Actions.onChecked ~= nil) then
                                Actions.onChecked();
                            end
                        else
                            if (Actions.onUnChecked ~= nil) then
                                Actions.onUnChecked();
                            end
                        end
                    end
                else
                    error("UICheckBox Style is not a `table`")
                end

                RageUI.ItemOffset = RageUI.ItemOffset + SettingsButton.Rectangle.Height

                RageUI.ItemsDescription(CurrentMenu, Description, Selected)

                if (Actions.onSelected ~= nil) and (Selected) then
                    Actions.onSelected(Checked);
                end

            end
            RageUI.Options = RageUI.Options + 1
        end
    end
end

function RageUI.ReloadAnimationCheckBox()
    Citizen.CreateThread(function() 
        while true do
            Wait(100)
            progressValue = 0
            canInteract = true 
            alpha = 100
            break
        end
    end)
end