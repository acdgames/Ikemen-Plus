
math.randomseed(os.time())

--;===========================================================
--; SCREENPACK DEFINITION
--;===========================================================
--Create global space (accessing variables between modules)
data = require('script.data')

--Load saved variables
assert(loadfile('script/data_sav.lua'))()

--Assign Lifebar
loadLifebar(data.lifebar) --path to lifebar stored in 'script/data_sav.lua', also adjustable from options

--Debug stuff
loadDebugFont('data/gms_lifebar/font2.fnt')
setDebugScript('script/debug.lua')

--SFF
sysSff = sffNew('data/system.sff')
fadeSff = sffNew('data/fade.sff')

--SND
sysSnd = sndNew('data/system.snd')

--Fonts
jgFnt = fontNew('font/JG.fnt')
font1 = fontNew('font/f-4x6.fnt')
font2 = fontNew('font/f-6x9.fnt')
survBarsFnt = fontNew('font/survival_bars.fnt')
survNumFnt = fontNew('font/survival_nums.fnt')

--Music
bgm = 'sound/Menu.mp3'
bgmSelect = 'sound/Char Select.mp3'

--;===========================================================
--; COMMON SECTION
--;===========================================================
--input stuff
inputdia = inputDialogNew()
data.p1In = 1
data.p2In = 1

function setCommand(c)
	commandAdd(c, 'u', '$U')
	commandAdd(c, 'd', '$D')
	commandAdd(c, 'l', '$B')
	commandAdd(c, 'r', '$F')
	commandAdd(c, 'a', 'a')
	commandAdd(c, 'b', 'b')
	commandAdd(c, 'c', 'c')
	commandAdd(c, 'x', 'x')
	commandAdd(c, 'y', 'y')
	commandAdd(c, 'z', 'z')
	commandAdd(c, 's', 's')
	commandAdd(c, 'holds', '/s')
	commandAdd(c, 'su', '/s, U')
	commandAdd(c, 'sd', '/s, D')
end

p1Cmd = commandNew()
setCommand(p1Cmd)

p2Cmd = commandNew()
setCommand(p2Cmd)

function cmdInput()
	commandInput(p1Cmd, data.p1In)
	commandInput(p2Cmd, data.p2In)
end

--returns value depending on button pressed (a = 1; a + start = 7 etc.)
function btnPalNo(cmd)
	local s = 0
	if commandGetState(cmd, 'holds') then s = 6 end
	if commandGetState(cmd, 'a') then return 1 + s end
	if commandGetState(cmd, 'b') then return 2 + s end
	if commandGetState(cmd, 'c') then return 3 + s end
	if commandGetState(cmd, 'x') then return 4 + s end
	if commandGetState(cmd, 'y') then return 5 + s end
	if commandGetState(cmd, 'z') then return 6 + s end
	return 0
end

--animDraw at specified coordinates
function animPosDraw(a, x, y)
	animSetPos(a, x, y)
	animUpdate(a)
	animDraw(a)
end

--textImgDraw at specified coordinates
function textImgPosDraw(ti, x, y)
	textImgSetPos(ti, x, y)
	textImgDraw(ti)
end

--shortcut for creating new text with several parameters
function createTextImg(font, bank, aline, text, x, y, scaleX, scaleY)
	local ti = textImgNew()
	textImgSetFont(ti, font)
	textImgSetBank(ti, bank)
	textImgSetAlign(ti, aline)
	textImgSetText(ti, text)
	textImgSetPos(ti, x, y)
	scaleX = scaleX or 1
	scaleY = scaleY or 1
	textImgSetScale(ti, scaleX, scaleY)
	return ti
end

--shortcut for updating text with several parameters
function f_updateTextImg(animName, font, bank, aline, text, x, y, scaleX, scaleY)
	textImgSetFont(animName, font)
	textImgSetBank(animName, bank)
	textImgSetAlign(animName, aline)
	textImgSetText(animName, text)
	textImgSetPos(animName, x, y)
	scaleX = scaleX or 1
	scaleY = scaleY or 1
	textImgSetScale(animName, scaleX, scaleY)
	return animName
