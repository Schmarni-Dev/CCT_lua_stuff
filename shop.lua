-- Setup --

local sebase = [[
local eject = true
local stacklimit = 64

local function onPay(items)
    local c = 0
    while items > c + stacklimit do
        turtle.suckDown(stacklimit)
        turtle.drop(stacklimit)
        c = c + stacklimit
    end
    turtle.suckDown(items - c)
    turtle.drop(items - c)
end

return {
    onPay = onPay,
    pt = print_table,
    eject = eject
}
]]
if not fs.exists("config/se.lua") then
    local f = fs.open("config/se.lua", "w")
    f.write(sebase)
    f.close();
end
local se = require("config/se")

local drive = peripheral.find("drive", function(name, object)
    object.side = name
    return true
end)
local monitor = peripheral.find("monitor", function(name, object)
    object.side = name
    return true
end)

-- local barrel = peripheral.find("minecraft:barrel")
local barrel = peripheral.wrap("bottom")

monitor.setTextScale(0.5)

-- Functions --
local function readJson(path)
    local f = fs.open(path, "r")
    diskjson = textutils.unserialiseJSON(f.readAll())
    f.close()
    return diskjson
end

local function checkStock(items)
    local c = 0
    for slot, item in pairs(barrel.list()) do
        c = c + item.count
    end
    return c >= items
end

local function StandartDisplay(c)
    monitor.setCursorPos(1, 1)
    monitor.clear()
    monitor.write("Seller :")
    monitor.setCursorPos(1, 2)
    monitor.write(c["userName"])
    monitor.setCursorPos(1, 3)
    monitor.write("Item : " .. c["item"]["name"])
    monitor.setCursorPos(1, 4)
    monitor.write("Price : " .. c["item"]["price"] .. "$")
    monitor.setCursorPos(1, 5)
    monitor.write("Ammount : " .. c["item"]["amount"])
    monitor.setCursorPos(1, 7)
    monitor.write("Click to Buy")
end

local function displayForTime(msg, t,msg2)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write(msg)
    monitor.setCursorPos(1, 2)
    monitor.write(msg2)
    os.sleep(t)
end

-- Main Code --

local config = readJson("config/shop.json")

while true do
    StandartDisplay(config)
    local event, peripheral_name, x, y = os.pullEvent("monitor_touch")
    if disk.hasData(drive.side) and peripheral_name ~= null then
        if checkStock(config["item"]["amount"]) then
            local dj = readJson("disk/schmAPIcard.json")
            local json_payload = {
                ["data"] = dj["secret"],
                ["data1"] = config["secret"],
                ["data2"] = config["item"]["price"],
                ["type"] = "key"
            }
            local j = textutils.unserialiseJSON(http.post("http://schmerver.mooo.com:5000/api/money/transfer", textutils.serialiseJSON(json_payload)).readAll())
            if j["error"] == "" then
                se.onPay(config["item"]["amount"])
                local json_payload = {
                    ["data"] = dj["secret"],
                    ["type"] = "key"
                }
                local m = textutils.unserialiseJSON(http.post("http://schmerver.mooo.com:5000/api/money/get", textutils.serialiseJSON(json_payload)).readAll())
                disk.setLabel(drive.side,dj["name"].."'s card. "..m["data"].."$")
                if se.eject then
                    disk.eject(drive.side)
                end
                displayForTime("Thank you for",1,"your Purchase")
            else     
                local m = textutils.unserialiseJSON(http.post("http://schmerver.mooo.com:5000/api/money/get", textutils.serialiseJSON(json_payload)).readAll())
                disk.setLabel(drive.side,dj["name"].."'s card. "..m["data"].."$")
                if se.eject then
                    disk.eject(drive.side)
                end
                displayForTime("You don't have enough",2,"$ for your Purchase")
            end
        else
            displayForTime("Out of Stock",1)
            disk.eject(drive.side)
        end
    else 
        displayForTime("No Valid Disk", 1)
        disk.eject(drive.side)
    end
end

