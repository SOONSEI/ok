
local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local EggAmount = 1
local DigDownKey = "U"
local OpenPets = "P"

function breakblock(place, pos)
	local success, response = pcall(function()
		local args = {
   [1] = place.Name,
   [2] = pos,
   [3] = pos
   }

   game:GetService("ReplicatedStorage").Events.TerrainToolRequest:InvokeServer(unpack(args))
	end)
end

function getPartBelow()
   local Character = game.Players.LocalPlayer.Character
   local Foot = Character.RightFoot
   local RayOrigin = Foot.Position
   local RayDirection = Vector3.new(0, -3, 0)
 
   local Params = RaycastParams.new()
   Params.FilterType = Enum.RaycastFilterType.Blacklist
   Params.FilterDescendantsInstances = {Character}

   local Result = workspace:Raycast(RayOrigin, RayDirection, Params)

   if Result then
       local RayInstance = Result.Instance
       return RayInstance
   end

   return nil
end

local Window = Library:CreateWindow({
    Title = 'Treasure Hunt Islands - SOONSEI',
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'), 
    ['Key Binds'] = Window:AddTab('Key Binds'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Main')
local KeyBindsLeftBox = Tabs['Key Binds']:AddLeftGroupbox('Main')


LeftGroupBox:AddToggle('AutoFarmToggle', {
    Text = 'Dig Down',
    Default = false, -- Default value (true / false)
    Tooltip = 'Dig Down', -- Information shown when you hover over the toggle
})
game.Players.LocalPlayer.CharacterAdded:Connect(function(person)
    if Toggles.AutoFarmToggle.Value == true then
        task.wait(1)
        Toggles.AutoFarmToggle:SetValue(true)
    end
end)
LeftGroupBox:AddDivider()

Toggles.AutoFarmToggle:OnChanged(function()
    getgenv().auto = Toggles.AutoFarmToggle.Value
    
    while auto and task.wait() do
        local closest = getPartBelow()
    	
    	if closest ~= nil then
			local Pos = closest.Position
			local Place = closest.Parent.Parent
			task.spawn(
				function()
					breakblock(Place,Pos)
				end
			)
		end
    end
end)

LeftGroupBox:AddDropdown('Eggs', {
    Values = {'Basic Egg', 'Uncommon Egg', 'Stranded Egg', 'Spikey Egg', 'Jungle Egg', 'Exotic Egg', 'Snowy Egg', 'Glacier Egg'},
    Default = 1, -- number index of the value / string
    Multi = false, -- true / false, allows multiple choices to be selected

    Text = 'Eggs',
    Tooltip = 'This the gun you own to kill all', -- Information shown when you hover over the textbox
})

LeftGroupBox:AddToggle('OpenEgg', {
    Text = 'Open Eggs',
    Default = false, -- Default value (true / false)
    Tooltip = 'Opens Eggs', -- Information shown when you hover over the toggle
})

LeftGroupBox:AddToggle('ThreeEggToggle', {
    Text = '3 Eggs',
    Default = false, -- Default value (true / false)
    Tooltip = 'Toggle Open 3 Eggs', -- Information shown when you hover over the toggle
})

Toggles.OpenEgg:OnChanged(function()
	while Toggles.OpenEgg.Value == true and Options.Eggs.Value do
		local args = {
		[1] = Options.Eggs.Value,
		[2] = EggAmount
		}
		game:GetService("ReplicatedStorage").Events.RequestEggHatch:FireServer(unpack(args))
		task.wait()
	end
end)

Toggles.ThreeEggToggle:OnChanged(function()
	if Toggles.ThreeEggToggle.Value == false then
		EggAmount = 1
	end
	if Toggles.ThreeEggToggle.Value == true then
		EggAmount = 3
	end
end)
LeftGroupBox:AddDivider()


game:GetService("UserInputService").InputBegan:Connect(function(keyobject, stuffhappening)
    if keyobject.KeyCode == Enum.KeyCode[DigDownKey] and not stuffhappening then
    	local val = not Toggles.AutoFarmToggle.Value
    	Toggles.AutoFarmToggle:SetValue(val)
	end
end)

game:GetService("UserInputService").InputBegan:Connect(function(keyobject, stuffhappening)
    if keyobject.KeyCode == Enum.KeyCode[OpenPets] and not stuffhappening then
    	local val = not Toggles.OpenEgg.Value
    	Toggles.OpenEgg:SetValue(val)
	end
end)



local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 
SaveManager:BuildConfigSection(Tabs['UI Settings']) 
ThemeManager:ApplyToTab(Tabs['UI Settings'])
