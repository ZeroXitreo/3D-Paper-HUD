/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/
local settings_filename = "hud_settings.txt"
local settings = string.Split(file.Read(settings_filename,"DATA"), ";")
if !file.Exists( settings_filename, "DATA" ) || !settings[3] then
	file.Write(settings_filename, false)
	file.Write(settings_filename, file.Read(settings_filename,"DATA") .. "1;")
	file.Write(settings_filename, file.Read(settings_filename,"DATA") .. "2;")
	file.Write(settings_filename, file.Read(settings_filename,"DATA") .. "100;")
end
local settings = string.Split(file.Read(settings_filename,"DATA"), ";")
local enabled = tonumber(settings[1])
local units = tonumber(settings[2])
local sensitivity = tonumber(settings[3])

function SetSettings(content)
	file.Write(settings_filename, content)
	settings = string.Split(file.Read(settings_filename,"DATA"), ";")
	enabled = tonumber(settings[1])
	units = tonumber(settings[2])
	sensitivity = tonumber(settings[3])
end
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/

local healthNOW = 0
local armorNOW = 0
local health = armorNOW
local armor = armorNOW
local health2 = armorNOW
local armor2 = armorNOW
local healthNowRound = armorNOW
local armorNowRound = armorNOW
local healthNowRound2 = armorNOW
local armorNowRound2 = armorNOW
local maxhealth = armorNOW
local maxarmor = armorNOW
local maxhealth2 = armorNOW
local maxarmor2 = armorNOW
local velEye = Angle()
local velDelay = Angle()
local velMove = Angle()
local WeaponName = ""
local maxClip1 = 0
local maxCap1 = 0
local maxClip2 = 0
local movement = 0
local smoothmovement = 0

local fps = 0
local fpssmooth = 0
local inf = 1 / 0
local nan = 0 / 0

local menu_m = 0
local menu_m_smo = 0
local hp_smo = 0
local hp_m_smo = 0
local ar_smo = 0
local ar_m_smo = 0
/**/
local sin,cos,rad = math.sin,math.cos,math.rad
local function GeneratePoly(x,y,radius,quality)
    local circle = {};
    local tmp = 0;
	local s,c;
    for i=1,quality do
        tmp = rad(i*360)/quality;
		s = sin(tmp);
		c = cos(tmp);
        circle[i] = {x = x + c*radius,y = y + s*radius,u = (c+1)/2,v = (s+1)/2};
    end
    return circle;
