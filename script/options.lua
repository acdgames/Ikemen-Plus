
module(..., package.seeall)

--;===========================================================
--; LOAD DATA
--;===========================================================
-- Data loading from data_sav.lua
local file = io.open("script/data_sav.lua","r")
s_dataLUA = file:read("*all")
file:close()

-- Data loading from config.ssz
local file = io.open("ssz/config.ssz","r")
s_configSSZ = file:read("*all")
file:close()
resolutionWidth = tonumber(s_configSSZ:match('const int Width%s*=%s*(%d+)'))
resolutionHeight = tonumber(s_configSSZ:match('const int Height%s*=%s*(%d+)'))
gameSpeed = tonumber(s_configSSZ:match('const int GameSpeed%s*=%s*(%d+)'))
b_saveMemory = s_configSSZ:match('const bool SaveMemory%s*=%s*([^;%s]+)')
b_openGL = s_configSSZ:match('const bool OpenGL%s*=%s*([^;%s]+)')

-- Data loading from sound.ssz
local file = io.open("lib/sound.ssz","r")
s_soundSSZ = file:read("*all")
file:close()
freq = tonumber(s_soundSSZ:match('const int Freq%s*=%s*(%d+)'))
channels = tonumber(s_soundSSZ:match('const int Channels%s*=%s*(%d+)'))
buffer = tonumber(s_soundSSZ:match('const int BufferSamples%s*=%s*(%d+)'))

-- Data loading from lifebar
local file = io.open(data.lifebar,"r")
s_lifebarDEF = file:read("*all")
file:close()
roundsNum = tonumber(s_lifebarDEF:match('match.wins%s*=%s*(%d+)'))

--Variable setting based on loaded data
if gameSpeed == 48 then
	s_gameSpeed = '80%'
elseif gameSpeed == 56 then
	s_gameSpeed = '93.33%'
elseif gameSpeed == 60 then
	s_gameSpeed = '100%'
elseif gameSpeed == 64 then
	s_gameSpeed = '106.66%'
elseif gameSpeed == 72 then
	s_gameSpeed = '120%'
end
if channels == 6 then
	s_channels = '5.1'
elseif channels == 4 then
	s_channels = 'quad'
elseif channels == 2 then
	s_channels = 'stereo'
elseif channels == 1 then
	s_channels = 'mono'
end
if b_saveMemory == 'true' then
	b_saveMemory = true
	s_saveMemory = 'Yes'
elseif b_saveMemory == 'false' then
	b_saveMemory = false
	s_saveMemory = 'No'
end
if b_openGL == 'true' then
	b_openGL = true
	s_openGL = 'Yes'
elseif b_openGL == 'false' then
	b_openGL = false
	s_openGL = 'No'
end
if data.teamLifeShare then
	s_teamLifeShare = 'Yes'
else
	s_teamLifeShare = 'No'
end
if data.zoomActive then
	s_zoomActive = 'Yes'
else
	s_zoomActive = 'No'
end
if data.p1Controller == -1 then
	s_p1Controller = 'Keyboard'
else
	s_p1Controller = 'Gamepad'
end
if data.p2Controller == -1 then
	s_p2Controller = 'Keyboard'
else
	s_p2Controller = 'Gamepad'
end
if data.contSelection then
	s_contSelection = 'Yes'
else
	s_contSelection = 'No'
end
if data.aiRamping then
	s_aiRamping = 'Yes'
else
	s_aiRamping = 'No'
end
if data.autoguard then
	s_autoguard = 'Yes'
else
	s_autoguard = 'No'
end

--;===========================================================
--; BACKGROUND DEFINITION
--;===========================================================
--Scrolling background
optionsBG0 = animNew(sysSff, [[
100,0, 0,0, -1
]])
animAddPos(optionsBG0, 160, 0)
animSetTile(optionsBG0, 1, 1)
animSetColorKey(optionsBG0, -1)

--Transparent background
optionsBG1 = animNew(sysSff, [[
100,1, 0,0, -1
]])
animSetTile(optionsBG1, 1, 1)
animSetAlpha(optionsBG1, 20, 100)
animUpdate(optionsBG1)

--;===========================================================
--; ON EXIT
--;===========================================================
modified = 0
needReload = 0

function f_strSub(str, t)
	local txt = ''
	for row, val in pairs(t) do
		if type(val) == 'string' then
			val = "'" .. tostring(val) .. "'"
		elseif type(var) == 'number' then
			val = var
		else
			val = tostring(val)
		end
		str = str:gsub(row .. '%s*=%s*[^\n]+', row .. ' = ' .. val)
		txt = txt .. row .. ' = ' .. val .. '\n'
	end
	return str, txt
end

function f_saveCfg()
	-- Data saving to data_sav.lua
	local t_saves = {
		['data.lifeMul'] = data.lifeMul,
		['data.team1VS2Life'] = data.team1VS2Life,
		['data.turnsRecoveryRate'] = data.turnsRecoveryRate,
		['data.teamLifeShare'] = data.teamLifeShare,
		['data.zoomActive'] = data.zoomActive,
		['data.zoomMin'] = data.zoomMin,
		['data.zoomMax'] = data.zoomMax,
		['data.zoomSpeed'] = data.zoomSpeed,
		['data.roundTime'] = data.roundTime,
		['data.numTurns'] = data.numTurns,
		['data.numSimul'] = data.numSimul,
		['data.simulType'] = data.simulType,
		['data.p1Controller'] = data.p1Controller,
		['data.p2Controller'] = data.p2Controller,
		['data.difficulty'] = data.difficulty,
		['data.coins'] = data.coins,
		['data.contSelection'] = data.contSelection,
		['data.aiRamping'] = data.aiRamping,
		['data.autoguard'] = data.autoguard,
		['data.lifebar'] = data.lifebar,
		['data.sffConversion'] = data.sffConversion
	}
	s_dataLUA = f_strSub(s_dataLUA, t_saves)
	local file = io.open("script/data_sav.lua","w+")
	file:write(s_dataLUA)
	file:close()
	-- Data saving to config.ssz
	if b_saveMemory then
		s_saveMemory = s_saveMemory:gsub('const bool SaveMemory%s*=%s*[^;%s]+', 'const bool SaveMemory = true')
	else
		s_saveMemory = s_saveMemory:gsub('const bool SaveMemory%s*=%s*[^;%s]+', 'const bool SaveMemory = false')
	end
	if b_openGL then
		s_configSSZ = s_configSSZ:gsub('const bool OpenGL%s*=%s*[^;%s]+', 'const bool OpenGL = true')
	else
		s_configSSZ = s_configSSZ:gsub('const bool OpenGL%s*=%s*[^;%s]+', 'const bool OpenGL = false')
	end
	s_configSSZ = s_configSSZ:gsub('const int Width%s*=%s*%d+', 'const int Width = ' .. resolutionWidth)
	s_configSSZ = s_configSSZ:gsub('const int Height%s*=%s*%d+', 'const int Height = ' .. resolutionHeight)
	s_configSSZ = s_configSSZ:gsub('const int GameSpeed%s*=%s*%d+', 'const int GameSpeed = ' .. gameSpeed)
	local file = io.open("ssz/config.ssz","w+")
	file:write(s_configSSZ)
	file:close()
	-- Data saving to sound.ssz
	s_soundSSZ = s_soundSSZ:gsub('const int Freq%s*=%s*%d+', 'const int Freq = ' .. freq)
	s_soundSSZ = s_soundSSZ:gsub('const int Channels%s*=%s*%d+', 'const int Channels = ' .. channels)
	s_soundSSZ = s_soundSSZ:gsub('const int BufferSamples%s*=%s*%d+', 'const int BufferSamples = ' .. buffer)
	local file = io.open("lib/sound.ssz","w+")
	file:write(s_soundSSZ)
	file:close()
	-- Data saving to lifebar
	s_lifebarDEF = s_lifebarDEF:gsub('match.wins%s*=%s*%d+', 'match.wins = ' .. roundsNum)
	local file = io.open(data.lifebar,"w+")
	file:write(s_lifebarDEF)
	file:close()
	-- Reload lifebar
	loadLifebar(data.lifebar)
	-- Reload game if needed
	if needReload == 1 then
		os.execute("reload.bat")
		os.exit()
	end
