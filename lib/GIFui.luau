local GIFui = {}
GIFui.__index = GIFui

local Players    = game:GetService("Players")
local TweenSvc   = game:GetService("TweenService")
local InputSvc   = game:GetService("UserInputService")
local RunSvc     = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local T = {
	BG        = Color3.fromRGB(13,  13,  16),
	Surface   = Color3.fromRGB(22,  22,  28),
	Elevated  = Color3.fromRGB(30,  30,  38),
	Border    = Color3.fromRGB(48,  48,  60),
	Accent    = Color3.fromRGB(99,  102, 241),
	AccentHov = Color3.fromRGB(129, 131, 255),
	Success   = Color3.fromRGB(34,  197, 94),
	Text      = Color3.fromRGB(245, 245, 250),
	TextDim   = Color3.fromRGB(140, 140, 160),
	Font      = Enum.Font.GothamMedium,
	FontBold  = Enum.Font.GothamBold,
}

local TWEEN_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED   = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function New(class, props, children)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do obj[k] = v end
	for _, c in pairs(children or {}) do c.Parent = obj end
	return obj
end

local function Corner(r)
	return New("UICorner", { CornerRadius = UDim.new(0, r or 8) })
end

local function Stroke(color, thick)
	return New("UIStroke", { Color = color or T.Border, Thickness = thick or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

local function Tween(obj, info, props)
	TweenSvc:Create(obj, info, props):Play()
end

local function Pad(px)
	return New("UIPadding", {
		PaddingTop    = UDim.new(0, px),
		PaddingBottom = UDim.new(0, px),
		PaddingLeft   = UDim.new(0, px),
		PaddingRight  = UDim.new(0, px),
	})
end

local function MakeDraggable(handle, target)
	local dragging, startMouse, startPos = false, nil, nil
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging   = true
			startMouse = InputSvc:GetMouseLocation()
			startPos   = Vector2.new(target.Position.X.Scale, target.Position.Y.Scale)
		end
	end)
	handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
			dragging = false 
		end
	end)
	RunSvc.Heartbeat:Connect(function()
		if not dragging then return end
		local m = InputSvc:GetMouseLocation()
		local vp = workspace.CurrentCamera.ViewportSize
		local delta = (m - startMouse) / vp
		target.Position = UDim2.fromScale(startPos.X + delta.X, startPos.Y + delta.Y)
	end)
end

local Root = New("ScreenGui", {
	Name            = "GIFui",
	Parent          = (game:FindFirstChild("CoreGui") or PlayerGui),
	IgnoreGuiInset  = true,
	ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
	ResetOnSpawn    = false,
	DisplayOrder    = 9e6,
})

