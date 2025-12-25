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
	Flags = {},
	Sections = {}, -- Store for legacy compatibility
	FPS = 0,
	Ping = 0
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

--// Utility Functions
local function Create(class, properties)
	local instance = Instance.new(class)
	for k, v in pairs(properties) do
		if k == "Parent" then continue end -- Set Parent last
		if typeof(k) == "number" then
			-- Helper for child instances if passed as array
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

-- Legacy API Compatibility Helpers
function Library:AddWindow(name, options)
	name = name or "UI Library"
	options = options or {}
	
	-- Create ScreenGui
	local ScreenGui = Create("ScreenGui", {
		Name = "ModernUI",
		Parent = CoreGui,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	
	Library.GUI = ScreenGui -- For legacy access
	
	-- Main Container Frame
	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CurrentTheme.Main,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 700, 0, 450), -- Modern wide aspect ratio
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	
	Drag(MainFrame)
	
	-- Styling MainFrame
	Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})
	Create("UIStroke", {Parent = MainFrame, Color = CurrentTheme.Stroke, Thickness = 1.5, Transparency = 0.5})
	
	-- Sidebar Container
	local Sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = MainFrame,
		BackgroundColor3 = CurrentTheme.Secondary,
		Size = UDim2.new(0, 180, 1, 0),
		BorderSizePixel = 0,
		ZIndex = 2
	})
	Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
	-- Fix corner overlap (square right side)
	local SidebarFix = Create("Frame", {
		Parent = Sidebar,
		BackgroundColor3 = CurrentTheme.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 10, 1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		ZIndex = 2
	})
	
	-- Content Container
	local ContentContainer = Create("Frame", {
		Name = "Content",
		Parent = MainFrame,
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 180, 0, 0),
		Size = UDim2.new(1, -180, 1, 0),
		ClipsDescendants = true
	})
	
	-- Window Title
	local TitleLabel = Create("TextLabel", {
		Name = "Title",
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 20),
		Size = UDim2.new(1, -30, 0, 25),
		Font = Enum.Font.GothamBold,
		Text = name,
		TextColor3 = CurrentTheme.Text,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5
	})
	
	-- Tab Container
	local TabContainer = Create("ScrollingFrame", {
		Name = "Tabs",
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 70),
		Size = UDim2.new(1, -20, 1, -80),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		BorderSizePixel = 0
	})
	Create("UIListLayout", {
		Parent = TabContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})
	
	local Window = {
		Tabs = {},
		ActiveTab = nil
	}
	
	-- Legacy compatibility: In the old lib, AddWindow returned a table to AddTab/AddSection. 
	-- But looking at the source, AddWindow actually created the whole thing and returned object with AddSection.
	-- Actually, the old source had library:AddWindow(text) which returned 'sec' table with AddSection.
	-- But it seems it used a top-bar style. We are switching to Sidebar.
	-- To maintain compatibility, we treat `AddWindow` as creating the *Main Window*. 
	-- If the user code calls AddWindow multiple times (creating tabs in Kavo), we need to adapt.
	-- Wait, Kavo treats "Window" as a Tab in some versions? No, `AddWindow` allows adding Tabs?
	-- Re-reading source: `library:AddWindow(text)` creates the main UI, returning a table where you can `AddSection`. Wait..
	-- The old source seems to use `AddWindow` to create TABS. 
	-- "Undo" this mental model: In old Kavo, you do Lib:AddWindow("Title"), then Window:AddTab("TabName") -> Section.
	-- But the provided source `function library:AddWindow(text)` creates a `TEMPLATE_TEXT` in `Upper`. This implies `AddWindow` adds a **Tab**.
	-- So, `library:AddWindow` in the provided source actually adds a Tab to the global window.
	
	-- Correction: The provided source initializes the library which creates `MAIN`, `Upper` (Tab bar), `limit1` (Container).
	-- Then `library:AddWindow(text)` adds a button to `Upper` and a frame to `limit1`. So `AddWindow` = New Tab.
	-- We must preserve this behavior.
	
	-- Since I am creating a "Main Window" inside library initialization (or lazy loading it), I should do that.
	
	if not Library.MainContainer then
		-- Create the single main window first time AddWindow is called, or right now?
		-- The old source created MAIN immediately on require.
		-- I should do the same.
	end
	
	-- Let's refactor:
	-- The code above created a MainFrame. We should hoist this out of AddWindow if we want to call it multiple times.
	-- BUT, if I return a new window object every time, I break common usage if they expect one UI.
	-- The provided source's `AddWindow` adds a TAB.
	-- So `Library` is the Window. `AddWindow` is `AddTab`.
	-- I will expose `Library:AddWindow` as `AddTab` logic.
	
	-- However, standard Kavo usually goes: Window = Lib.CreateLib(...) -> Tab = Window:NewTab(...)
	-- This specific source is a Custom Kavo edit where `AddWindow` acts as a Tab.
	-- I will respect the provided source logic.
	
	-- RE-VERIFYING SOURCE LOGIC:
	-- `library:AddWindow(text)` -> adds button to `Upper`, adds scrolling frame `HOLDER` to `limit1`.
	-- Yes, `AddWindow` creates a "Page/Tab".
	
	-- So, I need to create the Main UI immediately, and `AddWindow` pushes a new button to the Sidebar.
	
	-- Destroy the temp logical wrapper I made and make it global.
	MainFrame:Destroy() 
	ScreenGui:Destroy()
	
	-- New Global initialization
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
		Size = UDim2.new(0, 750, 0, 480),
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
		Text = "UI Library", -- Default title
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
		Size = UDim2.new(1, -20, 1, -70),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		BorderSizePixel = 0
	})
	local TabList = Create("UIListLayout", {
		Parent = TabScroll,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
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
	
	-- Compatibility for FPS/Ping
	spawn(function()
		while true do
			Library.fps = string.format("%d FPS", 1 / RunService.RenderStepped:Wait())
			-- simple ping
			Library.ms = "0ms" -- Placeholder or real logic
			task.wait(1)
		end
	end)
	
	-- Define AddWindow (which creates a Tab)
	function Library:AddWindow(text)
		local TabName = text or "Tab"
		
		-- Tab Button
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
		
		-- Page Container
		local Page = Create("ScrollingFrame", {
			Name = TabName .. "_Page",
			Parent = ContentArea,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 2,
			Visible = false
		})
		-- Two columns usually? or Single? 
		-- Old source had Left/Right columns.
		-- We'll implement a flexible layout using UIListLayout for the page, and Sections will stack.
		
		local PageLayout = Create("UIListLayout", {
			Parent = Page,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10)
		})
		
		-- Left/Right Column implementation wrapper to match legacy API
		-- The old API used `GetSide(col)` to put sections in left/right.
		-- We can simulate this by having two hidden frames and just putting all sections in the main list, OR actually split it.
		-- Let's stick to a clean single column or 2-column if requested.
		-- Old code: `section:AddSection(text, side)` where side 1=left, 2=right.
		
		local LeftColumn = Create("Frame", {
			Name = "Left",
			Parent = Page,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.48, 0, 0, 0), -- Auto scalable
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
		-- Make Page NOT a UIListLayout directly, but a holder for these two
		PageLayout:Destroy()
		
		-- Use a UIGridLayout or just manual positioning? 
		-- Simpler: Page contains 2 Lists.
		
		local LeftList = Create("UIListLayout", {
			Parent = LeftColumn,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10)
		})
		local RightList = Create("UIListLayout", {
			Parent = RightColumn,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10)
		})
		
		-- Selection Logic
		local function Activate()
			if Library.ActiveTab then
				-- Deactivate old
				local oldBtn = Library.ActiveTab.Button
				Tween(oldBtn, {BackgroundTransparency = 1, TextColor3 = CurrentTheme.TextDark})
				oldBtn.Frame.Indicator.Visible = false
				Library.ActiveTab.Page.Visible = false
			end
			
			Library.ActiveTab = {Button = {Frame=TabButton, Text=TabButton}, Page = Page}
			
			Tween(TabButton, {BackgroundTransparency = 0.95, TextColor3 = CurrentTheme.Accent})
			Indicator.Visible = true
			Page.Visible = true
		end
		
		TabButton.MouseButton1Click:Connect(Activate)
		
		-- If first tab, activate
		if #Library.Tabs == 0 then
			Activate()
		end
		table.insert(Library.Tabs, {Button = {Frame=TabButton}, Page = Page})
		
		
		-- Tab Object to return
		local TabObj = {}
		
		function TabObj:AddSection(text, side)
			text = text or "Section"
			side = side or 1 -- 1 = left, 2 = right
			
			local ParentColumn = (side == 2 or side == "Right") and RightColumn or LeftColumn
			
			local SectionContainer = Create("Frame", {
				Name = "Section",
				Parent = ParentColumn,
				BackgroundColor3 = CurrentTheme.Secondary,
				Size = UDim2.new(1, 0, 0, 50), -- Height auto
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0
			})
			Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
			Create("UIStroke", {Parent = SectionContainer, Color = CurrentTheme.Stroke, Thickness = 1})
			
			local SectionTitle = Create("TextLabel", {
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
			
			local Divider = Create("Frame", {
				Parent = SectionContainer,
				BackgroundColor3 = CurrentTheme.Stroke,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0, 32),
				Size = UDim2.new(1, -20, 0, 1)
			})
			
			local ItemContainer = Create("Frame", {
				Parent = SectionContainer,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 40),
				Size = UDim2.new(1, -20, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y
			})
			local ItemList = Create("UIListLayout", {
				Parent = ItemContainer,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			})
			
			-- Pad bottom of section
			Create("UIPadding", {
				Parent = ItemContainer,
				PaddingBottom = UDim.new(0, 10)
			})
			
			-- Section Object
			local SectionObj = {}
			
			--// ELEMENTS //--
			
			function SectionObj:AddButton(text, callback)
				text = text or "Button"
				callback = callback or function() end
				
				local Button = Create("TextButton", {
					Name = "Button",
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
				Create("UIStroke", {Parent = Button, Color = CurrentTheme.Stroke, Thickness = 1})
				
				Ripple(Button)
				
				Button.MouseButton1Click:Connect(callback)
				
				-- Hover
				Button.MouseEnter:Connect(function()
					Tween(Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 35), BorderColor3 = CurrentTheme.Accent}, 0.2)
					Tween(Button.UIStroke, {Color = CurrentTheme.Accent}, 0.2)
				end)
				Button.MouseLeave:Connect(function()
					Tween(Button, {BackgroundColor3 = CurrentTheme.Main}, 0.2)
					Tween(Button.UIStroke, {Color = CurrentTheme.Stroke}, 0.2)
				end)
			end
			
			function SectionObj:AddToggle(text, state, keybind, callback)
				-- Compatible args with old Lib
				callback = callback or function() end
				if type(keybind) == "function" then
					callback = keybind
					keybind = nil
				end
				
				local Enabled = state or false
				
				local ToggleFrame = Create("Frame", {
					Name = "Toggle",
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30)
				})
				
				local ToggleText = Create("TextLabel", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 0),
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
				
				local Button = Create("TextButton", {
					Parent = ToggleFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				
				local function Update()
					Enabled = not Enabled
					Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(50, 50, 50)})
					Tween(Dot, {Position = UDim2.new(0, Enabled and 22 or 2, 0.5, 0)})
					callback(Enabled)
				end
				
				Button.MouseButton1Click:Connect(Update)
				
				-- Return object to allow setting value programmatically
				local ToggleObj = {}
				function ToggleObj:UpdateValue(val)
					if val ~= Enabled then Update() end
				end
				return ToggleObj
			end
			
			function SectionObj:AddSlider(text, max, min, default, callback)
				max = max or 100
				min = min or 0
				default = default or min
				callback = callback or function() end
				
				local SliderFrame = Create("Frame", {
					Name = "Slider",
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 45)
				})
				
				local Label = Create("TextLabel", {
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
				
				local SliderBar = Create("Frame", {
					Parent = SliderFrame,
					BackgroundColor3 = Color3.fromRGB(40, 40, 40),
					Position = UDim2.new(0, 0, 0, 25),
					Size = UDim2.new(1, 0, 0, 6)
				})
				Create("UICorner", {Parent = SliderBar, CornerRadius = UDim.new(1, 0)})
				
				local Fill = Create("Frame", {
					Parent = SliderBar,
					BackgroundColor3 = CurrentTheme.Accent,
					Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
					BorderSizePixel = 0
				})
				Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
				
				local DragButton = Create("TextButton", {
					Parent = SliderBar,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				
				local function Update(input)
					local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
					local value = math.floor(min + ((max - min) * pos))
					
					Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
					ValueLabel.Text = tostring(value)
					callback(value)
				end
				
				local dragging = false
				DragButton.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						Update(input)
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						Update(input)
					end
				end)
			end
			
			function SectionObj:AddDropdown(text, items, default, callback)
				items = items or {}
				default = default or items[1]
				callback = callback or function() end
				
				local DropdownFrame = Create("Frame", {
					Name = "Dropdown",
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32), -- Compressed size
					ClipsDescendants = true
				})
				
				local ListLayout = Create("UIListLayout", {
					Parent = DropdownFrame,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2)
				})
				
				local Header = Create("TextButton", {
					Name = "Header",
					Parent = DropdownFrame,
					BackgroundColor3 = CurrentTheme.Main,
					Size = UDim2.new(1, 0, 0, 30),
					AutoButtonColor = false,
					Text = ""
				})
				Create("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 4)})
				Create("UIStroke", {Parent = Header, Color = CurrentTheme.Stroke, Thickness = 1})
				
				local Label = Create("TextLabel", {
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
				
				local SelectedLabel = Create("TextLabel", {
					Parent = Header,
					BackgroundTransparency = 1,
					Position = UDim2.new(0.6, 0, 0, 0),
					Size = UDim2.new(0.4, -25, 1, 0),
					Font = Enum.Font.Gotham,
					Text = default or "Select...",
					TextColor3 = CurrentTheme.Accent,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right
				})
				
				local Icon = Create("ImageLabel", {
					Parent = Header,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -20, 0.5, -6),
					Size = UDim2.new(0, 12, 0, 12),
					Image = "rbxassetid://6034818372", -- Down arrow
					ImageColor3 = CurrentTheme.TextDark
				})
				
				local expanded = false
				local ItemFrames = {}
				
				local function Toggle()
					expanded = not expanded
					Tween(Icon, {Rotation = expanded and 180 or 0})
					Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, expanded and (32 + (#items * 28)) or 32)})
				end
				
				Header.MouseButton1Click:Connect(Toggle)
				
				-- Items
				for _, item in ipairs(items) do
					local ItemBtn = Create("TextButton", {
						Name = item,
						Parent = DropdownFrame,
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
						SelectedLabel.Text = item
						callback(item)
						Toggle()
					end)
					
					table.insert(ItemFrames, ItemBtn)
				end
			end
			
			function SectionObj:AddTextBox(text, placeholder, clearOnFocus, type, callback)
				-- TextBox implementation
				placeholder = placeholder or "Input..."
				callback = callback or function() end
				
				local BoxFrame = Create("Frame", {
					Name = "Input",
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 35)
				})
				
				local Label = Create("TextLabel", {
					Parent = BoxFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, 0, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
					TextColor3 = CurrentTheme.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local InputBox = Create("TextBox", {
					Parent = BoxFrame,
					BackgroundColor3 = CurrentTheme.Main,
					Position = UDim2.new(0.5, 0, 0, 2),
					Size = UDim2.new(0.5, 0, 1, -4),
					Font = Enum.Font.Gotham,
					PlaceholderText = placeholder,
					Text = "",
					TextColor3 = CurrentTheme.Text,
					TextSize = 13,
					ClearTextOnFocus = clearOnFocus
				})
				Create("UICorner", {Parent = InputBox, CornerRadius = UDim.new(0, 4)})
				Create("UIStroke", {Parent = InputBox, Color = CurrentTheme.Stroke, Thickness = 1})
				
				InputBox.FocusLost:Connect(function(enter)
					if enter then
						callback(InputBox.Text)
					end
				end)
			end
			
			function SectionObj:AddKeyBind(text, defaultKey, callback)
				-- Keybind implementation
				-- Placeholder logic
				callback = callback or function() end
				defaultKey = defaultKey or Enum.KeyCode.RightControl
				
				local BindFrame = Create("Frame", {
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30)
				})
				
				local Label = Create("TextLabel", {
					Parent = BindFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.6, 0, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = text,
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
					Text = defaultKey.Name,
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
						Button.Text = input.KeyCode.Name
						callback(input.KeyCode)
					end
				end)
			end
			
			function SectionObj:AddColorPallete(text, default, callback)
				text = text or "Color"
				default = default or Color3.fromRGB(255, 255, 255)
				callback = callback or function() end
				
				local current = default
				local expanded = false
				
				local PickerFrame = Create("Frame", {
					Name = "ColorPicker",
					Parent = ItemContainer,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
					ClipsDescendants = true
				})
				
				local Label = Create("TextLabel", {
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
				local h, s, v = Color3.toHSV(default)
				
				local function UpdateColor()
					current = Color3.fromHSV(h, s, v)
					Preview.BackgroundColor3 = current
					SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
					callback(current)
				end
				
				local function UpdateSV(input)
					local rPos = Vector2.new(input.Position.X - SVBox.AbsolutePosition.X, input.Position.Y - SVBox.AbsolutePosition.Y)
					local pctX = math.clamp(rPos.X / SVBox.AbsoluteSize.X, 0, 1)
					local pctY = math.clamp(rPos.Y / SVBox.AbsoluteSize.Y, 0, 1)
					
					Cursor.Position = UDim2.new(pctX, 0, pctY, 0)
					s = pctX
					v = 1 - pctY
					UpdateColor()
				end
				
				local function UpdateHue(input)
					local rPos = input.Position.Y - HueBar.AbsolutePosition.Y
					local pct = math.clamp(rPos / HueBar.AbsoluteSize.Y, 0, 1)
					
					HueCursor.Position = UDim2.new(0, -2, pct, 0)
					h = 1 - pct
					UpdateColor()
				end
				
				-- Input Handling
				SVBox.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local dragging = true
						UpdateSV(input)
						local con
						con = UserInputService.InputChanged:Connect(function(MoveInput)
							if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
								UpdateSV(MoveInput)
							end
						end)
						
						local endCon
						endCon = UserInputService.InputEnded:Connect(function(EndInput)
							if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging = false
								con:Disconnect()
								endCon:Disconnect()
							end
						end)
					end
				end)
				
				HueBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local dragging = true
						UpdateHue(input)
						local con
						con = UserInputService.InputChanged:Connect(function(MoveInput)
							if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
								UpdateHue(MoveInput)
							end
						end)
						
						local endCon
						endCon = UserInputService.InputEnded:Connect(function(EndInput)
							if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
								dragging = false
								con:Disconnect()
								endCon:Disconnect()
							end
						end)
					end
				end)
				
				Preview.MouseButton1Click:Connect(function()
					expanded = not expanded
					Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, expanded and 160 or 30)})
				end)
			end
			
			-- Minimal Label
			function SectionObj:AddLabel(text)
				local Label = Create("TextLabel", {
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
	
	-- If text was provided to AddWindow, create that initial tab
	return Library:AddWindow(name)
end 

return Library
