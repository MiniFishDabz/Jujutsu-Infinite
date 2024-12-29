local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/MiniFishDabz/Jujutsu-Infinite/refs/heads/main/lib.lua", true))()

local Options = Fluent.Options
Fluent.Version = 0.1

local dropfolder = workspace.Objects.Drops
local player = game:GetService("Players").LocalPlayer
local char = player.Character
local Api = "https://games.roblox.com/v1/games/"
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

Fluent:Notify({
    Title = "|| JuJutsu Infinite ||",
    Content = "Subscribe to MiniFishDabz",
    SubContent = "https://www.youtube.com/@MiniFishDabz", -- Optional
    Duration = 5, -- Set to nil to make the notification not disappear
    -- setclipboard("https://www.youtube.com/@MiniFishDabz")
})

local Window = Fluent:CreateWindow({
    Title = "JuJutsu Infinite Item Finder " .. Fluent.Version,
    SubTitle = "by MiniFishDabz",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightAlt -- Used when theres no MinimizeKeybind
})

Window:Dialog({
    Title = "Key System",
    Content = "You have to subscribe for the key (no cap 🗿)",
    Buttons = {
        { 
            Title = "I Subscribed 😎",
            Callback = function()
                print("Yippee")
            end 
        }, {
            Title = "I Subscribed 😎",
            Callback = function()
                print("Yippee")
            end 
        }
    }
})

local Tabs = {
    Credits = Window:AddTab({ Title = "|| Credits ||", Icon = "info" }),
    Main = Window:AddTab({ Title = "|| Item Finder ||", Icon = "map-pin" })
}

Window:SelectTab(1)

local SectionC = Tabs.Credits:AddSection()
SectionC:AddParagraph({
    Title = "Last Update: 29/12/2024"
})
SectionC:AddParagraph({
    Title = [[

Credit: MiniFishDabz
Youtube: https://www.youtube.com/@MiniFishDabz    
    ]]
})
SectionC:AddParagraph({
    Title = "Supported Devices:",
    Content = [[

    - PC

    - Mobile/Emulator

    - Not a potato
    ]]
})

local SectionM = Tabs.Main


local objectMap = {}

-- Refresh function to update the values and object map
local function refresh()
    local values = {}
    local counter = 1
    for _, drop in pairs(dropfolder:GetChildren()) do
        local value = counter .. " " .. drop.Name
        table.insert(values, value)
        objectMap[value] = drop -- Map the dropdown value to the object
        counter = counter + 1
    end
    
    -- Sort the values numerically (based on the number in front of the item name)
    table.sort(values, function(a, b)
        local numA = tonumber(a:match("^(%d+)")) -- Extract the number from the string
        local numB = tonumber(b:match("^(%d+)"))
        return numA < numB -- Compare the numbers for sorting
    end)
    
    return values
end

local function fireproxprompt()
    for _, v in pairs(dropfolder:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
        end
    end
end

local DropM = SectionM:AddDropdown("Dropdown", {
    Title = "Spawned Items",
    Description = "Items currently in your server",
    Values = refresh(),
    Multi = false,
})

Tabs.Main:AddButton({
    Title = "Collect Item",
    Description = "Collects the selected item!",
    Callback = function()
        local selectedValue = DropM.Value
        local selectedObject = objectMap[selectedValue]
        if selectedObject and selectedObject.PrimaryPart then
            char.HumanoidRootPart.CFrame = selectedObject.PrimaryPart.CFrame
            task.wait(0.5)
            fireproxprompt()
        else
            Fluent:Notify({
                Title = "|| Teleport Failed ||",
                Content = "This item does not exist try refreshing!",
                Duration = 2
            })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Collect All Items",
    Description = "Collects all spawned items!",
    Callback = function()
        Fluent:Notify({
            Title = "|| Collect All Started ||",
            Content = "Collecting all spawned items!",
            Duration = 3
        })
        for _, alldrops in pairs(dropfolder:GetChildren()) do
            char.HumanoidRootPart.CFrame = alldrops.PrimaryPart.CFrame
            task.wait(0.5)
            fireproxprompt()
            task.wait(0.1)
        end
    end
})

Tabs.Main:AddButton({
    Title = "Refresh Item List",
    Description = "Manually refreshes the item list!",
    Callback = function()
        DropM.Values = refresh()
        DropM:SetValue(refresh()[1])
        Fluent:Notify({
            Title = "Item List Refreshed!",
            Content = "The spawned item list has been refreshed!",
            Duration = 3
        })
    end
})

Tabs.Main:AddButton({
    Title = "Server Hop",
    Description = "Switches servers for you!",
    Callback = function()
local _place,_id = game.PlaceId, game.JobId
-- Asc for lowest player count, Desc for highest player count
local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=10"
local function ListServers(cursor)
   local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
   return HttpService:JSONDecode(Raw)
end

local time_to_wait = 1 --seconds

-- choose a random server and join every 2 minutes
while wait(time_to_wait) do
   --freeze player before teleporting to prevent synapse crash?
   player.Character.HumanoidRootPart.Anchored = true
   local Servers = ListServers()
   local Server = Servers.data[math.random(1,#Servers.data)]
   TeleportService:TeleportToPlaceInstance(_place, Server.id, player)
end
    end
})

local lastValues = {}

local function checkForMissingItems()
    while task.wait(0.5) do
        local currentValues = {}
        local currentMap = {}

        -- Iterate over the objectMap and check if each object still exists
        for value, drop in pairs(objectMap) do
            if drop and drop.Parent then
                -- Object still exists, keep it in the list
                table.insert(currentValues, value)
                currentMap[value] = drop
            end
        end

        -- Sort the current values numerically
        table.sort(currentValues, function(a, b)
            local numA = tonumber(a:match("^(%d+)")) -- Extract the number from the string
            local numB = tonumber(b:match("^(%d+)"))
            return numA < numB -- Compare the numbers for sorting
        end)

        -- Check if the current list of values is different from the last known list
        if #currentValues ~= #lastValues then
            -- Only refresh if the list has changed
            if #currentValues > 0 then
                -- Update dropdown values only if items are still in the list
                DropM.Values = currentValues
                DropM:SetValue(currentValues[1])  -- Optionally set the first item as default

                -- Update the object map to reflect the new items
                objectMap = currentMap

                -- Notify the user about the refresh
                Fluent:Notify({
                    Title = "|| Auto Refresh ||",
                    Content = "The item list has been refreshed because an item was missing!",
                    Duration = 1.5
                })

                -- Update the last known values
                lastValues = currentValues
            end
        end
    end
end

checkForMissingItems()