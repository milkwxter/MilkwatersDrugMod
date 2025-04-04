AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.PrintName = "Drug Buyer NPC"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

if SERVER then
	-- add network string for colored messages
	util.AddNetworkString("SimpleDrugBuyer.Notify")
	
	-- list of drugs he buys
	local drugList = {
		{name = "Weed Brick", class = "weed_brick", price = 300},
	}
	
	-- initialize entity
	function ENT:Initialize()
		self:SetModel("models/Humans/Group02/male_07.mdl")
		self:SetHullType(0)
		self:SetHullSizeNormal()
		self:SetNPCState(NPC_STATE_SCRIPT)
		self:SetSolid(SOLID_BBOX)
		self:SetUseType(SIMPLE_USE)
		self:SetMoveType(MOVETYPE_NONE)
	end
	
	-- server side notification, for colored messages
	local function Notify(ply, msg)
		net.Start("SimpleDrugBuyer.Notify")
		net.WriteString(msg)
		net.Send(ply)
	end
	
	-- when someone presses "E" on this entity
	function ENT:AcceptInput(inputName, activator, caller)
		if inputName == "Use" and IsValid(caller) and caller:IsPlayer() then
			self:BuyFromPlayer(caller)
		end
	end
	
	-- this handles buying a players stuff
	function ENT:BuyFromPlayer(ply)
		-- get pocket items as an array
		local pocketItems = ply:getPocketItems()
		local itemsSold = 0
		
		-- iterate through the array
		if #pocketItems > 0 then
			-- for each item in pocket, do this
			for key, value in ipairs(pocketItems) do
				for drugKey, drugValue in ipairs(drugList) do
					if value.class == drugValue.class then
						Notify(ply, "You sold a " .. drugValue.name .. " and got paid $" .. drugValue.price .. "!")
						ply:removePocketItem(key)
						ply:addMoney(drugValue.price)
						itemsSold = itemsSold + 1
					end
				end
			end
			if itemsSold != 0 then
				-- at the end, play a fun sound and throw money
				EmitSound( "garrysmod/save_load1.wav", self:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
				local effectData = EffectData()
				effectData:SetOrigin(self:GetPos())
				util.Effect("money_drop", effectData)
			else
				-- if the player had zero drugs
				Notify(ply, "Your pocket had no drugs! No deal.")
				EmitSound( "vo/npc/male01/excuseme01.wav", self:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
			end
		else
			-- if the player had zero pocket items
			Notify(ply, "Your pocket had no drugs! No deal.")
			EmitSound( "vo/npc/male01/excuseme01.wav", self:GetPos(), 1, CHAN_AUTO, 1, 75, 0, 100 )
		end
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
        local pos = self:GetPos() + Vector(0, 0, 80)
        local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

        cam.Start3D2D(pos, ang, 0.2)
        draw.SimpleText("Drug Buyer NPC", "Trebuchet24", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
		cam.Start3D2D(pos - Vector(0, 0, 5), ang, 0.1)
        draw.SimpleText("Sell drugs here!", "Trebuchet24", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
	
	local function Notify(msg)
		chat.AddText(Color(85, 170, 85), "Drug Buyer NPC | ", Color(255, 255, 255), msg)
	end

	net.Receive("SimpleDrugBuyer.Notify", function()
		Notify(net.ReadString())
	end)
end
