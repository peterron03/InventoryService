# InventoryService
A server-sided data system for Roblox inventories.

## What exactly is InventoryService?
To put it simply, InventoryService is a server-sided table of data that you can add to, remove from, or get from. It simplifies your typical Roblox inventories and turns them into a service with functions and events, as well as saves your data using Roblox's DataStoreService. InventoryService is by no means a top-tier must-have, but it's something I made for myself and decided to share with the world for anyone that might find it interesting or useful.

## Examples
The following creates a Swords inventory for the provided player upon joining the game, with the starter item being the Red Blade. The Red Blade would automatically be equipped in the inventory.
```lua
-- Get the InventoryService:
local InventoryService = require(somewhere.InventoryService)

-- Create an Inventory for a player upon joining:
game.Players.PlayerAdded:Connect(function(player)
  InventoryService:CreateInventory(player, "Swords", "Red Blade")
end
```
Now, I understand what some of you might be thinking if you know anything about InventoryService, and you're right. Using the `:CreateInventory` function isn't necessary, as making changes to inventories automatically creates one if it doesn't already exist. However, it's optional to use for better organization and overall ease if you'd like.

Either way, with the inventory created, making changes to it is super easy. Below is an example of adding a new sword to the inventory after a player tries to buy it, using a RemoteEvent and a Currency leaderstat.
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
-- In a LocalScript:
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
