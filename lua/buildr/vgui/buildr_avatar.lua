local AVATAR = {}

function AVATAR:Init()
	self:SetSize( 64, 64 )
	
	self:CreateAvatar( 64 )
end

function AVATAR:CreateAvatar( size )
	self.avatar = vgui.Create( "AvatarImage", self )
	self.avatar:SetPlayer( LocalPlayer(), size )
	self.avatar:SetSize( size, size )
	self.avatar:SetPaintedManually( true )
	
	self.avatar.dummy = vgui.Create( "EditablePanel", self.avatar )
	self.avatar.dummy:SetSize( size, size )
	self.avatar.dummy.OnMousePressed = function(_,m) self:OnMousePressed( m ) end
	self.avatar.dummy.OnMouseReleased = function(_,m) self:OnMouseReleased( m ) end
end

function AVATAR:GetCode()
	return { "RHUD:PaintAvatar()" }
end

function AVATAR:GetInitCode()
	return { "self.Avatar:SetPos( $x$, $y$ )" }
end

function AVATAR:AddRightClickOptions( menu )
	--[[local size = menu:AddSubMenu( "Change Avatar Size To:" )
	
	for _, sz in pairs( { 16, 32, 64, 84, 128, 184 } ) do
		size:AddOption( sz, function() self:SetAvatarSize( sz ) end )
	end]]
end

function AVATAR:SetAvatarSize( size )
	self:SetSize( size, size )
	
	self.avatar.dummy:Remove()
	self.avatar:Remove()
	self:CreateAvatar( size )
end

function AVATAR:PaintPreview( w, h, pnl )
	local av = self:GenerateAvatar( pnl )

	av:SetPaintedManually( false )
	av:PaintManual()
	av:SetPaintedManually( true )
end

function AVATAR:GenerateAvatar( pnl )
	if self.avatarpnl == pnl and self.gen_avatar then return self.gen_avatar end

	self.avatarpnl = pnl
	self.gen_avatar = vgui.Create( "AvatarImage", pnl )
	self.gen_avatar:SetPlayer( LocalPlayer(), 64 )
	self.gen_avatar:SetSize( 64, 64 )
	self.gen_avatar:SetPaintedManually( true )
	return self.gen_avatar
end

function AVATAR:Paint( w, h )
	if not self.avatar then return end
	self.avatar:SetPaintedManually( false )
	self.avatar:PaintManual()
	self.avatar:SetPaintedManually( true )
end

buildr.register( "Avatar", {
	description = "Avatar. Displays steam avatars",
	panel = AVATAR,
} )