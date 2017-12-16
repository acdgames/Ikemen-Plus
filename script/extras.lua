
module(..., package.seeall)

--;===========================================================
--; MAIN LOOP
--;===========================================================
t_mainExtras = {
	{id = textImgNew(), text = 'FREE BATTLE'},
	{id = textImgNew(), text = 'BOSS RUSH'},
	{id = textImgNew(), text = 'VS 100 KUMITE'},
	{id = textImgNew(), text = 'BONUS GAMES'},
	{id = textImgNew(), text = 'REPLAY'},
	{id = textImgNew(), text = 'DEMO'},
	{id = textImgNew(), text = 'BACK'},
}

function f_mainExtras()
	cmdInput()
	local cursorPosY = 0
	local moveTxt = 0
	local mainExtras = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			mainExtras = mainExtras - 1
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			mainExtras = mainExtras + 1
		end
		if mainExtras < 1 then
			mainExtras = #t_mainExtras
			if #t_mainExtras > 4 then
				cursorPosY = 4
			else
				cursorPosY = #t_mainExtras-1
			end
		elseif mainExtras > #t_mainExtras then
			mainExtras = 1
			cursorPosY = 0
		elseif commandGetState(p1Cmd, 'u') and cursorPosY > 0 then
			cursorPosY = cursorPosY - 1
		elseif commandGetState(p1Cmd, 'd') and cursorPosY < 4 then
			cursorPosY = cursorPosY + 1
		end
		if cursorPosY == 4 then
			moveTxt = (mainExtras - 5) * 13
		elseif cursorPosY == 0 then
			moveTxt = (mainExtras - 1) * 13
		end
		if btnPalNo(p1Cmd) > 0 then
			f_default()
			--FREE BATTLE
			if mainExtras == 1 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 1
				data.stageMenu = true
				data.p2Faces = true
				textImgSetText(txt_mainSelect, 'Free Battle')
				script.select.f_selectSimple()
			--BOSS RUSH
			elseif mainExtras == 2 then
				sndPlay(sysSnd, 100, 1)
				if #t_bossChars ~= 0 then
					data.p2In = 1
					data.p2SelectMenu = false
					data.coinsLeft = 0
					data.gameMode = 'bossrush'
					textImgSetText(txt_mainSelect, 'Boss Rush')
					script.select.f_selectAdvance()
				end
			--VS 100 KUMITE
			elseif mainExtras == 3 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 1
				data.p2SelectMenu = false
				data.gameMode = '100kumite'
				textImgSetText(txt_mainSelect, 'VS 100 Kumite')
				script.select.f_selectAdvance()
			--BONUS GAMES
			elseif mainExtras == 4 then
				sndPlay(sysSnd, 100, 1)
				f_bonusExtras()
			--REPLAY
			elseif mainExtras == 5 then
				sndPlay(sysSnd, 100, 1)
				
				data.p2In = 2
				data.stageMenu = true
				data.p2Faces = true

				textImgSetText(txt_mainSelect, 'Online Versus')
				enterReplay('replay/netplay.replay')
				synchronize()
				math.randomseed(sszRandom())
				script.select.f_selectSimple()

				exitNetPlay()
    			exitReplay()
			--DEMO
			elseif mainExtras == 6 then
				sndPlay(sysSnd, 100, 1)
				script.randomtest.run()
			--BACK
			else
				sndPlay(sysSnd, 100, 2)
				break
			end
		end
		animDraw(f_animVelocity(titleBG0, -2.15, 0))
		for i=1, #t_mainExtras do
			if i == mainExtras then
				bank = 5
			else
				bank = 0
			end
			textImgDraw(f_updateTextImg(t_mainExtras[i].id, jgFnt, bank, 0, t_mainExtras[i].text, 159, 144+i*13-moveTxt))
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
--; BONUS GAMES
--;===========================================================
t_bonusExtras = {}
local endFor = #t_bonusChars+1
for i=1, endFor do
	t_bonusExtras[#t_bonusExtras+1] = {}
	t_bonusExtras[i]['id'] = textImgNew()
	if i < endFor then
		t_bonusExtras[i]['text'] = t_selChars[t_bonusChars[i]+1].displayname:upper()
	else
		t_bonusExtras[i]['text'] = 'BACK'
	end
end

function f_bonusExtras()
	cmdInput()
	local cursorPosY = 0
	local moveTxt = 0
	local bonusExtras = 1
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			break
		elseif commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			bonusExtras = bonusExtras - 1
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			bonusExtras = bonusExtras + 1
		end
		if bonusExtras < 1 then
			bonusExtras = #t_bonusExtras
			if #t_bonusExtras > 4 then
				cursorPosY = 4
			else
				cursorPosY = #t_bonusExtras-1
			end
		elseif bonusExtras > #t_bonusExtras then
			bonusExtras = 1
			cursorPosY = 0
		elseif commandGetState(p1Cmd, 'u') and cursorPosY > 0 then
			cursorPosY = cursorPosY - 1
		elseif commandGetState(p1Cmd, 'd') and cursorPosY < 4 then
			cursorPosY = cursorPosY + 1
		end
		if cursorPosY == 4 then
			moveTxt = (bonusExtras - 5) * 13
		elseif cursorPosY == 0 then
			moveTxt = (bonusExtras - 1) * 13
		end
		if btnPalNo(p1Cmd) > 0 then
			f_default()
			if bonusExtras < #t_bonusExtras then
			--BONUS CHAR NAME
				sndPlay(sysSnd, 100, 1)
				data.versusScreen = false
				data.p1TeamMenu = {mode = 0, chars = 1}
				data.p2TeamMenu = {mode = 0, chars = 1}
				data.p2Char = {t_bonusChars[bonusExtras]}
				textImgSetText(txt_mainSelect, t_selChars[t_bonusChars[bonusExtras]+1].displayname)
				script.select.f_selectSimple()
			--BACK
			else
				sndPlay(sysSnd, 100, 2)
				break
			end
		end
		animDraw(f_animVelocity(titleBG0, -2.15, 0))
		for i=1, #t_bonusExtras do
			if i == bonusExtras then
				bank = 5
			else
				bank = 0
			end
			textImgDraw(f_updateTextImg(t_bonusExtras[i].id, jgFnt, bank, 0, t_bonusExtras[i].text, 159, 144+i*13-moveTxt))
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
