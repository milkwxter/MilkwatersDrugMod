AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Weed Brick"
ENT.Author = "Milkwater"
ENT.Category = "DarkRP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true

if SERVER then
	-- called when you spawn it
	function ENT:Initialize()
		-- initialize model
		self:SetModel("models/weed/weed_big_bag01/weed_big_bag01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end

	-- called when someone presses "E" on it
	function ENT:Use(activator)
		if activator:IsPlayer() then
			-- max out health
			activator:SetHealth(activator:GetMaxHealth())
			
			-- effects
			local effectData = EffectData()
			effectData:SetOrigin(self:GetPos())
			util.Effect("weed_boom", effectData)
			self:EmitSound("weed_rustle.wav")
			
			-- remove self
			self:Remove()
		end
	end
end