end

--;===========================================================
--; MAIN LOOP
--;===========================================================
txt_mainCfg = createTextImg(jgFnt, 0, 0, 'OPTIONS', 159, 13)
t_mainCfg = {
	{id = '', text = 'Life',               varID = textImgNew(), varText = data.lifeMul .. '%'},
	{id = '', text = 'Game Speed',         varID = textImgNew(), varText = s_gameSpeed},
	{id = '', text = 'Rounds to Win',      varID = textImgNew(), varText = roundsNum},
	{id = '', text = 'Round Time',         varID = textImgNew(), varText = data.roundTime},
	{id = '', text = 'Port Change',        varID = textImgNew(), varText = getListenPort()},
	{id = '', text = 'Gameplay Settings'},
	{id = '', text = 'Team Settings'},
	{id = '', text = 'Audio Settings'},
	{id = '', text = 'Video Settings'},
	{id = '', text = 'Zoom Settings'},
	{id = '', text = 'Input Settings'},
	{id = '', text = 'Default Values'},
	{id = '', text = 'Back'},
}
for i=1, #t_mainCfg do
	t_mainCfg[i].id = createTextImg(font2, 0, 1, t_mainCfg[i].text, 85, 15+i*15)
end

function f_mainCfg()
	cmdInput()
	local mainCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			if modified == 1 then
				f_saveCfg()
			end
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			mainCfg = mainCfg - 1
			if mainCfg < 1 then mainCfg = #t_mainCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			mainCfg = mainCfg + 1
			if mainCfg > #t_mainCfg then mainCfg = 1 end
		--Life
		elseif mainCfg == 1 then
			if commandGetState(p1Cmd, 'r') and data.lifeMul < 300 then
				sndPlay(sysSnd, 100, 0)
				data.lifeMul = data.lifeMul + 10
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.lifeMul > 10 then
				sndPlay(sysSnd, 100, 0)
				data.lifeMul = data.lifeMul - 10
				modified = 1
			end
		--Game Speed
		elseif mainCfg == 2 then
			if commandGetState(p1Cmd, 'r') and gameSpeed < 72 then
				sndPlay(sysSnd, 100, 0)
				if gameSpeed < 48 then
					gameSpeed = 48
					s_gameSpeed = '80%'
				elseif gameSpeed < 56 then
					gameSpeed = 56
					s_gameSpeed = '93.33%'
				elseif gameSpeed < 60 then
					gameSpeed = 60
					s_gameSpeed = '100%'
				elseif gameSpeed < 64 then
					gameSpeed = 64
					s_gameSpeed = '106.66%'
				elseif gameSpeed < 72 then
					gameSpeed = 72
					s_gameSpeed = '120%'
				end
				modified = 1
				needReload = 1
			elseif commandGetState(p1Cmd, 'l') and gameSpeed > 48 then
				sndPlay(sysSnd, 100, 0)
				if gameSpeed >= 72 then
					gameSpeed = 64
					s_gameSpeed = '106.66%'
				elseif gameSpeed >= 64 then
					gameSpeed = 60
					s_gameSpeed = '100%'
				elseif gameSpeed >= 60 then
					gameSpeed = 56
					s_gameSpeed = '93.33%'
				elseif gameSpeed >= 56 then
					gameSpeed = 48
					s_gameSpeed = '80%'
				end
				modified = 1
				needReload = 1
			end
		--Rounds to Win
		elseif mainCfg == 3 then
			if commandGetState(p1Cmd, 'r') and roundsNum < 10 then
				sndPlay(sysSnd, 100, 0)
				roundsNum = roundsNum + 1
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and roundsNum > 1 then
				sndPlay(sysSnd, 100, 0)
				roundsNum = roundsNum - 1
				modified = 1
			end
		--Round Time
		elseif mainCfg == 4 then
			if commandGetState(p1Cmd, 'r') and data.roundTime < 1000 then
				sndPlay(sysSnd, 100, 0)
				data.roundTime = data.roundTime + 1
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.roundTime > -2 then
				sndPlay(sysSnd, 100, 0)
				data.roundTime = data.roundTime - 1
				modified = 1
			end
		--Port Change
		elseif mainCfg == 5 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 1)
			inputDialogPopup(inputdia, 'Input Port')
			while not inputDialogIsDone(inputdia) do
				animDraw(f_animVelocity(optionsBG0, -1, -1))
				refresh()
			end
			setListenPort(inputDialogGetStr(inputdia))
			modified = 1
		elseif btnPalNo(p1Cmd) > 0 then
			--Gameplay Settings
			if mainCfg == 6 then
				sndPlay(sysSnd, 100, 1)
				f_modesCfg()
			--Team Settings
			elseif mainCfg == 7 then
				sndPlay(sysSnd, 100, 1)
				f_teamCfg()
			--Audio Settings
			elseif mainCfg == 8 then
				sndPlay(sysSnd, 100, 1)
				f_audioCfg()
			--Video Settings
			elseif mainCfg == 9 then
				sndPlay(sysSnd, 100, 1)
				f_videoCfg()
			--Zoom Settings
			elseif mainCfg == 10 then
				sndPlay(sysSnd, 100, 1)
				f_zoomCfg()
			--Input Settings
			elseif mainCfg == 11 then
				sndPlay(sysSnd, 100, 1)
				f_inputCfg()
			--Default Values
			elseif mainCfg == 12 then
				sndPlay(sysSnd, 100, 1)
				--saves.ini
				data.lifeMul = 100
				data.team1VS2Life = 120
				data.turnsRecoveryRate = 300
				data.teamLifeShare = false
				s_teamLifeShare = 'No'
				data.zoomActive = true
				s_zoomActive = 'Yes'
				data.zoomMin = 0.75
				data.zoomMax = 1.1
				data.zoomSpeed = 1.0
				data.roundTime = 99
				data.numTurns = 4
				data.numSimul = 4
				data.simulType = 'Assist'
				data.difficulty = 8
				data.coins = 10
				data.contSelection = true
				s_contSelection = 'Yes'
				data.aiRamping = true
				s_aiRamping = 'Yes'
				data.autoguard = false
				s_autoguard = 'No'
				data.lifebar = 'data/gms_lifebar/fight.def'
				data.sffConversion = true
				--config.ssz
				f_inputDefault()
				b_saveMemory = false
				s_saveMemory = 'No'
				b_openGL = true
				s_openGL = 'Yes'
				resolutionWidth = 960
				resolutionHeight = 720
				gameSpeed = 60
				s_gameSpeed = '100%'
				--sound.ssz
				freq = 48000
				channels = 2
				s_channels = 'stereo'
				buffer = 2048
				--lifebar
				roundsNum = 2
				--other
				setListenPort(7500)
				modified = 1
				needReload = 1
			--Back
			else
				sndPlay(sysSnd, 100, 2)
				if modified == 1 then
					f_saveCfg()
				end
				break
			end
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_mainCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_mainCfg)
		t_mainCfg[1].varText = data.lifeMul .. '%'
		t_mainCfg[2].varText = s_gameSpeed
		t_mainCfg[3].varText = roundsNum
		t_mainCfg[4].varText = data.roundTime
		t_mainCfg[5].varText = getListenPort()
		for i=1, #t_mainCfg do
			textImgDraw(t_mainCfg[i].id)
			if t_mainCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_mainCfg[i].varID, font2, 0, -1, t_mainCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+mainCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

