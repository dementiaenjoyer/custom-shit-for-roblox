-- This is my esp project. I plan on expanding this soon

-- Services
local players = game.GetService(game, "Players");
local run_service = game.GetService(game, "RunService");

-- Variables
local camera = workspace.CurrentCamera;
local overlay = Instance.new("ScreenGui", (run_service.IsStudio(run_service) and players.LocalPlayer.PlayerGui) or (gethui and gethui()) or (game.GetService(game, "CoreGui")));

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
			["color_2"] = Color3.new(1, 1, 1)
		},
		
		["offset"] = vector.create(0, 1, 0),
		["size"] = vector.create(3, 4),
	};
	
	_esp.funcs = {}; do
		function _esp.funcs.get_root(player)
			local character = player.Character;

			if (not character) then
				return;
			end

			return character.FindFirstChild(character, "HumanoidRootPart");
		end

		function _esp.funcs.get_roots()
			local root_parts = {};
			local children = players.GetChildren(players);

			for index = 1, #children do
				local player = children[index];
				local root = _esp.funcs.get_root(player);

				if (not root) then
					continue;
				end

				root_parts[player] = root;
			end

			return root_parts;
		end
	end

	-- Functions
	do
		function _esp.create(object)
			if (cache[object]) then
				return;
			end

			local main_holder = Instance.new("Frame", overlay); do
				main_holder.BorderSizePixel = 0;
				main_holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
				main_holder.Size = UDim2.new(1, 0, 1, 0);
				main_holder.BorderColor3 = Color3.fromRGB(0, 0, 0);
				main_holder.BackgroundTransparency = 1;
				main_holder.Name = "Holder";
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

			cache[object] = new_cache;
		end

		function _esp.remove(object)
			if (not cache[object]) then
				return;
			end

			for _, object in cache[object] do
				local element_type = typeof(object);

				if (element_type == "table") then
					for _, element in object do
						element.Destroy(element);
					end
				elseif (element_type == "Instance") then
					object.Destroy(object);
				end
			end

			cache[object] = nil;
		end

		function _esp.update(object, object_cache, root)
			if (not cache[object]) then
				return;
			end

			local world_to_screen, on_screen = camera.WorldToScreenPoint(camera, root.Position - _esp.settings.offset);
			local distance = world_to_screen.Z;

			if (not on_screen) or (not root) then
				return _esp.remove(object);
			end

			local holder = object_cache.holder;
			local box = object_cache.box;
			
			local scale = (root.Size.Y * camera.ViewportSize.Y) / ((2 * distance * math.tan(math.rad(camera.FieldOfView) / 2)) * 1.5); -- this is pasted from somewhere, i can't remember where
			
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
						
						local color_gradient = box.color_gradient; do
							if (box_settings.rotation_speed) then
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
				for player, root in _esp.funcs.get_roots() do
					_esp.create(player);
					_esp.update(player, cache[player], root, _esp.settings.offset, dt);
				end

				for player, data in cache do
					if (not _esp.funcs.get_root(player)) then
						_esp.remove(player);
					end
				end
			end)
		end
		
		function _esp.unload()
			if (heartbeat) then
				heartbeat.Disconnect(heartbeat);
			end
		end
	end
end

return _esp;
