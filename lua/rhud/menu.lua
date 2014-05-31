local credits = [[RHUD + RIM was entirely coded by rejax, with love.
steamcommunity.com/rejax_
github.com/rejax
uppercutservers.com
This HUD was made by: %s]]

local function PaintDermaMenu( menu, bg, highlight, sub )
	menu.Paint = function( m, w, h ) -- it's invalidated each time
		draw.RoundedBox( 0, 0, 0, w, h, bg )
	end
	for n, p in pairs( menu:GetCanvas():GetChildren() ) do
		p.OnCursorEntered = function( d ) 
			d.In = true
		end
		p.OnCursorExited = function( d ) d.In = false end
		p.Paint = function( op, w, h )
			if op.In then
				draw.RoundedBox( 0, 2, 2, w-4, h-4, highlight )
			else
				draw.RoundedBox( 0, 0, 0, w, h, sub )
			end
		end
	end
end

local function PaintDropDown( drop, main_col, drop_col, drop_sub, drop_highlight ) -- there's a much cleaner way involving vgui.GetControlTable(), but it breaks the dropdown triangle :(
	drop.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, main_col )
	end
	
	drop.OldOpenMenu = drop.OpenMenu
	drop.OpenMenu = function( s )
		s:OldOpenMenu()
		if not ValidPanel( s.Menu ) then return end
		PaintDermaMenu( s.Menu, drop_col, drop_sub, drop_highlight )
	end
end

function RHUD:OpenChoiceMenu()
	local base = vgui.Create( "DFrame" )
		base:SetSize( 300, 80 )
		base:Center()
		base:SetTitle( "Hud Selection" )
		base:ShowCloseButton( false )
		base:MakePopup()
		base.Paint = function(_,w,h) draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50 ) ) end
	
	local close = vgui.Create( "DButton", base )
		close:SetPos( base:GetWide() - 50, 0 )
		close:SetSize( 50, 25 )
		close:SetText( "Close" )
		close:SetName( "rhud_close" )
		close:SetTextColor( color_white )
		close.DoClick = function() 
			if base.Options then base.Options:SlideClosed( function() base:SetVisible( false ) end ) return end
			base:SetVisible( false )
		end
		close.Paint = function(_,w,h) draw.RoundedBox( 0, 0, 0, w, h, Color( 120, 40, 50 ) ) end
	
	local label = vgui.Create( "DLabel", base )
		label:Dock( TOP )
		label.OnChangeHud = function(s)
			local hud = self:GetHud( true )
			if hud.Name == "No Custom Hud" then s:SetText( "You do not have a custom hud active." ) return end
			s:SetText( "Current hud is " .. hud.Name )
		end
		label:OnChangeHud()
		
	local choice = vgui.Create( "DComboBox", base )
		choice:Dock( BOTTOM )
		choice.OnSelect = function( s, ind )
			self:SelectHud( s.Data[ind] )
			label:OnChangeHud()
		end
		choice.Construct = function( s, first )
			s:Clear()
			for name, tab in pairs( self.Huds ) do
				s:AddChoice( tab.Name, name )
			end
			s:SetValue( "Choose a hud!" )
		end
		choice:Construct()
		base.Choice = choice
	PaintDropDown( choice, Color( 220, 220, 220 ), Color( 120, 120, 120 ), Color( 150, 150, 150 ), Color( 180, 180, 180 ) )
		
	local options = vgui.Create( "DImageButton", base )
		options:SetPos( base:GetWide() - close:GetWide() - 21, 4.5 )
		options:SetSize( 16, 16 )
		options:SetImage( "icon16/wrench.png" )
		options.DoClick = function() base.Options = self:Options( base ) end
		options.Paint = function( s, w, h )
			surface.DisableClipping( true )
				draw.RoundedBox( 0, -4, -4, w + 9, h + 9, Color( 100, 100, 100, 150 ) )
			surface.DisableClipping( false )
		end
		
	if RIM then
		local rim = vgui.Create( "DImageButton", base )
			rim:SetPos( base:GetWide() - close:GetWide() - 46, 4.5 )
			rim:SetSize( 16, 16 )
			rim:SetImage( "icon16/script_edit.png" )
			rim.DoClick = function() RIM.Editor:Open() close:DoClick() end
			rim.Paint = function( s, w, h )
				surface.DisableClipping( true )
					draw.RoundedBox( 0, -4, -4, w + 9, h + 9, Color( 100, 100, 100, 150 ) )
				surface.DisableClipping( false )
			end
	end
	
	self.MenuFrame = base
