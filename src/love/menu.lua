--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten by HTV04
------------------------------------------------------------------------------]]

menu = {
	-- Initialises menu
	init = function()
		menuState = 0
		weekSongs = {
			{
				"Tutorial"
			},
			{
				"Bopeebo",
				"Fresh",
				"Dadbattle"
			},
			{
				"Spookeez",
				"South"
			},
			{
				"Pico",
				"Philly Nice",
				"Blammed"
			}
		}
		difficultyStrs = {
			"-easy",
			"",
			"-hard"
		}
		
		-- Sounds used for menu actions, full loaded
		selectSound = love.audio.newSource("sounds/scrollMenu.ogg", "static")
		confirmSound = love.audio.newSource("sounds/confirmMenu.ogg", "static")
		
		-- Background image and FNFR logo
		titleBG = Image(love.graphics.newImage("images/titleBG.png"))
		logo = Image(love.graphics.newImage("images/logo.png"))
		
		-- Girlfriend animation specified by table of animation data
		girlfriendTitle = love.filesystem.load("sprites/girlfriend-title.lua")()
		
		logo.x, logo.y = -350, -125
		logo.sizeX, logo.sizeY = 1.25, 1.25
		
		girlfriendTitle.x, girlfriendTitle.y = 300, -75
		
		-- Menu background music, streamed from disc for efficiency
		music = love.audio.newSource("music/freakyMenu.ogg", "stream")
		music:setLooping(true)
		music:play()
	end,
	
	-- Update input and animations
	-- 'dt' means delta time
	update = function(dt)
		-- Update girlfriend animation
		girlfriendTitle:update(dt)
		
		-- Handle input only if graphics isn't fading
		if not graphics.isFading then
			if input:pressed("left") then
				audio.playSound(selectSound)
				
				if menuState == 0 then
					-- Week selection
					weekNum = weekNum - 1
					
					if weekNum < 0 then
						weekNum = 3
					end
				elseif menuState == 1 then
					-- Song selection
					songNum = songNum - 1
					
					if songNum < 0 then
						songNum = #weekSongs[weekNum + 1]
					end
				elseif menuState == 2 then
					-- Difficulty selection
					songDifficulty = songDifficulty - 1
					
					if songDifficulty < 1 then
						songDifficulty = 3
					end
				end
			elseif input:pressed("right") then
				audio.playSound(selectSound)
				
				if menuState == 0 then
					-- Week selection
					weekNum = weekNum + 1
					
					if weekNum > 3 then
						weekNum = 0
					end
				elseif menuState == 1 then
					-- Song selection
					songNum = songNum + 1
					
					if songNum > #weekSongs[weekNum + 1] then
						songNum = 0
					end
				elseif menuState == 2 then
					-- Difficulty selection
					songDifficulty = songDifficulty + 1
					
					if songDifficulty > 3 then
						songDifficulty = 1
					end
				end
			elseif input:pressed("confirm") then
				audio.playSound(confirmSound)
				
				-- Selection an option is equivalent
				-- to increasing the level of nesting
				menuState = menuState + 1
				
				if menuState > 2 then
					-- Prepare to begin the game with the chosen settings

					-- Stop the menu music
					music:stop()
					
					-- Clamp value so menuState isn't an "invalid" value
					menuState = 2
					
					-- Begin fade out transition to gameplay
					graphics.fadeOut(
						1,
						function()
							songAppend = difficultyStrs[songDifficulty]
							
							inMenu = false
							inGame = true
							
							if songNum == 0 then
								songNum = 1
								storyMode = true
							end
							
							weeks[weekNum].init()
						end
					)
				end
			elseif input:pressed("back") then
				-- Don't play sound if exiting the game
				if menuState > 0 then
					audio.playSound(selectSound)
				end
				
				-- Backing out of an option is equivalent
				-- to reducing the level of nesting
				menuState = menuState - 1
				
				if menuState == 0 then
					songNum = 0
				elseif menuState < 0 then
					-- Quitting

					-- Clamp value so menuState isn't an "invalid" value
					menuState = 0
					
					-- Fade graphics out
					graphics.fadeOut(1, love.event.quit)
				end
			end
		end
	end,
	
	draw = function()
		-- Draw the background
		titleBG:draw()
		
		love.graphics.push()
			love.graphics.scale(cam.sizeX, cam.sizeY)
			
			-- Draw FNFR logo
			logo:draw()
			
			-- Draw the animated girlfriend
			girlfriendTitle:draw()
			
			-- Print authorship
			love.graphics.printf("By HTV04\nv1.0.0 beta 2\n\nOriginal game by ninjamuffin99, PhantomArcade, kawaisprite, and evilsk8er, in association with Newgrounds", -525, 90, 450, "right", nil, 1, 1)
			
			graphics.setColor(1, 1, 0)
			if menuState == 0 then
				-- Week selection
				if weekNum == 0 then
					-- Tutorial
					love.graphics.printf("Choose a week: < Tutorial >", -640, 285, 853, "center", nil, 1.5, 1.5)
				else
					-- Normal Week
					love.graphics.printf("Choose a week: < Week " .. weekNum .. " >", -640, 285, 853, "center", nil, 1.5, 1.5)
				end
			elseif menuState == 1 then
				-- Song selection
				if songNum == 0 then
					-- Story mode
					love.graphics.printf("Choose a song: < (Story Mode) >", -640, 285, 853, "center", nil, 1.5, 1.5)
				else
					-- Normal Song
					love.graphics.printf("Choose a song: < " .. weekSongs[weekNum + 1][songNum] .. " >", -640, 285, 853, "center", nil, 1.5, 1.5)
				end
			elseif menuState == 2 then
				-- Difficulty selection
				if songDifficulty == 1 then
					-- Easy
					love.graphics.printf("Choose a difficulty: < Easy >", -640, 285, 853, "center", nil, 1.5, 1.5)
				elseif songDifficulty == 2 then
					-- Normal
					love.graphics.printf("Choose a difficulty: < Normal >", -640, 285, 853, "center", nil, 1.5, 1.5)
				elseif songDifficulty == 3 then
					-- Hard
					love.graphics.printf("Choose a difficulty: < Hard >", -640, 285, 853, "center", nil, 1.5, 1.5)
				end
			end
			graphics.setColor(1, 1, 1)
			
			if menuState <= 0 then
				-- Top level
				if input:getActiveDevice() == "joy" then
					-- Joystick
					love.graphics.printf("Left Stick/D-Pad: Select | A: Confirm | B: Exit", -640, 350, 1280, "center", nil, 1, 1)
				else
					-- Keyboard
					love.graphics.printf("Arrow Keys: Select | Enter: Confirm | Escape: Exit", -640, 350, 1280, "center", nil, 1, 1)
				end
			else
				-- Nested options
				if input:getActiveDevice() == "joy" then
					-- Joystick
					love.graphics.printf("Left Stick/D-Pad: Select | A: Confirm | B: Back", -640, 350, 1280, "center", nil, 1, 1)
				else
					-- Keyboard
					love.graphics.printf("Arrow Keys: Select | Enter: Confirm | Escape: Back", -640, 350, 1280, "center", nil, 1, 1)
				end
			end
		love.graphics.pop()
	end
}