end
/**/
surface.CreateFont( "Big", {
	font = "Helvetica",
	size = 21,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
} )
surface.CreateFont( "Small", {
	font = "Helvetica",
	size = 11,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
} )
hook.Add("HUDPaint", "HUD_dosmoothstuff", function()
	velEye = LocalPlayer():EyeAngles()
	if velDelay.y < -90 and velEye.y > 90 then
		velDelay.y = velDelay.y+360
	elseif velDelay.y > 90 and velEye.y < -90 then
		velDelay.y = velDelay.y-360
	end
	local maxMovement = 45
	if velEye.y - velDelay.y > maxMovement*math.cos(math.abs(velEye.p - velDelay.p) / maxMovement) then
		velDelay.y = velEye.y - maxMovement*math.cos(math.abs(velEye.p - velDelay.p) / maxMovement)
	elseif velEye.y - velDelay.y < -maxMovement*math.cos(math.abs(velEye.p - velDelay.p) / maxMovement) then
		velDelay.y = velEye.y + maxMovement*math.cos(math.abs(velEye.p - velDelay.p) / maxMovement)
	end
	if velEye.p - velDelay.p > maxMovement*math.cos(math.abs(velEye.y - velDelay.y) / maxMovement) then
		velDelay.p = velEye.p - maxMovement*math.cos(math.abs(velEye.y - velDelay.y) / maxMovement)
	elseif velEye.p - velDelay.p < -maxMovement*math.cos(math.abs(velEye.y - velDelay.y) / maxMovement) then
		velDelay.p = velEye.p + maxMovement*math.cos(math.abs(velEye.y - velDelay.y) / maxMovement)
	end

	healthNowRound2 = healthNowRound2+(LocalPlayer():Health()-healthNowRound2)/25
	armorNowRound2 = armorNowRound2+(armorNOW-armorNowRound2)/25
	health2 = math.Round(healthNowRound2)
	armor2 = math.Round(armorNowRound2)
	
	healthNowRound = healthNowRound+(LocalPlayer():Health()-healthNowRound)/25
	armorNowRound = armorNowRound+(armorNOW-armorNowRound)/25
	health = math.Round(healthNowRound)
	armor = math.Round(armorNowRound)
	
	
	fpssmooth = fpssmooth + (fps - fpssmooth) / (1 / RealFrameTime())
	
	/*****************************************************************/
	fps = 1 / RealFrameTime()
	if fpssmooth == inf then
		fpssmooth = 1 / RealFrameTime()
	end
	velDelay.p, velDelay.y, velDelay.r = velDelay.p+(velEye.p-velDelay.p)/fps*5, velDelay.y+(velEye.y-velDelay.y)/fps*5, velDelay.r+(velEye.r-velDelay.r)/fps*5
	velMove = (velEye - velDelay)*5*(sensitivity/200)
	velMove.p, velMove.y, velMove.r = math.Round(velMove.p), math.Round(velMove.y), math.Round(velMove.r)
	
	local vel
	if LocalPlayer():GetVehicle():IsVehicle() then
		vel = LocalPlayer():GetVehicle():GetVelocity():Length()
	else
		vel = LocalPlayer():GetVelocity():Length()
	end
	txt =  math.Round(vel)
	armorNOW = LocalPlayer():Armor()
	
	if health2 <= 0 then
		maxhealth2 = 0
	end
	if armor2 <= 0 or health2 <= 0 then
		maxarmor2 = 0
	end
	if health2 > maxhealth2 then
		maxhealth2 = health2
	end
	maxhealth2 = maxhealth2 + (health2 - maxhealth2) / fps
	
	if armor2 > maxarmor2 then
		maxarmor2 = armor2
	end
	
	
	
	/* Is everything smoothed, capped and moved? */
	/* --- Menu */
	if ( Heuheuheu ) then
		Heuheuheu:SetPos( ScrW()/2 - Heuheuheu:GetWide()/2,ScrH() - math.Round(menu_m_smo*Heuheuheu:GetTall()) )
	end
	menu_m_smo = menu_m_smo + (menu_m - menu_m_smo)/fps*10
	
	/* --- Health */
	hp_smo = hp_smo + (LocalPlayer():Health() - hp_smo)/fps*10
	hp_m_smo = hp_m_smo + (hp_smo - hp_m_smo)/fps/2
	if hp_smo > hp_m_smo then
		hp_m_smo = hp_smo
	end
	if hp_m_smo < 100 then
		hp_m_smo = 100
	end
	
	/* --- Armour */
	ar_smo = ar_smo + (LocalPlayer():Armor() - ar_smo)/fps*10
	if ar_smo > ar_m_smo then
		ar_m_smo = ar_smo
	end
	
	
	
	/* Is everything drawn? */
	if LocalPlayer():Health() > 0 && enabled == 1 then
		surface.SetTexture(0)
		if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetActiveWeapon():GetPrintName() != WeaponName then
			maxClip1 = 0
			maxClip2 = 0
			maxCap1 = 0
		end
		if LocalPlayer():GetActiveWeapon():IsWeapon() then
			WeaponName = LocalPlayer():GetActiveWeapon():GetPrintName()
		end
		if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetActiveWeapon():Clip1() > maxClip1 then
			maxClip1 = LocalPlayer():GetActiveWeapon():Clip1()
		end
		if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) > maxCap1 then
			maxCap1 = LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType())
		end
		if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()) > maxClip2 then
			maxClip2 = LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType())
		end
					--This here, is for the left HUD (etc. HP ARMOUR FPS PING)
					centerx = velMove.y + ScrW()/20
					centery = ScrH() - 70 - velMove.p - ScrH()/20
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx + 25
					trianglevertex[1]["y"] = centery + 25 - 25/8
					
					trianglevertex[2]["x"] = centerx + 200
					trianglevertex[2]["y"] = centery
					
					trianglevertex[3]["x"] = centerx + 200
					trianglevertex[3]["y"] = centery + 10
					
					trianglevertex[4]["x"] = centerx
					trianglevertex[4]["y"] = centery + 60
					surface.SetDrawColor( 241, 241, 241, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx + 25
					trianglevertex[1]["y"] = centery + 25 - 25/8
					
					if LocalPlayer():Ping() > 300 then
						trianglevertex[2]["x"] = centerx + 200
						trianglevertex[2]["y"] = centery
						
						trianglevertex[3]["x"] = centerx + 200
						trianglevertex[3]["y"] = centery + 10
					else
						trianglevertex[2]["x"] = centerx + 25 + LocalPlayer():Ping()/300*175
						trianglevertex[2]["y"] = centery + 25 - 25/8 - LocalPlayer():Ping()/300*(25-25/8)
						
						trianglevertex[3]["x"] = centerx + LocalPlayer():Ping()/300 * 200
						trianglevertex[3]["y"] = centery + 60 - LocalPlayer():Ping()/300 * 50
					end
					
					trianglevertex[4]["x"] = centerx
					trianglevertex[4]["y"] = centery + 60
					surface.SetDrawColor( 225, 139, 53, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx + 200
					trianglevertex[1]["y"] = centery + 10
					
					trianglevertex[2]["x"] = centerx + 175
					trianglevertex[2]["y"] = centery + 45 + 25/8
					
					trianglevertex[3]["x"] = centerx
					trianglevertex[3]["y"] = centery + 70
					
					trianglevertex[4]["x"] = centerx
					trianglevertex[4]["y"] = centery + 60
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					if fpssmooth > 300 then
						trianglevertex[1]["x"] = centerx + 200
						trianglevertex[1]["y"] = centery + 10
						
						trianglevertex[2]["x"] = centerx + 175
						trianglevertex[2]["y"] = centery + 45 + 25/8
					else
						trianglevertex[1]["x"] = centerx + fpssmooth/300 * 200
						trianglevertex[1]["y"] = centery + 60 - fpssmooth/300 * 50
						
						trianglevertex[2]["x"] = centerx + fpssmooth/300*175
						trianglevertex[2]["y"] = centery + 70 + fpssmooth/300*(45 + 25/8-70)
					end
					
					trianglevertex[3]["x"] = centerx
					trianglevertex[3]["y"] = centery + 70
					
					trianglevertex[4]["x"] = centerx
					trianglevertex[4]["y"] = centery + 60
					surface.SetDrawColor( 53, 225, 53, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx + 200
					trianglevertex[1]["y"] = centery + 10
					
					trianglevertex[2]["x"] = centerx + 175
					trianglevertex[2]["y"] = centery + 35 + 25/8
					
					trianglevertex[3]["x"] = centerx
					trianglevertex[3]["y"] = centery + 60
					surface.SetDrawColor( 241, 241, 241, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx + 25
					trianglevertex[1]["y"] = centery + 35 - 25/8
					
					trianglevertex[2]["x"] = centerx + 200
					trianglevertex[2]["y"] = centery + 10
					
					trianglevertex[3]["x"] = centerx
					trianglevertex[3]["y"] = centery + 60
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx + 25 + hp_smo / hp_m_smo * 175
					trianglevertex[1]["y"] = centery + 60 - 25 - 25/8 - hp_smo / hp_m_smo * (25-25/8)
					
					trianglevertex[2]["x"] = centerx + hp_smo / hp_m_smo * 175
					trianglevertex[2]["y"] = centery + 60 - hp_smo / hp_m_smo * (25-25/8)
					
					trianglevertex[3]["x"] = centerx
					trianglevertex[3]["y"] = centery + 60
					
					trianglevertex[4]["x"] = centerx + 25
					trianglevertex[4]["y"] = centery + 35 - 25/8
					surface.SetDrawColor( 225, 53, 53, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ }} --create the two dimensional table
					trianglevertex[1]["x"] = centerx + 25
					trianglevertex[1]["y"] = centery + 35 - 25/8
					
					trianglevertex[2]["x"] = centerx + 25 + armor2 / maxarmor2 * 175
					trianglevertex[2]["y"] = centery + 35 - 25/8 - armor2 / maxarmor2 * (25-25/8)
					
					trianglevertex[3]["x"] = centerx
					trianglevertex[3]["y"] = centery + 60
					surface.SetDrawColor( 53, 129, 225, 255 )
					if armor > 0 then
						surface.DrawPoly( trianglevertex )
					end
					--This here, is for the left HUD (etc. HP ARMOUR FPS PING)
					centerx2 = ScrW() - 200 + velMove.y - ScrW()/20
					centery2 = ScrH() - 70 - velMove.p - ScrH()/20
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx2 + 175
					trianglevertex[1]["y"] = centery2 + 25 - 25/8
					
					trianglevertex[2]["x"] = centerx2
					trianglevertex[2]["y"] = centery2
					
					trianglevertex[3]["x"] = centerx2
					trianglevertex[3]["y"] = centery2 + 10
					
					trianglevertex[4]["x"] = centerx2 + 200
					trianglevertex[4]["y"] = centery2 + 60
					surface.SetDrawColor( 241, 241, 241, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx2 + 175
					trianglevertex[1]["y"] = centery2 + 25 - 25/8
					
					if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType() > 0 then
						trianglevertex[2]["x"] = centerx2 + 175 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType())/maxClip2*175
						trianglevertex[2]["y"] = centery2 + 25 - 25/8 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType())/maxClip2*(25-25/8)
						
						trianglevertex[3]["x"] = centerx2 + 200 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType())/maxClip2 * 200
						trianglevertex[3]["y"] = centery2 + 60 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType())/maxClip2 * 50
					else
						trianglevertex[2]["x"] = centerx2 + 175
						trianglevertex[2]["y"] = centery2 + 25 - 25/8
						
						trianglevertex[3]["x"] = centerx2 + 200
						trianglevertex[3]["y"] = centery2 + 60
					end
					
					trianglevertex[4]["x"] = centerx2 + 200
					trianglevertex[4]["y"] = centery2 + 60
					surface.SetDrawColor( 225, 139, 53, 255 )
					if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType() > 0 then
						if LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()) > 0 then
							surface.DrawPoly( trianglevertex )
						end
					end
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx2
					trianglevertex[1]["y"] = centery2 + 10
					
					trianglevertex[2]["x"] = centerx2 + 25
					trianglevertex[2]["y"] = centery2 + 45 + 25/8
					
					trianglevertex[3]["x"] = centerx2 + 200
					trianglevertex[3]["y"] = centery2 + 70
					
					trianglevertex[4]["x"] = centerx2 + 200
					trianglevertex[4]["y"] = centery2 + 60
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
					
					if txt > 1500 then
						trianglevertex[1]["x"] = centerx2
						trianglevertex[1]["y"] = centery2 + 10
						
						trianglevertex[2]["x"] = centerx2 + 25
						trianglevertex[2]["y"] = centery2 + 45 + 25/8
					else
						trianglevertex[1]["x"] = centerx2 + 200 - txt/1500 * 200
						trianglevertex[1]["y"] = centery2 + 60 - txt/1500 * 50
						
						trianglevertex[2]["x"] = centerx2 + 200 - txt/1500*175
						trianglevertex[2]["y"] = centery2 + 70 + txt/1500*(25/8 - 25)
					end
					
					trianglevertex[3]["x"] = centerx2 + 200
					trianglevertex[3]["y"] = centery2 + 70
					
					trianglevertex[4]["x"] = centerx2 + 200
					trianglevertex[4]["y"] = centery2 + 60
					surface.SetDrawColor( 53, 225, 53, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx2
					trianglevertex[1]["y"] = centery2 + 10
					
					trianglevertex[2]["x"] = centerx2 + 25
					trianglevertex[2]["y"] = centery2 + 35 + 25/8
					
					trianglevertex[3]["x"] = centerx2 + 200
					trianglevertex[3]["y"] = centery2 + 60
					surface.SetDrawColor( 241, 241, 241, 255 )
					surface.DrawPoly( trianglevertex )
					trianglevertex = {{ },{ },{ }} --create the two dimensional table
					
					trianglevertex[1]["x"] = centerx2 + 175
					trianglevertex[1]["y"] = centery2 + 35 - 25/8
					
					trianglevertex[2]["x"] = centerx2
					trianglevertex[2]["y"] = centery2 + 10
					
					trianglevertex[3]["x"] = centerx2 + 200
					trianglevertex[3]["y"] = centery2 + 60
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawPoly( trianglevertex )
					if LocalPlayer():GetActiveWeapon():IsWeapon() then
						trianglevertex = {{ },{ },{ },{ }} --create the two dimensional table
						
						trianglevertex[1]["x"] = centerx2 + 175 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) / maxCap1 * 175
						trianglevertex[1]["y"] = centery2 + 60 - 25 - 25/8 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) / maxCap1 * (25-25/8)
						
						trianglevertex[2]["x"] = centerx2 + 200 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) / maxCap1 * 175
						trianglevertex[2]["y"] = centery2 + 60 - LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) / maxCap1 * (25-25/8)
						
						trianglevertex[3]["x"] = centerx2 + 200
						trianglevertex[3]["y"] = centery2 + 60
						
						trianglevertex[4]["x"] = centerx2 + 175
						trianglevertex[4]["y"] = centery2 + 35 - 25/8
						surface.SetDrawColor( 225, 53, 53, 255 )
						if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()) > 0 then
							surface.DrawPoly( trianglevertex )
						end
						trianglevertex = {{ },{ },{ }} --create the two dimensional table
						
						trianglevertex[1]["x"] = centerx2 + 175
						trianglevertex[1]["y"] = centery2 + 35 - 25/8
						
						trianglevertex[2]["x"] = centerx2 + 175 - LocalPlayer():GetActiveWeapon():Clip1() / maxClip1 * 175
						trianglevertex[2]["y"] = centery2 + 35 - 25/8 - LocalPlayer():GetActiveWeapon():Clip1() / maxClip1 * (25-25/8)
						
						trianglevertex[3]["x"] = centerx2 + 200
						trianglevertex[3]["y"] = centery2 + 60
						surface.SetDrawColor( 53, 129, 225, 255 )
						if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetActiveWeapon():Clip1() > 0 then
							surface.DrawPoly( trianglevertex )
						end
					end
		
		local function RightTextSlide(text, x, y)
			for i = 1, string.len(text) do
				local thespace = surface.GetTextSize(string.sub(text, 0, i-1))
				surface.SetTextPos( centerx2 + x + thespace, centery2 + y + math.Round(thespace/175 * (25-25/8)) )
				surface.DrawText(string.sub(text, i, i))
			end
		end
		local function LeftTextSlide(text, x, y)
			for i = 1, string.len(text) do
				local thespace = surface.GetTextSize(string.sub(text, 0, i-1))
				local totalspace = surface.GetTextSize(text)
				local raisedcharacter = surface.GetTextSize(string.sub(text, i, i))
				surface.SetTextPos( centerx + x + thespace - totalspace, centery + y - math.Round((thespace-totalspace+raisedcharacter)/175 * (25-25/8)) )
				surface.DrawText(string.sub(text, i, i))
			end
		end
		
		
		surface.SetFont( "Small" )
		/*Whited*/
		surface.SetTextColor(255,255,255,255)
		if LocalPlayer():GetActiveWeapon():IsWeapon() then
			/*RightTextSlide(LocalPlayer():GetActiveWeapon():GetPrintName(), 0, -11 )*/
			surface.SetTextPos( centerx2, centery2 - 11 )
			surface.DrawText(LocalPlayer():GetActiveWeapon():GetPrintName())
		end
		/*Blacked*/
		surface.SetTextColor(31, 31, 31,255)
		
		if units == 1 then
			RightTextSlide(math.Round(txt) .. " Units", 25 + 25/8, 35 + 25/8)
		elseif units == 3 then
			RightTextSlide(math.Round(txt * 3600 / 63360 * 0.75) .. " mph", 25 + 25/8, 35 + 25/8)
		else
			RightTextSlide(math.Round(txt * 3600 * 0.0000254 * 0.75) .. " kph", 25 + 25/8, 35 + 25/8)
		end
		
		LeftTextSlide(LocalPlayer():Ping() .." ms", 200 - 25/8, 0)
		LeftTextSlide(math.floor(fpssmooth) .. " fps", 175 - 25/8, 35 + 25/8)

		if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType() > 0 then
			RightTextSlide(LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()), 25/8, 0 )
		end
		
		surface.SetFont( "Big" )
		
		LeftTextSlide(math.Round(hp_smo), 175, 15)
		
		if armor > 0 then
			sethealthsize = surface.GetTextSize(math.Round(hp_smo))
			surface.SetFont( "Small" )
			LeftTextSlide(armor2 .. "/", 175 - sethealthsize, 23 + math.Round(sethealthsize/175 * (25-25/8)))
			surface.SetFont( "Big" )
		end
		
		if LocalPlayer():GetActiveWeapon():IsWeapon() and LocalPlayer():GetActiveWeapon():Clip1() == -1 and LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() > 0 then
			RightTextSlide(LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()), 25, 15 )
		elseif LocalPlayer():GetActiveWeapon():IsWeapon() and (LocalPlayer():GetActiveWeapon():Clip1() > 0 or LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType() > 0) then
			RightTextSlide(LocalPlayer():GetActiveWeapon():Clip1() .. "/" .. LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()), 25, 15 )
		end
	else
		/* Is the values reseted on death? */
		hp_smo = 0
		hp_m_smo = 0
		ar_smo = 0
		ar_m_smo = 0
	end
	/*surface.DrawText(LocalPlayer():GetActiveWeapon():GetPrintName() .. " : " .. enabled .. " : " .. units .. " : " .. sensitivity)*/
