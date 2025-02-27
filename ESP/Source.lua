--[[
	CHANGELOGS:
		- Fixed issues regarding custom game support
		- Fixed issues where elements wouldn't get deleted if the esp priority got destroyed
		- Switched to namecalling instead of indexing, only more optimized in some scenarios
		- Preset size for root Y to prevent scaling miscalculation
		- More customization
]]

-- Services
local players = game:GetService("Players");
local run_service = game:GetService("RunService");

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
			
			["outline_transparency"] = 0,
			["transparency"] = 0,
		},

		["offset"] = Vector3.new(0, 1, 0),
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
				end

				local outline = Instance.new("Frame", box); do
					outline.BorderSizePixel = 0;
					outline.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
					outline.Size = UDim2.new(1, 2, 1, 2);
					outline.BorderColor3 = Color3.fromRGB(0, 0, 0);
					outline.BackgroundTransparency = 1;
					outline.Position = UDim2.new(0, -1, 0, -1);
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

			local world_to_screen, on_screen = camera:WorldToScreenPoint(root.Position - _esp.settings.offset);
			local distance = world_to_screen.Z;

			if (not on_screen) then
				return _esp.remove(player);
			end

			local holder = object_cache.holder;
			local box = object_cache.box;

			local scale = (2 * camera.ViewportSize.Y) / ((2 * distance * math.tan(math.rad(camera.FieldOfView) / 2)) * 1.5); -- this is pasted from somewhere, i can't remember where

			local size = _esp.settings.size;
			local width, height = size.X * scale, size.Y * scale;

			-- Box
			do
				local main_box = box.box;
				local main_outline = box.outline;

				local box_settings = _esp.settings.box; do
					local enabled = box_settings.enabled;

					main_box.Visible = enabled;
					main_outline.Visible = enabled;

					if (enabled) then
						main_box.Size = UDim2.new(0, width, 0, height);
						main_box.Position = UDim2.new(0, world_to_screen.X - (width / 2), 0, world_to_screen.Y - (height / 2));

						main_outline.Size = UDim2.new(1, 2, 1, 2);
						main_outline.Position = UDim2.new(0, -1, 0, -1);
						
						box.outline_stroke.Transparency = box_settings.outline_transparency;

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
		end
	end

	-- Connections
	do
		local heartbeat = nil;

		function _esp.load()
			heartbeat = run_service.Heartbeat:Connect(function(dt)
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
			if (heartbeat) then
				heartbeat:Disconnect();
			end
		end
	end
end

return _esp;
