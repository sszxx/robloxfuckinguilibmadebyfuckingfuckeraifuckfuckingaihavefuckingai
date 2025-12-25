--[[
    Titan UI Library - "Fluent" Reference Edition (v3.1)
    
    Updates:
    - Added Functional Sidebar for Tabs
    - Fixed Left Alt Toggle
    - Fixed Close Button Logic
    
    Style:
    - Fluent/Rayfield Aesthetic
    - Card-Based, Rounded, Dark Theme
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// THEME CONSTANTS //--
local Theme = {
    Background = Color3.fromHex("#101010"),
    Sidebar = Color3.fromHex("#151515"),      -- Slightly lighter for sidebar
    Card = Color3.fromHex("#1E1E1E"),
    CardHover = Color3.fromHex("#252525"),
    Text = Color3.fromHex("#FFFFFF"),
    SubText = Color3.fromHex("#888888"),
    Accent = Color3.fromHex("#34d399"),       -- Fluent Green
    Stroke = Color3.fromHex("#2A2A2A"),
    StrokeHover = Color3.fromHex("#404040"),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold
}

--// UTILITY //--
local Utility = {}

function Utility:Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        if k ~= "Parent" then instance[k] = v end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

function Utility:Round(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

function Utility:Stroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Stroke
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function Utility:Tween(instance, tweendata, time)
    TweenService:Create(instance, TweenInfo.new(time or 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), tweendata):Play()
end

--// ICONS //--
local Icons = {
    Home = "rbxassetid://10709782497",
    Settings = "rbxassetid://10734950309",
    Search = "rbxassetid://10709781460",
    Close = "rbxassetid://10747384394",
    Minimize = "rbxassetid://10734896206",
    Edit = "rbxassetid://10734934823",
    User = "rbxassetid://10709806144",
    List = "rbxassetid://10709781998",
    Code = "rbxassetid://10723404550",
    Toggle = "rbxassetid://10709782154",
    Lock = "rbxassetid://10709782672",
    Tab = "rbxassetid://10709781998" -- Generic Tab Icon
}

--// LIBRARY CORE //--
local Library = {
    Windows = {},
    Open = true
}

--// WINDOW //--
function Library:CreateWindow(options)
    options = options or {}
    local TitleText = options.Name or "Library"
    
    local GUI = Utility:Create("ScreenGui", {
        Name = "FluentUI_" .. math.random(10000),
        Parent = CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Window
    local Main = Utility:Create("Frame", {
        Name = "Main",
        Parent = GUI,
        Size = UDim2.new(0, 700, 0, 450), -- Widescreen
        Position = UDim2.new(0.5, -350, 0.5, -225),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    Utility:Round(Main, 12)
    Utility:Stroke(Main, Theme.Stroke, 1)
    
    -- Sidebar Container
    local Sidebar = Utility:Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    })
    Utility:Round(Sidebar, 12)
    -- Fix Right side of sidebar to be flat
    local SidebarFix = Utility:Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    })
    
    -- Sidebar Content
    local TabContainer = Utility:Create("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, -20, 1, -80),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0)
    })
    local TabList = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Header Elements (Title in Sidebar for layout)
    local Title = Utility:Create("TextLabel", {
        Parent = Sidebar,
        Text = TitleText,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SubTitle = Utility:Create("TextLabel", {
        Parent = Sidebar,
        Text = "V3.0",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 20, 0, 42),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        TextSize = 12,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Dragging Logic (Top Area)
    local DragFrame = Utility:Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -180, 0, 40),
        Position = UDim2.new(0, 180, 0, 0),
        BackgroundTransparency = 1
    })
    local dragging, dragStart, startPos
    DragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                 if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Utility:Tween(Main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
    
    -- Window Controls (Top Right)
    local IconsContainer = Utility:Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 100, 0, 24),
        Position = UDim2.new(1, -110, 0, 15),
        BackgroundTransparency = 1,
        ZIndex = 5
    })
    local IconLayout = Utility:Create("UIListLayout", {
        Parent = IconsContainer, 
        FillDirection = Enum.FillDirection.Horizontal, 
        HorizontalAlignment = Enum.HorizontalAlignment.Right, 
        Padding = UDim.new(0, 10)
    })
    
    local function HeaderIcon(id)
        local Btn = Utility:Create("ImageButton", {
            Parent = IconsContainer,
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Image = id,
            ImageColor3 = Theme.SubText
        })
        Btn.MouseEnter:Connect(function() Utility:Tween(Btn, {ImageColor3 = Theme.Text}) end)
        Btn.MouseLeave:Connect(function() Utility:Tween(Btn, {ImageColor3 = Theme.SubText}) end)
        return Btn
    end
    -- Icons
    HeaderIcon(Icons.Search) -- Decorative
    HeaderIcon(Icons.Settings) -- Decorative
    local CloseBtn = HeaderIcon(Icons.Close) -- Functional

    -- Toggle Logic
    function Library:Toggle()
        Library.Open = not Library.Open
        if Library.Open then
             Main.Visible = true
             Utility:Tween(Main, {Size = UDim2.new(0, 700, 0, 450)}, 0.4)
        else
             Utility:Tween(Main, {Size = UDim2.new(0, 700, 0, 0)}, 0.4)
             task.wait(0.3)
             if not Library.Open then Main.Visible = false end
        end
    end
    
    CloseBtn.MouseButton1Click:Connect(function() Library:Toggle() end)
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.LeftAlt then
            Library:Toggle()
        end
    end)

    -- Content Area
    local ContentContainer = Utility:Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -200, 1, -20),
        Position = UDim2.new(0, 190, 0, 10),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    local WindowObj = {}
    local Tabs = {}
    local FirstTab = true

    function WindowObj:NewTab(name)
        local Tab = {}
        
        -- Create Sidebar Button
        local TabBtn = Utility:Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })
        Utility:Round(TabBtn, 6)
        
        local TabIcon = Utility:Create("ImageLabel", {
            Parent = TabBtn,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            BackgroundTransparency = 1,
            Image = Icons.Tab,
            ImageColor3 = Theme.SubText
        })
        
        local TabLabel = Utility:Create("TextLabel", {
            Parent = TabBtn,
            Text = name,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 38, 0, 0),
            BackgroundTransparency = 1,
            Font = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Indicator
        local Indicator = Utility:Create("Frame", {
            Parent = TabBtn,
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1
        })
        Utility:Round(Indicator, 2)

        -- Page
        local Page = Utility:Create("ScrollingFrame", {
            Parent = ContentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Stroke,
            CanvasSize = UDim2.new(0,0,0,0)
        })
        local PageList = Utility:Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        local PagePad = Utility:Create("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 10),  PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 5),   PaddingRight = UDim.new(0, 15)
        })
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 20)
        end)
        TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContainer.CanvasSize = UDim2.new(0,0,0,TabList.AbsoluteContentSize.Y + 10)
        end)
        
        -- Select Logic
        local function Activate()
            -- Reset All
            for _, t in ipairs(Tabs) do
                t.Page.Visible = false
                Utility:Tween(t.UI.Label, {TextColor3 = Theme.SubText})
                Utility:Tween(t.UI.Icon, {ImageColor3 = Theme.SubText})
                Utility:Tween(t.UI.Btn, {BackgroundTransparency = 1})
                Utility:Tween(t.UI.Indicator, {BackgroundTransparency = 1})
            end
            
            -- Active
            Page.Visible = true
            Utility:Tween(TabLabel, {TextColor3 = Theme.Text})
            Utility:Tween(TabIcon, {ImageColor3 = Theme.Text})
            Utility:Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = Theme.Text}) -- Light highlight
            Utility:Tween(Indicator, {BackgroundTransparency = 0})
        end
        
        TabBtn.MouseButton1Click:Connect(Activate)
        
        Tab.UI = { Btn = TabBtn, Label = TabLabel, Icon = TabIcon, Indicator = Indicator }
        Tab.Page = Page
        table.insert(Tabs, Tab)
        
        if FirstTab then FirstTab = false; Activate() end

        function Tab:NewSection(title)
            local Section = {}
            -- Section Title
            local SectionHeader = Utility:Create("TextLabel", {
                Parent = Page,
                Text = title,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Font = Theme.FontBold,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local function CreateCard(height)
                local Card = Utility:Create("Frame", {
                    Parent = Page,
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor3 = Theme.Card,
                })
                Utility:Round(Card, 8)
                local Stroke = Utility:Stroke(Card, Theme.Stroke, 1)
                
                Card.MouseEnter:Connect(function() 
                    Utility:Tween(Card, {BackgroundColor3 = Theme.CardHover}) 
                    Utility:Tween(Stroke, {Color = Theme.StrokeHover}) 
                end)
                Card.MouseLeave:Connect(function() 
                    Utility:Tween(Card, {BackgroundColor3 = Theme.Card}) 
                    Utility:Tween(Stroke, {Color = Theme.Stroke}) 
                end)
                return Card
            end

            --// BUTTON
            function Section:NewButton(text, tip, callback)
                local Card = CreateCard(42)
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,12,0.5,-9),
                    BackgroundTransparency = 1, Image = Icons.Edit, ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Card, Text = text, Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,40,0,0),
                    BackgroundTransparency = 1, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Btn = Utility:Create("TextButton", {
                    Parent = Card, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""
                })
                Btn.MouseButton1Click:Connect(function()
                    Utility:Tween(Card, {Size = UDim2.new(0.98,0,0,38)}, 0.05)
                    task.wait(0.05)
                    Utility:Tween(Card, {Size = UDim2.new(1,0,0,42)}, 0.1)
                    if callback then callback() end
                end)
                return {UpdateButton = function(_,t) Label.Text = t end}
            end

            --// TOGGLE
            function Section:NewToggle(text, tip, callback)
                local Card = CreateCard(42)
                local Toggled = false
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,12,0.5,-9),
                    BackgroundTransparency = 1, Image = Icons.Toggle, ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Card, Text = text, Size = UDim2.new(1,-100,1,0), Position = UDim2.new(0,40,0,0),
                    BackgroundTransparency = 1, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Switch = Utility:Create("Frame", {
                    Parent = Card, Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-52,0.5,-10),
                    BackgroundColor3 = Color3.fromHex("#333333")
                })
                Utility:Round(Switch, 10)
                
                local Circle = Utility:Create("Frame", {
                    Parent = Switch, Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,2,0.5,-8),
                    BackgroundColor3 = Theme.Text
                })
                Utility:Round(Circle, 8)
                
                local Btn = Utility:Create("TextButton", {
                    Parent = Card, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""
                })
                
                local function Update()
                    if Toggled then
                        Utility:Tween(Switch, {BackgroundColor3 = Theme.Accent})
                        Utility:Tween(Circle, {Position = UDim2.new(1,-18,0.5,-8)})
                        Utility:Tween(Icon, {ImageColor3 = Theme.Accent})
                        Utility:Tween(Label, {TextColor3 = Theme.Accent})
                    else
                        Utility:Tween(Switch, {BackgroundColor3 = Color3.fromHex("#333333")})
                        Utility:Tween(Circle, {Position = UDim2.new(0,2,0.5,-8)})
                        Utility:Tween(Icon, {ImageColor3 = Theme.SubText})
                        Utility:Tween(Label, {TextColor3 = Theme.Text})
                    end
                    if callback then callback(Toggled) end
                end
                
                Btn.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
                
                return {UpdateToggle = function(_,t,s) if t then Label.Text=t end; if s~=nil then Toggled=s; Update() end end}
            end

            --// SLIDER
            function Section:NewSlider(text, tip, max, min, callback)
                local Card = CreateCard(56) -- Taller
                min = min or 0; max = max or 100
                local Val = min
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,12,0,12),
                    BackgroundTransparency = 1, Image = Icons.List, ImageColor3 = Theme.SubText
                })
                 
                local Label = Utility:Create("TextLabel", {
                    Parent = Card, Text = text, Size = UDim2.new(0,200,0,20), Position = UDim2.new(0,40,0,11),
                    BackgroundTransparency = 1, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                 
                local ValueLabel = Utility:Create("TextLabel", {
                    Parent = Card, Text = tostring(min), Size = UDim2.new(0,50,0,20), Position = UDim2.new(1,-60,0,11),
                    BackgroundTransparency = 1, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local Track = Utility:Create("Frame", {
                    Parent = Card, Size = UDim2.new(1,-24,0,4), Position = UDim2.new(0,12,0,40),
                    BackgroundColor3 = Color3.fromHex("#333333")
                })
                Utility:Round(Track, 2)
                
                local Fill = Utility:Create("Frame", {
                    Parent = Track, Size = UDim2.new(0,0,1,0), BackgroundColor3 = Theme.Accent
                })
                Utility:Round(Fill, 2)
                
                local Btn = Utility:Create("TextButton", {Parent = Card, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})
                
                local function Set(v)
                    v = math.clamp(v, min, max)
                    local p = (v-min)/(max-min)
                    Utility:Tween(Fill, {Size = UDim2.new(p,0,1,0)}, 0.05)
                    ValueLabel.Text = tostring(math.floor(v*100)/100)
                    if callback then callback(v) end
                end
                
                local drag = false
                Btn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
                Btn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
                UserInputService.InputChanged:Connect(function(i) 
                    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                        local m = UserInputService:GetMouseLocation().X
                        local b = Track.AbsolutePosition.X
                        local w = Track.AbsoluteSize.X
                        Set(min + (max-min)*((m-b)/w))
                    end
                end)
                return {SetValue = function(_,v) Set(v) end}
            end

            --// DROPDOWN
            function Section:NewDropdown(text, tip, options, callback)
                local Card = CreateCard(42)
                local IsOpen = false
                local Selected = options[1] or "Select"
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,12,0.5,-9),
                    BackgroundTransparency = 1, Image = Icons.List, ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Card, Text = text .. " : " .. Selected, Size = UDim2.new(1,-70,1,0), Position = UDim2.new(0,40,0,0),
                    BackgroundTransparency = 1, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Chev = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(1,-30,0.5,-9),
                    BackgroundTransparency = 1, Image = "rbxassetid://6031091004", ImageColor3 = Theme.SubText
                })
                
                local List = Utility:Create("Frame", {
                    Parent = Card, Size = UDim2.new(1,-24,0,0), Position = UDim2.new(0,12,0,42),
                    BackgroundTransparency = 1, ClipsDescendants = true
                })
                local Layout = Utility:Create("UIListLayout", {Parent = List, Padding = UDim.new(0,4)})
                
                for _, opt in ipairs(options) do
                    local B = Utility:Create("TextButton", {
                        Parent = List, Size = UDim2.new(1,0,0,30), BackgroundColor3 = Theme.Background,
                        Text = "  "..opt, Font = Theme.Font, TextSize = 13, TextColor3 = Theme.SubText,
                        TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
                    })
                    Utility:Round(B, 4)
                    B.MouseButton1Click:Connect(function()
                        Selected = opt; Label.Text = text .. " : " .. opt; if callback then callback(opt) end
                        IsOpen = false
                        Utility:Tween(Card, {Size = UDim2.new(1,0,0,42)})
                        Utility:Tween(Chev, {Rotation = 0})
                    end)
                end
                
                local Btn = Utility:Create("TextButton", {Parent = Card, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", ZIndex = 2})
                Btn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    if IsOpen then
                        local h = Layout.AbsoluteContentSize.Y + 10
                        Utility:Tween(Card, {Size = UDim2.new(1,0,0,42+h)})
                        Utility:Tween(Chev, {Rotation = 180})
                        Card.ZIndex = 5
                    else
                        Utility:Tween(Card, {Size = UDim2.new(1,0,0,42)})
                        Utility:Tween(Chev, {Rotation = 0})
                        Card.ZIndex = 1
                    end
                end)
                return {Refresh = function() end}
            end

            --// TEXTBOX
            function Section:NewTextBox(text, tip, callback)
                local Card = CreateCard(42)
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,12,0.5,-9),
                    BackgroundTransparency = 1, Image = Icons.Edit, ImageColor3 = Theme.SubText
                })
                
                local Box = Utility:Create("TextBox", {
                    Parent = Card, Size = UDim2.new(1,-50,1,0), Position = UDim2.new(0,40,0,0),
                    BackgroundTransparency = 1, Text = "", PlaceholderText = text, Font = Theme.FontBold,
                    TextSize = 13, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
                })
                Box.FocusLost:Connect(function() if callback then callback(Box.Text) end end)
            end

            --// KEYBIND
            function Section:NewKeybind(text, tip, default, callback)
                local Card = CreateCard(42)
                local Key = default or Enum.KeyCode.E
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,12,0.5,-9),
                    BackgroundTransparency = 1, Image = Icons.Lock, ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Card, Text = text, Size = UDim2.new(1,-100,1,0), Position = UDim2.new(0,40,0,0),
                    BackgroundTransparency = 1, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Bind = Utility:Create("TextButton", {
                    Parent = Card, Size = UDim2.new(0,80,0,24), Position = UDim2.new(1,-90,0.5,-12),
                    BackgroundColor3 = Theme.Background, Text = Key.Name, Font = Theme.Font,
                    TextSize = 12, TextColor3 = Theme.SubText, AutoButtonColor = false
                })
                Utility:Round(Bind, 6)
                
                local Listening = false
                Bind.MouseButton1Click:Connect(function() Listening=true; Bind.Text="..."; Bind.TextColor3=Theme.Accent end)
                UserInputService.InputBegan:Connect(function(i)
                    if Listening and i.UserInputType==Enum.UserInputType.Keyboard then
                        Key = i.KeyCode; Bind.Text = Key.Name; Bind.TextColor3 = Theme.SubText; Listening=false
                        if callback then callback(Key) end
                    elseif not Listening and i.KeyCode==Key then
                        if callback then callback() end
                    end
                end)
            end

            --// COLOR PICKER
            function Section:NewColorPicker(text, tip, default, callback)
                local Card = CreateCard(42)
                local Def = default or Color3.new(1,1,1)
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = Card, Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,12,0.5,-9),
                    BackgroundTransparency = 1, Image = Icons.User, ImageColor3 = Theme.SubText
                })
                 
                local Label = Utility:Create("TextLabel", {
                    Parent = Card, Text = text, Size = UDim2.new(1,-100,1,0), Position = UDim2.new(0,40,0,0),
                    BackgroundTransparency = 1, Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Prev = Utility:Create("TextButton", {
                    Parent = Card, Size = UDim2.new(0,40,0,20), Position = UDim2.new(1,-50,0.5,-10),
                    BackgroundColor3 = Def, Text = "", AutoButtonColor = false
                })
                Utility:Round(Prev, 4)
                
                Prev.MouseButton1Click:Connect(function()
                    local r = Color3.fromHSV(math.random(),0.8,1); Prev.BackgroundColor3=r
                    if callback then callback(r) end
                end)
            end
            
            return Section
        end
        return Tab
    end
    return WindowObj
end

--// KAVO WRAPPER //--
local Kavo = {}
function Kavo.CreateLib(name) return Library:CreateWindow({Name = name}) end
return Kavo