function f_inputDefault()
	if data.p1Controller ~= -1 then
		data.p1Controller = -1
		s_p1Controller = 'Keyboard'
		f_swapController(0, 2, 0, -1)
	end
	if data.p2Controller ~= -1 then
		data.p2Controller = -1
		s_p2Controller = 'Keyboard'
		f_swapController(1, 3, 1, -1)
	end
	t_keyCfg[1].varText = 'UP'
	t_keyCfg[2].varText = 'DOWN'
	t_keyCfg[3].varText = 'LEFT'
	t_keyCfg[4].varText = 'RIGHT'
	t_keyCfg[5].varText = 'z'
	t_keyCfg[6].varText = 'x'
	t_keyCfg[7].varText = 'c'
	t_keyCfg[8].varText = 'a'
	t_keyCfg[9].varText = 's'
	t_keyCfg[10].varText = 'd'
	t_keyCfg[11].varText = 'RETURN'
	f_keySave(0,-1)
	t_keyCfg[1].varText = 't'
	t_keyCfg[2].varText = 'g'
	t_keyCfg[3].varText = 'f'
	t_keyCfg[4].varText = 'h'
	t_keyCfg[5].varText = 'j'
	t_keyCfg[6].varText = 'k'
	t_keyCfg[7].varText = 'l'
	t_keyCfg[8].varText = 'i'
	t_keyCfg[9].varText = 'o'
	t_keyCfg[10].varText = 'p'
	t_keyCfg[11].varText = 'q'
	f_keySave(1,-1)
	t_keyCfg[1].varText = '-7'
	t_keyCfg[2].varText = '-8'
	t_keyCfg[3].varText = '-5'
	t_keyCfg[4].varText = '-6'
	t_keyCfg[5].varText = '0'
	t_keyCfg[6].varText = '1'
	t_keyCfg[7].varText = '4'
	t_keyCfg[8].varText = '2'
	t_keyCfg[9].varText = '3'
	t_keyCfg[10].varText = '5'
	t_keyCfg[11].varText = '7'
	f_keySave(2,0)
	t_keyCfg[1].varText = '-7'
	t_keyCfg[2].varText = '-8'
	t_keyCfg[3].varText = '-5'
	t_keyCfg[4].varText = '-6'
	t_keyCfg[5].varText = '0'
	t_keyCfg[6].varText = '1'
	t_keyCfg[7].varText = '4'
	t_keyCfg[8].varText = '2'
	t_keyCfg[9].varText = '3'
	t_keyCfg[10].varText = '5'
	t_keyCfg[11].varText = '7'
	f_keySave(3,1)
end

--;===========================================================
--; GAMEPLAY SETTINGS
--;===========================================================
txt_modesCfg = createTextImg(jgFnt, 0, 0, 'GAMEPLAY SETTINGS', 159, 13)
t_modesCfg = {
	{id = '', text = 'Difficulty level',         varID = textImgNew(), varText = data.difficulty},
	{id = '', text = 'Arcade Coins',             varID = textImgNew(), varText = data.coins},
	{id = '', text = 'Char change at Continue',  varID = textImgNew(), varText = s_contSelection},
	{id = '', text = 'AI ramping',               varID = textImgNew(), varText = s_aiRamping},
	{id = '', text = 'Auto-Guard',               varID = textImgNew(), varText = s_autoguard},
	{id = '', text = 'Back'},
}
for i=1, #t_modesCfg do
	t_modesCfg[i].id = createTextImg(font2, 0, 1, t_modesCfg[i].text, 85, 15+i*15)
end

function f_modesCfg()
	cmdInput()
	local modesCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			modesCfg = modesCfg - 1
			if modesCfg < 1 then modesCfg = #t_modesCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			modesCfg = modesCfg + 1
			if modesCfg > #t_modesCfg then modesCfg = 1 end
		--Difficulty level
		elseif modesCfg == 1 then
			if commandGetState(p1Cmd, 'r') and data.difficulty < 8 then
				sndPlay(sysSnd, 100, 0)
				data.difficulty = data.difficulty + 1
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.difficulty > 1 then
				sndPlay(sysSnd, 100, 0)
				data.difficulty = data.difficulty - 1
				modified = 1
			end
		--Arcade Coins
		elseif modesCfg == 2 then
			if commandGetState(p1Cmd, 'r') and data.coins < 99 then
				sndPlay(sysSnd, 100, 0)
				data.coins = data.coins + 1
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.coins > 1 then
				sndPlay(sysSnd, 100, 0)
				data.coins = data.coins - 1
				modified = 1
			end
		--Char change at Continue
		elseif modesCfg == 3 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if data.contSelection then
				data.contSelection = false
				s_contSelection = 'No'
			else
				data.contSelection = true
				s_contSelection = 'Yes'
			end
			modified = 1
		--AI ramping
		elseif modesCfg == 4 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if data.aiRamping then
				data.aiRamping = false
				s_aiRamping = 'No'
			else
				data.aiRamping = true
				s_aiRamping = 'Yes'
			end
			modified = 1
		--Auto-Guard
		elseif modesCfg == 5 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if data.autoguard then
				data.autoguard = false
				s_autoguard = 'No'
			else
				data.autoguard = true
				s_autoguard = 'Yes'
			end
			modified = 1
		--Back
		elseif modesCfg == 6 and btnPalNo(p1Cmd) > 0 then
			sndPlay(sysSnd, 100, 2)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_modesCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_modesCfg)
		t_modesCfg[1].varText = data.difficulty
		t_modesCfg[2].varText = data.coins
		t_modesCfg[3].varText = s_contSelection
		t_modesCfg[4].varText = s_aiRamping
		t_modesCfg[5].varText = s_autoguard
		for i=1, #t_modesCfg do
			textImgDraw(t_modesCfg[i].id)
			if t_modesCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_modesCfg[i].varID, font2, 0, -1, t_modesCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+modesCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; TEAM SETTINGS
