--[[
	CHANGELOGS:
		- Added tracers
]]

-- Services
local players = game:GetService("Players");
local run_service = game:GetService("RunService");
local user_input_service = game:GetService("UserInputService");
local gui_service = (run_service:IsStudio() and game:GetService("GuiService")) or (cloneref and cloneref(game:GetService("GuiService")));

-- Modules
local math_module = loadstring(game:HttpGet("https://raw.githubusercontent.com/dementiaenjoyer/roblox-math/refs/heads/main/module.lua"))();

-- Variables
local camera = workspace.CurrentCamera
local overlay = Instance.new("ScreenGui", (run_service:IsStudio() and players.LocalPlayer.PlayerGui) or (gethui and gethui()) or (game:GetService("CoreGui")));

-- Fonts
local roboto = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal);

-- Main
local _esp = {}; do
	local cache = {};

	_esp.settings = {
		["box"] = {
			["enabled"] = false, 
			["rotate_gradient"] = false,
			["rotation_speed"] = 1,

			["color_1"] = Color3.new(1, 1, 1), 
			["color_2"] = Color3.new(1, 1, 1),

			["outline_color"] = Color3.new(0, 0, 0),
			["outline_transparency"] = 0,
			["transparency"] = 0,
		},
		
		["tracers"] = {
			["enabled"] = false,
			
			["color_1"] = Color3.new(1, 1, 1), 
			["color_2"] = Color3.new(1, 1, 1),
			
			["outline_color"] = Color3.new(0, 0, 0),
			["outline_transparency"] = 1,
			["transparency"] = 0,
		},

		["offset"] = Vector3.new(0, 0.3, 0),
		["size"] = Vector2.new(3, 4),
	};

	_esp.funcs = {}; do
		function _esp.funcs.get_root(character)
			return character:FindFirstChild("HumanoidRootPart");
		end

		function _esp.funcs.get_roots()
			local root_parts = {};
			local children = workspace:GetChildren();

			for _, player in children do
				if (player:FindFirstChildOfClass("Humanoid")) then
					local root = _esp.funcs.get_root(player);

					if (not root) then
						continue;
					end

					root_parts[player] = root;
				end
			end

			return root_parts;
		end
	end

	-- Functions
	do
		function _esp.create(player, root)
			if (cache[player]) then
				return;
			end

			local main_holder = Instance.new("Frame", overlay); do
				main_holder.BorderSizePixel = 0;
				main_holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				main_holder.Size = UDim2.new(1, 0, 1, 0);
				main_holder.BorderColor3 = Color3.fromRGB(0, 0, 0);
				main_holder.BackgroundTransparency = 1;
			end

			local new_cache = {holder = main_holder};

			-- Box
			do
				local box = Instance.new("Frame", main_holder); do
					box.BorderSizePixel = 0;
					box.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					box.Size = UDim2.new(1, 0, 1, 0);
					box.BorderColor3 = Color3.fromRGB(0, 0, 0);
					box.BackgroundTransparency = 1;
					box.ZIndex = 2;
				end

				local outline = Instance.new("Frame", box); do
					outline.BorderSizePixel = 0;
					outline.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					outline.Size = UDim2.new(1, 2, 1, 2);
					outline.BorderColor3 = Color3.fromRGB(0, 0, 0);
					outline.BackgroundTransparency = 1;
					outline.Position = UDim2.new(0, -1, 0, -1);
					outline.ZIndex = 3;
				end

				local inline_stroke = Instance.new("UIStroke", outline); do
					inline_stroke.Color = Color3.fromRGB(255, 255, 255);
					inline_stroke.LineJoinMode = Enum.LineJoinMode.Miter;
				end

				local outline_stroke = Instance.new("UIStroke", box); do
					outline_stroke.Thickness = 3;
					outline_stroke.LineJoinMode = Enum.LineJoinMode.Miter;
				end

				new_cache.box = {box = box, outline = outline, outline_stroke = outline_stroke, inline_stroke = inline_stroke, color_gradient = Instance.new("UIGradient", inline_stroke)};
			end
			
			-- Tracers
			do
				local tracer_line = Instance.new("Frame", main_holder); do
					tracer_line.BorderSizePixel = 0;
					tracer_line.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					tracer_line.Size = UDim2.new(1, 0, 1, 0);
					tracer_line.BorderColor3 = Color3.fromRGB(0, 0, 0);
					tracer_line.AnchorPoint = Vector2.new(0.5, 0.5);
					tracer_line.ZIndex = 1;
				end
				
				local color_gradient = Instance.new("UIGradient", tracer_line);
				
				local outline_stroke = Instance.new("UIStroke", tracer_line); do
					outline_stroke.Thickness = 1;
					outline_stroke.LineJoinMode = Enum.LineJoinMode.Miter;
				end
				
				new_cache.tracer = {tracer_line = tracer_line, outline_stroke = outline_stroke, color_gradient = color_gradient};
			end

			cache[player] = new_cache;
		end

		function _esp.remove(player)
			if (not cache[player]) then
				return
			end

			for _, object in cache[player] do
				local element_type = typeof(object)

				if (element_type == "table") then
					for _, element in object do
						element:Destroy();
					end
				elseif (element_type == "Instance") then
					object:Destroy();
				end
			end

			cache[player] = nil;
		end

		function _esp.update(player, object_cache, root)
			if (not cache[player]) then
				return;
			end

			if (not player or not player.Parent or not root or not root.Parent) then
				return _esp.remove(player);
			end

			local position = root.Position - _esp.settings.offset;
			
			local world_to_screen_point, on_screen = camera:WorldToScreenPoint(position);
			local world_to_viewport_point, on_screen = camera:WorldToViewportPoint(position);
			
			local distance = world_to_screen_point.Z;

			if (not on_screen) then
				return _esp.remove(player);
			end

			local holder = object_cache.holder;
			local box = object_cache.box;
			local tracer = object_cache.tracer;

			local scale = (2 * camera.ViewportSize.Y) / ((2 * distance * math.tan(math.rad(camera.FieldOfView) / 2)) * 1.5); -- this is pasted from somewhere, i can't remember where

			local size = _esp.settings.size;
			local width, height = size.X * scale, size.Y * scale;
			
			local main_box = box.box;
			local main_outline = box.outline;

			-- Box
			do
				local box_settings = _esp.settings.box; do
					local enabled = box_settings.enabled;

					main_box.Visible = enabled;
					main_outline.Visible = enabled;

					if (enabled) then
						main_box.Size = UDim2.new(0, width, 0, height);
						main_box.Position = UDim2.new(0, world_to_screen_point.X - (width / 2), 0, world_to_screen_point.Y - (height / 2));

						main_outline.Size = UDim2.new(1, 2, 1, 2);
						main_outline.Position = UDim2.new(0, -1, 0, -1);

						local outline_stroke = box.outline_stroke; do
							outline_stroke.Color = box_settings.outline_color;
							outline_stroke.Transparency = box_settings.outline_transparency;
						end

						local color_gradient = box.color_gradient; do
							if (box_settings.rotate_gradient) then
								color_gradient.Rotation += box_settings.rotation_speed;
							end

							color_gradient.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, box_settings.color_1),
								ColorSequenceKeypoint.new(1, box_settings.color_2),
							});
						end
					end
				end
			end
			
			-- Tracer
			do
				local tracer_settings = _esp.settings.tracers; do
					local enabled = tracer_settings.enabled;
					local tracer_line = tracer.tracer_line;
					
					tracer_line.Visible = enabled;
					
					if (enabled) then
						local position, rotation, size = math_module.line_rotation(user_input_service:GetMouseLocation(), Vector2.new(world_to_viewport_point.X, world_to_viewport_point.Y + (main_box.Size.Y.Offset / 2)), 1, gui_service)

						tracer_line.Position = position;
						tracer_line.Size = size;
						tracer_line.Rotation = rotation;
						tracer_line.BackgroundTransparency = tracer.transparency;
						
						local outline_stroke = tracer.outline_stroke; do
							outline_stroke.Color = tracer_settings.outline_color;
							outline_stroke.Transparency = tracer_settings.outline_transparency;
						end
						
						local color_gradient = tracer.color_gradient; do
							color_gradient.Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, tracer_settings.color_1),
								ColorSequenceKeypoint.new(1, tracer_settings.color_2),
							});
						end
					end
				end
			end
		end
	end

	-- Connections
	do
		_esp.heartbeat = nil;

		function _esp.load()
			_esp.heartbeat = run_service.Heartbeat:Connect(function(dt)
				local roots = _esp.funcs.get_roots();

				for player, root in roots do
					_esp.create(player, root);
				end

				for player, data in cache do
					_esp.update(player, data, roots[player], _esp.settings.offset, dt);
				end
			end)
		end

		function _esp.unload()
			if (_esp.heartbeat) then
				_esp.heartbeat:Disconnect();
			end
		end
	end
end

return _esp; 
