--local occluded_color = Color3.fromRGB(255, 64, 67);
--local visible_color = Color3.fromRGB(29, 255, 123);

local occluded_color = Color3.fromRGB(58, 61, 255);
local visible_color = Color3.fromRGB(255, 255, 255);

local chams = {}; do
	chams.created = {};
	
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
					local identify_head = bodypart.Name == "Head"; -- change if required for your game
					
					if (not chams.created[character][bodypart]) then
						chams.created[character][bodypart] = {};
					end

					local cached_bodyparts = chams.created[character][bodypart];
					local occluded = Instance.new("BoxHandleAdornment", bodypart);
					local visible = Instance.new("BoxHandleAdornment", occluded);

					occluded.Adornee = bodypart;
					occluded.AlwaysOnTop = true;
					occluded.Transparency = 0.8;
					occluded.Color3 = occluded_color;
					occluded.ZIndex = 1;
					occluded.Size = bodypart.Size;

					visible.Adornee = bodypart;
					visible.Transparency = 0.5;
					visible.Color3 = visible_color;
					visible.ZIndex = 1;
					visible.Size = (identify_head and bodypart.Size * 1.05) or bodypart.Size * 1.03;
					visible.Parent = occluded;

					cached_bodyparts.visible = visible;
					cached_bodyparts.occluded = occluded;
					cached_bodyparts.transparency = bodypart.Transparency;
					
					bodypart.Transparency = 1;
				end
			end
		end
	end
	
	chams.remove = function(character)
		local created = chams.created[character];
		
		if (not created) then
			return;
		end
		
		for bodypart, data in created do
			local occluded, visible = data.occluded, data.visible;
			
			if (occluded and visible) then
				data.occluded:Destroy();
				data.visible:Destroy();
			end
			
			bodypart.Transparency = data.transparency;
			created[bodypart] = nil;
		end
	end
end

return chams;
