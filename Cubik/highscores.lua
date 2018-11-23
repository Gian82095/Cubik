
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local json = require( "json" )

local scoresTable = {}

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )
local menuButton

local function loadScores()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end


local function saveScores()

	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end


local function gotoMenu()
	composer.gotoScene( "menu", { time=800, effect="crossFade" } )
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
function scene:create( event )

    local sceneGroup = self.view
    loadScores()
    table.insert( scoresTable, composer.getVariable("finalScore"))
    composer.setVariable( "finalScore", 0 )
    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )
    saveScores()

	local background = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
	background:setFillColor (0.6, 0.6, 0.6)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local highScoresHeader = display.newText (sceneGroup, "Top 5 punteggi", display.contentCenterX, 100, native.systemFont, 44)
	highScoresHeader:setFillColor (0, 0, 0)

    for i = 1, 5 do
        if ( scoresTable[i] ) then
            local yPos = 150 + ( i * 56 )

            local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-80, yPos, native.systemFont, 36 )
            rankNum:setFillColor(0, 0, 0)
            rankNum.anchorX = 1

            local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-50, yPos, native.systemFont, 36 )
            thisScore.anchorX = 0
			thisScore:setFillColor(0, 0, 0)
			
        end
    end

    menuButton = display.newText( sceneGroup, "Ritorna al menu", display.contentCenterX, 550, native.systemFont, 44 )
    menuButton:setFillColor(0, 0, 0)
    
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
	menuButton:addEventListener( "tap", gotoMenu )
	Runtime:addEventListener ("key", pushBackKey)
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener ("key", pushBackKey)
		composer.removeScene( "highscores" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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
