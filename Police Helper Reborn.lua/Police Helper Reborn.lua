
hello = "how are you bro? please dont crack my script bro"

script_name("Police Helper Manager")
script_author("#Northn")
script_version("1.1.1b")
script_version_number(5)
script_url("https://policehelper.ru")

local var_0_1, var_0_2 = pcall(require, "mimgui")
local var_0_3, var_0_4 = pcall(require, "PoliceHelper.fAwesome6")
local var_0_5, var_0_6 = pcall(require, "RakLua")
local var_0_7, var_0_8 = pcall(require, "PoliceHelper.mimgui_piemenu")
local var_0_9, var_0_10 = pcall(require, "MoonMonet")
local var_0_11 = require("ffi")

function main()
	local var_2_0, var_2_1, var_2_2 = os.rename(script.this.path, script.this.path)

	if not var_2_0 and var_2_2 == 13 then
		ShowMessage("Police Helper Reborn \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xE1\xFB\xF2\xFC \xE7\xE0\xEF\xF3\xF9\xE5\xED.\n\xCF\xF0\xE8\xEB\xEE\xE6\xE5\xED\xE8\xE5 \xED\xE5 \xE8\xEC\xE5\xE5\xF2 \xEF\xF0\xE0\xE2 \xE4\xEB\xFF \xE2\xE7\xE0\xE8\xEC\xEE\xE4\xE5\xE9\xF1\xF2\xE2\xE8\xFF \xF1 \xF2\xE5\xEA\xF3\xF9\xE5\xE9 \xEF\xE0\xEF\xEA\xEE\xE9: " .. getGameDirectory() .. "\n\xCD\xE5\xEE\xE1\xF5\xEE\xE4\xE8\xEC\xEE \xEF\xE5\xF0\xE5\xEC\xE5\xF1\xF2\xE8\xF2\xFC \xE8\xE3\xF0\xF3 \xE2 \xE4\xF0\xF3\xE3\xF3\xFE \xEF\xE0\xEF\xEA\xF3, \xED\xE0\xEF\xF0\xE8\xEC\xE5\xF0, \xE2 " .. getGameDirectory():sub(1, 1) .. "\\Games\\GTA San Andreas\n\n\xD2\xE5\xF5\xED\xE8\xF7\xE5\xF1\xEA\xE0\xFF \xEF\xEE\xE4\xE4\xE5\xF0\xE6\xEA\xE0 \xF1\xEA\xF0\xE8\xEF\xF2\xE0 \x97 vk.com/policehelper", 16)

		return error("Script has no permissions to manipulate with working folder (" .. getGameDirectory() .. ")\nYou should replace GTA to another folder. For example, to: " .. getGameDirectory():sub(1, 1) .. "\\Games\\GTA San Andreas")
	end

	local var_2_3 = getModuleHandle("samp.dll")

	if not var_2_3 or var_2_3 == 4294967295 then
		return error("GTA SA booted in offline mode, unloading Police Helper Manager...")
	end

	SAMP.dll = var_2_3

	if SAMP:getVersion() == "Unknown" then
		ShowMessage("Police Helper Reborn \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xE1\xFB\xF2\xFC \xE7\xE0\xEF\xF3\xF9\xE5\xED.\n\xD3 \xE2\xE0\xF1 \xE7\xE0\xEF\xF3\xF9\xE5\xED\xE0 \xED\xE5\xF1\xEE\xE2\xEC\xE5\xF1\xF2\xE8\xEC\xE0\xFF \xE2\xE5\xF0\xF1\xE8\xFF SAMP, \xF1 \xEA\xEE\xF2\xEE\xF0\xFB\xEC \xED\xE0\xF8 \xF1\xEA\xF0\xE8\xEF\xF2 \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xF4\xF3\xED\xEA\xF6\xE8\xEE\xED\xE8\xF0\xEE\xE2\xE0\xF2\xFC. \xD1\xEE\xE2\xEC\xE5\xF1\xF2\xE8\xEC\xFB\xE5 \xE2\xE5\xF0\xF1\xE8\xE8 SAMP: 0.3.7-R1, 0.3.7-R3.\n\n\xD2\xE5\xF5\xED\xE8\xF7\xE5\xF1\xEA\xE0\xFF \xEF\xEE\xE4\xE4\xE5\xF0\xE6\xEA\xE0 \xF1\xEA\xF0\xE8\xEF\xF2\xE0 \x97 vk.com/policehelper", 16)

		return error("Unsupported version of SAMP detected, unloading...")
	end

	if doesFileExist("!0AntiStealerByDarkP1xel.ASI") then
		ShowMessage("Police Helper Reborn \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xE1\xFB\xF2\xFC \xE7\xE0\xEF\xF3\xF9\xE5\xED.\n\xC2 \xEA\xEE\xF0\xED\xE5\xE2\xEE\xE9 \xEF\xE0\xEF\xEA\xE5 \xF1 \xE8\xE3\xF0\xEE\xE9 \xF1\xF3\xF9\xE5\xF1\xF2\xE2\xF3\xE5\xF2 \xF4\xE0\xE9\xEB \"!0AntiStealerByDarkP1xel.ASI\".\n\xC4\xE0\xED\xED\xFB\xE9 \xF4\xE0\xE9\xEB \xFF\xE2\xEB\xFF\xE5\xF2\xF1\xFF AntiStealer'\xEE\xEC, \xE4\xE0, \xFD\xF2\xEE \xEF\xEE\xEB\xE5\xE7\xED\xFB\xE9 \xEF\xEB\xE0\xE3\xE8\xED, \xEE\xE4\xED\xE0\xEA\xEE \xEE\xED \xE1\xEB\xEE\xEA\xE8\xF0\xF3\xE5\xF2 \xE8\xED\xF2\xE5\xF0\xED\xE5\xF2-\xF1\xEE\xE5\xE4\xE8\xED\xE5\xED\xE8\xE5 \xED\xE0\xF8\xE5\xEC\xF3 \xF1\xEA\xF0\xE8\xEF\xF2\xF3. \xD3\xE4\xE0\xEB\xE8\xF2\xE5 \xE4\xE0\xED\xED\xFB\xE9 \xF4\xE0\xE9\xEB \xE8 \xEF\xEE\xEF\xF0\xEE\xE1\xF3\xE9\xF2\xE5 \xE7\xE0\xE9\xF2\xE8 \xEF\xEE\xE2\xF2\xEE\xF0\xED\xEE \xE2 \xE8\xE3\xF0\xF3.\n\n\xD2\xE5\xF5\xED\xE8\xF7\xE5\xF1\xEA\xE0\xFF \xEF\xEE\xE4\xE4\xE5\xF0\xE6\xEA\xE0 \xF1\xEA\xF0\xE8\xEF\xF2\xE0 \x97 vk.com/policehelper", 16)

		return error("AntiStealer detected, unloading Police Helper Manager...")
	end

	if not var_0_9 then
		createDirectory("moonloader\\lib\\MoonMonet")
		wait(200)
		downloadUrlToFile("https://github.com/Northn/MoonMonet/releases/download/0.1.0/moonmonet_rs.dll", "moonloader\\lib\\MoonMonet\\moonmonet_rs.dll")
		wait(3000)
		downloadUrlToFile("https://github.com/Northn/MoonMonet/releases/download/0.1.0/init.lua", "moonloader\\lib\\MoonMonet\\init.lua")
		wait(1800)

		var_0_9, var_0_10 = pcall(require, "MoonMonet")
	end

	if not var_0_3 then
		downloadUrlToFile("https://dl.dropboxusercontent.com/s/l8p622vl6jemx5u/fAwesome6.lua?dl=1", "moonloader\\lib\\PoliceHelper\\fAwesome6.lua")
		wait(2700)

		var_0_3, var_0_4 = pcall(require, "PoliceHelper.fAwesome6")
	end

	if not var_0_1 or not var_0_3 or not var_0_5 or var_0_6.VERSION < 1.3 or not var_0_7 or not var_0_9 then
		local var_2_4 = "mimgui: " .. tostring(var_0_1) .. ", faicons 6: " .. tostring(var_0_3) .. "\nRakLua: " .. tostring(var_0_5) .. ", ver: " .. tostring(var_0_5 and var_0_6.VERSION) .. "\nmimgui Pie: " .. tostring(var_0_7) .. "\nMoonMonet: " .. tostring(var_0_9)

		if isMSVCPmissing(var_0_2) or isMSVCPmissing(var_0_8) or isMSVCPmissing(var_0_4) or isMSVCPmissing(var_0_6) or isMSVCPmissing(var_0_10) then
			RedirectToPage("Police Helper Reborn \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xE1\xFB\xF2\xFC \xE7\xE0\xEF\xF3\xF9\xE5\xED.\n\xCA\xF0\xE8\xF2\xE8\xF7\xE5\xF1\xEA\xE8 \xED\xE5\xEE\xE1\xF5\xEE\xE4\xE8\xEC\xE0\xFF \xE1\xE8\xE1\xEB\xE8\xEE\xF2\xE5\xEA\xE0 Microsoft Visual C++ 2017 (x32) \xEE\xF2\xF1\xF3\xF2\xF1\xF2\xE2\xF3\xE5\xF2.\n\n\xD3\xF1\xF2\xE0\xED\xEE\xE2\xF9\xE8\xEA \xE1\xE8\xE1\xEB\xE8\xEE\xF2\xE5\xEA\xE8 \x97 aka.ms/vs/16/release/vc_redist.x86.exe\n\xD2\xE5\xF5\xED\xE8\xF7\xE5\xF1\xEA\xE0\xFF \xEF\xEE\xE4\xE4\xE5\xF0\xE6\xEA\xE0 \xF1\xEA\xF0\xE8\xEF\xF2\xE0 \x97 vk.com/policehelper\n\n\xCF\xE5\xF0\xE5\xE9\xF2\xE8 \xED\xE0 \xF1\xE0\xE9\xF2 \xF1 \xF3\xF1\xF2\xE0\xED\xEE\xE2\xF9\xE8\xEA\xEE\xEC \xE1\xE8\xE1\xEB\xE8\xEE\xF2\xE5\xEA\xE8?", "https://aka.ms/vs/16/release/vc_redist.x86.exe")

			return error("Microsoft Visual C++ 2017 x32 doesn't exist, unloading Police Helper Manager...\nLibs states: " .. var_2_4)
		else
			RedirectToPage("Police Helper Reborn \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xE1\xFB\xF2\xFC \xE7\xE0\xEF\xF3\xF9\xE5\xED.\n\xCA\xF0\xE8\xF2\xE8\xF7\xE5\xF1\xEA\xE8 \xED\xE5\xEE\xE1\xF5\xEE\xE4\xE8\xEC\xFB\xE5 \xE1\xE8\xE1\xEB\xE8\xEE\xF2\xE5\xEA\xE8 \xEE\xF2\xF1\xF3\xF2\xF1\xF2\xE2\xF3\xFE\xF2 \xEB\xE8\xE1\xEE \xE1\xFB\xEB\xE8 \xEF\xEE\xE2\xF0\xE5\xE6\xE4\xE5\xED\xFB. \xC2\xE0\xEC \xED\xE5\xEE\xE1\xF5\xEE\xE4\xE8\xEC\xEE \xF3\xF1\xF2\xE0\xED\xEE\xE2\xE8\xF2\xFC \xEF\xF0\xE8\xEB\xEE\xE6\xE5\xED\xE8\xE5 \xF7\xE5\xF0\xE5\xE7 \xE0\xE2\xF2\xEE\xF3\xF1\xF2\xE0\xED\xEE\xE2\xF9\xE8\xEA\n" .. var_2_4 .. "\n\n\xD3\xF1\xF2\xE0\xED\xEE\xE2\xF9\xE8\xEA \x97 policehelper.ru/download\n\xCF\xEE\xE6\xE0\xEB\xF3\xE9\xF1\xF2\xE0, \xEE\xE1\xF0\xE0\xF2\xE8\xF2\xE5\xF1\xFC \xE2 \xED\xE0\xF8\xF3 \xF2\xE5\xF5.\xEF\xEE\xE4\xE4\xE5\xF0\xE6\xEA\xF3, \xE5\xF1\xEB\xE8 \xEF\xF0\xEE\xE1\xEB\xE5\xEC\xE0 \xED\xE5 \xEF\xF0\xEE\xEF\xE0\xE4\xE0\xE5\xF2.\n\xD2\xE5\xF5\xED\xE8\xF7\xE5\xF1\xEA\xE0\xFF \xEF\xEE\xE4\xE4\xE5\xF0\xE6\xEA\xE0 \xF1\xEA\xF0\xE8\xEF\xF2\xE0 \x97 vk.com/policehelper\n\n\xCF\xE5\xF0\xE5\xE9\xF2\xE8 \xED\xE0 \xF1\xE0\xE9\xF2 \xF1 \xF3\xF1\xF2\xE0\xED\xEE\xE2\xF9\xE8\xEA\xEE\xEC?", "https://policehelper.ru/download")

			return error("Some libraries doesn't exist, unloading Police Helper Manager...\nLibs states: " .. var_2_4)
		end
	end

	print("Compatibility test passed.")
	print("Installed manager version: " .. script.this.version_num .. " | " .. script.this.version)

	local var_2_5 = doesFileExist("moonloader/Police Helper Reborn/betaTester")

	print("Reborn core build type: " .. (var_2_5 and "Beta" or "Stable"))

	local var_2_6 = script.find("Police Helper Reborn") or script.load("moonloader/Police Helper Reborn/Police Helper Reborn.luac")

	print("Reborn core version: " .. (var_2_6 and var_2_6.version_num .. " | " .. var_2_6.version or "Unavailable"))
	print("Checking for updates...")

	local var_2_7 = checkUpdates()

	if var_2_7 then
		checkManagerVersion(var_2_7.manager)
		checkRebornVersion(var_2_7[var_2_5 and "beta" or "stable"], var_2_6, var_2_5)
	else
		print("Couldn't check for updates. Booting core if exists...")
		SAMP:Initialize()
		addNotif("\xCD\xE5 \xF3\xE4\xE0\xEB\xEE\xF1\xFC \xF1\xE2\xFF\xE7\xE0\xF2\xFC\xF1\xFF \xF1 \xF1\xE5\xF0\xE2\xE5\xF0\xE0\xEC\xE8 \xE4\xEB\xFF \xEF\xF0\xEE\xE2\xE5\xF0\xEA\xE8 \xED\xE0\xEB\xE8\xF7\xE8\xFF \xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE9.")

		if var_2_6 then
			var_2_6.exports.ready()
		end
	end

	print("Manager done his work. Unloading...")
