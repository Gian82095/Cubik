

local composer=require ("composer")

local scene=composer.newScene()
audio.setVolume( 0.5, { channel=1 } )
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity(0, 0)

--VARIABILI--
local speed=4
local bg1
local bg2
local bgback1
local bgback2
local platform1
local platform2
local player
local salto=1
local score=0
local secondi=0
local minuti=0
local powerUp=0
local tempoText
local scoreText
local powerText
local levelText
local fantasma
local ghostHearth=2
local dead=false
local backg ={}
local backgg={}
local pos=1   --posizione del background nell'array da mettere 
local livello=1
local r=1

local ostacoliTable = {}
local powerTable = {}

local ostacoliTimer
local backTimer
local scoreTimer
local tempoTimer
--GRUPPI--
local gruppoOstacoli
local gruppoBg
local gruppoScena
local gruppoPlayer

--SUONI--
local explosionSound
local gameLoopSound
local killGhostSound
local powerupSound

--FUNZIONI--
local function loopBackgrounds()	
	bg1.x = bg1.x - (speed)
	if(bg1.x < -600 ) then
		bg1.x =  600 + 1197 - speed*2 --bg2.x al posto di 600 1200 - speed*2   -(screenXwidth-1)
	end	
	bg2.x = bg2.x - (speed)
	if(bg2.x < -600) then
		bg2.x = 600 + 1197 - speed*2
	end
	bgback1.x=bgback1.x - speed/3
	if(bgback1.x<-600) then
		bgback1.x=600+1197-speed
	end
	bgback2.x=bgback2.x - speed/3
	if(bgback2.x<-600) then
		bgback2.x=600+1197-speed
	end	
end

local function tornaGiu()
	transition.to (player,
	{
		y=platform1.y-52,
		time=350,
		onComplete= function()
			salto=1
		end
	})
end

local function singleJump(event)
	if (dead==false) then  --questa funzione è chiamata anche da doubleJump. se non controllo che dead==false e avviene una collisione "a mezz'aria" da l'errore su player.y
		if(salto>0) then
			salto=0
			transition.to (player,
			{
				y=player.y - 200,
				time=350,
				onComplete= function()
					if (dead==false) then
						timer.performWithDelay (90, tornaGiu, 1)
					end
				end
			})
		end
	end
end

local function doubleJump(event) --doppio salto solo se ho powerUp
	if (powerUp>0) then
		if (event.phase=="ended") then
			local dY= event.y-event.yStart
			if (dY < -10) then
				if(salto>0) then
					transition.to (player,
					{
						y=player.y - 150,
						time=350,
						onComplete= function()
							timer.performWithDelay (90, singleJump, 1)
						end
					})
					powerUp=powerUp-1
					powerText.text= "PowerUp= ".. powerUp
				end
			else
				return true
			end
		end
	else
		return true
	end
end

local function killGhost (event)  --problema con doppio-tap. risolto mettendo ghostHearth e "raggirando" il problema
	if(event.target.myName=="fantasma") then --FANTASMA ESISTE SOLO SE LIVELLO >=2
		if (event.numTaps>=0) then
			event.target.ghostHearth= event.target.ghostHearth-event.numTaps
			print (event.target.ghostHearth.. "vita")
			if (event.target.ghostHearth<=0) then
				audio.play(killGhostSound)
				for i=#ostacoliTable, 1, -1 do
					if (ostacoliTable[i]==event.target) then
						table.remove (ostacoliTable, i)
					end
				end
				display.remove (event.target)
				
			end
		end
	else
		return true
	end
end

local function destroyMeteors (event)  --SHAKE PER DISTRUGGERE METEORE. LE METEORE CI SONO SOLO SE LIVELLO>=3
	if (event.isShake) then
		for i=#ostacoliTable, 1, -1 do
			local thisMeteora = ostacoliTable[i]
			if (ostacoliTable[i].myName=="meteora") then
				table.remove (ostacoliTable, i)
				display.remove (thisMeteora)
				local boom=display.newImageRect ("IMG/boom2.png", 200, 200)
				audio.play(explosionSound)
				boom.x= thisMeteora.x
				boom.y=thisMeteora.y
				transition.to (boom,
				{
					time=1000,
					onComplete = function()
						display.remove (boom)
					end
				})
			end
		end
	end
	
end