--;===========================================================
txt_teamCfg = createTextImg(jgFnt, 0, 0, 'TEAM SETTINGS', 159, 13)
t_teamCfg = {
	{id = '', text = '1P Vs Team Life',         varID = textImgNew(), varText = data.team1VS2Life},
	{id = '', text = 'Turns HP Recovery',       varID = textImgNew(), varText = data.turnsRecoveryRate},
	{id = '', text = 'Disadvantage Life Share', varID = textImgNew(), varText = s_teamLifeShare},
	{id = '', text = 'Turns Limit',             varID = textImgNew(), varText = data.numTurns},
	{id = '', text = 'Simul Limit',             varID = textImgNew(), varText = data.numSimul},
	{id = '', text = 'Simul Type',              varID = textImgNew(), varText = data.simulType},
	{id = '', text = 'Back'},
}
for i=1, #t_teamCfg do
	t_teamCfg[i].id = createTextImg(font2, 0, 1, t_teamCfg[i].text, 85, 15+i*15)
end

function f_teamCfg()
	cmdInput()
	local teamCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			teamCfg = teamCfg - 1
			if teamCfg < 1 then teamCfg = #t_teamCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			teamCfg = teamCfg + 1
			if teamCfg > #t_teamCfg then teamCfg = 1 end
		--1P Vs Team Life
		elseif teamCfg == 1 then
			if commandGetState(p1Cmd, 'r') and data.team1VS2Life < 3000 then
				sndPlay(sysSnd, 100, 0)
				data.team1VS2Life = data.team1VS2Life + 10
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.team1VS2Life > 10 then
				sndPlay(sysSnd, 100, 0)
				data.team1VS2Life = data.team1VS2Life - 10
				modified = 1
			end
		--Turns HP Recovery
		elseif teamCfg == 2 then
			if commandGetState(p1Cmd, 'r') and data.turnsRecoveryRate < 3000 then
				sndPlay(sysSnd, 100, 0)
				data.turnsRecoveryRate = data.turnsRecoveryRate + 10
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.turnsRecoveryRate > 10 then
				sndPlay(sysSnd, 100, 0)
				data.turnsRecoveryRate = data.turnsRecoveryRate - 10
				modified = 1
			end
		--Disadvantage Life Share
		elseif teamCfg == 3 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if data.teamLifeShare then
				data.teamLifeShare = false
				s_teamLifeShare = 'No'
			else
				data.teamLifeShare = true
				s_teamLifeShare = 'Yes'
			end
			modified = 1
		--Turns Limit (by default also requires editing 'if(!.m.inRange!int?(1, 4, nt)){' in ssz/system-script.ssz)
		elseif teamCfg == 4 then
			if commandGetState(p1Cmd, 'r') and data.numTurns < 10 then
				sndPlay(sysSnd, 100, 0)
				data.numTurns = data.numTurns + 1
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.numTurns > 1 then
				sndPlay(sysSnd, 100, 0)
				data.numTurns = data.numTurns - 1
				modified = 1
			end
		--Simul Limit (by default also requires editing 'const int maxSimul = 4;' in ssz/common.ssz)
		elseif teamCfg == 5 then
			if commandGetState(p1Cmd, 'r') and data.numSimul < 10 then
				sndPlay(sysSnd, 100, 0)
				data.numSimul = data.numSimul + 1
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.numSimul > 1 then
				sndPlay(sysSnd, 100, 0)
				data.numSimul = data.numSimul - 1
				modified = 1
			end
		--Simul Type
		elseif teamCfg == 6 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if data.simulType == 'Tag' then
				data.simulType = 'Assist'
			else
				data.simulType = 'Tag'
			end
			modified = 1
		--Back
		elseif teamCfg == 7 and btnPalNo(p1Cmd) > 0 then
			sndPlay(sysSnd, 100, 2)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_teamCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_teamCfg)
		t_teamCfg[1].varText = data.team1VS2Life
		t_teamCfg[2].varText = data.turnsRecoveryRate
		t_teamCfg[3].varText = s_teamLifeShare
		t_teamCfg[4].varText = data.numTurns
		t_teamCfg[5].varText = data.numSimul
		t_teamCfg[6].varText = data.simulType
		for i=1, #t_teamCfg do
			textImgDraw(t_teamCfg[i].id)
			if t_teamCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_teamCfg[i].varID, font2, 0, -1, t_teamCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+teamCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; AUDIO SETTINGS
--;===========================================================
txt_audioCfg = createTextImg(jgFnt, 0, 0, 'AUDIO SETTINGS', 159, 13)
t_audioCfg = {
	{id = '', text = 'Sample Rate',    varID = textImgNew(), varText = freq},
	{id = '', text = 'Channels',       varID = textImgNew(), varText = s_channels},
	{id = '', text = 'Buffer Samples', varID = textImgNew(), varText = buffer},
	{id = '', text = 'Back'},
}
for i=1, #t_audioCfg do
	t_audioCfg[i].id = createTextImg(font2, 0, 1, t_audioCfg[i].text, 85, 15+i*15)
end

function f_audioCfg()
	cmdInput()
	local audioCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			audioCfg = audioCfg - 1
			if audioCfg < 1 then audioCfg = #t_audioCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			audioCfg = audioCfg + 1
			if audioCfg > #t_audioCfg then audioCfg = 1 end
		--Sample Rate
		elseif audioCfg == 1 then
			if commandGetState(p1Cmd, 'r') and  freq < 96000 then
				sndPlay(sysSnd, 100, 0)
				if freq < 22050 then
					freq = 22050
				elseif freq < 44100 then
					freq = 44100
				elseif freq < 48000 then
					freq = 48000
				elseif freq < 64000 then
					freq = 64000
				elseif freq < 88200 then
					freq = 88200
				elseif freq < 96000 then
					freq = 96000
				end
				modified = 1
				needReload = 1
			elseif commandGetState(p1Cmd, 'l') and freq >= 22050 then
				sndPlay(sysSnd, 100, 0)
				if freq >= 96000 then
					freq = 88200
				elseif freq >= 88200 then
					freq = 64000
				elseif freq >= 64000 then
					freq = 48000
				elseif freq >= 48000 then
					freq = 44100
				elseif freq >= 44100 then
					freq = 22050
				elseif freq >= 22050 then
					freq = 11025
				end
				modified = 1
				needReload = 1
			end
		--Channels
		elseif audioCfg == 2 then
			if commandGetState(p1Cmd, 'r') and  channels < 6 then
				sndPlay(sysSnd, 100, 0)
				if channels < 2 then
					channels = 2
					s_channels = 'stereo'
				elseif channels < 4 then
					channels = 4
					s_channels = 'quad'
				elseif channels < 6 then
					channels = 6
					s_channels = '5.1'
				end
				modified = 1
				needReload = 1
			elseif commandGetState(p1Cmd, 'l') and channels >= 2 then
				sndPlay(sysSnd, 100, 0)
				if channels >= 6 then
					channels = 4
					s_channels = 'quad'
				elseif channels >= 4 then
					channels = 2
					s_channels = 'stereo'
				elseif channels >= 2 then
					channels = 1
					s_channels = 'mono'
				end
				modified = 1
				needReload = 1
			end
		--Buffer Samples
		elseif audioCfg == 3 then
			if commandGetState(p1Cmd, 'r') and buffer < 8192 then
				sndPlay(sysSnd, 100, 0)
				buffer = buffer * 2
				modified = 1
				needReload = 1
			elseif commandGetState(p1Cmd, 'l') and buffer >= 1024 then
				sndPlay(sysSnd, 100, 0)
				buffer = buffer / 2
				modified = 1
				needReload = 1
			end
		--Back
		elseif audioCfg == 4 and btnPalNo(p1Cmd) > 0 then
			sndPlay(sysSnd, 100, 2)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_audioCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_audioCfg)
		t_audioCfg[1].varText = freq
		t_audioCfg[2].varText = s_channels
		t_audioCfg[3].varText = buffer
		for i=1, #t_audioCfg do
			textImgDraw(t_audioCfg[i].id)
			if t_audioCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_audioCfg[i].varID, font2, 0, -1, t_audioCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+audioCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; VIDEO SETTINGS