end

function checkUpdates()
	local var_3_0 = math.random(1024, 4096)^2 - 10
	local var_3_1 = os.getenv("TEMP") .. "\\" .. var_3_0 .. ".txt"
	local var_3_2 = os.clock()
	local var_3_3

	downloadUrlToFile(table.concat({
		"h",
		"t",
		"t",
		"p",
		"s",
		":",
		"/",
		"/",
		"w",
		"w",
		"w",
		".",
		"d",
		"l",
		".",
		"d",
		"r",
		"o",
		"p",
		"b",
		"o",
		"x",
		"u",
		"s",
		"e",
		"r",
		"c",
		"o",
		"n",
		"t",
		"e",
		"n",
		"t",
		".",
		"c",
		"o",
		"m",
		"/",
		"s",
		"/",
		"q",
		"f",
		"6",
		"u",
		"5",
		"e",
		"8",
		"3",
		"d",
		"z",
		"v",
		"t",
		"8",
		"9",
		"7",
		"/",
		"r",
		"e",
		"b",
		"o",
		"r",
		"n",
		"_",
		"u",
		"p",
		"d",
		"a",
		"t",
		"e",
		"s",
		".",
		"j",
		"s",
		"o",
		"n",
		"?",
		"d",
		"l",
		"=",
		"1"
	}, ""), var_3_1, function(arg_4_0, arg_4_1, arg_4_2, arg_4_3)
		if arg_4_1 == 58 then
			lua_thread.create(function()
				local var_5_0

				for iter_5_0 = 0, 10 do
					var_5_0 = io.open(var_3_1, "r")

					wait(10)

					if var_5_0 then
						break
					end
				end

				if var_5_0 then
					local var_5_1 = var_5_0:read("*a")

					if var_5_1 then
						io.close(var_5_0)
						os.remove(var_3_1)

						local var_5_2 = decodeJson(var_5_1)

						if var_5_2 then
							var_3_3 = var_5_2

							return
						end
					end
				end

				var_3_3 = false
			end)
		end
	end)

	while var_3_3 == nil and os.clock() - var_3_2 < 8 do
		wait(0)
	end

	return var_3_3
