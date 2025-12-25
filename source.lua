--[[
    Titan UI Library - Vercel Edition
    A pixel-perfect, minimalist UI library inspired by Next.js & Vercel Design System.
    
    Aesthetic:
    - Pure Black Backgrounds (#000000)
    - Subtle Borders (#333333)
    - Inter-like Typography (Gotham)
    - High Performance Spring Logic
    
    Compability:
    - Kavo UI API Wrapper
    
    Created by: Antigravity
--]]

--// SERVICES //--
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--// CONSTANTS //--
local Viewport = workspace.CurrentCamera.ViewportSize
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// THEME ENGINE //--
-- Vercel Design Tokens
local Theme = {
    Background = Color3.fromHex("#000000"),
    Surface = Color3.fromHex("#0A0A0A"),    -- Vercel Darker Gray
    Border = Color3.fromHex("#333333"),     -- Subtle Border
    BorderHover = Color3.fromHex("#666666"),-- Hover Border
    Text = Color3.fromHex("#EDEDED"),       -- Primary Text
    SubText = Color3.fromHex("#888888"),    -- Secondary Text
    Accent = Color3.fromHex("#FFFFFF"),     -- White Accent (Vercel Style) or #0070F3
    Blue = Color3.fromHex("#0070F3"),       -- Vercel Blue
    Danger = Color3.fromHex("#E00000"),     -- Red
    Success = Color3.fromHex("#0070F3"),    -- Use Blue for success in this theme or Green
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamMedium -- Not too bold, cleaner
}

--// UTILITY MODULE //--
local Utility = {}

function Utility:Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Corner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

function Utility:Stroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function Utility:Tween(instance, tweendata, time)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, tweendata)
    tween:Play()
    return tween
end

function Utility:Spring(target, initial)
    -- Simple linear interpolation wrapper with "spring-like" feel via smoothing
    -- Real springs are heavy for UI loop, using optimized Lerp for sleekness
    return initial
    -- Expanded later if needed
end

function Utility:Connect(signal, callback)
    local con = signal:Connect(callback)
    return con
end

--// UI CLASSES //--

local Library = {
    Windows = {},
    Open = true
}

--// COMPONENT: WINDOW //--
function Library:CreateWindow(options)
    options = options or {}
    local Title = options.Name or "Library"
    
    local GUI = Utility:Create("ScreenGui", {
        Name = "VercelUI_" .. math.random(10000),
        Parent = CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Background Blur
    local Blur = Utility:Create("BlurEffect", {
        Parent = Lighting,
        Size = 0,
        Name = "VercelBlur"
    })
    
    -- Main Container (Centered)
    local MainFrame = Utility:Create("Frame", {
        Name = "Main",
        Parent = GUI,
        Size = UDim2.new(0, 700, 0, 450), -- Widescreen feel
        Position = UDim2.new(0.5, -350, 0.5, -225),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Utility:Corner(MainFrame, 8)
    Utility:Stroke(MainFrame, Theme.Border, 1)

    -- Topbar (Vercel Header)
    local Topbar = Utility:Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    local TopbarLine = Utility:Create("Frame", {
        Name = "Separator",
        Parent = Topbar,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    })

    -- Gradient for Topbar (Subtle shine)
    local TopbarGradient = Utility:Create("UIGradient", {
        Parent = Topbar,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
        })
    })

    -- Logo / Title
    local Logo = Utility:Create("Frame", {
        Parent = Topbar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 16, 0.5, -12),
        BackgroundColor3 = Theme.Text
    })
    Utility:Corner(Logo, 24) -- Circle
    local LogoGradient = Utility:Create("UIGradient", {
        Parent = Logo,
        Rotation = 45,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Text),
            ColorSequenceKeypoint.new(1, Theme.SubText)
        }
    })

    local TitleLabel = Utility:Create("TextLabel", {
        Parent = Topbar,
        Text = Title,
        Font = Theme.FontBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 52, 0, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Breadcrumb Separator / Version
    local Slash = Utility:Create("TextLabel", {
        Parent = Topbar,
        Text = "/",
        Font = Theme.Font,
        TextSize = 14,
        TextColor3 = Theme.Border,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(0, 40+TitleLabel.TextBounds.X, 0, 0), -- Dynamic pos tricky here
        BackgroundTransparency = 1,
        Visible = false 
    })

    -- Sidebar Container
    local Sidebar = Utility:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 200, 1, -49),
        Position = UDim2.new(0, 0, 0, 49),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    local SidebarBorder = Utility:Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    })
    
    local SidebarScroll = Utility:Create("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, -1, 1, -20),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0)
    })
    local SidebarList = Utility:Create("UIListLayout", {
        Parent = SidebarScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    -- Content Container
    local Content = Utility:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -201, 1, -49),
        Position = UDim2.new(0, 201, 0, 49),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    --// DRAGGING //--
    local dragging, dragInput, dragStart, startPos
    local function UpdateDrag(input)
        local delta = input.Position - dragStart
        Utility:Tween(MainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
    end
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then UpdateDrag(input) end
    end)

    --// TOGGLE LOGIC //--
    local function Toggle(bool)
        Library.Open = bool
        if bool then
            MainFrame.Visible = true
            Utility:Tween(MainFrame, {Position = UDim2.new(0.5, -350, 0.5, -225)}, 0.4) -- Centered
            Utility:Tween(Blur, {Size = 24}, 0.5)
            -- Fade in content?
        else
            Utility:Tween(MainFrame, {Position = UDim2.new(0.5, -350, 0.6, -225)}, 0.4) -- Slide down slightly
            Utility:Tween(Blur, {Size = 0}, 0.5)
            task.delay(0.3, function()
                if not Library.Open then MainFrame.Visible = false end
            end)
        end
    end
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == Enum.KeyCode.LeftAlt then
            Toggle(not Library.Open)
        end
    end)
    -- Init animation
    Blur.Size = 24

    local WindowObj = {}
    local Tabs = {}

    --// TAB CREATION //--
    function WindowObj:NewTab(name)
        local Tab = {}
        
        -- Create Tab Button
        local Btn = Utility:Create("TextButton", {
            Parent = SidebarScroll,
            Size = UDim2.new(1, -24, 0, 32),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })
        Utility:Corner(Btn, 6)
        
        local Title = Utility:Create("TextLabel", {
            Parent = Btn,
            Text = name,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Font = Theme.Font,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Page Container
        local Page = Utility:Create("ScrollingFrame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false, -- Hidden by default
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Border,
            CanvasSize = UDim2.new(0,0,0,0)
        })
        local PageList = Utility:Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 16),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        -- Padding Frame
        local Padder = Utility:Create("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 24),
            PaddingLeft = UDim.new(0, 24),
            PaddingRight = UDim.new(0, 24),
            PaddingBottom = UDim.new(0, 24)
        })

        -- Auto Canvas
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 48)
        end)
        SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 20)
        end)

        -- Interaction
        local function SetActive()
            -- Unselect others
            for _, t in ipairs(Tabs) do
                Utility:Tween(t.Title, {TextColor3 = Theme.SubText}, 0.2)
                Utility:Tween(t.Btn, {BackgroundColor3 = Theme.Background}, 0.2)
                t.Page.Visible = false
            end
            -- Select Self
            Utility:Tween(Title, {TextColor3 = Theme.Text}, 0.2)
            Utility:Tween(Btn, {BackgroundColor3 = Theme.Surface}, 0.2)
            Page.Visible = true
            -- Pop Animation
            Page.Position = UDim2.new(0, 0, 0, 5)
            Page.BackgroundTransparency = 1
            Utility:Tween(Page, {Position = UDim2.new(0,0,0,0)}, 0.3)
        end

        Btn.MouseButton1Click:Connect(SetActive)
        Btn.MouseEnter:Connect(function() 
            if Title.TextColor3 ~= Theme.Text then 
                Utility:Tween(Title, {TextColor3 = Theme.Text}, 0.2) 
            end 
        end)
        Btn.MouseLeave:Connect(function() 
            if not Page.Visible then 
                Utility:Tween(Title, {TextColor3 = Theme.SubText}, 0.2) 
            end 
        end)

        Tab.Btn = Btn
        Tab.Title = Title
        Tab.Page = Page
        table.insert(Tabs, Tab)
        
        -- Auto select first
        if #Tabs == 1 then SetActive() end
        
        
        --// SECTIONS //--
        function Tab:NewSection(title)
            local Section = {}
            
            -- Title text
            local Header = Utility:Create("TextLabel", {
                Parent = Page,
                Text = title,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Font = Theme.FontBold,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Container for items
            local Container = Utility:Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.Surface,
                BorderSizePixel = 0
            })
            Utility:Corner(Container, 8)
            Utility:Stroke(Container, Theme.Border, 1)
            
            local ContainerList = Utility:Create("UIListLayout", {
                Parent = Container,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 1) -- 1px Lines between items
            })
            
            ContainerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, ContainerList.AbsoluteContentSize.Y)
            end)
            
            -- Helper for Item Rows
            local function CreateRow(height)
                local Row = Utility:Create("Frame", {
                    Parent = Container,
                    Size = UDim2.new(1, 0, 0, height or 48),
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0
                })
                -- Separator logic (if not first) 
                -- or we use UIListLayout with Padding 1 and set Background of Container to Border color?
                -- "Gap" approach:
                return Row
            end
            
            --// BUTTON //--
            function Section:NewButton(text, tip, callback)
                local Row = CreateRow(48)
                
                local BtnLabel = Utility:Create("TextLabel", {
                    Parent = Row,
                    Text = text,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ActionBtn = Utility:Create("TextButton", {
                    Parent = Row,
                    Size = UDim2.new(0, 100, 0, 32),
                    Position = UDim2.new(1, -116, 0.5, -16),
                    BackgroundColor3 = Theme.Background,
                    Text = "Click",
                    Font = Theme.FontBold,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    AutoButtonColor = false
                })
                Utility:Corner(ActionBtn, 6)
                local Stroke = Utility:Stroke(ActionBtn, Theme.Border, 1)
                
                ActionBtn.MouseEnter:Connect(function()
                    Utility:Tween(Stroke, {Color = Theme.Accent}, 0.2)
                    Utility:Tween(ActionBtn, {TextColor3 = Theme.Accent}, 0.2)
                end)
                ActionBtn.MouseLeave:Connect(function()
                    Utility:Tween(Stroke, {Color = Theme.Border}, 0.2)
                    Utility:Tween(ActionBtn, {TextColor3 = Theme.Text}, 0.2)
                end)
                ActionBtn.MouseButton1Click:Connect(function()
                     if callback then callback() end
                end)
            end
            
            --// TOGGLE //--
            function Section:NewToggle(text, tip, callback)
                local Row = CreateRow(48)
                local Toggled = false
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Row,
                    Text = text,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Switch = Utility:Create("TextButton", {
                    Parent = Row,
                    Size = UDim2.new(0, 40, 0, 24),
                    Position = UDim2.new(1, -56, 0.5, -12),
                    BackgroundColor3 = Theme.Background,
                    Text = "",
                    AutoButtonColor = false
                })
                Utility:Corner(Switch, 12)
                Utility:Stroke(Switch, Theme.Border, 1)
                
                local Knob = Utility:Create("Frame", {
                    Parent = Switch,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 2, 0.5, -10),
                    BackgroundColor3 = Theme.SubText
                })
                Utility:Corner(Knob, 10) -- Circle
                
                local function Update()
                    if Toggled then
                        Utility:Tween(Switch, {BackgroundColor3 = Theme.Text}, 0.2) -- Active White
                        Utility:Tween(Knob, {Position = UDim2.new(1, -22, 0.5, -10), BackgroundColor3 = Theme.Background}, 0.2) -- Black Knob
                    else
                        Utility:Tween(Switch, {BackgroundColor3 = Theme.Background}, 0.2)
                        Utility:Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = Theme.SubText}, 0.2)
                    end
                    if callback then callback(Toggled) end
                end
                
                Switch.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)
            end
            
            --// SLIDER //--
            function Section:NewSlider(text, tip, max, min, callback)
                local Row = CreateRow(64)
                min = min or 0
                max = max or 100
                local Value = min
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Row,
                    Text = text,
                    Size = UDim2.new(0, 200, 0, 24),
                    Position = UDim2.new(0, 16, 0, 10),
                    BackgroundTransparency = 1,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Utility:Create("TextLabel", {
                    Parent = Row,
                    Text = tostring(min),
                    Size = UDim2.new(0, 50, 0, 24),
                    Position = UDim2.new(1, -66, 0, 10),
                    BackgroundTransparency = 1,
                    Font = Enum.FontBold,
                    TextSize = 13,
                    TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local Bar = Utility:Create("Frame", {
                    Parent = Row,
                    Size = UDim2.new(1, -32, 0, 4),
                    Position = UDim2.new(0, 16, 0, 44),
                    BackgroundColor3 = Theme.Border
                })
                Utility:Corner(Bar, 2)
                
                local Fill = Utility:Create("Frame", {
                    Parent = Bar,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Theme.Text -- White fill
                })
                Utility:Corner(Fill, 2)
                
                local Knob = Utility:Create("Frame", {
                    Parent = Fill,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -8, 0.5, -8),
                    BackgroundColor3 = Theme.Text,
                    Visible = false -- Only show on drag? Next.js style usually hides knob or small
                })
                Utility:Corner(Knob, 8)
                Utility:Stroke(Knob, Theme.Background, 2)
                
                local DragPad = Utility:Create("TextButton", {
                    Parent = Bar,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ""
                })
                
                local function Set(v)
                    v = math.clamp(v, min, max)
                    local p = (v - min) / (max - min)
                    Utility:Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.05)
                    ValueLabel.Text = tostring(math.floor(v * 100)/100)
                    if callback then callback(v) end
                end
                
                local Dragging = false
                DragPad.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        Knob.Visible = true
                    end
                end)
                DragPad.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                        Knob.Visible = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if Dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local m = UserInputService:GetMouseLocation().X
                        local b = Bar.AbsolutePosition.X
                        local w = Bar.AbsoluteSize.X
                        local p = math.clamp((m-b)/w, 0, 1)
                        Set(min + (max-min)*p)
                    end
                end)
            end
            
            --// DROPDOWN //--
            function Section:NewDropdown(text, tip, options, callback)
                local Row = CreateRow(48)
                local IsOpen = false
                local Selected = options[1] or "Select"
                
                local Label = Utility:Create("TextLabel", {
                   Parent = Row,
                   Text = text,
                   Size = UDim2.new(1, -150, 1, 0),
                   Position = UDim2.new(0, 16, 0, 0),
                   BackgroundTransparency = 1,
                   Font = Theme.Font,
                   TextSize = 13,
                   TextColor3 = Theme.Text,
                   TextXAlignment = Enum.TextXAlignment.Left
               })
               
               local Trigger = Utility:Create("TextButton", {
                   Parent = Row,
                   Size = UDim2.new(0, 140, 0, 32),
                   Position = UDim2.new(1, -156, 0.5, -16),
                   BackgroundColor3 = Theme.Background,
                   Text = "",
                   AutoButtonColor = false
               })
               Utility:Corner(Trigger, 6)
               local Stroke = Utility:Stroke(Trigger, Theme.Border, 1)
               
               local SelectedLabel = Utility:Create("TextLabel", {
                   Parent = Trigger,
                   Text = Selected,
                   Size = UDim2.new(1, -30, 1, 0),
                   Position = UDim2.new(0, 10, 0, 0),
                   BackgroundTransparency = 1,
                   Font = Theme.Font,
                   TextSize = 12,
                   TextColor3 = Theme.SubText,
                   TextXAlignment = Enum.TextXAlignment.Left,
                   ClipsDescendants = true
               })
               
               local Arrow = Utility:Create("ImageLabel", {
                   Parent = Trigger,
                   Image = "rbxassetid://6031091004", -- Chevron
                   Size = UDim2.new(0, 16, 0, 16),
                   Position = UDim2.new(1, -20, 0.5, -8),
                   BackgroundTransparency = 1,
                   ImageColor3 = Theme.SubText
               })
               
               -- Floating Menu
               local Menu = Utility:Create("Frame", {
                   Parent = Row, 
                   Size = UDim2.new(0, 140, 0, 0),
                   Position = UDim2.new(1, -156, 1, 4),
                   BackgroundColor3 = Theme.Surface,
                   Visible = false,
                   ZIndex = 10 -- Above content
               })
               Utility:Corner(Menu, 6)
               Utility:Stroke(Menu, Theme.Border, 1)
               
               local MenuList = Utility:Create("ScrollingFrame", {
                   Parent = Menu,
                   Size = UDim2.new(1, 0, 1, 0),
                   BackgroundTransparency = 1,
                   ScrollBarThickness = 2,
                   CanvasSize = UDim2.new(0,0,0,0)
               })
               local Layout = Utility:Create("UIListLayout", {Parent = MenuList, Padding = UDim.new(0, 2)})
               
               for _, opt in ipairs(options) do
                   local OptBtn = Utility:Create("TextButton", {
                       Parent = MenuList,
                       Size = UDim2.new(1, -8, 0, 28),
                       BackgroundColor3 = Theme.Surface,
                       Text = "  " .. opt,
                       Font = Theme.Font,
                       TextSize = 12,
                       TextColor3 = Theme.SubText,
                       TextXAlignment = Enum.TextXAlignment.Left,
                       AutoButtonColor = false
                   })
                   Utility:Corner(OptBtn, 4)
                   
                   OptBtn.MouseEnter:Connect(function() 
                       OptBtn.BackgroundColor3 = Theme.Border 
                       OptBtn.TextColor3 = Theme.Text
                   end)
                   OptBtn.MouseLeave:Connect(function() 
                       OptBtn.BackgroundColor3 = Theme.Surface
                       OptBtn.TextColor3 = Theme.SubText
                   end)
                   OptBtn.MouseButton1Click:Connect(function()
                       Selected = opt
                       SelectedLabel.Text = opt
                       if callback then callback(opt) end
                       -- Close
                       IsOpen = false
                       Menu.Visible = false
                       Row.ZIndex = 1
                   end)
               end
               
               Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                   MenuList.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y)
               end)
               
               Trigger.MouseButton1Click:Connect(function()
                   IsOpen = not IsOpen
                   if IsOpen then
                       Row.ZIndex = 10 -- Bring row forward
                       Menu.Visible = true
                       Menu.Size = UDim2.new(0, 140, 0, math.min(150, Layout.AbsoluteContentSize.Y))
                   else
                       Menu.Visible = false
                       Row.ZIndex = 1
                   end
               end)
            end
            
             --// COLOR PICKER //--
            function Section:NewColorPicker(text, tip, default, callback)
                -- Simplistic
                 local Row = CreateRow(48)
                 local Col = default or Color3.new(1,1,1)
                 
                 local Label = Utility:Create("TextLabel", {
                   Parent = Row,
                   Text = text,
                   Size = UDim2.new(1, -60, 1, 0),
                   Position = UDim2.new(0, 16, 0, 0),
                   BackgroundTransparency = 1,
                   Font = Theme.Font,
                   TextSize = 13,
                   TextColor3 = Theme.Text,
                   TextXAlignment = Enum.TextXAlignment.Left
               })
               
               local Preview = Utility:Create("TextButton", {
                   Parent = Row,
                   Size = UDim2.new(0, 40, 0, 24),
                   Position = UDim2.new(1, -56, 0.5, -12),
                   BackgroundColor3 = Col,
                   Text = "",
               })
               Utility:Corner(Preview, 6)
               Utility:Stroke(Preview, Theme.Border, 1)
               
               Preview.MouseButton1Click:Connect(function()
                   -- Random for demo
                   Col = Color3.fromHSV(math.random(), 0.8, 1)
                   Preview.BackgroundColor3 = Col
                   if callback then callback(Col) end
               end)
            end
            
            --// KEYBIND //--
            function Section:NewKeybind(text, tip, default, callback)
                local Row = CreateRow(48)
                local Key = default or Enum.KeyCode.E
                
                local Label = Utility:Create("TextLabel", {
                   Parent = Row,
                   Text = text,
                   Size = UDim2.new(1, -60, 1, 0),
                   Position = UDim2.new(0, 16, 0, 0),
                   BackgroundTransparency = 1,
                   Font = Theme.Font,
                   TextSize = 13,
                   TextColor3 = Theme.Text,
                   TextXAlignment = Enum.TextXAlignment.Left
               })
               
                local BindBtn = Utility:Create("TextButton", {
                   Parent = Row,
                   Size = UDim2.new(0, 80, 0, 24),
                   Position = UDim2.new(1, -96, 0.5, -12),
                   BackgroundColor3 = Theme.Background,
                   Text = Key.Name,
                   Font = Theme.Font,
                   TextSize = 12,
                   TextColor3 = Theme.SubText
               })
               Utility:Corner(BindBtn, 6)
               Utility:Stroke(BindBtn, Theme.Border, 1)
               
               local Listening = false
               BindBtn.MouseButton1Click:Connect(function()
                   Listening = true
                   BindBtn.Text = "..."
                   BindBtn.TextColor3 = Theme.Accent
               end)
               
               UserInputService.InputBegan:Connect(function(inp)
                   if Listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                       Key = inp.KeyCode
                       BindBtn.Text = Key.Name
                       BindBtn.TextColor3 = Theme.SubText
                       Listening = false
                       if callback then callback(Key) end
                   elseif not Listening and inp.KeyCode == Key then
                       if callback then callback() end
                   end
               end)
            end
            
             --// TEXTBOX //--
            function Section:NewTextBox(text, tip, callback)
                local Row = CreateRow(48)
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Row,
                    Text = text,
                    Size = UDim2.new(1, -160, 1, 0),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local BoxContainer = Utility:Create("Frame", {
                    Parent = Row,
                    Size = UDim2.new(0, 140, 0, 32),
                    Position = UDim2.new(1, -156, 0.5, -16),
                    BackgroundColor3 = Theme.Background,
                })
                Utility:Corner(BoxContainer, 6)
                local Stroke = Utility:Stroke(BoxContainer, Theme.Border, 1)
                
                local Box = Utility:Create("TextBox", {
                    Parent = BoxContainer,
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    PlaceholderText = "Type...",
                    Font = Theme.Font,
                    TextSize = 12,
                    TextColor3 = Theme.Text,
                    ClearTextOnFocus = false
                })
                
                Box.Focused:Connect(function() Utility:Tween(Stroke, {Color = Theme.Text}, 0.2) end)
                Box.FocusLost:Connect(function() 
                    Utility:Tween(Stroke, {Color = Theme.Border}, 0.2)
                    if callback then callback(Box.Text) end
                end)
            end

            return Section
        end
        
        return Tab
    end
    
    return WindowObj
end

--// KAVO COMPATIBILITY WRAPPER //--
local Kavo = {}
function Kavo.CreateLib(name)
    return Library:CreateWindow({Name = name})
end

return Kavo
