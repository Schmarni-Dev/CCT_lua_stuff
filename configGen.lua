local function runA()
    local config = {}
    config.item = {}
    term.clear()
    term.setCursorPos(1, 1)
    print("Enter your Client secret")
    config.secret = read("*")
    term.clear()
    term.setCursorPos(1, 1)
    print("Enter your Item Name")
    config.item.name = read()
    term.clear()
    term.setCursorPos(1, 1)
    print("Enter your how many items")
    print("you sell at once (no max)")
    config.item.amount = tonumber(read())
    term.clear()
    term.setCursorPos(1, 1)
    print("Enter your Item Price (per "..config["item"]["amount"].." items)")
    print("(must be a full number like 1,2,3,4,5)")
    config.item.price = tonumber(read())
    term.clear()
    term.setCursorPos(1, 1)
    textutils.slowPrint("waiting...", 10)
    local json_payload = {
        ["data"] = config["secret"],
        ["type"] = "key"
    }
    local r = http.post("http://schmerver.mooo.com:5000/api/getUsername", textutils.serialiseJSON(json_payload))
                  .readAll()
    local j = textutils.unserialiseJSON(r)
    config.userName = j["data"]

    f = fs.open("config/shop.json", "w")
    f.write(textutils.serialiseJSON(config))
    f.close()
    return "R"
end

local function runR()
    local status, res = pcall(runA)
    if not status then
        runR()
    else
        print("Done")
        os.sleep(1)
        shell.run("startup.lua")
    end
end

runR()