end

function checkManagerVersion(arg_6_0)
	if script.this.version_num < arg_6_0.id then
		print("Manager update available. Updating...")
		downloadUrlToFile(arg_6_0.url, script.this.path, function(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
			if arg_7_1 == 58 then
				lua_thread.create(function()
					wait(50)
					print("Manager update is ready. Rebooting...")
					script.this:reload()
				end)
			end
		end)

		while true do
			wait(0)
		end
	end
end

function checkRebornVersion(arg_9_0, arg_9_1, arg_9_2)
	local var_9_0 = "moonloader\\Police Helper Reborn\\Police Helper Reborn.luac"
	local var_9_1 = false

	if not arg_9_1 or arg_9_1.version_num < arg_9_0.id or arg_9_2 and not arg_9_1.exports.beta or not arg_9_2 and arg_9_1.exports.beta then
		print("Core update available. Updating...")
		SAMP:Initialize()
		downloadUrlToFile(arg_9_0.url, var_9_0, function(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
			if arg_10_1 == 58 then
				lua_thread.create(function()
					addNotif("\xCE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5 \xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xEE. " .. (arg_9_1 and "\xCF\xE5\xF0\xE5\xE7\xE0\xEF\xF3\xF1\xEA\xE0\xE5\xEC" or "\xC7\xE0\xEF\xF3\xF1\xEA\xE0\xE5\xEC") .. " Police Helper Reborn.")
					wait(50)
					print("Core update is ready. Rebooting...")

					if arg_9_1 then
						arg_9_1:unload()
					end

					arg_9_1 = script.load(var_9_0)
					var_9_1 = true
				end)
			end
		end)
		addNotif("\xCE\xE1\xED\xE0\xF0\xF3\xE6\xE5\xED\xEE \xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5 Police Helper Reborn \xEE\xF2 {aaaaaa}" .. arg_9_0.date .. "{ffffff}. \xCE\xE1\xED\xEE\xE2\xEB\xFF\xE5\xEC\xF1\xFF...")

		if not arg_9_1 or arg_9_1.version ~= arg_9_0.name then
			addNotif("\xD2\xE5\xEA\xF3\xF9\xE0\xFF \xE2\xE5\xF0\xF1\xE8\xFF: {aaaaaa}" .. (arg_9_1 and arg_9_1.version or "\xCD\xE5\xF2") .. "{ffffff}, \xED\xEE\xE2\xE0\xFF \xE2\xE5\xF0\xF1\xE8\xFF: {aaaaaa}" .. arg_9_0.name)
		else
			addNotif("\xCE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5 \xED\xE5 \xF1\xEE\xE4\xE5\xF0\xE6\xE8\xF2 \xEA\xF0\xF3\xEF\xED\xFB\xF5 \xE8\xE7\xEC\xE5\xED\xE5\xED\xE8\xE9.")
		end

		while not var_9_1 do
			wait(0)
		end
	end

	arg_9_1.exports.ready()
end

function isMSVCPmissing(arg_12_0)
	return type(arg_12_0) == "string" and arg_12_0:find("error loading module")
end

SAMP = {
	pAddEntry_R1 = 409616,
	dll = 4294967295,
	pChat = 4294967295,
	pAddEntry_R3 = 423008,
	pChat_R1 = 2203876,
	pChat_R3 = 2549960,
	pInfo_R3 = 2549980,
	version = "",
	pInfo_R1 = 2203896,
	addEntry = function(arg_13_0, arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5)
		return
	end,
	getVersion = function()
		return
	end,
	Initialize = function()
		return
	end
}

function SAMP.getVersion(arg_16_0)
	if arg_16_0.version == "" then
		local var_16_0 = {
			[3268371] = "R1",
			[836816] = "R3"
		}
		local var_16_1 = arg_16_0.dll + var_0_11.cast("int*", arg_16_0.dll + 60)[0]

		arg_16_0.version = var_16_0[var_0_11.cast("uint32_t*", var_16_1 + 40)[0]] or "Unknown"
	end

	return arg_16_0.version
end

function SAMP.Initialize(arg_17_0)
	arg_17_0.dll = getModuleHandle("samp.dll")

	if not arg_17_0.dll or arg_17_0.dll == 4294967295 then
		error("GTA SA booted in offline mode, unloading Police Helper Manager...")
	end

	local var_17_0 = arg_17_0:getVersion()

	if var_17_0 == "Unknown" then
		ShowMessage("Police Helper Reborn \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xE1\xFB\xF2\xFC \xE7\xE0\xEF\xF3\xF9\xE5\xED.\n\xD3 \xE2\xE0\xF1 \xE7\xE0\xEF\xF3\xF9\xE5\xED\xE0 \xED\xE5\xF1\xEE\xE2\xEC\xE5\xF1\xF2\xE8\xEC\xE0\xFF \xE2\xE5\xF0\xF1\xE8\xFF SAMP, \xF1 \xEA\xEE\xF2\xEE\xF0\xFB\xEC \xED\xE0\xF8 \xF1\xEA\xF0\xE8\xEF\xF2 \xED\xE5 \xEC\xEE\xE6\xE5\xF2 \xF4\xF3\xED\xEA\xF6\xE8\xEE\xED\xE8\xF0\xEE\xE2\xE0\xF2\xFC. \xD1\xEE\xE2\xEC\xE5\xF1\xF2\xE8\xEC\xFB\xE5 \xE2\xE5\xF0\xF1\xE8\xE8 SAMP: 0.3.7-R1, 0.3.7-R3.\n\n\xD2\xE5\xF5\xED\xE8\xF7\xE5\xF1\xEA\xE0\xFF \xEF\xEE\xE4\xE4\xE5\xF0\xE6\xEA\xE0 \xF1\xEA\xF0\xE8\xEF\xF2\xE0 \x97 vk.com/policehelper", 16)
		error("Unsupported version of SAMP detected, unloading...")
	end

	local var_17_1 = 0

	while var_17_1 == 0 do
		var_17_1 = var_0_11.cast("intptr_t*", arg_17_0.dll + arg_17_0[var_17_0 == "R1" and "pInfo_R1" or "pInfo_R3"])[0]

		wait(0)
	end

	arg_17_0.pChat = var_0_11.cast("intptr_t*", arg_17_0.dll + arg_17_0[var_17_0 == "R1" and "pChat_R1" or "pChat_R3"])[0]
	arg_17_0.addEntry = var_0_11.cast("void(__thiscall *)(intptr_t this, int type, const char* szText, const char* szPrefix, uint32_t textColor, uint32_t prefixColor)", arg_17_0.dll + arg_17_0[var_17_0 == "R1" and "pAddEntry_R1" or "pAddEntry_R3"])
end

function sampAddChatMessage(arg_18_0, arg_18_1)
	SAMP.addEntry(SAMP.pChat, 4, tostring(arg_18_0), "", arg_18_1 or -1, -1)
end

function addNotif(arg_19_0)
	sampAddChatMessage("[Police Helper \xBB{E47200} Manager{0088ff}]{ffffff}: " .. tostring(arg_19_0), 35071)
end

var_0_11.cdef("    int MessageBoxA(\n        void* hWnd,\n        const char* lpText,\n        const char* lpCaption,\n        unsigned int uType\n    );\n")

function ShowMessage(arg_20_0, arg_20_1)
	local var_20_0 = var_0_11.cast("void*", readMemory(13160328, 4, false))

	var_0_11.C.MessageBoxA(var_20_0, arg_20_0, "Police Helper Reborn", arg_20_1 and arg_20_1 + 327680 or 327680)
end

function RedirectToPage(arg_21_0, arg_21_1)
	local var_21_0 = var_0_11.cast("void*", readMemory(13160328, 4, false))

	if var_0_11.C.MessageBoxA(var_21_0, arg_21_0, "Police Helper Reborn", 20) == 6 then
		os.execute("explorer \"" .. arg_21_1 .. "\"")
	end
end
