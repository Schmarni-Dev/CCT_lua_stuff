local drive = peripheral.find("drive", function(name, object)
    object.side = name
    return true
end)

local J = {}

print("Enter your Client secret")
J.secret = read("*")

local json_payload = {
    ["data"] = J["secret"],
    ["type"] = "key"
}
local r = http.post("http://schmerver.mooo.com:5000/api/getUsername", textutils.serialiseJSON(json_payload)).readAll()
local j = textutils.unserialiseJSON(r)
J.name = j["data"]

textutils.slowPrint("Okay Done User: "..J["name"])

f = fs.open("disk/schmAPIcard.json","w")
f.write(textutils.serialiseJSON(J))
f.close()

local m = textutils.unserialiseJSON(http.post("http://schmerver.mooo.com:5000/api/money/get", textutils.serialiseJSON(json_payload)).readAll())
disk.setLabel(drive.side,J["name"].."'s card. "..m["data"].."$")
disk.eject(drive.side)