--;===========================================================
txt_videoCfg = createTextImg(jgFnt, 0, 0, 'VIDEO SETTINGS', 159, 13)
t_videoCfg = {
	{id = '', text = 'Resolution',  varID = textImgNew(), varText = resolutionWidth .. 'x' .. resolutionHeight},
	{id = '', text = 'OpeanGL 2.0', varID = textImgNew(), varText = s_openGL},
	{id = '', text = 'Save memory', varID = textImgNew(), varText = s_saveMemory},
	{id = '', text = 'Back'},
}
for i=1, #t_videoCfg do
	t_videoCfg[i].id = createTextImg(font2, 0, 1, t_videoCfg[i].text, 85, 15+i*15)
end

function f_videoCfg()
	cmdInput()
	local videoCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			videoCfg = videoCfg - 1
			if videoCfg < 1 then videoCfg = #t_videoCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			videoCfg = videoCfg + 1
			if videoCfg > #t_videoCfg then videoCfg = 1 end
		--Resolution
		elseif videoCfg == 1 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			f_resCfg()
		--OpeanGL 2.0
		elseif videoCfg == 2 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if b_openGL == false then
				b_openGL = true
				s_openGL = 'Yes'
				f_glWarning()
			else
				b_openGL = false
				s_openGL = 'No'
			end
			modified = 1
			needReload = 1
		--Save memory
		elseif videoCfg == 3 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if b_saveMemory == false then
				b_saveMemory = true
				s_saveMemory = 'Yes'
				f_memWarning()
			else
				b_saveMemory = false
				s_saveMemory = 'No'
				f_memWarning()
			end
			modified = 1
			needReload = 1
		--Back
		elseif videoCfg == 4 and btnPalNo(p1Cmd) > 0 then
			sndPlay(sysSnd, 100, 2)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_videoCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_videoCfg)
		t_videoCfg[1].varText = resolutionWidth .. 'x' .. resolutionHeight
		t_videoCfg[2].varText = s_openGL
		t_videoCfg[3].varText = s_saveMemory
		for i=1, #t_videoCfg do
			textImgDraw(t_videoCfg[i].id)
			if t_videoCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_videoCfg[i].varID, font2, 0, -1, t_videoCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+videoCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

txt_Warning = createTextImg(jgFnt, 0, 0, 'WARNING', 159, 13)
t_glWarning = {
	{id = '', text = "You won't be able to start the game if your system"},
	{id = '', text = "doesn't support OpenGL 2.0 or later."},
	{id = '', text = "In such case you will need to edit ssz/config.ssz:"},
	{id = '', text = "const bool OpenGL = false"},
}
for i=1, #t_glWarning do
	t_glWarning[i].id = createTextImg(font2, 0, 1, t_glWarning[i].text, 25, 15+i*15)
end
function f_glWarning()
	cmdInput()
	while true do
		if btnPalNo(p1Cmd) > 0 or esc() then
			sndPlay(sysSnd, 100, 0)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 20,20, 280,#t_glWarning*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_Warning)
		for i=1, #t_glWarning do
			textImgDraw(t_glWarning[i].id)
		end
		cmdInput()
		refresh()
	end
end

t_memWarning = {
	{id = '', text = "Enabling 'Save memory' option negatively affects FPS."},
	{id = '', text = "It's not yet known if disabling it has any drawbacks."},
}
for i=1, #t_memWarning do
	t_memWarning[i].id = createTextImg(font2, 0, 1, t_memWarning[i].text, 25, 15+i*15)
end
function f_memWarning()
	cmdInput()
	while true do
		if btnPalNo(p1Cmd) > 0 or esc() then
			sndPlay(sysSnd, 100, 0)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 20,20, 280,#t_memWarning*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_Warning)
		for i=1, #t_memWarning do
			textImgDraw(t_memWarning[i].id)
		end
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; RESOLUTION SETTINGS
--;===========================================================
txt_resCfg = createTextImg(jgFnt, 0, 0, 'RESOLUTION SETTINGS', 159, 13)
t_resCfg = {
	{id = '', x = 320,  y = 240,  text = '320x240     (4:3 QVGA)'},
	{id = '', x = 640,  y = 480,  text = '640x480     (4:3 VGA)'},
	{id = '', x = 800,  y = 600,  text = '800x600     (4:3 SVGA)'},
	{id = '', x = 1024, y = 768,  text = '1024x768    (4:3 XGA)'},
	{id = '', x = 1152, y = 864,  text = '1152x864    (4:3 XGA+)'},
	{id = '', x = 1280, y = 960,  text = '1280x960    (4:3 Quad-VGA)'},
	{id = '', x = 1600, y = 1200, text = '1600x1200   (4:3 UXGA)'},
	{id = '', x = 960,  y = 720,  text = '960x720     (4:3 HD)'},
	{id = '', x = 1200, y = 900,  text = '1200x900    (4:3 HD+)'},
	{id = '', x = 1440, y = 1080, text = '1440x1080   (4:3 FHD)'},
	{id = '', x = 1280, y = 720,  text = '1280x720    (16:9 HD)'},
	{id = '', x = 1600, y = 900,  text = '1600x900    (16:9 HD+)'},
	{id = '', x = 1920, y = 1080, text = '1920x1080   (16:9 FHD)'},
	{id = '', x = 2560, y = 1440, text = '2560x1440   (16:9 2K)'},
	{id = '', x = 3840, y = 2160, text = '3840x2160   (16:9 4K)'},
	{id = '', x = 1280, y = 800,  text = '1280x800    (16:10 WXGA)'},
	{id = '', x = 1440, y = 900,  text = '1440x900    (16:10 WXGA+)'},
	{id = '', x = 1680, y = 1050, text = '1680x1050   (16:10 WSXGA+)'},
	{id = '', x = 1920, y = 1200, text = '1920x1200   (16:10 WUXGA)'},
	{id = '', x = 2560, y = 1600, text = '2560x1600   (16:10 WQXGA)'},
	{id = '', x = 400,  y = 254,  text = '400x254     (arcade)'},
	{id = '', x = 800,  y = 508,  text = '400x508     (arcade x2)'},
	{id = '', x = 1200, y = 762,  text = '1200x762    (arcade x3)'},
	{id = '', x = 1600, y = 1016, text = '1600x1016   (arcade x4)'},
	{id = '', text = 'Back'},
}
for i=1, #t_resCfg do
	t_resCfg[i].id = createTextImg(font2, 0, 1, t_resCfg[i].text, 85, 15+i*15)
