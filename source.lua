--[[
    Modern UI Library Compatibility Layer
    Replaces Kavo UI with a modern, high-performance, and aesthetic interface.
    
    Credits:
    - Original Kavo UI for the API structure
    - Modern UI Design inspired by Fluent/Orion
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// Utility //--
local Utility = {}

function Utility:Tween(instance, info, goals)
    local tween = TweenService:Create(instance, info, goals)
    tween:Play()
    return tween
end

function Utility:Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

function Utility:MakeDraggable(topbarobject, object)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Utility:Tween(object, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos})
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Utility:Ripple(object)
    task.spawn(function()
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Parent = object
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        local maxSize = math.max(object.AbsoluteSize.X, object.AbsoluteSize.Y) * 1.5
        
        Utility:Tween(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, maxSize, 0, maxSize),
            BackgroundTransparency = 1
        })
        
        task.wait(0.5)
        ripple:Destroy()
    end)
end


--// Theme System //--
local Themes = {
    Default = {
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Stroke = Color3.fromRGB(50, 50, 50),
        Divider = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(170, 170, 170),
        Accent = Color3.fromRGB(0, 255, 215) -- Cyan-ish
    },
    LegacyMappings = {
        -- Map old Kavo themes to our system slightly
        DarkTheme = { Accent = Color3.fromRGB(255, 255, 255) },
        LightTheme = { Main = Color3.fromRGB(240, 240, 240), Secondary = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(0, 0, 0) },
        BloodTheme = { Accent = Color3.fromRGB(227, 27, 27) },
        GrapeTheme = { Accent = Color3.fromRGB(166, 71, 214) },
        Ocean = { Accent = Color3.fromRGB(86, 76, 251) },
        Midnight = { Accent = Color3.fromRGB(26, 189, 158) },
        Sentinel = { Accent = Color3.fromRGB(230, 35, 69) },
        Synapse = { Accent = Color3.fromRGB(152, 99, 53) },
        Serpent = { Accent = Color3.fromRGB(0, 166, 58) }
    }
}
local CurrentTheme = Themes.Default

--// Library Class //--
local Library = {
    Windows = {},
    Open = true
}

--// API Compatibility Wrapper //--
local Kavo = {}

function Kavo.CreateLib(libName, themeName)
    local Options = { Name = libName or "Library" }
    
    if themeName then
        if type(themeName) == "table" then
           if themeName.SchemeColor then CurrentTheme.Accent = themeName.SchemeColor end
           if themeName.Background then CurrentTheme.Main = themeName.Background end
           if themeName.Header then CurrentTheme.Secondary = themeName.Header end
           if themeName.TextColor then CurrentTheme.Text = themeName.TextColor end
        elseif type(themeName) == "string" and Themes.LegacyMappings[themeName] then
            for k, v in pairs(Themes.LegacyMappings[themeName]) do
                CurrentTheme[k] = v
            end
        end
    end

    return Library:CreateWindow(Options)
end

function Kavo:ToggleUI()
    Library.Open = not Library.Open
    for _, window in pairs(Library.Windows) do
        window.MainFrame.Visible = Library.Open
    end
end