local function loopOstacolo()
	local random = math.random(r*5)
	local newOstacolo
	if(random < 7 and random > 0) then
		newOstacolo= display.newImage (gruppoOstacoli, "IMG/triangolo.png")
		table.insert (ostacoliTable, newOstacolo)
		newOstacolo.myName= "ostacolo"
		newOstacolo.x= platform2.x
		newOstacolo.y= platform2.y - 45
		physics.addBody (newOstacolo, "dynamic", {density=100, friction=1, isSensor="true"})
		newOstacolo:addEventListener ("tap", killGhost)
		transition.to (newOstacolo,
		{
			x=platform1.x -700, 
			time=20000/speed,
			onComplete = function()
				for i=#ostacoliTable, 1, -1 do
					if (ostacoliTable[i]==newOstacolo) then
						table.remove (ostacoliTable, i)
					end
				end
				display.remove (newOstacolo)
			end
		})
	elseif (random > 6 and random < 14) then
		newOstacolo= display.newImageRect (gruppoOstacoli, "IMG/fantasma.png", 120, 120)
		table.insert (ostacoliTable, newOstacolo)
		newOstacolo.myName= "fantasma"
		newOstacolo.ghostHearth=2
		newOstacolo.x= platform2.x
		newOstacolo.y= platform2.y - 130
		physics.addBody (newOstacolo, "dynamic", {density=100, friction=1, isSensor="true"})
		newOstacolo:addEventListener ("tap", killGhost)
		transition.to (newOstacolo,
		{
			x=platform1.x -730, 
			time=50000/speed,
			onComplete = function()
				for i=#ostacoliTable, 1, -1 do
					if (ostacoliTable[i]==newOstacolo) then
						table.remove (ostacoliTable, i)
					end
				end
				display.remove (newOstacolo)
			end
		})
	elseif (random > 13) then
		local random2=math.random(20)  --JUMP BOOST HA UNA PASSA POSSIBILITA' DI USCIRE
		if (random2<10) then
			local newjumpBoost
			newjumpBoost= display.newImageRect (gruppoOstacoli, "IMG/jump.png", 50, 50)
			table.insert (powerTable, newjumpBoost)
			newjumpBoost.myName= "jump"
			newjumpBoost.x= player.x
			newjumpBoost.y= -80
			physics.addBody (newjumpBoost, "dynamic", {isSensor="true"})
			transition.to (newjumpBoost,
			{
				y= player.y + 300,
				time=25000/speed,
				onComplete = function()
					for i=#powerTable, 1, -1 do
						if (powerTable[i]==newjumpBoost) then
							table.remove (powerTable, i)
						end
					end
					display.remove (newjumpBoost)
				end
			})
		else
			newOstacolo= display.newImageRect (gruppoOstacoli, "IMG/meteorite.png", 150, 170)
			table.insert(ostacoliTable, newOstacolo)
			newOstacolo.myName="meteora"
			newOstacolo.x=display.contentWidth+150
			newOstacolo.y= -170
			physics.addBody (newOstacolo, "dynamic", {density=100, friction=1, isSensor="true"})
			--newOstacolo:addEventListener ("tap", killGhost)
			transition.to (newOstacolo, 
			{
				x=player.x-300,
				y=player.y+170,
				time=7000,
				onComplete = function()
					for i=#ostacoliTable, 1, -1 do
						if (ostacoliTable[i]==newOstacolo) then
							table.remove (ostacoliTable, i)
						end
					end
					display.remove (newOstacolo)
				end
			})
		end
	end
	
end

local function loopScore()
	score = score + 10
	scoreText.text= "Score: ".. score
	if (score%1500==0 and score>0 and dead==false) then
		pos=pos+1   --posizione del background nell'array da mettere 
		if (pos==3) then
			pos=1
		end
		
		bgback1:removeSelf()
		bgback1=display.newImage(gruppoBg, backgg[pos])
		bgback1.x= display.contentCenterX
		bgback1.y= display.contentCenterY - 200
		bgback1.myName= "bgback1"
	
		bgback2:removeSelf()
		bgback2=display.newImage(gruppoBg, backgg[pos])
		bgback2.x= display.contentCenterX + 1197
		bgback2.y= display.contentCenterY - 200
		bgback2.myName= "bgback2"
		
		bg1:removeSelf()
		bg1= display.newImage(gruppoBg, backg[1])
		bg1.x= 600
		bg1.y= display.contentCenterY + 30
		bg1.myName= "bg1"
		
		bg2:removeSelf()
		bg2= display.newImage(gruppoBg, backg[1])
		bg2.x= bg1.x + 1198
		bg2.y= display.contentCenterY + 30
		bg2.myName= "bg2"
		
		if (pos==1) then 
			player:setFillColor (0, 0.2, 0)
			scoreText:setFillColor(0,0,0)
			levelText:setFillColor(0,0,0)
			tempoText:setFillColor(0,0,0)
			powerText:setFillColor(0,0,0)
			
		elseif (pos==2) then
			player:setFillColor (0, 0, 1)
			scoreText:setFillColor(1,1,1)
			levelText:setFillColor(1,1,1)
			tempoText:setFillColor(1,1,1)
			powerText:setFillColor(1,1,1)
		end
	end
	if (score%500==0 and score>0 and dead==false) then
		if (livello<3) then
			r=r+1 				--per spawn ostacoli
			livello=livello+1
		else
			livello=livello+1
			speed=speed*1.2
		end
		levelText.text= "Livello: ".. livello
		
	end	