end)
hook.Add("HUDShouldDraw", "letmedomyjobmkay", function( name )
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo"})do
		if name == v and enabled == 1 then return false end
	end
end)
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/
local MENU = {}

function MENU:Initialize()
	Heuheuheu = vgui.Create( "DFrame" )
	Heuheuheu:SetSize( 320, 120 )
	Heuheuheu:SetPos( ScrW()/2 - Heuheuheu:GetWide()/2, ScrH() - math.Round(menu_m_smo*Heuheuheu:GetTall()) )
	Heuheuheu:ShowCloseButton( false )
	Heuheuheu:SetDraggable( false )
	Heuheuheu:SetTitle( "" )
	Heuheuheu:MakePopup()
	Heuheuheu.Paint = function() end

	self.TabContainer = vgui.Create( "DPropertySheet", Heuheuheu )
	self.TabContainer:SetPos( 0, 0 )
	self.TabContainer:SetSize( Heuheuheu:GetSize() )
	
	
	TestingButtonEnable = vgui.Create( "Button", self.TabContainer )
	TestingButtonEnable:SetPos( 5, 5 )
	TestingButtonEnable:SetSize( 150,20 )
	TestingButtonEnable:SetVisible( true )
	TestingButtonEnable:SetText( "Enable" )
	function TestingButtonEnable:OnMousePressed()
		SetSettings(1 .. ";" .. units .. ";" .. sensitivity .. ";")
	end
	
	TestingButtonDisable = vgui.Create( "Button", self.TabContainer )
	TestingButtonDisable:SetPos( 165, 5 )
	TestingButtonDisable:SetSize( 150,20 )
	TestingButtonDisable:SetVisible( true )
	TestingButtonDisable:SetText( "Disable" )
	function TestingButtonDisable:OnMousePressed()
		SetSettings(2 .. ";" .. units .. ";" .. sensitivity .. ";")
	end
	
	TestingComboBox = vgui.Create( "DComboBox", self.TabContainer )
	TestingComboBox:SetPos( 5, 30 )
	TestingComboBox:SetSize( 310, 20 )
	TestingComboBox:AddChoice( "Units" )
	TestingComboBox:AddChoice( "kph" )
	TestingComboBox:AddChoice( "mph" )
	TestingComboBox:ChooseOptionID( units )
	TestingComboBox.OnSelect = function( panel, index, content )
		SetSettings(enabled .. ";" .. index .. ";" .. sensitivity .. ";")
	end

	TestingSensitivity = vgui.Create( "DNumSlider", self.TabContainer )
	TestingSensitivity:SetPos( 5, 55 )
	TestingSensitivity:SetWide( 310 )
	TestingSensitivity:SetDecimals( 0 )
	TestingSensitivity:SetMin( 0 )
	TestingSensitivity:SetMax( 200 )
	TestingSensitivity:SetText( "Sensitivity" )
	TestingSensitivity:SetValue( sensitivity )
	TestingSensitivity.Think = function()
		if ( input.IsMouseDown( MOUSE_LEFT ) ) then
			self.applySettings = true
		elseif ( input.IsMouseDown( MOUSE_LEFT ) == false and self.applySettings == true ) then
			SetSettings(enabled .. ";" .. units .. ";" .. math.Round(TestingSensitivity:GetValue()) .. ";")
			self.applySettings = false
		end
	end
end

function MENU:Show()
	if ( !Heuheuheu ) then MENU:Initialize() end
	
	Heuheuheu:SetKeyboardInputEnabled( false )
	Heuheuheu:SetMouseInputEnabled( true )
	input.SetCursorPos( ScrW()/2, ScrH() - Heuheuheu:GetTall()/2 )
	menu_m = 1
end

function MENU:Hide()
	if ( !Heuheuheu ) then return end

	Heuheuheu:SetKeyboardInputEnabled( false )
	Heuheuheu:SetMouseInputEnabled( false )
	menu_m = 0
end
concommand.Add( "+hud_menu", function() MENU:Show() end )
concommand.Add( "-hud_menu", function() MENU:Hide() end )
concommand.Add( "hud_reset", function() MENU:Initialize() MENU:Hide() end )
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/