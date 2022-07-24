-- Made with <3 by Stromic (76561198387898442)

local addedPrefix = "[FastDL Scraper] Added | "
local printToConsole = true
local forcedFastDLURL = "" -- You can override the FastDL URL here.

local function addResourceRecursively(url, cur_dir)
    cur_dir = cur_dir or ""

    http.Fetch(url, function(res)
        local cur_line = ""

        local res_table = string.ToTable(res)
        local inline = false

        local assets, folders = {}, {}

        for k,v in ipairs(res_table) do
            if !inline and (res_table[k - 1] == '"' and res_table[k - 2] == "=" and res_table[k - 3] == "f") then
                if (res_table[k] == "." and res_table[k + 1] == "." and res_table[k + 2] == "/") then continue end -- This is return folders..
                if (res_table[k] == "m" and res_table[k + 1] == "a" and res_table[k + 2] == "p" and res_table[k + 3] == "s" and res_table[k + 4] == "/" and res_table[k + 5] == '"') then continue end -- Maps is auto added!
                
                inline = true
            end

            if inline and (v == '"' and res_table[k + 1] == ">") then
                inline = false
            end

            if inline then
                cur_line = cur_line..v
            end

            if !inline and cur_line != "" then
                table.insert(cur_line[#cur_line] == "/" and folders or assets, cur_line)

                cur_line = ""
            end
        end

        for k,v in ipairs(folders) do
            addResourceRecursively(url..v, cur_dir..v)
        end

        for k,v in ipairs(assets) do
            if printToConsole then print(addedPrefix..cur_dir..v) end
            resource.AddFile(cur_dir..v)
        end
    end, function(err) print(err) end)
end

timer.Simple(3, function()
    local FastDLURL = forcedFastDLURL != "" and forcedFastDLURL or GetConVar("sv_downloadurl"):GetString()

    if !FastDLURL or FastDLURL == "" then return end

    addResourceRecursively(GetConVar("sv_downloadurl"):GetString())
end)
