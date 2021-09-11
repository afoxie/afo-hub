while game.GameId == 0 do wait() end
if game.GameId ~= 2585430167 or __AHLOADED then return end
warn(pcall(function()
    local o = {}
    loadstring(game:HttpGet("https://hub.afo.xyz/include/logging.lua"))()
    clear()
	title("AfoHub")
    printwelcome()
    info("Loading AfoHub!")
	local MethodOverrides = {
        ["Stats"] = {
            ["GetTotalMemoryUsageMb"] = function()
                return { math.random(1000, 1200) + (math.random(1700, 8000) / 10000) }
            end
        }
	}
    local EventOverrides = {}
    ---------------------------------------------------
	info("Hooking global __namecall")
    local printTable do
        local ignoreList = {"SetInterface","Replicate"}
        printTable = function(tbl, i)
            local spaces = ("    "):rep(i or 1)
            for i, v in pairs(tbl) do
                info(spaces, i, "->", v)
                if type(v) == "table" then
                    printTable(v, i + 1)
                end
            end
        end
        function logEv(m, ev, args, s)
            if not o.do_debug then return end
            if table.find(ignoreList, ev.Name) then return end
            warn(tostring(ev), tostring(m), "(FROM \"" .. tostring(s) .. "\")")
            for _, arg in pairs(args) do
                local astr = (typeof(arg) ~= "Instance" and tostring(arg)) or arg:GetFullName()
                warn("[" .. tostring(_) .. "]", "<" .. typeof(arg) .. ">", "->", astr)
                if typeof(arg) == "table" then
                    printTable(arg)
                end
            end
            warn("--------------------")
        end
    end
    local Last__nc
    OldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(Event, ...)
        local Args = { ... }
        local Method = getnamecallmethod()
        --spawn(function() info(tostring(Event) .. ":" .. tostring(Method) .. "(" .. table.concat(Args, ", ") .. ");") end)
        if not checkcaller() then
            if Method == "FireServer" or Method == "InvokeServer" then
                if tonumber(Event.Name) ~= nil then
                    --spawn(function() pcall(game.Destroy, Event) end)
                    --if o.do_debug then
                    --    warn("Anticheat call intercepted! Stay safe.")
                    --end
                    return nil -- block the call
                end
                local scrip = getcallingscript()
                spawn(coroutine.wrap(function() logEv(Method, Event, Args, scrip) end))
            elseif Method == "InvalidNameCall" then
                return nil
            elseif EventOverrides[Event.Name] == "function" then
                return OldNameCall(Event, unpack(EventOverrides[Event.Name](select(2, unpack(Args)))))
            elseif MethodOverrides[Event.Name] and MethodOverrides[Event.Name][Args[1]] then
                return OldNameCall(Event, MethodOverrides[Event.Name][Args[1]](select(2, unpack(Args))))
            end
        end
        return OldNameCall(Event, ...)
    end))
    ---------------------------------------------------
	info("Hooking global __index")
    do
        local proxyEv = setmetatable({}, {
            __namecall = function() return nil end,
            __index = function() return nil end
        })
        local isA = game.IsA
        local findFirstChild = game.FindFirstChild
        OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, Key, ...)
            --// spoof!!!!!! stu pit antichet:(
            local args = { ... }
            if not checkcaller() then
                if isA(self, "Stats") then
                    local prop = args[1]
                    local value = 0
                    if prop == "DataReceiveKbps" then
                        value = math.random(6236, 9000) / 100
                    elseif prop == "DataSendKbps" then
                        value = math.random(1200, 6400) / 10000
                    end
                    return value
                else
                    local child = findFirstChild(self, Key)
                    if child and isA(child, "RemoteEvent") and tonumber(Key) then
                        return nil
                    end
                end
            end
            return OldIndex(self, Key, ...)
        end))
    end
    ---------------------------------------------------

	while game:GetService("Players").PreferredPlayersInternal == 0 do wait() end
    local isInMenu = game.PlaceId == 6808416928
    if isInMenu then
        title("Aimblox - AfoHub - Menu")
        info("You are in the menu :D");
        isInMenu = true;
        --[[
        game.DescendantAdded:Connect(function(L)
            if L:IsA("LocalScript") then
                L.Disabled = true
            end
        end)
		repeat wait() until false--]]
    else
        title("Aimblox - AfoHub - In Game")
        info("You are in a match :3");
        isInMenu = false;
    end

    while not game:GetService("ReplicatedStorage") do wait() end

    local replicatedstorage = game:GetService("ReplicatedStorage")
    local replicatedfirst = game:GetService("ReplicatedFirst")
    local teleportservice = game:GetService("TeleportService")
    local httpservice = game:GetService("HttpService")
    local runservice = game:GetService("RunService")
    local lighting = game:GetService("Lighting")
    local stats = game:GetService("Stats")

    --// Events
    info("Getting remotes")
    local remotes = replicatedstorage:WaitForChild("Remotes")
    info("Getting team remote")
    local switchTeam = remotes:WaitForChild("SelectTeam")
    info("Getting shoot remote")
    local shoot = remotes:WaitForChild("GunShot")
    --// Modules
    info("Getting client modules")
    local client = replicatedstorage:WaitForChild("Client")

    --// Module cont.
    info("Getting remote caller")
    local caller = client:WaitForChild("RemoteCaller")
    info("Getting shared")
    local repshared = replicatedstorage:WaitForChild("Shared")
    info("Getting utils")
    local util = require(repshared:WaitForChild("RemoteUtils"))

    --// Event proxies
    --[[
    EventOverrides["ReplicateSound"] = function(Sound, ...)
        target = target or ClosestPlayerToMouse()
        local part = target.Character and target.Character.Head
        if Sound == "ShootSound" and o.do_silentaim and target and part then
            caller.RemoteCall(
                shoot,
                { target },
                workspace.CurrentCamera:FindFirstChildOfClass("Model").Name,
                utils.PackVector(part.Position),
                part,
                "ADS",
                0
            )
            silentEvent:Fire(part, part.Position, Vector3.new(0, 0, 0), 0)
        end
        return { Sound, ... }
    end--]]

    --// Options
    o.do_debug = true
    -- // Game options
    o.walkspeed = 14
    o.gravity = 196
    o.do_chatspam = false
    o.do_noclip = false
    o.chatspam_message = "AfoHub winning!"
    o.do_esp = false
    o.esp_highlighttarget = false
    o.esp_highlightcolor = Color3.new(1, 1, 0)
    o.esp_teamcolor = Color3.new(0, 1, 0)
    o.esp_enemycolor = Color3.new(1, 0, 0)
    o.viewmodel_offset = { x = 0, y = 0, z = 0, roll = 0 }
    o.esp_showteammates = false
    o.esp_text = false
    o.esp_tracers = false
    o.esp_boxes = false
    o.do_aimbot = false
    o.do_silentaim = false
    o.do_fullbright = false
    o.do_autofarm = false
    o.do_infiniteammo = false
    o.do_alwaysauto = false
    o.do_nocooldown = false
    o.do_alwaysequipped = false
    o.do_norecoil = false
    o.do_alwayscanshoot = false
    o.forced_state = "Don't force"
    o.team = "Don't force"
    o.silentfov = 70
    o.viewmodel_fov = 70
    o.fovcolor = Color3.new(1, 1, 1)
    o.usefov = false

    -- // Lobby options
    o.lobby = setmetatable({}, {})
    
    local defaults = o
    --// Save/Load
    local fn = "afohub_settings.ab.json"
    function saveOptions()
        local str = httpservice:JSONEncode(o)
        local suc, err = pcall(writefile, fn, str)
        if not suc then
            messagebox(tostring(err), "An error ocurred", 0)
        end
    end
    do -- load settings
        local suc, err = pcall(function()
            local _o = httpservice:JSONDecode(readfile(fn))
            o = _o
            for key, value in pairs(defaults) do
                if o[key] == nil then
                    o[key] = value
                end
            end
        end)
        if not suc then
            --messagebox(tostring(err), "Failed to load config", 0)
        end
    end

    function rejoin(sameInstance)
        if not sameInstance then
            teleportservice:Teleport(game.PlaceId, localplayer)
        else
            teleportservice:TeleportToPlaceInstance(game.PlaceId, game.JobId, localplayer, nil, teleportservice:GetLocalPlayerTeleportData())
        end
    end

    local closestPlayer = nil

    info("Get players")
    local players = game:GetService("Players")
    info("Get localplayer")
    while players.LocalPlayer == nil do wait() end
    local localplayer = players.LocalPlayer
    ok("Got " .. localplayer.Name)
    info("Get mouse")
    local mouse = localplayer:GetMouse()
    info("Get playergui")
    local playergui = localplayer:WaitForChild("PlayerGui")
	info("Get playerscripts")
	local playerscripts = localplayer:WaitForChild("PlayerScripts")

    --// Silent aim proxy
    local gunController, gun, projectile, gunEngine do
        --if not isInMenu then
            --// Module shims
            local old_identity = syn.get_thread_identity()
            syn.set_thread_identity(2)
            local engine = client:WaitForChild("Components"):WaitForChild("GunEngine")
            local gun_module = engine:WaitForChild("Gun")
            local proj_module = engine:WaitForChild("Projectile")
            gun = require(gun_module)
            projectile = require(proj_module)
            gunEngine = require(engine)
            info("Hooking gunengine")
            local oldGunEngine = gunEngine
            gunEngine = oldGunEngine
            function gunEngine.CanClientShoot()
                if o.do_alwayscanshoot then
                    return true
                else
                    return gunEngine.Enabled and not gunEngine.MenuLocked
                end
            end
            local oldDoRecoil = gunEngine.DoRecoil
            function gunEngine.DoRecoil(...)
                if not o.do_norecoil then
                    return oldDoRecoil(...)
                end
            end
            ok("Hooked!")
            info("Hooking gunengine.gun")
            local oldFire = gun._FireInternal
            function gun:_FireInternal(lookVector, ...)
                --local target = ClosestPlayerToMouse()
                gunController = self
                local newVector = (o.do_silentaim and target and CFrame.new(localplayer.Character.Head.Position, target.Character.Head.Position).LookVector.Unit * 10000) or lookVector
                if o.do_debug then
                    local args = { ... }
                    info("== Shoot ==")
                    info("target ->", target)
                    info("old ->", lookVector)
                    info("new ->", newVector)
                    for _, arg in pairs(args) do
                        info("arg" .. tostring(_), "->", arg)
                    end
                    info("== ===== ==")
                end
                return oldFire(self, newVector, ...)
            end
            ok("Hooked!")
            info("Hooking gunengine.projectile")
            local oldNew = projectile.new
            function projectile.new(from, to, ...)
                local newTo = (o.do_silentaim and target and target.Character.Head.Position) or to
                return oldNew(from, newTo, ...)
            end
            ok("Hooked!")
            syn.set_thread_identity(old_identity)
        --end
    end
    getgenv(0).__gunengine = gunEngine

    do
        local proxy = Instance.new("Camera")
        function W2S(Cam, Vec3)
            return proxy.WorldToScreenPoint(Cam, Vec3)
        end
    end
    function ClosestPlayerToMouse()
        local target = nil
        local dist = math.huge
        for i, v in pairs(players:GetPlayers()) do
            if v ~= localplayer then
                if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart") and v.TeamColor ~= localplayer.TeamColor then
                    local screenpoint = W2S(workspace.CurrentCamera, v.Character.HumanoidRootPart.Position)
                    local check = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenpoint.X, screenpoint.Y)).magnitude
                    if check < dist then
                        target  = v.Character
                        dist = check
                    end
                end
            end
        end
        return target
    end
    
    function GetPlayersWithinFOV()
        local playerlist = {}
        local origin = localplayer.Character.Head.Position
        for _, player in ipairs(players:GetPlayers()) do
            if player and player.TeamColor ~= localplayer.TeamColor and player ~= localplayer and player.Character and player.Character.Head then
                local head = player.Character and player.Character:FindFirstChild("Head")
                if (head) then
                    local _, onScreen = W2S(workspace.CurrentCamera, head.Position)
                    if (onScreen) then
                        table.insert(playerlist, player)
                    end
                end
            end
        end
        return playerlist
    end

    --//

    info("Getting ui library")
    local library = loadstring(game:HttpGet("https://hub.afo.xyz/include/ui.lua", true))()
    info("Getting esp library")
    local ESP = loadstring(game:HttpGet("https://hub.afo.xyz/include/esp.lua", true))()

    -- silent target
    local onCircleStateUpdated do
        local circle = Drawing.new('Circle') do
            circle.Visible = false;
            circle.Color = Color3.new(1, 1, 1)
            circle.Thickness = 1;
            circle.Transparency = 1;
        end

        function onCircleStateUpdated(state)
            if type(state) == 'boolean' then
                circle.Visible = state;
            elseif type(state) == 'number' then
                circle.Radius = state
            elseif typeof(state) == 'Color3' then
                circle.Color = state;
            end
        end

        runservice.Heartbeat:Connect(function()
            local vps = workspace.CurrentCamera.ViewportSize
            local origin = Vector2.new(vps.X / 2, vps.Y / 2)

            circle.Position = origin
            circle.Visible = gunEngine.EnableAmmo

            local targets = {};
            local cCharacter = localplayer.Character

            if (not cCharacter) then
                return
            end

            for _, plr in pairs(players:GetPlayers()) do
                if plr == localplayer then
                    continue
                end

                local character = plr.Character;
                local humanoid = (character and character:FindFirstChildWhichIsA('Humanoid'))
                local head = (character and character:FindFirstChild('Head'))
                local isFFA = #game:GetService("Teams"):GetChildren() ~= 0

                if (not humanoid) or (humanoid.Health <= 0) or (plr.Team and plr.Team == localplayer.Team) then
                    continue
                end

                local vector, visible = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                if (not visible) then
                    continue
                end

                local vector = Vector2.new(vector.X, vector.Y)
                local distance = math.floor((vector - origin).magnitude)

                if o.usefov then
                    if distance > o.silentfov then
                        continue
                    end
                end

                targets[#targets + 1] = { plr, distance }
            end

            table.sort(targets, function(a, b) return a[2] < b[2] end)

            local _target = targets[1]
            if _target then
                target = _target[1]
            else
                target = nil
            end
        end)
    end

    -- visuals
    do
        ESP:Toggle(false);

        ESP.FaceCamera = true;
        ESP.TeamMates = false;
        ESP.Names = false;
        ESP.Tracers = false;
        ESP.Boxes = false;

        function ESP.Overrides.IsTeamMate(player)
            return player.Team and (player.Team == localplayer.Team)
        end

        function ESP.Overrides.GetColor(character)
            local plr = ESP:GetPlrFromChar(character)
            if plr then
                local isSameTeam = ESP:IsTeamMate(plr)
                if (o.esp_highlighttarget and plr == target) then
                    return o.esp_highlightcolor
                end
                return (isSameTeam and o.esp_teamcolor or o.esp_enemycolor)
            end
            return nil
        end

        function ESP.Overrides.GetTeam(plr)
            if plr.Team then
                return plr.Team
            end
            return nil
        end	
    end
    
    info("Initializing ui")
    local ui = library:CreateWindow("AfoHub")
    if isInMenu then

    else --//IN GAME
        --
        local movement = ui:AddFolder("Movement")
        local visuals = ui:AddFolder("Visuals")
        local aim = ui:AddFolder("Aim")
        local gun = ui:AddFolder("Gun Mods")
        local misc = ui:AddFolder("Misc")

        movement:AddSlider({
            text = "Speed",
            value = o.walkspeed,
            min = 14,
            max = 70,
            callback = function(v) o.walkspeed = v end
        })
        movement:AddSlider({
            text = "Gravity",
            value = o.gravity,
            min = 12,
            max = 196,
            callback = function(v) o.gravity = v end
        })
        movement:AddToggle({
            text = "No Action Cooldown",
            state = o.do_nocooldown,
            callback = function(v) o.do_nocooldown = v end
        })

        visuals:AddToggle({
            text = "Enable",
            state = o.do_esp,
            callback = function(v) o.do_esp = v ESP:Toggle(v) end
        })
        visuals:AddColor({
            text = "Enemy Color",
            color = { o.esp_enemycolor.r, o.esp_enemycolor.g, o.esp_enemycolor.b },
            callback = function(v) o.esp_enemycolor = v end
        })
        visuals:AddColor({
            text = "Team Color",
            color = { o.esp_teamcolor.r, o.esp_teamcolor.g, o.esp_teamcolor.b },
            callback = function(v) o.esp_teamcolor = v end
        })
        visuals:AddToggle({
            text = "Show Teammates",
            state = o.esp_showteammates,
            callback = function(v) o.esp_showteammates = v ESP.TeamMates = v end
        })
        visuals:AddToggle({
            text = "Show Names",
            state = o.esp_text,
            callback = function(v) o.esp_text = v ESP.Names = v end
        })
        visuals:AddToggle({
            text = "Tracers",
            state = o.esp_tracers,
            callback = function(v) o.esp_tracers = v ESP.Tracers = v end
        })
        visuals:AddToggle({
            text = "Boxes",
            state = o.esp_boxes,
            callback = function(v) o.esp_boxes = v ESP.Boxes = v end
        })
        visuals:AddToggle({
            text = "Highlight Target",
            state = o.esp_highlighttarget,
            callback = function(v) o.esp_highlighttarget = v end
        })
        visuals:AddColor({
            text = "Highlight Color",
            color = {  o.esp_highlightcolor.r, o.esp_highlightcolor.g, o.esp_highlightcolor.b },
            callback = function(v) o.esp_highlightcolor = v end
        })
        visuals:AddColor({
            text = "FOV Circle Color",
            color = o.fovcolor,
            callback = function(v) o.fovcolor = v onCircleStateUpdated(v) end
        }) onCircleStateUpdated(o.fovcolor)
        visuals:AddSlider({
            text = "Viewmodel Offset X",
            value = o.viewmodel_offset.x,
            min = -200,
            max = 200,
            callback = function(v) o.viewmodel_offset.x = v / 100 end
        })
        visuals:AddSlider({
            text = "Viewmodel Offset Y",
            value = o.viewmodel_offset.y,
            min = -200,
            max = 0,
            callback = function(v) o.viewmodel_offset.y = v / 100 end
        })
        visuals:AddSlider({
            text = "Viewmodel Offset Z",
            value = o.viewmodel_offset.z,
            min = 0,
            max = 780,
            callback = function(v) o.viewmodel_offset.z = v / -100 end
        })
        visuals:AddSlider({
            text = "Viewmodel Roll",
            value = o.viewmodel_offset.roll,
            min = 0,
            max = 360,
            callback = function(v) o.viewmodel_offset.roll = v end
        })
        
        visuals:AddSlider({
            text = "Field Of View",
            value = o.viewmodel_fov,
            min = 70,
            max = 120,
            callback = function(v) o.viewmodel_fov = v end
        })

        aim:AddToggle({
            text = "Use FOV",
            state = o.usefov,
            callback = function(v) o.usefov = v onCircleStateUpdated(v) end
        }) onCircleStateUpdated(o.usefov)
        aim:AddSlider({
            text = "FOV",
            value = o.silentfov,
            min = 0,
            max = 900,
            callback = function(v) o.silentfov = v onCircleStateUpdated(v) end
        }) onCircleStateUpdated(o.silentfov)
        aim:AddToggle({
            text = "Silent Aim",
            state = o.do_silentaim,
            callback = function(v) o.do_silentaim = v end
        })
        aim:AddBind({
            text = "Force Shoot",
            key = "F",
            hold = true,
            callback = function()
                if currentGun.GunFiringType == "Projectile" then
                    currentGun:Fire(true)
                    delay(0.01, function()
                        currentGun:Fire(false)
                    end)
                else
                    currentGun:_FireInternal(mouse.Hit.LookVector.Unit * 10000)
                end
            end
        })
        aim:AddToggle({
            text = "Auto Kill Farm",
            state = o.do_autofarm,
            callback = function(v) o.do_autofarm = v end
        })
        
        gun:AddToggle({
            text = "Infinite Ammo",
            state = o.do_infiniteammo,
            callback = function(v) o.do_infiniteammo = v end
        })
        gun:AddToggle({
            text = "No Recoil",
            state = o.do_norecoil,
            callback = function(v) o.do_norecoil = v end
        })
        gun:AddToggle({
            text = "Always Allow Shooting",
            state = o.do_alwayscanshoot,
            callback = function(v) o.do_alwayscanshoot = v end
        })
        gun:AddToggle({
            text = "Always Auto",
            state = o.do_alwaysauto,
            callback = function(v) o.do_alwaysauto = v end
        })

        misc:AddList({
            text = "Force State",
            value = o.forced_state,
            values = { "Don't force", "Default", "ADS", "Sprinting", "Crouching" },
            callback = function(v) o.forced_state = v end
        })
        misc:AddList({
            text = "Force Team",
            value = o.team,
            values = { "Don't force", "Red", "Green", "Blue", "Yellow" },
            callback = function(v) o.team = v switchTeam:FireServer(o.team) end
        })
        misc:AddToggle({
            text = "Auto-Equip Weapons",
            state = o.do_alwaysequipped,
            callback = function(v) o.do_alwaysequipped = v end
        })
    end
    ui:AddToggle({
        text = "Debug Mode",
        state = o.do_debug,
        callback = function(value)
            o.do_debug = value
        end
    })
    ui:AddButton({
        text = "Save Options",
        callback = saveOptions
    })

    library:Init()
    ---------------------------------------------------
    local TweenService = game:GetService("TweenService")
    spawn(function()
        while wait(4) do
            if o.team ~= "Don't force" then
                switchTeam:FireServer(o.team)
            end
        end
    end)
    runservice.RenderStepped:Connect(function()
        local character = localplayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        currentGun = gunEngine and gunEngine.CurrentGuns and (gunEngine.CurrentGuns[gunEngine.CurrentGun] or gunEngine.CurrentGuns[1])
        if o.do_autofarm then
            oldFire(currentGun, localplayer.Character.Head.Position)
        end
        if o.jumppower ~= 30 and humanoid then
            humanoid.JumpPower = o.jumppower
        end
        if o.walkspeed ~= 14 and humanoid then
            humanoid.WalkSpeed = o.walkspeed
        end
        if currentGun then
            if o.do_infiniteammo then
                currentGun.Ammo = math.huge
            end
            if o.do_alwaysauto then
                currentGun.AutoFiring = true
                currentGun.FiringMode = "Auto"
            end
            if o.do_alwayscanshoot then
                currentGun.NextShot = -math.huge
                currentGun.Reloading = false
                currentGun.PerformingAction = false
            end
            if o.do_nocooldown then
                gunEngine.JumpCooldownTime = -1
                gunEngine.Sliding = false
                gunEngine.TimeSinceSprint = 50000
            end
            gunEngine.ViewModelOffset = CFrame.new(o.viewmodel_offset.x, o.viewmodel_offset.y, o.viewmodel_offset.z) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(o.viewmodel_offset.roll or 0))
        end
        if gunEngine then
            if o.do_alwaysequipped then
                gunEngine.Enabled = true
                gunEngine.EnableAmmo = true
            end
            if o.viewmodel_fov ~= 70 then
                gunEngine.FieldOfView = o.viewmodel_fov
            end
            if o.forced_state ~= "Don't force" then
                gunEngine._CurrentState = o.forced_state
            end
        end
        if o.gravity ~= 196 then
            workspace.Gravity = o.gravity
        end
    end)
    --// Esp

    --// Finalize
    ok("AfoHub loaded!")
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Welcome to AfoHub", Text = "Made by Afoxie on V3rm", Image = "rbxassetid://7091101767" })
    getgenv(0).__AHLOADED = true
end))