end

--shortcut for updating velocity
function f_animVelocity(animName, addX, addY)
	animAddPos(animName, addX, addY)
	animUpdate(animName)
	return animName
end

--dynamically adjusts alpha blending each time called based on specified values
alpha1cur = 0
alpha2cur = 0
alpha1add = true
alpha2add = true
function f_dynamicAlpha(animName, r1min, r1max, r1step, r2min, r2max, r2step)
	if r1step == 0 then alpha1cur = r1max end
	if alpha1cur < r1max and alpha1add then
		alpha1cur = alpha1cur + r1step
		if alpha1cur >= r1max then
			alpha1add = false
		end
	elseif alpha1cur > r1min and not alpha1add then
		alpha1cur = alpha1cur - r1step
		if alpha1cur <= r1min then
			alpha1add = true
		end
	end
	if r2step == 0 then alpha2cur = r2max end
	if alpha2cur < r2max and alpha2add then
		alpha2cur = alpha2cur + r2step
		if alpha2cur >= r2max then
			alpha2add = false
		end
	elseif alpha2cur > r2min and not alpha2add then
		alpha2cur = alpha2cur - r2step
		if alpha2cur <= r2min then
			alpha2add = true
		end
	end
	animSetAlpha(animName, alpha1cur, alpha2cur)
end

--Convert number to name and get rid of the ""
function f_getName(cel)
	local tmp = getCharName(cel)
	tmp = tmp:gsub('^["%s]*(.-)["%s]*$', '%1')
	return tmp
end

--randomizes table content
function f_shuffleTable(t)
    local rand = math.random 
    assert(t, "f_shuffleTable() expected a table, got nil")
    local iterations = #t
    local j
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

--prints "t" table content into "toFile" file
function f_printTable(t, toFile)
	local toFile = toFile or 'debug/table_print.txt'
	local txt = ''
	local print_t_cache = {}
	local function sub_print_t(t, indent)
		if print_t_cache[tostring(t)] then
			txt = txt .. indent .. '*' .. tostring(t) .. '\n'
		else
			print_t_cache[tostring(t)] = true
			if type(t) == 'table' then
				for pos, val in pairs(t) do
					if type(val) == 'table' then
						txt = txt .. indent .. '[' .. pos .. '] => ' .. tostring(t) .. ' {' .. '\n'
						sub_print_t(val, indent .. string.rep(' ', string.len(pos)+8))
						txt = txt .. indent .. string.rep(' ', string.len(pos)+6) .. '}' .. '\n'
					elseif type(val) == 'string' then
						txt = txt .. indent .. '[' .. pos .. '] => "' .. val .. '"' .. '\n'
					else
						txt = txt .. indent .. '[' .. pos .. '] => ' .. tostring(val) ..'\n'
					end
				end
			else
				txt = txt .. indent .. tostring(t) .. '\n'
			end
		end
	end
	if type(t) == 'table' then
		txt = txt .. tostring(t) .. ' {' .. '\n'
		sub_print_t(t, '  ')
		txt = txt .. '}' .. '\n'
	else
		sub_print_t(t, '  ')
	end
	local file = io.open(toFile,"w+")
	file:write(txt)
	file:close()
end

--prints "v" variable into "toFile" file
function f_printVar(v, toFile)
	local toFile = toFile or 'debug/var_print.txt'
	local file = io.open(toFile,"w+")
	file:write(v)
	file:close()
end

--generate anim from table
function f_animFromTable(t, sff, x, y, scaleX, scaleY, facing, infFrame)
	infFrame = infFrame or 1
	scaleX = scaleX or 1
	scaleY = scaleY or 1
	facing = facing or 0
	local anim = ''
	local length = 0
	for i=1, #t do
		anim = anim .. t[i] .. ', ' .. facing .. '\n'
		if not t[i]:match('loopstart') then
			local tmp = t[i]:gsub('^.-([^,%s]+)$','%1')
			if tonumber(tmp) == -1 then
				tmp = infFrame
			end
			length = length + tmp
		end
	end
	local id = animNew(sff, anim)
	animAddPos(id, x, y)
	animSetScale(id, scaleX, scaleY)
	animUpdate(id)
	return id, tonumber(length)