end

function f_resCfg()
	cmdInput()
	local cursorPosY = 1
	local moveTxt = 0
	local resCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			resCfg = resCfg - 1
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			resCfg = resCfg + 1
		end
		--Cursor position calculation
		if resCfg < 1 then
			resCfg = #t_resCfg
			if #t_resCfg > 14 then
				cursorPosY = 14
			else
				cursorPosY = #t_resCfg
			end
		elseif resCfg > #t_resCfg then
			resCfg = 1
			cursorPosY = 1
		elseif commandGetState(p1Cmd, 'u') and cursorPosY > 1 then
			cursorPosY = cursorPosY - 1
		elseif commandGetState(p1Cmd, 'd') and cursorPosY < 14 then
			cursorPosY = cursorPosY + 1
		end
		if cursorPosY == 14 then
			moveTxt = (resCfg - 14) * 15
		elseif cursorPosY == 1 then
			moveTxt = (resCfg - 1) * 15
		end
		--Options
		if btnPalNo(p1Cmd) > 0 then
			--Back
			if resCfg == #t_resCfg then
				sndPlay(sysSnd, 100, 2)
				break
			--Resolution
			else
				sndPlay(sysSnd, 100, 0)
				resolutionWidth = t_resCfg[resCfg].x
				resolutionHeight = t_resCfg[resCfg].y
				if (resolutionHeight / 3 * 4) ~= resolutionWidth then
					f_resWarning()
				end
				modified = 1
				needReload = 1
				break
			end
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		if #t_resCfg > 14 and moveTxt == (#t_resCfg - 14) * 15 then
			animSetWindow(optionsBG1, 80,20, 160,14*15)
		else
			animSetWindow(optionsBG1, 80,20, 160,#t_resCfg*15)
		end
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_resCfg)
		for i=1, #t_resCfg do
			if i > resCfg - cursorPosY then
				textImgDraw(f_updateTextImg(t_resCfg[i].id, font2, 0, 1, t_resCfg[i].text, 85, 15+i*15-moveTxt))
			end
		end
		animSetWindow(cursorBox, 80,5+cursorPosY*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

t_resWarning = {
	{id = '', text = "Non 4:3 resolutions requires stages coded for different"},
	{id = '', text = "aspect ratio. Change it back to 4:3 if stages look off."},
}
for i=1, #t_resWarning do
	t_resWarning[i].id = createTextImg(font2, 0, 1, t_resWarning[i].text, 25, 15+i*15)
end
function f_resWarning()
	cmdInput()
	while true do
		if btnPalNo(p1Cmd) > 0 or esc() then
			sndPlay(sysSnd, 100, 0)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 20,20, 280,#t_resWarning*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_Warning)
		for i=1, #t_resWarning do
			textImgDraw(t_resWarning[i].id)
		end
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; ZOOM SETTINGS
--;===========================================================
txt_zoomCfg = createTextImg(jgFnt, 0, 0, 'ZOOM SETTINGS', 159, 13)
t_zoomCfg = {
	{id = '', text = 'Zoom Active',  varID = textImgNew(), varText = s_zoomActive},
	{id = '', text = 'Max Zoom Out', varID = textImgNew(), varText = data.zoomMin},
	{id = '', text = 'Max Zoom In',  varID = textImgNew(), varText = data.zoomMax},
	{id = '', text = 'Zoom Speed',   varID = textImgNew(), varText = data.zoomSpeed},
	{id = '', text = 'Back'},
}
for i=1, #t_zoomCfg do
	t_zoomCfg[i].id = createTextImg(font2, 0, 1, t_zoomCfg[i].text, 85, 15+i*15)
end

function f_zoomCfg()
	cmdInput()
	local zoomCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			zoomCfg = zoomCfg - 1
			if zoomCfg < 1 then zoomCfg = #t_zoomCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			zoomCfg = zoomCfg + 1
			if zoomCfg > #t_zoomCfg then zoomCfg = 1 end
		--Zoom Active
		elseif zoomCfg == 1 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			sndPlay(sysSnd, 100, 0)
			if data.zoomActive then
				data.zoomActive = false
				s_zoomActive = 'No'
			else
				data.zoomActive = true
				s_zoomActive = 'Yes'
			end
			modified = 1
		--Max Zoom Out
		elseif zoomCfg == 2 and data.zoomMin < 10 then
			if commandGetState(p1Cmd, 'r') then
				sndPlay(sysSnd, 100, 0)
				data.zoomMin = data.zoomMin + 0.05
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.zoomMin > 0.05 then
				sndPlay(sysSnd, 100, 0)
				data.zoomMin = data.zoomMin - 0.05
				modified = 1
			end
		--Max Zoom In
		elseif zoomCfg == 3 then
			if commandGetState(p1Cmd, 'r') and data.zoomMax < 10 then
				sndPlay(sysSnd, 100, 0)
				data.zoomMax = data.zoomMax + 0.05
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.zoomMax > 0.05 then
				sndPlay(sysSnd, 100, 0)
				data.zoomMax = data.zoomMax - 0.05
				modified = 1
			end
		--Zoom Speed
		elseif zoomCfg == 4 then
			if commandGetState(p1Cmd, 'r') and data.zoomSpeed < 10 then
				sndPlay(sysSnd, 100, 0)
				data.zoomSpeed = data.zoomSpeed + 0.1
				modified = 1
			elseif commandGetState(p1Cmd, 'l') and data.zoomSpeed > 0.1 then
				sndPlay(sysSnd, 100, 0)
				data.zoomSpeed = data.zoomSpeed - 0.1
				modified = 1
			end
		--Back
		elseif zoomCfg == 5 and btnPalNo(p1Cmd) > 0 then
			sndPlay(sysSnd, 100, 2)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_zoomCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_zoomCfg)
		t_zoomCfg[1].varText = s_zoomActive
		t_zoomCfg[2].varText = data.zoomMin
		t_zoomCfg[3].varText = data.zoomMax
		t_zoomCfg[4].varText = data.zoomSpeed
		for i=1, #t_zoomCfg do
			textImgDraw(t_zoomCfg[i].id)
			if t_zoomCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_zoomCfg[i].varID, font2, 0, -1, t_zoomCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+zoomCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; INPUT SETTINGS
--;===========================================================
txt_inputCfg = createTextImg(jgFnt, 0, 0, 'INPUT SETTINGS', 159, 13)
t_inputCfg = {
	{id = '', text = 'P1 Keyboard'},
	{id = '', text = 'P1 Gamepad'},
	{id = '', text = 'P2 Keyboard'},
	{id = '', text = 'P2 Gamepad'},
	{id = '', text = 'P1 Controller', varID = textImgNew(), varText = s_p1Controller},
	{id = '', text = 'P2 Controller', varID = textImgNew(), varText = s_p2Controller},
	{id = '', text = 'Default Values'},
	{id = '', text = 'Back'},
}
for i=1, #t_inputCfg do
	t_inputCfg[i].id = createTextImg(font2, 0, 1, t_inputCfg[i].text, 85, 15+i*15)
end

