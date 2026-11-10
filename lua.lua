-- Code Sniper: live context, announcement memory, compound riddles, and growing code prefixes.
-- Optional BEFORE launch:
-- getgenv().SpookyCodeFacts = {["my name"]="SAMMY", ["your exact riddle text"]="ANSWER"}
-- getgenv().SpookyCodeOptions = {SubmitGap=0.2} -- minimum 0.2 seconds
-- Diagnostics: getgenv().SpookyCodeRuntime.TestRiddle("your riddle") -- never submits
-- No uploaded proxy, third-party key, callback hooks, or guessed server remotes are used.
local env = getgenv()
if env.SpookyCodeRuntime and env.SpookyCodeRuntime.Stop then
    env.SpookyCodeRuntime.Stop()
end
local runtime = {alive=true, connections={}, version="2026-11-08-release-clues"}
env.SpookyCodeRuntime = runtime
function runtime.Stop()
    if not runtime.alive then return end
    runtime.alive = false
    for _, connection in ipairs(runtime.connections) do pcall(function() connection:Disconnect() end) end
    runtime.connections = {}
    if runtime.gui then runtime.gui:Destroy() end
end
local function connect(signal, callback)
    local connection = signal:Connect(function(...)
        if runtime.alive then return callback(...) end
    end)
    runtime.connections[#runtime.connections + 1] = connection
    return connection
end
local StartMainScript

-- Open the main panel immediately; no fullscreen intro.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

StartMainScript = function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local _enabled = true
	local _autoSubmit = true
	local _seen = {}
	local _lockedBox = nil
	local CodeSmall
    local resetStack

	local Parser = (function()
-- Pure Lua parser: no HTTP, GUI access, dynamic evaluation, or redemption.
local Parser = {}

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Parser.clean(s)
    s = tostring(s or ""):gsub("\r", "")
    s = s:gsub("<[^>]->", "")
    for entity, value in pairs({["&lt;"]="<", ["&gt;"]=">", ["&quot;"]='"', ["&apos;"]="'", ["&amp;"]="&"}) do
        s = s:gsub(entity, value)
    end
    return trim(s)
end

local function code(s)
    s = trim(s):upper()
    if #s < 1 or #s > 80 or not s:match("^[A-Z0-9_%-]+$") then return nil end
    return s
end

local function boundary(s, word)
    return s:find("%f[%a]" .. word .. "%f[%A]") ~= nil
end

local function arithmetic(expression)
    -- Recursive descent, never loadstring: normal precedence and parentheses.
    local s = expression:gsub("%s+", "")
    if #s == 0 or #s > 100 or s:find("[^%d%.%+%-%*/%%%(%)%^]") then return nil end
    local i = 1
    local sum, product, power, atom
    atom = function()
        local c = s:sub(i, i)
        if c == "+" or c == "-" then
            i = i + 1
            local value = atom()
            return c == "-" and -value or value
        end
        if c == "(" then
            i = i + 1
            local value = sum()
            assert(s:sub(i, i) == ")", "missing parenthesis")
            i = i + 1
            return value
        end
        local number = s:sub(i):match("^%d+%.?%d*") or s:sub(i):match("^%.%d+")
        assert(number, "expected number")
        i = i + #number
        return assert(tonumber(number))
    end
    power = function()
        local value = atom()
        if s:sub(i, i) == "^" then
            i = i + 1
            value = value ^ power()
        end
        return value
    end
    product = function()
        local value = power()
        while true do
            local op = s:sub(i, i)
            if op ~= "*" and op ~= "/" and op ~= "%" then break end
            i = i + 1
            local right = power()
            assert((op ~= "/" and op ~= "%") or right ~= 0, "division by zero")
            if op == "*" then value = value * right
            elseif op == "/" then value = value / right
            else value = value % right end
        end
        return value
    end
    sum = function()
        local value = product()
        while true do
            local op = s:sub(i, i)
            if op ~= "+" and op ~= "-" then break end
            i = i + 1
            local right = product()
            value = op == "+" and value + right or value - right
        end
        return value
    end
    local ok, value = pcall(sum)
    if not ok or i <= #s or value ~= value or math.abs(value) > 1e12 then return nil end
    return string.format("%.10g", value)
end

-- SAB history snapshot through Update 73 (October 31, 2026).
-- Numbered releases: https://stealabrainrot.wiki/wiki/update-log/
local updateDates = {
    "2025-05-31", "2025-06-07", "2025-06-14", "2025-06-21", "2025-06-28", -- 1–5
    "2025-07-05", "2025-07-12", "2025-07-18", "2025-07-25", "2025-08-01", -- 6–10
    "2025-08-08", "2025-08-15", "2025-08-23", "2025-08-30", "2025-09-06", -- 11–15
    "2025-09-13", "2025-09-20", "2025-09-27", "2025-10-04", "2025-10-11", -- 16–20
    "2025-10-18", "2025-10-25", "2025-11-01", "2025-11-08", "2025-11-15", -- 21–25
    "2025-11-22", "2025-11-29", "2025-12-06", "2025-12-13", "2025-12-20", -- 26–30
    "2025-12-27", "2026-01-03", "2026-01-10", "2026-01-17", "2026-01-24", -- 31–35
    "2026-01-31", "2026-02-07", "2026-02-14", "2026-02-21", "2026-02-28", -- 36–40
    "2026-03-07", "2026-03-14", "2026-03-21", "2026-03-28", "2026-04-04", -- 41–45
    "2026-04-11", "2026-04-18", "2026-04-25", "2026-05-02", "2026-05-09", -- 46–50
    "2026-05-16", "2026-05-23", "2026-06-13", "2026-06-20", "2026-06-27", -- 51–55
    "2026-07-04", "2026-07-11", "2026-07-18", "2026-07-25", "2026-08-01", -- 56–60
    "2026-08-08", "2026-08-15", "2026-08-22", "2026-08-29", "2026-09-05", -- 61–65
    "2026-09-12", "2026-09-19", "2026-09-26", "2026-10-03", "2026-10-10", -- 66–70
    "2026-10-17", "2026-10-24", "2026-10-31", -- 71–73
    [52.5] = "2026-05-30",
    [52.75] = "2026-06-06",
}

local milestones = {}
local function addMilestone(update, ...)
    for _, name in ipairs({...}) do milestones[name] = update end
end
addMilestone(1, "secret rarity", "gold mutation", "diamond mutation")
addMilestone(2, "bloodmoon", "blood moon", "bloodmoon event", "blood moon event", "bloodrot mutation", "first event", "first ever event")
addMilestone(4, "rainbow mutation", "rainbow machine")
addMilestone(5, "traits", "taco trait")
addMilestone(6, "candy mutation", "candy aurora", "candy aurora event")
addMilestone(7, "lucky blocks", "first lucky blocks")
addMilestone(8, "bubblegum machine")
addMilestone(9, "lava mutation", "molten event")
addMilestone(10, "fuse machine", "first fuse machine")
addMilestone(12, "brazil event")
addMilestone(13, "admin war", "admin abuse war", "galaxy event", "galaxy mutation")
addMilestone(14, "og rarity", "first og", "first og brainrot", "strawberry elephant")
addMilestone(15, "craft machine")
addMilestone(16, "extinct event")
addMilestone(17, "mexico event")
addMilestone(18, "yin yang event", "yin yang mutation")
addMilestone(19, "los lucky blocks", "rebirth 16")
addMilestone(20, "witch fuse", "witching hour")
addMilestone(21, "meowl", "second og", "second og brainrot", "indonesia event")
addMilestone(22, "frightrot", "first halloween event")
addMilestone(23, "1x1x1x1 ritual")
addMilestone(24, "brainrot dealer")
addMilestone(25, "radioactive mutation", "fishing")
addMilestone(26, "rebirth 17")
addMilestone(28, "santas fuse", "winter hour")
addMilestone(29, "north pole event", "festive lucky block")
addMilestone(30, "gingerbread town")
addMilestone(31, "skibidi toilet", "third og", "third og brainrot")
addMilestone(32, "cursed mutation")
addMilestone(33, "duels machine")
addMilestone(34, "bruno mars concert")
addMilestone(37, "cupids machine", "heart lucky block")
addMilestone(39, "trade machine", "divine mutation")
addMilestone(40, "divine admin machine")
addMilestone(41, "divine fuse")
addMilestone(42, "st patricks update")
addMilestone(44, "easter hour")
addMilestone(45, "egg lucky block", "egg city")
addMilestone(47, "cyber mutation", "cyber craft machine")
addMilestone(49, "john pork")
addMilestone(50, "backrooms event")
addMilestone(51, "first anniversary", "1 year event")
addMilestone(52, "summer fuse")
addMilestone(52.5, "steakini fattini")
addMilestone(52.75, "caylusaurus")
addMilestone(53, "phantom mutation", "summer lucky block")
addMilestone(54, "trade plaza")
addMilestone(57, "los traders")
addMilestone(59, "crystal mutation")
addMilestone(61, "bee event", "rng machine")
addMilestone(62, "rebirth 19", "la fuse machine")
addMilestone(69, "haunted fuse", "eclipse mutation")
addMilestone(70, "skull lucky block")
addMilestone(71, "spooky scary skeletons event")
addMilestone(73, "headless merchant", "puppetmaster", "scorpi inferni", "jacko jakat", "spooky kart", "scarino crowino")

local historyQuestions = {}
local function addHistory(answer, previewOnly, ...)
    local fact = {answer=answer, previewOnly=previewOnly}
    for _, question in ipairs({...}) do historyQuestions[question] = fact end
end

-- Roblox credits BRAZILIAN SPYDER. Community developer credits list both accounts.
-- https://www.roblox.com/games/109983668079237/Steal-a-Brainrot
-- https://roblox.fandom.com/wiki/BRAZILIAN_SPYDER/Steal_a_Brainrot
addHistory("SpyderSammy", false, "who created sab", "who made sab", "who is the creator of sab", "who is the main developer of sab")
addHistory("do_small", false, "who created sab with sammy", "who co created sab with sammy", "who helped sammy create sab")
addHistory("BRAZILIAN SPYDER", false, "who published sab", "which group published sab", "what group published sab")
addHistory("Noobini Pizzanini", false, "what is the tutorial brainrot", "what is the starter brainrot", "what brainrot do you buy in the tutorial",
    "what is the first brainrot you buy", "what is the first brainrot you buy in sab")
addHistory("Noobini Pizzanini (tutorial starter)", true, "what was the first brainrot", "what is the first brainrot", "name the first brainrot",
    "what was the first brainrot in sab", "what is the first brainrot in sab")

-- Launch references differ on the day. May 2025 is shared by both sources.
-- https://www.robloxgo.com/game/109983668079237/steal-a-brainrot/faq/12345/When-was-Steal-a-Brainrot-created
-- https://stealabrainrot.fandom.com/wiki/Steal_a_Brainrot_(Game)
addHistory("May 16, 2025 (some sources list May 15)", true, "when did sab release", "when was sab released", "when did sab launch",
    "when was sab created", "when did sab come out", "what is the release date of sab", "what was the release date of sab",
    "what date did sab release", "what date was sab released", "on what date was sab released")
addHistory("May", false, "what month did sab release", "what month did sab launch", "what month was sab released", "in what month was sab released")
addHistory("2025", false, "what year did sab release", "what year did sab launch", "what year was sab released", "in what year was sab released")

-- Publicly reported age, shown as a suggestion only.
-- https://www.famousbirthdays.com/people/spydersammy.html
addHistory(function()
    local today = os.date("!*t")
    local age = today.year - 2002
    if today.month < 2 or (today.month == 2 and today.day < 24) then age = age - 1 end
    return tostring(age) .. " (publicly reported birthday)"
end, true, "how old is sammy", "how old is spydersammy", "how old is the creator of sab", "what is sammys age", "what is spydersammys age")

-- https://stealabrainrot.wiki/wiki/bloodmoon-event/
-- https://stealabrainrot.wiki/wiki/update-log/update-14/
-- https://stealabrainrot.wiki/wiki/meowl/
-- https://stealabrainrot.wiki/wiki/update-log/update-31/
-- https://stealabrainrot.wiki/wiki/secret/
-- https://stealabrainrot.wiki/wiki/taco-tuesday/
addHistory("Bloodmoon", false, "what was the first event", "what was the first ever event", "what was the first event in sab", "what is the first event in sab", "what is the first event", "name the first event")
addHistory("Bloodrot", false, "what mutation did bloodmoon introduce", "what mutation did the bloodmoon event add")
addHistory("Strawberry Elephant", false, "what was the first og", "what was the first og brainrot", "what was the first og in sab",
    "what was the first og brainrot in sab", "what is the first og in sab", "what is the first og", "what is the first og brainrot", "name the first og brainrot", "which brainrot introduced og rarity")
addHistory("Meowl", false, "what was the second og", "what was the second og brainrot", "name the second og brainrot")
addHistory("Skibidi Toilet", false, "what was the third og", "what was the third og brainrot", "name the third og brainrot")
addHistory("La Vacca Saturno Saturnita / Los Tralaleritos", true, "what was the first secret", "what was the first secret brainrot", "name the first secret brainrot")
addHistory("2025-08-19", false, "when was the first taco tuesday", "when did taco tuesday start", "when did the first taco tuesday happen")
addHistory("Grow a Garden", false, "what game faced sab in the admin war", "what game did sab face in the admin war")
addHistory("Jandel", false, "who did sammy face in the admin war")

-- Names and stats from https://stealabrainrotgame.wiki/brainrots/ and https://rblxguide.com/games/steal-a-brainrot/brainrots
-- Columns: name, rarity, income, cost, reported route, alternate income, alternate rarity.
local brainrotCatalog = {
    ["1x1x1x1"] = {"1x1x1x1", "Secret", "$1.1M/s", "$256M", "Rituals"},
    ["25"] = {"25", "Secret", "$2.5M/s", "$600M", "Formerly Advent Calendar"},
    ["4th bros"] = {"4th Bros", "Secret", "$3.75M/s", "$800M", "Formerly Spawned only once"},
    ["67"] = {"67", "Secret", "$7.5M/s", "$1.25B", "Admin Lucky Block"},
    ["abyssaloco"] = {"Abyssaloco", "Secret", "$33.3M/s", "$4.3B", "Backrooms Event", "$33.33M/s"},
    ["admin lucky block"] = {"Admin Lucky Block", "Lucky Block", "$0/s", "$100M", "Admin Abuse, Sammy's Base, RNG Machine"},
    ["agarrini la palini"] = {"Agarrini la Palini", "Secret", "$425K/s", "$80M", "Fuse Machine"},
    ["alessio"] = {"Alessio", "Brainrot God", "$85K/s", "$17.5M", "Admin Lucky Block"},
    ["anpali babel"] = {"Anpali Babel", "Brainrot God", "$280K/s", "$48M", "Formerly Brainrot Trader and Craft Machine exclusive"},
    ["antonio"] = {"Antonio", "Secret", "$125M/s", "$50B", "Craft Machine", "$55M/s"},
    ["appelini"] = {"Appelini", "Brainrot God", "$300K/s", "$69M", "Red Carpet"},
    ["aqua dragon"] = {"Aqua Dragon", "Secret", "$0/s"},
    ["aquanaut"] = {"Aquanaut", "Brainrot God", "$245K/s", "$45.5M", nil},
    ["aquarino"] = {"Aquarino", "Secret", "$4.2M/s", "$865M", "Summer Hour"},
    ["arca bros"] = {"Arca Bros", "Secret", "$250M/s"},
    ["arcadopus"] = {"Arcadopus", "Secret", "$5M/s", "$900M", "Sammy's Base"},
    ["arcadragon"] = {"Arcadragon", "Secret", "$215M/s", "$215B", "DLC", "$150M/s"},
    ["astrolero cervalero"] = {"Astrolero Cervalero", "Brainrot God", "$280K/s", "$48M", "Divine Fuse"},
    ["avocadini antilopini"] = {"Avocadini Antilopini", "Epic", "$115/s", "$17.5K", "Red Carpet"},
    ["avocadini guffo"] = {"Avocadini Guffo", "Epic", "$225/s", "$35K", "Red Carpet"},
    ["avocadorilla"] = {"Avocadorilla", "Mythic", "$7K/s", "$2M", "Fuse Machine"},
    ["bacuru and egguru"] = {"Bacuru and Egguru", "Secret", "$24M/s", "$3.8B", "Fuse Machine", "$16M/s"},
    ["ballerina cappuccina"] = {"Ballerina Cappuccina", "Legendary", "$500/s", "$100K", nil},
    ["ballerina peppermintina"] = {"Ballerina Peppermintina", "Brainrot God", "$215K/s", "$37.5M", "North Pole"},
    ["ballerino lololo"] = {"Ballerino Lololo", "Brainrot God", "$200K/s", "$35M", nil},
    ["bambini crostini"] = {"Bambini Crostini", "Epic", "$135/s", "$22.5K", "Red Carpet"},
    ["bambu bambu sahur"] = {"Bambu Bambu Sahur", "Brainrot God", "$275K/s"},
    ["bananita dolphinita"] = {"Bananita Dolphinita", "Epic", "$150/s", "$25K", "Red Carpet / Fishing"},
    ["bananito"] = {"Bananito", "Secret", "$15M/s", "$2B", nil},
    ["bananito bandito"] = {"Bananito Bandito", "Mythic", "$16.5K/s", "$4.9M", "Mythic Lucky Block"},
    ["bananito skelito"] = {"Bananito Skelito", "Secret", "$8.5M/s"},
    ["bandito axolito"] = {"Bandito Axolito", "Legendary", "$1.23K/s", "$290K", "RNG Machine", "$1.2K/s"},
    ["bandito bobritto"] = {"Bandito Bobritto", "Rare", "$35/s", "$4.5K", "Red Carpet"},
    ["baskito"] = {"Baskito", "Secret", "$16M/s", "$2.1B", "Formerly Egg Lucky Block, Eggrot Hunt"},
    ["bat in the box"] = {"Bat-in-the-Box", "Secret", "$22.5M/s"},
    ["bearito cabinito"] = {"Bearito Cabinito", "Secret", "$72.5M/s", "$21B", "Unobtainable(Octo Lucky Block"},
    ["bearo houso"] = {"Bearo Houso", nil, "$0/s"},
    ["beavo potto"] = {"Beavo Potto", "Brainrot God", "$315K/s", "$75M", "Bee Lucky Block"},
    ["bee loco"] = {"Bee Loco", "Mythic", "$13.5K/s", "$4.5M", "Cyber Craft Machine"},
    ["bee lucky block"] = {"Bee Lucky Block", "Lucky Block", "$0/s", "$400M", nil},
    ["belula beluga"] = {"Belula Beluga", "Brainrot God", "$290K/s", "$60M", "Fishing"},
    ["berenjello angello"] = {"Berenjello Angello", "Mythic", "$18K/s", "$5.5M", "Formerly Divine Fuse"},
    ["berryno"] = {"Berryno", "Secret", "$1.5M/s", "$500M", "Red Carpet"},
    ["bisonte giuppitere"] = {"Bisonte Giuppitere", "Secret", "$325K/s", "$80M", "Sammy's Base"},
    ["blackhole goat"] = {"Blackhole Goat", "Secret", "$400K/s", "$75M", nil},
    ["blueberrinni octopusini"] = {"Blueberrinni Octopusini", "Legendary", "$1K/s", "$250K", "Red Carpet / Fishing"},
    ["boatito auratito"] = {"Boatito Auratito", "Secret", "$525K/s", "$115M", "Backrooms Event"},
    ["boba panda"] = {"Boba Panda", "Brainrot God", "$270K/s", "$47M", "Formerly 2026 Fuse Machine"},
    ["bombardini tortinii"] = {"Bombardini Tortinii", "Brainrot God", "$225K/s", "$50M", "Fat Sammy and RNG Machine"},
    ["bombardiro crocodilo"] = {"Bombardiro Crocodilo", "Mythic", "$2.5K/s", "$500K", "Red Carpet"},
    ["bombardiro vaccariro"] = {"Bombardiro Vaccariro", "Secret", "$1M/s", "$250M", "Summer Fuse"},
    ["bombombini gusini"] = {"Bombombini Gusini", "Mythic", "$5K/s", "$1M", "Red Carpet"},
    ["boneca ambalabu"] = {"Boneca Ambalabu", "Rare", "$40/s", "$5K", "Red Carpet"},
    ["boo boo rocket"] = {"Boo Boo Rocket", "Secret", "$37.5M/s"},
    ["boppin bunny"] = {"Boppin Bunny", "Secret", "$80M/s", "$25B", "Formerly DLC"},
    ["brainrot god lucky block"] = {"Brainrot God Lucky Block", "Brainrot God", "$0/s", "$25M", "Red Carpet, Robux Shop, Sammy's Base, Backrooms Event and RNG Machine"},
    ["brasilini berimbini"] = {"Brasilini Berimbini", "Brainrot God", "$285K/s", "$55M", "RNG Machine"},
    ["brr brr patapim"] = {"Brr Brr Patapim", "Epic", "$100/s", "$15K", "Red Carpet, Robux Shop"},
    ["brr es teh patipum"] = {"Brr es Teh Patipum", "Brainrot God", "$225K/s", "$40M", "Unobtainable"},
    ["brri brri bicus dicus bombicus"] = {"Brri Brri Bicus Dicus Bombicus", "Epic", "$175/s", "$30K", "Red Carpet"},
    ["brunito marsito"] = {"Brunito Marsito", "Secret", "$3.5M/s", "$750M", "Unobtainable"},
    ["brutto gialutto"] = {"Brutto Gialutto", "Mythic", "$3K/s", "$600K", "Craft Machine"},
    ["bucketoro"] = {"Bucketoro", "Mythic", "$18.3K/s", "$5.75M", "Summer Fuse", "$18.2K/s"},
    ["bufalino boomberino"] = {"Bufalino Boomberino", "Secret", "$32M/s", "$4B", "Formerly Out of stock"},
    ["buho de fuego"] = {"Buho de Fuego", "Legendary", "$1.85K/s", "$345K", "Formerly Witch Fuse", "$1.8K/s"},
    ["buho de noelo"] = {"Buho de Noelo", "Brainrot God", "$268K/s", "$46.7M", "Formerly Santa's Fuse", "$267.5K/s"},
    ["buho de volto"] = {"Buho de Volto", "Secret", "$2.75M/s", "$650M", "Formerly Cyber Craft Machine", "$2.7M/s"},
    ["buho del cielo"] = {"Buho del Cielo", "Legendary", "$1.35K/s", "$325K", "Formerly Divine Fuse", "$1.3K/s"},
    ["bulbito bandito traktorito"] = {"Bulbito Bandito Traktorito", "Brainrot God", "$205K/s", "$35M", "Brainrot God Lucky Block"},
    ["bumbatron"] = {"Bumbatron", "Secret", "$173M/s", "$140B", "Bee Shop", "$172.5M/s"},
    ["bunito bunito spinito"] = {"Bunito Bunito Spinito", "Secret", "$3M/s", "$900M", "Formerly 2026 Event"},
    ["bunny and eggy"] = {"Bunny and Eggy", "Secret", "$170M/s", "$135B", "Divine Fuse"},
    ["bunny bunny bunny sahur"] = {"Bunny Bunny Bunny Sahur", "Secret", "$2.25M/s", "$575M", "Formerly Easter Hour"},
    ["bunny tralala"] = {"Bunny Tralala", "Brainrot God", "$270K/s", "$47M", "Formerly Egg Lucky Block"},
    ["bunnyman"] = {"Bunnyman", "Secret", "$1.5M/s", "$500M", "Formerly Advent Calendar"},
    ["buntteo"] = {"Buntteo", "Secret", "$850K/s", "$225M", "Formerly Easter Hour"},
    ["burbaloni loliloli"] = {"Burbaloni Loliloli", "Legendary", "$200/s", "$35K", "Red Carpet"},
    ["burguro and fryuro"] = {"Burguro And Fryuro", "Secret", "$150M/s", "$75B", nil},
    ["burrito bandito"] = {"Burrito Bandito", "Secret", "$4M/s", "$850M", nil},
    ["burrito bat"] = {"Burrito Bat", "Secret", "$7M/s", "$1.2B", "Taco Merchant"},
    ["cacasito satalito"] = {"Cacasito Satalito", "Brainrot God", "$240K/s", "$45M", nil},
    ["cachorrito melonito"] = {"Cachorrito Melonito", "Mythic", "$13K/s", "$4.4M", nil},
    ["cacto hipopotamo"] = {"Cacto Hipopotamo", "Rare", "$50/s", "$6.5K", "Red Carpet"},
    ["camera ramena"] = {"Camera Ramena", "Secret", "$17M/s", "$2.3B", "Cyber Craft Machine"},
    ["candi corni"] = {"Candi Corni", "Brainrot God", "$321K/s"},
    ["candini fluffini"] = {"Candini Fluffini", "Secret", "$57.5M/s", "$14B", "RNG Machine"},
    ["cangurato gelato"] = {"Cangurato Gelato", "Secret", "$77.5M/s", "$23.5B", "Red Carpet"},
    ["capi taco"] = {"Capi Taco", "Brainrot God", "$155K/s", "$31M", "Taco Tuesday"},
    ["capibaro celestino"] = {"Capibaro Celestino", "Secret", "$1.7M/s"},
    ["capitano americano"] = {"Capitano Americano", "Secret", "$72.5M/s", "$21B", "Formerly Out of Stock"},
    ["capitano gullini"] = {"Capitano Gullini", "Secret", "$22M/s", "$2.7B", "Summer Fuse"},
    ["capitano moby"] = {"Capitano Moby", "Secret", "$160M/s", "$125B", "Red Carpet"},
    ["cappuccino assassino"] = {"Cappuccino Assassino", "Epic", "$75/s", "$10K", "Red Carpet"},
    ["cappuccino clownino"] = {"Cappuccino Clownino", "Brainrot God", "$285K/s", "$48.5M", "Formerly Spooky Lucky Block"},
    ["caramello filtrello"] = {"Caramello Filtrello", "Legendary", "$1.05K/s", "$255K", "Craft Machine", "$1K/s"},
    ["carloo"] = {"Carloo", "Mythic", "$13.5K/s", "$4.5M", "Admin Lucky Block"},
    ["carrotini brainini"] = {"Carrotini Brainini", "Mythic", "$15K/s", "$4.75M", "Mythic Lucky Block"},
    ["cash or card"] = {"Cash or Card", "Secret", "$100M/s", "$40B", "Red Carpet"},
    ["cavallo virtuoso"] = {"Cavallo Virtuoso", "Mythic", "$7.5K/s", "$2.5M", nil},
    ["caylusaurus"] = {"Caylusaurus", "Secret", "$55M/s", "$12.5B", "Formerly Out of Stock"},
    ["celestial pegasus"] = {"Celestial Pegasus", "Secret", "$175M/s", "$150B", "Secret Lucky Block"},
    ["celularcini viciosini"] = {"Celularcini Viciosini", "Secret", "$22.5M/s", "$2.7B", "Craft Machine"},
    ["centrucci nuclucci"] = {"Centrucci Nuclucci", "Mythic", "$15.5K/s", "$4.8M", "Brainrot Trader"},
    ["cerberus"] = {"Cerberus", "Secret", "$175M/s", "$150B", "Red Carpet"},
    ["chachechi"] = {"Chachechi", "Secret", "$400K/s", "$85M", "Admin Abuse"},
    ["chef crabracadabra"] = {"Chef Crabracadabra", "Legendary", "$600/s", "$150K", "Red Carpet"},
    ["chicken zombie"] = {"Chicken Zombie", "Secret", "$5.5M/s"},
    ["chicleteira bicicleteira"] = {"Chicleteira Bicicleteira", "Secret", "$3.5M/s", "$750M", "Red Carpet and Sammy's Base"},
    ["chicleteira boardeira"] = {"Chicleteira Boardeira", nil, "$0/s"},
    ["chicleteira champeona"] = {"Chicleteira Champeona", "Secret", "$19M/s", "$2.8B", "Spain Event"},
    ["chicleteira cupideira"] = {"Chicleteira Cupideira", "Secret", "$17.5M/s", "$2.5B", "Heart Lucky Block"},
    ["chicleteira noelteira"] = {"Chicleteira Noelteira", "Secret", "$15M/s", "$2B", "Santa's Fuse"},
    ["chicleteira surfeiteira"] = {"Chicleteira Surfeiteira", "Secret", "$16M/s", "$2.1B", "Summer Hour"},
    ["chicleteirina bicicleteirina"] = {"Chicleteirina Bicicleteirina", "Secret", "$4M/s", "$850M", nil},
    ["chicli chicla"] = {"Chicli Chicla", "Secret", "$47.5M/s"},
    ["chihuanini taconini"] = {"Chihuanini Taconini", "Brainrot God", "$45K/s", "$8.5M", "Taco Lucky Block"},
    ["chill puppy"] = {"Chill Puppy", "Secret", "$4M/s", "$850M", "Formerly Fuse Machine Was Replaced By Divine Fuse"},
    ["chillin chili"] = {"Chillin Chili", "Secret", "$25M/s", "$2.5B", "Formerly Out of Stock"},
    ["chimnino"] = {"Chimnino", "Secret", "$14M/s", "$1.9B", "Festive Lucky Block"},
    ["chimpanzini bananini"] = {"Chimpanzini Bananini", "Legendary", "$300/s", "$50K", "Red Carpet"},
    ["chimpanzini spiderini"] = {"Chimpanzini Spiderini", "Secret", "$350K/s", "$100M", "Formerly replaced by Sammyni Spyderini"},
    ["chipso and queso"] = {"Chipso and Queso", "Secret", "$25M/s", "$2.5B", "Formerly Out of Stock"},
    ["chocco bunny"] = {"Chocco Bunny", "Legendary", "$1.4K/s", "$328K", "Formerly Santa's Fuse"},
    ["chrismasmamat"] = {"Chrismasmamat", "Brainrot God", "$278K/s", "$47.8M", "Festive Lucky Block", "$277.5K/s"},
    ["churrito bunnito"] = {"Churrito Bunnito", "Secret", "$21M/s", "$2.6B", "Formerly Egg Lucky Block and Eggrot Hunt"},
    ["cigno fulgoro"] = {"Cigno Fulgoro", "Secret", "$20M/s"},
    ["clickerino crabo"] = {"Clickerino Crabo", "Legendary", "$1K/s", "$250K", "Formerly Brainrot Dealer / Brainrot Trader"},
    ["cloverat clapat"] = {"Cloverat Clapat", "Secret", "$60M/s", "$15B", "Lucky Pot"},
    ["clovkur kurkur"] = {"Clovkur Kurkur", "Brainrot God", "$305K/s", "$70M", "Unobtainable"},
    ["co co co sahur"] = {"Co Co Co Sahur", "Secret", "$1.7M/s"},
    ["cobra gelato"] = {"Cobra Gelato", "Secret", "$77.5M/s"},
    ["coco and mango"] = {"Coco and Mango", "Secret", "$33.5M/s", "$4.5B", "Summer Fuse"},
    ["cocoa assassino"] = {"Cocoa Assassino", "Brainrot God", "$291K/s", "$61M", nil},
    ["cocofanto elefanto"] = {"Cocofanto Elefanto", "Brainrot God", "$19K/s", "$6.5M", "Red Carpet, Backrooms Event"},
    ["cocosini mama"] = {"Cocosini Mama", "Legendary", "$1.2K/s", "$285K", "Formerly Summer Fuse"},
    ["cocoteddy"] = {"Cocoteddy", "Mythic", "$15K/s", "$4.7M", "Summer Fuse"},
    ["coffin tung tung tung sahur"] = {"Coffin Tung Tung Tung Sahur", "Secret", "$0/s", "$500M", "Admin Abuse", "$1.5M/s"},
    ["cola cat"] = {"Cola Cat", "Brainrot God", "$275K/s", "$47.5M", "Not obtainable yet (DLC", "$160M/s", "Secret"},
    ["conetto morsetto"] = {"Conetto Morsetto", "Secret", "$10M/s", "$1.5B", "Bee Shop"},
    ["cooki and milki"] = {"Cooki and Milki", "Secret", "$155M/s", "$100B", "Santa's Fuse"},
    ["corn corn corn sahur"] = {"Corn Corn Corn Sahur", "Brainrot God", "$250K/s", "$45M", "Piñata", "$250k/s"},
    ["cornetto morsetto"] = {"Cornetto Morsetto", nil, "$0/s"},
    ["crabbo limonetta"] = {"Crabbo Limonetta", "Brainrot God", "$235K/s", "$46M", "Admin Lucky Block, Fishing"},
    ["craburger"] = {"Craburger", "Secret", "$1.3M/s", "$350M", "unobtainable (Octo Lucky Block"},
    ["cuadramat and pakrahmatmamat"] = {"Cuadramat and Pakrahmatmamat", "Secret", "$1.4M/s", "$400M", "Formerly Brainrot Trader"},
    ["cupcake koala"] = {"Cupcake Koala", "Rare", "$60/s", "$8K", "Formerly Brainrot Dealer / Brainrot Trader"},
    ["cupid cupid sahur"] = {"Cupid Cupid Sahur", "Secret", "$3.1M/s", "$715M", "Formerly Cupid's Machine"},
    ["cupid hotspot"] = {"Cupid Hotspot", "Secret", "$3.5M/s"},
    ["deputy leopard"] = {"Deputy Leopard", "Secret", "$18M/s"},
    ["digi narwhal"] = {"Digi Narwhal", "Secret", "$200M/s", "$200B", "Cyber Craft Machine"},
    ["divino platypio"] = {"Divino Platypio", "Brainrot God", "$160K/s", "$32M", "Formerly Divine Fuse"},
    ["dj panda"] = {"DJ Panda", "Secret", "$17.5M/s", "$2.5B", "Red Carpet"},
    ["doi doi do"] = {"Doi Doi Do", "Epic", "$260/s", "$41K", "Formerly Brainrot Dealer / Brainrot Trader"},
    ["dolphini jetskini"] = {"Dolphini Jetskini", "Brainrot God", "$295K/s", "$64.5M", "Formerly 2026 Fuse Machine", "$294.5K/s"},
    ["donkeyturbo express"] = {"Donkeyturbo Express", "Secret", "$7.5M/s", "$1.25B", "Formerly North Pole Event"},
    ["draculino"] = {"Draculino", "Secret", "$120M/s"},
    ["dragon aquanini"] = {"Dragon Aquanini", "Secret", "$375M/s", "$375B", "Summer Fuse"},
    ["dragon cannelloni"] = {"Dragon Cannelloni", "Secret", "$250M/s", "$250B", "Red Carpet"},
    ["dragon caylusini"] = {"Dragon Caylusini", nil, "$0/s"},
    ["dragon gingerini"] = {"Dragon Gingerini", "Secret", "$350M/s"},
    ["dragon skeletonini"] = {"Dragon Skeletonini", "Secret", "$325M/s"},
    ["dug dug dug"] = {"Dug dug dug", "Secret", "$35M/s", "$5B", "Craft Machine"},
    ["duggy bros"] = {"Duggy Bros", "Secret", "$90M/s", "$30B", "Cyber Craft Machine"},
    ["dul dul dul"] = {"Dul Dul Dul", "Secret", "$375K/s", "$150M", "Admin Abuse"},
    ["dumborino miracello"] = {"Dumborino Miracello", "Brainrot God", "$315K/s", "$75M", "Formerly Divine Fuse Machine"},
    ["easter bunny"] = {"Easter Bunny", "Legendary", "$5.2M/s"},
    ["easter easter easter sahur"] = {"Easter Easter Easter Sahur", "Secret", "$1.25M/s", "$300M", "Egg Lucky Block"},
    ["egg lucky block"] = {"Egg Lucky Block", "Lucky Block", nil, "$300M", "Formerly removed 4/18"},
    ["eggdin egg egg dun"] = {"Eggdin Egg Egg Dun", "Brainrot God", "$310K/s", "$72.5M", "Formerly Egg Lucky Block"},
    ["eid eid eid sahur"] = {"Eid Eid Eid Sahur", "Secret", "$3.5M/s"},
    ["electro quacko"] = {"Electro Quacko", "Legendary", "$1.85K/s", "$345K", "Cyber Craft Machine", "$1.8K/s"},
    ["elefanto frigo"] = {"Elefanto Frigo", "Secret", "$85M/s"},
    ["esok goala"] = {"Esok Goala", "Secret", "$32.5M/s", "$4.2B", "Soccer Board"},
    ["esok sekolah"] = {"Esok Sekolah", "Secret", "$30M/s", "$3B", "Secret Lucky Block"},
    ["espresso signora"] = {"Espresso Signora", "Brainrot God", "$70K/s", "$25M", "Admin Abuse, Backrooms Event and RNG Machine"},
    ["eviledon"] = {"Eviledon", "Secret", "$31.5M/s", "$3.85B", "Fishing"},
    ["examen bros"] = {"Examen Bros", "Secret", "$70M/s", "$20B", "Los Traders"},
    ["extinct ballerina"] = {"Extinct Ballerina", "Brainrot God", "$125K/s"},
    ["extinct matteo"] = {"Extinct Matteo", "Secret", "$625K/s", "$140M", "Formerly Extinct Event"},
    ["extinct tralalero"] = {"Extinct Tralalero", "Secret", "$450K/s", "$125M", "Fishing Event"},
    ["fang fang draculang"] = {"Fang Fang Draculang", "Secret", "$24.5M/s"},
    ["fangaro lupino"] = {"Fangaro Lupino", "Secret", "$7.2M/s"},
    ["festive 67"] = {"Festive 67", "Secret", "$67M/s", "$16B", "Formerly Out of stock"},
    ["festive lucky block"] = {"Festive Lucky Block", "Lucky Block", "$0/s", "$400M", "North Pole"},
    ["fishboard"] = {"Fishboard", "Secret", "$825K/s", "$215M", nil},
    ["fishino clownino"] = {"Fishino Clownino", "Secret", "$120M/s", "$48.5B", "Unobtainable", "$47M/s"},
    ["fizzy soda"] = {"Fizzy Soda", "Mythic", "$17.3K/s", "$4.9M", "Formerly Fuse Machine", "$17.2K/s"},
    ["flancito"] = {"Flancito", "Secret", "$3.75M/s", "$800M", "Formerly Anniversary"},
    ["flappin clover"] = {"Flappin Clover", "Secret", nil, nil, "Lucky Pot"},
    ["flipa sandala"] = {"Flipa Sandala", "Secret", "$6M/s", "$1.1B", "Backrooms Event"},
    ["flippo marino"] = {"Flippo Marino", "Brainrot God", "$316K/s", "$75.5M", "Summer Fuse"},
    ["fluriflura"] = {"Fluriflura", "Common", "$7/s", "$750", "Red Carpet"},
    ["flying dutchman"] = {"Flying Dutchman", "Secret", "$92.5M/s"},
    ["fortunu and cashuru"] = {"Fortunu and Cashuru", "Secret", "$130M/s", "$55B", "Leprechaun Lucky Block"},
    ["foxini lanternini"] = {"Foxini Lanternini", "Secret", "$115M/s", "$47.5B", "'Eid Celebration"},
    ["fragola la la la"] = {"Fragola La La La", "Secret", "$32.5M/s", "$4.2B", "Craft Machine", "$450K/s"},
    ["fragrama and chocrama"] = {"Fragrama and Chocrama", "Secret", "$100M/s", "$40B", "Brainrot Trader"},
    ["frankentteo"] = {"Frankentteo", "Secret", "$700K/s", "$175M", "Witching Hour Event"},
    ["frio ninja"] = {"Frio Ninja", "Brainrot God", "$265K/s", "$46.5M", "Formerly Witch Fuse"},
    ["frogato pirato"] = {"Frogato Pirato", "Epic", "$240/s", "$39K", "Formerly Witch Fuse"},
    ["frogo elfo"] = {"Frogo Elfo", "Rare", "$67/s", "$9.2K", "Formerly Santa's Fuse"},
    ["frostino vampiro"] = {"Frostino Vampiro", "Mythic", "$17.5K/s"},
    ["frullato framingo"] = {"Frullato Framingo", "Secret", "$20M/s", "$3B", "Codes"},
    ["futbolini skatini"] = {"Futbolini Skatini", "Secret", "$4.5M/s", "$875M", "Formerly Cyber Craft Machine"},
    ["ganganzelli trulala"] = {"Ganganzelli Trulala", "Mythic", "$9K/s", "$3.75M", "Fuse Machine"},
    ["gangster footera"] = {"Gangster Footera", "Rare", "$30/s", "$4K", "Red Carpet"},
    ["garama and madundung"] = {"Garama and Madundung", "Secret", "$50M/s", "$10B", "RNG Machine, Red Carpet"},
    ["gato celesto"] = {"Gato Celesto", "Epic", "$250/s", "$40K", "Formerly Divine Fuse"},
    ["gattatino neonino"] = {"Gattatino Neonino", "Brainrot God", "$35K/s", "$7.5M", "Formerly Replaced with Gattatino Nyanino"},
    ["gattatino nyanino"] = {"Gattatino Nyanino", "Brainrot God", "$35K/s", "$7.5M", "Admin Abuse, Backrooms Event and RNG Machine"},
    ["gattino hydrantino"] = {"Gattino Hydrantino", "Secret", "$14.5M/s"},
    ["gattito tacoto"] = {"Gattito Tacoto", "Brainrot God", "$165K/s", "$32.5M", "Taco Tuesday Exclusive (Taco Lucky Block"},
    ["gelatina volatina"] = {"Gelatina Volatina", "Secret", "$2.4M/s", "$590M", "RNG Machine"},
    ["gelato lumacho"] = {"Gelato Lumacho", "Secret", "$1.4M/s", "$400M", "Summer Hour"},
    ["giftini spyderini"] = {"Giftini Spyderini", "Secret", "$1000K/s", "$240M", "North Pole Event", "$999.9K/s"},
    ["ginger cisterna"] = {"Ginger Cisterna", "Brainrot God", "$294K/s", "$63.5M", "Santa's Fuse", "$293.5K/s"},
    ["ginger gerat"] = {"Ginger Gerat", "Secret", "$75M/s", "$22.5B", "Formerly Santa's Shop"},
    ["ginger globo"] = {"Ginger Globo", "Brainrot God", "$258K/s", "$45.7M", "Formerly Santa's Fuse", "$257.5K/s"},
    ["girafa celestre"] = {"Girafa Celestre", "Brainrot God", "$20K/s", "$7.5M", "Red Carpet, Backrooms Event"},
    ["girafini raftini"] = {"Girafini Raftini", "Secret", "$18M/s", "$2.6B", "Octo Lucky Block"},
    ["glaciator"] = {"Glaciator", "Secret", "$2.3M/s", "$580M", "Backrooms Event"},
    ["globa steppa"] = {"Globa Steppa", "Secret", "$27.5M/s", "$3B", "DLC"},
    ["glorbo fruttodrillo"] = {"Glorbo Fruttodrillo", "Legendary", "$750/s", "$200K", "Red Carpet"},
    ["goat"] = {"GOAT", "Secret", "$950K/s", "$238M", "Unobtainable"},
    ["gobblino uniciclino"] = {"Gobblino Uniciclino", "Secret", "$27.5M/s", "$2.8B", "Unobtainable"},
    ["gold and diamond"] = {"Gold and Diamond", "Secret", "$85M/s"},
    ["gold egg"] = {"Gold Egg", "Secret", "$0/s", "$0", "Formerly Eggrot Hunt, Egg City"},
    ["gold elf"] = {"Gold Elf", "Secret", "$0/s", "$0", "Formerly Red Carpet"},
    ["gold gold gold"] = {"Gold Gold Gold", "Secret", "$45M/s", "$8B", "Formerly Leprechaun Lucky Block"},
    ["gorillo subwoofero"] = {"Gorillo Subwoofero", "Mythic", "$7.75K/s", "$2.75M", "Craft Machine", "$68M/s", "Secret"},
    ["gorillo watermelondrillo"] = {"Gorillo Watermelondrillo", "Mythic", "$8K/s", "$3M", nil},
    ["grabatron"] = {"Grabatron", "Secret", "$62.5M/s", "$15B", "DLC"},
    ["graipuss medussi"] = {"Graipuss Medussi", "Secret", "$1M/s", "$250M", "Red Carpet"},
    ["granchiello spiritell"] = {"Granchiello Spiritell", "Brainrot God", "$260K/s", "$46M", "Fishing Event activated in Admin Abuse", "$260k/s"},
    ["granny"] = {"Granny", "Secret", "$4M/s", "$850M", "Formerly Admin Abuse"},
    ["griffin"] = {"Griffin", "Secret", "$400M/s", "$400B", "Divine Fuse"},
    ["grim cheese"] = {"Grim Cheese", "Secret", "$1.6M/s"},
    ["gub"] = {"Gub", "Secret", "$5M/s"},
    ["guerriro digitale"] = {"Guerriro Digitale", "Secret", "$550K/s", "$120M", "Admin Abuse, Admin Lucky Block", "$550k/s"},
    ["guest 666"] = {"Guest 666", "Secret", "$66.6M/s", "$15.6B", nil, "$6.6M/s"},
    ["gym bros"] = {"Gym Bros", "Secret", "$42.5M/s", "$7.5B", "Cyber Craft Machine"},
    ["harpuccino"] = {"Harpuccino", "Mythic", "$14K/s", "$4.6M", "Formerly Divine Fuse"},
    ["headless horseman"] = {"Headless Horseman", "OG", "$600M/s", "$600B", "Witch Fuse", "$550M/s"},
    ["heart lucky block"] = {"Heart Lucky Block", "Lucky Block", "$0/s", "$350M", "Unobtainable"},
    ["hippo golazo"] = {"Hippo Golazo", "Secret", "$1.25M/s", "$300M", "Live Match Events"},
    ["hippo jacuzzo"] = {"Hippo Jacuzzo", "Brainrot God", "$282.5K/s"},
    ["ho ho ho sahur"] = {"Ho Ho Ho Sahur", "Secret", "$3.2M/s", "$725M", "Unobtainable"},
    ["holy arepa"] = {"Holy Arepa", "Common", "$14/s", "$1.7K", "Divine Fuse"},
    ["honey honey bear"] = {"Honey Honey Bear", "Secret", "$32M/s", "$4B", "Bee Shop"},
    ["honey honey narwhal"] = {"Honey Honey Narwhal", "Secret", "$950K/s", "$238M", "Bee Lucky Block"},
    ["hopilikalika hopilikalako"] = {"Hopilikalika Hopilikalako", "Secret", "$55M/s", "$12.5B", "Egg Lucky Block"},
    ["horegini boom"] = {"Horegini Boom", "Secret", "$2.75M/s", "$650M", "Admin Abuse"},
    ["hydra bunny"] = {"Hydra Bunny", "Secret", "$185M/s", "$175B", "Egg Lucky Block"},
    ["hydra dragon cannelloni"] = {"Hydra Dragon Cannelloni", "Secret", "$300M/s", "$300B", "Fuse Machine"},
    ["hydra serpent"] = {"Hydra Serpent", "Secret", "$220M/s"},
    ["ice dragon"] = {"Ice Dragon", "Secret", "$0/s", nil, "Scrapped"},
    ["jacko jack jack"] = {"Jacko Jack Jack", "Brainrot God", "$150K/s", "$30M", "Formerly Witch Fuse"},
    ["jacko jakat"] = {"Jacko Jakat", "Secret", "$41M/s"},
    ["jacko spaventosa"] = {"Jacko Spaventosa", "Mythic", "$16.3K/s", "$4.8M", "Formerly Witch Fuse", "$16.2K/s"},
    ["jackorilla"] = {"Jackorilla", "Secret", "$315K/s", "$80M", "Unobtainable"},
    ["jelly moby"] = {"Jelly Moby", "Secret", "$175M/s", "$150B", "Cyber Craft"},
    ["jingle jingle sahur"] = {"Jingle Jingle Sahur", "Mythic", "$12.3K/s", "$4.3M", "Formerly Santa's Fuse", "$12.2K/s"},
    ["job job job sahur"] = {"Job Job Job Sahur", "Secret", "$700K/s", "$175M", "Red Carpet"},
    ["john doe"] = {"John Doe", "Secret", "$7.5M/s", "$1.25B", "1x1x1x1 Ritual Event"},
    ["john pork"] = {"John Pork", "OG", "$500M/s", "$500B", "Red Carpet"},
    ["jolly jolly sahur"] = {"Jolly Jolly Sahur", "Secret", "$45M/s", "$8B", "Santa's Shop"},
    ["kalika bros"] = {"Kalika Bros", "Secret", "$115M/s", "$47.5B", "Formerly Cyber Craft Machine", "$190M/s"},
    ["karker sahur"] = {"Karker Sahur", "Secret", "$725K/s", "$185M", "Craft Machine"},
    ["karkerheart luvkur"] = {"Karkerheart Luvkur", "Brainrot God", "$297.5K/s"},
    ["karkerkar kurkur"] = {"Karkerkar Kurkur", "Secret", "$325K/s", "$80M", nil},
    ["ketchuru and musturu"] = {"Ketchuru and Musturu", "Secret", "$42.5M/s", "$7.5B", nil},
    ["ketupat bros"] = {"Ketupat Bros", "Secret", "$145M/s"},
    ["ketupat kepat"] = {"Ketupat Kepat", "Secret", "$35M/s", "$5B", "Red Carpet"},
    ["koala parabala"] = {"Koala Parabala", "Brainrot God", "$200K/s"},
    ["kraken"] = {"Kraken", "Secret", "$200M/s"},
    ["krupuk pagi pagi"] = {"Krupuk Pagi Pagi", "Brainrot God", "$290K/s", "$60M", "Aura Farm Boat"},
    ["la anniversary grande"] = {"La Anniversary Grande", "Secret", "$50M/s", "$10B", "Formerly Out of Stock"},
    ["la breakfast combinasion"] = {"La Breakfast Combinasion", "Secret", "$165M/s", "$130B", "RNG Machine"},
    ["la casa boo"] = {"La Casa Boo", "Secret", "$100M/s", "$40B", "Spooky Lucky Block"},
    ["la craft machine"] = {"La Craft Machine", "Secret", "$75M/s"},
    ["la cucaracha"] = {"La Cucaracha", "Secret", "$475K/s", "$110M", "Mexico Event and Backrooms Event"},
    ["la easter grande"] = {"La Easter Grande", "Secret", "$55M/s", "$12.5B", "Formerly Out of Stock"},
    ["la extinct grande"] = {"La Extinct Grande", "Secret", "$23.5M/s", "$3.25B", "Limited Quantity Brainrots"},
    ["la food combinasion"] = {"La Food Combinasion", "Secret", "$90M/s", "$30B", "Taco Lucky Block"},
    ["la fuse machine"] = {"La Fuse Machine", "Secret", "$95M/s", "$35B", "RNG Machine"},
    ["la ginger sekolah"] = {"La Ginger Sekolah", "Secret", "$75M/s", "$23B", "Formerly Festive Lucky Block"},
    ["la grande combinasion"] = {"La Grande Combinasion", "Secret", "$10M/s", "$1B", nil},
    ["la jolly grande"] = {"La Jolly Grande", "Secret", "$30M/s", "$3.5B", "Formerly Out of stock"},
    ["la karkerkar combinasion"] = {"La Karkerkar Combinasion", "Secret", "$600K/s", "$160M", "Craft Machine"},
    ["la lucky grande"] = {"La Lucky Grande", "Secret", "$40M/s", "$7B", "Formerly Out of Stock"},
    ["la romantic grande"] = {"La Romantic Grande", "Secret", "$40M/s", "$7B", "Formerly Out of Stock"},
    ["la sahur combinasion"] = {"La Sahur Combinasion", "Secret", "$2M/s", "$550M", "Craft Machine"},
    ["la secret combinasion"] = {"La Secret Combinasion", "Secret", "$125M/s", "$50B", "Secret Lucky Block", "$95M/s"},
    ["la spooky grande"] = {"La Spooky Grande", "Secret", "$24.5M/s", "$2.9B", "Formerly Out of Stock"},
    ["la summer grande"] = {"La Summer Grande", "Secret", "$60M/s"},
    ["la supreme combinasion"] = {"La Supreme Combinasion", "Secret", "$200M/s", "$200B", "Fuse Machine"},
    ["la taco combinasion"] = {"La Taco Combinasion", "Secret", "$35M/s", "$5B", "Formerly Out of Stock"},
    ["la vacca jacko linterino"] = {"La Vacca Jacko Linterino", "Secret", "$850K/s", "$225M", "Formerly Witching Hour Event exclusive."},
    ["la vacca lepre lepreino"] = {"La Vacca Lepre Lepreino", "Secret", "$1.1M/s", "$255M", "Formerly Leprechaun Lucky Block"},
    ["la vacca prese presente"] = {"La Vacca Prese Presente", "Secret", "$600K/s", "$160M", "Formerly Santa's Fuse"},
    ["la vacca saturno saturnita"] = {"La Vacca Saturno Saturnita", "Secret", "$325K/s", "$80M", nil},
    ["las capuchinas"] = {"Las Capuchinas", "Brainrot God", "$185K/s", "$32.5M", "Unobtainable"},
    ["las sis"] = {"Las Sis", "Secret", "$17.5M/s", "$2.5B", "Formerly Craft Machine"},
    ["las tralaleritas"] = {"Las Tralaleritas", "Secret", "$650K/s", "$150M", "Red Carpet, Fishing, Backrooms, ETM"},
    ["las vaquitas saturnitas"] = {"Las Vaquitas Saturnitas", "Secret", "$750K/s", "$200M", "Rituals"},
    ["lavadorito spinito"] = {"Lavadorito Spinito", "Secret", "$45M/s", "$8B", "Red Carpet"},
    ["lavamanta"] = {"Lavamanta", "Secret", "$28.5M/s"},
    ["lazy ducky"] = {"Lazy Ducky", "Brainrot God", "$255K/s", "$45.5M", "DLC"},
    ["lemonita splashita"] = {"Lemonita Splashita", "Brainrot God", "$280K/s", "$48M", "Summer Fuse"},
    ["leprechaun lucky block"] = {"Leprechaun Lucky Block", "Lucky Block", "$0/s", "$400M", "Unobtainable"},
    ["lerulerulerule"] = {"Lerulerulerule", "Mythic", "$8.75K/s", "$3.5M", "Red Carpet"},
    ["lionel cactuseli"] = {"Lionel Cactuseli", "Legendary", "$650/s", "$175K", "Red Carpet"},
    ["lionello casarello"] = {"Lionello Casarello", "Secret", "$58.5M/s"},
    ["lirili larila"] = {"Lirilì Larilà", "Common", "$3/s", "$250", "Red Carpet"},
    ["list list list sahur"] = {"List List List Sahur", "Secret", "$2M/s", "$550M", "Formerly Winter Hour"},
    ["los 25"] = {"Los 25", "Secret", "$10M/s", "$1.5B", nil},
    ["los 67"] = {"Los 67", "Secret", "$22.5M/s", "$2.75B", "Los Lucky Blocks, Admin Abuse", "$13.5M/s"},
    ["los admins"] = {"Los Admins", "Secret", "$95M/s", "$35B", "Los Traders"},
    ["los amigos"] = {"Los Amigos", "Secret", "$130M/s", "$55B", "Los Taco Blocks"},
    ["los bombinitos"] = {"Los Bombinitos", "Brainrot God", "$220K/s"},
    ["los bros"] = {"Los Bros", "Secret", "$24M/s", "$2.6B", "Formerly Craft Machine"},
    ["los bunitos"] = {"Los Bunitos", "Secret", "$4.2M/s", "$865M", "Formerly Egg Lucky Block", "$4.25M/s"},
    ["los burritos"] = {"Los Burritos", "Secret", "$8.5M/s", "$1.4B", "Los Taco Blocks"},
    ["los candies"] = {"Los Candies", "Secret", "$23M/s", "$3B", "Formerly Santa's Fuse"},
    ["los chicleteiras"] = {"Los Chicleteiras", "Secret", "$7M/s", "$1.2B", "Rituals"},
    ["los chihuaninis"] = {"Los Chihuaninis", "Brainrot God", "$160K/s", "$35M", "Los Taco Blocks"},
    ["los chillis"] = {"Los Chillis", "Secret", "$75M/s", "$22.5B", "Cyber Craft Machine"},
    ["los combinasionas"] = {"Los Combinasionas", "Secret", "$15M/s", "$2B", "Los Lucky Blocks"},
    ["los cornis"] = {"Los Cornis", "Secret", "$3.1M/s", "$715M", "Los Traders"},
    ["los crocodillitos"] = {"Los Crocodillitos", "Brainrot God", "$55K/s", "$12.5M", "Rituals"},
    ["los cucarachas"] = {"Los Cucarachas", "Secret", "$1.25M/s", "$300M", nil, "$1.2M/s"},
    ["los cupids"] = {"Los Cupids", "Secret", "$30M/s", "$3.5B", "Formerly Divine Fuse"},
    ["los dragons"] = {"Los Dragons", "Secret", "$425M/s"},
    ["los fruits"] = {"Los Fruits", "Secret", "$23M/s", "$3B", "Summer Fuse"},
    ["los gattitos"] = {"Los Gattitos", "Brainrot God", "$275K/s"},
    ["los hackers"] = {"Los Hackers", "Secret", "$75M/s", "$22.5B", "Cyber Craft Machine"},
    ["los hotspotsitos"] = {"Los Hotspotsitos", "Secret", "$20M/s", "$3B", "Fuse Machine"},
    ["los jobcitos"] = {"Los Jobcitos", "Secret", "$1.5M/s", "$500M", "Los Lucky Blocks"},
    ["los jolly combinasionas"] = {"Los Jolly Combinasionas", "Secret", "$20M/s", "$3B", "Formerly Santa's Shop"},
    ["los karkeritos"] = {"Los Karkeritos", "Secret", "$750K/s", "$200M", nil},
    ["los losers"] = {"Los Losers", nil, "$37.5M/s"},
    ["los lucky blocks"] = {"Los Lucky Blocks", "Lucky Block", "$0/s", "$250M", "Admin Abuse, Sammy's base, RNG Machine"},
    ["los mariachis"] = {"Los Mariachis", "Secret", "$30M/s", "$3B", "Piñata"},
    ["los matteos"] = {"Los Matteos", "Secret", "$325K/s", "$80M", nil},
    ["los mi gatitos"] = {"Los Mi Gatitos", "Secret", "$6.5M/s", "$1.25B", "Rituals"},
    ["los mobilis"] = {"Los Mobilis", "Secret", "$22M/s", "$2.7B", "Formerly Witch Fuse", "$8.5M/s"},
    ["los noobinis"] = {"Los Noobinis", "Mythic", "$12.5K/s", "$4.3M", "RNG Machine"},
    ["los nooo my hotspotsitos"] = {"Los Nooo My Hotspotsitos", "Secret", "$5.5M/s", "$1B", "Taco Lucky Block"},
    ["los orcalitos"] = {"Los Orcalitos", "Brainrot God", "$235K/s", "$45M", "Los Lucky Blocks, Fishing, Rituals"},
    ["los planitos"] = {"Los Planitos", "Secret", "$18.5M/s", "$2.75B", "Formerly Brainrot Trader"},
    ["los primos"] = {"Los Primos", "Secret", "$31M/s", "$3.75B", "Fishing"},
    ["los puggies"] = {"Los Puggies", "Secret", "$30M/s", "$3B", "Formerly Brainrot Dealer, Brainrot Trader"},
    ["los quesadillas"] = {"Los Quesadillas", "Secret", "$4.5M/s", "$875M", "Los Taco Blocks"},
    ["los secret combinasionas"] = {"Los Secret Combinasionas", "Secret", "$150M/s", "$75B", "Los Traders"},
    ["los sekolahs"] = {"Los Sekolahs", "Secret", "$110M/s", "$45B", "Los Lucky Blocks"},
    ["los sigmas"] = {"Los Sigmas", "Secret", "$2.3M/s", "$580M", "Los Traders"},
    ["los spaghettis"] = {"Los Spaghettis", "Secret", "$70M/s", "$20B", "Brainrot Trader"},
    ["los spooky combinasionas"] = {"Los Spooky Combinasionas", "Secret", "$20M/s", "$3B", "Formerly Spooky Lucky Block"},
    ["los spyderinis"] = {"Los Spyderinis", "Secret", "$425K/s", "$125M", "Sammyni Ritual"},
    ["los sweethearts"] = {"Los Sweethearts", "Secret", "$16.5M/s", "$2.2B", "Formerly 2026 Fuse Machine"},
    ["los taco blocks"] = {"Los Taco Blocks", "Event exclusive", "$0/s", "$300M", "Admin Abuse"},
    ["los tacoritas"] = {"Los Tacoritas", "Secret", "$32M/s", "$4B", "Formerly Craft Machine"},
    ["los tangcitos"] = {"Los Tangcitos", "Secret", "$42.5M/s", "$7.5B", "Los Traders"},
    ["los tictacs"] = {"Los Tictacs", "Secret", "$60M/s", "$15B", "Los Traders"},
    ["los tipi tacos"] = {"Los Tipi Tacos", "Brainrot God", "$260K/s", "$46M", "Taco Lucky Block"},
    ["los tortus"] = {"Los Tortus", "Secret", "$500K/s", "$100M", "Los Lucky Blocks"},
    ["los tralaleritos"] = {"Los Tralaleritos", "Secret", "$500K/s", "$100M", "Red Carpet"},
    ["los treaters"] = {"Los Treaters", "Secret", "$1.2M/s"},
    ["los trios"] = {"Los Trios", "Secret", "$700K/s", "$175M", "Formerly Fuse Machine"},
    ["los tungtungtungcitos"] = {"Los Tungtungtungcitos", "Brainrot God", "$210K/s", "$37.5M", "Los Lucky Blocks, Admin Abuse"},
    ["love love bear"] = {"Love Love Bear", "Secret", "$225M/s", "$225B", "Formerly Cupid's Machine"},
    ["love love love sahur"] = {"Love Love Love Sahur", "Secret", "$1M/s", "$250M", "Heart Lucky Block"},
    ["lovin rose"] = {"Lovin Rose", "Secret", "$32.5M/s", "$4.2B", "Cupid's Machine"},
    ["luck luck luck sahur"] = {"Luck Luck Luck Sahur", "Secret", "$3.75M/s", "$800M", "Formerly Leprechaun Lucky Block", "$3.7M/s"},
    ["lumaca malefica"] = {"Lumaca Malefica", "Brainrot God", "$265K/s", "$46.5M", "Backrooms Event"},
    ["luv luv luv"] = {"Luv Luv Luv", "Brainrot God", "$283K/s", "$48.3M", "Heart Lucky Block", "$282.5K/s"},
    ["magi ribbitini"] = {"Magi Ribbitini", "Mythic", "$11.5K/s", "$4.2M", "Formerly Witch Fuse"},
    ["malame amarele"] = {"Malame Amarele", "Epic", "$140/s", "$23.5K", "Craft Machine"},
    ["mangolini parrocini"] = {"Mangolini Parrocini", "Epic", "$235/s", "$38.5K", "Formerly Craft Machine, Brainrot Trader"},
    ["mariachi corazoni"] = {"Mariachi Corazoni", "Secret", "$12.5M/s", "$1.75B", "Piñata & Admin Abuse Exclusive"},
    ["marino submarino"] = {"Marino Submarino", "Secret", "$3.6M/s"},
    ["mastodontico telepiedone"] = {"Mastodontico Telepiedone", "Brainrot God", "$275K/s", "$47.5M", "Brainrot God Lucky Block"},
    ["matteo"] = {"Matteo", "Brainrot God", "$50K/s", "$10M", "Admin Abuse, Backrooms Event and RNG Machine"},
    ["medusini and demonini"] = {"Medusini and Demonini", "Secret", "$180M/s"},
    ["meowl"] = {"Meowl", "OG", "$600M/s", "$650B", nil},
    ["mi gatito"] = {"Mi Gatito", "Secret", "$3.2M/s", "$725M", "Unobtainable", "$3.25M/s"},
    ["mieteteira bicicleteira"] = {"Mieteteira Bicicleteira", "Secret", "$26M/s", "$2.75B", "Witch Fuse"},
    ["moby bros"] = {"Moby Bros", "Secret", "$225M/s", "$225B", "Los Traders"},
    ["money money bros"] = {"Money Money Bros", "Secret", "$47M/s", "$9B", "Cyber Craft Machine"},
    ["money money cat"] = {"Money Money Cat", "Secret", "$14.5M/s"},
    ["money money man"] = {"Money Money Man", "Brainrot God", "$65K/s", "$17.5M", "Formerly Brainrot Dealer, Brainrot Trader", "$65k/s"},
    ["money money puggy"] = {"Money Money Puggy", "Secret", "$21M/s", "$2.6B", nil},
    ["money money reindeer"] = {"Money Money Reindeer", "Secret", "$25M/s", "$2.5B", "Unobtainable"},
    ["mortaruga"] = {"Mortaruga", "Brainrot God", "$324K/s"},
    ["motorino bumbino"] = {"Motorino Bumbino", "Secret", "$16.5M/s", "$2.2B", "Bee Lucky Block"},
    ["mummelo bandello"] = {"Mummelo Bandello", "Brainrot God", "$285K/s"},
    ["mummio rappitto"] = {"Mummio Rappitto", "Epic", "$325/s", "$47.5K", "Formerly Witch Fuse"},
    ["mummy ambalabu"] = {"Mummy Ambalabu", "Brainrot God", "$250K/s", "$45M", "Formerly Spooky Lucky Block"},
    ["mythic lucky block"] = {"Mythic Lucky Block", "Mythic", "$0/s", "$2.5M", "Red Carpet, Robux Shop"},
    ["nacho spyder"] = {"Nacho Spyder", "Secret", "$50M/s", "$10B", "Formerly Out of Stock"},
    ["nachorilla"] = {"Nachorilla", "Secret", "$47.5M/s", "$9.2B", "Taco Merchant"},
    ["naughty naughty"] = {"Naughty Naughty", "Secret", "$3M/s", "$700M", "North Pole Event"},
    ["noo la polizia"] = {"Noo La Polizia", "Brainrot God", "$280K/s", "$67M", "Formerly Brainrot Trader"},
    ["noo my candy"] = {"Noo my Candy", "Secret", "$5M/s", "$900M", "Unobtainable"},
    ["noo my eggs"] = {"Noo my Eggs", "Secret", "$7M/s", "$1.2B", "Formerly Easter Hour and Eggrot Hunt"},
    ["noo my examen"] = {"Noo my Examen", "Secret", "$32.5M/s", "$4.2B", "Ritual"},
    ["noo my gold"] = {"Noo my Gold", "Secret", "$13.5M/s", "$1.85B", "Formerly Leprechaun Lucky Block"},
    ["noo my heart"] = {"Noo my Heart", "Secret", "$13M/s", "$1.8B", "Formerly Heart Lucky Block"},
    ["noo my present"] = {"Noo my Present", "Secret", "$6M/s", "$1.1B", "North Pole Event"},
    ["noo my resume"] = {"Noo my Resume", "Secret", "$32.5M/s", "$4.2B", "Rituals"},
    ["noobini pizzanini"] = {"Noobini Pizzanini", "Common", "$1/s", "$25", "Red Carpet"},
    ["noobini santanini"] = {"Noobini Santanini", "Common", "$11/s", "$1.3K", "Santa's Fuse"},
    ["noodle noodle poodle"] = {"Noodle Noodle Poodle", "Secret", "$27.5M/s", "$3B", "Red Carpet"},
    ["nooo my hotspot"] = {"Nooo My Hotspot", "Secret", "$1.5M/s", "$500M", "Fat Sammy, Admin Abuse"},
    ["nuclearo dinossauro"] = {"Nuclearo Dinossauro", "Secret", "$15M/s", "$2.5B", "Red Carpet"},
    ["octo lucky block"] = {"Octo Lucky Block", "Lucky Block", nil, "$600M", "Summer Admin Machine"},
    ["octoball"] = {"Octoball", "Secret", "$3.2M/s", "$725M", "Octo Lucky Block"},
    ["odin din din dun"] = {"Odin Din Din Dun", "Brainrot God", "$75K/s", "$15M", "Red Carpet, Backrooms Event"},
    ["ombrello topolino"] = {"Ombrello Topolino", "Secret", "$6.5M/s", "$1.2B", "Summer Fuse"},
    ["oni oni panda"] = {"Oni Oni Panda", "Secret", "$27M/s"},
    ["orangutini ananassini"] = {"Orangutini Ananassini", "Mythic", "$2.1K/s", "$400K", "Red Carpet"},
    ["orbi mochi"] = {"Orbi Mochi", "Mythic", "$18.5K/s", "$6M", "Cyber Craft Machine", "$46M/s", "Secret"},
    ["orcaledon"] = {"Orcaledon", "Secret", "$40M/s", "$7B", "Fishing"},
    ["orcalero orcala"] = {"Orcalero Orcala", "Brainrot God", "$100K/s", "$25M", "Brainrot God Lucky Block and from the Fishing Event"},
    ["orcalita orcala"] = {"Orcalita Orcala", "Brainrot God", "$240K/s", "$45M", "Fishing and RNG Machine"},
    ["orchidox"] = {"Orchidox", "Secret", "$155M/s", "$100B", "Bee Lucky Block"},
    ["pakrahmatmamat"] = {"Pakrahmatmamat", "Brainrot God", "$215K/s", "$37.5M", "Red Carpet, Backrooms Event and RNG Machine"},
    ["pakrahmatmatina"] = {"Pakrahmatmatina", "Brainrot God", "$225K/s", "$40.5M", "Pole Game and RNG Machine"},
    ["pancake and syrup"] = {"Pancake and Syrup", "Secret", "$125M/s", "$50B", "DLC"},
    ["panda popanda"] = {"Panda Popanda", "Secret", "$67M/s"},
    ["pandaccini bananini"] = {"Pandaccini Bananini", "Legendary", "$1.25K/s", "$300K", "Red Carpet"},
    ["pandanini frostini"] = {"Pandanini Frostini", "Brainrot God", "$294K/s", "$64M", "Formerly Festive Lucky Block"},
    ["paradiso axolottino"] = {"Paradiso Axolottino", "Secret", "$900K/s", "$235M", "Formerly Divine Fuse"},
    ["patteo"] = {"Patteo", "Brainrot God", "$288K/s", "$57.5M", "Unobtainable", "$287.5K/s"},
    ["pelican pachetto"] = {"Pelican Pachetto", "Secret", "$1.75M/s"},
    ["pengolino nuvoletto"] = {"Pengolino Nuvoletto", "Rare", "$72/s", "$9.6K", "Formerly Divine Fuse"},
    ["penguin tree"] = {"Penguin Tree", "Epic", "$270/s", "$42K", "Formerly Santa's Fuse"},
    ["penguino cocosino"] = {"Penguino Cocosino", "Epic", "$300/s", "$45K", "Formerly Summer Fuse"},
    ["penguino pumpkino"] = {"Penguino Pumpkino", "Epic", "$235/s"},
    ["perochello lemonchello"] = {"Perochello Lemonchello", "Epic", "$160/s", "$27.5K", "Red Carpet"},
    ["perrito burrito"] = {"Perrito Burrito", "Secret", "$1M/s", "$250M", "Formerly Out of Stock"},
    ["peschito machito"] = {"Peschito Machito", "Secret", "$19M/s", "$2.8B", "RNG Machine"},
    ["phoenix"] = {"Phoenix", "Secret", "$425M/s"},
    ["pi pi watermelon"] = {"Pi Pi Watermelon", "Legendary", "$1.3K/s"},
    ["piccione macchina"] = {"Piccione Macchina", "Brainrot God", "$225K/s", "$40M", nil},
    ["piccionetta machina"] = {"Piccionetta Machina", "Brainrot God", "$270K/s", "$47M", "Formerly Brainrot Trader"},
    ["pin pin pengu"] = {"Pin Pin Pengu", "Secret", "$2.3M/s"},
    ["pinealotto fruttarino"] = {"Pinealotto Fruttarino", "Rare", "$75/s", "$9.7K", "Formerly Witch Fuse"},
    ["pineaplino"] = {"Pineaplino", "Brainrot God", "$200K/s", "$35M", "DLC"},
    ["pipi avocado"] = {"Pipi Avocado", "Rare", "$70/s", "$9.5K", "Formerly Summer Fuse"},
    ["pipi corni"] = {"Pipi Corni", "Common", "$14/s", "$1.75K", "Summer Fuse"},
    ["pipi kiwi"] = {"Pipi Kiwi", "Common", "$13/s", "$1.5K", "Red Carpet"},
    ["pipi potato"] = {"Pipi Potato", "Legendary", "$1.1K/s", "$265K", "Red Carpet"},
    ["pipi watermelon"] = {"Pipi Watermelon", "Legendary", "$1.3K/s"},
    ["pirulitoita bicicleteira"] = {"Pirulitoita Bicicleteira", "Secret", "$2.5M/s", "$600M", "Formerly Brainrot Trader, Brainrot Dealer"},
    ["pizza and ranch"] = {"Pizza and Ranch", "Secret", "$130M/s", "$55B", "Red Carpet"},
    ["plant bros"] = {"Plant Bros", "Secret", "$300M/s"},
    ["please my present"] = {"Please my Present", "Secret", "$1.3M/s", "$350M", "Formerly Advent Calendar"},
    ["pogo pogo penguin"] = {"Pogo Pogo Penguin", "Secret", "$12.5M/s", "$1.75B", "RNG Machine"},
    ["polaroidini"] = {"Polaroidini", "Secret", "$55M/s", "$12.5B", "Formerly Given out codes"},
    ["pop pop petalini"] = {"Pop Pop Petalini", "Secret", "$62.5M/s", "$15B", "Bee Lucky Block"},
    ["pop pop sahur"] = {"Pop Pop Sahur", "Brainrot God", "$295K/s", "$65M", "Brainrot God Lucky Block"},
    ["popcuru and fizzuru"] = {"Popcuru and Fizzuru", "Secret", "$170M/s", "$135B", "Formerly Fuse Machine", "$115M/s"},
    ["pot hotspot"] = {"Pot Hotspot", "Secret", "$2.5M/s", "$600M", "Secret Lucky Block"},
    ["pot pumpkin"] = {"Pot Pumpkin", "Secret", "$3M/s", "$700M", "Unobtainble (Graveyard"},
    ["pretzo robo"] = {"Pretzo Robo", "Brainrot God", "$320K/s", "$77M", "Cyber Craft Machine", "$52.5M/s", "Secret"},
    ["puffaball"] = {"Puffaball", "Legendary", "$1.5K/s", "$330K", "Fishing"},
    ["puffino builderino"] = {"Puffino Builderino", "Secret", "$31M/s"},
    ["pum pum pum"] = {"Pum Pum Pum", "Secret", "$31M/s"},
    ["pumpkini spyderini"] = {"Pumpkini Spyderini", "Secret", "$650K/s", "$165M", "Spooky Lucky Block"},
    ["puppetmaster"] = {"Puppetmaster", "Secret", "$177.5M/s"},
    ["qamar camelamp"] = {"Qamar Camelamp", "Secret", "$3.3M/s"},
    ["quackalena"] = {"Quackalena", "Brainrot God", "$265K/s", "$46.5M", "RNG Machine"},
    ["quackini snackini"] = {"Quackini Snackini", "Secret", "$65M/s", "$15.5B", "Egg City"},
    ["quackula"] = {"Quackula", "Legendary", "$1.27K/s", "$310K", "Formerly Witch Fuse", "$1.2K/s"},
    ["queen bee"] = {"Queen Bee", "Secret", "$65M/s", "$15.5B", "Bee Shop"},
    ["quesadilla crocodila"] = {"Quesadilla Crocodila", "Secret", "$3M/s", "$700M", "Taco Lucky Block"},
    ["quesadillo vampiro"] = {"Quesadillo Vampiro", "Secret", "$3.5M/s", "$750M", "Formerly Out of Stock"},
    ["quivioli ameleonni"] = {"Quivioli Ameleonni", "Legendary", "$900/s", "$225K", "Red Carpet"},
    ["raccooni jandelini"] = {"Raccooni Jandelini", "Common", "$12/s", "$1.3K", "Formerly Admin Abuse War, Cyber Craft Machine"},
    ["rainbow and gold"] = {"Rainbow and Gold", "Event exclusive", nil, nil, "Leprechaun Lucky Block"},
    ["rang ring bus"] = {"Rang Ring Bus", "Secret", "$6M/s", "$1.1B", "Pole Game"},
    ["ranito pepito"] = {"Ranito Pepito", "Secret", "$950k/s"},
    ["ref ref ref sahur"] = {"Ref Ref Ref Sahur", "Secret", "$2.7M/s", "$650M", "Soccer Board"},
    ["reindeer tralala"] = {"Reindeer Tralala", "Secret", "$600K/s", "$160M", "Formerly Winter Hour"},
    ["reinito sleighito"] = {"Reinito Sleighito", "Secret", "$140M/s", "$60B", "Festive Lucky Block"},
    ["rexino ramino"] = {"Rexino Ramino", "Secret", "$2.6M/s"},
    ["rhino helicopterino"] = {"Rhino Helicopterino", "Mythic", "$11K/s", "$4.1M", "Craft Machine"},
    ["rhino slido"] = {"Rhino Slido", nil, "$0/s"},
    ["rhino toasterino"] = {"Rhino Toasterino", "Mythic", "$2.15K/s", "$450K", nil, "$2.1K/s"},
    ["rico dinero"] = {"Rico Dinero", "Secret", "$42.5M/s", "$7.5B", "DLC"},
    ["robo grafito"] = {"Robo Grafito", "Brainrot God", "$318K/s", "$76M", "Backrooms Event", "$317.5K/s"},
    ["rocco disco"] = {"Rocco Disco", "Secret", "$650K/s", "$150M", "Unobtainable"},
    ["rockarino rockara"] = {"Rockarino Rockara", "Secret", "$3M/s"},
    ["rocketini frostini"] = {"Rocketini Frostini", "Secret", "$3M/s", "$700M", "RNG Machine"},
    ["rosatops triceratino"] = {"Rosatops Triceratino", "Secret", "$3.1M/s", "$715M", "Bee Lucky Block"},
    ["rosetti tualetti"] = {"Rosetti Tualetti", "Secret", "$50M/s", "$10B", "Formerly Heart Lucky Block"},
    ["rosey and teddy"] = {"Rosey and Teddy", "Secret", "$165M/s", "$130B", "Heart Lucky Block"},
    ["rubiko and kubiko"] = {"Rubiko and Kubiko", "Secret", "$72.5M/s", "$21B", "Los Traders"},
    ["rubrikiko"] = {"Rubrikiko", "Secret", "$70M/s", "$20B", "Backrooms Event"},
    ["salamino penguino"] = {"Salamino Penguino", "Epic", "$250/s", "$40K", "Red Carpet"},
    ["sammyni cakini"] = {"Sammyni Cakini", "Secret", "$85M/s", "$12.5B", "Cyber Craft"},
    ["sammyni fattini"] = {"Sammyni Fattini", "Secret", "$70M/s", "$20B", "Admin Lucky Block"},
    ["sammyni spookyni"] = {"Sammyni Spookyni", "Secret", "$80M/s"},
    ["sammyni spyderini"] = {"Sammyni Spyderini", "Secret", "$325K/s", "$75M", "Admin Abuse, Sammy's Base"},
    ["sammyni truckini"] = {"Sammyni Truckini", "Secret", "$110M/s", "$45B", "Taco Merchant"},
    ["sand sand sand"] = {"Sand Sand Sand", "Secret", "$30M/s", "$3B", "Octo Lucky Block"},
    ["santa hotspot"] = {"Santa Hotspot", "Secret", "$2.6M/s", "$625M", "Festive Lucky Block"},
    ["santteo"] = {"Santteo", "Secret", "$800K/s", "$210M", "Formerly Winter Hour"},
    ["scarino crowino"] = {"Scarino Crowino", "Secret", "$135M/s"},
    ["scorpi inferni"] = {"Scorpi Inferni", "Secret", "$76M/s"},
    ["scorpino coasterino"] = {"Scorpino Coasterino", "Secret", "$47.5M/s", "$9.2B", "RNG Machine"},
    ["sealo regalo"] = {"Sealo Regalo", "Legendary", "$1.82K/s", "$343K", "Formerly Santa's Fuse", "$1.8K/s"},
    ["secret lucky block"] = {"Secret Lucky Block", "Secret", "$0/s", "$750M", "Red Carpet, Robux Shop, Sammy's Base, Admin Abuse"},
    ["serafinna medusella"] = {"Serafinna Medusella", "Secret", "$5.5M/s", "$1B", "Formerly Divine Fuse"},
    ["seraphino gruyero"] = {"Seraphino Gruyero", "Legendary", "$1.9K/s", "$348K", "Formerly Divine Fuse"},
    ["sigma boy"] = {"Sigma Boy", "Legendary", "$1.35K/s", "$325K", "Red Carpet"},
    ["sigma girl"] = {"Sigma Girl", "Legendary", "$1.8K/s", "$340K", "Formerly Craft Machine"},
    ["signore carapace"] = {"Signore Carapace", "Secret", "$275M/s", "$275B", "Craft Machine", "$105M/s"},
    ["sir mangus"] = {"Sir Mangus", "Secret", "$7.5M/s"},
    ["skelly and coffy"] = {"Skelly and Coffy", "Secret", "$155M/s"},
    ["ski ski skunki"] = {"Ski Ski Skunki", "Secret", "$1.6M/s"},
    ["skibidi toilet"] = {"Skibidi Toilet", "OG", "$450M/s", "$450B", nil},
    ["skooter skelly"] = {"Skooter Skelly", "Secret", "$2.6M/s"},
    ["skul skuli skuli"] = {"Skul Skuli Skuli", "Brainrot God", "$300K/s"},
    ["skull lucky block"] = {"Skull Lucky Block", nil, "$0/s"},
    ["skull skull skull"] = {"Skull Skull Skull", "Brainrot God", "$290K/s", "$60M", "Unobtainable"},
    ["slushi huski"] = {"Slushi Huski", "Brainrot God", "$322.5K/s"},
    ["smore serat"] = {"S'more Serat", "Secret", "$85M/s", "$25.5B", "Bee Shop"},
    ["smurf cat"] = {"Smurf Cat", nil, "$0/s"},
    ["snailenzo"] = {"Snailenzo", "Brainrot God", "$250K/s", "$45M", "Formerly Witch Fuse"},
    ["snailo clovero"] = {"Snailo Clovero", "Secret", "$18.5M/s", "$2.7B", "Unobtainable"},
    ["spaghetti tualetti"] = {"Spaghetti Tualetti", "Secret", "$60M/s", "$15B", "Secret Lucky Block"},
    ["spinny hammy"] = {"Spinny Hammy", "Secret", "$17M/s", "$2.3B", "Formerly Fuse Machine"},
    ["spioniro golubiro"] = {"Spioniro Golubiro", "Mythic", "$3.5K/s", "$750K", "Mythic Lucky Block"},
    ["spongini quackini"] = {"Spongini Quackini", "Mythic", "$13K/s", "$4.4M", "Formerly Fuse Machine"},
    ["spooketti tualetti"] = {"Spooketti Tualetti", "Secret", "$77.5M/s"},
    ["spooky and pumpky"] = {"Spooky and Pumpky", "Secret", "$80M/s", "$25B", "Witch Fuse"},
    ["spooky kart"] = {"Spooky Kart", "Secret", "$13M/s"},
    ["spooky lucky block"] = {"Spooky Lucky Block", "Lucky Block", "$0/s", "$350M", "Unobtainable"},
    ["spooky spooky sahur"] = {"Spooky Spooky Sahur", "Secret", "$46M/s"},
    ["spyder elephant"] = {"Spyder Elephant", "OG", "$1B/s", "$1T", "Resellers"},
    ["squalanana"] = {"Squalanana", "Brainrot God", "$250K/s", "$45M", "Fishing"},
    ["statutino libertino"] = {"Statutino Libertino", "Brainrot God", "$75K/s", "$20M", "Formerly Replaced by Unclito Samito"},
    ["steakini fattini"] = {"Steakini Fattini", "Secret", "$55M/s", "$12.5B", "Formerly Out of Stock"},
    ["stoppo luminino"] = {"Stoppo Luminino", "Mythic", "$8K/s", "$3M", "Brainrot Trader"},
    ["strawberrelli flamingelli"] = {"Strawberrelli Flamingelli", "Legendary", "$1.15K/s", "$275K", "Red Carpet"},
    ["strawberrita"] = {"Strawberrita", "Secret", "$6.5M/s", "$1.2B", "Red Carpet"},
    ["strawberry elephant"] = {"Strawberry Elephant", "OG", "$750M/s", "$750B", "Red Carpet"},
    ["sundrilla sundae"] = {"Sundrilla Sundae", "Brainrot God", "$180K/s", "$31M", "Summer Fuse"},
    ["sushi inu"] = {"Sushi Inu", "Secret", "$8M/s", "$1.3B", "Octo Lucky Block"},
    ["svinina bombardino"] = {"Svinina Bombardino", "Common", "$10/s", "$1.25K", "Red Carpet"},
    ["swag soda"] = {"Swag Soda", "Secret", "$13M/s", "$1.8B", "Formerly Brainrot Trader"},
    ["swaggy bros"] = {"Swaggy Bros", "Secret", "$40M/s", "$7B", "Formerly Out of Stock"},
    ["syrup samurai"] = {"Syrup Samurai", "Secret", "$6.7M/s", "$1.1B", "Bee Lucky Block"},
    ["ta ta ta ta sahur"] = {"Ta Ta Ta Ta Sahur", "Rare", "$55/s", "$7.5K", "Red Carpet"},
    ["taco lucky block"] = {"Taco Lucky Block", "Lucky Block", "$0/s", "$50M", "Admin Abuse, Taco Tuesday"},
    ["tacorillo crocodillo"] = {"Tacorillo Crocodillo", "Secret", "$12.5M/s", "$1.5B", "Formerly Out of Stock"},
    ["tacorita bicicleta"] = {"Tacorita Bicicleta", "Secret", "$16.5M/s", "$2.2B", "Limited Quantity Brainrots"},
    ["tacoturbo tacorito"] = {"Tacoturbo Tacorito", "Secret", "$26M/s", "$2.7B", "Taco Merchant"},
    ["talpa di fero"] = {"Talpa Di Fero", "Common", "$9/s", "$1K", "Red Carpet"},
    ["tang tang keletang"] = {"Tang Tang Keletang", "Secret", "$33.5M/s", "$4.5B", "Red Carpet"},
    ["tartaragno"] = {"Tartaragno", "Common", "$13/s", "$1.5K", "Witch Fuse"},
    ["tartaruga cisterna"] = {"Tartaruga Cisterna", "Brainrot God", "$250K/s", "$45M", "Sammy's Base, Backrooms Event and RNG Machine"},
    ["te te te sahur"] = {"Te Te Te Sahur", "Mythic", "$9.5K/s", "$4M", "Red Carpet"},
    ["telemorte"] = {"Telemorte", "Secret", "$2M/s", "$550M", "Unobtainable"},
    ["tenini ballini"] = {"Tenini Ballini", "Brainrot God", "$320K/s", "$77M", "DLC", "$300K/s"},
    ["tentacolo tecnico"] = {"Tentacolo Tecnico", "Brainrot God", "$293K/s", "$62.5M", "Fishing", "$292.5K/s"},
    ["ti ti ti sahur"] = {"Ti Ti Ti Sahur", "Epic", "$225/s", "$37.5K", "Formerly Summer Fuse"},
    ["tic tic ribbit"] = {"Tic Tic Ribbit", "Mythic", "$18.8K/s", "$6.25M", "RNG Machine", "$18.7K/s"},
    ["tictac sahur"] = {"Tictac Sahur", "Secret", "$37.5M/s", "$6B", nil},
    ["tigrilini watermelini"] = {"Tigrilini Watermelini", "Mythic", "$6.5K/s", "$1.75M", "Mythic Lucky Block"},
    ["tigroligre frutonni"] = {"Tigroligre Frutonni", "Brainrot God", "$60K/s", "$15M", "Brainrot God Lucky Block"},
    ["tim cheese"] = {"Tim Cheese", "Common", "$5/s", "$500", "Red Carpet"},
    ["tipi topi taco"] = {"Tipi Topi Taco", "Brainrot God", "$75K/s"},
    ["tirilikalika tirilikalako"] = {"Tirilikalika Tirilikalako", "Secret", "$42.5M/s", "$7.5B", "Craft Machine", "$82.5M/s"},
    ["to to to sahur"] = {"To to to Sahur", "Secret", "$2.25M/s", "$575M", "Red Carpet"},
    ["tob tobi tobi"] = {"Tob Tobi Tobi", "Mythic", "$8.5K/s", "$3.5M", "Fuse Machine", "$8.5k/s"},
    ["toiletto focaccino"] = {"Toiletto Focaccino", "Mythic", "$16K/s", "$4.85M", "Red Carpet and RNG Machine"},
    ["tootini shrimpini"] = {"Tootini Shrimpini", "Brainrot God", "$260K/s", "$46M", "Unobtainable"},
    ["toro espanolo"] = {"Toro Españolo", "Secret", "$2.2M/s", "$575M", "Spain Event"},
    ["torrtuginni dragonfrutini"] = {"Torrtuginni Dragonfrutini", "Secret", "$350K/s", "$125M", "Secret Lucky Block"},
    ["tortuginni sandcastlini"] = {"Tortuginni Sandcastlini", "Brainrot God", "$318K/s", "$76M", "Octo Lucky Block", "$317.5K/s"},
    ["tracoducotulu delapeladustuz"] = {"Tracoducotulu Delapeladustuz", "Mythic", "$12K/s", "$4.2M", nil},
    ["tractoro dinosauro"] = {"Tractoro Dinosauro", "Brainrot God", "$230K/s", "$42.5M", nil},
    ["tralaledon"] = {"Tralaledon", "Secret", "$27.5M/s", "$3B", "Fishing"},
    ["tralalero tralala"] = {"Tralalero Tralala", "Brainrot God", "$50K/s", "$10M", "Red Carpet"},
    ["tralalita tralala"] = {"Tralalita Tralala", "Brainrot God", "$100K/s", "$20M", nil},
    ["tree tree tree sahur"] = {"Tree Tree Tree Sahur", "Mythic", "$17K/s", "$4.9M", "Formerly Santa's Fuse"},
    ["trenostruzzo turbo 3000"] = {"Trenostruzzo Turbo 3000", "Brainrot God", "$150K/s", "$25M", "Red Carpet"},
    ["trenostruzzo turbo 4000"] = {"Trenostruzzo Turbo 4000", "Secret", "$335K/s", "$90M", "Formerly Craft Machine"},
    ["trenotubo axolotrico 9000"] = {"Trenotubo Axolotrico 9000", "Brainrot God", "$255K/s", "$45.5M", "Cyber Craft Machine"},
    ["tric trac baraboom"] = {"Tric Trac Baraboom", "Rare", "$65/s", "$9K", "Red Carpet"},
    ["trickolino"] = {"Trickolino", "Secret", "$900K/s", "$235M", "Unobtainable"},
    ["triplito tralaleritos"] = {"Triplito Tralaleritos", "Secret", "$875K/s", "$230M", "Festive Lucky Block"},
    ["trippi troppi"] = {"Trippi Troppi", "Rare", "$15/s", "$2K", "Red Carpet"},
    ["trippi troppi troppa trippa"] = {"Trippi Troppi Troppa Trippa", "Brainrot God", "$175K/s", "$30M", "Red Carpet, Backrooms Event"},
    ["trulimero trulicina"] = {"Trulimero Trulicina", "Epic", "$125/s", "$20K", "Red Carpet / Fishing"},
    ["tuff toucan"] = {"Tuff Toucan", "Secret", "$26M/s", "$2.7B", "Formerly Out of Stock"},
    ["tukanno bananno"] = {"Tukanno Bananno", "Brainrot God", "$100K/s", "$22.5M", "Formerly Fuse Machine", "$100k/s"},
    ["tung tung tung sahur"] = {"Tung Tung Tung Sahur", "Secret", "$1.5M/s", "$500M", "Formerly Removed"},
    ["unclito samito"] = {"Unclito Samito", "Brainrot God", "$75K/s", "$20M", "Formerly Exclusive from July 4th"},
    ["urubini flamenguini"] = {"Urubini Flamenguini", "Brainrot God", "$150K/s", "$30M", "Admin Abuse, Backrooms Event and RNG Machine"},
    ["vampi ribbitini"] = {"Vampi Ribbitini", "Brainrot God", "$185K/s"},
    ["vampira cappuccina"] = {"Vampira Cappuccina", "Brainrot God", "$125K/s"},
    ["vampira cappucina"] = {"Vampira Cappucina", "Brainrot God", "$125K/s", "$24.5M", "Witching Hour Event"},
    ["var var var"] = {"Var Var Var", "Secret", "$5.5M/s", "$1B", "Unobtainable"},
    ["ventoliero pavonero"] = {"Ventoliero Pavonero", "Secret", "$65M/s", "$15.5B", nil},
    ["venuspino"] = {"Venuspino", "Secret", "$175M/s", "$150B", "Summer Fuse"},
    ["vulturino skeletono"] = {"Vulturino Skeletono", "Secret", "$500K/s", "$110M", "Formerly Witch Fuse"},
    ["w or l"] = {"W or L", "Secret", "$30M/s", "$3B", "Formerly Out of Stock"},
    ["wombo rollo"] = {"Wombo Rollo", "Epic", "$275/s", "$42.5K", "Red Carpet"},
    ["yess my examen"] = {"Yess my Examen", "Secret", "$575K/s", "$130M", "Rituals"},
    ["yess my resume"] = {"Yess my Resume", "Secret", "$2.1M/s", "$563M", "Rituals"},
    ["yeti claus"] = {"Yeti Claus", "Brainrot God", "$258K/s", "$45.7M", "Formerly Santa's Fuse", "$257.5K/s"},
    ["yetimatic"] = {"Yetimatic", "Secret", "$87.5M/s", "$27.5B", "RNG Machine"},
    ["zebrino pianino"] = {"Zebrino Pianino", "Secret", "$7.25M/s"},
    ["zibra zubra zibralini"] = {"Zibra Zubra Zibralini", "Mythic", "$6K/s", "$1.5M", "Mythic Lucky Block"},
    ["zombie bowl"] = {"Zombie Bowl", "Secret", "$4.5M/s"},
    ["zombie tralala"] = {"Zombie Tralala", "Secret", "$500K/s", "$100M", "Admin Abuse Exclusive (Fishing Event"},
}

-- https://steal-a-brainrot.org/wiki/rebirth
local rebirthRequirements = {
    [1] = {"$500K", "Trippi Troppi, Gangster Footera"},
    [2] = {"$1.5M", "Brr Brr Patapim, Boneca Ambalabu"},
    [3] = {"$12.5M", "Trulimero Trulicina, Chimpanzini Bananini"},
    [4] = {"$35M", "Chef Crabracadabra, Glorbo Fruttodrillo"},
    [5] = {"$100M", "Frigo Camelo, Orangutini Ananassini"},
    [6] = {"$350M", "Bombardiro Crocodilo"},
    [7] = {"$1B", "Bombombini Gusini"},
    [8] = {"$5B", "Te Te Te Sahur"},
    [9] = {"$12.5B", "Cocofanto Elefanto"},
    [10] = {"$125B", "Girafa Celestre"},
    [11] = {"$800B", "Tralalero Tralala"},
    [12] = {"$3.5T", "Odin Din Din Dun"},
    [13] = {"$14T", "Trenostruzzo Turbo 3000"},
    [14] = {"$40T", "Trippi Troppi Troppa Trippa"},
    [15] = {"$100T", "Pakrahmatmamat"},
    [16] = {"$1Qa", "Los Tralaleritos"},
    [17] = {"$2Qa", "Job Job Job Sahur, Chicleteira Bicicleteira"},
    [18] = {"$10Qa", "Graipuss Medussi"},
    [19] = {"$30Qa", "La Grande Combinasion"},
}

-- https://stealabrainrot.wiki/wiki/mutations/
local mutationMultipliers = {
    ["default"] = "1x",
    ["gold"] = "1.25x",
    ["diamond"] = "1.5x",
    ["rainbow"] = "10x",
    ["bloodrot"] = "2x",
    ["candy"] = "4x",
    ["lava"] = "6x",
    ["galaxy"] = "7x",
    ["yin yang"] = "7.5x",
    ["radioactive"] = "8.5x",
    ["cursed"] = "9x",
    ["divine"] = "10x",
    ["cyber"] = "11x",
    ["phantom"] = "12x",
    ["crystal"] = "13x",
    ["eclipse"] = "14x",
}

-- https://stealabrainrotgame.wiki/traits/ (additive bonuses)
local traitBonuses = {
    ["strawberry"] = "+8x to the income multiplier",
    ["meowl"] = "+7x to the income multiplier",
    ["john pork"] = "+6.5x to the income multiplier",
    ["skibidi"] = "+6x to the income multiplier",
    ["granny"] = "+5.5x to the income multiplier",
    ["fire"] = "+5x to the income multiplier",
    ["rose"] = "+5x to the income multiplier",
    ["fireworks"] = "+5x to the income multiplier",
    ["nyan"] = "+5x to the income multiplier",
    ["lightning"] = "+5x to the income multiplier",
    ["burger"] = "+4.5x to the income multiplier",
    ["aura shades"] = "+4.5x to the income multiplier",
    ["disco"] = "+4x to the income multiplier",
    ["glitched"] = "+4x to the income multiplier",
    ["claws"] = "+4x to the income multiplier",
    ["zombie"] = "+4x to the income multiplier",
    ["bubblegum"] = "+3x to the income multiplier",
    ["ufo"] = "+2x to the income multiplier",
    ["taco"] = "+2x to the income multiplier",
    ["sleepy"] = "0.5x (listed trait multiplier)",
    ["paint"] = "+5x to the income multiplier",
    [":3"] = "+4.5x to the income multiplier",
    ["tie"] = "+3.75x to the income multiplier",
    ["spider"] = "+3.5x to the income multiplier",
    ["matteo hat"] = "+3.5x to the income multiplier",
    ["galactic"] = "+3x to the income multiplier",
    ["explosive"] = "+3x to the income multiplier",
    ["shark fin"] = "+3x to the income multiplier",
    ["pink egg"] = "+6.5x to the income multiplier",
    ["rainbow balloon"] = "+6.5x to the income multiplier",
    ["1 year"] = "+5.5x to the income multiplier",
    ["pink balloon"] = "+5.5x to the income multiplier",
    ["reindeer pet"] = "+5x to the income multiplier",
    ["blue egg"] = "+5x to the income multiplier",
    ["26"] = "+5x to the income multiplier",
    ["red balloon"] = "+5x to the income multiplier",
    ["halo"] = "+5x to the income multiplier",
    ["lucky"] = "+6x to the income multiplier",
    ["sun"] = "+5x to the income multiplier",
    ["ball"] = "+5x to the income multiplier",
    ["jack o lantern pet"] = "+4.5x to the income multiplier",
    ["bunny ears"] = "+4.5x to the income multiplier",
    ["chocolate"] = "+4.5x to the income multiplier",
    ["santa hat"] = "+4x to the income multiplier",
    ["green egg"] = "+4x to the income multiplier",
    ["blue balloon"] = "+4x to the income multiplier",
    ["rip gravestone"] = "+3.5x to the income multiplier",
    ["green balloon"] = "+3.5x to the income multiplier",
    ["witch hat"] = "+3x to the income multiplier",
    ["orange egg"] = "+3x to the income multiplier",
    ["10b"] = "+3x to the income multiplier",
    ["orange balloon"] = "+3x to the income multiplier",
    ["skeleton"] = "+3x to the income multiplier",
    ["brazil"] = "+5x to the income multiplier",
    ["algeria"] = "+4.5x to the income multiplier",
    ["argentina"] = "+4.5x to the income multiplier",
    ["australia"] = "+4.5x to the income multiplier",
    ["austria"] = "+4.5x to the income multiplier",
    ["belgium"] = "+4.5x to the income multiplier",
    ["bosnia and herzegovina"] = "+4.5x to the income multiplier",
    ["canada"] = "+4.5x to the income multiplier",
    ["cape verde"] = "+4.5x to the income multiplier",
    ["croatia"] = "+4.5x to the income multiplier",
    ["curacao"] = "+4.5x to the income multiplier",
    ["czechia"] = "+4.5x to the income multiplier",
    ["dr congo"] = "+4.5x to the income multiplier",
    ["ecuador"] = "+4.5x to the income multiplier",
    ["egypt"] = "+4.5x to the income multiplier",
    ["england"] = "+4.5x to the income multiplier",
    ["france"] = "+4.5x to the income multiplier",
    ["germany"] = "+4.5x to the income multiplier",
    ["ghana"] = "+4.5x to the income multiplier",
    ["haiti"] = "+4.5x to the income multiplier",
    ["iran"] = "+4.5x to the income multiplier",
    ["iraq"] = "+4.5x to the income multiplier",
    ["ivory coast"] = "+4.5x to the income multiplier",
    ["japan"] = "+4.5x to the income multiplier",
    ["jordan"] = "+4.5x to the income multiplier",
    ["mexico"] = "+4.5x to the income multiplier",
    ["morocco"] = "+4.5x to the income multiplier",
    ["netherlands"] = "+4.5x to the income multiplier",
    ["new zealand"] = "+4.5x to the income multiplier",
    ["norway"] = "+4.5x to the income multiplier",
    ["panama"] = "+4.5x to the income multiplier",
    ["paraguay"] = "+4.5x to the income multiplier",
    ["portugal"] = "+4.5x to the income multiplier",
    ["qatar"] = "+4.5x to the income multiplier",
    ["saudi arabia"] = "+4.5x to the income multiplier",
    ["scotland"] = "+4.5x to the income multiplier",
    ["senegal"] = "+4.5x to the income multiplier",
    ["south africa"] = "+4.5x to the income multiplier",
    ["south korea"] = "+4.5x to the income multiplier",
    ["spain"] = "+4.5x to the income multiplier",
    ["sweden"] = "+4.5x to the income multiplier",
    ["switzerland"] = "+4.5x to the income multiplier",
    ["tunisia"] = "+4.5x to the income multiplier",
    ["turkey"] = "+4.5x to the income multiplier",
    ["united states"] = "+4.5x to the income multiplier",
    ["uruguay"] = "+4.5x to the income multiplier",
    ["uzbekistan"] = "+4.5x to the income multiplier",
    ["indonesian"] = "+4x to the income multiplier",
    ["sombrero"] = "+4x to the income multiplier",
    ["comet struck"] = "+2.5x to the income multiplier",
    ["snowy"] = "+2x to the income multiplier",
    ["wet"] = "+1.5x to the income multiplier",
}

-- https://stealabrainrot.wiki/wiki/rituals/
local ritualInputs = {
    [""] = "---",
    ["las vaquitas saturnitas"] = "La Vacca Saturno Saturnita x3",
    ["bombardiro crocodilo"] = "Bombardiro Crocodilo x3",
    ["los crocodillitos"] = "Bombardiro Crocodilo x3",
    ["los orcalitos"] = "Orcalero Orcala x4 or x4 Orcalita Orcala",
    ["matteo"] = "Matteo x3",
    ["los matteos"] = "Matteo x3",
    ["sammyni spyderini"] = "Sammyni Spyderini x4",
    ["los spyderinis"] = "Sammyni Spyderini x4",
    ["chicleteira bicicleteira"] = "Chicleteira Bicicleteira x2",
    ["los chicleteiras"] = "Chicleteira Bicicleteira x2",
    ["dul dul dul"] = "Dul Dul Dul x4",
    ["yess my examen"] = "Dul Dul Dul x4",
    ["noo my examen"] = "Dul Dul Dul x4",
    ["karkerkar kurkur"] = "Karkerkar Kurkur x4",
    ["los karkeritos"] = "Karkerkar Kurkur x4",
    ["guerriro digitale"] = "Guerriro Digitale x4",
    ["1x1x1x1"] = "Guerriro Digitale x4",
    ["guest 666"] = "Guerriro Digitale x4",
    ["john doe"] = "Guerriro Digitale x4",
    ["mi gatito"] = "2x Mi Gatito",
    ["los mi gatitos"] = "2x Mi Gatito",
    ["job job job sahur"] = "4x Job Job Job Sahur",
    ["noo my resume"] = "4x Job Job Job Sahur",
    ["yess my resume"] = "4x Job Job Job Sahur",
    ["money money puggy"] = "2x Money Money Puggy",
    ["los puggies"] = "2x Money Money Puggy",
}

-- https://rblxguide.com/games/steal-a-brainrot/fuse (documented combinations; outcomes can vary)
local fuseInputs = {
    ["ketupat bros"] = "Ketupat Kepat + Ginger Gerat (100% listed odds)",
    ["pipi avocado"] = "2x Pipi Kiwi + 2x Bandito Bobritto (95% listed odds, older recipe)",
    ["ti ti ti sahur"] = "3x Perochello Lemonchello + Trulimero Trulicina (62% listed odds, older recipe)",
    ["penguino cocosino"] = "4x Brr Brr Patapim (31% listed odds, older recipe)",
    ["pi pi watermelon"] = "4x Ballerina Cappuccina (47% listed odds, older recipe)",
    ["tob tobi tobi"] = "Frigo Camelo + Sigma Boy (43% listed odds, older recipe)",
    ["ganganzelli trulala"] = "Bombardiro Crocodilo + Blueberrinni Octopusini (26% listed odds, older recipe)",
    ["tukanno bananno"] = "Girafa Celestre (60% listed odds, older recipe)",
    ["brr es teh patipum"] = "Tralalero Tralala + Cocofanto Elefanto (44% listed odds, older recipe)",
    ["los tungtungtungcitos"] = "Odin Din Din Dun + Piccione Macchina (76% listed odds, older recipe)",
    ["agarrini la palini"] = "Graipuss Medussi (96% listed odds, older recipe)",
    ["los combinasionas"] = "Graipuss Medussi + Chicleteira Bicicleteira (6% listed odds, older recipe)",
    ["los hotspotsitos"] = "La Grande Combinasion + Los Combinasionas (3% listed odds, older recipe)",
    ["la supreme combinasion"] = "Strawberry Elephant (7% listed odds, older recipe)",
    ["pipi corni"] = "4x Noobini Pizzanini (67% listed odds, older recipe)",
    ["mummio rappitto"] = "Avocadini Antilopini + Bambini Crostini + 2x Salamino Penguino (36% listed odds)",
    ["quackula"] = "3x Chimpanzini Bananini + Burbaloni Loliloli (30% listed odds)",
    ["buho de fuego"] = "3x Chimpanzini Bananini + Burbaloni Loliloli (60% listed odds)",
    ["plant bros"] = "Orchidox + Venuspino (50% listed odds)",
    ["hydra dragon cannelloni"] = "4x Strawberry Elephant (10% listed odds)",
    ["celestial pegasus"] = "4x Strawberry Elephant (10% listed odds)",
    ["tartaragno"] = "4x Noobini Pizzanini (67% listed odds)",
    ["penguino pumpkino"] = "Avocadini Antilopini + Bambini Crostini + 2x Salamino Penguino (36% listed odds)",
}

-- https://steal-a-brainrot.org/crafts and https://stealabrainrot.wiki/wiki/taco-tuesday/
local craftInputs = {
    ["los dragons"] = "Dragon Cannelloni + Dragon Gingerini + Dragon Aquanini ($425B)",
    ["la craft machine"] = "Fragola La La La + Celularcini Viciosini + Las Sis + La Sahur Combinasion ($22.5B)",
    ["perrito burrito"] = "Chihuanini Taconini + La Cucaracha + Job Job Job Sahur (Taco Truck)",
    ["chillin chili"] = "67 + Los Nooo My Hotspotsitos + Quesadilla Crocodila (Taco Truck)",
    ["panda popanda"] = "DJ Panda + Candini Fluffini (OG Craft Machine)",
    ["deputy leopard"] = "La Grande Combinasion + Sir Mangus + Gub ($2.6B)",
    ["swaggy bros"] = "67 + Los 25 + Los Burritos + Swag Soda (Taco Tuesday)",
}

-- https://stealabrainrot.wiki/wiki/lucky-blocks/ and linked block pages
local luckyDrops = {
    ["mythic lucky block"] = "Spioniro Golubiro 37% / Zibra Zubra Zibralini 30% / Tigrilini Watermelini 20% / Carrotini Brainini 10% / Bananito Bandito 3%",
    ["brainrot god lucky block"] = "Tigroligre Frutonni 54% / Orcalero Orcala 30% / Bulbito Bandito Traktorito 10% / Mastodontico Telepiedone 5% / Pop Pop Sahur 1%",
    ["festive lucky block"] = "Chrismasmamat 30.9% / Pandanini Frostini 30% / Triplito Tralaleritos 25% / Santa Hotspot 10% / Los 25 2.5% / Chimnino 1% / La Ginger Sekolah 0.5% / Reinito Sleighito 0.1%",
    ["leprechaun lucky block"] = "Patteo 30.9% / Clovkur Kurkur 30% / La Vacca Lepre Lepreino 25% / Luck Luck Luck Sahur 10% / Noo my Gold 2.5% / Snailo Clovero 1% / Gold Gold Gold 0.5% / Fortunu and Cashuru 0.1%",
    ["secret lucky block"] = "Torrtuginni Dragonfrutini 74.45% / Pot Hotspot 21% / Esok Sekolah 3% / Spaghetti Tualetti 1% / La Secret Combinasion 0.5% / Celestial Pegasus 0.05%",
    ["los lucky blocks"] = "Documented drops: Los Bombinitos 40% / Los Sekolahs 0.25%",
    ["spooky lucky block"] = "Documented drops: Mummy Ambalabu 32.75% / La Casa Boo 0.3%",
}

-- https://stealabrainrot.wiki/wiki/taco-tuesday/
local tacoDates = {
    [1] = "2025-08-19",
    [2] = "2025-08-26",
    [3] = "2025-09-02",
    [4] = "2025-09-09",
    [5] = "2025-09-16",
    [6] = "2025-09-23",
    [7] = "2025-09-30",
    [8] = "2025-10-07",
    [9] = "2025-10-14",
    [10] = "2025-10-21",
    [11] = "2025-10-28",
    [12] = "2025-11-11",
    [13] = "2025-11-18",
    [14] = "2025-11-25",
    [15] = "2025-12-02",
    [16] = "2025-12-09",
    [17] = "2025-12-16",
    [18] = "2026-01-06",
    [19] = "2026-01-13",
    [20] = "2026-01-20",
    [21] = "2026-01-27",
    [22] = "2026-02-03",
    [23] = "2026-02-10",
    [24] = "2026-02-17",
    [25] = "2026-02-24",
    [26] = "2026-03-03",
    [27] = "2026-03-10",
    [28] = "2026-03-17",
    [29] = "2026-03-24",
    [30] = "2026-03-31",
    [31] = "2026-04-07",
    [32] = "2026-04-14",
    [33] = "2026-04-21",
    [34] = "2026-06-09",
    [35] = "2026-06-16",
    [36] = "2026-06-23",
    [37] = "2026-06-30",
    [38] = "2026-07-07",
    [39] = "2026-07-14",
    [40] = "2026-07-21",
    [41] = "2026-07-28",
    [42] = "2026-08-04",
    [43] = "2026-08-11",
    [44] = "2026-08-18",
    [45] = "2026-08-25",
    [46] = "2026-09-01",
    [47] = "2026-09-08",
    [48] = "2026-09-15",
    [49] = "2026-09-22",
    [50] = "2026-09-29",
    [51] = "2026-10-06",
    [52] = "2026-10-13",
}

-- Major changes summarized from the published update log. Dates are above.
local updateHighlights = {
    "Gold and Diamond mutations, Secret rarity, and Rebirths 6 and 7.",
    "The Bloodmoon event and Bloodrot mutation.",
    "More Brainrots and Rebirth 9.",
    "The Rainbow mutation and Rainbow Machine.",
    "The trait system.",
    "Candy Aurora and the Candy mutation.",
    "Lucky Blocks and Rebirth 12.",
    "The Bubblegum Machine and Bubblegum trait.",
    "The Molten event, Lava mutation, and Rebirth 13.",
    "The Fuse Machine.",
    "New Brainrots and Rebirth 14.",
    "The Brazil event.",
    "The Admin War and Galaxy event.",
    "OG rarity debuted with Strawberry Elephant.",
    "The Craft Machine and Rebirth 15.",
    "The Extinct event.",
    "The Mexico event.",
    "The Yin Yang event.",
    "Los Lucky Blocks and Rebirth 16.",
    "Witch Fuse and Witching Hour.",
    "The Indonesia event and Meowl.",
    "Frightrot, the Halloween update.",
    "The 1x1x1x1 ritual.",
    "The Brainrot Dealer and an extension of the Yin Yang event.",
    "Fishing, the Brainrot Trader, and the Radioactive mutation.",
    "Rebirth 17.",
    "Tung Tung Tung Sahur returned.",
    "Santa's Fuse and Winter Hour.",
    "The North Pole event and Festive Lucky Block.",
    "Gingerbread Town and a new index.",
    "Skibidi Toilet joined the OG roster.",
    "The Cursed mutation replaced Radioactive as the featured mutation.",
    "The Duels Machine.",
    "The Bruno Mars concert.",
    "A returning Fuse Machine, a limited-time mode, and a rebirth.",
    "The Ay Mi Gatito ritual and new Brainrots.",
    "Cupid's Machine and the Heart Lucky Block.",
    "The Valentine's Admin Machine and a gift-shop discount.",
    "The Trade Machine and Divine mutation.",
    "The Divine Admin Machine and Headless Horseman base skin.",
    "Divine Fuse and new Brainrots.",
    "The St. Patrick's update with Lucky Pot and Lucky Blocks.",
    "Granny's Funeral and the Eid celebration.",
    "Easter Hour.",
    "Egg Lucky Block, Egg City, an egg hunt, and a fishing mode.",
    "Food Brainrots including Berryno, Appelini, and Strawberrita.",
    "The Cyber mutation and Cyber Craft Machine.",
    "Cyber Admin Machine and new Cyber Craft recipes.",
    "John Pork joined the OG roster.",
    "The Backrooms event.",
    "The first anniversary event and a 30x luck boost.",
    "Summer Fuse.",
    "Summer Lucky Block and the Phantom mutation. The Trade Machine was removed.",
    "The Trade Plaza.",
    "Live football match events.",
    "Fourth of July Brainrots and Var Var Var.",
    "Los Traders and six new Brainrots.",
    "Two Red Carpet additions and a Los Traders addition.",
    "The Crystal mutation.",
    "Summer Fuse was removed and a new ritual arrived.",
    "The Bee event and RNG Machine.",
    "Rebirth 19, new RNG rewards, and La Fuse Machine.",
    "The Bee base and Bee flying gear.",
    "The Bee Admin Machine and additional Brainrots.",
    "The Money Money Puggy ritual.",
    "The Craft Machine returned for OG Craft.",
    "More Craft Machine Brainrots.",
    "Jump for Eggs, a limited-time mode.",
    "Haunted Fuse and the Eclipse mutation.",
    "New bases and the Skull Lucky Block.",
    "The Spooky Scary Skeletons event.",
    "New Brainrots and another event.",
    "The Headless Merchant and Trick or Treat.",
    [52.5] = "Steak's Admin Abuse and Steakini Fattini.",
    [52.75] = "Caylus's Admin Abuse and Caylusaurus.",
}

local catalogPatterns = {
    {2, "^what rarity is (.+)$", "^what is the rarity of (.+)$", "^which rarity is (.+)$"},
    {3, "^how much does (.+) make$", "^how much does (.+) earn$", "^how much does (.+) make per second$",
        "^what is (.+)s income$", "^what is the base income of (.+)$", "^what is the income of (.+)$"},
    {4, "^how much does (.+) cost$", "^what is (.+)s price$", "^what is the price of (.+)$", "^what is the cost of (.+)$"},
    {5, "^how do you get (.+)$", "^how can you get (.+)$", "^where do you get (.+)$", "^how is (.+) obtained$"},
}

local mechanicPatterns = {
    {mutationMultipliers, "^what is the (.+) mutation multiplier$", "^what is the multiplier for the (.+) mutation$", "^how much does the (.+) mutation multiply income$"},
    {traitBonuses, "^what is the (.+) trait multiplier$", "^what is the multiplier for the (.+) trait$", "^how much does the (.+) trait add$"},
    {ritualInputs, "^what do you need for the (.+) ritual$", "^what does the (.+) ritual require$", "^how do you do the (.+) ritual$", "^what is the ritual for (.+)$"},
    {craftInputs, "^what is the craft recipe for (.+)$", "^how do you craft (.+)$", "^what do you need to craft (.+)$"},
    {fuseInputs, "^what is the fuse recipe for (.+)$", "^how do you fuse (.+)$"},
    {luckyDrops, "^what is in the (.+ lucky blocks?)$", "^what can you get from the (.+ lucky blocks?)$", "^what are the drops from the (.+ lucky blocks?)$"},
}

local function lookupGameData(question)
    question = question:gsub(" in sab$", ""):gsub(" in the game$", "")
    local firstWord = question:match("^(%a+)")
    if firstWord ~= "what" and firstWord ~= "which" and firstWord ~= "how" and firstWord ~= "where" and firstWord ~= "when" then
        return nil
    end
    local update = question:match("^what was added in update (%d+%.?%d*)$")
        or question:match("^what changed in update (%d+%.?%d*)$")
        or question:match("^what did update (%d+%.?%d*) add$")
    if update then return updateHighlights[tonumber(update)], true end

    local taco = question:match("^when was taco tuesday (%d+)$") or question:match("^when did taco tuesday (%d+) happen$")
    if taco then
        local edition = tonumber(taco)
        if edition == 53 then return "2026-10-20 (listed schedule)", true end
        return tacoDates[edition]
    end

    local drop, block = question:match("^what are the odds of getting (.+) from the (.+ lucky blocks?)$")
    local drops = block and luckyDrops[block]
    if drops then
        for name, odds in drops:gsub("^Documented drops?: ", ""):gmatch("([^/]+)%s+([%d.]+%%)") do
            if trim(name):lower() == drop then return odds, true end
        end
    end

    local level = question:match("^what do you need for rebirth (%d+)$")
        or question:match("^what are the requirements for rebirth (%d+)$")
        or question:match("^what does rebirth (%d+) require$")
    if level then
        local requirement = rebirthRequirements[tonumber(level)]
        if requirement then return requirement[1] .. " + " .. requirement[2], true end
    end
    level = question:match("^how much cash does rebirth (%d+) require$")
        or question:match("^how much money do you need for rebirth (%d+)$")
        or question:match("^how much does rebirth (%d+) cost$")
    if level then
        local requirement = rebirthRequirements[tonumber(level)]
        if requirement then return requirement[1], true end
    end

    for _, rule in ipairs(catalogPatterns) do
        for i = 2, #rule do
            local name = question:match(rule[i])
            local item = name and brainrotCatalog[name]
            local field = rule[1]
            if item and item[field] then
                local value = item[field]
                local alternate = field == 2 and item[7] or field == 3 and item[6]
                if alternate then return value .. " / " .. alternate .. " (catalogs differ)", true end
                if field == 2 and (value == "Lucky Block" or value == "Event exclusive") then
                    return value .. " (catalog category)", true
                end
                if field == 5 then return value .. " (reported route)", true end
                return value, field ~= 2
            end
        end
    end

    for _, rule in ipairs(mechanicPatterns) do
        for i = 2, #rule do
            local name = question:match(rule[i])
            local value = name and rule[1][name]
            if value then return value, true end
        end
    end
end

-- Each row is an answer plus one or more required clue groups. Alternatives
-- within a group are equivalent. A rule only runs for its requested answer type.
-- Event and visual references:
-- https://stealabrainrot.wiki/wiki/events/
-- https://stealabrainrot.wiki/wiki/traits/
-- https://stealabrainrot.wiki/wiki/witching-hour-event/
-- https://stealabrainrot.wiki/wiki/halloween/
-- https://stealabrainrot.wiki/wiki/headless-merchant/
local clueRules = {
    event = {
        {"Witching Hour", {"purple hat", "purple witch hat", "purple pointy hat", "purple wizard hat", "purple hats", "purple witch hats", "witch hat", "witch hats", "witches hat"}},
        {"Witching Hour", {"purple grass", "grass turns purple", "grass turned purple", "turned the grass purple", "purple environment", "purple sky"}, {"pumpkin", "pumpkins", "halloween"}},
        {"Graveyard", {"agarrini shovel", "dig graves", "digging graves", "rip tombstone", "dig up graves"}},
        {"Trick or Treating", {"knock on doors", "knock on houses", "knocking on doors", "knock on the door", "lit houses", "door to door", "jack o lantern pet"}, {"candy", "candy corn", "halloween", "jack o lantern pet"}},
        {"Trick or Treating", {"roller coaster", "rollercoaster"}, {"halloween", "candy", "houses"}},
        {"Bloodmoon", {"bloodrot", "blood rot"}},
        {"Bloodmoon", {"first event", "first ever event", "earliest event"}, {"red moon", "blood red sky", "sky turned red"}},
        {"Candy Aurora", {"candy mutation"}, {"pink", "aurora", "introduced", "added", "gave", "applied"}},
        {"Molten Event", {"lava mutation", "molten mutation"}, {"added", "introduced", "gave", "applied"}},
        {"Galaxy Event", {"galaxy mutation"}, {"admin war", "jandel", "added", "introduced", "gave", "applied"}},
        {"Winter Hour", {"santa hat", "santa hats"}, {"christmas", "snow", "brainrot", "brainrots", "trait"}},
        {"Gingerbread Town", {"money money reindeer"}},
        {"North Pole", {"festive lucky block"}, {"christmas", "holiday", "winter", "introduced", "added"}},
        {"Starfall", {"cometstruck", "comet struck"}},
        {"Starfall", {"stars fall", "falling stars", "stars fell"}, {"sparks", "red carpet", "brainrot", "brainrots"}},
        {"Raining Tacos", {"taco cannon", "tacos fall", "falling tacos"}, {"taco trait", "red carpet", "brainrot", "brainrots"}},
        {"Egg City", {"gold eggs", "golden eggs"}, {"city", "houses", "neighborhood"}},
        {"Egg City", {"pink egg trait", "blue egg trait"}},
        {"Fishing", {"fishing rod", "fishing rods"}, {"water", "flooded", "catch", "brainrot", "brainrots"}},
        {"Valentines", {"chocolate trait", "chocolate aura", "covered in chocolate"}, {"pink", "heart", "valentine", "valentines"}},
        {"First Anniversary", {"30x luck", "30 x luck"}, {"1yr", "one year", "first anniversary", "anniversary", "birthday"}},
        {"Admin Abuse War", {"jandel", "grow a garden"}, {"sammy", "spyder sammy", "spydersammy", "war", "competition", "concurrent players"}},
        {"North Pole", {"train", "christmas train"}, {"snow", "different map", "christmas", "red carpet"}},
        {"Extinct", {"fossils", "dinosaur bones"}, {"dry", "dried out", "ribs", "extincty"}},
        {"Easter Hour", {"bunny ears", "rabbit ears"}, {"easter", "bunnies", "rabbits", "brainrot", "brainrots"}},
        {"Live Match Events", {"goal posts", "goalposts", "soccer balls", "football match"}, {"tunnels", "red carpet", "country flag", "country flags", "brainrot", "brainrots"}},
        {"Brazil Event", {"favelas", "brazilian flag"}, {"speaker", "laser beams", "favelas", "flag"}},
        {"Indonesia Event", {"aura boat"}, {"indonesia", "indonesian", "city", "flag"}},
        {"Halloween 2026", {"witch skeleton", "vampire skeleton"}, {"2026", "skeletons"}, preview=true},
    },
    trait = {
        {"Witch Hat", {"witching hour", "purple witch hat", "purple hat", "purple pointy hat", "purple wizard hat", "purple hats", "purple witch hats"}},
        {"RIP Tombstone", {"grave digger", "graveyard", "tombstone", "gravestone"}, {"halloween", "head", "brainrot", "brainrots", "grave digger", "graveyard"}},
        {"Jack O Lantern Pet", {"trick or treating", "trick or treat"}, {"pumpkin", "pet", "halloween", "jack o lantern"}},
        {"Santa Hat", {"winter hour"}, {"santa", "festive", "christmas", "hat", "brainrot", "brainrots"}},
        {"Reindeer Pet", {"mini reindeer", "small reindeer", "little reindeer"}, {"christmas", "follows", "pet", "brainrot", "brainrots"}},
        {"Strawberry", {"strawberry elephant"}, {"stem hat", "strawberry texture", "red sky", "spawn", "spawns", "gives", "gave"}},
        {"Meowl", {"cat ears", "cat ear"}, {"tail", "meowl", "tree", "trees"}},
        {"John Pork", {"is calling", "decline call", "accept call"}, {"phone", "green", "red", "name", "brainrot", "brainrots"}},
        {"Skibidi", {"toilet head", "skibidi toilet"}, {"head", "spawn", "spawns", "gives", "gave"}},
        {"Bubblegum", {"bubblegum machine", "gum bubble", "bubblegum bubble"}},
        {"Taco", {"taco cannon", "raining tacos", "tacos on their head", "taco on the head"}},
        {"UFO", {"mini ufo", "alien beam", "ufo beam", "flying saucer above"}},
        {"Claws", {"crab arms", "crab claws", "crab rave"}},
        {"Aura Shades", {"deal with it", "deal with it shades"}, {"glasses", "shades", "sunglasses", "caylus"}},
        {"Sleepy", {"fell asleep", "fall asleep", "floating z", "floating zs", "halves income", "cuts income in half"}},
        {"Zombie", {"evil tung tung", "evil los tung"}, {"red eyes", "attacks", "attack", "hit"}},
        {"Spider", {"sammyni spyderini ritual", "spider on the eye", "spider covers"}, {"eye", "cobweb", "sammyni spyderini", "spider"}},
        {"Matteo Hat", {"bowler hat", "matteo ritual"}, {"tree", "lightning", "matteo", "head", "hat"}},
        {"Tie", {"graduation platform", "graduation stage", "dul dul dul ritual"}},
        {"Galactic", {"la vacca saturno saturnita ritual", "las vaquitas saturnitas ritual"}},
        {"Explosive", {"bombardiro crocodilo ritual", "bombardiro bombing"}},
        {"Chocolate", {"chocolate aura", "covered in chocolate", "chocolate heart box"}},
        {"Wet", {"water droplets", "raindrops", "rain drops"}, {"rain", "cloudy", "water", "head"}},
        {"Snowy", {"snowflakes", "snow flakes"}, {"snow", "falling", "white grass", "brainrot", "brainrots"}},
        {"Bunny Ears", {"easter hour", "rabbit ears", "bunny ears"}, {"head", "easter", "bunny", "bunnies", "gave", "gives"}},
        {"Pink Egg", {"pink egg"}, {"egg city", "easter", "brainrot", "brainrots"}},
        {"Ball", {"goal posts", "goalposts", "hit by a futbol"}, {"soccer", "football", "match", "futbol"}},
        {"Extincty", {"rib cage", "ribs"}, {"chest", "fossils", "extinct", "dinosaur"}},
        {"Brazil", {"brazilian flag"}, {"laser", "lasers", "favelas", "brainrot", "brainrots"}},
        {"Indonesian", {"aura boat", "indonesian flag"}, {"indonesia", "indonesian", "flag", "brainrot", "brainrots"}},
        {"26", {"new year machine", "new years machine"}, {"2026", "26", "skyscrapers", "text"}},
        {"1 Year", {"1yr", "1 yr"}, {"anniversary", "blue text", "above", "head"}},
        {"Cometstruck", {"starfall", "star fall", "falling stars", "stars fall"}, {"sparks", "brainrot", "brainrots", "red carpet"}},
    },
    mutation = {
        {"Bloodrot", {"bloodmoon", "blood moon"}},
        {"Candy", {"candy aurora"}},
        {"Lava", {"molten event", "molten wheel"}},
        {"Galaxy", {"galaxy event"}, {"admin war", "jandel", "purple", "introduced", "added", "gave"}},
        {"Radioactive", {"radioactive event", "neon green"}, {"fishing", "hatch texture", "green", "radioactive event"}},
        {"Yin Yang", {"black and white", "yin yang event"}, {"half", "split", "two halves", "yin yang event"}},
        {"Eclipse", {"eclipse event", "haunted fuse"}, {"black and yellow", "yellow eyes", "october 2026", "14x", "14 x", "eclipse event"}},
        {"Phantom", {"summer lucky block", "summer update"}, {"transparent", "see through", "12x", "12 x"}},
        {"Crystal", {"crystal event"}, {"purple", "blue", "13x", "13 x", "introduced", "added", "gave"}},
        {"Cyber", {"cyber craft machine", "cyber event"}, {"11x", "11 x", "black and blue", "introduced", "added", "gave"}},
        {"Diamond", {"cyan", "diamond blue", "light blue"}, {"1 5x", "1 5 x", "1 5 times"}},
        {"Gold", {"yellow", "golden"}, {"1 25x", "1 25 x", "1 25 times"}},
        {"Rainbow", {"cycles colors", "cycles colours", "changes color", "changes colour", "rgb"}, {"10x", "10 x", "rgb", "rainbow colors", "rainbow colours"}},
    },
    brainrot = {
        {"Noobini Pizzanini", {"tutorial", "starter", "starting"}, {"first", "25", "1 per second", "pizza", "buy"}},
        {"Strawberry Elephant", {"first og", "introduced og rarity", "debuted og rarity"}},
        {"Meowl", {"second og", "cat owl", "owl cat", "cat and owl", "owl with a cat head"}},
        {"Skibidi Toilet", {"third og", "head in a toilet", "head sticking out of a toilet"}},
        {"John Pork", {"phone", "calling"}, {"og", "green call", "decline button", "pig"}},
        {"La Vacca Saturno Saturnita", {"cow"}, {"saturn", "planet with rings"}},
        {"Los Crocodillitos", {"bombardiro crocodilo"}, {"ritual", "three players"}},
        {"Los Spyderinis", {"sammyni spyderini"}, {"ritual", "four players", "square"}},
        {"Los Matteos", {"matteo"}, {"ritual", "on top of each other"}},
        {"Los Orcalitos", {"orcalero orcala", "orcalita orcala"}, {"ritual", "four players"}},
        {"Los Chicleteiras", {"chicleteira bicicleteira"}, {"ritual", "two players"}},
        {"Las Vaquitas Saturnitas", {"la vacca saturno saturnita"}, {"ritual", "triangle formation"}},
        {"Los Karkeritos", {"karkerkar kurkur"}, {"ritual", "cube"}},
        {"Los Mi Gatitos", {"mi gatito"}, {"ritual", "hug"}},
        {"Los Puggies", {"money money puggy"}, {"ritual", "two players", "money rain"}},
        {"Puppetmaster", {"headless merchant"}, {"12500 candy", "12 500 candy", "12500 candycorn", "12 500 candycorn"}},
        {"Scorpi Inferni", {"headless merchant"}, {"7500 candy", "7 500 candy", "7500 candycorn", "7 500 candycorn"}},
        {"Jacko Jakat", {"headless merchant"}, {"3500 candy", "3 500 candy", "3500 candycorn", "3 500 candycorn"}},
        {"Spooky Kart", {"headless merchant"}, {"1000 candy", "1 000 candy", "1000 candycorn", "1 000 candycorn"}},
        {"Scarino Crowino", {"trick or treat", "trick or treating"}, {"update 73", "2026", "135m", "135 million"}},
    },
    machine = {
        {"Headless Merchant", {"candy corn", "candy corns", "candycorn"}, {"spooky kart", "jacko jakat", "scorpi inferni", "puppetmaster"}},
        {"RNG Machine", {"bee event", "update 61"}, {"roll", "rolling", "rng", "introduced", "added"}},
        {"Witch Fuse", {"witching hour", "october 11 2025", "update 20"}, {"witch", "halloween", "fuse", "replaced"}},
        {"Santa's Fuse", {"winter hour", "update 28"}, {"santa", "winter", "christmas", "fuse"}},
        {"Bubblegum Machine", {"bubblegum trait", "bubblegum bubble"}, {"candy", "brainrot", "brainrots", "gave", "gives", "made"}},
        {"Rainbow Machine", {"rainbow mutation"}, {"update 4", "june 21 2025", "introduced", "added"}},
        {"Duels Machine", {"duels", "dueling"}, {"update 33", "january 10 2026", "one on one", "1v1"}},
        {"Trade Machine", {"update 39", "february 21 2026"}, {"trading", "trade", "divine mutation"}},
        {"Brainrot Dealer", {"yin yang event"}, {"update 24", "november 8 2025", "dealer"}},
    },
}

local clueKinds = {
    event="event", weather="event", trait="trait", mutation="mutation",
    brainrot="brainrot", character="brainrot", unit="brainrot", og="brainrot",
    machine="machine", shop="machine", merchant="machine", vendor="machine", fuse="machine",
}
local rarityWords = {"brainrot god", "event exclusive", "legendary", "common", "secret", "mythic", "epic", "rare", "og"}
local cashUnits = {
    k=1e3, thousand=1e3, m=1e6, million=1e6, b=1e9, billion=1e9,
    t=1e12, trillion=1e12, qa=1e15, quadrillion=1e15,
}

local function hasPhrase(padded, phrase)
    return padded:find(" " .. phrase .. " ", 1, true) ~= nil
end

local function cashValue(number, unit)
    local value = tonumber(number)
    return value and value * (cashUnits[unit] or 1)
end

local function amountAfter(text, verbs)
    for _, verb in ipairs(verbs) do
        local number, unit = text:match("%f[%a]" .. verb .. "%s*[:=]?%s*%$?%s*(%d+%.?%d*)%s*(%a*)")
        if number then return cashValue(number, unit) end
    end
end

local catalogByCash
local function cashIndex()
    if catalogByCash then return catalogByCash end
    catalogByCash = {cost={}, income={}}
    local function add(index, amount, item)
        if not amount then return end
        local number, unit = amount:match("^%$(%d+%.?%d*)(%a*)")
        local value = cashValue(number, unit and unit:lower())
        if not value then return end
        local entries = index[value]
        if not entries then
            entries = {}
            index[value] = entries
        end
        entries[item[1]] = item
    end
    for _, item in pairs(brainrotCatalog) do
        add(catalogByCash.cost, item[4], item)
        add(catalogByCash.income, item[3], item)
        add(catalogByCash.income, item[6], item)
    end
    return catalogByCash
end

local function resolveClueMatches(matches)
    local answers = {}
    for name in pairs(matches) do answers[#answers + 1] = name end
    if #answers == 1 then return answers[1], matches[answers[1]] end
    if #answers > 1 then
        table.sort(answers)
        local list = table.concat(answers, " / ", 1, math.min(3, #answers))
        return "Possible answers: " .. list .. (#answers > 3 and " / …" or ""), true
    end
end

local function catalogClue(question, padded)
    local rarity
    for _, name in ipairs(rarityWords) do
        if hasPhrase(padded, name) then
            rarity = name
            break
        end
    end
    local amounts = question:gsub("(%d),(%d%d%d)", "%1%2"):gsub("(%d),(%d%d%d)", "%1%2")
    local cost = amountAfter(amounts, {"costs", "cost", "price of", "priced at", "costing"})
    local income = amountAfter(amounts, {"makes", "make", "earns", "earn", "generates", "generate", "income of", "produces"})
    if not (cost and income) and not (rarity and (cost or income)) then return end

    local index = cashIndex()
    local costMatches = cost and index.cost[cost]
    local incomeMatches = income and index.income[income]
    if (cost and not costMatches) or (income and not incomeMatches) then return end
    local matches = {}
    for name, item in pairs(costMatches or incomeMatches) do
        local currentRarity = item[2] and item[2]:lower()
        local alternateRarity = item[7] and item[7]:lower()
        if (not incomeMatches or incomeMatches[name]) and (not rarity or rarity == currentRarity or rarity == alternateRarity) then
            matches[name] = (income ~= nil and item[6] ~= nil) or (rarity ~= nil and item[7] ~= nil)
        end
    end
    return resolveClueMatches(matches)
end

local function lookupClue(question)
    if #question > 1200 then return end
    local first = question:match("^(%a+)")
    local selfDescription = first == "i" and (question:find("what am i", 1, true) or question:find("who am i", 1, true))
    local dateQuestion = first == "when"
    if first ~= "what" and first ~= "which" and first ~= "name" and not selfDescription
        and not dateQuestion and not question:match("^in which update ") then return end

    local words = trim(question:gsub("[^%w]+", " "))
    local padded = " " .. words .. " "
    for _, exclusion in ipairs({"not", "never", "except", "without"}) do
        if hasPhrase(padded, exclusion) then return end
    end
    local updateQuestion = words:match("^what update ") or words:match("^which update ")
        or words:match("^in which update ")
    -- Pick the thing being asked for before scanning the clues. For example,
    -- "what trait did the event give" asks for a trait, not an event.
    local kind
    for word in words:gmatch("%w+") do
        if word == "that" or word == "costs" or word == "makes"
            or (not updateQuestion and not dateQuestion and (word == "did" or word == "introduced"))
            or word == "gave" or word == "gives" then break end
        kind = clueKinds[word]
        if kind then break end
    end
    if selfDescription and not kind then
        for _, word in ipairs(rarityWords) do
            if hasPhrase(padded, word) then kind = "brainrot"; break end
        end
    end
    if not kind then return end

    local matches = {}
    for _, rule in ipairs(clueRules[kind]) do
        local complete = true
        for i = 2, #rule do
            local found = false
            for _, phrase in ipairs(rule[i]) do
                if hasPhrase(padded, phrase) then found = true; break end
            end
            if not found then complete = false; break end
        end
        if complete then
            local name = rule[1]
            matches[name] = matches[name] ~= false and rule.preview == true
        end
    end
    local answer, preview = resolveClueMatches(matches)
    if updateQuestion or dateQuestion then
        local update = answer and not preview and milestones[answer:lower()]
        if update then
            if dateQuestion then return updateDates[update] end
            return tostring(update), update % 1 ~= 0
        end
        return
    end
    if answer then return answer, preview end
    if kind == "brainrot" then return catalogClue(question, padded) end
end

local function lookupHistory(text)
    local question = text:lower():gsub("’", "'"):gsub("é", "e")
    question = question:gsub("['#]", ""):gsub("%-", " "):gsub("%s+", " ")
    question = trim(question:gsub("[%?!.]+$", ""))
    question = question:gsub("^witchs%s+riddle%s*[:=]?%s*", ""):gsub("^riddle%s*[:=]%s*", ""):gsub("^riddle%s+", "")
    question = question:gsub("^trivia%s*[:=]%s*", ""):gsub("^question%s*[:=]%s*", "")
    question = question:gsub("steal a brainrot", "sab"):gsub("steal a brain rot", "sab")

    -- Catalog keys use common Latin spellings so accents are optional in questions.
    if question:find("[\128-\255]") then
        for accented, plain in pairs({["à"]="a", ["á"]="a", ["â"]="a", ["ä"]="a", ["ç"]="c",
        ["è"]="e", ["ê"]="e", ["ë"]="e", ["ì"]="i", ["í"]="i", ["î"]="i", ["ï"]="i",
        ["ñ"]="n", ["ò"]="o", ["ó"]="o", ["ô"]="o", ["ö"]="o", ["ù"]="u", ["ú"]="u", ["ü"]="u",
        ["À"]="a", ["Á"]="a", ["È"]="e", ["É"]="e", ["Ì"]="i", ["Í"]="i", ["Ñ"]="n", ["Ò"]="o", ["Ó"]="o"}) do
            question = question:gsub(accented, plain)
        end
    end

    local fact = historyQuestions[question]
    if fact then
        local answer = fact.answer
        if type(answer) == "function" then answer = answer() end
        return answer, fact.previewOnly
    end

    local update = question:match("^when was update (%d+%.?%d*) released$")
        or question:match("^when did update (%d+%.?%d*) come out$")
        or question:match("^when was update (%d+%.?%d*)$")
        or question:match("^what was the release date of update (%d+%.?%d*)$")
    if update then
        local number = tonumber(update)
        if number == 74 then return "2026-11-07 (listed schedule)", true end
        return updateDates[number]
    end

    local topic = question:match("^when was (.+) added$")
        or question:match("^when was (.+) released$")
        or question:match("^when was (.+) introduced$")
        or question:match("^when did (.+) come out$")
        or question:match("^when did (.+) debut$")
        or question:match("^when did (.+) start$")
    if topic then
        local date = updateDates[milestones[topic:gsub("^the ", "")]]
        if date then return date end
    end

    topic = question:match("^what update added (.+)$")
        or question:match("^which update added (.+)$")
        or question:match("^what update introduced (.+)$")
        or question:match("^which update introduced (.+)$")
        or question:match("^what update did (.+) come out in$")
    local number = topic and milestones[topic:gsub("^the ", "")]
    if number then return tostring(number), number % 1 ~= 0 end
    local answer, preview = lookupGameData(question)
    if answer then return answer, preview end
    return lookupClue(question)
end

local function solveBase(text, facts, historyAnswer, historyPreviewOnly)
    local clean = Parser.clean(text)
    local l = clean:lower()
    for question, answer in pairs(facts or {}) do
        if trim(tostring(question):lower()) == l then return code(tostring(answer)), "configured answer" end
    end

    if historyAnswer then
        if historyPreviewOnly then return nil, "SAB history", historyAnswer end
        return code((historyAnswer:gsub("%s+", ""))), "SAB history", historyAnswer
    end

    local reversed = l:match('[Rr]everse%s+["\'`](.-)["\'`]')
        or l:match('[Ss]pell%s+["\'`](.-)["\'`]%s+[Bb]ackward')
        or l:match('[Rr]everse%s+([%w_%-]+)%s*[%.!?]*$')
        or l:match('[Ss]pell%s+([%w_%-]+)%s+[Bb]ackwards?%s*[%.!?]*$')
    if reversed then return code(reversed:gsub("%s+", ""):reverse()), "reversed text" end

    local initials = l:match('[Ff]irst%s+[Ll]etters?%s+[Oo]f%s*[:=]?%s*(.+)')
        or l:match('[Ii]nitials%s+[Oo]f%s*[:=]?%s*(.+)')
    if initials then
        local letters = {}
        for word in initials:gmatch("[%a%d]+") do letters[#letters + 1] = word:sub(1, 1) end
        if #letters >= 2 and #letters <= 20 then return code(table.concat(letters)), "initials" end
    end

    local mathText = l
    local words = {zero="0",one="1",two="2",three="3",four="4",five="5",six="6",seven="7",eight="8",nine="9",ten="10",eleven="11",twelve="12",twenty="20"}
    for word, number in pairs(words) do mathText = mathText:gsub("%f[%a]" .. word .. "%f[%A]", number) end
    for _, replacement in ipairs({{"multiplied by","*"},{"divided by","/"},{"times","*"},{"plus","+"},{"minus","-"},{"modulo","%"}}) do
        mathText = mathText:gsub("%f[%a]" .. replacement[1] .. "%f[%A]", function() return replacement[2] end)
    end
    local expression = mathText:match("calculate%s*[:=]?%s*([%d%.%s%+%-%*/%%%(%)%^]+)")
        or mathText:match("what%s+is%s+([%d%.%s%+%-%*/%%%(%)%^]+)")
        or mathText:match("solve%s*[:=]?%s*([%d%.%s%+%-%*/%%%(%)%^]+)")
        or mathText:match("^%s*([%d%.%s%+%-%*/%%%(%)%^]+)%s*[%?=]*$")
    if expression and expression:find("[%+%-%*/%%%^]") then
        expression = trim(expression):gsub("%.$", "")
        local answer = arithmetic(expression)
        if answer then return code(answer), "arithmetic" end
    end

    -- Generic word riddles use specific clue combinations.
    local clues = {
        {"keys", "space", "KEYBOARD"}, {"keys", "locks", "PIANO"}, {"hands", "clap", "CLOCK"},
        {"wetter", "dries", "TOWEL"}, {"cities", "houses", "MAP"},
        {"speak", "mouth", "ECHO"}, {"head", "tail", "COIN"},
        {"neck", "head", "BOTTLE"}, {"eye", "see", "NEEDLE"},
        {"full of holes", "water", "SPONGE"}, {"take away", "bigger", "HOLE"},
        {"young", "tall", "CANDLE"}, {"break", "use", "EGG"},
        {"goes up", "comes down", "AGE"},
    }
    for _, clue in ipairs(clues) do
        if l:find(clue[1], 1, true) and l:find(clue[2], 1, true) then return clue[3], "known riddle" end
    end
end

-- Pure data solver. Runtime adapters supply observed data; no HTTP or game access here.
local Smart = {}
do
    local accents = {
        ["à"]="a",["á"]="a",["â"]="a",["ã"]="a",["ä"]="a",["å"]="a",
        ["À"]="a",["Á"]="a",["Â"]="a",["Ã"]="a",["Ä"]="a",["Å"]="a",
        ["è"]="e",["é"]="e",["ê"]="e",["ë"]="e",["È"]="e",["É"]="e",["Ê"]="e",["Ë"]="e",
        ["ì"]="i",["í"]="i",["î"]="i",["ï"]="i",["Ì"]="i",["Í"]="i",["Î"]="i",["Ï"]="i",
        ["ò"]="o",["ó"]="o",["ô"]="o",["õ"]="o",["ö"]="o",["Ò"]="o",["Ó"]="o",["Ô"]="o",["Õ"]="o",["Ö"]="o",
        ["ù"]="u",["ú"]="u",["û"]="u",["ü"]="u",["Ù"]="u",["Ú"]="u",["Û"]="u",["Ü"]="u",["ñ"]="n",["Ñ"]="n",["ç"]="c",["Ç"]="c",
    }
    function Smart.fold(value)
        local s = Parser.clean(value)
        for accented, plain in pairs(accents) do s = s:gsub(accented, plain) end
        return trim(s:lower():gsub("[’']", ""):gsub("[_%-]", " "):gsub("%s+", " "):gsub("[%?!%.]+$", ""))
    end
    function Smart.code(value)
        local s = Smart.fold(value):upper():gsub("[^A-Z0-9]", "")
        if #s > 0 and #s <= 80 then return s end
    end
    function Smart.number(value)
        if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return nil end
        if math.abs(value) < 1e16 and value % 1 == 0 then return string.format("%.0f", value) end
        return string.format("%.12g", value)
    end
    local function phrase(s, word)
        return (" " .. s .. " "):find(" " .. word .. " ", 1, true) ~= nil
    end
    local function result(value, reason, preview)
        return {code=not preview and Smart.code(value) or nil, display=tostring(value), reason=reason, preview=preview}
    end
    -- Parse amounts before folding punctuation: commas and decimal points matter.
    function Smart.incomeClue(text)
        local q=Parser.clean(text):lower():gsub("(%d),(%d%d%d)","%1%2"):gsub("(%d),(%d%d%d)","%1%2"):gsub("(%d),(%d%d%d)","%1%2")
        local amount
        local function note(number,unit)
            if unit~="" and not cashUnits[unit] then return end
            local value=cashValue(number,unit)
            if not value or value<=0 then return end
            if amount and math.abs(amount-value)>math.max(0.001,value*1e-10) then return false end
            amount=value
            return true
        end
        for _,pattern in ipairs({"(%d+%.?%d*)%s*(%a*)%s*/%s*s%f[%A]",
            "(%d+%.?%d*)%s*(%a*)%s+per%s+second%f[%A]",
            "(%d+%.?%d*)%s*(%a*)%s+a%s+second%f[%A]"}) do
            for number,unit in q:gmatch(pattern) do if note(number,unit)==false then return nil,"conflicting income figures" end end
        end
        for _,verb in ipairs({"does","do","makes","make","earns","earn","generates","generate","produces","income of"}) do
            local number,unit=q:match("%f[%a]"..verb.."%s*[:=]?%s*%$?%s*(%d+%.?%d*)%s*(%a*)")
            if number and note(number,unit)==false then return nil,"conflicting income figures" end
        end
        return amount
    end
    function Smart.identifiesBrainrot(text)
        local q=Smart.fold(text)
        return (phrase(q,"brainrot") or phrase(q,"brainrots")) and
            (q:find("name",1,true) or q:find("which",1,true) or q:find("what brainrot",1,true)
                or q:find("brainrot that",1,true) or q:find("one that",1,true) or q:find("on that",1,true))~=nil
    end
    function Smart.confirmedExample(text)
        local q=Smart.fold(text):gsub(",",""):gsub("the on that","the one that"):gsub("%s+"," ")
            :gsub("^riddle%s*:%s*","")
        if q=="its the name of the brainrot that released today the one that does 23.5m/s" then
            -- User-confirmed on 2026-11-08. A replay is not evidence of today's release.
            return {code="BALLOONBABOON",display="Balloon Baboon",reason="user-confirmed test example (2026-11-08)"}
        end
    end
    local function unique(rows, field, descending, ordinal)
        local candidates = {}
        for _, row in ipairs(rows or {}) do
            if type(row[field]) == "number" then candidates[#candidates+1] = row end
        end
        table.sort(candidates, function(a,b)
            if a[field] == b[field] then return a.name < b.name end
            if descending then return a[field] > b[field] end
            return a[field] < b[field]
        end)
        local index = ordinal or 1
        local chosen = candidates[index]
        if not chosen then return nil end
        -- A tie has no unique ordinal answer.
        if (candidates[index-1] and candidates[index-1][field] == chosen[field])
            or (candidates[index+1] and candidates[index+1][field] == chosen[field]) then
            return result("Tied " .. field .. " values; review the live list", "live ranking", true)
        end
        return result(chosen.name, "live " .. field .. " ranking")
    end
    function Smart.new()
        local self = {context={}, messages={}, memory={}, revision=0}
        function self:setContext(context)
            self.context = type(context) == "table" and context or {}
            self.revision = self.revision + 1
        end
        function self:remember(text, now)
            text = Parser.clean(text)
            if #text < 1 or #text > 1200 then return end
            self.messages[#self.messages+1] = {text=text, time=now}
            while #self.messages > 50 or (#self.messages > 0 and now-self.messages[1].time > 900) do
                table.remove(self.messages, 1)
            end
            local q = Smart.fold(text)
            if text:find("?",1,true) or q:match("^riddle") or q:match("^what ") then return end
            local patterns = {
                {"name", "^my name is (.+)$"}, {"age", "^my age is (%d+)$"}, {"age", "^i am (%d+) years old$"},
                {"favorite color", "^my favou?rite colou?r is (.+)$"},
                {"favorite brainrot", "^my favou?rite brainrot is (.+)$"},
                {"country", "^my country is (.+)$"}, {"number", "^the number is (%d+)$"},
                {"brainrot", "^the brainrot is (.+)$"}, {"word", "^the word is ([%w]+)$"},
            }
            for _, rule in ipairs(patterns) do
                local value = q:match(rule[2])
                if value and #value <= 80 then self.memory[rule[1]] = {value=value,time=now,source=text} end
            end
        end
        function self:memoryValue(key, now)
            local item = self.memory[key]
            if item and now-item.time <= 900 then return result(item.value, "earlier announcement") end
        end
        function self:reverseIncome(q,now)
            if not Smart.identifiesBrainrot(q) then return nil end
            local income,err=Smart.incomeClue(q)
            if err then return result(err,"income clue needs review",true) end
            if not income then return nil end
            local c=self.context
            local words=trim(q:gsub("[^%w%s]"," "):gsub("%s+"," "))
            for _,word in ipairs({"not","except","without"}) do
                if phrase(words,word) then return result("Negated income clues need review","income clue needs review",true) end
            end
            local today=phrase(words,"today")
            local newest=phrase(words,"new") or phrase(words,"newest") or phrase(words,"latest")
                or q:find("just released",1,true) or q:find("just added",1,true)
            local releaseConstraint=today or newest
            local rarity
            for _,value in ipairs(rarityWords) do if phrase(words,value) then rarity=value;break end end
            local rows,seen={},{}
            for _,row in ipairs(c.animals or {}) do
                local id=Smart.code(row.name)
                if id then rows[#rows+1]=row;seen[id]=true end
            end
            -- Live values replace the old entry for the same name. Older catalog
            -- entries remain candidates, so a shared income never looks unique.
            for _,row in pairs(brainrotCatalog) do
                if not seen[Smart.code(row[1])] then
                    local n,u=(row[3] or ""):match("^%$(%d+%.?%d*)(%a*)")
                    if n then rows[#rows+1]={name=row[1],rarity=row[2],income=cashValue(n,u:lower()),catalog=true} end
                end
            end
            local matches,unverified={},{}
            local named={}
            for _,row in ipairs(rows) do if phrase(q,Smart.fold(row.name)) then named[Smart.code(row.name)]=true end end
            local hasNamed=next(named)~=nil
            for _,row in ipairs(rows) do
                local same=type(row.income)=="number" and math.abs(row.income-income)<=math.max(0.001,income*1e-10)
                if same and (not rarity or Smart.fold(row.rarity)==rarity) and (not hasNamed or named[Smart.code(row.name)]) and row.enabled~=false then
                    local verified=not releaseConstraint
                    if releaseConstraint and c.observedAt and now-c.observedAt<=5 then
                        if today then
                            verified=row.releaseDay~=nil and c.calendar and row.releaseDay==c.calendar.date and row.releaseConfirmed==true
                        else
                            verified=row.updateId~=nil and c.currentUpdate and row.updateId==c.currentUpdate.id
                                and row.enabled==true
                        end
                    end
                    if verified then matches[#matches+1]=row else unverified[#unverified+1]=row.name end
                end
            end
            if #matches==1 then
                return result(matches[1].name,releaseConstraint and "live release + income match" or "income clue match")
            end
            if #matches>1 then
                local names={};for _,row in ipairs(matches) do names[#names+1]=row.name end
                table.sort(names)
                return result("Multiple brainrots match that income: "..table.concat(names,", "),"income clue needs review",true)
            end
            if releaseConstraint then
                table.sort(unverified)
                return result("Release timing is unreadable or no released brainrot matches "..Smart.number(income).."/s"
                    ..(#unverified>0 and (". Income-only candidates: "..table.concat(unverified,", ")) or ""),"release clue needs live evidence",true)
            end
            return result("No brainrot matches "..Smart.number(income).."/s in the available data","income clue needs review",true)
        end
        function self:atom(raw, facts, now, allowLiteral)
            local q = Smart.fold(raw):gsub("^the ", "")
            local c = self.context
            for key, value in pairs(facts or {}) do
                if type(key) == "string" and Smart.fold(key) == q
                    and (type(value) == "string" or type(value) == "number") then
                    return result(value, "configured answer")
                end
            end
            local memoryKeys = { ["my name"]="name",["my age"]="age",["my country"]="country",
                ["my favorite color"]="favorite color",["my favourite colour"]="favorite color",
                ["my favourite color"]="favorite color",["my favorite colour"]="favorite color",
                ["my favorite brainrot"]="favorite brainrot",["my favourite brainrot"]="favorite brainrot",
                ["number i said earlier"]="number",["what number did i say earlier"]="number",
                ["what brainrot did i mention earlier"]="brainrot",["brainrot i mentioned earlier"]="brainrot",
                ["word i said earlier"]="word",
            }
            if memoryKeys[q] then return self:memoryValue(memoryKeys[q], now) end
            -- These separators introduce components, except when part of an exact name.
            if q:find(" plus ",1,true) or q:find("+",1,true) then return nil end
            if q == "current month" or q == "this month" or q == "current year" or q == "this year" then
                -- Supplied by the adapter in America/New_York, matching event time.
                local key = q:find("month",1,true) and "month" or "year"
                if c.calendar then return result(c.calendar[key], "current event date") end
                return nil
            end
            local fresh = c.observedAt and now-c.observedAt <= 5
            local mutationNow = q == "current mutation" or q == "mutation running now" or q == "mutation running right now"
                or q == "what mutation is running now" or q == "one we are in right now"
            local eventNow = q == "current event" or q == "event right now" or q == "event running now"
                or q == "what event are we in right now" or q == "what event is running now"
            local traitNow = q == "current trait" or q == "trait running now" or q == "trait running right now"
            if mutationNow or eventNow or traitNow then
                if not fresh then return result("Live event data is unavailable or stale", "live context", true) end
                local names = mutationNow and c.activeMutations or traitNow and c.activeTraits or c.events
                if names and #names == 1 then return result(names[1], "live event") end
                return result(names and #names > 1 and ("Multiple active matches: " .. table.concat(names, ", "))
                    or "No readable active match", "live context", true)
            end
            local luck = q == "current luck" or q == "luck that is running" or q == "luck running now"
                or q == "server luck" or q == "what is the current luck"
            if luck then
                if fresh and c.serverLuck then return result(Smart.number(c.serverLuck) .. "X", "live server luck") end
                return result("Server luck multiplier is unreadable", "live context", true)
            end
            if q == "fuse machine luck" or q == "rng machine luck" then
                local n = q:sub(1,4) == "fuse" and c.fuseLuck or c.rngLuck
                if fresh and type(n) == "number" then return result(Smart.number(n) .. "X", "live machine luck") end
                return result("Machine luck multiplier is unreadable", "live context", true)
            end
            if q:find(" and ",1,true) and not q:find(" with ",1,true) then
                local masked=q
                -- 'Released today and makes 23.5M/s' joins two predicates,
                -- rather than requesting two code components.
                for _,verb in ipairs({"does","makes","earns","generates","produces"}) do
                    masked=masked:gsub(" and "..verb.." "," "..verb.." ")
                end
                for name in pairs(brainrotCatalog) do
                    if name:find(" and ",1,true) then masked=masked:gsub(name:gsub("([^%w])","%%%1"),"namedbrainrot") end
                end
                for _,row in ipairs(c.animals or {}) do
                    local name=Smart.fold(row.name)
                    if name:find(" and ",1,true) then masked=masked:gsub(name:gsub("([^%w])","%%%1"),"namedbrainrot") end
                end
                if masked:find(" and ",1,true) then return nil end
            end
            local reverse=self:reverseIncome(q,now)
            if reverse then return reverse end
            local totalKind = q:match("^how many (brainrots) are in the game$") or q:match("^how many (mutations) are in the game$")
                or q:match("^how many (traits) are in the game$")
            if totalKind then
                local rows = totalKind == "brainrots" and c.animals or c[totalKind]
                if rows then return result(#rows .. " entries in client data; release availability may differ", "client catalog count", true) end
            end
            local level = tonumber(q:match("rebirth (%d+)"))
            if level and c.rebirths and c.rebirths[level] then
                local row = c.rebirths[level]
                if q:find("cash",1,true) or q:find("cost",1,true) or q:find("money",1,true) then
                    if row.cash then return result(Smart.number(row.cash), "live rebirth cash") end
                elseif q:find("gear",1,true) or q:find("reward",1,true) then
                    if row.gears and #row.gears > 0 then
                        return result(table.concat(row.gears, ", "), "live rebirth gear", #row.gears ~= 1)
                    end
                elseif row.characters and #row.characters > 0 then
                    return result((row.cash and (Smart.number(row.cash).." cash; ") or "") .. table.concat(row.characters, ", "), "live rebirth requirements", true)
                end
            end
            -- Whole-name matching avoids turning a partial overlap into a guessed answer.
            local named = {}
            for _, row in ipairs(c.animals or {}) do
                if phrase(q, Smart.fold(row.name)) then named[#named+1] = row end
            end
            if #named == 1 then
                local row = named[1]
                if q:find("rarity",1,true) then return result(row.rarity, "live brainrot rarity") end
                if q:find("income",1,true) or q:find("make",1,true) or q:find("earn",1,true) or q:find("per second",1,true) then
                    if row.income then
                        local modifiers=q:match(" with (.+)$")
                        if modifiers then
                            local remaining=modifiers
                            local base,bonus,mutations,matched=1,0,0,0
                            for _,kind in ipairs({"mutations","traits"}) do
                                for _,modifier in ipairs(c[kind] or {}) do
                                    local name=Smart.fold(modifier.name)
                                    if phrase(modifiers,name) then
                                        if not modifier.multiplier then return result("A modifier value is unreadable", "income needs review", true) end
                                        if kind=="mutations" then mutations=mutations+1;base=modifier.multiplier else bonus=bonus+modifier.multiplier end
                                        remaining=remaining:gsub(name:gsub("([^%w])","%%%1")," ")
                                        matched=matched+1
                                    end
                                end
                            end
                            remaining=remaining:gsub("%f[%a]mutation%f[%A]",""):gsub("%f[%a]trait%f[%A]","")
                                :gsub("%f[%a]and%f[%A]",""):gsub("%f[%a]the%f[%A]",""):gsub("[%s,]+","")
                            if mutations>1 or matched==0 or remaining~="" then return result("Income modifiers could not be resolved uniquely", "income needs review", true) end
                            return result(Smart.number(row.income*(base+bonus)), "live income with additive traits")
                        end
                        -- Do not call an unspecified modified value the base income.
                        if q:find("mutation",1,true) or q:find("trait",1,true) then return result("Specify the mutation and traits using 'with'", "income needs review", true) end
                        return result(Smart.number(row.income), "live base income")
                    end
                end
                if q:find("cost",1,true) or q:find("price",1,true) then
                    if row.price then return result(Smart.number(row.price), "live price") end
                end
                if q:find("come from",1,true) or q:find("came from",1,true) or q:find("obtain",1,true) then
                    if row.source then return result(row.source, "live acquisition source", true) end
                end
                if allowLiteral and q == Smart.fold(row.name) then return result(row.name, "game name") end
            end
            if (q:find("highest",1,true) or q:find("lowest",1,true)) and q:find("multiplier",1,true) then
                local kind=q:find("trait",1,true) and "traits" or q:find("mutation",1,true) and "mutations"
                if kind and c[kind] then return unique(c[kind],"multiplier",not q:find("lowest",1,true)) end
            end
            for _, kind in ipairs({"mutations", "traits"}) do
                for _, row in ipairs(c[kind] or {}) do
                    if phrase(q, Smart.fold(row.name)) or (row.key and phrase(q, Smart.fold(row.key))) then
                        if q:find("multiplier",1,true) or q:find("bonus",1,true) then
                            if row.multiplier then
                                return result(Smart.number(row.multiplier) .. (kind == "traits" and "x additive bonus" or "x"),
                                    "live " .. kind .. " multiplier", kind == "traits")
                            end
                        end
                        if allowLiteral and (q == Smart.fold(row.name) or q == Smart.fold(row.name).." "..(kind == "traits" and "trait" or "mutation")
                            or (row.key and q == Smart.fold(row.key).." "..(kind == "traits" and "trait" or "mutation"))) then
                            return result(row.name, "game " .. kind)
                        end
                    end
                end
            end
            local ranking = q:find("cheapest",1,true) or q:find("lowest price",1,true) or q:find("most expensive",1,true)
                or q:find("highest price",1,true) or q:find("highest income",1,true) or q:find("highest earning",1,true)
                or q:find("best",1,true) or q:find("strongest",1,true)
            if ranking and (q:find("brainrot",1,true) or q:find("secret",1,true) or phrase(q,"og")) then
                -- Source/availability/exist-count rankings need data beyond base stats.
                for _, excluded in ipairs({"obtainable","no robux","rarest","limited","newest","merchant","machine","shop","block"}) do
                    if q:find(excluded,1,true) then return result("This ranking needs availability/source data", "live ranking", true) end
                end
                local rows, rarity = {}, nil
                for _, name in ipairs(rarityWords) do if phrase(q,name) then rarity=name; break end end
                for _, row in ipairs(c.animals or {}) do
                    if not rarity or Smart.fold(row.rarity) == rarity then rows[#rows+1] = row end
                end
                local field = (q:find("price",1,true) or q:find("expensive",1,true) or q:find("cheapest",1,true)) and "price" or "income"
                local descending = not (q:find("cheapest",1,true) or q:find("lowest",1,true))
                local ordinal = q:find("second",1,true) and 2 or q:find("third",1,true) and 3 or 1
                if q:find("fourth",1,true) or q:find("fifth",1,true) then return nil end
                return unique(rows, field, descending, ordinal)
            end
            if allowLiteral then
                if q:match("^%d+$") then return result(q, "literal number") end
                if q:match('^"[^"]+"$') or q:match("^'[^']+'$") then return result(q:sub(2,-2), "quoted word") end
                if brainrotCatalog[q] then return result(brainrotCatalog[q][1], "catalog name") end
                local mutation = q:gsub(" mutation$", "")
                if mutationMultipliers[mutation] then return result(mutation, "catalog mutation") end
                -- Only explicitly phrased history questions are trusted here; preview flags propagate.
                local answer, preview = lookupHistory(q)
                if not answer and not q:match("^what ") and not q:match("^who ") and not q:match("^when ") then
                    answer, preview = lookupHistory("what was " .. q)
                    if not answer then answer, preview=lookupHistory("what was the "..q) end
                end
                if answer then return result(answer, "SAB history", preview) end
            end
        end
        function self:solve(text, facts, now)
            local q = Smart.fold(text):gsub("^the code is%s+", ""):gsub("^code is%s+", "")
                :gsub("^riddle%s*:%s*", ""):gsub("^riddle%s+", ""):gsub("^question%s*:%s*", "")
            local mathText=q:gsub("^what is%s+", ""):gsub("^calculate%s+", ""):gsub("^solve%s+", "")
            for word,n in pairs({zero=0,one=1,two=2,three=3,four=4,five=5,six=6,seven=7,eight=8,nine=9,ten=10,eleven=11,twelve=12,twenty=20}) do
                mathText=mathText:gsub("%f[%a]"..word.."%f[%A]",tostring(n))
            end
            for _,pair in ipairs({{"plus","+"},{"minus","-"},{"times","*"},{"divided by","/"},{"multiplied by","*"}}) do
                mathText=mathText:gsub(pair[1],function() return pair[2] end)
            end
            if mathText:match("^[%d%.%s%+%-%*/%%%(%)%^]+$") then return nil end
            -- Resolve the entire question first: names can contain 'and' or numbers.
            local direct = self:atom(q, facts, now, false)
            if direct then return direct end
            if not q:find(" plus ",1,true) and not q:find("+",1,true) and not q:find(" and ",1,true) then return nil end
            -- A numeric sum remains arithmetic, never concatenation.
            if not q:find("%a") or q:match("^what is [%d%s%+%-*/%.]+$") then return nil end
            local parts = {}
            local function split(segment, depth)
                if depth > 8 then return false end
                local whole = self:atom(segment, facts, now, true)
                if whole and whole.code then parts[#parts+1] = whole; return true end
                local a,b = segment:find(" plus ",1,true)
                if not a then a,b = segment:find("+",1,true) end
                if not a then a,b = segment:find(" and ",1,true) end
                if a then
                    local left=split(segment:sub(1,a-1),depth+1)
                    local right=split(segment:sub(b+1),depth+1)
                    return left and right
                end
                if whole then parts[#parts+1] = whole; return true end
                parts[#parts+1] = {display="Unresolved: "..segment,preview=true}
                return false
            end
            local complete = split(q,0)
            if #parts < 2 and complete then return nil end
            local codes, labels, uncertain = {}, {}, not complete
            for _, part in ipairs(parts) do
                labels[#labels+1] = part.display
                if part.code then codes[#codes+1] = part.code else uncertain=true end
            end
            if uncertain then return result(table.concat(labels," + "), "compound clue needs review", true) end
            local value = table.concat(codes)
            if #value > 80 then return result("Combined answer exceeds 80 characters", "compound clue", true) end
            return {code=value,display=table.concat(labels," + "),reason="compound clue"}
        end
        return self
    end
end
Parser.Smart = Smart
function Smart.isRiddle(text)
    local q=Smart.fold(text):gsub("^the code is%s+", ""):gsub("^code is%s+", "")
    if q:match("^riddle") or q:match("^question%s*:") or q:match("^what ") or q:match("^which ")
        or q:match("^how ") or q:match("^who ") or q:match("^when ") or q:match("^where ") then return true end
    if q:find(" plus ",1,true) or q:find("+",1,true) then return true end
    if q:match("^my .+ and ") then return true end
    if Smart.identifiesBrainrot(q) and Smart.incomeClue(q) then return true end
    return q=="current mutation" or q=="mutation running now" or q=="current event" or q=="current luck"
end

-- Response correlation is separate from triggering the game's submit control.
local Feedback = {}
function Feedback.classify(text)
    local q = Smart.fold(text)
    for _, pattern in ipairs({"already redeemed", "already used", "already claimed"}) do
        if q:find(pattern,1,true) then return "used" end
    end
    for _, pattern in ipairs({"invalid code", "code is invalid", "code not found", "code does not exist", "code doesnt exist", "code expired", "code has expired", "code is expired"}) do
        if q:find(pattern,1,true) then return "invalid" end
    end
    for _, pattern in ipairs({"too many requests", "too many attempts", "try again later", "on cooldown", "please wait"}) do
        if q:find(pattern,1,true) then return "cooldown" end
    end
    for _, pattern in ipairs({"successfully redeemed", "redeemed successfully", "code redeemed successfully", "code redeemed", "successfully claimed"}) do
        if q:find(pattern,1,true) then
            if q:find("not ",1,true) or q:find("failed",1,true) then return nil end
            return "accepted"
        end
    end
end
function Feedback.new()
    local self = {items={}, serial=0}
    function self:begin(value, now, session)
        self.serial = self.serial+1
        local entry = {id=self.serial,code=value,time=now,session=session,state="sending"}
        self.items[#self.items+1] = entry
        while #self.items > 30 do table.remove(self.items,1) end
        return entry
    end
    function self:observe(text, now, session)
        local state = Feedback.classify(text)
        if not state then return nil end
        local pending, exact, sessions = {}, {}, {}
        local upper = Parser.clean(text):upper()
        for _, entry in ipairs(self.items) do
            -- Filled-only rows cannot be confirmed as submissions.
            if now-entry.time <= 4 and entry.state ~= "filled" and entry.state ~= "error" then
                sessions[entry.session] = true
                if entry.state == "sending" or entry.state == "submitted" then pending[#pending+1] = entry end
                if upper:find("%f[%w]" .. entry.code:gsub("([^%w])","%%%1") .. "%f[%W]") then exact[#exact+1] = entry end
            end
        end
        local chosen = #exact == 1 and exact[1] or nil
        if not chosen then
            -- Generic responses cannot be assigned across overlapping sessions.
            for id in pairs(sessions) do if id ~= session then return nil end end
            if #pending == 1 then chosen=pending[1] end
        end
        if chosen and chosen.session ~= session then return nil end
        if not chosen and #pending == 0 then return nil end
        if not chosen and state ~= "accepted" and state ~= "used" and state ~= "cooldown" then return nil end
        if chosen then chosen.state=state end
        return {state=state,code=chosen and chosen.code,session=session,ambiguous=chosen==nil}
    end
    return self
end
Parser.Feedback = Feedback

function Parser.solve(text, facts, historyAnswer, historyPreviewOnly, smart, now, testReplay)
    local clean=Parser.clean(text)
    local _,marker=clean:lower():find("^the%s+code%s+is%s+")
    if not marker then _,marker=clean:lower():find("^code%s+is%s+") end
    if marker then text=trim(clean:sub(marker+1):gsub("^[%s:=]+", "")) end
    if smart then
        local solved=smart:solve(text,facts,now or 0)
        if testReplay and (not solved or not solved.code) then
            local sample=Parser.Smart.confirmedExample(text)
            if sample then return sample.code,sample.reason,sample.display end
        end
        if solved then
            if solved.code then return solved.code,solved.reason,solved.display end
            if solved.preview then return nil,solved.reason,solved.display end
        end
    end
    if not historyAnswer then historyAnswer,historyPreviewOnly=lookupHistory(text) end
    return solveBase(text,facts,historyAnswer,historyPreviewOnly)
end

local countWords = {
    a=1, one=1, two=2, three=3, four=4, five=5, six=6, seven=7, eight=8, nine=9, ten=10,
    eleven=11, twelve=12, thirteen=13, fourteen=14, fifteen=15, sixteen=16,
    seventeen=17, eighteen=18, nineteen=19, twenty=20,
}
local fragmentStops = {
    THE=true, CODE=true, IS=true, GUYS=true, WAIT=true, HELLO=true, SOON=true,
    READY=true, RDY=true, YES=true, NO=true, LOL=true, THANKS=true, UPDATE=true,
    EVENT=true, SPAWNED=true, NEXT=true, PLEASE=true,
}
local fillerPhrases = {
    ["GET RDY"]=true, ["GET READY"]=true, ["HOLD ON"]=true,
    ["HERE WE GO"]=true, ["NOT YET"]=true, ["JUST KIDDING"]=true,
    ["HOLD UP"]=true, ["WAIT A SECOND"]=true, ["WAIT FOR IT"]=true,
    ["ARE YOU READY"]=true, ["GET SET"]=true, ["ONE SECOND"]=true,
}

local function announcedWordCount(payload)
    local number = payload:match("^([%w]+)[%s%-]+words?%f[%W]")
        or payload:match("^([%w]+)[%s%-]+parts?%f[%W]")
    if not number then return nil end
    return (number:match("^%d+$") and tonumber(number)) or countWords[number] or false
end

function Parser.new()
    local self = {pieces={}, untilTime=0, riddle=nil, facts={}, smart=Smart.new()}
    function self:reset()
        self.pieces = {}
        self.untilTime = 0
        self.riddle = nil
        self.announcedSize = nil
    end
    function self:feed(input, now)
        local text = Parser.clean(input)
        if text == "" then return {kind="ignored"} end
        local l = text:lower()
        self.smart:remember(text,now)
        if l:match("^my .+ is ") or l:match("^the number is %d+") or l:match("^i am %d+ years old") then
            return {kind="remembered"}
        end
        if self.untilTime > 0 and now >= self.untilTime then self:reset() end
        if l:find("code expired",1,true) or l:find("no more codes",1,true)
            or l:find("code is expired",1,true) or l:find("code is fake",1,true)
            or l:find("code is not valid",1,true) or l:find("code is not real",1,true)
            or (not self.announcedSize and l:find("code is not",1,true)) then
            self:reset()
            return {kind="reset", reason="code announcement cancelled"}
        end

        local markerEnd
        for _, pattern in ipairs({"%f[%a]the%s+code%s+is%f[%A]", "%f[%a]code%s+is%f[%A]", "%f[%a]code%s*:", "%f[%a]use%s+code%f[%A]", "%f[%a]redeem%s+code%f[%A]"}) do
            local _, finish = l:find(pattern)
            if finish and (not markerEnd or finish < markerEnd) then markerEnd = finish end
        end
        local countEnd = markerEnd
        if not countEnd then
            local _, finish = l:find("%f[%a]code%s+will%s+be%f[%A]")
            if not finish then _, finish = l:find("%f[%a]code%s+has%f[%A]") end
            countEnd = finish
        end

        local countPayload
        if countEnd then
            countPayload = trim(l:sub(countEnd + 1):gsub("^[%s%.:=%-]+", ""))
        elseif self.untilTime > now and not self.riddle and #self.pieces == 0 then
            countPayload = l
        end
        local announced = countPayload and announcedWordCount(countPayload)
        if announced ~= nil then
            if not announced or announced < 1 or announced > 80 then return {kind="ignored"} end
            self:reset()
            self.announcedSize = announced
            self.untilTime = now + 45
            return {kind="armed", total=announced}
        end

        local riddleHint=Smart.isRiddle(text)
        if markerEnd or (self.announcedSize and riddleHint) then self:reset() end
        local counted = self.announcedSize ~= nil
        if self.riddle and (l:match("^riddle") or l:match("^question%s*:") or l:match("^what ") or l:match("^who ") or l:match("^which ")) then
            self.riddle=nil
        end
        local historyAnswer, historyPreviewOnly
        if not counted then historyAnswer, historyPreviewOnly = lookupHistory(text) end
        local hasRiddle = not counted and (riddleHint or historyAnswer or boundary(l,"riddle") or boundary(l,"solve")
            or l:find("what am i",1,true) or l:find("what is",1,true)
            or l:find("what has",1,true) or l:find("what gets",1,true)
            or (text:find("?",1,true) and (boundary(l,"what") or boundary(l,"how") or boundary(l,"which")
                or l:match("^when%s") or l:match("^who%s")))
            or boundary(l,"reverse") or l:find("first letter",1,true)
            or boundary(l,"backwards") or boundary(l,"calculate")
            or (self.riddle and self.untilTime > now))

        if hasRiddle then
            local combined = self.riddle and (self.riddle .. " " .. text) or text
            if #combined > 1200 then combined = text end
            local prompt = combined
            if historyAnswer then
                prompt = text
            else
                historyAnswer, historyPreviewOnly = lookupHistory(combined)
            end
            local answer, reason, display = Parser.solve(prompt, self.facts, historyAnswer, historyPreviewOnly, self.smart, now)
            if answer then
                self:reset()
                return {kind="code", code=answer, reason=reason, display=display}
            end
            if display then
                self:reset()
                return {kind="historyPreview", display=display}
            end
            self.riddle = combined
            self.untilTime = now + 45
            self.pieces = {}
            return {kind="unsolved", text=combined}
        end

        local payload = text
        if markerEnd then
            payload = trim(text:sub(markerEnd + 1)):gsub("^[%s%.:=%-]+", "")
            if not counted then
                self.untilTime = now + 45
                if payload == "" then return {kind="armed"} end
            end
        elseif self.untilTime <= now then
            return {kind="ignored"}
        end

        local tokens = {}
        payload = trim(payload:gsub("[%.!]+$", ""))
        local quoted = payload:match('^(["\'`])([%w_%-%s]+)%1$')
        if quoted then payload = trim(payload:sub(2, -2)) end
        if payload:find("[^%w_%-%s]") or fillerPhrases[(payload:upper():gsub("%s+", " "))] then
            return {kind="ignored"}
        end
        for token in payload:gmatch("%S+") do
            local upper = token:upper()
            if #token > 40 or fragmentStops[upper] then return {kind="ignored"} end
            if not quoted and (counted or not markerEnd) and token ~= upper then return {kind="ignored"} end
            tokens[#tokens + 1] = upper
        end

        if #tokens == 0 then return {kind="ignored"} end
        local joined = table.concat(self.pieces)
        if #joined + #table.concat(tokens) > 80 then return {kind="ignored"} end
        local candidates = {}
        for _, token in ipairs(tokens) do
            self.pieces[#self.pieces + 1] = token
            joined = joined .. token
            candidates[#candidates + 1] = joined
        end
        self.untilTime = now + 45
        return {
            kind="code", code=joined, candidates=candidates, count=#self.pieces,
            total=self.announcedSize, reason="growing prefix", newSession=markerEnd ~= nil and not counted,
        }
    end
    return self
end

return Parser

end)()
	local parser = Parser.new()
	parser.facts = type(env.SpookyCodeFacts) == "table" and env.SpookyCodeFacts or {}
    -- Optional reads run outside the UI and announcement paths. No remote invocation,
    -- callback hooks, upvalue changes, or dependency waits are used.
    local live = {modules={},pending={},context={},revision=0,lastScan=-math.huge,releaseChecks={}}
    do
        local function visible(object)
            local p=object
            while p and p~=playerGui do
                if p:IsA("GuiObject") and not p.Visible then return false end
                if p:IsA("ScreenGui") and not p.Enabled then return false end
                p=p.Parent
            end
            return object and object.Parent~=nil
        end
        local function requestModule(parent, name)
            local module=parent and parent:FindFirstChild(name)
            if not module or not module:IsA("ModuleScript") then return end
            local pending=live.pending[module]
            if pending==true or (type(pending)=="number" and os.clock()<pending) then return end
            live.pending[module]=true
            task.spawn(function()
                local ok,value=pcall(require,module)
                if runtime.alive and ok and type(value)=="table" then
                    live.modules[name]=value
                    live.revision=live.revision+1
                    if live.rebuildData then
                        pcall(function() live:rebuildData();live:refreshFast() end)
                    end
                else
                    live.pending[module]=os.clock()+30
                end
            end)
        end
        local function calendar(stamp)
            local year=os.date("!*t",stamp).year
            local function sunday(month,offset)
                local first=os.time({year=year,month=month,day=1,hour=0})
                return 1+(8-os.date("!*t",first).wday)%7+offset
            end
            local dstStart=os.time({year=year,month=3,day=sunday(3,7),hour=7})
            local dstEnd=os.time({year=year,month=11,day=sunday(11,0),hour=6})
            local date=os.date("!*t",stamp-((stamp>=dstStart and stamp<dstEnd) and 4 or 5)*3600)
            local months={"January","February","March","April","May","June","July","August","September","October","November","December"}
            return {month=months[date.month],year=tostring(date.year),day=date.day,date=string.format("%04d-%02d-%02d",date.year,date.month,date.day)}
        end
        local function updateId(value)
            if type(value)~="string" and type(value)~="number" then return nil end
            return tostring(value):lower():gsub("^update[%s%-%_]","")
        end
        local function timestamp(value)
            local n=tonumber(value)
            if n and n>1e12 then n=n/1000 end
            return n and n>0 and n or nil
        end
        function live:checkEnabled(fn)
            local info=self.releaseChecks[fn]
            if info and (info.pending or os.clock()-(info.checkedAt or -math.huge)<10) then return info end
            info=info or {}
            self.releaseChecks[fn]=info
            info.pending=true
            task.spawn(function()
                local constants=(debug and debug.getconstants) or getconstants
                if not info.inspected and type(constants)=="function" then
                    info.inspected=true
                    local ok,values=pcall(constants,fn)
                    if ok and type(values)=="table" then
                        local stamps={}
                        for _,value in pairs(values) do
                            if type(value)=="string" and value:match("^Update%-") then stamps[updateId(value)]=true end
                        end
                        local single
                        for id in pairs(stamps) do if single then single=nil;break end;single=id end
                        info.updateId=single
                    end
                end
                local ok,enabled=pcall(fn)
                if not runtime.alive then return end
                info.enabled=ok and type(enabled)=="boolean" and enabled or nil
                -- Preserve false: the boolean shortcut above would erase it.
                if ok and enabled==false then info.enabled=false end
                info.checkedAt=os.clock();info.pending=false
                live.releaseDirty=true
            end)
            return info
        end
        local function shortText(value)
            return type(value)=="string" and Parser.clean(value):gsub("<[^>]->","") or nil
        end
        function live:scanModules()
            local datas=ReplicatedStorage:FindFirstChild("Datas")
            for _,name in ipairs({"Animals","Mutations","Traits","Rebirth","Rarities"}) do requestModule(datas,name) end
            requestModule(ReplicatedStorage:FindFirstChild("Shared"),"Updates")
            -- EventController is only read when Roblox reports it already loaded.
            -- Requiring an unstarted controller may wait indefinitely on initialization.
            if type(getloadedmodules)=="function" then
                local ok,loaded=pcall(getloadedmodules)
                if ok and type(loaded)=="table" then
                    for _,module in ipairs(loaded) do
                        if module.Name=="EventController" and module:IsDescendantOf(ReplicatedStorage) then requestModule(module.Parent,module.Name) end
                    end
                end
            end
        end
        function live:rebuildData()
            local c={animals=nil,mutations=nil,traits=nil,rebirths=nil}
            local updates=self.modules.Updates
            local updateTimes={}
            if updates and type(updates.List)=="table" then
                for key,row in pairs(updates.List) do
                    local id=updateId(key)
                    local stamp=type(row)=="table" and timestamp(row.UnixTimeStamp)
                    if id and stamp then
                        updateTimes[id]=stamp
                        if stamp<=os.time() and (not c.currentUpdate or stamp>c.currentUpdate.time) then
                            c.currentUpdate={id=id,time=stamp}
                        end
                    end
                end
            end
            local animals=self.modules.Animals
            if animals then
                c.animals={}
                for key,row in pairs(animals) do
                    if type(row)=="table" and type(row.DisplayName or key)=="string" then
                        local source=type(row.ObtainedFrom)=="table" and row.ObtainedFrom.Source or nil
                        local check=type(row.IsEnabled)=="function" and self:checkEnabled(row.IsEnabled) or nil
                        local enabled=type(row.IsEnabled)=="boolean" and row.IsEnabled or nil
                        if row.IsEnabled==false then enabled=false elseif check then enabled=check.enabled end
                        local id=updateId(row.UpdateId or row.AddedInUpdate or row.Update) or (check and check.updateId)
                        local released=timestamp(row.ReleaseTimestamp or row.ReleasedAt)
                        local releaseDay=type(row.ReleaseDate)=="string" and row.ReleaseDate:match("^(%d%d%d%d%-%d%d%-%d%d)$") or nil
                        local confirmed=false
                        if released and released<=os.time() and enabled~=false then
                            releaseDay=calendar(released).date;confirmed=true
                        elseif id and updateTimes[id] and updateTimes[id]<=os.time() and enabled==true then
                            releaseDay=calendar(updateTimes[id]).date;confirmed=true
                        elseif releaseDay and enabled==true then confirmed=true end
                        c.animals[#c.animals+1]={name=shortText(row.DisplayName) or key,key=tostring(key),
                            rarity=shortText(row.Rarity),income=tonumber(row.Generation),price=tonumber(row.Price),
                            source=shortText(source),updateId=id,enabled=enabled,releaseDay=releaseDay,releaseConfirmed=confirmed}
                    end
                end
                table.sort(c.animals,function(a,b) return a.name<b.name end)
            end
            for _,kind in ipairs({"Mutations","Traits"}) do
                if self.modules[kind] then
                    local rows={}
                    for key,row in pairs(self.modules[kind]) do
                        if type(row)=="table" and type(key)=="string" then
                            local display=shortText(row.DisplayText or row.Display or row.Name) or key
                            rows[#rows+1]={name=display,key=key,multiplier=kind=="Mutations" and
                                (tonumber(row.Modifier) and (1+tonumber(row.Modifier))) or tonumber(row.MultiplierModifier)}
                        end
                    end
                    table.sort(rows,function(a,b) return a.name<b.name end)
                    c[kind:lower()]=rows
                end
            end
            if self.modules.Rebirth then
                c.rebirths={}
                for key,row in pairs(self.modules.Rebirth) do
                    local level=type(row)=="table" and tonumber(row.RebirthNumber or key)
                    if level then
                        local req=type(row.Requirements)=="table" and row.Requirements or {}
                        local rewards=type(row.Rewards)=="table" and row.Rewards or {}
                        local chars,gears={},{}
                        for _,value in pairs(type(req.RequiredCharacters)=="table" and req.RequiredCharacters or {}) do
                            if type(value)=="string" then chars[#chars+1]=value end
                        end
                        for _,value in pairs(type(rewards.Gears)=="table" and rewards.Gears or {}) do
                            if type(value)=="string" then gears[#gears+1]=value end
                        end
                        c.rebirths[level]={cash=tonumber(req.Cash),characters=chars,gears=gears}
                    end
                end
            end
            self.data=c
        end
        function live:refreshFast()
            if self.releaseDirty then self.releaseDirty=false;self:rebuildData() end
            local c={}
            for key,value in pairs(self.data or {}) do c[key]=value end
            c.calendar=calendar(os.time())
            c.events,c.activeMutations,c.activeTraits={},{},{}
            local seen={}
            local function event(name)
                name=shortText(name)
                if not name or name=="" or seen[name] then return end
                seen[name]=true
                c.events[#c.events+1]=name
                local eventKey=Parser.Smart.fold(name):gsub(" event$","")
                for _,kind in ipairs({"mutations","traits"}) do
                    for _,row in ipairs(c[kind] or {}) do
                        local key=Parser.Smart.fold(row.key or row.name)
                        if eventKey==key or eventKey==Parser.Smart.fold(row.name) then
                            local list=kind=="mutations" and c.activeMutations or c.activeTraits
                            list[#list+1]=row.name
                        end
                    end
                end
            end
            local panel=playerGui:FindFirstChild("ActiveEvents")
            panel=panel and (panel:FindFirstChild("ActiveEvents") or panel)
            if panel and visible(panel) then
                for _,child in ipairs(panel:GetChildren()) do
                    if child:IsA("GuiObject") and visible(child) and child.Name~="Luck" then event(child.Name) end
                end
            end
            for key,value in pairs(ReplicatedStorage:GetAttributes()) do
                if value==true then
                    local luck=key:match("^(%d+)xServerLuckEvent$")
                    if luck then c.serverLuck=math.max(c.serverLuck or 0,tonumber(luck)) end
                    -- Only resolve exact mutation/trait keys; unrelated boolean events
                    -- cannot prove a weather is active.
                    for _,kind in ipairs({"mutations","traits"}) do
                        for _,row in ipairs(c[kind] or {}) do
                            if key==(row.key or row.name).."Event" then event(row.key or row.name) end
                        end
                    end
                end
            end
            local fuse=ReplicatedStorage:GetAttribute("FuseMachineLuck")
            local rng=ReplicatedStorage:GetAttribute("RNGMachineLuck")
            c.fuseLuck=type(fuse)=="number" and fuse>1 and fuse or nil
            c.rngLuck=type(rng)=="number" and rng>1 and rng or nil
            c.observedAt=os.clock()
            self.context=c
            parser.smart:setContext(c)
            return c
        end
        function live:refresh()
            self:scanModules()
            self:rebuildData()
            self:refreshFast()
            local controller=self.modules.EventController
            if controller and type(controller.GetActiveEvents)=="function" and not self.readingEvents then
                self.readingEvents=true
                task.spawn(function()
                    local ok,events=pcall(controller.GetActiveEvents,controller)
                    self.readingEvents=false
                    if runtime.alive and ok and type(events)=="table" then
                        -- The UI/attribute path stays authoritative; this is diagnostic
                        -- context only until an event's active-state schema is known.
                        self.controllerEvents=events
                    end
                end)
            end
        end
        task.spawn(function()
            while runtime.alive do
                local ok,err=pcall(function() live:refresh() end)
                if not ok then live.lastError=tostring(err) end
                task.wait(10)
            end
        end)
    end


	local T = {
		BG = Color3.fromRGB(15, 15, 19),
		Card = Color3.fromRGB(24, 24, 30),
		Field = Color3.fromRGB(19, 19, 24),
		Border = Color3.fromRGB(63, 35, 40),
		Accent = Color3.fromRGB(229, 57, 62),
		Focus = Color3.fromRGB(242, 104, 108),
		Green = Color3.fromRGB(137, 226, 184),
		Red = Color3.fromRGB(255, 132, 146),
		White = Color3.fromRGB(240, 240, 244),
		Dim = Color3.fromRGB(147, 147, 160),
		Yellow = Color3.fromRGB(255, 190, 100),
	}

	local Smooth = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local Bounce = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function Tw(o, i, p)
        if not runtime.alive or not o or not o.Parent then return end
		TweenService:Create(o, i or Smooth, p):Play()
	end

	local function Corner(p, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r or 8)
		c.Parent = p
	end

	local function Stroke(p, col, th)
		local s = Instance.new("UIStroke")
		s.Color = col or T.Border
		s.Thickness = th or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = p
		return s
	end

	pcall(function()
		if game.CoreGui:FindFirstChild("SpookyAutoRedeemer") then
			game.CoreGui.SpookyAutoRedeemer:Destroy()
		end
	end)
	pcall(function()
		if playerGui:FindFirstChild("SpookyAutoRedeemer") then
			playerGui.SpookyAutoRedeemer:Destroy()
		end
	end)

	local GUI = Instance.new("ScreenGui")
	GUI.Name = "SpookyAutoRedeemer"
	GUI.ResetOnSpawn = false
	GUI.IgnoreGuiInset = true
	GUI.DisplayOrder = 999
	if not pcall(function()
		GUI.Parent = game.CoreGui
	end) then
		GUI.Parent = playerGui
	end

    runtime.gui = GUI
    connect(GUI.Destroying, function() runtime.Stop() end)

	local WIN_W = 360
	local isMinimized = false

	local Win = Instance.new("Frame")
	Win.Name = "Win"
	Win.Size = UDim2.new(0, WIN_W, 0, 10)
	Win.AutomaticSize = Enum.AutomaticSize.Y
	Win.AnchorPoint = Vector2.new(1, 0)
	Win.Position = UDim2.new(1, -14, 0, 52)
	Win.BackgroundColor3 = T.BG
	Win.BorderSizePixel = 0
	Win.ZIndex = 100
	Win.ClipsDescendants = true
	Win.Parent = GUI
	Corner(Win, 14)

	local panelScale = Instance.new("UIScale")
	panelScale.Parent = Win
	local viewportConnection,viewportSizeConnection
	local function bindViewport()
		if viewportConnection then viewportConnection:Disconnect() end
		local camera = workspace.CurrentCamera
		if not camera then return end
		local function fitPanel()
            local size=camera.ViewportSize
            local naturalHeight=math.max(440,Win.AbsoluteSize.Y/math.max(panelScale.Scale,0.01))
            panelScale.Scale=math.max(0.15,math.min(1,(size.X-28)/WIN_W,(size.Y-68)/naturalHeight))
        end
        if viewportSizeConnection then viewportSizeConnection:Disconnect() end
        viewportSizeConnection=connect(Win:GetPropertyChangedSignal("AbsoluteSize"),fitPanel)
		fitPanel()
		viewportConnection = connect(camera:GetPropertyChangedSignal("ViewportSize"), fitPanel)
	end
	connect(workspace:GetPropertyChangedSignal("CurrentCamera"), bindViewport)
	bindViewport()

	Stroke(Win, T.Border, 1)

	local WinList = Instance.new("UIListLayout")
	WinList.FillDirection = Enum.FillDirection.Vertical
	WinList.SortOrder = Enum.SortOrder.LayoutOrder
	WinList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	WinList.Parent = Win

	-- CASHERS logo asset: embedded PNG, no external image download.
	local cashersLogoCache
	local function getCashersLogo()
	    if cashersLogoCache ~= nil then return cashersLogoCache or nil end
	    cashersLogoCache = false
	    local assetFunction = getcustomasset or getsynasset
	    if type(writefile) ~= "function" or type(assetFunction) ~= "function" then return nil end
	    local ok, asset = pcall(function()
	        local encoded = "iVBORw0KGgoAAAANSUhEUgAAAHwAAACACAYAAADJTg3cAAAmXklEQVR42u19eXhdVbn+u9be+8w5c07moWmGNumc0pYWSIuIBUEUPKeIyhWRSQUckMErnAREQa8gXuAy6I+Ze8mBioCKAm0KhbbQuSSdkraZT4aTM097WOv3R1KsAyoINknP9zz9Zz95evZe736/7/2+9X1rAzmbNOZHheFBNEof52/Q3DIff+MA+R2gX+GMzxjANi23ItMbbAoAe0499czNc+eWHn0BcgyfjmD7/ZQA7PAZZyyzllcWLduzp2/iGv+4flPMLfvxc+MA8O6ZXqfOrf+GarVcw8EJWgjPrc50BNzrFQDg8Nmr7w1+45rLj72Ws2kK9lsnneTr+/LFGznnhPv9FB9j7M7F8OOVevn9lD73nPZESUlp1epPPWQqK72TEMLR0UHwMcbunB0fI7y1VQBAe1tufTNx//0bAYBzniPetHTl42Cj6wc/uJO/+RYPffXKOSAEE+48Z9MubhOCHeefv0rdtYunH3/yaQBo5Twn1KZjvs05J3+A2TP66GNH1Dc3pTurquYcI9ZyNq3i9oQq33fRRc/y/Qd5+O577puI3Tl2Tzdb39QkAsCOU5ZfL99zD08/91xob11dZY7d09GVAwIAHKmvPz2y5sIsf/U13nfj9XcdK+D+3ZYrrX58YFMCaG8WFlaQbPaRvMaTdKk9746G1rXdxTknzSRXQp1OYBMOUO73i/2Sbl3s7HM5f/RRHrryyh8eT3bn7GN25Xsk/X/Fyiq4/NDDSurHtw9tdLmKOefEfxwrnDnR8DGATQBtc3nJ50W9+F31rLOyUn6+mDzc+8ApodAAAgHaArDjdX+5GP5Rx21CtJc5rzYKwv3upSeptpNXiKmx8GDv25vvnQyxO8fwj8j8AG0G8DjnZmtZ0dNuLuTbV6xSaVmhMBAO3bdo584R4PiyOwf4R2jNAGkBWL7dflfWoD9JnDEjS5c06qPJzMimzp0Pc85Jc3N7TplPi+LKRGj8g6i/4v9qZvDN8+fIyTvuyPLN7/D+1sC4Mp8kVbUcw/9FawWEVYAaNOYtC7osP3cUz9DUkgro3C4pNToST/V0P8g5J2huzrF7OsRtABgxGosfMpsOP3vyMr5x9VlK7733ynzXTh787W/vn0zszjH8XyyuNIwXWITdjD8UKS2tNBQUKpaKMlo8e5YYS2Uz7wZ77uXApGJ3Li37kNYGCD5AfUHQ337Ebv+0bd5sOXikTzx9yXKNZhQpplOeP+PSqzo455QQwnIMn+IibRWgdkuGNUG75fuhwnwlHBwR5ixbjhjR6GAsirTR8AjnnCAQIJPp3nMM/+CuXCCA2ilJje8YdA+GSwoYBIGGRsKktG4We+NQhyjo6I7PXbimDQCIz8dygE9hkUYA7W2DoWzAZAkcNpttSSqqPZEx6jv3c9iwv53POeOT4Cbzk4QQeUKsTapZsZxL/wAirRmcc8AcFXT/120yzeiVqLI7FKLW4mLkVZbygWRCHAwGw/JoIgAAzZMwFcsx/J8EOwBQH4i2tajo0V7Gl28Ck0EkSa/X8dqaWuw6fJit+eKXhMHQ2MYlvs/1TjaxlmP4BwC7ralJ8AFa72mn/yKc7/l8Z75DpmajmJZEXllZiZScwawlS4ghPx+ZTOoZAKStuXlSrm2O4f8o/WpqElZt2KCOrj7bH9HUq4N5Jjk4khLTnKF+dg1qly5FUlW5w24Xjxw4GHrhv+5+BQBva2lhk/F5cgz/e+lXU5O4asMGdV/jwhs279/X/Foirvyxt0+Iayo8hYWwlZRi3ooVcLicbLB/AHv372372Z49w9zvP+67YjnAP6grnwA7fvKKa/cPh+/YbbOowWxKcOW7SWV5KQrLSqB3O3H48GHojCbMXdSIBcuXvwTO0bZy5aRd15xL/2sjvKlJIBs2qCOnr/zGjkM9P+/MM6r2fDeJU4o5ThvCgg7LzjkHVJLQdfgwambNEnUOe3bXK69tBIC2tjY2aR8uh++fCzR4vZQEAtroGWd+K97bf9crPKvJhR4yqDEyd8F8ZEURisGIwuqZyC8uBieUiaIkGk3md1pPOXVZM+ecEDLx3+Vc+pQAO7p69XVSSr57t8XEVI+HZAWBVNfVQl9cjLQowlFagjy7HWOhEPRmM9Pp9QiPjm6ZiNsUk3jsNwf4UbD9fkICAa33nHNuTUeiP30dqnrYKMKS7yYlCxciabOBmMx81py5rKZ2FpwFBSCUIpvJ0hmzZiEZi78JAIFAYFI/6wkfw/0AxbgbZrEf3PRTYyx53RZJVPbFInQ0liE6vQ75lMLl9nBHcTEpraoShoeHmZgBPMUl3OFyC+HQWDKD7FYAaG+f3G1MJ3QM534/JS0tDJyTscsuewCjocuHCz3KAa7S3Qe7SEV1FXRuJwSrXVu4fIUUSyVxcHD4BYNIT7eYTOaKulnqyMCARAnZ/b0f/qjx9dc3qHyS97WcsAxv9XoF0tKifb2+3nLTFVc+lR0d+8xWJSObBIiDiSw0Wx7y58zhNpebWT0FUkhWht96e/ulajotfvq8c85VOdeioyMoKCyEqqqdGzZsUCdrOfWEB3y93y+uamlRn7j66tJVlrz/ZdHwKe1FLjkly2J3IomoLGPOilM0Wa8Xi2trhR37Dr50W0vLt7Z1dna98NhjjzicLtIfHGQGnQ6CICDLtH1TxWOecICvX79eXLVqldp61VWNtTrpGVlVZg6UFcvEaBSNqRRYdzeXFZk1LFokpYHEHze9fdNl11xzLyEEXq/X4vC4V4yMjkBOpykxmlh2cBAyY4MT+XcO8Ekjzvx+2tzcDEKI+psbv/eFudV1/5Ps7bbtF4hidjpFwjnCsaiWV1EuOvUGoScUXvd04NnvPdraup1zLjY3NzMbY/PNRtNM0WBkJsZoKDTGCwoKYBN1Y1NlHU6ItKzV6xVabr2VEULYqz/98a2zZ896OpKO25KV5YquuEjQOxy8q6dHowajpHCkg5HYDWd6fZ94tLV1u9/vF9va2tDS0sLqqipPT0TDdP0f/6ByQhEZCyERiyI42CdjnOI5wCdDvPYFAtp3PR7P+nv/+7myWbNvzjpcqlRdo0rufEFnsWlMEMmyT62W+oeHNz7yyBOnXHfb7T/hnBO/309bWlrUlStXahycvL317U9u2bIZHrebDPT1QuMcsdAodr/RRgGgbQqsx7R16ce68Ee+9h/LKpaf+tjsJSfV9nV3y4RS0ZBn5bpsVrV7PLqOffvkvkz2J49399/W0dkp+/1+kRCiTlTMKCGEffeiiyqKnJXzCSGIxONUYRyqLHNFJ6GgvMIGACsBtOQYflzAFltaWhghhP365hu/VbXqE+tdNdW1Y4mE7CguEe2FRZrVahVcpaW6rsHBt57+9Quner/45Zs7AgH5KKvfCwetrQQAnC7XUpPBZB0ZHVXj8SiRsxnodCIx6PTQNK0GAFY2NPAcw48Tq/1NTZWLzv7UXZXz5n4uGItzUKqCUso4Z8UlJVJPf39k4+uv33nZN6/5GQBlIlXTWt6nccHksn/Sle8EYzIDFWkmnQI4J1Sng06UlmK8Fs8m+xpNl0obaW1tpT6fTwOAX3z7mxdXz513R0FlZZGqaQoYJwVlFdzldkqRSAzte/e98NDDD9+w9qWX9lFKcfPNN9P3AZoQQvjSpUuN13zl4p2CQGtTyaSqE0XKOIeo0/Hi0lKaHBlNaz19C865+ebO5uZm0jJJu12mg0snreNnoHGfz6ddu2p53cO33Bgoqql5zFFaWmS0WGWLzY7CsnIxz2aTdrfv6/rf59b6Vp933nlrX3ppH+dcYIy9L0B+v59wzvHJhQvnzGqor85kssxisdBUJo1gcAgiQNKJuEolyUQt5v8ghPCGhoZJTSI6lYEmlHJfIKDlA5YHbr7pB4vP+eym4rrZny+ZWaMUlZRn9QYDteRZpZGxcOLZX6+9c8WqVcuuv+mmAOec+v1+SgjR8He2MldOrE/1zJmnumw2SihR3QWFKCkpQ119PSBKcOd7KJVEbi8uuuIP/p96vF4v80/i89emlEvnAAl4vXTNs89qfHyXQrztS1/4cuXCBTfqDMbaWDyOmrra7Oz5C4U8u13csWMHuroOPbn21623Pf/71w4QQvDMM88IR13/P/y9idr4+hdffGFR48JzO/d1KLFoTCCihI49uzF77jwkE3GEh4La4saTJC0Se2DOuedexfl6kZBVak60fVgxBtAGr5eQ557TEAhoAOjtX/B9pmz+vOsFvf5kU14ekulUduHSJaS6plY/OhbG9l27X3njjY0/+9Fdd/1hAjyBEML+WbAn4jfzNtVbzHrdwmQ0Co2DUklEPBqFO9+NoqIixMJ6COBC3/CwWurxXPnG449uImTV41u3bpUWL16s5AD/AN6H+/0k0NFBfM8+qyEQQCtgcZx2su9gTfWV5SctPclRWoaBgX7ZU1jIZ82Zpzfk5WH7zp0d69evu+2WH/74/46ydEK5f6CRn6Mi0HfRN+bZnY6ikZEhZnM4iCBJsDvcMOgkJONx6I0mVM+ux2BvL+nu7WXz5s5/4M0nnuhfvHjxa3z9ehErV2pkEh3CN+kA534/RUMDIRdeqJGWFg4AdwOVntqqi4UFjRdlGurqqmbMgMFml0cGB/iMmlp9cVk5+oaHOl5/du09V1933ZMAUpxzEvD56AcF+qh5vV4AgMXpWSnp9UIylZKhaiI0RiByaJrKqSAgmUjAarXC5XSRaCjEuw53GWobF73wykMPXUVWrXocGD+Ij/zznmX6Az4xVkub29s5+ZNipv3nn3Vyp4qLHXPmnx+1Wd1JhwOxZCJjEiTitDv0eXlW9A4OHlz3+psPXO/3PwggeTROTwD9rywyBwCrzXpqIh7jGUUl7kIHdAY97+/pRkFJOawOJzKpJAb6+6BmMvAUFZNkIsE6D+43Fs+c8VjH7363vH/37huIzxc9+ozw+Rg5jj1vxw1wv99PGzo6SHt9PZ9oGtAAgF911eykw3G+oW7WeT3hkZN0qQyGLWbo3A45T2+QHC67ISWr6Onr7Rgci9x92dXXPgMgTgjBLbfcIra0tGi+f5FNEwqe/ez73y8pLiw4WVM1Iok6nlUUjWsMLk8BpaJAJL0OajYDaBpACGRNQSIZJ0f6+xhTVV7s9lxhzDOt2nnffbcTQp587xlbWwWMv9wc/2bw/52AE6/XS+vr60nLX1S0Qt/5TpmzaWlTtO2tNaGZNav0RUXmI0oWwzYrM1WUqeH+fkFkXBQlKTYUGt2wc8euh2/5xX0vTSgrMMYkALytrQ0NDQ3U6/Wyj6JVOJvNFo9Fo2Gz2WKyOp26dCIOVdNQWVOLeCTClKysccZ5UWk5TaVTpPPAfqKkU+AchHNOOnt7FCWZqG2omf3Y4aeeulyyWX5RMm/hi6S8PP2eVvB6hfxAgKwc73jlHzf7P7a0jAOk2e8naGujDR4P942r6/fsyG23zWjfvv0TJqaeO+e8z52qceY40rEH+upqZPLy5LHhYRrPZKjOmgen283j8QSNxGL7ofGHyyvLd2aiyejrb746fPujz/Tjb4z1EErBNE1AIAB4vRyEfNjFNFx95ZWz62qr690OxwKny7nI4XDVaXK2uKiwkNgcdiTjCYwGBxEOjaqRsTCnlJDI2Bhh2Sw50tXJenv7UVdUIpYVFqE0371XPzL6TG1tw29tl1684y81hh+gK9FEV3o9HPX1HC0tH+lL8FEBTvwAafB6CbxeTDDsz25yOZB31ooV82fOrltpNBtXSURoLHa7bJrZhM7REVCNKdb8fESzSaGwrIoM9PbA7rBz6PWwOJwYGuiH0+GgJRUzwJgGRVG5ZLaMpJLxQUkQeyDQ/ZmxSFcsGt/XN9i575LrW4J/y1V/RGVP1+Vf/GLFnPnz51XNrGw0GUyLRabONhv0NoPRhJ4DBwDOEQwGWWxkGOFQCL1HujVjOkWy6YzoMlpQZnewGSJtNydSm2aFxjZ6hga3ovYTR8jmQPpvkIcCIG0AWTkO/nuh4IO+DB8GcMI5R3NzMwFAGxo6uM8X+KuYedMpC/Ira2ZVBROZFZFUZkkqFl2samxmvtOO4XAE0UQCyxsbFW4ywmQ0UlFvIEZLHjGbjOO0stnAGYPGOc9mZRSWlEDS6ThnGtNUFS6PR5B0eipJOjg9BdBJIggVEY/HEOzvHxMk4UAqltidHB3ZQkTd9h9+79JDL3eOxT7Uy+z3k4aGBjKh3NnfSrPO+1RT5WkrT28sd3pOkQg5KToWmskyKY+cSCAai6H3cA+Gh4eQiSeZjTFuVWQhlkjSAr0BtYIIIR7N1ojikQKDcW9ZQclu4nRs069Ythe1tQPkkkuSYAx4n5bYox+sbQbQcszL8KEA55wTn8/3XqkwEPhrcDlAfQUFFc7q8gU1DQ0rBkdCSyhBtQBeRCQdbC43hvv6EI7HGWVMNRj0xGwy075QiCxpXIQ8vR6HBwYgmszEZbNBlbPcaLMRo8nE9YKApKygdu48EM6RSiZh0OuRX1jIU6kULDY7N5rNnCkK0uk0BFGg5rw8wZHvQXJsDL2HujAWGtWcrvy+ZCq57tTzzv8qIQT8X+snJn6/nwCg5557LmlsbGTHuuYrzlw1f/bMmu/rdDqvoJdYeCREMuk0ug4cgItSZJNpZBIpHo2M8XKNMZ5VwLgmlnNOTRxo0umgmcxIalq01GwM6vS6bktaPpCOJzoscvqQgdIBKEo/gBgBPlBF7x+Ktom3+c9A/s3ttxfs6TlUkW+zLFTT6cafaaRxnizPcDjsDo/bDZPbg57eXjjNJjWVTrNYJAyu01GzQU9FSsXe4REooTGsPuUUjKTSZO+B/byytByiTuLZTBoL5i3A/oP7+XAsBpPRCGdREaKhEPKsVhSVVwJcg6DTE1FRiJrNYDgS5hpnxOpwYiwU4uDQhoYGOWdgw6OjhGkaSqsqK3Zu21ENAIyxf7WdmAMgzc3NfKJRAl+eNct13le/4nMXei6MRyInE0WRkukM45pCREXFaDqNArMZellBmcfN+/gItzMrdyZSyKga8cgKKwRYkUDJITkrFDENpXlWW4Eo2HSyUgdNPVMzGZCAin5VY8OCMETAj6xn5ICV8IOjArrCCuvaC3R3AKHA+6Sk7wu4FxDy6upMS5uaSnrT6WqdwBsgiHMNJmPdu0c6q/Ko4LTqTRD1JgQ7D6FYp4cWTWD/vgOIxxPgmooBURTtOh2yyYRGqcCInNUSGRnWTJoUF3iI22giLBzlEU5RUVqEnuAI7B4PYokoJEmH9OgoPIWFsFptMJtMUFUVnKkYGBggBp2Og2lwFxVDMBigpVI8HY/DYskj0ViUKIrKFTlLzRYzotGYunvbNhaNxjf/q9plYs+dEEK0lpYW3PpFb1390hVfMxuNa4rdrjLRaEA2meYpzjWHw06HjxzhSibLraLE3GVlXNQYNcWTYpGTocpsQ3R0FHp9BsztgKw3wCFJcQf4kNFiHs63mPpinAR3q/JoKpoM5klaJNg7kIxHI6lEKpnWq5pKKFRVAetkkC1ASgTU4b/zfO8L+AEb8hZSJb+9a19eTKMKFfGuKEo7ACCbSGiWdErbJ4i6eGjUNFcQ87KxZIEK7kgoasFgKFRiATxhwDMIWBOAtQ4QdBOuggPI33eApzdsVIdNZm7Ms9DovgM0v7YWWjqL6JAes2bOQHVNFfQ2O/R6E+LRKIhAkYjHQZnG9QY9GAgi0SgysRixOezcYrMjFo0gEYvxcCgEyaBHntWKVDpJ5JhKI7FoO4Cj+uODa5fWVkp8Pq2lpQU3fPnLC5cuXXy1zW5fU1VXZ0pmMoiPhdTU0BAsDgfRKzKPDg+pTNFIgaQTK2vqhILyUkR27sbh4XcTzGQc6slG9kYy6f0Zzg/JBZ6+VCrVv2XL5mA9EPspEP+35uG7oojsih6KYO+hD7HpSkA5MDxzpvVb0WFPUVwuKtC0yk7G5i7gfJ6RkBkq51UrOJdmpFOwppKIA2zrocNqJ0AFQaTDhQUoWjQfppOXwzWjEvnFRdCbTDi0dy8KSsrACEhWlsEY44qiQNIbkYiGkU1neCadgtPtht5ghCzLsJjMgsPpYkM7t787cYcfyJ23trYKa9as0YjPp635VFPlZ1Z/9oaa+tlfsVmtBlmVcfjIIVlJZwSrw0ns7nwuZ9LcBEm0WR3QKvUIvfVGsD043LFz157No1vffuu5dGT/5pFYL4Dsez+y/k9JxW8nXBDzegV4vcAxA4pHhxXbjxFmzeP5+19VCT+MaCP+8clKdHR0kPr6et4x/hXcP7P64eH3rjVs2MC9wN8tHxYBptVAZTFw0jJRPMPB+TJOUG0EkAeC/Zqm7uec7wOE7QDKCgpw9jlnY5X3AsQNBgicoOdQF0kmYnDne7igN4BxBoNOD1GnQyabAdcYYuExZGSZL1i8RAiHw8H7739gzhPPPx8anx38xxsaE+6bT/yt+dGf/9e1aix23fzGxQ4uilzUGxRJEoVUOIxMOs1UjUklnnzEgkGEDh46ODQ6+kpXKPTSXU8/vT0JDP2FNgJjjLQRIrQBaPB6eXsgwP8CwI+8CPNx74cTAMQ7/u+oNuDkrxlmvAhYdC7IZ/IJPbeUkNlRwrEeUCMAOjSNBgF8w27Hwi+sgXj2WTjQ3wcd50TIs/DhkREQQUBJeSU0TYWWzYKBIJ5IQlOyWv28+dJgMLhxtffCJj6ONv9nWH20RHvfj25bU1Fc/IOKioo5kWgU+YWFSiISoYlkCjaHg2VTKckyPiOeGu3t/W1f/+CTV99zzzoAiaPLwDmjCARIwOdDO8D/Ufo03Rogxgs1E7+/BtCOeXLT7aDnuMG/OQs41USANkKVLQIVChQFgwA+X12Nhi+swejc2aRzTzsvrKpCJpUinsJCUEHgRpMZ6UwalAoYHQqqLqdT1z80/P++cOU3Lj06V/b3KoQY9wDsnDNWlH/9q1f+pKa6Zg1nGpSsLKdlWdCbTIRqmmbQ6ySdIGLb1m2RoZ7upwa6u+5veSrQMUFh8GeeEQKBAHyBAMMkOSRgsnS8EC9AvX8B/t3AZ/MJva0OmPMyuLaJUvRTStyKgkscdsy/8nK8pskon1ENTVPgzi8A1UnghEJWFWTTaaRiUW3xkmXSpnfe+eaXvn71fRONEH8zZWn1eoWjJeAffP2KryxftuxHixobi8ZCISWbzRKrO5/GxkKaAEJLy8uFA52die3r2h54Zu3aBzd0dXUe3X8P+HxkMoE8GffDeQDQJqQJaQXoGkD7NvD8PZyt6wFuMRDy3SrOkWFMTUsS/WE4gh/c/yDOvOF72BkJY3R4GBwUrsIiMDWN4OAg8qw2VFTVkLFoFCpT94yLHt/7xWvR19Kifufyy93Fbtvd82bVf6morAzhaFTRNCaIosgBaG6HUxrqOsRefbfj0fsef/zODdu27Tu6A9bc3s5z48IfAnzfRNGgdfxM8hiA6/6b0zcbOfuVJsCxkzHFJkn00WiUNDzxNExrzofGGPp7uqHIMqx2OzRVhcls5vF4VNy3d2/sj6+29QJAe3uAv48LV69dc8HK5YsWPLh06Um1Y+GwMtDbQyS9QTCbTcxitVFdOi1tfG399pefbr3+sb17XvszoCdJg8NUBPw9842794lzTrVf3wUM2xgJuCgKI5ypEEXhjb0dWN4xG4mGeoTDEQz0dsPqsKOisgKCKHGmKoiGI8Hdb7wxCAAtLX9ys16vV6DPPqtxQvi1F5x7g/f8C24rLC2VJJ1Ojo2GRIfDBdFgUNOhUV18JKy8snbtD7/14ot3AEhzzoXm5uYpA/SUAPyY3SDtckD6DvBmC2efK+XC+kFwnUAJ3wwQ0+tvorykGKLHg5icQfuuncTucmPu3Hm8uGIGBgaHjnQDmWNPaDhGhTt/dcvND0uafD7TVBYa6NN2vfO2mE0kMX9RIyeDQd3IuvW721566Zofj45uoJTiggsuED5s61QO8H/SHgKUywHJD2z5GvjVNuCXOo2rUULI4UgYy/UGyHlmqHEO6srnodFhyKkUT2fSIDpp97Ei1d/UJPp8PvWGL31p/pK5s5+CojQoik6hmSzt7+sl2dCYZpd00si6Ngxsfvveeze+/v23gPjRcaS/tYE0VWxKDSI8BCitgPBLxn7lYvzFekDUBEHbnsmio+sQiCwjnUpCkTOwO+zIKjJhWRlqeKwdAK644grK/X7asmGD6r/Q65vlcWwoK/A0cE2VC2154qHduwgfi6qra+okbH4n/r/33vsfF218/eq3KI17vV5hIp2b0p+jmnKTJ0eVfITzO/soNIUSmgJwcP9+BINBDPb1IxEag9li5XlGg5AcHdEOth/YywHyYFGRRlpa2JWnLffnm0zPmKhg27m+TaGyItrtVl5izFNPZtCt+9X/67h3w4bTHsxkHuetrQJnjExlVk9Jl34M4Nr41wmw6SDnW2wcy2OAwkdGhWxwCKlsFnk2K7iiQMtmqS7POnaou7uHALy+pUW6onHBA9VFxZfoRUEdHRwidgJBHovwVGo/d+7fr3tkb/sL/3m4+1IAo/6mJpH4fCqmkU3JceGVgLABUL/C+GsNFMu3UMrTBiNmWK1IZLPIxOMYTqa4SaeDHaT/qTfeCF510acdxRHlKaKqZxkpl/WJlGDIZklVWRkL7z1I5SNHhMPR8E/+Mxi8gRCCz3MutGzYMK3AnpIuHQA8E3FUpnRbJwBmMVGzww6ZAfs7u2AymlFdU8Miw0OIRyO7SutLHWVh9eU8Qs9y26wyGxwTddEYMWQzmrWrR7SrGbauv/fKLwaDN3DOyS2c08Ak+zjNCc3weoCDEFRp2qGw3cZmVldRhQOhoSCIkkWeQY/4WIiO9vRgcCiku95dsdZA6ZLRaEzWZ7KiW6AoNFq0GSKVDhzcH3t5z/4Lfyanft/q9QoTaRvDNLUpfQLEOiB1qsWcLayqMoa6jrDK/HwsyM+HEokilklTnaZx53DQl80qiPO4WmnQi1IiA4/HpZWrmrRvYKCv9WDXBb+SU2+vB8RVgYCKaW5T90AAMt4EUO9ywiAKWHr6ShgcNgwPD0G0mGHU6RDtH+SxcJhlmarm60RqzSpYXFOtzdQbpc7B/v3Nb2385K9isbePfmkQJ4BN4RMgCPyAcZ7dKZXMqOJxJctHIlHMaWiAEovDIoqoKCtHeGAYRToDLVc0lKiaZnW7pB3hsY47t2w+cxMh+/wnENhTG3DO8XvA/o4gCvYCD08mE6SkpBiEMaRVBQWlpdCBoMRhg0VRMVeGNu/MT0pvHzy4K/Dqq2e+SklPK+dCywkE9pQFvMHrJeAcJ1dUlZ/m85EZNXXMXVIMk8UCJitESKVQOLMa5mQKTQWFmGWza85Pr5b27dy1f/Cll859nJD+VsYF3zRV4tNOtLVP9NDNKC+rM1ksSCYTzGl3UEGnh70gH8UeD9DTg0oC1HiKNLGqShrY236o5zfPr/4qpb2tjJ2QYE9Zhje3tWkEgG5GxQJ43Eik08Rqd0ASBRj0Bm6122BMZ1FisDJx4SJpuPtw/+annz7vLEqPnMhgT1XAiSAI4x99tdnmx4KDGA6NEi7pkOd0w+VwgIUj0Is65q6tof3bt0RffPSRz15A6bvrGRNPZLCnJOCtXi9ljMFnMCyYU11VZnE5mcPloqAEoihAxzlKZ1RxVyKNwS1v0cCTT138NUK2rmfshFLj0wbw/In4/Znlp64odLmEg4cPqzpVg8AYRroOQxodg51SJrStE9te+eO13wZeWM95DuypKtpWtrVpIASlBY5PxZIxSJSQbDIBokgQIxHklVao4s/u1u17Z8tDF1H6C86YQE5wNz5lGe4HKKGU3wnUjAJLk0zjWjQiJJIJZCNRFM2cqbm2bdNt3rT55S89+OA3J8CelO3COcD/GXY3NVFwDs8pp5zlnD/XrKiaGhkdI0hliBhPM3vrWqnjV7/s/F6h+eLtV1yhNB+n6Y4c4B+ROl/Z1qYBQEgQPusuKgLRGHR6PS8257G5Hg+Jbtsaf06WfRuHkiPPAELLNN71mvYx3A8QQim7UpdXN2flacsP7T/IeTZDSTzObXY3U1ufk14c6P/OLZTuyCnyacDwo+XU6rrKz0PO6pPRqCKoGikS9Frp629Iv2977edfp/SXObD/gZucKvdJCOEXl5cblp20cGue3dGQSqVUk8r56ZRKO373u42fLi39BO/o0HIibRow3AtQzjmC3d1NEhEabHabaqAU83WiMLJp0/AvYrEvk7175ZxImyaAt/r9HABOram7xGkyQolGWX4kxkNvvEmf7+7+2h8IOfLM+FZnTqRNdcD9ACW33sou8XiqGhYv/HRSlrklnkHpoSPSpu7uu/yUvtjKueDLFVemCcMncu+ZnsIvWvIsFimVzhbEYrp3ug5tvAm4sZUxwZtj9rQBnDS3tWkuIG/GzMqLU/EEK44nxd6d28ZeyqYvI4DS/m84kDaXh/+7YrfXSykh2h31s84pzXdW27NaZmR42LB5IHjFWkL25Vz5NGO4t7WVcYBWz6y+zKY3c6Iqhq3B/vt/CPKsn3MxB/Y0ArwVEADgjvr65UVO12kuxsjWd7bu3DYavoH7b6HNObCnl3HOKQBsvu66RyPfu569MHtW9tvAMhAC78TLkLNpwnD/+H3x+6+6pMrjKTyP9XST3T3dd9xNyOZWzoVAjt3TjN2trQIAvHLjjbfz5hb+XHn56wBEPv7ZSZJboekENkA4OLnw9KUFhy69YnDrihXJy4G5hJCjzM/ZtAJ8nMX43aWX/WfyzHP4tZReA0LeE3E5m0bmBygHyEU3XuXYfcZZo7+1u7dg/BrNufJpzO61SxbfsstTxL8GNJI/ibicTUd2ey/1Ot+prkk/Adw5cV3Mrc70FGsCALzhKrh9o9HcDcCYc+XTnN1rAddOKgw/CZwFICfUpju7Xwa56zeEPJUD++MzOgnAJgDY80BximDVi5zfwAHantvynJ52lMm/JuTHj4J+M8fu6e3KCQDyCFD5S0IeAyBNgJ0Tah+THe+UhwBgY6AXDHH2PxjvYKHIufNpy27cCNT+iOKSo2o9tzLTm+GgQF2M4XkOkFxv2vQ1AgA3AQU3ArXHXsvZ9GQ4B4AQoIWBrgmwc+z+N9j/B4hwekZ1VTGZAAAAAElFTkSuQmCC"
	        local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	        local lookup, out = {}, {}
	        for i = 1, #alphabet do lookup[alphabet:sub(i,i)] = i-1 end
	        for i = 1, #encoded, 4 do
	            local a,b,c,d = encoded:sub(i,i),encoded:sub(i+1,i+1),encoded:sub(i+2,i+2),encoded:sub(i+3,i+3)
	            local n = lookup[a]*262144+lookup[b]*4096+(lookup[c] or 0)*64+(lookup[d] or 0)
	            out[#out+1] = string.char(math.floor(n/65536)%256)
	            if c ~= "=" then out[#out+1] = string.char(math.floor(n/256)%256) end
	            if d ~= "=" then out[#out+1] = string.char(n%256) end
	        end
	        local path = "cashers-code-sniper-symbol.png"
	        writefile(path,table.concat(out))
	        return assetFunction(path)
	    end)
	    if ok and type(asset) == "string" and asset ~= "" then cashersLogoCache = asset end
	    return cashersLogoCache or nil
	end
	local function placeCashersLogo(parent, zindex)
	    local asset = getCashersLogo()
	    if asset then
	        local mark = Instance.new("ImageLabel")
	        mark.Name = "CashersSymbol"
	        mark.Size = UDim2.fromScale(1,1)
	        mark.BackgroundTransparency = 1
	        mark.Image = asset
	        mark.ScaleType = Enum.ScaleType.Fit
	        mark.ZIndex = zindex or 2
	        mark.Parent = parent
	    else
	        local mark = Instance.new("TextLabel")
	        mark.Name = "SymbolFallback"
	        mark.Size = UDim2.fromScale(1,1)
	        mark.BackgroundTransparency = 1
	        mark.Text = "✦"
	        mark.Font = Enum.Font.GothamBold
	        mark.TextSize = 36
	        mark.TextColor3 = T.Accent
	        mark.ZIndex = zindex or 2
	        mark.Parent = parent
	    end
	end

	-- HEADER
	local Hdr = Instance.new("Frame")
	Hdr.Size = UDim2.new(1, 0, 0, 74)
	Hdr.BackgroundTransparency = 1
	Hdr.LayoutOrder = 1
	Hdr.Active = true
	Hdr.ZIndex = 101
	Hdr.Parent = Win

	local HdrLine = Instance.new("Frame")
	HdrLine.Size = UDim2.new(1, -36, 0, 1)
	HdrLine.Position = UDim2.new(0, 18, 1, -1)
	HdrLine.BackgroundColor3 = T.Border
	HdrLine.BorderSizePixel = 0
	HdrLine.ZIndex = 102
	HdrLine.Parent = Hdr

	local Logo = Instance.new("Frame")
	Logo.Size = UDim2.fromOffset(50, 50)
	Logo.Position = UDim2.fromOffset(14, 11)
	Logo.BackgroundTransparency = 1
	Logo.ZIndex = 102
	Logo.Parent = Hdr
	placeCashersLogo(Logo, 103)

	local TitleL = Instance.new("TextLabel")
	TitleL.Size = UDim2.new(1, -132, 0, 26)
	TitleL.Position = UDim2.fromOffset(74, 15)
	TitleL.BackgroundTransparency = 1
	TitleL.Text = "CASHERS"
	TitleL.TextSize = 21
	TitleL.Font = Enum.Font.GothamBold
	TitleL.TextColor3 = T.White
	TitleL.TextXAlignment = Enum.TextXAlignment.Left
	TitleL.ZIndex = 102
	TitleL.Parent = Hdr

	local Subtitle = Instance.new("TextLabel")
	Subtitle.Size = UDim2.new(1, -132, 0, 16)
	Subtitle.Position = UDim2.fromOffset(74, 42)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Text = "CODE SNIPER"
	Subtitle.TextSize = 10
	Subtitle.Font = Enum.Font.GothamMedium
	Subtitle.TextColor3 = T.Dim
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	Subtitle.ZIndex = 102
	Subtitle.Parent = Hdr

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.fromOffset(32, 32)
	MinBtn.Position = UDim2.new(1, -50, 0, 20)
	MinBtn.BackgroundColor3 = T.Card
	MinBtn.BorderSizePixel = 0
	MinBtn.Text = "−"
	MinBtn.TextSize = 22
	MinBtn.Font = Enum.Font.Gotham
	MinBtn.TextColor3 = T.Dim
	MinBtn.ZIndex = 105
	MinBtn.Parent = Hdr
	Corner(MinBtn, 8)
	Stroke(MinBtn)

	-- BODY
	local Body = Instance.new("Frame")
	Body.Size = UDim2.new(1, 0, 0, 0)
	Body.AutomaticSize = Enum.AutomaticSize.Y
	Body.BackgroundTransparency = 1
	Body.LayoutOrder = 2
	Body.ZIndex = 101
	Body.Parent = Win

	local BL = Instance.new("UIListLayout")
	BL.FillDirection = Enum.FillDirection.Vertical
	BL.Padding = UDim.new(0, 9)
	BL.SortOrder = Enum.SortOrder.LayoutOrder
	BL.HorizontalAlignment = Enum.HorizontalAlignment.Center
	BL.Parent = Body

	local BPad = Instance.new("UIPadding")
	BPad.PaddingTop = UDim.new(0, 10)
	BPad.PaddingBottom = UDim.new(0, 12)
	BPad.PaddingLeft = UDim.new(0, 18)
	BPad.PaddingRight = UDim.new(0, 18)
	BPad.Parent = Body

	-- STATUS
	local StatusCard = Instance.new("Frame")
	StatusCard.Size = UDim2.new(1, 0, 0, 40)
	StatusCard.BackgroundColor3 = T.Card
	StatusCard.ZIndex = 102
	StatusCard.LayoutOrder = 1
	StatusCard.Parent = Body
	Corner(StatusCard, 10)
	Stroke(StatusCard, T.Border, 1.2)

	local SDot = Instance.new("Frame")
	SDot.Size = UDim2.new(0, 9, 0, 9)
	SDot.Position = UDim2.new(0, 14, 0.5, -4.5)
	SDot.BackgroundColor3 = T.Dim
	SDot.ZIndex = 103
	SDot.Parent = StatusCard
	Corner(SDot, 5)

	local SLbl = Instance.new("TextLabel")
	SLbl.Size = UDim2.new(1, -36, 1, 0)
	SLbl.Position = UDim2.new(0, 30, 0, 0)
	SLbl.BackgroundTransparency = 1
	SLbl.Text = "Click the code box first"
	SLbl.TextSize = 12
	SLbl.TextWrapped = true
	SLbl.Font = Enum.Font.GothamMedium
	SLbl.TextColor3 = T.Dim
	SLbl.TextXAlignment = Enum.TextXAlignment.Left
	SLbl.ZIndex = 103
	SLbl.Parent = StatusCard

	-- TOGGLES
	local ToggleCard = Instance.new("Frame")
	ToggleCard.Size = UDim2.new(1, 0, 0, 70)
	ToggleCard.BackgroundColor3 = T.Card
	ToggleCard.ZIndex = 102
	ToggleCard.LayoutOrder = 2
	ToggleCard.Parent = Body
	Corner(ToggleCard, 10)
	Stroke(ToggleCard, T.Border, 1.2)

	local function CreateToggle(parent, yPos, labelText, defaultOn)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -20, 0, 26)
		row.Position = UDim2.new(0, 10, 0, yPos)
		row.BackgroundTransparency = 1
		row.ZIndex = 103
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.6, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextSize = 12
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextColor3 = T.White
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 104
		lbl.Parent = row

		local track = Instance.new("Frame")
		track.Size = UDim2.new(0, 42, 0, 22)
		track.Position = UDim2.new(1, -42, 0.5, -11)
		track.BackgroundColor3 = defaultOn and T.Accent or T.Field
		track.ZIndex = 104
		track.Parent = row
		Corner(track, 11)
		Stroke(track, T.Border)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 18, 0, 18)
		knob.Position = defaultOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.ZIndex = 105
		knob.Parent = track
		Corner(knob, 9)

		local state = defaultOn
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.ZIndex = 106
		btn.Parent = row

		return {
			Button = btn,
			Set = function(val)
				state = val
				Tw(track, Smooth, {BackgroundColor3 = state and T.Accent or T.Field})
				Tw(knob, Bounce, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
			end
		}
	end

	local EnabledToggle = CreateToggle(ToggleCard, 10, "Enabled", true)
	local AutoToggle = CreateToggle(ToggleCard, 40, "Auto Submit", true)

	local ClearBtn = Instance.new("TextButton")
	ClearBtn.Size = UDim2.new(1, 0, 0, 32)
	ClearBtn.BackgroundColor3 = T.Card
	ClearBtn.BorderSizePixel = 0
	ClearBtn.Text = "CLEAR CODE"
	ClearBtn.TextSize = 12
	ClearBtn.Font = Enum.Font.GothamBold
	ClearBtn.TextColor3 = T.Focus
	ClearBtn.ZIndex = 103
	ClearBtn.AutoButtonColor = false
	ClearBtn.LayoutOrder = 3
	ClearBtn.Parent = Body
	Corner(ClearBtn, 8)
	Stroke(ClearBtn)

    local function updatePartStatus()
        CodeSmall.Text = "PARTS RECEIVED: " .. #parser.pieces
            .. (parser.announcedSize and (" • announced " .. parser.announcedSize) or "")
    end

	-- CODE CARD
	local CodeCard = Instance.new("Frame")
	CodeCard.Size = UDim2.new(1, 0, 0, 56)
	CodeCard.BackgroundColor3 = T.Field
	CodeCard.ZIndex = 102
	CodeCard.LayoutOrder = 5
	CodeCard.Parent = Body
	Corner(CodeCard, 10)
	local CodeStroke = Stroke(CodeCard, T.Border, 1.2)

	CodeSmall = Instance.new("TextLabel")
	CodeSmall.Size = UDim2.new(1, -16, 0, 14)
	CodeSmall.Position = UDim2.new(0, 10, 0, 6)
	CodeSmall.BackgroundTransparency = 1
	CodeSmall.Text = "PARTS RECEIVED: 0"
	CodeSmall.TextSize = 9
	CodeSmall.Font = Enum.Font.GothamBold
	CodeSmall.TextColor3 = T.Focus
	CodeSmall.TextXAlignment = Enum.TextXAlignment.Left
	CodeSmall.ZIndex = 103
	CodeSmall.Parent = CodeCard

	local CodeVal = Instance.new("TextLabel")
	CodeVal.Size = UDim2.new(1, -16, 0, 28)
	CodeVal.Position = UDim2.new(0, 10, 0, 22)
	CodeVal.BackgroundTransparency = 1
	CodeVal.Text = "—"
	CodeVal.TextScaled = true
	CodeVal.TextWrapped = true
	CodeVal.Font = Enum.Font.Code
	CodeVal.TextColor3 = T.Dim
	CodeVal.TextXAlignment = Enum.TextXAlignment.Left
	CodeVal.ZIndex = 103
	CodeVal.Parent = CodeCard
	local codeTextSize = Instance.new("UITextSizeConstraint")
	codeTextSize.MinTextSize = 8
	codeTextSize.MaxTextSize = 15
	codeTextSize.Parent = CodeVal

	-- RIDDLE
	local RiddleCard = Instance.new("Frame")
	RiddleCard.Size = UDim2.new(1, 0, 0, 0)
	RiddleCard.AutomaticSize = Enum.AutomaticSize.Y
	RiddleCard.BackgroundColor3 = T.Card
	RiddleCard.Visible = false
	RiddleCard.ZIndex = 102
	RiddleCard.LayoutOrder = 6
	RiddleCard.Parent = Body
	Corner(RiddleCard, 10)
	Stroke(RiddleCard)

	local RiddlePad = Instance.new("UIPadding")
	RiddlePad.PaddingTop = UDim.new(0, 6)
	RiddlePad.PaddingBottom = UDim.new(0, 8)
	RiddlePad.PaddingLeft = UDim.new(0, 10)
	RiddlePad.PaddingRight = UDim.new(0, 10)
	RiddlePad.Parent = RiddleCard

	local RLL = Instance.new("UIListLayout")
	RLL.Padding = UDim.new(0, 3)
	RLL.Parent = RiddleCard

	local RTag = Instance.new("TextLabel")
	RTag.Size = UDim2.new(1, 0, 0, 13)
	RTag.BackgroundTransparency = 1
	RTag.Text = "WITCH'S RIDDLE SOLVER"
	RTag.TextSize = 10
	RTag.Font = Enum.Font.GothamBold
	RTag.TextColor3 = T.Yellow
	RTag.TextXAlignment = Enum.TextXAlignment.Left
	RTag.ZIndex = 103
	RTag.Parent = RiddleCard

	local RMsg = Instance.new("TextLabel")
	RMsg.Size = UDim2.new(1, 0, 0, 0)
	RMsg.AutomaticSize = Enum.AutomaticSize.Y
	RMsg.BackgroundTransparency = 1
	RMsg.TextSize = 11
	RMsg.Font = Enum.Font.GothamMedium
	RMsg.TextColor3 = T.White
	RMsg.TextXAlignment = Enum.TextXAlignment.Left
	RMsg.TextWrapped = true
	RMsg.ZIndex = 103
	RMsg.Parent = RiddleCard

	local function setStatus(msg, col)
		SLbl.Text = msg
		SLbl.TextColor3 = col or T.Dim
		SDot.BackgroundColor3 = col or T.Dim
	end

	local function flashCode(code, col)
		CodeVal.Text = code
		CodeVal.TextColor3 = col or T.Accent
		Tw(CodeStroke, Fast, {Color = col or T.Accent})
		task.delay(0.4, function()
			Tw(CodeStroke, Smooth, {Color = T.Border})
		end)
	end

	local function showRiddle(msg, col)
		RMsg.Text = msg
		RMsg.TextColor3 = col or T.White
		RiddleCard.Visible = true
	end

	local function hideRiddle()
		RiddleCard.Visible = false
	end

	-- LOGIC
	connect(EnabledToggle.Button.Activated, function()
		_enabled = not _enabled
        if not _enabled then resetStack() end
		EnabledToggle.Set(_enabled)
		setStatus(_enabled and (_lockedBox and "Locked & Watching" or "Click the code box first") or "Paused", _enabled and (_lockedBox and T.Green or T.Dim) or T.Dim)
	end)

	connect(AutoToggle.Button.Activated, function()
		_autoSubmit = not _autoSubmit
		AutoToggle.Set(_autoSubmit)
	end)

    connect(ClearBtn.Activated, function()
        resetStack()
        setStatus("Code cleared — waiting for a new announcement", T.Yellow)
    end)

	connect(MinBtn.Activated, function()
		isMinimized = not isMinimized
		MinBtn.Text = isMinimized and "+" or "−"
		Body.Visible = not isMinimized
	end)

	-- Drag
	do
		local drag, ds, ws
		connect(Hdr.InputBegan, function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				drag = true
				ds = inp.Position
				ws = Win.Position
			end
		end)
		connect(Hdr.InputEnded, function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				drag = false
			end
		end)
		connect(UserInputService.InputChanged, function(inp)
			if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local d = inp.Position - ds
				Win.Position = UDim2.new(ws.X.Scale, ws.X.Offset + d.X, ws.Y.Scale, ws.Y.Offset + d.Y)
			end
		end)
	end

    -- Queue ownership, response tracking, and local diagnostics.
    local engine = {
        queue={},queued={},tried={},recent={},session=1,serial=0,lastAttempt=-math.huge,
        submitting=false,scheduled=false,enabled=true,feedback=Parser.Feedback.new(),
        gap=0.2,cooldownUntil=0,attempts=0,latestAnswer=nil,
    }
    do
        local options=type(env.SpookyCodeOptions)=="table" and env.SpookyCodeOptions or {}
        engine.gap=math.max(0.2,math.min(5,tonumber(options.SubmitGap) or 0.2))
        local locks=env.CashersCodeSubmitLocks
        if type(locks)~="table" then locks=setmetatable({},{__mode="k"});env.CashersCodeSubmitLocks=locks end
        local function displayed(object)
            if not object or not object.Parent then return false end
            local current=object
            while current and current~=playerGui do
                if current:IsA("GuiObject") and not current.Visible then return false end
                if current:IsA("ScreenGui") and not current.Enabled then return false end
                current=current.Parent
            end
            return true
        end
        local function isCodeBox(box)
            if not box:IsA("TextBox") or box:IsDescendantOf(GUI) then return false end
            local current=box
            while current and current~=playerGui do
                local name=current.Name:lower()
                if name:find("chat",1,true) then return false end
                if name=="codes" or name=="coderedeem" or name=="redeemcode" or name=="codesgui" or name=="codegui" then return true end
                current=current.Parent
            end
            return false
        end
        function engine:autoLock()
            if _lockedBox and _lockedBox.Parent then return end
            local root=playerGui:FindFirstChild("Codes")
            local found={}
            if root then
                for _,object in ipairs(root:GetDescendants()) do if isCodeBox(object) then found[#found+1]=object end end
            end
            if #found==1 then _lockedBox=found[1] end
        end
        function engine:log()
            if self.onLog then self.onLog(self.feedback.items) end
        end
        function engine:clearQueue(newSession)
            self.queue,self.queued={},{}
            self.serial=self.serial+1
            if newSession then self.session=self.session+1 end
        end
        resetStack=function()
            parser:reset()
            engine:clearQueue(true)
            updatePartStatus()
            flashCode("—",T.Dim)
            hideRiddle()
        end
        function engine:schedule(delay)
            if self.scheduled or not runtime.alive then return end
            self.scheduled=true
            task.delay(math.max(delay or 0,0.01),function()
                self.scheduled=false
                if runtime.alive then self:pump() end
            end)
        end
        function engine:pump()
            if self.submitting or not runtime.alive or not _enabled or not self.queue[1] then return end
            local now=os.clock()
            local item=self.queue[1]
            if now-item.time>45 or item.session~=self.session then
                table.remove(self.queue,1);self.queued[item.code]=nil;self:schedule();return
            end
            self:autoLock()
            if not _lockedBox or not displayed(_lockedBox) then
                setStatus("Code queued — open the game's Codes panel",T.Yellow)
                return
            end
            local remaining=math.max(self.gap-(now-self.lastAttempt),self.cooldownUntil-now)
            if locks[_lockedBox] then remaining=math.max(remaining,0.1) end
            if remaining>0 then self:schedule(remaining);return end
            table.remove(self.queue,1);self.queued[item.code]=nil
            local last=self.tried[item.code]
            if last and now-last<120 then self:schedule();return end
            local box,version=_lockedBox,self.serial
            local entry=self.feedback:begin(item.code,now,self.session)
            self.submitting=true
            locks[box]=true
            self.lastAttempt=now
            self:log()
            local ok,performed=pcall(function()
                box.Text=item.code
                if _autoSubmit then
                    box:CaptureFocus()
                    task.wait(0.05)
                    if not runtime.alive or not _enabled or version~=self.serial or box~=_lockedBox or not displayed(box) then return false end
                    if not _autoSubmit then entry.state="filled";return true end
                    -- A dispatched callback is never counted as server acceptance.
                    entry.state="submitted"
                    entry.time=os.clock()
                    box:ReleaseFocus(true)
                else entry.state="filled" end
                return true
            end)
            locks[box]=nil
            self.submitting=false
            if not runtime.alive then return end
            if not ok or not performed then
                entry.state="error"
                if version==self.serial then setStatus("Submission interrupted — check the Codes panel",T.Yellow) end
            elseif version==self.serial then
                self.tried[item.code]=os.clock()
                self.attempts=self.attempts+1
                setStatus(_autoSubmit and ("Submitted — awaiting game result: "..item.code) or ("Filled: "..item.code),T.Green)
            end
            self:log()
            if self.queue[1] then self:schedule() end
        end
        function engine:enqueue(value,reason)
            if type(value)~="string" or not value:match("^[A-Z0-9_%-]+$") or #value>80 then return end
            if self.queued[value] or (self.tried[value] and os.clock()-self.tried[value]<120) then return end
            if #self.queue>=80 then return end
            self.queue[#self.queue+1]={code=value,reason=reason,time=os.clock(),session=self.session}
            self.queued[value]=true
        end
        function engine:feedbackText(text)
            if not _enabled then return end
            local observed=self.feedback:observe(text,os.clock(),self.session)
            if not observed then return end
            if observed.state=="accepted" or observed.state=="used" then
                parser:reset()
                self:clearQueue(false)
                updatePartStatus()
                local label=observed.code or "a code in this session"
                setStatus((observed.state=="accepted" and "Game confirmed redemption: " or "Game reports already used: ")..label,T.Green)
            elseif observed.state=="cooldown" then
                self.cooldownUntil=os.clock()+math.max(1,self.gap)
                setStatus("Game cooldown — queued parts will wait",T.Yellow)
                self:schedule(1)
            elseif observed.state=="invalid" then
                setStatus("Rejected: "..(observed.code or "code").." — waiting for the next part",T.Yellow)
            end
            self:log()
        end
        function engine:handle(result)
            if result.kind=="ignored" then return end
            if result.kind=="remembered" then return end
            if result.kind=="armed" or result.kind=="reset" then
                self:clearQueue(true)
                updatePartStatus();hideRiddle();flashCode("—",T.Dim)
                setStatus(result.kind=="armed" and ("Trying after every part"..(result.total and (" • announced "..result.total) or "")) or "Code announcement cancelled",T.Yellow)
            elseif result.kind=="historyPreview" then
                self:clearQueue(true)
                self.latestAnswer=nil
                flashCode("—",T.Dim);showRiddle(result.display,T.Yellow)
                setStatus("Answer needs review — details shown below",T.Yellow)
            elseif result.kind=="unsolved" then
                self:clearQueue(true)
                self.latestAnswer=nil
                showRiddle("No confident answer yet. Waiting for more clues.",T.Yellow)
                setStatus("Riddle recognized — waiting for clues",T.Yellow)
            elseif result.kind=="code" and result.code then
                if result.newSession or result.reason~="growing prefix" then self:clearQueue(true) end
                updatePartStatus();flashCode(result.code,T.Green)
                self.latestAnswer=result.code
                if result.reason~="growing prefix" then showRiddle("Answer: "..(result.display or result.code).." ("..result.reason..")",T.Green) end
                for _,value in ipairs(result.candidates or {result.code}) do self:enqueue(value,result.reason) end
                self:pump()
            end
        end
        function engine:process(text,source)
            if not runtime.alive or not _enabled then return end
            text=Parser.clean(text)
            if text=="" or #text>1500 then return end
            local now=os.clock()
            local previous=self.recent[text]
            if previous and previous.source~=source and now-previous.time<1.25 then return end
            self.recent[text]={source=source,time=now}
            for key,entry in pairs(self.recent) do if now-entry.time>5 then self.recent[key]=nil end end
            pcall(function() live:refreshFast() end)
            self:handle(parser:feed(text,now))
        end
        function engine:test(text)
            pcall(function() live:refreshFast() end)
            local answer,reason,display=Parser.solve(text,parser.facts,nil,nil,parser.smart,os.clock(),true)
            return {code=answer,reason=reason,display=display or answer or "No confident local answer",review=answer==nil}
        end
        -- Public diagnostic entry points never submit codes.
        runtime.TestRiddle=function(text) return engine:test(text) end
        runtime.GetStatus=function()
            return {queued=#engine.queue,attempts=engine.attempts,parts=#parser.pieces,
                announced=parser.announcedSize,locked=_lockedBox and _lockedBox.Parent~=nil,
                liveBrainrots=live.context.animals and #live.context.animals or 0,
                remembered=#parser.smart.messages,session=engine.session,lastError=live.lastError}
        end
        connect(UserInputService.TextBoxFocused,function(box)
            if not isCodeBox(box) then return end
            _lockedBox=box
            if _enabled then engine:pump() end
        end)
        -- A server response is observed only from the game's Codes UI, after a change.
        local responseWatched=setmetatable({},{__mode="k"})
        local function isResponseLabel(object)
            if object:IsDescendantOf(GUI) then return false end
            local p=object.Parent
            while p and p~=playerGui do
                local n=p.Name:lower()
                if n=="codes" or n=="notifications" or n=="notification" or n=="toasts" then return true end
                p=p.Parent
            end
            return false
        end
        local function watchResponse(object)
            if responseWatched[object] or not (object:IsA("TextLabel") or object:IsA("TextButton")) then return end
            if not isResponseLabel(object) then return end
            responseWatched[object]=true
            local last=Parser.clean(object.Text)
            connect(object:GetPropertyChangedSignal("Text"),function()
                local value=Parser.clean(object.Text)
                if value==last then return end
                last=value
                if displayed(object) then engine:feedbackText(value) end
            end)
        end
        local watched=setmetatable({},{__mode="k"})
        local function isAnnouncement(object)
            if object:IsDescendantOf(GUI) then return false end
            local p=object
            local matches=false
            for _=1,8 do
                if not p or p==playerGui then break end
                local n=p.Name:lower()
                if n:find("chat",1,true) or n=="codes" then return false end
                if n:find("announce",1,true) or n:find("broadcast",1,true) or n:find("global",1,true)
                    or n:find("notif",1,true) or n:find("banner",1,true) or n=="sammy" or n=="alert" or n=="news" then matches=true end
                p=p.Parent
            end
            return matches
        end
        local function watchAnnouncement(object,newLabel)
            if watched[object] or not object:IsA("TextLabel") or not isAnnouncement(object) then return end
            watched[object]=true
            local last=not newLabel and Parser.clean(object.Text) or nil
            local function capture()
                local text=Parser.clean(object.Text)
                if text=="" then last=nil;return end
                if not displayed(object) or text==last then return end
                last=text
                if isResponseLabel(object) and Parser.Feedback.classify(text) then return end
                task.defer(function() if runtime.alive then engine:process(text,object) end end)
            end
            connect(object:GetPropertyChangedSignal("Text"),capture)
            local p=object
            for _=1,8 do
                if not p or p==playerGui then break end
                if p:IsA("GuiObject") then connect(p:GetPropertyChangedSignal("Visible"),capture)
                elseif p:IsA("ScreenGui") then connect(p:GetPropertyChangedSignal("Enabled"),capture) end
                p=p.Parent
            end
            if newLabel then capture() end
        end
        connect(playerGui.DescendantAdded,function(object)
            watchAnnouncement(object,true);watchResponse(object)
            -- UI objects may be parented before their descendants or text are ready.
            if object:IsA("TextBox") then engine:autoLock();engine:pump() end
        end)
        for _,object in ipairs(playerGui:GetDescendants()) do watchAnnouncement(object,false);watchResponse(object) end
        -- Exact named notification remotes are read-only. No opaque remote guessing.
        local remoteWatched=setmetatable({},{__mode="k"})
        local function watchRemote(object)
            if remoteWatched[object] or not object:IsA("RemoteEvent") then return end
            local name=object.Name:lower()
            if not (name=="notify" or name=="notification" or name=="announcement" or name=="re/notification" or name=="re/notify") then return end
            remoteWatched[object]=true
            connect(object.OnClientEvent,function(message)
                local text=type(message)=="string" and message or type(message)=="table" and (message.Text or message.Message or message.text or message.message)
                if type(text)~="string" then return end
                if Parser.Feedback.classify(text) and name~="announcement" then engine:feedbackText(text)
                else engine:process(text,object) end
            end)
        end
        connect(ReplicatedStorage.DescendantAdded,watchRemote)
        for _,object in ipairs(ReplicatedStorage:GetDescendants()) do watchRemote(object) end
        task.spawn(function()
            while runtime.alive do
                task.wait(0.5)
                if not runtime.alive then break end
                if _enabled and parser.untilTime>0 and os.clock()>parser.untilTime then
                    resetStack();setStatus("Announcement timed out — waiting for a new one",T.Dim)
                end
                if _enabled and #engine.queue>0 then engine:pump() end
                -- Bound duplicate memory for long-running sessions.
                for value,time in pairs(engine.tried) do if os.clock()-time>120 then engine.tried[value]=nil end end
            end
        end)
    end

    do
        local panel=Instance.new("Frame")
        panel.Name="SolverTools"
        panel.Size=UDim2.new(1,0,0,0)
        panel.AutomaticSize=Enum.AutomaticSize.Y
        panel.BackgroundTransparency=1
        panel.LayoutOrder=7
        panel.ZIndex=102
        panel.Parent=Body
        local layout=Instance.new("UIListLayout")
        layout.Padding=UDim.new(0,6)
        layout.SortOrder=Enum.SortOrder.LayoutOrder
        layout.Parent=panel
        local function button(text,parent,order)
            local b=Instance.new("TextButton")
            b.Size=UDim2.new(1,0,0,28)
            b.BackgroundColor3=T.Card
            b.TextColor3=T.Focus
            b.Font=Enum.Font.GothamBold
            b.TextSize=10
            b.Text=text
            b.BorderSizePixel=0
            b.LayoutOrder=order
            b.ZIndex=104
            b.Parent=parent
            Corner(b,8);Stroke(b)
            return b
        end
        local toggle=button("SOLVER TOOLS +",panel,1)
        local details=Instance.new("Frame")
        details.Size=UDim2.new(1,0,0,0)
        details.AutomaticSize=Enum.AutomaticSize.Y
        details.BackgroundTransparency=1
        details.Visible=false
        details.LayoutOrder=2
        details.ZIndex=102
        details.Parent=panel
        local rows=Instance.new("UIListLayout")
        rows.Padding=UDim.new(0,6)
        rows.SortOrder=Enum.SortOrder.LayoutOrder
        rows.Parent=details
        local test=Instance.new("TextBox")
        test.Name="RiddleTest"
        test.Size=UDim2.new(1,0,0,46)
        test.BackgroundColor3=T.Field
        test.TextColor3=T.White
        test.PlaceholderText="Type a riddle to test (never submits)"
        test.PlaceholderColor3=T.Dim
        test.Text=""
        test.ClearTextOnFocus=false
        test.TextWrapped=true
        test.TextSize=11
        test.Font=Enum.Font.GothamMedium
        test.LayoutOrder=1
        test.ZIndex=104
        test.Parent=details
        Corner(test,8)
        local run=button("TEST RIDDLE",details,2)
        connect(run.Activated,function()
            if Parser.clean(test.Text)=="" then return end
            local result=engine:test(test.Text)
            engine.latestAnswer=result.code
            showRiddle((result.review and "Review: " or "Test answer: ")..result.display..(result.reason and (" ("..result.reason..")") or ""),result.review and T.Yellow or T.Green)
        end)
        local copy=button("COPY LAST ANSWER",details,3)
        connect(copy.Activated,function()
            if not engine.latestAnswer then setStatus("No complete answer to copy",T.Yellow);return end
            local clipboard=setclipboard or toclipboard
            if type(clipboard)=="function" then
                local ok=pcall(clipboard,engine.latestAnswer)
                setStatus(ok and "Answer copied" or "Clipboard unavailable",ok and T.Green or T.Yellow)
            else setStatus("Clipboard unavailable",T.Yellow) end
        end)
        local feed=Instance.new("TextLabel")
        feed.Name="AttemptFeed"
        feed.Size=UDim2.new(1,0,0,0)
        feed.AutomaticSize=Enum.AutomaticSize.Y
        feed.BackgroundColor3=T.Field
        feed.TextColor3=T.Dim
        feed.TextSize=10
        feed.Font=Enum.Font.Code
        feed.TextXAlignment=Enum.TextXAlignment.Left
        feed.TextYAlignment=Enum.TextYAlignment.Top
        feed.TextWrapped=true
        feed.Text="No attempts yet. Submitted means awaiting game confirmation."
        feed.LayoutOrder=4
        feed.ZIndex=104
        feed.Parent=details
        Corner(feed,8)
        engine.onLog=function(items)
            local lines={}
            for i=math.max(1,#items-5),#items do
                local item=items[i]
                lines[#lines+1]=item.code.."  • "..item.state
            end
            feed.Text=#lines>0 and table.concat(lines,"\n") or "No attempts yet."
        end
        connect(toggle.Activated,function()
            details.Visible=not details.Visible
            toggle.Text=details.Visible and "SOLVER TOOLS −" or "SOLVER TOOLS +"
        end)
    end

    updatePartStatus()
    setStatus("Open Codes • tries each part • solver tools below", T.Dim)
    flashCode("—", T.Dim)

end

StartMainScript()
