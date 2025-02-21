local run_service = game.GetService(game, "RunService");
local chams_parent = (gethui and gethui()) or (cloneref and cloneref(game.GetService(game, "CoreGui"))) or game.GetService(game, "CoreGui");

local chams = {}; do
	-- Utility
	chams.connection = nil;
	chams.created = {};
	chams.utility = {
		["is_head"] = function(bodypart, size, mesh)
			return (bodypart.Name == "Head") or (size == Vector3.new(1, 1, 1)) or (mesh == "rbxassetid://6179256256");
		end,
	};

	-- Settings
	chams.enabled = true;
	chams.occluded_color = Color3.fromRGB(58, 61, 255);
	chams.visible_color = Color3.fromRGB(255, 255, 255);

	-- Functions
	chams.update = function(cham_object, character)
		local chams_enabled = chams.enabled;
		local occluded_color, visible_color = chams.occluded_color, chams.visible_color;

		for body_part, cham in cham_object do
			local occluded, visible = cham.occluded, cham.visible;

			if (not chams.enabled) or (not body_part or body_part.Parent == nil) or (occluded.Parent == nil) or (visible.Parent == nil) then
				chams.remove(cham, body_part);
			end

			occluded.Color3 = chams.occluded_color;
			visible.Color3 = chams.visible_color;
		end
	end

	chams.create = function(character)			
		if (not character) then
			return;
		end

		if (not chams.created[character]) then
			chams.created[character] = {};
		end

		for _, bodypart in character.GetChildren(character) do
			if (bodypart.IsA(bodypart, "BasePart")) then
				local bodypart_name = bodypart.Name;

				if (bodypart_name ~= "HumanoidRootPart") then
					local mesh_part = bodypart.FindFirstChildOfClass(bodypart, "SpecialMesh");
					local identify_head = chams.utility.is_head(bodypart, bodypart.Size, (mesh_part and mesh_part.MeshId) or "")

					if (not chams.created[character][bodypart]) then
						chams.created[character][bodypart] = {};
					end

					local cached_bodyparts = chams.created[character][bodypart];
					local occluded = Instance.new("BoxHandleAdornment", chams_parent);
					local visible = Instance.new("BoxHandleAdornment", occluded);

					occluded.Adornee = bodypart;
					occluded.AlwaysOnTop = true;
					occluded.Transparency = 0.8;
					occluded.Color3 = chams.occluded_color;
					occluded.ZIndex = 1;
					occluded.Size = bodypart.Size;

					visible.Adornee = bodypart;
					visible.Transparency = 0.5;
					visible.Color3 = chams.visible_color;
					visible.ZIndex = 1;
					visible.Size = (identify_head and bodypart.Size * 1.05) or bodypart.Size * 1.03;
					visible.Parent = occluded;

					local accessories = character.FindFirstChildOfClass(character, "Folder");

					cached_bodyparts.visible = visible;
					cached_bodyparts.occluded = occluded;
					cached_bodyparts.transparency = bodypart.Transparency;

					if (accessories) then
						accessories.Parent = nil;
						cached_bodyparts.accessories = accessories;
					end

					bodypart.Transparency = 1;
				end
			end
		end
	end

	chams.remove = function(cham, bodypart, character)
		if (not cham) or (not bodypart) then
			return;
		end

		local occluded, visible = cham.occluded, cham.visible;

		if (occluded and visible) then
			occluded.Destroy(occluded);
			visible.Destroy(visible);
		end

		local cloned_accessories = cham.accessories;

		if (cloned_accessories) then
			cloned_accessories.Parent = character;
		end

		bodypart.Transparency = cham.transparency;
		chams.created[character][bodypart] = nil;
	end


	chams.unload = function()
		chams.connection = nil;

		for character, cham_object in chams.created do
			for bodypart, cham in cham_object do
				chams.remove(cham, bodypart, character);
			end
		end
	end

	-- Loops
	do
		chams.connection = run_service.Heartbeat:Connect(function(dt)
			for character, cham_object in chams.created do
				chams.update(cham_object, character);
			end
		end)
	end
end

return chams;
