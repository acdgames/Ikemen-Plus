
module(..., package.seeall)

--;===========================================================
--; MAIN LOOP
--;===========================================================
t_mainNetplay = {
	{id = textImgNew(), text = 'VS MODE'},
	{id = textImgNew(), text = 'TEAM CO-OP'},
	{id = textImgNew(), text = 'SURVIVAL CO-OP'},
	{id = textImgNew(), text = 'BACK'},
}
txt_connecting = createTextImg(jgFnt, 0, 1, '', 10, 140)

function f_mainNetplay()
	cmdInput()
	local cursorPosY = 0
	local moveTxt = 0
	local mainNetplay = 1
	local cancel = false
	while true do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			return
		end

		if commandGetState(p1Cmd, 'u') then
			sndPlay(sysSnd, 100, 0)
			mainNetplay = mainNetplay - 1
		elseif commandGetState(p1Cmd, 'd') then
			sndPlay(sysSnd, 100, 0)
			mainNetplay = mainNetplay + 1
		end
		if mainNetplay < 1 then
			mainNetplay = #t_mainNetplay
			if #t_mainNetplay > 4 then
				cursorPosY = 4
			else
				cursorPosY = #t_mainNetplay-1
			end
		elseif mainNetplay > #t_mainNetplay then
			mainNetplay = 1
			cursorPosY = 0
		elseif commandGetState(p1Cmd, 'u') and cursorPosY > 0 then
			cursorPosY = cursorPosY - 1
		elseif commandGetState(p1Cmd, 'd') and cursorPosY < 4 then
			cursorPosY = cursorPosY + 1
		end
		if cursorPosY == 4 then
			moveTxt = (mainNetplay - 5) * 13
		elseif cursorPosY == 0 then
			moveTxt = (mainNetplay - 1) * 13
		end
		if btnPalNo(p1Cmd) > 0 then
			f_default()
			--VS MODE
			if mainNetplay == 1 then
				sndPlay(sysSnd, 100, 1)
				setHomeTeam(1)
				data.p2In = 2
				data.stageMenu = true
				data.p2Faces = true
				textImgSetText(txt_mainSelect, 'Online Versus')
				cancel = f_connect()
				if not cancel then
					synchronize()
					math.randomseed(sszRandom())
					script.select.f_selectSimple()
				end
			--TEAM CO-OP
			elseif mainNetplay == 2 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 2
				data.p2Faces = true
				data.coop = true
				data.coinsLeft = data.coins - 1
				data.gameMode = 'arcade'
				textImgSetText(txt_mainSelect, 'Online Cooperative')
				cancel = f_connect()
				if not cancel then
					synchronize()
					math.randomseed(sszRandom())
					script.select.f_selectAdvance()
				end
			--SURVIVAL CO-OP
			elseif mainNetplay == 3 then
				sndPlay(sysSnd, 100, 1)
				data.p2In = 2
				data.p2Faces = true
				data.coop = true
				data.coinsLeft = 0
				data.gameMode = 'survival'
				textImgSetText(txt_mainSelect, 'Online Survival')
				cancel = f_connect()
				if not cancel then
					synchronize()
					math.randomseed(sszRandom())
					script.select.f_selectAdvance()
				end
			--BACK
			else
				sndPlay(sysSnd, 100, 2)
				break
			end
		end
		animDraw(f_animVelocity(titleBG0, -2.15, 0))
		for i=1, #t_mainNetplay do
			if i == mainNetplay then
				bank = 5
			else
				bank = 0
			end
			textImgDraw(f_updateTextImg(t_mainNetplay[i].id, jgFnt, bank, 0, t_mainNetplay[i].text, 159, 144+i*13-moveTxt))
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

		exitNetPlay()
    	exitReplay()

		cmdInput()
		refresh()
	end
end

function f_connect()
	inputDialogPopup(inputdia, 'Input Server')
	while not inputDialogIsDone(inputdia) do
		refresh()
	end
	textImgSetText(txt_connecting, 'Now connecting... ' .. inputDialogGetStr(inputdia) .. ' ' .. getListenPort())
	enterNetPlay(inputDialogGetStr(inputdia))
	while not connected() do
		if esc() then
			sndPlay(sysSnd, 100, 2)
			return true
		end
		textImgDraw(txt_connecting)
		refresh()
	end
	return false
end