end

local vals = { ["boolean"] = function( b ) return b and "Enabled" or "Disabled" end }
local function Typeify( val )
	local v = vals[type(val)]
	local t = { status = false, kind = type(val), value = val }
	if v then t.status = v( val ) end
	return t
end

local function GetIcon( bool )
	if bool then return "icon16/tick.png" end
	return "icon16/cross.png"
end

function RHUD:Options( p )
	local p_posx, p_posy = p:GetPos()
	local base = vgui.Create( "DFrame" )
		base:CopyPos( p )
		base:CopyHeight( p )
		base:SetWide( p:GetWide()/2 )
		base:SetTitle( "Options" )
		base:ShowCloseButton( false )
		base.Paint = function(_,w,h) draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50 ) ) end
		base:MoveTo( p_posx + 10 + base:GetWide() * 2, p_posy, .5, 0, .01, function() base:MakePopup() end )
		base:SizeTo( base:GetWide()*2, base:GetTall(), .5, 0, .2, function() 
			--base:SizeTo( base:GetWide(), base:GetTall() * 4, .5, 0, .2, function() end )
		end )
		base.Think = function( s ) 
			if not p:IsVisible() then s:Remove() end 
			local posx, posy = p:GetPos()
			if p_posx ~= posx or p_posy ~= posy then
				p_posx, p_posy = posx, posy
				s:MoveTo( p_posx + base:GetWide() + 10, p_posy, 1, 0, .01, function() end )
			end
		end
		base.SlideClosed = function( s, call )
			p:MakePopup()
			local function slidein()
				s:MoveTo( p_posx, p_posy, .4, 0, .2, function()
					p.Options = nil
					s:Close() 
					if call then call() end
				end )
			end
			
			if s.SlideOpen then
				s:SizeTo( p:GetWide(), p:GetTall(), .2, 0, .1, slidein )
			else
				slidein()
			end
		end
	
	local close = vgui.Create( "DButton", base )
		close:SetPos( p:GetWide() - 50, 0 )
		close:SetSize( 50, 25 )
		close:SetText( "Close" )
		close:SetTextColor( color_white )
		close.DoClick = function()
			base:SlideClosed()
		end
		close.Paint = function(_,w,h) draw.RoundedBox( 0, 0, 0, w, h, Color( 120, 40, 50 ) ) end
		
	local about = vgui.Create( "DImageButton", base )
		about:SetPos( p:GetWide() - close:GetWide() - 20, 4.5 )
		about:SetSize( 16, 16 )
		about:SetImage( "icon16/information.png" )
		about.DoClick = function() 
		local author = "Unknown"
		local hud = self:GetHud( true )
		if hud.Author then author = hud.Author end
			Derma_Message( Format( credits, author ), 
			"RHUD Information", "ok :)" ) 
		end
		about.Paint = function( s, w, h )
			surface.DisableClipping( true )
				draw.RoundedBox( 0, -4, -4, w + 9, h + 9, Color( 100, 100, 100, 150 ) )
			surface.DisableClipping( false )
		end
	
	local auth = vgui.Create( "DLabel", base )
		auth:Dock( BOTTOM )
		auth:SetText( "" )
		auth:SetTextColor( color_white )
		auth:Hide()
		auth.SetHud = function( s, name )
			local hud = RHUD:GetHudNamed( name:lower() )
			if hud and hud.Author then
				s:Show()
				s:SetText( hud.Name .. " was written by " .. hud.Author )
			else
				s:Hide()
				base.HudList:SetTall( base.HudList:GetTall() - 15 )
			end
		end
		
	local choice = vgui.Create( "DComboBox", base )
		choice:Dock( TOP )
		choice.OnSelect = function( s, ind )
			base.HudList:LayoutHud( s.Data[ind] )
			if not base.SlideOpen then
				base:SizeTo( base:GetWide(), base:GetTall() * 4, .5, 0, .2, function() end )
				base.SlideOpen = true
			end
			auth:SetHud( s.Data[ind] )
		end
		choice.Construct = function( s, first )
			s:Clear()
			for name, tab in pairs( self.Huds ) do
				if name == "none" then continue end
				local hud = self:GetHudNamed( name )
				if table.Count( hud.Config ) > 0 then
					s:AddChoice( tab.Name .. " (".. table.Count( hud.Config ) .. " options)", name )
				end
			end
			s:SetValue( "Choose a hud to view options!" )
		end
		choice:Construct()
		PaintDropDown( choice, Color( 220, 220, 220 ), Color( 120, 120, 120 ), Color( 150, 150, 150 ), Color( 180, 180, 180 ) )
	
	local hudlist = vgui.Create( "DListView", base )
		hudlist:Dock( FILL )
		hudlist:DockMargin( 0, 5, 0, 0 )
		hudlist:AddColumn( "Name" )
		hudlist:AddColumn( "Value" )
		hudlist.Configs = {}
	base.HudList = hudlist
	
	for id, column in ipairs( hudlist.Columns ) do
		column.DraggerBar:Hide()
		column.Header.DoClick = function() end
		column.Header:SetTextColor( Color( 100, 100, 100 ) )
		local mv = id == 1 and 1 or 0 -- align the columns
		column.Header.Paint = function( self, w, h )
			local wv = hudlist.VBar.Enabled and 0 or 1
			draw.RoundedBox( 0, mv, 0, w - wv, h, Color( 210, 210, 210 ) )
		end
	end
	
	
	local bar = hudlist.VBar
	local function paint( w, h, color ) draw.RoundedBox( 0, 0, 0, w, h, color ) end
	local bgcol = Color( 120, 120, 120 )
	bar.Paint = function( s, w, h ) paint( w, h, Color(80, 80, 80) ) end
	bar.btnUp.Paint = function( self, w, h ) paint( w, h, bgcol ) end
	bar.btnDown.Paint = function( self, w, h ) paint( w, h-1, bgcol ) end
	bar.btnGrip.Paint = function( self, w, h ) paint( w, h, bgcol ) end
	
	hudlist.LayoutHud = function( s, name )
		local hud = self:GetHudNamed( name )
		s:Clear()
		if not s.Configs[name] then
			s.Configs[name] = {}
		end
		for k, v in pairs( hud.Config ) do
			local typeify = { Typeify( v.enabled ), k }
			if not typeify[1].status then continue end
			local line = hudlist:AddLine( k, typeify[1].status )
			s.Configs[name][line] = typeify
		end
		
		for k, line in pairs( s.Lines ) do
			local even = ( k % 2 ) == 1
			
			line.OnCursorEntered = function(s) s.In = true end
			line.OnCursorExited = function(s) s.In = false end
			
			line.Paint = function( s, w, h )
				if s:IsLineSelected() then
					draw.RoundedBox( 0, 0, 0, w, h, Color( 60, 60, 60, 200 ) )
					return
				end
				if s.In then
					draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 150 ) )
				end
				if even then
					draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 75 ) )
				else
					draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 50 ) )
				end
			end
		end
	end
	
	hudlist.OnRowRightClick = function( s, _, row )
		for hud, t in pairs( s.Configs ) do
			for pnl, typeify in pairs( t ) do
				if pnl == row then s:Execute( hud, typeify ) end
			end
		end
	end
	hudlist.OnClickLine = function( s, line ) s:OnRowRightClick( nil, line ) end
	
	hudlist.Execute = function( s, hud, t )
		local menu = DermaMenu()
		
		if t[1].kind == "boolean" then
			menu:AddOption( t[1].value and "Disable this" or "Enable this", function()
				self:ChangeConfigValue( hud, t[2], not t[1].value )
				s:LayoutHud( hud )
			end ):SetIcon( GetIcon( not t[1].value ) )
		elseif t[1].kind == "table" and t[1].kind.r then
			-- is color, do shit
		end
		
		local info = menu:AddOption( self:GetHudNamed( hud ).Config[t[2]].info ) -- ew, make this better pls
		info:SetIcon( "icon16/information.png" )
		info.OnMousePressed = function() end
		info.OnCursorEntered = function() end
		
		PaintDermaMenu( menu, Color( 200, 200, 200 ), Color( 120, 120, 120 ), Color( 190, 190, 190 ) )
		menu:Open()
	end
	
	return base
end

concommand.Add( "cls", function() RHUD.Frame:Remove() RHUD.Frame = nil end )
concommand.Add( "rhud_choose", function() RHUD:OpenChoiceMenu() end )
concommand.Add( "choosehud", function() RHUD:OpenChoiceMenu() end )

hook.Add( "OnPlayerChat", "RHUD_Command", function( ply, text )
	if text:lower():find( "^[/!]hud[s]?$" ) then -- because people like to use / and ! for chat commands
		if ply == LocalPlayer() then RHUD:OpenChoiceMenu() end
		return true
	end
end )