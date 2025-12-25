--[[ 
	Modern UI Library
	A premium, Fluent-inspired UI library for Roblox.
	Redesigned for maximum aesthetic appeal and smooth interactions.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
	Connections = {},
	Instances = {},
	ThemeObjects = {}, -- Track objects to update theme
	FPS = 0,
	Ping = 0,
	Unloaded = false
}

--// Constants & Theming
local Themes = {
	Default = {
		Main = Color3.fromRGB(24, 24, 24),
		Secondary = Color3.fromRGB(32, 32, 32),
		Stroke = Color3.fromRGB(45, 45, 45),
		Accent = Color3.fromRGB(65, 120, 255), -- Fluent Blue
		AccentHover = Color3.fromRGB(85, 140, 255),
		Text = Color3.fromRGB(240, 240, 240),
		TextDark = Color3.fromRGB(160, 160, 160),
		Success = Color3.fromRGB(60, 200, 80),
		Error = Color3.fromRGB(255, 80, 80)
	}
}

local CurrentTheme = Themes.Default
local ToggleKey = Enum.KeyCode.LeftAlt

local function AddThemeObject(instance, prop, type)
	table.insert(Library.ThemeObjects, {Instance = instance, Property = prop, Type = type})
	-- Apply immediate
	if type == "Accent" then
		instance[prop] = CurrentTheme.Accent
	end
end

function Library:UpdateTheme(newAccent)
	CurrentTheme.Accent = newAccent
	for _, obj in pairs(Library.ThemeObjects) do
		if obj.Instance and obj.Instance.Parent then -- Check if valid
			if obj.Type == "Accent" then
				obj.Instance[obj.Property] = CurrentTheme.Accent
			end
		end
	end
end

function Library:Destroy()
	if Library.GUI then Library.GUI:Destroy() end
	if Library.Main then Library.Main:Destroy() end
	
	-- Disconnect all events
	for _, c in pairs(Library.Connections) do
		c:Disconnect()
	end
	
	-- Restore lighting if needed (blur)
	local blur = game:GetService("Lighting"):FindFirstChild("ModernUI_Blur")
	if blur then blur:Destroy() end
	
	Library.Unloaded = true
end

--// Utility Functions
local function Create(class, properties)
	local instance = Instance.new(class)
	for k, v in pairs(properties) do
		if k == "Parent" then continue end
		if typeof(k) == "number" then
			v.Parent = instance
		else
			instance[k] = v
		end
	end
	if properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

local function GetAsset(id)
	if id == nil then return "" end
	if not string.find(id, "rbxassetid://") and not tonumber(id) then 
		-- Assume URL
		if not isfile or not writefile or not getcustomasset then
			return id -- Executor doesn't support custom assets, return as is (might fail if URL)
		end
		
		local fileName = "ModernUI_" .. string.gsub(id, "%W", "") .. ".png"
		if not isfile(fileName) then
			writefile(fileName, game:HttpGet(id))
		end
		return getcustomasset(fileName)
	elseif tonumber(id) then
		return "rbxassetid://" .. id
	end
	return id
end

local function Tween(instance, properties, time, style, direction)
	local info = TweenInfo.new(
		time or 0.2, 
		style or Enum.EasingStyle.Quint, 
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

local function Drag(frame, dragObject)
	dragObject = dragObject or frame
	local dragging, dragInput, dragStart, startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		local targetPos = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
		Tween(frame, {Position = targetPos}, 0.1, Enum.EasingStyle.Sine)
	end
	
	dragObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	dragObject.InputChanged:Connect(function(input)
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

local function Ripple(button)
	button.ClipsDescendants = true
	button.MouseButton1Click:Connect(function()
		local x, y = Mouse.X - button.AbsolutePosition.X, Mouse.Y - button.AbsolutePosition.Y
		local circle = Create("ImageLabel", {
			Name = "Ripple",
			Parent = button,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Image = "rbxassetid://266543268",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 0.8,
			Position = UDim2.new(0, x, 0, y),
			Size = UDim2.new(0, 0, 0, 0),
			ZIndex = 100
		})
		
		local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
		Tween(circle, {
			Size = UDim2.new(0, size, 0, size),
			Position = UDim2.new(0, x - size/2, 0, y - size/2),
			ImageTransparency = 1
		}, 0.5)
		
		task.delay(0.5, function() circle:Destroy() end)
	end)
end

--// Main UI Logic

function Library:AddWindow(name)
	name = name or "UI Library"
	
	local ScreenGui = Create("ScreenGui", {
		Name = "ModernUI",
		Parent = CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	
	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CurrentTheme.Main,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 600, 0, 450),
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	
	Drag(MainFrame)
	
	Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
	Create("UIStroke", {Parent = MainFrame, Color = CurrentTheme.Stroke, Thickness = 2, Transparency = 0})
	
	-- Sidebar
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = MainFrame,
		BackgroundColor3 = CurrentTheme.Secondary,
		Size = UDim2.new(0, 180, 1, 0),
		BorderSizePixel = 0,
		ZIndex = 2
	})
	Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
	local SidebarFix = Create("Frame", {
		Parent = Sidebar,
		BackgroundColor3 = CurrentTheme.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 10, 1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		ZIndex = 2
	})
	
	-- Title
	local TopTitle = Create("TextLabel", {
		Name = "Title",
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 20),
		Size = UDim2.new(1, -40, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = name,
		TextColor3 = CurrentTheme.Text,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5
	})
	
	local TabScroll = Create("ScrollingFrame", {
		Name = "TabScroll",
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 60),
		Size = UDim2.new(1, -20, 1, -110), -- Adjusted for footer
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		BorderSizePixel = 0
	})
	local TabList = Create("UIListLayout", {
		Parent = TabScroll,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})
	
	-- Sidebar Footer (Bomb/Gear)
	local Footer = Create("Frame", {
		Name = "Footer",
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 1, -40),
		Size = UDim2.new(1, -20, 0, 30),
		ZIndex = 5
	})
	
	local Bomb = Create("TextButton", {
		Name = "Destroy",
		Parent = Footer,
		BackgroundColor3 = CurrentTheme.Main,
		Size = UDim2.new(0, 30, 0, 30),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5
	})
	Create("UICorner", {Parent = Bomb, CornerRadius = UDim.new(0, 6)})
	Create("ImageLabel", {
		Parent = Bomb,
		BackgroundTransparency = 1,
		Image = GetAsset("https://i.postimg.cc/TP1s3fMf/image-Photoroom-(45).png"), -- Bomb Icon
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		ImageColor3 = Color3.fromRGB(200, 50, 50),
		ZIndex = 6
	})
	
	local Gear = Create("TextButton", {
		Name = "Settings",
		Parent = Footer,
		BackgroundColor3 = CurrentTheme.Main,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 35, 0, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 5
	})
	Create("UICorner", {Parent = Gear, CornerRadius = UDim.new(0, 6)})
	Create("ImageLabel", {
		Parent = Gear,
		BackgroundTransparency = 1,
		Image = GetAsset("https://i.postimg.cc/rsXZj4dD/image.png"), -- Gear Icon
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 20, 0, 20),
		ImageColor3 = CurrentTheme.Text,
		ZIndex = 6
	})
	
	-- Content Area
	local ContentArea = Create("Frame", {
		Name = "ContentArea",
		Parent = MainFrame,
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 190, 0, 10),
		Size = UDim2.new(1, -200, 1, -20),
		ClipsDescendants = true
	})
	
	Library.GUI = ScreenGui
	Library.Main = MainFrame
	Library.Tabs = {}
	Library.ActiveTab = nil
	Library.SettingsTab = nil
	
	-- Bomb Logic
	Bomb.MouseButton1Click:Connect(function()
		Library:Destroy()
	end)
	
	-- Settings Page Logic
	local SettingsPage = Create("ScrollingFrame", {
		Name = "Internal_Settings_Page",
		Parent = ContentArea,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		Visible = false
	})
	local SettingsLayout = Create("UIListLayout", {
		Parent = SettingsPage,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10)
	})
	
	local SettingsSection = Create("Frame", {
		Name = "SettingsSection",
		Parent = SettingsPage,
		BackgroundColor3 = CurrentTheme.Secondary,
		Size = UDim2.new(1, 0, 0, 100), -- Auto
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0
	})
	Create("UICorner", {Parent = SettingsSection, CornerRadius = UDim.new(0, 6)})
	Create("UIStroke", {Parent = SettingsSection, Color = CurrentTheme.Stroke, Thickness = 1})
	
	Create("TextLabel", {
		Parent = SettingsSection,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 5),
		Size = UDim2.new(1, -20, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = "UI Settings",
		TextColor3 = CurrentTheme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local SettingsItems = Create("Frame", {
		Parent = SettingsSection,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 40),
		Size = UDim2.new(1, -20, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y
	})
	Create("UIListLayout", {
		Parent = SettingsItems,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6)
	})
	Create("UIPadding", {Parent = SettingsItems, PaddingBottom = UDim.new(0, 10)})
	
	-- Gear Logic
	Gear.MouseButton1Click:Connect(function()
		if Library.ActiveTab and Library.ActiveTab.Page ~= SettingsPage then
			-- Deactivate current tab visually
			local oldBtn = Library.ActiveTab.Button
			Tween(oldBtn.Frame, {BackgroundTransparency = 1})
			if typeof(oldBtn.Text) == "Instance" then
				Tween(oldBtn.Text, {TextColor3 = CurrentTheme.TextDark})
			end
			oldBtn.Indicator.Visible = false
			Library.ActiveTab.Page.Visible = false
			
			-- Activate Settings
			SettingsPage.Visible = true
			Library.ActiveTab = {Button = {Frame = Gear, Text = {}, Indicator = {Visible=false}}, Page = SettingsPage}
		end
	end)
	
	-- Helper to add internal elements
	local function AddInternalColorPicker(parent)
		-- Same logic as Section:AddColorPallete but simplified integration
		-- Basically copying the code and stripping table return
		
		local PickerFrame = Create("Frame", {
			Name = "ColorPicker",
			Parent = parent,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true
		})
		
		Create("TextLabel", {
			Parent = PickerFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.6, 0, 0, 30),
			Font = Enum.Font.GothamMedium,
			Text = "Theme Accent",
			TextColor3 = CurrentTheme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local Preview = Create("TextButton", {
			Parent = PickerFrame,
			BackgroundColor3 = CurrentTheme.Accent,
			Position = UDim2.new(1, -50, 0, 5),
			Size = UDim2.new(0, 40, 0, 20),
			Text = "",
			AutoButtonColor = false
		})
		Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})
		Create("UIStroke", {Parent = Preview, Color = CurrentTheme.Stroke, Thickness = 1})
		
		-- Logic: Update Theme when changed
		AddThemeObject(Preview, "BackgroundColor3", "Accent")
		
		-- Expanded Area
		local Palette = Create("Frame", {
			Parent = PickerFrame,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 35),
			Size = UDim2.new(1, 0, 0, 130)
		})
		
		-- SV Saturation/Value Box
		local SVBox = Create("ImageButton", {
			Parent = Palette,
			BackgroundColor3 = Color3.fromHSV(0, 1, 1), -- Base Red
			Size = UDim2.new(0.7, 0, 0.8, 0),
			Image = "rbxassetid://4155801252", -- Color Gradient Overlay
			AutoButtonColor = false
		})
		Create("UICorner", {Parent = SVBox, CornerRadius = UDim.new(0, 4)})
		
		local Cursor = Create("Frame", {
			Parent = SVBox,
			BackgroundColor3 = Color3.new(1,1,1),
			Size = UDim2.new(0, 6, 0, 6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0, 0)
		})
		Create("UICorner", {Parent = Cursor, CornerRadius = UDim.new(1, 0)})
		Create("UIStroke", {Parent = Cursor, Color = Color3.new(0,0,0), Thickness = 1})
		
		-- Hue Slider
		local HueBar = Create("ImageButton", {
			Parent = Palette,
			Position = UDim2.new(0.75, 0, 0, 0),
			Size = UDim2.new(0, 20, 0.8, 0),
			BackgroundColor3 = Color3.new(1,1,1),
			AutoButtonColor = false
		})
		Create("UICorner", {Parent = HueBar, CornerRadius = UDim.new(0, 4)})
		Create("UIGradient", {
			Parent = HueBar,
			Rotation = 90,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
				ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,0,255)),
				ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
				ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,255,0)),
				ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
			}
		})
		
		local HueCursor = Create("Frame", {
			Parent = HueBar,
			BackgroundColor3 = Color3.new(1,1,1),
			Size = UDim2.new(1, 4, 0, 4),
			Position = UDim2.new(0, -2, 0, 0),
			BorderSizePixel = 0
		})
		
		-- Logic
		local default = CurrentTheme.Accent
		local h, s, v = Color3.toHSV(default)
		
		local function UpdateColor(newH, newS, newV)
			h, s, v = newH or h, newS or s, newV or v
			local c = Color3.fromHSV(h, s, v)
			Preview.BackgroundColor3 = c
			SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			Library:UpdateTheme(c)
		end
		
		local function UpdateSV(input)
			local rPos = Vector2.new(input.Position.X - SVBox.AbsolutePosition.X, input.Position.Y - SVBox.AbsolutePosition.Y)
			local pctX = math.clamp(rPos.X / SVBox.AbsoluteSize.X, 0, 1)
			local pctY = math.clamp(rPos.Y / SVBox.AbsoluteSize.Y, 0, 1)
			
			Cursor.Position = UDim2.new(pctX, 0, pctY, 0)
			UpdateColor(nil, pctX, 1 - pctY)
		end
		
		local function UpdateHue(input)
			local rPos = input.Position.Y - HueBar.AbsolutePosition.Y
			local pct = math.clamp(rPos / HueBar.AbsoluteSize.Y, 0, 1)
			
			HueCursor.Position = UDim2.new(0, -2, pct, 0)
			UpdateColor(1 - pct, nil, nil)
		end
		
		-- Hook inputs
		SVBox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				UpdateSV(input)
				local con, endCon
				con = UserInputService.InputChanged:Connect(function(MoveInput)
					if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then UpdateSV(MoveInput) end
				end)
				endCon = UserInputService.InputEnded:Connect(function(EndInput)
					if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
						con:Disconnect(); endCon:Disconnect()
					end
				end)
			end
		end)
		
		HueBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				UpdateHue(input)
				local con, endCon
				con = UserInputService.InputChanged:Connect(function(MoveInput)
					if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then UpdateHue(MoveInput) end
				end)
				endCon = UserInputService.InputEnded:Connect(function(EndInput)
					if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
						con:Disconnect(); endCon:Disconnect()
					end
				end)
			end
		end)
		
		local expanded = false
		Preview.MouseButton1Click:Connect(function()
			expanded = not expanded
			Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, expanded and 160 or 30)})
		end)
	end
	
	local function AddInternalKeybind(parent)
		local BindFrame = Create("Frame", {
			Parent = parent,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30)
		})
		
		Create("TextLabel", {
			Parent = BindFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.6, 0, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = "Toggle Menu",
			TextColor3 = CurrentTheme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local Button = Create("TextButton", {
			Parent = BindFrame,
			BackgroundColor3 = CurrentTheme.Main,
			Position = UDim2.new(0.6, 0, 0, 2),
			Size = UDim2.new(0.4, 0, 1, -4),
			Font = Enum.Font.Gotham,
			Text = ToggleKey.Name,
			TextColor3 = CurrentTheme.TextDark,
			TextSize = 12
		})
		Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 4)})
		Create("UIStroke", {Parent = Button, Color = CurrentTheme.Stroke, Thickness = 1})
		
		local listening = false
		Button.MouseButton1Click:Connect(function()
			listening = true
			Button.Text = "..."
		end)
		
		UserInputService.InputBegan:Connect(function(input)
			if listening and input.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				ToggleKey = input.KeyCode
				Button.Text = input.KeyCode.Name
			end
		end)
	end
	
	AddInternalColorPicker(SettingsItems)
	AddInternalKeybind(SettingsItems)
	
	
	-- FPS/Ping (Optional, keep if needed)
	spawn(function()
		while Library.GUI and Library.GUI.Parent do
			Library.fps = string.format("%d FPS", 1 / RunService.RenderStepped:Wait())
			task.wait(1)
		end
	end)
	
	-- Define AddTab Loop
	function Library:AddWindow(text)
		local TabName = text or "Tab"
		
		local TabButton = Create("TextButton", {
			Name = TabName,
			Parent = TabScroll,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
			Font = Enum.Font.GothamMedium,
			Text = "    " .. TabName,
			TextColor3 = CurrentTheme.TextDark,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false
		})
		Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 6)})
		
		local Indicator = Create("Frame", {
			Parent = TabButton,
			BackgroundColor3 = CurrentTheme.Accent,
			Size = UDim2.new(0, 3, 0, 16),
			Position = UDim2.new(0, 0, 0.5, -8),
			BorderSizePixel = 0,
			Visible = false
		})
		Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(0, 2)})
		
		-- Track for themes
		AddThemeObject(Indicator, "BackgroundColor3", "Accent")
		
		local Page = Create("ScrollingFrame", {
			Name = TabName .. "_Page",
			Parent = ContentArea,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 2,
			Visible = false
		})
		
		-- Layouts
		local LeftColumn = Create("Frame", {
			Name = "Left",
			Parent = Page,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.48, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y
		})
		local RightColumn = Create("Frame", {
			Name = "Right",
			Parent = Page,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.48, 0, 0, 0),
			Position = UDim2.new(0.52, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y
		})
		
		Create("UIListLayout", {Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
		Create("UIListLayout", {Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
		
		local function Activate()
			if Library.ActiveTab then
				local oldBtn = Library.ActiveTab.Button
				Tween(oldBtn.Frame, {BackgroundTransparency = 1})
				if typeof(oldBtn.Text) == "Instance" then
					Tween(oldBtn.Text, {TextColor3 = CurrentTheme.TextDark})
				end
				oldBtn.Indicator.Visible = false
				Library.ActiveTab.Page.Visible = false
			end
			
			-- Force Hide Settings
			SettingsPage.Visible = false
			
			Library.ActiveTab = {
				Button = {Frame=TabButton, Text=TabButton, Indicator=Indicator}, 
				Page = Page
			}
			
			Tween(TabButton, {BackgroundTransparency = 0.95})
			Tween(TabButton, {TextColor3 = CurrentTheme.Accent}) -- Theme handled if we want text accent, but text usually better white/highlight. 
			-- For now stick to strict accent usage where verified.
			
			Indicator.Visible = true
			Page.Visible = true
		end
		
		TabButton.MouseButton1Click:Connect(Activate)
		if #Library.Tabs == 0 then Activate() end
		table.insert(Library.Tabs, {Button = {Frame=TabButton, Text=TabButton, Indicator=Indicator}, Page = Page})
		
		local TabObj = {}
		
		function TabObj:AddSection(text, side)
			text = text or "Section"
			side = side or 1
			local ParentColumn = (side == 2 or side == "Right") and RightColumn or LeftColumn
			
			local SectionContainer = Create("Frame", {
				Parent = ParentColumn,
				BackgroundColor3 = CurrentTheme.Secondary,
				Size = UDim2.new(1, 0, 0, 50),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0
			})
			Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
			Create("UIStroke", {Parent = SectionContainer, Color = CurrentTheme.Stroke, Thickness = 1})
			
			Create("TextLabel", {
				Parent = SectionContainer,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 5),
				Size = UDim2.new(1, -20, 0, 25),
				Font = Enum.Font.GothamBold,
				Text = text,
				TextColor3 = CurrentTheme.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local ItemContainer = Create("Frame", {
				Parent = SectionContainer,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 40),
				Size = UDim2.new(1, -20, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y
			})
			Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
			Create("UIPadding", {Parent = ItemContainer, PaddingBottom = UDim.new(0, 10)})
			
			local SectionObj = {}
			
			function SectionObj:AddButton(text, callback)
				local Button = Create("TextButton", {
					Parent = ItemContainer,
					BackgroundColor3 = CurrentTheme.Main,
					Size = UDim2.new(1, 0, 0, 32),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = CurrentTheme.Text,
					TextSize = 13,
					AutoButtonColor = false
				})
				Create("UICorner", {Parent = Button, CornerRadius = UDim.new(0, 4)})
				local Stroke = Create("UIStroke", {Parent = Button, Color = CurrentTheme.Stroke, Thickness = 1})
				
				Ripple(Button)
				Button.MouseButton1Click:Connect(callback or function() end)
				
				Button.MouseEnter:Connect(function()
					Tween(Stroke, {Color = CurrentTheme.Accent}, 0.2)
				end)
				Button.MouseLeave:Connect(function()
					Tween(Stroke, {Color = CurrentTheme.Stroke}, 0.2)
				end)
				
				-- Theme Tracking
				AddThemeObject(Stroke, "Color", "Accent") -- Only apply accent on hover? No, user wants accent everywhere?
				-- Actually better to dynamically update:
				-- We only want Stroke accent on hover. 
				-- We might skip adding this to global ThemeObjects if it's transient. 
				-- But user said "Accent color doesn't work".
				-- If I change accent, I want the HOVER color to update. 
				
				-- Let's change the MouseEnter to read from CurrentTheme.Accent directly (it already does).
				-- So dynamic update is handled by the variable reference in the closure! 
				-- Wait, if CurrentTheme is a table, and I update CurrentTheme.Accent, the closure `Color = CurrentTheme.Accent` will use the NEW value?
				-- Yes, if I access `CurrentTheme.Accent` inside the function.
				-- BUT, static elements (like Toggles ON state) need to be updated.
			end
			
			function SectionObj:AddToggle(text, state, callback)
				local Enabled = state or false
				local ToggleFrame = Create("Frame", {
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30)
				})
				Create("TextLabel", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.7, 0, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = CurrentTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local Switch = Create("Frame", {
					Parent = ToggleFrame,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(50, 50, 50),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0, 40, 0, 20)
				})
				Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
				local Dot = Create("Frame", {
					Parent = Switch,
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Position = UDim2.new(0, Enabled and 22 or 2, 0.5, 0),
					Size = UDim2.new(0, 16, 0, 16)
				})
				Create("UICorner", {Parent = Dot, CornerRadius = UDim.new(1, 0)})
				
				local Btn = Create("TextButton", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				
				local function Update()
					Enabled = not Enabled
					Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(50, 50, 50)})
					Tween(Dot, {Position = UDim2.new(0, Enabled and 22 or 2, 0.5, 0)})
					if callback then callback(Enabled) end
				end
				Btn.MouseButton1Click:Connect(Update)
				
				-- Theme Tracking
				-- We need to update Switch BackgroundColor IF enabled.
				-- Add to ThemeObjects with a custom updater or logic?
				-- Simpler: Add to ThemeObjects, and in UpdateTheme check logic.
				-- OR: Just re-run the logic in UpdateTheme.
				-- Implementing specific 'Toggle' type in ThemeObjects.
				
				table.insert(Library.ThemeObjects, {
					Type = "Custom",
					Update = function()
						if Enabled then
							Switch.BackgroundColor3 = CurrentTheme.Accent
						end
					end
				})
			end
			
			function SectionObj:AddSlider(text, max, min, default, callback)
				min = min or 0
				max = max or 100
				default = default or min
				
				local SliderFrame = Create("Frame", {
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 45)
				})
				Create("TextLabel", {
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = CurrentTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local ValueLabel = Create("TextLabel", {
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Font = Enum.Font.Gotham,
					Text = tostring(default),
					TextColor3 = CurrentTheme.TextDark,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right
				})
				local Bar = Create("Frame", {
					Parent = SliderFrame,
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					Position = UDim2.new(0, 0, 0, 25),
					Size = UDim2.new(1, 0, 0, 6)
				})
				Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})
				
				local Fill = Create("Frame", {
					Parent = Bar,
					BackgroundColor3 = CurrentTheme.Accent,
					Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
				})
				Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
				
				AddThemeObject(Fill, "BackgroundColor3", "Accent")
				
				local Btn = Create("TextButton", {
					Parent = Bar,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				
				local function Update(input)
					local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local val = math.floor(min + ((max - min) * pos))
					Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
					ValueLabel.Text = tostring(val)
					if callback then callback(val) end
				end
				
				local dragging = false
				Btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						Update(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
				end)
			end
			
			function SectionObj:AddDropdown(text, items, default, callback)
				default = default or items[1]
				local Frame = Create("Frame", {
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32),
					ClipsDescendants = true
				})
				Create("UIListLayout", {Parent = Frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
				
				local Header = Create("TextButton", {
					Parent = Frame,
					BackgroundColor3 = CurrentTheme.Main,
					Size = UDim2.new(1, 0, 0, 30),
					AutoButtonColor = false,
					Text = ""
				})
				Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 4)})
				Create("UIStroke", {Parent = Header, Color = CurrentTheme.Stroke, Thickness = 1})
				
				Create("TextLabel", {
					Parent = Header,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(0.6, 0, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = CurrentTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				local Selected = Create("TextLabel", {
					Parent = Header,
					BackgroundTransparency = 1,
					Position = UDim2.new(0.6, 0, 0, 0),
					Size = UDim2.new(0.4, -25, 1, 0),
					Font = Enum.Font.Gotham,
					Text = default,
					TextColor3 = CurrentTheme.Accent,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right
				})
				AddThemeObject(Selected, "TextColor3", "Accent")
				
				local expanded = false
				Header.MouseButton1Click:Connect(function()
					expanded = not expanded
					Tween(Frame, {Size = UDim2.new(1, 0, 0, expanded and (32 + (#items * 28)) or 32)})
				end)
				
				for _, item in ipairs(items) do
					local ItemBtn = Create("TextButton", {
						Parent = Frame,
						BackgroundColor3 = CurrentTheme.Main,
						BackgroundTransparency = 0.5,
						Size = UDim2.new(1, 0, 0, 26),
						Font = Enum.Font.Gotham,
						Text = "   " .. item,
						TextColor3 = CurrentTheme.TextDark,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Left,
						AutoButtonColor = false
					})
					Create("UICorner", {Parent = ItemBtn, CornerRadius = UDim.new(0, 4)})
					ItemBtn.MouseButton1Click:Connect(function()
						Selected.Text = item
						if callback then callback(item) end
						expanded = false
						Tween(Frame, {Size = UDim2.new(1, 0, 0, 32)})
					end)
				end
			end
			
			function SectionObj:AddColorPallete(text, default, callback)
				-- Using the robust Logic from internal settings
				default = default or Color3.new(1,1,1)
				local PickerFrame = Create("Frame", {
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					ClipsDescendants = true
				})
				
				Create("TextLabel", {
					Parent = PickerFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.6, 0, 0, 30),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = CurrentTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local Preview = Create("TextButton", {
					Parent = PickerFrame,
					BackgroundColor3 = default,
					Position = UDim2.new(1, -50, 0, 5),
					Size = UDim2.new(0, 40, 0, 20),
					Text = "",
					AutoButtonColor = false
				})
				Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})
				Create("UIStroke", {Parent = Preview, Color = CurrentTheme.Stroke, Thickness = 1})
				
				-- Expanded Area
				local Palette = Create("Frame", {
					Parent = PickerFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 35),
					Size = UDim2.new(1, 0, 0, 130)
				})
				
				-- SV Box
				local SVBox = Create("ImageButton", {
					Parent = Palette,
					BackgroundColor3 = Color3.fromHSV(0, 1, 1),
					Size = UDim2.new(0.7, 0, 0.8, 0),
					Image = "rbxassetid://4155801252",
					AutoButtonColor = false
				})
				Create("UICorner", {Parent = SVBox, CornerRadius = UDim.new(0, 4)})
				
				local Cursor = Create("Frame", {
					Parent = SVBox,
					BackgroundColor3 = Color3.new(1,1,1),
					Size = UDim2.new(0, 6, 0, 6),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(1, 0, 0, 0)
				})
				Create("UICorner", {Parent = Cursor, CornerRadius = UDim.new(1, 0)})
				Create("UIStroke", {Parent = Cursor, Color = Color3.new(0,0,0), Thickness = 1})
				
				-- Hue Slider
				local HueBar = Create("ImageButton", {
					Parent = Palette,
					Position = UDim2.new(0.75, 0, 0, 0),
					Size = UDim2.new(0, 20, 0.8, 0),
					BackgroundColor3 = Color3.new(1,1,1),
					AutoButtonColor = false
				})
				Create("UICorner", {Parent = HueBar, CornerRadius = UDim.new(0, 4)})
				Create("UIGradient", {
					Parent = HueBar,
					Rotation = 90,
					Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
						ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,0,255)),
						ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,0,255)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
						ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,255,0)),
						ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,255,0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
					}
				})
				
				local HueCursor = Create("Frame", {
					Parent = HueBar,
					BackgroundColor3 = Color3.new(1,1,1),
					Size = UDim2.new(1, 4, 0, 4),
					Position = UDim2.new(0, -2, 0, 0),
					BorderSizePixel = 0
				})
				
				local h, s, v = Color3.toHSV(default)
				local function UpdateColor(newH, newS, newV)
					h, s, v = newH or h, newS or s, newV or v
					local c = Color3.fromHSV(h, s, v)
					Preview.BackgroundColor3 = c
					SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					if callback then callback(c) end
				end
				
				local function UpdateSV(input)
					local rPos = Vector2.new(input.Position.X - SVBox.AbsolutePosition.X, input.Position.Y - SVBox.AbsolutePosition.Y)
					local pctX = math.clamp(rPos.X / SVBox.AbsoluteSize.X, 0, 1)
					local pctY = math.clamp(rPos.Y / SVBox.AbsoluteSize.Y, 0, 1)
					Cursor.Position = UDim2.new(pctX, 0, pctY, 0)
					UpdateColor(nil, pctX, 1 - pctY)
				end
				
				local function UpdateHue(input)
					local rPos = input.Position.Y - HueBar.AbsolutePosition.Y
					local pct = math.clamp(rPos / HueBar.AbsoluteSize.Y, 0, 1)
					HueCursor.Position = UDim2.new(0, -2, pct, 0)
					UpdateColor(1 - pct, nil, nil)
				end
				
				SVBox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						UpdateSV(input)
						local c = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then UpdateSV(i) end end)
						local e; e = UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then c:Disconnect(); e:Disconnect() end end)
					end
				end)
				HueBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						UpdateHue(input)
						local c = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement then UpdateHue(i) end end)
						local e; e = UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then c:Disconnect(); e:Disconnect() end end)
					end
				end)
				Preview.MouseButton1Click:Connect(function()
					local expanded = not expanded -- Wait, local var shadowing.
					-- Correct logic:
					if PickerFrame.Size.Y.Offset > 30 then
						Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 30)})
					else
						Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 160)})
					end
				end)
			end
			
			function SectionObj:AddLabel(text)
				Create("TextLabel", {
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 25),
					Font = Enum.Font.Gotham,
					Text = text,
					TextColor3 = CurrentTheme.TextDark,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			end
			
			return SectionObj
		end
		
		return TabObj
	end
	
	-- Blur/Keybind Logic
	local Blur = Create("BlurEffect", {Parent = game:GetService("Lighting"), Size = 24, Name = "ModernUI_Blur"})
	local toggled = true
	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == ToggleKey then
			toggled = not toggled
			local target = toggled and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 1.5, 0)
			if Library.Main then Tween(Library.Main, {Position = target}) end
			if Blur then Tween(Blur, {Size = toggled and 24 or 0}) end
		end
	end)
	
	return Library:AddWindow(name)
end

return Library