end

local function aggiornaTempo()
	if(dead==false) then
		if (secondi%59==0 and secondi>0) then
			secondi = 0
			minuti = minuti + 1
		else	
			secondi = secondi + 1
		end		
		tempoText.text = "Tempo: ".. minuti .. "," .. secondi
	end
end

local function gameOver()
	composer.setVariable( "finalScore", score)
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
	display.remove (bg1)
	display.remove (bg2)
	display.remove (bgback1)
	display.remove (bgback2)
	display.remove(platform1)
	display.remove(platform2)
	
	for i=#ostacoliTable, 1, -1 do
		local ostacolo = ostacoliTable[i]
		table.remove (ostacoliTable, i)
		display.remove (ostacolo)
	end		
	
end

local function onCollision (event)
	if ( event.phase == "began" ) then
		local obj1 = event.object1
		local obj2 = event.object2
		
		if ((obj1.myName == "ostacolo" and obj2.myName == "player") or (obj1.myName == "player" and obj2.myName == "ostacolo")) then
			display.remove (player)
			timer.performWithDelay (500, gameOver)
			dead=true
			
		elseif ((obj1.myName == "fantasma" and obj2.myName == "player") or (obj1.myName == "player" and obj2.myName == "fantasma")) then
			display.remove (player)
			timer.performWithDelay (500, gameOver)
			dead=true
			
		elseif ((obj1.myName == "meteora" and obj2.myName == "player") or (obj1.myName == "player" and obj2.myName == "meteora")) then
			display.remove (player)
			timer.performWithDelay (500, gameOver)
			dead=true
			
		elseif ((obj1.myName== "jump" and obj2.myName == "player") or (obj1.myName == "player" and obj2.myName== "jump")) then
			for i=#powerTable, 1, -1 do
				if (powerTable[i]==obj1) then
					table.remove (powerTable, i)
					display.remove (obj1)
				elseif (powerTable[i]==obj2) then
					table.remove (powerTable, i)
					display.remove (obj2)
				end
			end
			audio.play(powerupSound)
			powerUp= powerUp+1
			powerText.text= "PowerUp= ".. powerUp
		end
	end
end