function f_inputCfg()
	cmdInput()
	local inputCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		end
		if commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			inputCfg = inputCfg - 1
			if inputCfg < 1 then inputCfg = #t_inputCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			inputCfg = inputCfg + 1
			if inputCfg > #t_inputCfg then inputCfg = 1 end
		--P1 Controller
		elseif inputCfg == 5 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			if data.p1Controller == -1 then
				sndPlay(sysSnd, 100, 0)
				data.p1Controller = 0
				s_p1Controller = 'Gamepad'
				f_swapController(0, 2, -1, 0)
			else
				sndPlay(sysSnd, 100, 0)
				data.p1Controller = -1
				s_p1Controller = 'Keyboard'
				f_swapController(0, 2, 0, -1)
			end
			f_cmdWarning()
			modified = 1
			needReload = 1
		--P2 Controller
		elseif inputCfg == 6 and (commandGetState(p1Cmd, 'r') or commandGetState(p1Cmd, 'l') or btnPalNo(p1Cmd) > 0) then
			if data.p2Controller == -1 then
				sndPlay(sysSnd, 100, 0)
				data.p2Controller = 1
				s_p2Controller = 'Gamepad'
				f_swapController(1, 3, -1, 1)
			else
				sndPlay(sysSnd, 100, 0)
				data.p2Controller = -1
				s_p2Controller = 'Keyboard'
				f_swapController(1, 3, 1, -1)
			end
			f_cmdWarning()
			modified = 1
			needReload = 1
		elseif btnPalNo(p1Cmd) > 0 then
			--P1 Keyboard
			if inputCfg == 1 then
				sndPlay(sysSnd, 100, 0)
				if data.p1Controller == -1 then
					f_keyRead(0, -1)
					f_keyCfg(0, -1)
				else
					f_keyRead(2, -1)
					f_keyCfg(2, -1)
				end
			--P1 Gamepad
			elseif inputCfg == 2 then
				sndPlay(sysSnd, 100, 0)
				if data.p1Controller == -1 then
					f_padRead(2, 0)
					f_keyCfg(2, 0)
				else
					f_padRead(0, 0)
					f_keyCfg(0, 0)
				end
			--P2 Keyboard
			elseif inputCfg == 3 then
				sndPlay(sysSnd, 100, 0)
				if data.p2Controller == -1 then
					f_keyRead(1, -1)
					f_keyCfg(1, -1)
				else
					f_keyRead(3, -1)
					f_keyCfg(3, -1)
				end
			--P2 Gamepad
			elseif inputCfg == 4 then
				sndPlay(sysSnd, 100, 0)
				if data.p2Controller == -1 then
					f_padRead(3, 1)
					f_keyCfg(3, 1)
				else
					f_padRead(1, 1)
					f_keyCfg(1, 1)
				end
			--Default Values
			elseif inputCfg == 7 then
				sndPlay(sysSnd, 100, 1)
				f_inputDefault()
			--Back
			else
				sndPlay(sysSnd, 100, 2)
				break
			end
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_inputCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_inputCfg)
		t_inputCfg[5].varText = s_p1Controller
		t_inputCfg[6].varText = s_p2Controller
		for i=1, #t_inputCfg do
			textImgDraw(t_inputCfg[i].id)
			if t_inputCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_inputCfg[i].varID, font2, 0, -1, t_inputCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+inputCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

function f_swapController(playerOld, playerNew, controllerOld, controllerNew)
	s_configSSZ = s_configSSZ:gsub('in.new%[' .. playerOld .. '%]%.set%(\n*%s*' .. controllerOld, 'in.new[' .. playerNew .. 'deleteMe].set(\n  ' .. controllerOld)
	s_configSSZ = s_configSSZ:gsub('in.new%[' .. playerNew .. '%]%.set%(\n*%s*' .. controllerNew, 'in.new[' .. playerOld .. '].set(\n  ' .. controllerNew)
	s_configSSZ = s_configSSZ:gsub('deleteMe', '')
end

t_inputWarning = {
	{id = '', text = "If you loose control over the game controller settings"},
	{id = '', text = "will need to be manually changed via ssz/config.ssz"},
}
for i=1, #t_inputWarning do
	t_inputWarning[i].id = createTextImg(font2, 0, 1, t_inputWarning[i].text, 25, 15+i*15)
end
function f_cmdWarning()
	cmdInput()
	while true do
		if btnPalNo(p1Cmd) > 0 or esc() then
			sndPlay(sysSnd, 100, 0)
			break
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 20,20, 280,#t_inputWarning*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_Warning)
		for i=1, #t_inputWarning do
			textImgDraw(t_inputWarning[i].id)
		end
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; KEY SETTINGS
--;===========================================================
txt_keyCfg = createTextImg(jgFnt, 0, 0, 'KEY SETTINGS', 159, 13)
t_keyCfg = {
	{id = '', text = 'Up',    varID = textImgNew(), varText = ''},
	{id = '', text = 'Down',  varID = textImgNew(), varText = ''},
	{id = '', text = 'Left',  varID = textImgNew(), varText = ''},
	{id = '', text = 'Right', varID = textImgNew(), varText = ''},
	{id = '', text = 'A',     varID = textImgNew(), varText = ''},
	{id = '', text = 'B',     varID = textImgNew(), varText = ''},
	{id = '', text = 'C',     varID = textImgNew(), varText = ''},
	{id = '', text = 'X',     varID = textImgNew(), varText = ''},
	{id = '', text = 'Y',     varID = textImgNew(), varText = ''},
	{id = '', text = 'Z',     varID = textImgNew(),	varText = ''},
	{id = '', text = 'Start', varID = textImgNew(),	varText = ''},
	{id = '', text = 'Back'},
}
for i=1, #t_keyCfg do
	t_keyCfg[i].id = createTextImg(font2, 0, 1, t_keyCfg[i].text, 85, 15+i*15)
end

