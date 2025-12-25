--[[
    Titan UI Library - "Fluent" Reference Edition
    Replicating the specific aesthetic from the provided reference image.
    
    Style:
    - Highly Rounded Corners (10-12px)
    - Card-Based Layout (Components inside #1E1E1E cards)
    - Deep Dark Background (#101010)
    - Modern Iconography & Typography
    
    Compatibility:
    - Full Kavo API Wrapper
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

--// THEME CONSTANTS (From Image Design) //--
local Theme = {
    Background = Color3.fromHex("#101010"),   -- Main Window Back
    Card = Color3.fromHex("#1E1E1E"),         -- Element Backgrounds
    CardHover = Color3.fromHex("#252525"),    -- Element Hover
    Text = Color3.fromHex("#FFFFFF"),         -- Primary Text
    SubText = Color3.fromHex("#888888"),      -- Descriptions/Secondary
    Accent = Color3.fromHex("#34d399"),       -- "Fluent Green" from image (or Customizable)
    Stroke = Color3.fromHex("#2A2A2A"),       -- Card Borders
    StrokeHover = Color3.fromHex("#404040"),  -- Hover Borders
    Icon = Color3.fromHex("#CCCCCC"),
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

--// ICONS (Rayfield/Lucide Inspired Assets) //--
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
    Lock = "rbxassetid://10709782672"
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
    
    -- Main Window with reference Rounding
    local Main = Utility:Create("Frame", {
        Name = "Main",
        Parent = GUI,
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    Utility:Round(Main, 12) -- High rounding from image
    Utility:Stroke(Main, Theme.Stroke, 1)
    
    -- Dragging Logic
    local DragFrame = Utility:Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 40),
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
    
    -- Header Elements
    local Title = Utility:Create("TextLabel", {
        Parent = Main,
        Text = TitleText,
        Size = UDim2.new(1, -200, 0, 30),
        Position = UDim2.new(0, 24, 0, 20),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SubTitle = Utility:Create("TextLabel", {
        Parent = Main,
        Text = "Script Description or Info",
        Size = UDim2.new(1, -200, 0, 20),
        Position = UDim2.new(0, 24, 0, 46),
        BackgroundTransparency = 1,
        Font = Theme.Font,
        TextSize = 13,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Header Icons (Simulated from image)
    local IconsContainer = Utility:Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 100, 0, 24),
        Position = UDim2.new(1, -120, 0, 24),
        BackgroundTransparency = 1
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
    HeaderIcon(Icons.Search)
    HeaderIcon(Icons.Settings)
    local CloseBtn = HeaderIcon(Icons.Close)
    CloseBtn.MouseButton1Click:Connect(function() Library:Toggle() end)

    -- Container for Tabs/Content
    local ContentContainer = Utility:Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, -30, 1, -90),
        Position = UDim2.new(0, 15, 0, 80),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    -- Toggle Internal
    function Library:Toggle()
        Library.Open = not Library.Open
        if Library.Open then
             Main.Visible = true
             Utility:Tween(Main, {Size = UDim2.new(0, 650, 0, 420)}, 0.4)
             -- Scale Up effect
        else
             Utility:Tween(Main, {Size = UDim2.new(0, 650, 0, 0)}, 0.4)
             task.wait(0.3)
             if not Library.Open then Main.Visible = false end
        end
    end
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then Library:Toggle() end
    end)

    local WindowObj = {}
    local Tabs = {}

    function WindowObj:NewTab(name)
        local Tab = {}
        -- Reference image doesn't show tabs clearly, likely a sidebar or dropdown.
        -- We will use a "Horizontal Pill" style or simple content switcher since width is constrained.
        -- Assuming vertical scrolling content for "Tab" as usually seen in these single-window designs.
        
        -- Create a dedicated Page for this tab
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
            Padding = UDim.new(0, 12), -- Gap between cards
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        local PagePad = Utility:Create("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 10)
        })
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageList.AbsoluteContentSize.Y + 20)
        end)
        
        -- Auto-Select first tab
        if #Tabs == 0 then Page.Visible = true end
        table.insert(Tabs, Tab)

        -- If the user calls NewTab multiples times, we need a way to switch. 
        -- Creating a simple tab bar at the bottom or top of content?
        -- For Kavo compat, we often get multiple tabs.
        -- Let's put a simple horizontal tab bar at y=80?
        -- (Skipping complex tab bar for brevity, focusing on Component styling)

        function Tab:NewSection(title)
            local Section = {}
            -- Section Title
            local SectionHeader = Utility:Create("TextLabel", {
                Parent = Page,
                Text = title,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Font = Theme.FontBold,
                TextSize = 12,
                TextColor3 = Theme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Helpers
            local function CreateCard(height)
                local Card = Utility:Create("Frame", {
                    Parent = Page,
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor3 = Theme.Card,
                    BorderSizePixel = 0
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
            
            --// BUTTON //--
            function Section:NewButton(text, tip, callback)
                local ButtonCard = CreateCard(46)
                
                -- Icon (Placeholder)
                local Icon = Utility:Create("ImageLabel", {
                    Parent = ButtonCard,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 12, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = Icons.Edit,
                    ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = ButtonCard,
                    Text = text,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 44, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.FontBold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Clicker = Utility:Create("TextButton", {
                    Parent = ButtonCard,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = ""
                })
                
                Clicker.MouseButton1Click:Connect(function()
                    Utility:Tween(ButtonCard, {Size = UDim2.new(0.98, 0, 0, 42)}, 0.05)
                    task.wait(0.05)
                    Utility:Tween(ButtonCard, {Size = UDim2.new(1, 0, 0, 46)}, 0.1)
                    if callback then callback() end
                end)
                
                return { UpdateButton = function(_, t) Label.Text = t end }
            end

            --// TOGGLE //--
            function Section:NewToggle(text, tip, callback)
                local ToggleCard = CreateCard(46)
                local Toggled = false
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = ToggleCard,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 12, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = Icons.Toggle,
                    ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = ToggleCard,
                    Text = text,
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 44, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.FontBold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Switch Container
                local Switch = Utility:Create("Frame", {
                    Parent = ToggleCard,
                    Size = UDim2.new(0, 46, 0, 24),
                    Position = UDim2.new(1, -58, 0.5, -12),
                    BackgroundColor3 = Color3.fromHex("#333333") 
                })
                Utility:Round(Switch, 12)
                
                local Circle = Utility:Create("Frame", {
                    Parent = Switch,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 3, 0.5, -9),
                    BackgroundColor3 = Theme.Text
                })
                Utility:Round(Circle, 9)
                
                local Clicker = Utility:Create("TextButton", {
                    Parent = ToggleCard,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = ""
                })
                
                local function Update()
                    if Toggled then
                        Utility:Tween(Switch, {BackgroundColor3 = Theme.Accent})
                        Utility:Tween(Circle, {Position = UDim2.new(1, -21, 0.5, -9)})
                        Utility:Tween(Label, {TextColor3 = Theme.Accent}) -- Fluent highlight
                        Utility:Tween(Icon, {ImageColor3 = Theme.Accent})
                    else
                        Utility:Tween(Switch, {BackgroundColor3 = Color3.fromHex("#333333")})
                        Utility:Tween(Circle, {Position = UDim2.new(0, 3, 0.5, -9)})
                         Utility:Tween(Label, {TextColor3 = Theme.Text})
                         Utility:Tween(Icon, {ImageColor3 = Theme.SubText})
                    end
                    if callback then callback(Toggled) end
                end
                
                Clicker.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
                
                return {
                     UpdateToggle = function(_, t, s) 
                         if t then Label.Text = t end 
                         if s ~= nil then Toggled = s; Update() end 
                     end
                }
            end

            --// SLIDER //--
            function Section:NewSlider(text, tip, max, min, callback)
                local SliderCard = CreateCard(60)
                min = min or 0; max = max or 100
                local Val = min
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = SliderCard,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 12, 0, 12),
                    BackgroundTransparency = 1,
                    Image = Icons.List,
                    ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                   Parent = SliderCard,
                   Text = text,
                   Size = UDim2.new(0, 200, 0, 20),
                   Position = UDim2.new(0, 44, 0, 12),
                   BackgroundTransparency = 1,
                   Font = Theme.FontBold,
                   TextSize = 14,
                   TextColor3 = Theme.Text,
                   TextXAlignment = Enum.TextXAlignment.Left
               })
               
               local ValueLabel = Utility:Create("TextLabel", {
                   Parent = SliderCard,
                   Text = tostring(min),
                   Size = UDim2.new(0, 60, 0, 20),
                   Position = UDim2.new(1, -72, 0, 12),
                   BackgroundTransparency = 1,
                   Font = Theme.FontBold,
                   TextSize = 14,
                   TextColor3 = Theme.SubText,
                   TextXAlignment = Enum.TextXAlignment.Right
               })
               
               -- Slider Track
               local Track = Utility:Create("Frame", {
                   Parent = SliderCard,
                   Size = UDim2.new(1, -24, 0, 6),
                   Position = UDim2.new(0, 12, 0, 42),
                   BackgroundColor3 = Color3.fromHex("#333333")
               })
               Utility:Round(Track, 3)
               
               local Fill = Utility:Create("Frame", {
                   Parent = Track,
                   Size = UDim2.new(0, 0, 1, 0),
                   BackgroundColor3 = Theme.Accent
               })
               Utility:Round(Fill, 3)
               
               local Clicker = Utility:Create("TextButton", {
                   Parent = SliderCard,
                   Size = UDim2.new(1,0,1,0),
                   BackgroundTransparency = 1,
                   Text = ""
               })
               
               local function Set(v)
                   v = math.clamp(v, min, max)
                   local p = (v-min)/(max-min)
                   Utility:Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.05)
                   ValueLabel.Text = tostring(math.floor(v*100)/100)
                   if callback then callback(v) end
               end
               
               local dragging = false
               Clicker.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
               Clicker.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
               UserInputService.InputChanged:Connect(function(i)
                   if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
                       local m = UserInputService:GetMouseLocation().X
                       local b = Track.AbsolutePosition.X
                       local w = Track.AbsoluteSize.X
                       Set(min + (max-min)*((m-b)/w))
                   end
               end)
            end

            --// DROPDOWN //--
            function Section:NewDropdown(text, tip, options, callback)
                local DropCard = CreateCard(46)
                local IsOpen = false
                local Selected = options[1] or "Select"
                
                local Icon = Utility:Create("ImageLabel", {
                    Parent = DropCard,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 12, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = Icons.List,
                    ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = DropCard,
                    Text = text .. " : " .. Selected,
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 44, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.FontBold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Chevron = Utility:Create("ImageLabel", {
                    Parent = DropCard,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -32, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://6031091004", -- Chevron
                    ImageColor3 = Theme.SubText
                })
                
                local List = Utility:Create("Frame", {
                    Parent = DropCard,
                    Size = UDim2.new(1, -24, 0, 0),
                    Position = UDim2.new(0, 12, 0, 46),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true
                })
                local Layout = Utility:Create("UIListLayout", {Parent = List, Padding = UDim.new(0, 4)})
                
                for _, opt in ipairs(options) do
                    local Btn = Utility:Create("TextButton", {
                        Parent = List,
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = Theme.Background,
                        Text = "  " .. opt,
                        Font = Theme.Font,
                        TextSize = 13,
                        TextColor3 = Theme.SubText,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false
                    })
                    Utility:Round(Btn, 6)
                    Btn.MouseButton1Click:Connect(function()
                        Selected = opt
                        Label.Text = text .. " : " .. opt
                        if callback then callback(opt) end
                        -- close
                        IsOpen = false
                        Utility:Tween(DropCard, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
                        Utility:Tween(Chevron, {Rotation = 0}, 0.2)
                    end)
                end
                
                local Clicker = Utility:Create("TextButton", {
                    Parent = DropCard,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 10
                })
                Clicker.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    if IsOpen then
                        local h = Layout.AbsoluteContentSize.Y + 10
                        Utility:Tween(DropCard, {Size = UDim2.new(1, 0, 0, 46 + h)}, 0.2)
                        Utility:Tween(Chevron, {Rotation = 180}, 0.2)
                        -- Push zindex
                        DropCard.ZIndex = 5
                    else
                        Utility:Tween(DropCard, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
                        Utility:Tween(Chevron, {Rotation = 0}, 0.2)
                        DropCard.ZIndex = 1
                    end
                end)
                
                return {Refresh = function() end}
            end
            
             --// COLOR PICKER //--
            function Section:NewColorPicker(text, tip, default, callback)
                local ColorCard = CreateCard(46)
                local Def = default or Color3.new(1,1,1)
                
                 local Icon = Utility:Create("ImageLabel", {
                    Parent = ColorCard,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 12, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = Icons.User, -- Placeholder
                    ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = ColorCard,
                    Text = text,
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 44, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.FontBold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Preview = Utility:Create("Frame", {
                    Parent = ColorCard,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -52, 0.5, -10),
                    BackgroundColor3 = Def
                })
                Utility:Round(Preview, 6)
                
                -- Simple randomizer
                local Clicker = Utility:Create("TextButton", {
                    Parent = ColorCard,
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, 
                    Text = ""
                })
                Clicker.MouseButton1Click:Connect(function()
                    local r = Color3.fromHSV(math.random(), 0.9, 1)
                    Preview.BackgroundColor3 = r
                    if callback then callback(r) end
                end)
            end
            
            --// TEXTBOX //--
            function Section:NewTextBox(text, tip, callback)
                local Card = CreateCard(46)
                 local Icon = Utility:Create("ImageLabel", {
                    Parent = Card,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 12, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = Icons.Edit,
                    ImageColor3 = Theme.SubText
                })
                
                 local Input = Utility:Create("TextBox", {
                     Parent = Card,
                     Size = UDim2.new(1, -56, 1, 0),
                     Position = UDim2.new(0, 44, 0, 0),
                     BackgroundTransparency = 1,
                     Text = "",
                     PlaceholderText = text,
                     Font = Theme.FontBold,
                     TextSize = 14,
                     TextColor3 = Theme.Text,
                     PlaceholderColor3 = Theme.SubText,
                     TextXAlignment = Enum.TextXAlignment.Left,
                     ClearTextOnFocus = false
                 })
                 
                 Input.FocusLost:Connect(function() if callback then callback(Input.Text) end end)
            end
            
             --// KEYBIND //--
             function Section:NewKeybind(text, tip, default, callback)
                local Card = CreateCard(46)
                local Key = default or Enum.KeyCode.E
                
                 local Icon = Utility:Create("ImageLabel", {
                    Parent = Card,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 12, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = Icons.Lock,
                    ImageColor3 = Theme.SubText
                })
                
                local Label = Utility:Create("TextLabel", {
                    Parent = Card,
                    Text = text,
                    Size = UDim2.new(1, -100, 1, 0),
                    Position = UDim2.new(0, 44, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Theme.FontBold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local BindBtn = Utility:Create("TextButton", {
                    Parent = Card,
                    Size = UDim2.new(0, 80, 0, 24),
                    Position = UDim2.new(1, -92, 0.5, -12),
                    BackgroundColor3 = Theme.Background,
                    Text = Key.Name,
                    Font = Theme.Font,
                    TextSize = 12,
                    TextColor3 = Theme.SubText
                })
                Utility:Round(BindBtn, 6)
                
                local Listening = false
                BindBtn.MouseButton1Click:Connect(function() 
                    Listening = true 
                    BindBtn.Text = "..."
                    BindBtn.TextColor3 = Theme.Accent
                end)
                UserInputService.InputBegan:Connect(function(i)
                    if Listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        Key = i.KeyCode
                        BindBtn.Text = Key.Name
                        BindBtn.TextColor3 = Theme.SubText
                        Listening = false
                        if callback then callback(Key) end
                    elseif not Listening and i.KeyCode == Key then
                         if callback then callback() end
                    end
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