end

--generate fading animation
function f_fadeAnim(ticks, fadeType, color, sff)
	local anim = ''
	if color == 'white' then
		if fadeType == 'fadeout' then
			for i=1, ticks do
				anim = anim .. '0,1, 0,0, 1, 0, AS' .. math.floor(256/ticks*i) .. 'D256\n'
			end
			anim = anim .. '0,1, 0,0, -1, 0, AS256D256'
		else --fadein
			for i=ticks, 1, -1 do
				anim = anim .. '0,1, 0,0, 1, 0, AS' .. math.floor(256/ticks*i) .. 'D256\n'
			end
			anim = anim .. '0,1, 0,0, -1, 0, AS0D256'
		end
	else --black
		if fadeType == 'fadeout' then
			for i=ticks, 1, -1 do
				anim = anim .. '0,0, 0,0, 1, 0, AS256D' .. math.floor(256/ticks*i) .. '\n'
			end
			anim = anim .. '0,0, 0,0, -1, 0, AS256D0'
		else --fadein
			for i=1, ticks do
				anim = anim .. '0,0, 0,0, 1, 0, AS256D' .. math.floor(256/ticks*i) .. '\n'
			end
			anim = anim .. '0,0, 0,0, -1, 0, AS256D256'
		end
	end
	anim = animNew(sff, anim)
	animUpdate(anim)
	return anim, ticks
end

