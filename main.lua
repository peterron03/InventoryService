--[[
@TheAlmightyForehead
March 18th, 2024
This service handles inventories
]]

-- SERVICES --
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- KNIT --
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(Knit.Util.Signal)

-- DATASTORES --
local DataStore = DataStoreService:GetDataStore("INVENTORY_SERVICE_DATA")

local Inventory = Knit.CreateService {
	Name = "InventoryService",
	
	ItemAdded = Signal.new(),
	ItemRemoved = Signal.new(),
	ItemEquipped = Signal.new(),
	ItemUnequipped = Signal.new(),
	InventoryChanged = Signal.new(),
	DataChanged = Signal.new(),
	DataLoaded = Signal.new(),
	
	PlayerData = {},
	
	Client = {
		ItemAdded = Knit.CreateSignal(),
		ItemRemoved = Knit.CreateSignal(),
		ItemEquipped = Knit.CreateSignal(),
		ItemUnequipped = Knit.CreateSignal(),
		InventoryChanged = Knit.CreateSignal(),
		DataChanged = Knit.CreateSignal(),
		DataLoaded = Knit.CreateSignal()
	}
}

function Inventory:CreateInventory(player : Player, inventoryName : string, starterItem : string?)
	if not self.PlayerData[player].Inventories[inventoryName] then
		self.PlayerData[player].Inventories[inventoryName] = {}

		if starterItem then
			table.insert(self.PlayerData[player].Inventories[inventoryName], starterItem)
			self.PlayerData[player].Equipped[inventoryName] = starterItem

			self.ItemAdded:Fire(player, inventoryName, starterItem)
			self.InventoryChanged:Fire(player, inventoryName, self.PlayerData[player].Inventories[inventoryName])
		end

		self.DataChanged:Fire(player, self.PlayerData[player])
		self.Client.DataChanged:Fire(player, self.PlayerData[player])
	end

	return Inventory.PlayerData[player]
end

function Inventory:DestroyInventory(player : Player, inventoryName : string)
	local equippedItem = self:GetEquipped(player, inventoryName)
	
	if equippedItem then
		self:UnequipItem(player, inventoryName, equippedItem)
	end
	
	self.PlayerData[player].Inventories[inventoryName] = nil
	
	self.DataChanged:Fire(player, self.PlayerData[player])
	self.Client.DataChanged:Fire(player, self.PlayerData[player])

	return self.PlayerData[player]
end

function Inventory:IsItemEquipped(player : Player, inventoryName : string, itemName : string) : boolean
	return self.PlayerData[player].Equipped[inventoryName] == itemName
end

function Inventory:GetData(player : Player)
	return self.PlayerData[player] or nil
end

function Inventory:GetInventory(player : Player, inventoryName : string)
	return (self.PlayerData[player] and self.PlayerData[player].Inventories[inventoryName]) or nil
end

function Inventory:FindItem(player : Player, inventoryName : string, itemName : string) : number?
	if self.PlayerData[player].Inventories[inventoryName] then
		return table.find(self.PlayerData[player].Inventories[inventoryName], itemName)
	else
		return nil
	end
end

function Inventory:AddItem(player : Player, inventoryName : string, itemName : string)
	if not self.PlayerData[player].Inventories[inventoryName] then
		self.PlayerData[player].Inventories[inventoryName] = {}
	end

	table.insert(self.PlayerData[player].Inventories[inventoryName], itemName)

	self.ItemAdded:Fire(player, inventoryName, itemName)
	self.InventoryChanged:Fire(player, inventoryName, self.PlayerData[player].Inventories[inventoryName])
	self.DataChanged:Fire(player, self.PlayerData[player])
	self.Client.ItemAdded:Fire(player, inventoryName, itemName)
	self.Client.InventoryChanged:Fire(player, inventoryName, self.PlayerData[player].Inventories[inventoryName])
	self.Client.DataChanged:Fire(player, self.PlayerData[player])

	return self.PlayerData[player]
end

function Inventory:RemoveItem(player : Player, inventoryName : string, itemName : string)
	if self.PlayerData[player].Inventories[inventoryName] then
		local findItem = table.find(self.PlayerData[player].Inventories[inventoryName], itemName)

		if findItem then
			table.remove(self.PlayerData[player].Inventories[inventoryName], findItem)

			self.ItemRemoved:Fire(player, inventoryName, itemName)
			self.InventoryChanged:Fire(player, inventoryName, self.PlayerData[player].Inventories[inventoryName])
			self.DataChanged:Fire(player, self.PlayerData[player])
			self.Client.ItemRemoved:Fire(player, inventoryName, itemName)
			self.Client.InventoryChanged:Fire(player, inventoryName, self.PlayerData[player].Inventories[inventoryName])
			self.Client.DataChanged:Fire(player, self.PlayerData[player])
		end
	end

	return self.PlayerData[player]
