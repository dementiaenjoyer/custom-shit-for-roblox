-- This code is pretty bad, but i just wanted to get it working so i did some ghetto stuff

local run_service = game.GetService(game, "RunService");
local chams_parent = run_service:IsStudio() and workspace or ((gethui and gethui()) or (cloneref and cloneref(game.GetService(game, "CoreGui"))) or game.GetService(game, "CoreGui"));

local chams = {}; do
	-- Utility
	local sizes = {
		["Head"] = Vector3.new(1, 1, 1),
		["Torso"] = Vector3.new(2, 2, 1),
		["Right Leg"] = Vector3.new(1, 2, 1),
		["Left Leg"] = Vector3.new(1, 2, 1),
		["Right Arm"] = Vector3.new(1, 2, 1),
		["Left Arm"] = Vector3.new(1, 2, 1),
	};
	
	local mesh_ids = {
		["rbxassetid://6179256256"] = "Head",
		["rbxassetid://4049240078"] = "Torso",
		["rbxassetid://4049240323"] = "Right Leg",
		["rbxassetid://4049240209"] = "Left Leg",
	};
	
	local get_bodypart = function(bodypart, size, mesh)
		local bodypart_name = bodypart.Name;
		local bodypart_size_name = (function()
			for name, s in sizes do
				if (s == size) then
					return name;
				end
			end
		end)
		
		return (sizes[bodypart_name] and bodypart_name) or (bodypart_size_name) or (mesh_ids[mesh])
	end
	
	chams.connection = nil;
	chams.created = {};

	-- Settings
	chams.enabled = true;
	chams.fetch_sizes = true; -- R6 ONLY
	chams.occluded_color = Color3.fromRGB(58, 61, 255);
	chams.visible_color = Color3.fromRGB(255, 255, 255);
	chams.parent = chams_parent;

	-- Functions
	chams.update = function(cham_object, character)
		local chams_enabled = chams.enabled;
		local occluded_color, visible_color = chams.occluded_color, chams.visible_color;

		for body_part, cham in cham_object do
			local occluded, visible = cham.occluded, cham.visible;

			if (not chams.enabled) or (not body_part or body_part.Parent == nil) or (occluded.Parent == nil) or (visible.Parent == nil) then
				chams.remove(cham, body_part, character);
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
		else
			return;
		end

		for _, bodypart in character.GetChildren(character) do
			if (bodypart.IsA(bodypart, "BasePart")) then
				local bodypart_name = bodypart.Name;

				if (bodypart_name ~= "HumanoidRootPart") then
					local mesh_part = bodypart.FindFirstChildOfClass(bodypart, "SpecialMesh");
					local mesh_id = (mesh_part and mesh_part.MeshId) or "";
					local fetched_bodypart = get_bodypart(bodypart, Vector3.zero, mesh_id);
					
					if (not chams.created[character][bodypart]) then
						chams.created[character][bodypart] = {};
					end

					local cached_bodyparts = chams.created[character][bodypart];
					local occluded = Instance.new("BoxHandleAdornment", chams.parent);
					local visible = Instance.new("BoxHandleAdornment", occluded);
					
					local fetch_sizes = chams.fetch_sizes;
					local fetch_size = fetch_sizes and sizes[fetched_bodypart];
					local bodypart_size = bodypart.Size;

					occluded.Adornee = bodypart;
					occluded.AlwaysOnTop = true;
					occluded.Transparency = 0.8;
					occluded.Color3 = chams.occluded_color;
					occluded.ZIndex = 1;
					occluded.Size = fetch_size or bodypart_size;

					visible.Adornee = bodypart;
					visible.Transparency = 0.5;
					visible.Color3 = chams.visible_color;
					visible.ZIndex = 1;
					visible.Parent = occluded;
					visible.Size = fetch_size or bodypart_size;

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


	chams.create(workspace.Phantoms);

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
