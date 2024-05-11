# InventoryService
An Inventory system for Roblox, built using the Knit framework.

## What exactly is InventoryService?
To put it simply, InventoryService is a server-sided table of data that you can add to, remove from, or get from. It simplifies your typical Roblox inventories and turns them into a service with functions and events, as well as saves your data using Roblox's DataStoreService. InventoryService is by no means a top-tier must-have, but it's something I made for myself and decided to share with the world for anyone that might find it interesting or useful.

## What is Knit?
As stated in the very short description of InventoryService, Knit is used as a dependency. If you're unfamiliar with Knit, I highly suggest watching [this](https://www.youtube.com/watch?v=0Ty2ojfdOnA) video, which is a tutorial made by [@sleitnick](https://github.com/Sleitnick), the creator of Knit. Though InventoryService can be used without much knowledge of Knit, it's recommended you understand Knit first.

## Examples
The following creates a Swords inventory for the provided player upon joining the game, with the starter item being the Red Blade. The Red Blade would automatically be equipped in the inventory. And of course, InventoryService uses the Knit framework, so we're going to need to add that bit.
```lua
-- Get Knit, the framework used for InventoryService:
local Knit = require(game.ReplicatedStorage.Knit)

-- Load the InventoryService module from some folder, as well as any other modules you have:
Knit.AddServices(game.ServerScriptService.Services)

-- Start Knit:
Knit.Start():andThen(function()
	print("Knit started")
end):catch(warn)

-- Get the InventoryService:
local InventoryService = Knit.GetService("InventoryService")

-- Create an Inventory for a player upon joining:
game.Players.PlayerAdded:Connect(function(player)
  InventoryService:CreateInventory(player, "Swords", "Red Blade")
end
```
Now, I understand what some of you might be thinking if you know anything about InventoryService, and you're right. Using the `:CreateInventory` function isn't necessary, as making changes to inventories automatically creates one if it doesn't already exist. However, it's optional to use for better organization and overall ease if you'd like.

Either way, with the inventory created, making changes to it is super easy. Below is an example of adding a new sword to the inventory after a player tries to buy it, using a RemoteEvent and a Currency leaderstat. (Note: If you'd like a Currency system as well, you can check out my [CurrencyService](https://github.com/peterron03/CurrencyService), which is set up a lot like InventoryService and works well with it.)
```lua
-- RemoteEvent to buy an item:
local RemoteEvent = somewhere.RemoteEvent

-- Adding the item to the inventory if the player has enough Currency to afford it:
RemoteEvent.OnServerEvent:Connect(function(player, inventoryName, itemName)
  if player.leaderstats.Currency.Value >= somewhere[itemName].Price then
    InventoryService:AddItem(player, itemType, itemName)
  end
end
```
Now we have an Awesome Sword in the player's Swords inventory! But, wait, we have to let both the server and client know in case anything needs updated, such as UI, statistics, leaderboards, etc. Luckily, we have events to help us out with that.
```lua
-- In a LocalScript, assuming Knit has been set up on the client, as well:
InventoryService.ItemAdded:Connect(function(inventoryName, itemName)
  -- add item to UI on the client, however you have it set up
end)
```
While above is an example of `.ItemAdded` on the client, it can also be used on the server. The only difference is the first parameter being `player`, which is the player that received the added item, followed by `inventoryName` and `itemName`, of course.

Now that the player has added an Awesome Sword to their inventory, they'd like to equip it. This is done easily, using the following function on the server.
```lua
InventoryService:EquipItem(player, "Swords", "Awesome Sword")
```
And there you go! We've now created a Swords inventory, added an item to the inventory, checked that the item was added on the client, and equipped the item. There's plenty more to InventoryService such as removing items, unequipping items, and using events to update overall inventory data, but this was just a little example of how it's used.

## Documentation
Coming soon... maybe...
