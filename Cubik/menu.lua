
local composer = require( "composer" )

local scene = composer.newScene()

audio.reserveChannels(2)
audio.setVolume(0.5, { channel=2 })
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local menuSound
local player 
local egg=1
local background
local playButton
local highScoresButton
local tutorialButton
local cubikText
local gruppoMenu
local onGame=false
	
	
local function gotoGame()
	onGame=true
	audio.play(volumeON)
	audio.stop(2)
	audio.setVolume(0.0, {channel=2});
	display.remove (player)
	composer.gotoScene ("game", { time=800, effect="crossFade" })
end

local function gotoHighScores()
	onGame=true
	display.remove (player)
	composer.gotoScene ("highscores", { time=800, effect="crossFade" } )
end

local function gototutorial()
	onGame=true
	display.remove (player)
	composer.gotoScene ("tutorial", { time=800, effect="crossFade" } )
end

local function easterEgg()
	if (egg==1) then
		player:setFillColor(0.6, 0.6, 0.6)
		background:setFillColor(0, 0, 0)
		
		cubikText:setFillColor(1,1,1)
		playButton:setFillColor(1, 1, 1)
		highScoresButton:setFillColor( 1, 1, 1)
		tutorialButton:setFillColor(1, 1, 1)
		egg=egg+1
	elseif (egg==2) then
		player:setFillColor(0.3, 0.1, 0.2)
		background:setFillColor(0.65, 0.2, 0.2)
		
		cubikText:setFillColor(0,0,0)
		playButton:setFillColor( 0, 0, 0)
		highScoresButton:setFillColor( 0, 0, 0)
		tutorialButton:setFillColor( 0, 0, 0)
		egg=egg+1
	elseif (egg==3) then
		player:setFillColor(0.65, 0.2, 0.2)
		background:setFillColor(0.3, 0.1, 0.2)
		
		cubikText:setFillColor(1,1,1)
		playButton:setFillColor(1, 1, 1)
		highScoresButton:setFillColor( 1, 1, 1)
		tutorialButton:setFillColor(1, 1, 1)
		egg=egg+1
	elseif (egg==4) then
		player:setFillColor(0, 0, 0)
		background:setFillColor(0.6, 0.6, 0.6)
		
		cubikText:setFillColor(0,0,0)
		playButton:setFillColor( 0, 0, 0)
		highScoresButton:setFillColor( 0, 0, 0)
		tutorialButton:setFillColor( 0, 0, 0)
		egg=1
	end
end

local function tornaGiu()
	if(onGame==false) then
		transition.to (player,
		{
			y=player.y + 150,
			time=350,
		})
	end
end

local function singleJump()
	if(onGame==false) then
		transition.to (player,
		{
			y=player.y - 150,
			time=350,
			onComplete= function()
				timer.performWithDelay (90, tornaGiu, 1)
			end
		})
	end
end

local function Jump()
	if(onGame==false) then
		timer.performWithDelay (900, singleJump, 2)
	end
end

local function togliSuono(event)
	if (volumeON==true) then
		nsheet=false
		audio.setVolume(0.0)
		volumeON=false
		event.target:setFrame(2)
	else
		nsheet=true
		audio.setVolume(0.5)
		volumeON=true
		event.target:setFrame(1)
	end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local volumeButton
	local sheetVolume ={}
	local VolData ={}
	local volumeButtonSeq
	local volumeON=true
	local sceneGroup = self.view
	
	gruppoMenu= display.newGroup()
	sceneGroup:insert (gruppoMenu)
	
	gruppoPlayer= display.newGroup()
	sceneGroup:insert (gruppoMenu)
	
	-- Code here runs when the scene is first created but has not yet appeared on screen
	background = display.newRect(gruppoMenu, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor(0.6, 0.6, 0.6)
	
	player= display.newRect (gruppoPlayer, 100, display.contentCenterY+200, 65, 65)
	player:setFillColor(0, 0, 0)
	player.myName= "player"
	
	playButton = display.newText( gruppoMenu, "Gioca", display.contentCenterX, display.contentCenterY-50, native.systemFont, 44 )
	playButton:setFillColor( 0, 0, 0)
	
	cubikText= display.newText(gruppoMenu, "Cubik", playButton.x, playButton.y-150, native.systemFont, 60)
	cubikText:setFillColor(0,0,0)
	
	highScoresButton = display.newText( gruppoMenu, "Punteggi migliori", display.contentCenterX, playButton.y+80, native.systemFont, 44 )
	highScoresButton:setFillColor( 0, 0, 0)
	
	tutorialButton = display.newText( gruppoMenu, "Tutorial", display.contentCenterX, highScoresButton.y+80, native.systemFont, 44 )
	tutorialButton:setFillColor( 0, 0, 0)
	
	
	
	VolData={width =50, height =50, numFrames=2, sheetContentWidth =100, sheetContentHeight =50}
	sheetVolume=graphics.newImageSheet( "IMG/volume.png", VolData )
	volumeButtonSeq= 
	{
 		{ name = "vol", start=1, count=2},
		--{name="volon", start=2}
	}
	volumeButton=display.newSprite( gruppoMenu, sheetVolume, volumeButtonSeq, 60, 60)
	volumeButton:setSequence("vol")
	if (audio.getVolume() > 0) then
		volumeON=true
		volumeButton:setFrame(1)
		audio.setVolume( 0.5 )
	else
		volumeON=false
		volumeButton:setFrame(2)
		audio.setVolume( 0.0 )
	end
	volumeButton.x= tutorialButton.x
	volumeButton.y=tutorialButton.y+80
	volumeButton.myName="volButt"
	volumeButton:addEventListener("tap", togliSuono)
	
	menuSound=audio.loadStream("sounds/menuSong.mp3")
	
	player:addEventListener ("tap", easterEgg)
	playButton:addEventListener ("tap", gotoGame)
	highScoresButton:addEventListener ("tap", gotoHighScores)
	tutorialButton:addEventListener ("tap", gototutorial)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		audio.play (menuSound, { channel=2, loops=-1 })
		
		playerTimer= timer.performWithDelay (3000, Jump, 0)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel(playerTimer)
		
		
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "menu" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose(menuSound)
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
