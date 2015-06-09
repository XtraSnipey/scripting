class 'JobGui'

joblist = {"Military", "Police", "Criminal"}

function JobGui:__init()
    
    self.textColor = Color(200, 50, 200)
    self.admins = {}
	self.rows = {}
    self.windowShown = false
    
    
    self:AddAdmin('STEAM_0:0:29665334')
    self:AddAdmin('STEAM_0:0:90551453')
    
    -- CREATE GUI
    self.window = Window.Create()
    self.window:SetVisible(self.windowShown)
	self.window:SetTitle("Jobs Menu")
	self.window:SetSizeRel(Vector2(0.4, 0.7))
	self.window:SetMinimumSize(Vector2(400, 200))
	self.window:SetPositionRel( Vector2(0.75, 0.5) - self.window:GetSizeRel()/2)
    self.window:Subscribe("WindowClosed", self, function (args) self:SetWindowVisible(false) end)
    
    
    local tabControl = TabControl.Create(self.window)
	tabControl:SetDock(GwenPosition.Fill)
	tabControl:SetSizeRel(Vector2(0.98, 1))
    
    local playersPage = tabControl:AddPage("Players"):GetPage()
    local ManagePage = tabControl:AddPage("Manage"):GetPage()
    
    --Creating menu
    self.playerList = SortedList.Create(playersPage)
    self.playerList:SetDock(GwenPosition.Fill)
	self.playerList:SetMargin(Vector2(0, 0), Vector2(0, 4))
	self.playerList:AddColumn("Player")
	self.playerList:AddColumn("Money")
	self.playerList:AddColumn("Job")
	self.playerList:SetButtonsVisible(true)
    
    for player in Client:GetPlayers() do
		self:AddPlayer(player)
	end
    
    self.manageList = SortedList.Create(ManagePage)
    self.manageList:SetDock(GwenPosition.Fill)
	self.manageList:SetMargin(Vector2(0, 0), Vector2(0, 4))
	self.manageList:AddColumn("List of Available Jobs")
	self.manageList:AddColumn("", 90)
	self.manageList:SetButtonsVisible(true)
    
    for key, Cjob in pairs(joblist) do
        job = joblist[key]
        local jobItem = self.manageList:AddItem(job)
        
        local joinJobBtn = self:CreateListButton("Join", true, jobItem)
	       joinJobBtn:Subscribe("Press", function()
                JobGui:joinJobClick(jobJoin) 
            end)
    
    jobItem:SetCellContents(1, joinJobBtn)
    end
    
    Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
	Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("KeyUp", self, self.KeyUp)
    
    
    self:AddPlayer(LocalPlayer)
end

function JobGui:LocalPlayerChat(args)
	local message = args.text
	
	local commands = {}
	for command in string.gmatch(message, "[^%s]+") do
		table.insert(commands, command)
	end
	
	if commands[1] ~= "/jobs" then return true end
	
	if #commands == 1 then -- No extra commands, show window and return
		self:SetWindowVisible(not self.windowShown)
		return false
	end
	
	local warpNameSearch = table.concat(commands, " ", 2)
	
	for player in Client:GetPlayers() do
		if (self:PlayerNameContains(player:GetName(), warpNameSearch)) then
			self:WarpToPlayerClick(player)
			return false
		end
	end
	
	return false
end

function JobGui:LocalPlayerInput(args) -- Prevent mouse from moving & buttons being pressed
    return not (self.windowShown and Game:GetState() == GUIState.Game)
end

function JobGui:KeyUp( args )
    if args.key == string.byte('R') then
        self:SetWindowVisible(not self.windowShown)
    end
end

function JobGui:PlayerJoin(args)
	local player = args.player
	
	self:AddPlayer(player)
    
    
    
    
end

function JobGui:joinJobClick(job) 
    Network:Send("jobRequestToServer", {requester = LocalPlayer, sJob = job})
end

function JobGui:PlayerQuit(args)
	local player = args.player
	local playerId = tostring(player:GetSteamId().id)
	    
	if self.rows[playerId] == nil then return end

	self.playerList:RemoveItem(self.rows[playerId])
	self.rows[playerId] = nil
end

function JobGui:SetWindowVisible(visible)
	self.windowShown = visible
	self.window:SetVisible(visible)
	Mouse:SetVisible(visible)
end

function JobGui:AddAdmin(steamId)
	self.admins[steamId] = true
end

function JobGui:IsAdmin(player)
	return self.admins[player:GetSteamId().string] ~= nil
end

function JobGui:AddPlayer(player)
	local playerId = tostring(player:GetSteamId().id)
	local playerName = player:GetName()
	
	local item = self.playerList:AddItem(playerId)
	
	item:SetCellText(0, playerName)
	item:SetCellText(1, playerName)
	item:SetCellText(2, playerName)
	
	self.rows[playerId] = item

end

function VisualizeCash()
    
end


function JobGui:CreateListButton(text, enabled, listItem)
    local buttonBackground = Rectangle.Create(listItem)
    buttonBackground:SetSizeRel(Vector2(0.5, 1.0))
    buttonBackground:SetDock(GwenPosition.Fill)
    buttonBackground:SetColor(Color(0, 0, 0, 100))
	
	local button = Button.Create(listItem)
	button:SetText(text)
	button:SetDock(GwenPosition.Fill)
	button:SetEnabled(enabled)
	
	return button
end

Network:Subscribe("SendCash", VisualizeCash)
JobGui = JobGui()