function GIFui:CreateWindow(title, destroyCallback)
	local Win = { _tabs = {}, _activeTab = nil, _conns = {}, _elementCount = 0 }

	local function Track(c) table.insert(Win._conns, c) end

	local Shell = New("CanvasGroup", {
		Parent          = Root,
		Size            = UDim2.fromScale(0.55, .5),
		AutomaticSize   = Enum.AutomaticSize.None,
		Position        = UDim2.fromScale(0.5, 0.5),
		AnchorPoint     = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		Corner(12),
		New("UIAspectRatioConstraint", { AspectRatio = 1 }),
		New("UISizeConstraint", { MinSize = Vector2.new(250, 250) }),
	})

	local TopBar = New("Frame", {
		Parent          = Shell,
		Size            = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = T.Surface,
		BorderSizePixel = 0,
		ZIndex          = 3,
	}, {
		New("Frame", {
			Size             = UDim2.new(1, 0, 0.5, 0),
			AnchorPoint      = Vector2.new(0, 1),
			Position         = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = T.Surface,
			BorderSizePixel  = 0,
			ZIndex           = 3,
		}),
		Corner(12),
		New("TextLabel", {
			Text             = title or "GIFui",
			Font             = T.FontBold,
			TextSize         = 17,
			TextColor3       = T.Text,
			BackgroundTransparency = 1,
			Size             = UDim2.new(1, -110, 1, 0),
			Position         = UDim2.new(0, 16, 0, 0),
			TextXAlignment   = Enum.TextXAlignment.Left,
			ZIndex           = 4,
		}),
	})

	local BtnHolder = New("Frame", {
		Parent          = TopBar,
		Size            = UDim2.new(0, 84, 0, 34),
		Position        = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint     = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		ZIndex          = 4,
	}, {
		New("UIListLayout", {
			FillDirection       = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment   = Enum.VerticalAlignment.Center,
			Padding             = UDim.new(0, 6),
		}),
	})

	local function TopBtn(col, icon, cb)
		local b = New("TextButton", {
			Parent           = BtnHolder,
			Size             = UDim2.new(0, 32, 0, 32),
			BackgroundColor3 = col,
			Text             = icon,
			TextColor3       = T.Text,
			Font             = T.FontBold,
			TextSize         = 16,
			AutoButtonColor  = false,
			ZIndex           = 5,
		}, { Corner(6) })
		b.MouseButton1Click:Connect(cb)
		b.MouseEnter:Connect(function() Tween(b, TWEEN_FAST, { BackgroundColor3 = col:Lerp(Color3.new(1,1,1), 0.15) }) end)
		b.MouseLeave:Connect(function() Tween(b, TWEEN_FAST, { BackgroundColor3 = col }) end)
		return b
	end

	local minimised = false
	local ContentFrame 

	TopBtn(T.Elevated, "—", function()
		minimised = not minimised
		if minimised then
			Tween(ContentFrame, TWEEN_MED, { Size = UDim2.new(1, 0, 0, 0) })
		else
			Tween(ContentFrame, TWEEN_MED, { Size = UDim2.new(1, 0, 1, -52) })
		end
	end)
	TopBtn(Color3.fromRGB(220, 50, 50), "X", function()
		Win:Destroy()
	end)

	MakeDraggable(TopBar, Shell)

	ContentFrame = New("Frame", {
		Parent          = Shell,
		Size            = UDim2.new(1, 0, 1, -52),
		Position        = UDim2.new(0, 0, 0, 52),
		BackgroundTransparency = 0,
		BackgroundColor3 = T.BG,
		ClipsDescendants = true,
	})

	local Sidebar = New("ScrollingFrame", {
		Parent                    = ContentFrame,
		Size                      = UDim2.new(0.27, 0, 1, 0),
		BackgroundColor3          = T.Surface,
		BorderSizePixel           = 0,
		ScrollBarThickness        = 0,
		AutomaticCanvasSize       = Enum.AutomaticSize.Y,
		CanvasSize                = UDim2.new(0, 0, 0, 0),
		ClipsDescendants          = true,
	}, {
		New("UIListLayout", {
			Padding             = UDim.new(0, 4),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		Pad(8),
	})

	New("Frame", {
		Parent          = ContentFrame,
		Size            = UDim2.new(0, 1, 1, 0),
		Position        = UDim2.new(0.27, 0, 0, 0),
		BackgroundColor3 = T.Border,
		BorderSizePixel = 0,
	})

	local OptionsPane = New("ScrollingFrame", {
		Parent                    = ContentFrame,
		Size                      = UDim2.new(0.73, -1, 1, 0),
		Position                  = UDim2.new(0.27, 1, 0, 0),
		BackgroundTransparency    = 1,
		BorderSizePixel           = 0,
		ScrollBarThickness        = 0,
		ScrollBarImageColor3      = T.Border,
		AutomaticCanvasSize       = Enum.AutomaticSize.Y,
		CanvasSize                = UDim2.new(0, 0, 0, 0),
	}, {
		New("UIListLayout", {
			SortOrder           = Enum.SortOrder.LayoutOrder,
			Padding             = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		New("UIPadding", {
			PaddingTop    = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft   = UDim.new(0, 8),
			PaddingRight  = UDim.new(0, 8),
		}),
	})

	function Win:CreateTab(title)
		local Tab = { _elements = {} }

		local TabBtn = New("TextButton", {
			Parent          = Sidebar,
			Size            = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = T.BG,
			TextTransparency = 1,
			AutoButtonColor = false,
		}, { Corner(5) })

		local TabTitle = New("TextLabel", {
			Parent = TabBtn,
			BackgroundTransparency = 1,
			TextColor3 = T.TextDim,
			Font = T.FontBold,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.5),
			TextScaled = true,
			Text = title,
		})

		local AccentBar = New("Frame", {
			Parent          = TabBtn,
			Size            = UDim2.new(0, 3, 0.6, 0),
			Position        = UDim2.new(0, 0, 0.2, 0),
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = 1,
		}, { Corner(3) })

		local function setActive(on)
			Tween(TabBtn,    TWEEN_FAST, { BackgroundColor3 = on and T.Elevated or T.BG })
			Tween(TabTitle,    TWEEN_FAST, { TextColor3       = on and T.Text     or T.TextDim })
			Tween(AccentBar, TWEEN_FAST, { BackgroundTransparency = on and 0 or 1 })
		end

		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Win._tabs) do
				t._setActive(false)
				for _, el in pairs(t._elements) do el.Visible = false end
			end
			setActive(true)
			for _, el in pairs(Tab._elements) do el.Visible = true end
			Win._activeTab = Tab
		end)

		TabBtn.MouseEnter:Connect(function()
			if Win._activeTab ~= Tab then
				Tween(TabBtn, TWEEN_FAST, { BackgroundColor3 = T.Elevated:Lerp(T.BG, 0.5) })
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if Win._activeTab ~= Tab then
				Tween(TabBtn, TWEEN_FAST, { BackgroundColor3 = T.BG })
			end
		end)

		Tab._setActive = setActive
		table.insert(Win._tabs, Tab)

		if #Win._tabs == 1 then
			setActive(true)
			Win._activeTab = Tab
		end

		local function makeCard(h)
			Win._elementCount = Win._elementCount + 1
			local card = New("Frame", {
				Parent          = OptionsPane,
				Size            = UDim2.new(1, 0, 0, h or 64),
				BackgroundColor3 = T.Elevated,
				LayoutOrder     = Win._elementCount,
				Visible         = Win._activeTab == Tab,
			}, { Corner(10), Stroke(T.Border, 1) })
			table.insert(Tab._elements, card)
			return card
		end

		function Tab:CreateToggle(label, desc, default, callback)
			local card = makeCard(desc and 72 or 52)
			local state = default or false

			New("TextLabel", {
				Parent          = card,
				Text            = label,
				Font            = T.FontBold,
				TextSize        = 15,
				TextColor3      = T.Text,
				TextXAlignment  = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				AnchorPoint     = Vector2.new(0, 0),
				Position        = UDim2.new(0, 14, 0, desc and 9 or 0),
				Size            = UDim2.new(0.65, -14, 0, desc and 24 or card.Size.Y.Offset),
			})
			if desc then
				New("TextLabel", {
					Parent          = card,
					Position        = UDim2.new(0, 14, 0, 33),
					Size            = UDim2.new(0.65, -14, 0, 24),
					Text            = desc,
					TextWrapped     = true,
					Font            = T.Font,
					TextSize        = 12,
					TextColor3      = T.TextDim,
					TextXAlignment  = Enum.TextXAlignment.Left,
					TextYAlignment  = Enum.TextYAlignment.Top,
					BackgroundTransparency = 1,
				})
			end

			local Track = New("Frame", {
				Parent          = card,
				Size            = UDim2.new(0, 40, 0, 22),
				AnchorPoint     = Vector2.new(1, 0.5),
				Position        = UDim2.new(1, -14, 0.5, 0),
				BackgroundColor3 = state and T.Success or T.Border,
			}, { Corner(11) })
			local Knob = New("Frame", {
				Parent          = Track,
				Size            = UDim2.new(0, 16, 0, 16),
				AnchorPoint     = Vector2.new(0.5, 0.5),
				Position        = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0),
				BackgroundColor3 = Color3.new(1,1,1),
			}, { Corner(9) })

			local Btn = New("TextButton", {
				Parent          = card,
				Size            = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text            = "",
				ZIndex          = 2,
			})

			local function refresh()
				Tween(Track, TWEEN_FAST, { BackgroundColor3 = state and T.Success or T.Border })
				Tween(Knob,  TWEEN_FAST, { Position = state and UDim2.new(1, -11, 0.5, 0) or UDim2.new(0, 11, 0.5, 0) })
				if callback then callback(state) end
			end

			Btn.MouseButton1Click:Connect(function()
				state = not state
				refresh()
			end)

			local toggle = {}
			function toggle:Set(v) state = v; refresh() end
			function toggle:Get() return state end
			return toggle
		end

		function Tab:CreateButton(label, desc, callback)
			local card = makeCard(desc and 72 or 52)

			New("TextLabel", {
				Parent          = card,
				Position        = UDim2.new(0, 14, 0, desc and 9 or 0),
				Size            = UDim2.new(0.7, -14, 0, desc and 24 or card.Size.Y.Offset),
				Text            = label,
				Font            = T.FontBold,
				TextSize        = 15,
				TextColor3      = T.Text,
				TextXAlignment  = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
			})
			if desc then
				New("TextLabel", {
					Parent          = card,
					Position        = UDim2.new(0, 14, 0, 33),
					Size            = UDim2.new(0.7, -14, 0, 24),
					Text            = desc,
					TextWrapped     = true,
					Font            = T.Font,
					TextSize        = 12,
					TextColor3      = T.TextDim,
					TextXAlignment  = Enum.TextXAlignment.Left,
					TextYAlignment  = Enum.TextYAlignment.Top,
					BackgroundTransparency = 1,
				})
			end

			local Btn = New("TextButton", {
				Parent          = card,
				AnchorPoint     = Vector2.new(1, 0.5),
				Position        = UDim2.new(1, -14, 0.5, 0),
				Size            = UDim2.new(0, 84, 0, 34),
				BackgroundColor3 = T.Accent,
				Text            = "Run",
				Font            = T.FontBold,
				TextSize        = 14,
				TextColor3      = Color3.new(1,1,1),
				AutoButtonColor = false,
			}, { Corner(8) })

			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, TWEEN_FAST, { BackgroundColor3 = T.AccentHov })
				task.delay(0.15, function()
					Tween(Btn, TWEEN_FAST, { BackgroundColor3 = T.Accent })
				end)
				if callback then callback() end
			end)
			Btn.MouseEnter:Connect(function() Tween(Btn, TWEEN_FAST, { BackgroundColor3 = T.AccentHov }) end)
			Btn.MouseLeave:Connect(function() Tween(Btn, TWEEN_FAST, { BackgroundColor3 = T.Accent }) end)
		end

		function Tab:CreateInput(label, placeholder, callback)
			local card = makeCard(76)

			New("TextLabel", {
				Parent          = card,
				Position        = UDim2.new(0, 14, 0, 10),
				Size            = UDim2.new(1, -28, 0, 22),
				Text            = label,
				Font            = T.FontBold,
				TextSize        = 15,
				TextColor3      = T.Text,
				TextXAlignment  = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
			})

			local Box = New("TextBox", {
				Parent              = card,
				Position            = UDim2.new(0, 14, 0, 40),
				Size                = UDim2.new(1, -28, 0, 28),
				BackgroundColor3    = T.Surface,
				PlaceholderText     = placeholder or "Enter value...",
				PlaceholderColor3   = T.TextDim,
				Text                = "",
				Font                = T.Font,
				TextSize            = 14,
				TextColor3          = T.Text,
				ClearTextOnFocus    = false,
			}, { Corner(6), Stroke(T.Border, 1) })

			Box:GetPropertyChangedSignal("Text"):Connect(function()
				if callback then callback(Box.Text) end
			end)
			Box.Focused:Connect(function() Tween(Box:FindFirstChildOfClass("UIStroke"), TWEEN_FAST, { Color = T.Accent }) end)
			Box.FocusLost:Connect(function() Tween(Box:FindFirstChildOfClass("UIStroke"), TWEEN_FAST, { Color = T.Border }) end)

			local input = {}
			function input:Get() return Box.Text end
			function input:Set(v) Box.Text = tostring(v or "") end
			return input
		end

		function Tab:CreateLabel(text, color)
			Win._elementCount = Win._elementCount + 1
			local lbl = New("TextLabel", {
				Parent          = OptionsPane,
				Size            = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Text            = text or "",
				Font            = T.Font,
				TextSize        = 12,
				TextColor3      = color or T.TextDim,
				TextXAlignment  = Enum.TextXAlignment.Left,
				LayoutOrder     = Win._elementCount,
				Visible         = Win._activeTab == Tab,
			}, {
				New("UIPadding", { PaddingLeft = UDim.new(0, 8) }),
			})
			table.insert(Tab._elements, lbl)
		end

		function Tab:CreateSlider(label, desc, min, max, default, callback)
			local card = makeCard(desc and 86 or 64)
			local val = default or min
			val = math.clamp(val, min, max)
			local range = math.max(max - min, 0.001)

			New("TextLabel", {
				Parent          = card,
				Text            = label,
				Font            = T.FontBold,
				TextSize        = 15,
				TextColor3      = T.Text,
				TextXAlignment  = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				AnchorPoint     = Vector2.new(0, 0),
				Position        = UDim2.new(0, 14, 0, 10),
				Size            = UDim2.new(0.65, -14, 0, 22),
			})
			if desc then
				New("TextLabel", {
					Parent          = card,
					Position        = UDim2.new(0, 14, 0, 31),
					Size            = UDim2.new(0.65, -14, 0, 24),
					Text            = desc,
					TextWrapped     = true,
					Font            = T.Font,
					TextSize        = 12,
					TextColor3      = T.TextDim,
					TextXAlignment  = Enum.TextXAlignment.Left,
					TextYAlignment  = Enum.TextYAlignment.Top,
					BackgroundTransparency = 1,
				})
			end

			local ValLabel = New("TextLabel", {
				Parent          = card,
				AnchorPoint     = Vector2.new(1, 0),
				Position        = UDim2.new(1, -14, 0, 10),
				Size            = UDim2.new(0, 50, 0, 22),
				Text            = tostring(val),
				Font            = T.FontBold,
				TextSize        = 14,
				TextColor3      = T.Text,
				TextXAlignment  = Enum.TextXAlignment.Right,
				BackgroundTransparency = 1,
			})

			local TrackLine = New("Frame", {
				Parent          = card,
				Size            = UDim2.new(1, -28, 0, 6),
				AnchorPoint     = Vector2.new(0.5, 1),
				Position        = UDim2.new(0.5, 0, 1, -14),
				BackgroundColor3 = T.Border,
			}, { Corner(3) })

			local Fill = New("Frame", {
				Parent          = TrackLine,
				Size            = UDim2.new((val - min)/range, 0, 1, 0),
				BackgroundColor3 = T.Accent,
			}, { Corner(3) })

			local Knob = New("Frame", {
				Parent          = Fill,
				Size            = UDim2.new(0, 14, 0, 14),
				AnchorPoint     = Vector2.new(0.5, 0.5),
				Position        = UDim2.new(1, 0, 0.5, 0),
				BackgroundColor3 = Color3.new(1,1,1),
			}, { Corner(7) })

			local Btn = New("TextButton", {
				Parent          = TrackLine,
				Size            = UDim2.new(1, 0, 1, 24),
				AnchorPoint     = Vector2.new(0.5, 0.5),
				Position        = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				Text            = "",
				ZIndex          = 2,
			})

			local dragging = false
			local function updateSlider(input)
				local valPct = math.clamp((input.Position.X - TrackLine.AbsolutePosition.X) / TrackLine.AbsoluteSize.X, 0, 1)
				local newVal = min + ((max - min) * valPct)
				newVal = math.floor(newVal * 1000 + 0.5) / 1000
				newVal = math.clamp(newVal, min, max)
				if newVal ~= val then
					val = newVal
					ValLabel.Text = tostring(val)
					Tween(Fill, TWEEN_FAST, { Size = UDim2.new((val - min)/range, 0, 1, 0) })
					if callback then callback(val) end
				end
			end

			Btn.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateSlider(input)
				end
			end)

			Track(InputSvc.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end))

			Track(InputSvc.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateSlider(input)
				end
			end))

			local slider = {}
			function slider:Get() return val end
			function slider:Set(v)
				val = math.floor(v * 1000 + 0.5) / 1000
				val = math.clamp(val, min, max)
				ValLabel.Text = tostring(val)
				Tween(Fill, TWEEN_FAST, { Size = UDim2.new((val - min)/range, 0, 1, 0) })
				if callback then callback(val) end
			end
			return slider
		end

		return Tab
	end

	function Win:Destroy()
		for _, c in pairs(self._conns) do c:Disconnect() end
		if destroyCallback then destroyCallback() end
		Shell:Destroy()
	end

	return Win
end

return GIFui
