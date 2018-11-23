local composer=require("composer");

local scene=composer.newScene();

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local menuButton
local line1
local line2


local function gotoMenu()
	display.remove (line1)
	display.remove (line2)
	composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

local function pushBackKey(event)
	if (event.phase=="up" and event.keyName=="back") then
		display.remove (line1)
		display.remove (line2)
		composer.gotoScene( "menu", { time=800, effect="crossFade" } )
	end
	return true;
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create(event)

	local sceneGroup=self.view;
	gruppoTut= display.newGroup()
	sceneGroup:insert (gruppoTut)
	-- Code here runs when the scene is first created but has not yet appeared on screen
	
	background = display.newRect(gruppoTut, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor(0.6, 0.6, 0.6)
	
	local tutorialHeader = display.newText (gruppoTut, "Tutorial", display.contentCenterX, 50, native.systemFont, 44)
	tutorialHeader:setFillColor(0,0,0)
	line1=display.newLine (0, tutorialHeader.y+35, display.contentWidth, tutorialHeader.y+35)
	line1:setStrokeColor(0,0,0)
	
	local triangolo = display.newImage(gruppoTut, "IMG/triangolo.png")
	triangolo.x = display.contentCenterX-200
	triangolo.y = 150
	local triText=display.newText(gruppoTut, "Non toccarlo!\nSaltalo premendo su Cubik!", display.contentCenterX +100,triangolo.y, native.systemFont, 30)
	triText:setFillColor(0,0,0)
	
	local fantasma=display.newImageRect(gruppoTut, "IMG/fantasma.png", 100, 100)
	fantasma.x = triangolo.x
	fantasma.y = triangolo.y+110
	local fanText=display.newText(gruppoTut, "Fallo scomparire!\nCon un due tap!", display.contentCenterX +45,fantasma.y, native.systemFont, 30)
	fanText:setFillColor(0,0,0)
	
	local meteorite=display.newImageRect (gruppoTut, "IMG/meteorite.png", 88, 100)
	meteorite.x = triangolo.x
	meteorite.y = fantasma.y+110
	local metText=display.newText(gruppoTut, "Distruggila!\nShakerando il telefono!", display.contentCenterX +70, meteorite.y, native.systemFont, 30)
	metText:setFillColor(0,0,0)
	
	local power=display.newImageRect (gruppoTut, "IMG/jump.png", 50, 50)
	power.x = triangolo.x
	power.y = meteorite.y+110
	local powText=display.newText(gruppoTut, "Prendilo! Ed esegui un doppiosalto\nTrascinando verso l'alto!", display.contentCenterX +130, power.y, native.systemFont,30)
	powText:setFillColor(0,0,0)
	
	menuButton = display.newText( gruppoTut, "Ritorna al menu", display.contentCenterX, 600, native.systemFont, 44 )
	menuButton:setFillColor(0,0,0)
	
	line2=display.newLine (0, menuButton.y-35, display.contentWidth, menuButton.y-35)
	line2:setStrokeColor(0,0,0)
end


-- show()
function scene:show(event)

	local sceneGroup=self.view;
	local phase=event.phase;

	if (phase=="will") then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif (phase=="did") then
		-- Code here runs when the scene is entirely on screen
		menuButton:addEventListener( "tap", gotoMenu )
		Runtime:addEventListener ("key", pushBackKey)
	end
end


-- hide()
function scene:hide(event)

	local sceneGroup=self.view;
	local phase=event.phase;

	if (phase=="will") then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif (phase=="did") then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener ("key", pushBackKey)
		composer.removeScene( "tutorial" )
		
	end
end


-- destroy()
function scene:destroy(event)

	local sceneGroup=self.view;
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);
-- -----------------------------------------------------------------------------------

return scene;