function f_keyCfg(playerNo, controller)
	cmdInput()
	local keyCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			f_keySave(playerNo, controller)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			keyCfg = keyCfg - 1
			if keyCfg < 1 then keyCfg = #t_keyCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			keyCfg = keyCfg + 1
			if keyCfg > #t_keyCfg then keyCfg = 1 end
		end
		if btnPalNo(p1Cmd) > 0 then
			--Up, Down, Left, Right, A, B, C, X, Y, Z, Start
			if keyCfg < #t_keyCfg then
				sndPlay(sysSnd, 100, 0)
				t_keyCfg[keyCfg].varText = f_readInput(t_keyCfg[keyCfg].varText)
			--Back
			else
				sndPlay(sysSnd, 100, 2)
				f_keySave(playerNo, controller)
				break
			end
			modified = 1
			needReload = 1
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_keyCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_keyCfg)
		for i=1, #t_keyCfg do
			textImgDraw(t_keyCfg[i].id)
			if t_keyCfg[i].varID ~= nil then
				textImgDraw(f_updateTextImg(t_keyCfg[i].varID, font2, 0, -1, t_keyCfg[i].varText, 235, 15+i*15))
			end
		end
		animSetWindow(cursorBox, 80,5+keyCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

t_kpCfg = {
	{id = '', text = 'Keyboard'},
	{id = '', text = 'Keypad (Numpad)'},
}
for i=1, #t_kpCfg do
	t_kpCfg[i].id = createTextImg(font2, 0, 1, t_kpCfg[i].text, 85, 15+i*15)
end

function f_kpCfg(swap1, swap2)
	cmdInput()
	local kpCfg = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			return swap1
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			kpCfg = kpCfg - 1
			if kpCfg < 1 then kpCfg = #t_kpCfg end
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			kpCfg = kpCfg + 1
			if kpCfg > #t_kpCfg then kpCfg = 1 end
		end
		if btnPalNo(p1Cmd) > 0 then
			--Keyboard
			if kpCfg == 1 then
				return swap1
			--Keypad (Numpad)
			else
				return swap2
			end
		end
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		animSetWindow(optionsBG1, 80,20, 160,#t_kpCfg*15)
		animDraw(f_animVelocity(optionsBG1, -1, -1))
		textImgDraw(txt_keyCfg)
		for i=1, #t_kpCfg do
			textImgDraw(t_kpCfg[i].id)
		end
		animSetWindow(cursorBox, 80,5+kpCfg*15, 160,15)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		cmdInput()
		refresh()
	end
end

function f_keyRead(playerNo, controller)
	local tmp = s_configSSZ:match('in.new%[' .. playerNo .. '%]%.set%(\n*%s*' .. controller .. ',\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^%)%s]*%s*%);')
	local tmp = tmp:gsub('in.new%[' .. playerNo .. '%]%.set%(\n*%s*' .. controller .. ',\n*%s*', '')
	local tmp = tmp:gsub('%(int%)k_t::([^,%s]*)%s*(,)\n*%s*', '%1%2')
	local tmp = tmp:gsub('%(int%)k_t::([^%)%s]*)%s*%);', '%1')
	for i, c
		in ipairs(script.randomtest.strsplit(',', tmp)) --split string using "," delimiter
	do
		t_keyCfg[i].varText = c
	end
end
--for some reason doesn't work when nested inside f_keyRead
function f_padRead(playerNo, controller)
	local tmp = s_configSSZ:match('in.new%[' .. playerNo .. '%]%.set%(\n*%s*' .. controller .. ',\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^%)%s]*%s*%);')
	local tmp = tmp:gsub('in.new%[' .. playerNo .. '%]%.set%(\n*%s*' .. controller .. ',\n*%s*', '')
	local tmp = tmp:gsub('([^,%s]*)%s*(,)\n*%s*', '%1%2')
	local tmp = tmp:gsub('([^%)%s]*)%s*%);', '%1')
	for i, c
		in ipairs(script.randomtest.strsplit(',', tmp)) --split string using "," delimiter
	do
		t_keyCfg[i].varText = c
	end
end

t_keySwap = {
	{key = '`',  swap1 = 'GRAVE'},
	{key = '=',  swap1 = 'EQUALS'},
	{key = '[',  swap1 = 'LEFTBRACKET'},
	{key = ']',  swap1 = 'RIGHTBRACKET'},
	{key = '\\', swap1 = 'BACKSLASH'},
	{key = ';',  swap1 = 'SEMICOLON'},
	{key = "'",  swap1 = 'APOSTROPHE'},
	{key = '*',  swap1 = 'KP_MULTIPLY'},
	{key = '+',  swap1 = 'KP_PLUS'},
	{key = '-',  swap1 = 'MINUS',  swap2 = 'KP_MINUS'},
	{key = ',',  swap1 = 'COMMA',  swap2 = 'KP_PERIOD'},
	{key = '.',  swap1 = 'PERIOD', swap2 = 'KP_PERIOD'},
	{key = '/',  swap1 = 'SLASH',  swap2 = 'KP_DIVIDE'},
	{key = '0',  swap1 = '0',      swap2 = 'KP_0'},
	{key = '1',  swap1 = '1',      swap2 = 'KP_1'},
	{key = '2',  swap1 = '2',      swap2 = 'KP_2'},
	{key = '3',  swap1 = '3',      swap2 = 'KP_3'},
	{key = '4',  swap1 = '4',      swap2 = 'KP_4'},
	{key = '5',  swap1 = '5',      swap2 = 'KP_5'},
	{key = '6',  swap1 = '6',      swap2 = 'KP_6'},
	{key = '7',  swap1 = '7',      swap2 = 'KP_7'},
	{key = '8',  swap1 = '8',      swap2 = 'KP_8'},
	{key = '9',  swap1 = '9',      swap2 = 'KP_9'},
}
function f_readInput(oldKey)
	--for some reason io.read() doesn't work, inputDialogPopup will be used as a workaround for now
	--local key = io.read()
	--while key == nil do
	--	if esc() then
	--		sndPlay(sysSnd, 100, 2)
	--		break
	--	end
	--	refresh()
	--end
	--return key
	inputDialogPopup(inputdia, 'Type in the key')
	while not inputDialogIsDone(inputdia) do
		animDraw(f_animVelocity(optionsBG0, -1, -1))
		refresh()
	end
	local key = inputDialogGetStr(inputdia)
	if key == '' or key == nil then
		key = oldKey
	else
		for i=1, #t_keySwap do
			if key == t_keySwap[i].key then
				if t_keySwap[i].swap2 == nil then
					key = t_keySwap[i].swap1
				else
					key = f_kpCfg(t_keySwap[i].swap1, t_keySwap[i].swap2)
				end
				i = #t_keySwap
			end
		end
	end
	return key
end

function f_keySave(playerNo, controller)
	--Keyboard
	s_configSSZ = s_configSSZ:gsub('in.new%[' .. playerNo .. '%]%.set%(\n*%s*' .. controller .. ',\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^,%s]*%s*,\n*%s*%(int%)k_t::[^%)%s]*%s*%);',
	'in.new[' .. playerNo .. '].set(\n  ' .. controller .. ',\n  (int)k_t::' .. t_keyCfg[1].varText .. ',\n  (int)k_t::' .. t_keyCfg[2].varText .. ',\n  (int)k_t::' .. t_keyCfg[3].varText .. ',\n  (int)k_t::' .. t_keyCfg[4].varText .. ',\n  (int)k_t::' .. t_keyCfg[5].varText .. ',\n  (int)k_t::' .. t_keyCfg[6].varText .. ',\n  (int)k_t::' .. t_keyCfg[7].varText .. ',\n  (int)k_t::' .. t_keyCfg[8].varText .. ',\n  (int)k_t::' .. t_keyCfg[9].varText .. ',\n  (int)k_t::' .. t_keyCfg[10].varText .. ',\n  (int)k_t::' .. t_keyCfg[11].varText .. ');')
	--Gamepad
	s_configSSZ = s_configSSZ:gsub('in.new%[' .. playerNo .. '%]%.set%(\n*%s*' .. controller .. ',\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^,%s]*%s*,\n*%s*[^%)%s]*%s*%);',
	'in.new[' .. playerNo .. '].set(\n  ' .. controller .. ', ' .. t_keyCfg[1].varText .. ', ' .. t_keyCfg[2].varText .. ', ' .. t_keyCfg[3].varText .. ', ' .. t_keyCfg[4].varText .. ', ' .. t_keyCfg[5].varText .. ', ' .. t_keyCfg[6].varText .. ', ' .. t_keyCfg[7].varText .. ', ' .. t_keyCfg[8].varText .. ', ' .. t_keyCfg[9].varText .. ', ' .. t_keyCfg[10].varText .. ', ' .. t_keyCfg[11].varText .. ');')
end