--// Window Class //--
function Library:CreateWindow(options)
    local Window = {}
    local Tabs = {}
    local FirstTab = true

    -- GUI Creation
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = options.Name .. "_ModernUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = CurrentTheme.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -275, 0.5, -175),
        Size = UDim2.new(0, 550, 0, 350),
        ClipsDescendants = true
    })
    
    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })
    Utility:Create("UIStroke", {
        Color = CurrentTheme.Stroke,
        Thickness = 1,
        Parent = MainFrame
    })

    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 1, 0)
    })
    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Sidebar })
    
    local SidebarCover = Utility:Create("Frame", {
        BorderSizePixel = 0,
        BackgroundColor3 = CurrentTheme.Secondary,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        Parent = Sidebar
    })

    local TitleLabel = Utility:Create("TextLabel", {
        Name = "Title",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -30, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = options.Name,
        TextColor3 = CurrentTheme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 55),
        Size = UDim2.new(1, -20, 1, -65),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Stroke,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local TabListLayout = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    local ContentArea = Utility:Create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 0),
        Size = UDim2.new(1, -160, 1, 0)
    })

    Utility:MakeDraggable(Sidebar, MainFrame)

    table.insert(Library.Windows, { MainFrame = MainFrame })

    --// Tab Functions //--
    function Window:NewTab(tabName)
        local Tab = {}
        local TabButton = Utility:Create("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = CurrentTheme.Main,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = CurrentTheme.TextDark,
            TextSize = 14,
            AutoButtonColor = false
        })
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabButton })
        
        local TabPage = Utility:Create("ScrollingFrame", {
            Name = tabName .. "_Page",
            Parent = ContentArea,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(1, -30, 1, -30),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })
        local PageListLayout = Utility:Create("UIListLayout", {
            Parent = TabPage,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 20)
        end)
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
        end)

        local function Activate()
            for _, t in pairs(Tabs) do
                Utility:Tween(t.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1,
                    TextColor3 = CurrentTheme.TextDark
                })
                t.Page.Visible = false
            end
            
            TabButton.BackgroundTransparency = 1 
            Utility:Tween(TabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.9,
                BackgroundColor3 = CurrentTheme.Accent,
                TextColor3 = CurrentTheme.Text
            })
            TabPage.Visible = true
        end

        TabButton.MouseButton1Click:Connect(Activate)

        if FirstTab then
            FirstTab = false
            Activate()
        end

        table.insert(Tabs, { Button = TabButton, Page = TabPage })

        --// Section Functions //--
        function Tab:NewSection(sectionName)
            local Section = {}
            
            local SectionContainer = Utility:Create("Frame", {
                Name = sectionName,
                Parent = TabPage,
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                ClipsDescendants = true
            })
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SectionContainer })

            local SectionTitle = Utility:Create("TextLabel", {
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SectionContent = Utility:Create("Frame", {
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 0)
            })
            local SectionList = Utility:Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })

            SectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, -20, 0, SectionList.AbsoluteContentSize.Y + 10)
                SectionContainer.Size = UDim2.new(1, 0, 0, SectionList.AbsoluteContentSize.Y + 40)
            end)

            -- Helpers
            local function CreateElementFrame(height)
                local Frame = Utility:Create("Frame", {
                    Parent = SectionContent,
                    BackgroundColor3 = CurrentTheme.Main,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, height or 32)
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Frame })
                Utility:Create("UIStroke", { Color = CurrentTheme.Divider, Thickness = 1, Parent = Frame })
                return Frame
            end

            --// Elements //--
            function Section:NewButton(text, tip, callback)
                callback = callback or function() end
                local ButtonFrame = CreateElementFrame(32)
                
                local ButtonBtn = Utility:Create("TextButton", {
                    Parent = ButtonFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "  " .. text,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })

                ButtonBtn.MouseButton1Click:Connect(function()
                    Utility:Ripple(ButtonFrame)
                    callback()
                end)

                ButtonBtn.MouseEnter:Connect(function()
                    Utility:Tween(ButtonFrame, TweenInfo.new(0.2), { BackgroundColor3 = Utility:Create("Color3", {R=CurrentTheme.Main.R+0.1, G=CurrentTheme.Main.G+0.1, B=CurrentTheme.Main.B+0.1}) })
                end)
                ButtonBtn.MouseLeave:Connect(function()
                    Utility:Tween(ButtonFrame, TweenInfo.new(0.2), { BackgroundColor3 = CurrentTheme.Main })
                end)

                return {
                    UpdateButton = function(self, newTitle)
                        if newTitle then ButtonBtn.Text = "  " .. newTitle end
                    end
                }
            end

            function Section:NewToggle(text, tip, callback)
                callback = callback or function() end
                local ToggleFrame = CreateElementFrame(32)
                
                local Label = Utility:Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local SwitchBase = Utility:Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = CurrentTheme.Secondary,
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Size = UDim2.new(0, 35, 0, 20)
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchBase })

                local SwitchCircle = Utility:Create("Frame", {
                    Parent = SwitchBase,
                    BackgroundColor3 = CurrentTheme.Text,
                    Position = UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SwitchCircle })

                local Toggled = false
                local Trigger = Utility:Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local function UpdateToggle(state)
                    Toggled = state
                    if Toggled then
                         Utility:Tween(SwitchBase, TweenInfo.new(0.2), { BackgroundColor3 = CurrentTheme.Accent })
                         Utility:Tween(SwitchCircle, TweenInfo.new(0.2), { Position = UDim2.new(1, -18, 0.5, -8) })
                    else
                         Utility:Tween(SwitchBase, TweenInfo.new(0.2), { BackgroundColor3 = CurrentTheme.Secondary })
                         Utility:Tween(SwitchCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -8) })
                    end
                    callback(Toggled)
                end

                Trigger.MouseButton1Click:Connect(function()
                    UpdateToggle(not Toggled)
                end)

                return {
                    UpdateToggle = function(self, newText, newState)
                        if newText then Label.Text = newText end
                        if newState ~= nil then UpdateToggle(newState) end
                    end
                }
            end

            function Section:NewSlider(text, tip, max, min, callback)
                callback = callback or function() end
                min = min or 0
                max = max or 100
                local SliderFrame = CreateElementFrame(45)

                local Label = Utility:Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 5),
                    Size = UDim2.new(1, -20, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Utility:Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 5),
                    Size = UDim2.new(0, 50, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(min),
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBar = Utility:Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = CurrentTheme.Secondary,
                    Position = UDim2.new(0, 10, 0, 30),
                    Size = UDim2.new(1, -20, 0, 6)
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderBar })

                local SliderFill = Utility:Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = CurrentTheme.Accent,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = SliderFill })

                local DragBtn = Utility:Create("TextButton", {
                    Parent = SliderBar,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local dragging = false
                
                local function SetValue(value)
                    local percent = (value - min) / (max - min)
                    Utility:Tween(SliderFill, TweenInfo.new(0.1), { Size = UDim2.new(percent, 0, 1, 0) })
                    ValueLabel.Text = tostring(math.floor(value))
                    callback(value)
                end

                DragBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                DragBtn.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation().X
                        local barPos = SliderBar.AbsolutePosition.X
                        local barSize = SliderBar.AbsoluteSize.X
                        local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                        local value = math.floor(min + (max - min) * percent)
                        
                        Utility:Tween(SliderFill, TweenInfo.new(0.05), { Size = UDim2.new(percent, 0, 1, 0) })
                        ValueLabel.Text = tostring(value)
                        callback(value)
                    end
                end)

                return {
                    SetValue = function(self, newVal)
                         SetValue(newVal)
                    end
                }
            end

            function Section:NewDropdown(text, tip, options, callback)
                callback = callback or function() end
                options = options or {}
                
                local DropdownFrame = CreateElementFrame(32)
                DropdownFrame.ClipsDescendants = true
                
                local Label = Utility:Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = text .. " - " .. (options[1] or "Select"),
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Arrow = Utility:Create("ImageLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://6031091004",
                    ImageColor3 = CurrentTheme.TextDark
                })

                local ExpandBtn = Utility:Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    Text = ""
                })

                local OptionContainer = Utility:Create("Frame", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 32),
                    Size = UDim2.new(1, 0, 0, 0)
                })
                local OptionList = Utility:Create("UIListLayout", {
                    Parent = OptionContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })

                local Expanded = false
                
                local function RefreshOptions()
                   for _, v in pairs(OptionContainer:GetChildren()) do
                       if v:IsA("TextButton") then v:Destroy() end
                   end
                   
                   for _, option in pairs(options) do
                       local OptBtn = Utility:Create("TextButton", {
                           Parent = OptionContainer,
                           BackgroundColor3 = CurrentTheme.Secondary,
                           Size = UDim2.new(1, -10, 0, 25),
                           Position = UDim2.new(0, 5, 0, 0), 
                           Font = Enum.Font.Gotham,
                           Text = option,
                           TextColor3 = CurrentTheme.TextDark,
                           TextSize = 12
                       })
                       Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = OptBtn })
                       
                       OptBtn.MouseButton1Click:Connect(function()
                           Label.Text = text .. " - " .. option
                           Expanded = false
                           Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(1, 0, 0, 32) })
                           Utility:Tween(Arrow, TweenInfo.new(0.3), { Rotation = 0 })
                           callback(option)
                       end)
                   end
                end

                RefreshOptions()
                
                ExpandBtn.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    if Expanded then
                        local contentHeight = OptionList.AbsoluteContentSize.Y + 32 + 5
                        Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(1, 0, 0, contentHeight) })
                        Utility:Tween(Arrow, TweenInfo.new(0.3), { Rotation = 180 })
                    else
                        Utility:Tween(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(1, 0, 0, 32) })
                        Utility:Tween(Arrow, TweenInfo.new(0.3), { Rotation = 0 })
                    end
                end)
                
                return {
                    Refresh = function(self, newOptions)
                        options = newOptions
                        RefreshOptions()
                    end
                }
            end

            function Section:NewTextBox(text, tip, callback)
                callback = callback or function() end
                local BoxFrame = CreateElementFrame(32)
                
                local Label = Utility:Create("TextLabel", {
                    Parent = BoxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -120, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local InputBox = Utility:Create("TextBox", {
                    Parent = BoxFrame,
                    BackgroundColor3 = CurrentTheme.Secondary,
                    Position = UDim2.new(1, -110, 0.5, -10),
                    Size = UDim2.new(0, 100, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = "",
                    PlaceholderText = "Type...",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 12,
                    ClearTextOnFocus = false 
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = InputBox })
                
                InputBox.FocusLost:Connect(function(enter)
                    callback(InputBox.Text)
                end)
            end

            function Section:NewKeybind(text, tip, defaultInfo, callback)
                callback = callback or function() end
                local frame = CreateElementFrame(32)
                
                 local Label = Utility:Create("TextLabel", {
                    Parent = frame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local BindBtn = Utility:Create("TextButton", {
                    Parent = frame,
                    BackgroundColor3 = CurrentTheme.Secondary,
                    Position = UDim2.new(1, -90, 0.5, -10),
                    Size = UDim2.new(0, 80, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = "None",
                    TextColor3 = CurrentTheme.TextDark,
                    TextSize = 11
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = BindBtn })
                
                local listening = false
                
                BindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    BindBtn.Text = "..."
                    BindBtn.TextColor3 = CurrentTheme.Accent
                end)
                
                UserInputService.InputBegan:Connect(function(input)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        BindBtn.Text = input.KeyCode.Name
                        BindBtn.TextColor3 = CurrentTheme.Text
                        callback(input.KeyCode)
                    elseif not listening and input.KeyCode.Name == BindBtn.Text then
                        callback()
                    end
                end)
            end

            function Section:NewColorPicker(text, tip, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                
                local PickerFrame = CreateElementFrame(32)
                PickerFrame.ClipsDescendants = true
                
                local Label = Utility:Create("TextLabel", {
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorPreview = Utility:Create("TextButton", {
                    Parent = PickerFrame,
                    BackgroundColor3 = defaultColor,
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Size = UDim2.new(0, 35, 0, 20),
                    Text = ""
                })
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ColorPreview })
                
                -- Expanded area for sliders
                local Expanded = false
                local SliderContainer = Utility:Create("Frame", {
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 35),
                    Size = UDim2.new(1, -20, 0, 90)
                })
                
                local R = defaultColor.R * 255
                local G = defaultColor.G * 255
                local B = defaultColor.B * 255
                
                local function UpdateColor()
                    local newColor = Color3.fromRGB(R, G, B)
                    ColorPreview.BackgroundColor3 = newColor
                    callback(newColor)
                end
                
                local function CreateColorSlider(yPos, colorType)
                    local Bar = Utility:Create("Frame", {
                        Parent = SliderContainer,
                        BackgroundColor3 = CurrentTheme.Secondary,
                        Position = UDim2.new(0, 0, 0, yPos),
                        Size = UDim2.new(1, 0, 0, 6)
                    })
                    Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Bar })
                    
                    local Fill = Utility:Create("Frame", {
                        Parent = Bar,
                        BackgroundColor3 = CurrentTheme.Accent,
                        Size = UDim2.new(0, 0, 1, 0)
                    })
                    Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
                    
                    local initialVal = (colorType == "R" and R) or (colorType == "G" and G) or B
                    Fill.Size = UDim2.new(initialVal/255, 0, 1, 0)
                    
                    local Btn = Utility:Create("TextButton", {
                        Parent = Bar, 
                        BackgroundTransparency = 1, 
                        Size = UDim2.new(1, 0, 1, 0), 
                        Text = ""
                    })
                    
                    local dragging = false
                    Btn.InputBegan:Connect(function(input) 
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end 
                    end)
                    Btn.InputEnded:Connect(function(input) 
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local mouseX = UserInputService:GetMouseLocation().X
                            local barX = Bar.AbsolutePosition.X
                            local pct = math.clamp((mouseX - barX) / Bar.AbsoluteSize.X, 0, 1)
                            Fill.Size = UDim2.new(pct, 0, 1, 0)
                            local val = math.floor(pct * 255)
                            
                            if colorType == "R" then R = val
                            elseif colorType == "G" then G = val
                            else B = val end
                            UpdateColor()
                        end
                    end)
                end
                
                CreateColorSlider(10, "R")
                CreateColorSlider(35, "G")
                CreateColorSlider(60, "B")
                
                ColorPreview.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    if Expanded then
                        Utility:Tween(PickerFrame, TweenInfo.new(0.3), { Size = UDim2.new(1, 0, 0, 130) })
                    else
                         Utility:Tween(PickerFrame, TweenInfo.new(0.3), { Size = UDim2.new(1, 0, 0, 32) })
                    end
                end)
            end

            return Section
        end

        return Tab
    end
    
    return Window
end

return Kavo