end

function Inventory:GetEquipped(player : Player, inventoryName : string) : string
	return (self.PlayerData[player] and self.PlayerData[player].Equipped[inventoryName]) or nil
end

function Inventory:EquipItem(player : Player, inventoryName : string, itemName : string)
	if not self:FindItem(player, inventoryName, itemName) then
		self:AddItem(player, inventoryName, itemName)
	end
	
	self.PlayerData[player].Equipped[inventoryName] = itemName

	self.ItemEquipped:Fire(player, inventoryName, itemName)
	self.DataChanged:Fire(player, self.PlayerData[player])
	self.Client.ItemEquipped:Fire(player, inventoryName, itemName)
	self.Client.DataChanged:Fire(player, self.PlayerData[player])

	return self.PlayerData[player]
end

function Inventory:UnequipItem(player : Player, inventoryName : string, itemName : string)
	if self.PlayerData[player].Equipped[inventoryName] == itemName then
		self.PlayerData[player].Equipped[inventoryName] = nil

		self.ItemUnequipped:Fire(player, inventoryName, itemName)
		self.DataChanged:Fire(player, self.PlayerData[player])
		self.Client.ItemUnequipped:Fire(player, inventoryName, itemName)
		self.Client.DataChanged:Fire(player, self.PlayerData[player])
	end

	return self.PlayerData[player]
end

function Inventory:LoadData(player : Player)
	local data

	local success, err = pcall(function()
		data = DataStore:GetAsync(player.UserId .. "_INVENTORY_DATA")
	end)

	if success then
		self.PlayerData[player] = data or {Equipped = {}, Inventories = {}}
		
		for invName, inv in pairs(self.PlayerData[player].Inventories) do
			self.InventoryChanged:Fire(player, invName, inv)
			self.Client.InventoryChanged:Fire(player, invName, inv)
		end
		
		for invName, equippedItem in pairs(self.PlayerData[player].Equipped) do
			self.ItemEquipped:Fire(player, invName, equippedItem)
			self.Client.ItemEquipped:Fire(player, invName, equippedItem)
		end

		self.DataChanged:Fire(player, self.PlayerData[player])
		self.DataLoaded:Fire(player, self.PlayerData[player])
		self.Client.DataChanged:Fire(player, self.PlayerData[player])
		self.Client.DataLoaded:Fire(player, self.PlayerData[player])

		return self.PlayerData[player]
	else
		warn(err)
		warn("Failed to load INVENTORY data for " .. player.Name .. " (" .. player.UserId .. ").")
		player:Kick("Error while retreiving INVENTORY data, please rejoin.")
	end
end

function Inventory:SaveData(player : Player)
	local success, err = pcall(function()
		DataStore:SetAsync(player.UserId .. "_INVENTORY_DATA", tonumber(self.PlayerData[player]))
	end)

	if not success then
		warn(err)
		warn("Failed to save INVENTORY data for " .. player.Name .. "(" .. player.UserId .. ").")
	else
		return self.PlayerData[player]
	end
end

function Inventory.Client:IsItemEquipped(player : Player, inventoryName : string, itemName : string) : boolean
	return self.Server:IsItemEquipped(player, inventoryName, itemName)
end

function Inventory.Client:GetData(player : Player)
	return self.Server:GetData(player)
end

function Inventory.Client:GetInventory(player : Player, inventoryName : string)
	return self.Server:GetInventory(player, inventoryName)
end

function Inventory.Client:FindItem(player : Player, inventoryName : string, itemName : string) : number
	return self.Server:FindItem(player, inventoryName, itemName)
end

function Inventory.Client:GetEquipped(player : Player, inventoryName : string) : string
	return self.Server:GetEquipped(player, inventoryName)
end

function Inventory:KnitInit()
	Players.PlayerAdded:Connect(function(player)
		self:LoadData(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		self:SaveData(player)
		self.PlayerData[player] = nil
	end)
	
	print(script.Name .. " initialized")
end

function Inventory:KnitStart()
	print(script.Name .. " started")
end

return Inventory