--remove duplicated string pattern
function f_uniq(str, pattern, subpattern)
	local out = {}
	for s in str:gmatch(pattern) do
		local s2 = s:match(subpattern)
		if not f_contains(out, s2) then out[#out+1] = s end
	end
	return table.concat(out)
end

function f_contains(t, val)
	for k,v in pairs(t) do
		--if v == val then
		if v:match(val) then
			return true
		end
	end
	return false
end

--- Draw string letter by letter + wrap lines.
-- @data: text data
-- @str: string (text you want to draw)
-- @counter: external counter (values should be increased each frame by 1 starting from 1)
-- @x: first line X position
-- @y: first line Y position
-- @spacing: spacing between lines (rendering Y position increasement for each line)
-- @delay (optional): ticks (frames) delay between each letter is rendered, defaults to 0 (all text rendered immediately)
-- @limit (optional): maximum line length (string wraps when reached), if omitted line wraps only if string contains '\n'
function f_textRender(data, str, counter, x, y, spacing, delay, limit)
	local delay = delay or 0
	local limit = limit or -1
	str = tostring(str)
	if limit == -1 then
		str = str:gsub('\\n', '\n')
	else
		str = str:gsub('%s*\\n%s*', ' ')
		if math.floor(#str / limit) + 1 > 1 then
			str = f_wrap(str, limit, indent, indent1)
		end
	end
	local subEnd = math.floor(#str - (#str - counter/delay))
	local t = {}
	for line in str:gmatch('([^\r\n]*)[\r\n]?') do
		t[#t+1] = line
	end
	t[#t] = nil --get rid of the last blank line
	local lengthCnt = 0
	for i=1, #t do
		if subEnd < #str then
			local length = #t[i]
			if i > 1 and i <= #t then
				length = length + 1
			end
			lengthCnt = lengthCnt + length
			if subEnd < lengthCnt then
				t[i] = t[i]:sub(0, subEnd - lengthCnt)
			end
		end
		textImgSetText(data, t[i])
		textImgSetPos(data, x, y + spacing * (i - 1))
		textImgDraw(data)
	end
end

--- Wrap a long string.
-- source: http://lua-users.org/wiki/StringRecipes
-- @str: string to wrap
-- @limit: maximum line length
-- @indent: regular indentation
-- @indent1: indentation of first line
function f_wrap(str, limit, indent, indent1)
	indent = indent or ''
	indent1 = indent1 or indent
	limit = limit or 72
	local here = 1-#indent1
	return indent1 .. str:gsub("(%s+)()(%S+)()",
	function(sp, st, word, fi)
		if fi - here > limit then
			here = st - #indent
			return '\n' .. indent .. word
		end
	end)
end

txt_loading = createTextImg(font1, 0, -1, 'LOADING...', 310, 230)

--;===========================================================
--; LOAD ADDITIONAL SCRIPTS
--;===========================================================
require('script.randomtest')
assert(loadfile('script/parser.lua'))()
require('script.options')
require('script.netplay')
require('script.extras')
require('script.select')
require('script.continue')
require('script.storyboard')

--;===========================================================
--; TITLE BACKGROUND DEFINITION
--;===========================================================
--Buttons Background
titleBG0 = animNew(sysSff, [[
5,1, 0,145, -1
]])
animAddPos(titleBG0, 160, 0)
animSetTile(titleBG0, 1, 1)
animSetWindow(titleBG0, 0, 145, 320, 75)
--parallax is not supported in ikemen
--type  = parallax
--width = 400, 1200
--yscalestart = 100
--yscaledelta = 1

--Buttons Background (fade)
titleBG1 = animNew(sysSff, [[
5,2, -160,145, -1, 0, s
]])
animAddPos(titleBG1, 160, 0)
animUpdate(titleBG1)

--Background Top
titleBG2 = animNew(sysSff, [[
5,0, 0,10, -1
]])
animAddPos(titleBG2, 160, 0)
animSetTile(titleBG2, 1, 2)

--Logo
titleBG3 = animNew(sysSff, [[
0,0, 0,40, -1, 0, a
]])
animAddPos(titleBG3, 160, 0)
animUpdate(titleBG3)

--Background Middle (black text cover)
titleBG4 = animNew(sysSff, [[
5,1, 0,145, -1
]])
animAddPos(titleBG4, 160, 0)
animSetTile(titleBG4, 1, 1)
animSetWindow(titleBG4, 0, 138, 320, 7)
animSetAlpha(titleBG4, 0, 0)
animUpdate(titleBG4)

--Background Bottom (black text cover)
titleBG5 = animNew(sysSff, [[
5,1, 0,145, -1
]])
animAddPos(titleBG5, 160, 0)
animSetTile(titleBG5, 1, 1)
animSetWindow(titleBG5, 0, 220, 320, 20)
animSetAlpha(titleBG5, 0, 0)
animUpdate(titleBG5)

--Background Footer
titleBG6 = animNew(sysSff, [[
300,0, 0,233, -1
]])
animAddPos(titleBG6, 160, 0)
animSetTile(titleBG6, 1, 0)
animUpdate(titleBG6)

--Cursor Box
cursorBox = animNew(sysSff, [[
100,1, 0,0, -1
]])
animSetTile(cursorBox, 1, 1)

txt_titleFt = createTextImg(font1, 0, 1, 'I.K.E.M.E.N. by SUEHIRO', 2, 240)
txt_titleFt2 = createTextImg(font1, 0, -1, 'https://osdn.net/users/supersuehiro/', 319, 240)

--;===========================================================
--; MAIN MENU LOOP
--;===========================================================
txt_mainSelect = createTextImg(jgFnt, 0, 0, '', 159, 13)
t_mainMenu = {
	{id = textImgNew(), text = 'ARCADE'},
	{id = textImgNew(), text = 'VS MODE'},
	{id = textImgNew(), text = 'ONLINE'},
	{id = textImgNew(), text = 'TEAM CO-OP'},
	{id = textImgNew(), text = 'SURVIVAL'},
	{id = textImgNew(), text = 'SURVIVAL CO-OP'},
	{id = textImgNew(), text = 'TRAINING'},
	{id = textImgNew(), text = 'WATCH'},
	{id = textImgNew(), text = 'EXTRAS'},
	{id = textImgNew(), text = 'OPTIONS'},
	{id = textImgNew(), text = 'EXIT'},
}

function f_default()
	setAutoLevel(false) --generate autolevel.txt in game dir
	setHomeTeam(2) --P2 side considered the home team: http://mugenguild.com/forum/topics/ishometeam-triggers-169132.0.html
	resetRemapInput()
	--settings adjustable via options
	setAutoguard(1, data.autoguard)
	setAutoguard(2, data.autoguard)
	setRoundTime(data.roundTime * 60)
	setLifeMul(data.lifeMul / 100)
	setTeam1VS2Life(data.team1VS2Life / 100)
	setTurnsRecoveryRate(1.0 / data.turnsRecoveryRate)
	setSharedLife(data.teamLifeShare)
	--default values for all modes
	data.p1Char = nil --no predefined P1 character (assigned via table: {X, Y, (...)})
	data.p2Char = nil --no predefined P2 character (assigned via table: {X, Y, (...)})
	data.p1TeamMenu = nil --no predefined P1 team mode (assigned via table: {mode = X, chars = Y})
	data.p2TeamMenu = nil --no predefined P2 team mode (assigned via table: {mode = X, chars = Y})
	data.aiFight = false --AI = data.difficulty for all characters disabled
	data.stageMenu = false --stage selection disabled
	data.p2Faces = false --additional window with P2 select screen small portraits (faces) disabled
	data.coop = false --P2 fighting on P1 side disabled
	data.p2SelectMenu = true --P2 character selection enabled
	data.versusScreen = true --versus screen enabled
	data.p1In = 1 --P1 controls P1 side of the select screen
	data.p2In = 0 --P2 controls in the select screen disabled
	data.gameMode = '' --additional variable used to distinguish modes in select screen
end

function f_mainMenu()
	cmdInput()
	local cursorPosY = 0
	local moveTxt = 0
	local mainMenu = 1
	script.storyboard.f_storyboard('data/logo.def')
	script.storyboard.f_storyboard('data/intro.def')
	data.fadeTitle = f_fadeAnim(10, 'fadein', 'black', fadeSff) --global variable so we can set it also from within select.lua
	while true do
		if esc() then
			os.exit()
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			mainMenu = mainMenu - 1
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			mainMenu = mainMenu + 1
		end
		--mode titles/cursor position calculation
		if mainMenu < 1 then
			mainMenu = #t_mainMenu
			if #t_mainMenu > 4 then
				cursorPosY = 4
			else
				cursorPosY = #t_mainMenu-1
			end
		elseif mainMenu > #t_mainMenu then
			mainMenu = 1
			cursorPosY = 0
		elseif commandGetState(p1Cmd, 'u') and cursorPosY > 0 then
			cursorPosY = cursorPosY - 1
		elseif commandGetState(p1Cmd, 'd') and cursorPosY < 4 then
			cursorPosY = cursorPosY + 1
		end
		if cursorPosY == 4 then
			moveTxt = (mainMenu - 5) * 13
		elseif cursorPosY == 0 then
			moveTxt = (mainMenu - 1) * 13
		end
		--mode selected
		if btnPalNo(p1Cmd) > 0 then
			f_default()
			--ARCADE
			if mainMenu == 1 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 1 --P1 controls P2 side of the select screen
				data.p2SelectMenu = false --P2 character selection disabled
				data.coinsLeft = data.coins - 1 --amount of continues
				data.gameMode = 'arcade' --mode recognized in select screen as 'arcade'
				textImgSetText(txt_mainSelect, 'Arcade') --message displayed on top of select screen
				script.select.f_selectAdvance() --start f_selectAdvance() function from script/select.lua
			--VS MODE
			elseif mainMenu == 2 then
				sndPlay(sysSnd, 100, 1)
				setHomeTeam(1) --P1 side considered the home team
				data.p2In = 2 --P2 controls P2 side of the select screen
				data.stageMenu = true --stage selection enabled
				data.p2Faces = true --additional window with P2 select screen small portraits (faces) enabled
				textImgSetText(txt_mainSelect, 'Versus Mode')
				script.select.f_selectSimple() --start f_selectSimple() function from script/select.lua
			--ONLINE
			elseif mainMenu == 3 then
				sndPlay(sysSnd, 100, 1)
				script.netplay.f_mainNetplay() --start f_mainNetplay() function from script/netplay.lua
			--TEAM CO-OP
			elseif mainMenu == 4 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 2
				data.p2Faces = true
				data.coop = true --P2 fighting on P1 side enabled
				data.coinsLeft = data.coins - 1
				data.gameMode = 'arcade'
				textImgSetText(txt_mainSelect, 'Team Cooperative')
				script.select.f_selectAdvance()
			--SURVIVAL
			elseif mainMenu == 5 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 1
				data.p2SelectMenu = false
				data.coinsLeft = 0
				data.gameMode = 'survival'
				textImgSetText(txt_mainSelect, 'Survival')
				script.select.f_selectAdvance()
			--SURVIVAL CO-OP
			elseif mainMenu == 6 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 2
				data.p2Faces = true
				data.coop = true
				data.coinsLeft = 0
				data.gameMode = 'survival'
				textImgSetText(txt_mainSelect, 'Survival')
				script.select.f_selectAdvance()
			--TRAINING
			elseif mainMenu == 7 then
				sndPlay(sysSnd, 100, 1)
				setRoundTime(-1) --round time disabled
				data.p2In = 2
				data.stageMenu = true
				data.versusScreen = false --versus screen disabled
				data.p2TeamMenu = {mode = 0, chars = 1} --predefined P2 team mode as Single, 1 Character
				data.p2Char = {t_charAdd['training']} --predefined P2 character as Training by stupa
				data.gameMode = 'training'
				textImgSetText(txt_mainSelect, 'Training Mode')
				script.select.f_selectSimple()
			--WATCH
			elseif mainMenu == 8 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 1
				data.aiFight = true --AI = data.difficulty for all characters enabled
				data.stageMenu = true
				data.p2Faces = true
				textImgSetText(txt_mainSelect, 'Watch Mode')
				script.select.f_selectSimple()
			--EXTRAS
			elseif mainMenu == 9 then
				sndPlay(sysSnd, 100, 1)
				script.extras.f_mainExtras() --start f_mainExtras() function from script/extras.lua
			--OPTIONS
			elseif mainMenu == 10 then
				sndPlay(sysSnd, 100, 1)
				script.options.f_mainCfg() --start f_mainCfg() function from script/options.lua
			--EXIT
			else
				os.exit()
			end
		end
		animDraw(f_animVelocity(titleBG0, -2.15, 0))
		for i=1, #t_mainMenu do
			if i == mainMenu then
				bank = 5
			else
				bank = 0
			end
			textImgDraw(f_updateTextImg(t_mainMenu[i].id, jgFnt, bank, 0, t_mainMenu[i].text, 159, 144+i*13-moveTxt))
		end
		animSetWindow(cursorBox, 101,147+cursorPosY*13, 116,13)
		f_dynamicAlpha(cursorBox, 20,100,5, 255,255,0)
		animDraw(f_animVelocity(cursorBox, -1, -1))
		animDraw(titleBG1)
		animAddPos(titleBG2, -1, 0)
		animUpdate(titleBG2)
		animDraw(titleBG2)
		animDraw(titleBG3)
		animDraw(titleBG4)
		animDraw(titleBG5)
		animDraw(titleBG6)
		textImgDraw(txt_titleFt)
		textImgDraw(txt_titleFt2)
		animDraw(data.fadeTitle)
		animUpdate(data.fadeTitle)
		cmdInput()
		refresh()
	end
end

--;===========================================================
--; INITIALIZE LOOPS
--;===========================================================

f_mainMenu()
