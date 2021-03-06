pfUI:RegisterModule("unlock", function ()
  pfUI.unlock = CreateFrame("Button", "pfUIUnlockMode", UIParent)
  pfUI.unlock:Hide()
  pfUI.unlock:SetAllPoints(WorldFrame)
  pfUI.unlock:SetFrameStrata("BACKGROUND")
  pfUI.unlock:SetScript("OnClick", function()
    this:Hide()
  end)

  table.insert(UISpecialFrames, "pfUIUnlockMode")

  function pfUI.unlock:SavePosition(frame)
    local _, _, _, xpos, ypos = frame:GetPoint()
    if not C.position[frame:GetName()] then
      C.position[frame:GetName()] = {}
    end

    C.position[frame:GetName()]["xpos"] = round(xpos)
    C.position[frame:GetName()]["ypos"] = round(ypos)

    UpdateMovable(frame)
  end

  pfUI.unlock:SetScript("OnShow", function()
    if not this.setup then
      local size = 1
      local line = {}

      local width = GetScreenWidth()
      local height = GetScreenHeight()

      local ratio = width / GetScreenHeight()
      local rheight = GetScreenHeight() * ratio

      local wStep = width / 128
      local hStep = rheight / 128

      -- vertical lines
      for i = 0, 128 do
        if i == 128 / 2 then
          line = pfUI.unlock:CreateTexture(nil, 'BORDER')
          line:SetTexture(.1, .5, .4)
        else
          line = pfUI.unlock:CreateTexture(nil, 'BACKGROUND')
          line:SetTexture(0, 0, 0, .5)
        end
        line:SetPoint("TOPLEFT", pfUI.unlock, "TOPLEFT", i*wStep - (size/2), 0)
        line:SetPoint('BOTTOMRIGHT', pfUI.unlock, 'BOTTOMLEFT', i*wStep + (size/2), 0)
      end

      -- horizontal lines
      for i = 1, floor(height/hStep) do
        if i == floor(height/hStep / 2) then
          line = pfUI.unlock:CreateTexture(nil, 'BORDER')
          line:SetTexture(.1, .5, .4)
        else
          line = pfUI.unlock:CreateTexture(nil, 'BACKGROUND')
          line:SetTexture(0, 0, 0)
        end

        line:SetPoint("TOPLEFT", pfUI.unlock, "TOPLEFT", 0, -(i*hStep) + (size/2))
        line:SetPoint('BOTTOMRIGHT', pfUI.unlock, 'TOPRIGHT', 0, -(i*hStep + size/2))
      end

      this.setup = true
    end

    for _,frame in pairs(pfUI.movables) do
      local frame = _G[frame]

      if frame then
        if not frame:IsShown() then
          frame.hideLater = true
        end

        if not frame.drag then
          frame.drag = CreateFrame("Button", nil, frame)
          frame.drag:RegisterForClicks("MiddleButtonUp")
          frame.drag:SetAllPoints(frame)
          frame.drag:SetFrameStrata("DIALOG")
          CreateBackdrop(frame.drag, nil, nil, .8)
          frame.drag.backdrop:SetBackdropBorderColor(.2, 1, .8)
          frame.drag:EnableMouseWheel(1)
          frame.drag.text = frame.drag:CreateFontString("Status", "LOW", "GameFontNormal")
          frame.drag.text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
          frame.drag.text:ClearAllPoints()
          frame.drag.text:SetAllPoints(frame.drag)
          frame.drag.text:SetPoint("CENTER", 0, 0)
          frame.drag.text:SetFontObject(GameFontWhite)
          local label = frame:GetName()
          -- Check if the frame name starts with pf if so remove it
          local startsWithPf = string.sub(label, 1, string.len("pf")) == "pf"
          if startsWithPf then label = (strsub(frame:GetName(),3)) end
          if frame.drag:GetHeight() > (2 * frame.drag:GetWidth()) then
            label = strvertical(label)
          end
          frame.drag.text:SetText(label)
          frame.drag:SetAlpha(1)

          frame.drag:SetScript("OnMouseWheel", function()
            local scale = round(frame:GetScale() + arg1/10, 1)

            if IsShiftKeyDown() and strsub(frame:GetName(),0,7) == "pfCombo" then
              for i=1,5 do
                local frame = _G["pfCombo" .. i]
                pfUI.unlock:SaveScale(frame, scale)
              end
            elseif IsShiftKeyDown() and strsub(frame:GetName(),0,6) == "pfRaid" then
              for i=1,40 do
                local frame = _G["pfRaid" .. i]
                pfUI.unlock:SaveScale(frame, scale)
              end
            elseif IsControlKeyDown() and strsub(frame:GetName(),0,6) == "pfRaid" then
              local id = tonumber(strsub(frame:GetName(),7,8))
              local b = 1
              for i=6,40,5 do b = ( id >= i ) and i or b end
              for i=b,b+4 do
                local frame = _G["pfRaid" .. i]
                pfUI.unlock:SaveScale(frame, scale)
              end
            elseif IsShiftKeyDown() and strsub(frame:GetName(),0,7) == "pfGroup" then
              for i=1,4 do
                local frame = _G["pfGroup" .. i]
                pfUI.unlock:SaveScale(frame, scale)
              end
            elseif IsShiftKeyDown() and strsub(frame:GetName(),0,15) == "pfLootRollFrame" then
              for i=1,4 do
                local frame = _G["pfLootRollFrame" .. i]
                pfUI.unlock:SaveScale(frame, scale)
              end
            else
              pfUI.unlock:SaveScale(frame, scale)
            end

            -- repaint hackfix for panels
            if pfUI.panel and pfUI.chat then
              pfUI.panel.left:SetScale(pfUI.chat.left:GetScale())
              pfUI.panel.right:SetScale(pfUI.chat.right:GetScale())
            end

            if frame.OnMove then frame:OnMove() end
          end)


          frame.drag:SetScript("OnMouseDown",function()
            if arg1 == "MiddleButton" then return end
            if IsShiftKeyDown() then
              if strsub(frame:GetName(),0,7) == "pfCombo" then
                for i=1,5 do
                  local cframe = _G["pfCombo" .. i]
                  cframe:StartMoving()
                  cframe:StopMovingOrSizing()
                  cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
                end
              end
              if strsub(frame:GetName(),0,6) == "pfRaid" then
                for i=1,40 do
                  local cframe = _G["pfRaid" .. i]
                  cframe:StartMoving()
                  cframe:StopMovingOrSizing()
                  cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
                end
              end
              if strsub(frame:GetName(),0,7) == "pfGroup" then
                for i=1,4 do
                  local cframe = _G["pfGroup" .. i]
                  cframe:StartMoving()
                  cframe:StopMovingOrSizing()
                  cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
                end
              end
              if strsub(frame:GetName(),0,15) == "pfLootRollFrame" then
                for i=1,4 do
                  local cframe = _G["pfLootRollFrame" .. i]
                  cframe:StartMoving()
                  cframe:StopMovingOrSizing()
                  cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
                end
              end
              _, _, _, xpos, ypos = frame:GetPoint()
              frame.oldPos = { xpos, ypos }
            elseif IsControlKeyDown() then
              if strsub(frame:GetName(),0,6) == "pfRaid" then
                local id = tonumber(strsub(frame:GetName(),7,8))
                local b = 1
                for i=6,40,5 do b = ( id >= i ) and i or b end
                for i=b,b+4 do
                  local cframe = _G["pfRaid" .. i]
                  cframe:StartMoving()
                  cframe:StopMovingOrSizing()
                  cframe.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
                end
                frame.moveSubgroup = { b, b+4 }
              end
              _, _, _, xpos, ypos = frame:GetPoint()
              frame.oldPos = { xpos, ypos }
            else
              frame.oldPos = nil
            end
            frame.drag.backdrop:SetBackdropBorderColor(1,1,1,1)
            frame:StartMoving()
            if frame.OnMove then frame:OnMove() end
          end)

          frame.drag:SetScript("OnMouseUp",function()
              if arg1 == "MiddleButton" then return end
              frame:StopMovingOrSizing()
              _, _, _, xpos, ypos = frame:GetPoint()
              frame.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)

              if frame.oldPos then
                local diffxpos = frame.oldPos[1] - xpos
                local diffypos = frame.oldPos[2] - ypos
                if strsub(frame:GetName(),0,7) == "pfCombo" then
                  for i=1,5 do
                    local cframe = _G["pfCombo" .. i]
                    cframe.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
                    if cframe:GetName() ~= frame:GetName() then
                      local _, _, _, xpos, ypos = cframe:GetPoint()
                      cframe:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)
                      pfUI.unlock:SavePosition(cframe)
                    end
                  end
                elseif strsub(frame:GetName(),0,6) == "pfRaid" then
                  local b = frame.moveSubgroup and frame.moveSubgroup[1] or 1
                  local e = frame.moveSubgroup and frame.moveSubgroup[2] or 40
                  frame.moveSubgroup = nil

                  for i=b,e do
                    local cframe = _G["pfRaid" .. i]
                    cframe.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
                    if cframe:GetName() ~= frame:GetName() then
                      local _, _, _, xpos, ypos = cframe:GetPoint()
                      cframe:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)
                      pfUI.unlock:SavePosition(cframe)
                    end
                  end
                elseif strsub(frame:GetName(),0,7) == "pfGroup" then
                  for i=1,4 do
                    local cframe = _G["pfGroup" .. i]
                    cframe.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
                    if cframe:GetName() ~= frame:GetName() then
                      local _, _, _, xpos, ypos = cframe:GetPoint()
                      cframe:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)
                      pfUI.unlock:SavePosition(cframe)
                    end
                  end
                elseif strsub(frame:GetName(),0,15) == "pfLootRollFrame" then
                  for i=1,4 do
                    local cframe = _G["pfLootRollFrame" .. i]
                    cframe.drag.backdrop:SetBackdropBorderColor(.2,1,.8,1)
                    if cframe:GetName() ~= frame:GetName() then
                      local _, _, _, xpos, ypos = cframe:GetPoint()
                      cframe:SetPoint("TOPLEFT", xpos - diffxpos, ypos - diffypos)
                      pfUI.unlock:SavePosition(cframe)
                    end
                  end
                end
              end

              pfUI.unlock:SavePosition(frame)
              pfUI.unlock.settingChanged = true
          end)

          frame.drag:SetScript("OnClick", function()
            pfUI_config["position"][frame:GetName()] = nil
            UpdateMovable(frame)
          end)
        end

        frame:SetMovable(true)
        frame.drag:EnableMouse(true)
        frame.drag:Show()
        frame:Show()
      end
    end
  end)

  pfUI.unlock:SetScript("OnHide", function()
    for _,frame in pairs(pfUI.movables) do
      local frame = _G[frame]

      if frame then
        frame:StopMovingOrSizing()
        frame:SetMovable(false)
        frame.drag:EnableMouse(false)
        frame.drag:Hide()
        if frame.hideLater == true then
          frame:Hide()
        end
        UpdateMovable(frame)
      end
    end

    pfUI.unlock:Hide()
    pfUI.gui:Show()
  end)

  function pfUI.unlock:SaveScale(frame, scale)
    frame:SetScale(scale)

    if not C.position[frame:GetName()] then
      C.position[frame:GetName()] = {}
    end
    C.position[frame:GetName()]["scale"] = scale

    frame.drag.text:SetText("Scale: " .. scale)
    frame.drag.text:SetAlpha(1)

    frame.drag:SetScript("OnUpdate", function()
      this.text:SetAlpha(this.text:GetAlpha() -0.05)
      if this.text:GetAlpha() < 0.1 then
        this.text:SetText(strsub(this:GetParent():GetName(),3))
        this.text:SetAlpha(1)
        this:SetScript("OnUpdate", function() return end)
      end
    end)
  end

  function pfUI.unlock:UnlockFrames()
    local txt = T["|cff33ffccUnlock Mode|r\nThis mode allows you to move frames by dragging them using the mouse cursor. Frames can be scaled by scrolling up and down.\nTo scale multiple frames at once (eg. raidframes), hold down the shift key while scrolling. Click into an empty space to go back to the pfUI menu."]
    CreateInfoBox(txt, 15, pfUI.unlock)

    pfUI.unlock:Show()
    pfUI.gui:Hide()
  end
end)