local function pushBackKey(event)
	if (event.phase=="up" and event.keyName=="back") then
		composer.gotoScene( "menu", { time=800, effect="crossFade" } )
	end
	return true;
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

	local sceneGroup=self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()
	
	
	gruppoBg= display.newGroup()
	sceneGroup:insert (gruppoBg)
	
	gruppoScena= display.newGroup()
	sceneGroup:insert (gruppoScena)
	
	gruppoOstacoli= display.newGroup()
	sceneGroup:insert (gruppoOstacoli)
	
	gruppoPlayer= display.newGroup()
	sceneGroup:insert (gruppoPlayer)
	
	table.insert(backg, 1, "IMG/bggame1.png")
	table.insert(backg, 2, "IMG/bggame2.png")	
	
	table.insert(backgg, 1, "IMG/bgback1.png")
	table.insert(backgg, 2, "IMG/bgback2.png")	
	
	--SFONDI--	
	bgback1=display.newImage(gruppoBg, backgg[pos])
	bgback1.x= display.contentCenterX
	bgback1.y= display.contentCenterY - 200
	bgback1.myName= "bgback1"
	
	bgback2=display.newImage(gruppoBg, backgg[pos])
	bgback2.x= display.contentCenterX + 1197
	bgback2.y= display.contentCenterY - 200
	bgback2.myName= "bgback2"
	
	bg1= display.newImage(gruppoBg, backg[1])
	bg1.x= display.contentCenterX
	bg1.y= display.contentCenterY + 30
	bg1.myName= "bg1"
	
	bg2= display.newImage(gruppoBg, backg[1])
	bg2.x= display.contentCenterX + 1197
	bg2.y= display.contentCenterY + 30
	bg2.myName= "bg2"
	
	
	--PIATTAFORMA--
	platform1= display.newImage(gruppoScena, "IMG/platform.png")
	platform1.x=650
	platform1.y = display.contentCenterY + (display.contentCenterY-20)	
	physics.addBody (platform1, "static")
	platform1.myName= "platform1"

	
	platform2= display.newImage(gruppoScena, "IMG/platform.png")
	platform2.x= platform1.x + 1300
	platform2.y = display.contentCenterY + (display.contentCenterY-20)
	physics.addBody (platform2, "static")
	platform2.myName= "platform2"
	
	--PLAYER--
	player= display.newRect (gruppoPlayer, 100, platform1.y-52, 65, 65)
	player:setFillColor (0, 0.2, 0)
	physics.addBody (player, {density=0, isSensor="true"})
	player.myName= "player"
	
	--SCORE & TEMPO--
	tempoText = display.newText(gruppoScena, "Tempo: ".. minuti .. "," .. secondi , 0, 0, native.systemFont, 30)
	tempoText.anchorX, tempoText.anchorY = 0, .5
	tempoText.x, tempoText.y = 10, 20
	tempoText:setFillColor(0,0,0)
	
	scoreText = display.newText(gruppoScena, "Score: "..score, 0, 0, native.systemFont, 30)
	scoreText.anchorX, scoreText.anchorY = 0, .5
	scoreText.x, scoreText.y = tempoText.x+200, 20
	scoreText:setFillColor(0,0,0)
	
	powerText = display.newText(gruppoScena, "PowerUp: ".. powerUp, 0, 0, native.systemFont, 30)
	powerText.anchorX, powerText.anchorY = 0, .5
	powerText.x, powerText.y = scoreText.x+180, 20
	powerText:setFillColor(0,0,0)
	
	levelText = display.newText(gruppoScena, "Livello: ".. livello, 0, 0, native.systemFont, 30)
	levelText.anchorX, levelText.anchorY = 0, .5
	levelText.x, levelText.y = powerText.x+220, 20
	levelText:setFillColor(0,0,0)
	
	--EVENTI--
	player:addEventListener ("tap", singleJump)
	Runtime:addEventListener ("touch", doubleJump)
	
	--SUONI--
	gameLoopSound =audio.loadStream( "sounds/GameLoopSong.mp3" )
	explosionSound= audio.loadSound( "sounds/destroy_meteor.mp3" )
	powerupSound=audio.loadSound("sounds/powerup.mp3")
	killGhostSound= audio.loadSound( "sounds/kill_ghost.mp3" )
	
end

-- show()
function scene:show(event)

	local sceneGroup=self.view
	local phase=event.phase

	if (phase=="will") then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		
	elseif (phase=="did") then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		audio.play (gameLoopSound, { channel=1, loops=-1 })
		
		Runtime:addEventListener ("key", pushBackKey)
		Runtime:addEventListener ("collision", onCollision)
		Runtime:addEventListener ("accelerometer", destroyMeteors)
		backTimer= timer.performWithDelay (1, loopBackgrounds, 0)
		ostacoliTimer= timer.performWithDelay (2000, loopOstacolo, 0)
		scoreTimer= timer.performWithDelay (500, loopScore, 0)
		tempoTimer = timer.performWithDelay (1000, aggiornaTempo, secondi)
	end
end


-- hide()
function scene:hide(event)

	local sceneGroup=self.view
	local phase=event.phase

	if (phase=="will") then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel (ostacoliTimer)
		timer.cancel (backTimer)
		timer.cancel (scoreTimer)
		timer.cancel (tempoTimer)
		
	elseif (phase=="did") then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener ("collision", onCollision)
		Runtime:removeEventListener("touch", doubleJump)
		Runtime:removeEventListener("key", pushBackKey)
		physics.pause()
		audio.stop(1)
		composer.removeScene ("game")
	end
end


-- destroy()
function scene:destroy(event)
	local sceneGroup=self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose(powerupSound)
	audio.dispose(explosionSound)
    audio.dispose(killGhostSound)
    audio.dispose(GameLoopSound)
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene