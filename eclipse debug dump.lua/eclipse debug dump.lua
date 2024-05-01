-- user say didnt need crk

local var_0_0 = false
local var_0_1 = false
local var_0_2 = {}
local var_0_3 = require("ffi")

function var_0_2.json()
	local var_1_0 = {}

	var_1_0._version = "0.1.2"
	var_1_0.encode = nil
	var_1_0.escape_char_map = {
		["\f"] = "f",
		["\b"] = "b",
		["\n"] = "n",
		["\t"] = "t",
		["\\"] = "\\",
		["\r"] = "r",
		["\""] = "\""
	}
	var_1_0.escape_char_map_inv = {
		["/"] = "/"
	}

	for iter_1_0, iter_1_1 in pairs(var_1_0.escape_char_map) do
		var_1_0.escape_char_map_inv[iter_1_1] = iter_1_0
	end

	function var_1_0.escape_char(arg_2_0)
		return "\\" .. (var_1_0.escape_char_map[arg_2_0] or string.format("u%04x", arg_2_0:byte()))
	end

	function var_1_0.encode_nil(arg_3_0)
		return "null"
	end

	function var_1_0.encode_table(arg_4_0, arg_4_1)
		local var_4_0 = {}

		arg_4_1 = arg_4_1 or {}

		if arg_4_1[arg_4_0] then
			error("circular reference")
		end

		arg_4_1[arg_4_0] = true

		if rawget(arg_4_0, 1) ~= nil or next(arg_4_0) == nil then
			local var_4_1 = 0

			for iter_4_0 in pairs(arg_4_0) do
				if type(iter_4_0) ~= "number" then
					error("invalid table: mixed or invalid key types" .. " > got \"" .. type(iter_4_0) .. "\"( " .. tostring(iter_4_0) .. " )")
				end

				var_4_1 = var_4_1 + 1
			end

			if var_4_1 ~= #arg_4_0 then
				error("invalid table: sparse array")
			end

			for iter_4_1, iter_4_2 in ipairs(arg_4_0) do
				table.insert(var_4_0, var_1_0.encode(iter_4_2, arg_4_1))
			end

			arg_4_1[arg_4_0] = nil

			return "[" .. table.concat(var_4_0, ",") .. "]"
		else
			for iter_4_3, iter_4_4 in pairs(arg_4_0) do
				if type(iter_4_3) ~= "string" then
					error("invalid table: mixed or invalid key types" .. " > got \"" .. type(iter_4_3) .. "\"( " .. tostring(iter_4_3) .. " )")
				end

				table.insert(var_4_0, var_1_0.encode(iter_4_3, arg_4_1) .. ":" .. var_1_0.encode(iter_4_4, arg_4_1))
			end

			arg_4_1[arg_4_0] = nil

			return "{" .. table.concat(var_4_0, ",") .. "}"
		end
	end

	function var_1_0.encode_string(arg_5_0)
		return "\"" .. arg_5_0:gsub("[%z\x01-\x1F\\\"]", var_1_0.escape_char) .. "\""
	end

	function var_1_0.encode_number(arg_6_0)
		if arg_6_0 ~= arg_6_0 or arg_6_0 <= -math.huge or arg_6_0 >= math.huge then
			error("unexpected number value '" .. tostring(arg_6_0) .. "'")
		end

		return string.format("%.14g", arg_6_0)
	end

	local var_1_1 = {
		["nil"] = var_1_0.encode_nil,
		table = var_1_0.encode_table,
		string = var_1_0.encode_string,
		number = var_1_0.encode_number,
		boolean = tostring
	}

	function var_1_0.encode(arg_7_0, arg_7_1)
		local var_7_0 = type(arg_7_0)
		local var_7_1 = var_1_1[var_7_0]

		if var_7_1 then
			return var_7_1(arg_7_0, arg_7_1)
		end

		error("unexpected type '" .. var_7_0 .. "'")
	end

	function var_1_0.json_encode(arg_8_0)
		return var_1_0.encode(arg_8_0)
	end

	var_1_0.parse = nil

	function var_1_0.create_set(...)
		local var_9_0 = {}

		for iter_9_0 = 1, select("#", ...) do
			var_9_0[select(iter_9_0, ...)] = true
		end

		return var_9_0
	end

	local var_1_2 = var_1_0.create_set(" ", "\t", "\r", "\n")
	local var_1_3 = var_1_0.create_set(" ", "\t", "\r", "\n", "]", "}", ",")
	local var_1_4 = var_1_0.create_set("\\", "/", "\"", "b", "f", "n", "r", "t", "u")
	local var_1_5 = var_1_0.create_set("true", "false", "null")

	var_1_0.literal_map = {
		["false"] = false,
		["true"] = true
	}

	function var_1_0.next_char(arg_10_0, arg_10_1, arg_10_2, arg_10_3)
		for iter_10_0 = arg_10_1, #arg_10_0 do
			if arg_10_2[arg_10_0:sub(iter_10_0, iter_10_0)] ~= arg_10_3 then
				return iter_10_0
			end
		end

		return #arg_10_0 + 1
	end

	function var_1_0.decode_error(arg_11_0, arg_11_1, arg_11_2)
		local var_11_0 = 1
		local var_11_1 = 1

		for iter_11_0 = 1, arg_11_1 - 1 do
			var_11_1 = var_11_1 + 1

			if arg_11_0:sub(iter_11_0, iter_11_0) == "\n" then
				var_11_0 = var_11_0 + 1
				var_11_1 = 1
			end
		end

		error(string.format("%s at line %d col %d", arg_11_2, var_11_0, var_11_1))
	end

	function var_1_0.codepoint_to_utf8(arg_12_0)
		local var_12_0 = math.floor

		if arg_12_0 <= 127 then
			return string.char(arg_12_0)
		elseif arg_12_0 <= 2047 then
			return string.char(var_12_0(arg_12_0 / 64) + 192, arg_12_0 % 64 + 128)
		elseif arg_12_0 <= 65535 then
			return string.char(var_12_0(arg_12_0 / 4096) + 224, var_12_0(arg_12_0 % 4096 / 64) + 128, arg_12_0 % 64 + 128)
		elseif arg_12_0 <= 1114111 then
			return string.char(var_12_0(arg_12_0 / 262144) + 240, var_12_0(arg_12_0 % 262144 / 4096) + 128, var_12_0(arg_12_0 % 4096 / 64) + 128, arg_12_0 % 64 + 128)
		end

		error(string.format("invalid unicode codepoint '%x'", arg_12_0))
	end

	function var_1_0.parse_unicode_escape(arg_13_0)
		local var_13_0 = tonumber(arg_13_0:sub(1, 4), 16)
		local var_13_1 = tonumber(arg_13_0:sub(7, 10), 16)

		if var_13_1 then
			return var_1_0.codepoint_to_utf8((var_13_0 - 55296) * 1024 + (var_13_1 - 56320) + 65536)
		else
			return var_1_0.codepoint_to_utf8(var_13_0)
		end
	end

	function var_1_0.parse_string(arg_14_0, arg_14_1)
		local var_14_0 = ""
		local var_14_1 = arg_14_1 + 1
		local var_14_2 = var_14_1

		while var_14_1 <= #arg_14_0 do
			local var_14_3 = arg_14_0:byte(var_14_1)

			if var_14_3 < 32 then
				var_1_0.decode_error(arg_14_0, var_14_1, "control character in string")
			elseif var_14_3 == 92 then
				var_14_0 = var_14_0 .. arg_14_0:sub(var_14_2, var_14_1 - 1)
				var_14_1 = var_14_1 + 1

				local var_14_4 = arg_14_0:sub(var_14_1, var_14_1)

				if var_14_4 == "u" then
					local var_14_5 = arg_14_0:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", var_14_1 + 1) or arg_14_0:match("^%x%x%x%x", var_14_1 + 1) or var_1_0.decode_error(arg_14_0, var_14_1 - 1, "invalid unicode escape in string")

					var_14_0 = var_14_0 .. var_1_0.parse_unicode_escape(var_14_5)
					var_14_1 = var_14_1 + #var_14_5
				else
					if not var_1_4[var_14_4] then
						var_1_0.decode_error(arg_14_0, var_14_1 - 1, "invalid escape char '" .. var_14_4 .. "' in string")
					end

					var_14_0 = var_14_0 .. var_1_0.escape_char_map_inv[var_14_4]
				end

				var_14_2 = var_14_1 + 1
			elseif var_14_3 == 34 then
				var_14_0 = var_14_0 .. arg_14_0:sub(var_14_2, var_14_1 - 1)

				return var_14_0, var_14_1 + 1
			end

			var_14_1 = var_14_1 + 1
		end

		var_1_0.decode_error(arg_14_0, arg_14_1, "expected closing quote for string")
	end

	function var_1_0.parse_number(arg_15_0, arg_15_1)
		local var_15_0 = var_1_0.next_char(arg_15_0, arg_15_1, var_1_3)
		local var_15_1 = arg_15_0:sub(arg_15_1, var_15_0 - 1)
		local var_15_2 = tonumber(var_15_1)

		if not var_15_2 then
			var_1_0.decode_error(arg_15_0, arg_15_1, "invalid number '" .. var_15_1 .. "'")
		end

		return var_15_2, var_15_0
	end

	function var_1_0.parse_literal(arg_16_0, arg_16_1)
		local var_16_0 = var_1_0.next_char(arg_16_0, arg_16_1, var_1_3)
		local var_16_1 = arg_16_0:sub(arg_16_1, var_16_0 - 1)

		if not var_1_5[var_16_1] then
			var_1_0.decode_error(arg_16_0, arg_16_1, "invalid literal '" .. var_16_1 .. "'")
		end

		return var_1_0.literal_map[var_16_1], var_16_0
	end

	function var_1_0.parse_array(arg_17_0, arg_17_1)
		local var_17_0 = {}
		local var_17_1 = 1

		arg_17_1 = arg_17_1 + 1

		while true do
			local var_17_2

			arg_17_1 = var_1_0.next_char(arg_17_0, arg_17_1, var_1_2, true)

			if arg_17_0:sub(arg_17_1, arg_17_1) == "]" then
				arg_17_1 = arg_17_1 + 1

				break
			end

			var_17_0[var_17_1], arg_17_1 = var_1_0.parse(arg_17_0, arg_17_1)
			var_17_1 = var_17_1 + 1
			arg_17_1 = var_1_0.next_char(arg_17_0, arg_17_1, var_1_2, true)

			local var_17_3 = arg_17_0:sub(arg_17_1, arg_17_1)

			arg_17_1 = arg_17_1 + 1

			if var_17_3 == "]" then
				break
			end

			if var_17_3 ~= "," then
				var_1_0.decode_error(arg_17_0, arg_17_1, "expected ']' or ','")
			end
		end

		return var_17_0, arg_17_1
	end

	function var_1_0.parse_object(arg_18_0, arg_18_1)
		local var_18_0 = {}

		arg_18_1 = arg_18_1 + 1

		while true do
			local var_18_1
			local var_18_2

			arg_18_1 = var_1_0.next_char(arg_18_0, arg_18_1, var_1_2, true)

			if arg_18_0:sub(arg_18_1, arg_18_1) == "}" then
				arg_18_1 = arg_18_1 + 1

				break
			end

			if arg_18_0:sub(arg_18_1, arg_18_1) ~= "\"" then
				var_1_0.decode_error(arg_18_0, arg_18_1, "expected string for key")
			end

			local var_18_3

			var_18_3, arg_18_1 = var_1_0.parse(arg_18_0, arg_18_1)
			arg_18_1 = var_1_0.next_char(arg_18_0, arg_18_1, var_1_2, true)

			if arg_18_0:sub(arg_18_1, arg_18_1) ~= ":" then
				var_1_0.decode_error(arg_18_0, arg_18_1, "expected ':' after key")
			end

			arg_18_1 = var_1_0.next_char(arg_18_0, arg_18_1 + 1, var_1_2, true)
			var_18_0[var_18_3], arg_18_1 = var_1_0.parse(arg_18_0, arg_18_1)
			arg_18_1 = var_1_0.next_char(arg_18_0, arg_18_1, var_1_2, true)

			local var_18_4 = arg_18_0:sub(arg_18_1, arg_18_1)

			arg_18_1 = arg_18_1 + 1

			if var_18_4 == "}" then
				break
			end

			if var_18_4 ~= "," then
				var_1_0.decode_error(arg_18_0, arg_18_1, "expected '}' or ','")
			end
		end

		return var_18_0, arg_18_1
	end

	var_1_0.char_func_map = {
		["\""] = var_1_0.parse_string,
		["0"] = var_1_0.parse_number,
		["1"] = var_1_0.parse_number,
		["2"] = var_1_0.parse_number,
		["3"] = var_1_0.parse_number,
		["4"] = var_1_0.parse_number,
		["5"] = var_1_0.parse_number,
		["6"] = var_1_0.parse_number,
		["7"] = var_1_0.parse_number,
		["8"] = var_1_0.parse_number,
		["9"] = var_1_0.parse_number,
		["-"] = var_1_0.parse_number,
		t = var_1_0.parse_literal,
		f = var_1_0.parse_literal,
		n = var_1_0.parse_literal,
		["["] = var_1_0.parse_array,
		["{"] = var_1_0.parse_object
	}

	function var_1_0.parse(arg_19_0, arg_19_1)
		local var_19_0 = arg_19_0:sub(arg_19_1, arg_19_1)
		local var_19_1 = var_1_0.char_func_map[var_19_0]

		if var_19_1 then
			return var_19_1(arg_19_0, arg_19_1)
		end

		var_1_0.decode_error(arg_19_0, arg_19_1, "unexpected character '" .. var_19_0 .. "'")
	end

	function var_1_0.json_parse(arg_20_0)
		if type(arg_20_0) ~= "string" then
			error("expected argument of type string, got " .. type(arg_20_0))
		end

		local var_20_0, var_20_1 = var_1_0.parse(arg_20_0, var_1_0.next_char(arg_20_0, 1, var_1_2, true))
		local var_20_2 = var_1_0.next_char(arg_20_0, var_20_1, var_1_2, true)

		if var_20_2 <= #arg_20_0 then
			var_1_0.decode_error(arg_20_0, var_20_2, "trailing garbage")
		end

		return var_20_0
	end

	return var_1_0
end

function var_0_2.filesystem()
	local var_21_0 = {
		raw_fn = {},
		filesystem = memory.create_interface("filesystem_stdio.dll", "VBaseFileSystem011")
	}

	var_21_0.filesystem_class = var_0_3.cast(var_0_3.typeof("void***"), var_21_0.filesystem)
	var_21_0.filesystem_vftbl = var_21_0.filesystem_class[0]
	var_21_0.raw_fn.read_file = var_0_3.cast("int (__thiscall*)(void*, void*, int, void*)", var_21_0.filesystem_vftbl[0])
	var_21_0.raw_fn.write_file = var_0_3.cast("int (__thiscall*)(void*, void const*, int, void*)", var_21_0.filesystem_vftbl[1])
	var_21_0.raw_fn.open_file = var_0_3.cast("void* (__thiscall*)(void*, const char*, const char*, const char*)", var_21_0.filesystem_vftbl[2])
	var_21_0.raw_fn.close_file = var_0_3.cast("void (__thiscall*)(void*, void*)", var_21_0.filesystem_vftbl[3])
	var_21_0.raw_fn.get_file_size = var_0_3.cast("unsigned int (__thiscall*)(void*, void*)", var_21_0.filesystem_vftbl[7])
	var_21_0.raw_fn.file_exists = var_0_3.cast("bool (__thiscall*)(void*, const char*, const char*)", var_21_0.filesystem_vftbl[10])
	var_21_0.full_filesystem = memory.create_interface("filesystem_stdio.dll", "VFileSystem017")
	var_21_0.full_filesystem_class = var_0_3.cast(var_0_3.typeof("void***"), var_21_0.full_filesystem)
	var_21_0.full_filesystem_vftbl = var_21_0.full_filesystem_class[0]
	var_21_0.raw_fn.add_search_path = var_0_3.cast("void (__thiscall*)(void*, const char*, const char*, int)", var_21_0.full_filesystem_vftbl[11])
	var_21_0.raw_fn.remove_search_path = var_0_3.cast("bool (__thiscall*)(void*, const char*, const char*)", var_21_0.full_filesystem_vftbl[12])
	var_21_0.raw_fn.remove_file = var_0_3.cast("void (__thiscall*)(void*, const char*, const char*)", var_21_0.full_filesystem_vftbl[20])
	var_21_0.raw_fn.rename_file = var_0_3.cast("bool (__thiscall*)(void*, const char*, const char*, const char*)", var_21_0.full_filesystem_vftbl[21])
	var_21_0.raw_fn.create_dir_hierarchy = var_0_3.cast("void (__thiscall*)(void*, const char*, const char*)", var_21_0.full_filesystem_vftbl[22])
	var_21_0.raw_fn.is_directory = var_0_3.cast("bool (__thiscall*)(void*, const char*, const char*)", var_21_0.full_filesystem_vftbl[23])
	var_21_0.raw_fn.find_first = var_0_3.cast("const char* (__thiscall*)(void*, const char*, int*)", var_21_0.full_filesystem_vftbl[32])
	var_21_0.raw_fn.find_next = var_0_3.cast("const char* (__thiscall*)(void*, int)", var_21_0.full_filesystem_vftbl[33])
	var_21_0.raw_fn.find_is_directory = var_0_3.cast("bool (__thiscall*)(void*, int)", var_21_0.full_filesystem_vftbl[34])
	var_21_0.raw_fn.find_close = var_0_3.cast("void (__thiscall*)(void*, int)", var_21_0.full_filesystem_vftbl[35])
	var_21_0.MODES = {
		["r+"] = "r+",
		a = "a",
		["rb+"] = "rb+",
		r = "r",
		w = "w",
		["ab+"] = "ab+",
		["wb+"] = "wb+",
		wb = "wb",
		["w+"] = "w+",
		ab = "ab",
		["a+"] = "a+",
		rb = "rb"
	}
	var_21_0.fn = {}
	var_21_0.fn.__index = var_21_0.fn

	function var_21_0.fn.exists(arg_22_0, arg_22_1)
		return var_21_0.raw_fn.file_exists(var_21_0.filesystem_class, arg_22_0, arg_22_1)
	end

	function var_21_0.fn.rename(arg_23_0, arg_23_1, arg_23_2)
		var_21_0.raw_fn.rename_file(var_21_0.full_filesystem_class, arg_23_0, arg_23_1, arg_23_2)
	end

	function var_21_0.fn.remove(arg_24_0, arg_24_1)
		var_21_0.raw_fn.remove_file(var_21_0.full_filesystem_class, arg_24_0, arg_24_1)
	end

	function var_21_0.fn.create_directory(arg_25_0, arg_25_1)
		var_21_0.raw_fn.create_dir_hierarchy(var_21_0.full_filesystem_class, arg_25_0, arg_25_1)
	end

	function var_21_0.fn.is_directory(arg_26_0, arg_26_1)
		return var_21_0.raw_fn.is_directory(var_21_0.full_filesystem_class, arg_26_0, arg_26_1)
	end

	function var_21_0.fn.find_first(arg_27_0)
		local var_27_0 = var_0_3.new("int[1]")
		local var_27_1 = var_21_0.raw_fn.find_first(var_21_0.full_filesystem_class, arg_27_0, var_27_0)

		if var_27_1 == var_0_3.NULL then
			return nil
		end

		return var_27_0, var_0_3.string(var_27_1)
	end

	function var_21_0.fn.find_next(arg_28_0)
		local var_28_0 = var_21_0.raw_fn.find_next(var_21_0.full_filesystem_class, arg_28_0)

		if var_28_0 == var_0_3.NULL then
			return nil
		end

		return var_0_3.string(var_28_0)
	end

	function var_21_0.fn.find_is_directory(arg_29_0)
		return var_21_0.raw_fn.find_is_directory(var_21_0.full_filesystem_class, arg_29_0)
	end

	function var_21_0.fn.open(arg_30_0, arg_30_1, arg_30_2)
		if not var_21_0.MODES[arg_30_1] then
			error("Invalid mode!")
		end

		return (setmetatable({
			file = arg_30_0,
			mode = arg_30_1,
			path_id = arg_30_2,
			handle = var_21_0.raw_fn.open_file(var_21_0.filesystem_class, arg_30_0, arg_30_1, arg_30_2)
		}, var_21_0.fn))
	end

	function var_21_0.fn.get_size(arg_31_0)
		return var_21_0.raw_fn.get_file_size(var_21_0.filesystem_class, arg_31_0.handle)
	end

	function var_21_0.fn.write(arg_32_0, arg_32_1)
		var_21_0.raw_fn.write_file(var_21_0.filesystem_class, arg_32_1, #arg_32_1, arg_32_0.handle)
	end

	function var_21_0.fn.read(arg_33_0)
		local var_33_0 = arg_33_0:get_size()
		local var_33_1 = var_0_3.new("char[?]", var_33_0 + 1)

		var_21_0.raw_fn.read_file(var_21_0.filesystem_class, var_33_1, var_33_0, arg_33_0.handle)

		return var_0_3.string(var_33_1)
	end

	function var_21_0.fn.close(arg_34_0)
		var_21_0.raw_fn.close_file(var_21_0.filesystem_class, arg_34_0.handle)
	end

	return var_21_0
end

function var_0_2.search_files()
	local var_35_0 = {
		full_filesystem = memory.create_interface("filesystem_stdio.dll", "VFileSystem017")
	}

	var_35_0.call = var_0_3.cast("void***", var_35_0.full_filesystem)

	var_0_3.cdef("        typedef void (__thiscall* AddSearchPath)(void*, const char*, const char*);\n        typedef void (__thiscall* RemoveSearchPaths)(void*, const char*);\n        typedef const char* (__thiscall* FindNext)(void*, int);\n        typedef bool (__thiscall* FindIsDirectory)(void*, int);\n        typedef void (__thiscall* FindClose)(void*, int);\n        typedef const char* (__thiscall* FindFirstEx)(void*, const char*, const char*, int*);\n        typedef long (__thiscall* GetFileTime)(void*, const char*, const char*);\n    ")

	var_35_0.fn = {}
	var_35_0.fn.add_search_path = var_0_3.cast("AddSearchPath", var_35_0.call[0][11])
	var_35_0.fn.remove_search_paths = var_0_3.cast("RemoveSearchPaths", var_35_0.call[0][14])
	var_35_0.fn.find_next = var_0_3.cast("FindNext", var_35_0.call[0][33])
	var_35_0.fn.find_is_directory = var_0_3.cast("FindIsDirectory", var_35_0.call[0][34])
	var_35_0.fn.find_close = var_0_3.cast("FindClose", var_35_0.call[0][35])
	var_35_0.fn.find_first_ex = var_0_3.cast("FindFirstEx", var_35_0.call[0][36])

	function var_35_0.fn.list_files(arg_36_0)
		local var_36_0 = var_0_3.new("int[1]")

		var_35_0.fn.remove_search_paths(var_35_0.call, "eclipse_temp")
		var_35_0.fn.add_search_path(var_35_0.call, arg_36_0, "eclipse_temp")

		local var_36_1 = {}
		local var_36_2 = var_35_0.fn.find_first_ex(var_35_0.call, "*", "eclipse_temp", var_36_0)

		while var_36_2 ~= nil do
			local var_36_3 = var_0_3.string(var_36_2)
			local var_36_4 = var_36_3:sub(-4, -1) == ".ecl"

			if var_35_0.fn.find_is_directory(var_35_0.call, var_36_0[0]) == false and not var_36_3:find("banmdls[.]res") and var_36_4 then
				table.insert(var_36_1, var_36_3)
			end

			var_36_2 = var_35_0.fn.find_next(var_35_0.call, var_36_0[0])
		end

		var_35_0.fn.find_close(var_35_0.call, var_36_0[0])

		return var_36_1
	end

	return var_35_0
end

function var_0_2.animated_text()
	local var_37_0 = {
		hslToRgb = function(arg_38_0, arg_38_1, arg_38_2)
			if arg_38_1 == 0 then
				return arg_38_2, arg_38_2, arg_38_2
			end

			local function var_38_0(arg_39_0, arg_39_1, arg_39_2)
				if arg_39_2 < 0 then
					arg_39_2 = arg_39_2 + 1
				end

				if arg_39_2 > 1 then
					arg_39_2 = arg_39_2 - 1
				end

				if arg_39_2 < 0.16667 then
					return arg_39_0 + (arg_39_1 - arg_39_0) * 6 * arg_39_2
				end

				if arg_39_2 < 0.5 then
					return arg_39_1
				end

				if arg_39_2 < 0.66667 then
					return arg_39_0 + (arg_39_1 - arg_39_0) * (0.66667 - arg_39_2) * 6
				end

				return arg_39_0
			end

			local var_38_1 = arg_38_2 < 0.5 and arg_38_2 * (1 + arg_38_1) or arg_38_2 + arg_38_1 - arg_38_2 * arg_38_1
			local var_38_2 = 2 * arg_38_2 - var_38_1

			return var_38_0(var_38_2, var_38_1, arg_38_0 + 0.33334), var_38_0(var_38_2, var_38_1, arg_38_0), var_38_0(var_38_2, var_38_1, arg_38_0 - 0.33334)
		end,
		rgbToHsl = function(arg_40_0, arg_40_1, arg_40_2)
			local var_40_0 = math.max(arg_40_0, arg_40_1, arg_40_2)
			local var_40_1 = math.min(arg_40_0, arg_40_1, arg_40_2)
			local var_40_2 = var_40_0 + var_40_1
			local var_40_3 = var_40_2 / 2

			if var_40_0 == var_40_1 then
				return 0, 0, var_40_3
			end

			local var_40_4 = var_40_3
			local var_40_5 = var_40_3
			local var_40_6 = var_40_0 - var_40_1
			local var_40_7 = var_40_5 > 0.5 and var_40_6 / (2 - var_40_2) or var_40_6 / var_40_2

			if var_40_0 == arg_40_0 then
				var_40_3 = (arg_40_1 - var_40_2) / var_40_6 + (arg_40_1 < var_40_2 and 6 or 0)
			elseif var_40_0 == arg_40_1 then
				var_40_3 = (var_40_2 - arg_40_0) / var_40_6 + 2
			elseif var_40_0 == var_40_2 then
				var_40_3 = (arg_40_0 - arg_40_1) / var_40_6 + 4
			end

			return var_40_3 * 0.16667, var_40_7, var_40_5
		end,
		lerp = function(arg_41_0, arg_41_1, arg_41_2)
			return arg_41_0 + (arg_41_1 - arg_41_0) * arg_41_2
		end
	}

	var_37_0.loop_delay = 2
	var_37_0.animated_text_texts = {}

	function var_37_0.render(arg_42_0, arg_42_1, arg_42_2, arg_42_3, arg_42_4, arg_42_5)
		if not type(arg_42_0) ~= "string" then
			tostring(arg_42_0)
		end

		if not var_37_0[arg_42_0] then
			var_37_0[arg_42_0] = {}
			var_37_0[arg_42_0].inverted_animations = math.abs(arg_42_5) / arg_42_5
			var_37_0[arg_42_0].last_loop = 0
			var_37_0[arg_42_0].iter = 1

			for iter_42_0 = 1, #arg_42_2 do
				var_37_0[arg_42_0][iter_42_0] = {
					time = 0,
					inverted = false,
					time_delay = 0,
					offset = 0,
					letter = arg_42_2:sub(iter_42_0, iter_42_0)
				}
			end
		end

		if var_37_0[arg_42_0].iter > #arg_42_2 then
			var_37_0[arg_42_0].iter = 1
			var_37_0[arg_42_0].last_loop = global_vars.real_time()
		end

		if var_37_0[arg_42_0].last_loop + var_37_0.loop_delay > global_vars.real_time() then
			render.text(arg_42_1, arg_42_2, arg_42_3, arg_42_4)

			return
		end

		local var_42_0 = var_37_0[arg_42_0]
		local var_42_1 = 0

		for iter_42_1 = 1, #var_42_0 do
			local var_42_2 = var_42_0[iter_42_1]

			if var_37_0[arg_42_0].iter == iter_42_1 then
				if var_42_2.offset <= math.abs(arg_42_5) and not var_42_2.inverted then
					var_42_2.offset = var_37_0.lerp(var_42_2.offset, math.abs(arg_42_5 + arg_42_5 / 5), 0.1)
				else
					var_42_2.inverted = true
				end

				if var_42_2.offset >= 0 and var_42_2.inverted then
					var_42_2.offset = var_37_0.lerp(var_42_2.offset, -1, 0.1)

					if var_42_2.offset <= 0 then
						var_42_2.inverted = false
						var_37_0[arg_42_0].iter = var_37_0[arg_42_0].iter + 1
						var_42_2.offset = 0
					end
				end
			end

			local var_42_3 = {
				var_37_0.rgbToHsl(arg_42_4.r, arg_42_4.g, arg_42_4.b)
			}

			var_42_3[1] = var_42_3[1] + var_42_2.offset / 200

			local var_42_4 = {
				var_37_0.hslToRgb(var_42_3[1], var_42_3[2], var_42_3[3])
			}
			local var_42_5 = var_42_2.offset > 0 and color_t.new(math.floor(var_42_4[1]), math.floor(var_42_4[2]), math.floor(var_42_4[3]), arg_42_4.a) or arg_42_4

			render.text(arg_42_1, var_42_2.letter, arg_42_3 + vec2_t.new(var_42_1, var_37_0[arg_42_0].inverted_animations * var_42_2.offset), var_42_5)

			var_42_1 = var_42_1 + render.get_text_size(arg_42_1, var_42_2.letter).x
		end
	end

	return var_37_0
end

local var_0_4 = var_0_2.json()
local var_0_5 = var_0_2.filesystem()
local var_0_6 = var_0_2.search_files()
local var_0_7 = var_0_2.animated_text()
local var_0_8 = var_0_1 and require("menu") or (function()
	local var_43_0 = e_keys
	local var_43_1 = input
	local var_43_2 = render
	local var_43_3 = vec2_t
	local var_43_4 = color_t
	local var_43_5 = callbacks
	local var_43_6 = e_callbacks
	local var_43_7 = e_font_flags
	local var_43_8 = menu

	unpack = table.unpack == nil and unpack or table.unpack

	local var_43_9 = {
		accent = var_43_8.find("misc", "main", "personalization", "accent color")[2]
	}
	local var_43_10 = {
		primordial_outline = var_43_2.load_image_buffer("<svg width=\"3414\" height=\"5915\" viewBox=\"0 0 3414 5915\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n        <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M684.299 1722.07C-174.968 549.792 1334.88 3.54513 1334.88 3.54513C1125.91 -13.8695 889.271 59.6302 723.653 126.472C525.728 206.352 348.715 332.953 217.537 501.321C-3.21193 784.656 -22.6679 1082.47 16.4921 1315.11C51.9281 1525.64 146.211 1721.43 280.625 1887.28C598.725 2279.79 1076.75 2695.13 1386.3 2948.27C1007.9 3252.6 395.303 3774.84 188.732 4121.88C188.732 4121.88 -351.377 4944.32 397.412 5588.77C397.412 5588.77 827.044 5901.79 1342.6 5914.06C1342.6 5914.06 -1.53345 5472.15 556.989 4373.52C556.989 4373.52 900.696 3735.21 1654.21 3233.91C1671.95 3222.1 1689.55 3210.1 1707 3197.89C1724.45 3210.1 1742.05 3222.1 1759.79 3233.91C2513.31 3735.21 2857.01 4373.52 2857.01 4373.52C3415.53 5472.15 2071.4 5914.06 2071.4 5914.06C2586.96 5901.79 3016.59 5588.77 3016.59 5588.77C3765.38 4944.32 3225.27 4121.88 3225.27 4121.88C3018.7 3774.84 2406.1 3252.6 2027.7 2948.27C2337.25 2695.13 2815.28 2279.79 3133.37 1887.28C3267.79 1721.43 3362.07 1525.64 3397.51 1315.11C3436.67 1082.47 3417.21 784.656 3196.46 501.321C3065.29 332.953 2888.27 206.352 2690.35 126.472C2524.73 59.6302 2288.09 -13.8695 2079.12 3.54513C2079.12 3.54513 3588.97 549.792 2729.7 1722.07C2729.7 1722.07 2455.56 2154.61 1707 2697.99C958.437 2154.61 684.299 1722.07 684.299 1722.07ZM1707 2697.99C1706.29 2698.51 1705.58 2699.03 1704.87 2699.54C1704.13 2700.08 1703.39 2700.61 1702.65 2701.15C1701.3 2702.13 1699.94 2703.11 1698.59 2704.09C1698.59 2704.09 1570.06 2800.49 1386.3 2948.27C1468.95 3015.86 1539.6 3071.88 1591.98 3112.82C1629.57 3142.2 1667.92 3170.56 1707 3197.89C1746.08 3170.56 1784.43 3142.2 1822.02 3112.82C1874.4 3071.88 1945.05 3015.86 2027.7 2948.27C1843.95 2800.49 1715.42 2704.09 1715.42 2704.09C1712.6 2702.06 1709.8 2700.03 1707 2697.99Z\" fill=\"#D7D7D7\"/>\n        <path d=\"M1707 2697.99L1704.87 2699.54L1702.65 2701.15C1701.3 2702.13 1699.94 2703.11 1698.59 2704.09C1698.59 2704.09 1570.06 2800.49 1386.3 2948.27C1468.95 3015.86 1539.6 3071.88 1591.98 3112.82C1629.57 3142.2 1667.92 3170.56 1707 3197.89C1746.08 3170.56 1784.43 3142.2 1822.02 3112.82C1874.4 3071.88 1945.05 3015.86 2027.7 2948.27C1843.95 2800.49 1715.42 2704.09 1715.42 2704.09C1712.6 2702.06 1709.8 2700.03 1707 2697.99Z\" fill=\"#D7D7D7\"/>\n        </svg>"),
		primordial_inside = var_43_2.load_image_buffer("<svg width=\"3414\" height=\"5915\" viewBox=\"0 0 3414 5915\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n        <path d=\"M839.196 1488.69C831.596 1469.89 836.03 1460.19 839.196 1457.69C845.196 1450.49 874.363 1468.02 888.196 1477.69C1146.7 1613.69 1582.7 1676.69 1777.7 1674.19C1933.7 1672.19 2340.7 1656.36 2524.7 1648.69C2530.3 1649.49 2532.03 1656.36 2532.2 1659.69C2514.7 1766.69 2220.7 2088.69 2151.7 2146.19C2082.7 2203.69 1750.7 2468.69 1748.7 2471.19C1746.7 2473.69 1745.2 2474.69 1738.7 2475.19C1733.5 2475.59 1729.86 2472.69 1728.7 2471.19L1350.2 2146.19C1164.2 2005.69 957.696 1710.69 919.196 1649.69C880.696 1588.69 848.696 1512.19 839.196 1488.69Z\" fill=\"#FFFFFF\"/>\n        <path d=\"M1849 4883.5C1805 4822.3 1785.33 4720 1781 4676.5C1675 4848.5 1568.17 4968.5 1528 5007C1486.83 5053.17 1369.8 5164.8 1231 5242C1057.5 5338.5 912 5335.5 863.5 5337C824.7 5338.2 826.667 5359.5 832.5 5370C991.5 5569 1364 5780.5 1741.5 5767.5C2119 5754.5 2445 5484 2518.5 5394C2592 5304 2568 5288.5 2562 5272.5C2556 5256.5 2484 5212 2335 5164C2186 5116 2126.5 5102 2047 5068.5C1967.5 5035 1904 4960 1849 4883.5Z\" fill=\"#FFFFFF\"/>\n        </svg>")
	}
	local var_43_11 = var_43_8.is_open
	local var_43_12 = {
		out_exponent = function(arg_44_0)
			return arg_44_0 == 1 and 1 or 1 - 2^(-10 * arg_44_0)
		end
	}
	local var_43_13 = {
		combo = 3,
		multicombo = 4,
		list = 9,
		separator = 8,
		checkbox = 1,
		button = 11,
		text = 10,
		slider = 2,
		keybind = 6,
		text_input = 5,
		colorpicker = 7
	}
	local var_43_14 = {
		[var_43_13.checkbox] = "checkbox",
		[var_43_13.slider] = "slider",
		[var_43_13.combo] = "combo",
		[var_43_13.multicombo] = "multicombo",
		[var_43_13.text_input] = "text_input",
		[var_43_13.keybind] = "keybind",
		[var_43_13.colorpicker] = "colorpicker",
		[var_43_13.separator] = "separator",
		[var_43_13.list] = "list",
		[var_43_13.text] = "text",
		[var_43_13.button] = "button"
	}

	function table.shallow_has_value(arg_45_0, arg_45_1)
		for iter_45_0, iter_45_1 in pairs(arg_45_0) do
			if iter_45_1 == arg_45_1 then
				return true
			end
		end

		return false
	end

	function table.shallow_find(arg_46_0, arg_46_1)
		for iter_46_0, iter_46_1 in pairs(arg_46_0) do
			if iter_46_1 == arg_46_1 then
				return iter_46_0
			end
		end

		return nil
	end

	function math.clamp(arg_47_0, arg_47_1, arg_47_2)
		if arg_47_0 < arg_47_1 then
			return arg_47_1
		elseif arg_47_2 < arg_47_0 then
			return arg_47_2
		end

		return arg_47_0
	end

	local function var_43_15(arg_48_0)
		local var_48_0 = arg_48_0 / 360
		local var_48_1 = 0
		local var_48_2 = 0
		local var_48_3 = 0

		if var_48_0 < 0.16666666666666666 then
			var_48_1 = 1
			var_48_2 = var_48_0 * 6
		elseif var_48_0 < 0.3333333333333333 then
			var_48_1 = 1 - (var_48_0 - 0.16666666666666666) * 6
			var_48_2 = 1
		elseif var_48_0 < 0.5 then
			var_48_2 = 1
			var_48_3 = (var_48_0 - 0.3333333333333333) * 6
		elseif var_48_0 < 0.6666666666666666 then
			var_48_2 = 1 - (var_48_0 - 0.5) * 6
			var_48_3 = 1
		elseif var_48_0 < 0.8333333333333334 then
			var_48_1 = (var_48_0 - 0.6666666666666666) * 6
			var_48_3 = 1
		else
			var_48_1 = 1
			var_48_3 = 1 - (var_48_0 - 0.8333333333333334) * 6
		end

		return var_43_4.new(math.floor(var_48_1 * 255), math.floor(var_48_2 * 255), math.floor(var_48_3 * 255))
	end

	local function var_43_16(arg_49_0)
		return string.format("#%02X%02X%02X%02X", arg_49_0.r, arg_49_0.g, arg_49_0.b, arg_49_0.a)
	end

	local function var_43_17(arg_50_0)
		local var_50_0 = 0
		local var_50_1 = 0
		local var_50_2 = 0
		local var_50_3 = arg_50_0.r / 255
		local var_50_4 = arg_50_0.g / 255
		local var_50_5 = arg_50_0.b / 255
		local var_50_6 = math.max(var_50_3, var_50_4, var_50_5)
		local var_50_7 = math.min(var_50_3, var_50_4, var_50_5)
		local var_50_8 = var_50_6
		local var_50_9 = var_50_6 == 0 and 0 or (var_50_6 - var_50_7) / var_50_6

		if var_50_6 == var_50_7 then
			var_50_0 = 0
		else
			local var_50_10 = var_50_6 - var_50_7

			if var_50_6 == var_50_3 then
				var_50_0 = (var_50_4 - var_50_5) / var_50_10
			elseif var_50_6 == var_50_4 then
				var_50_0 = 2 + (var_50_5 - var_50_3) / var_50_10
			elseif var_50_6 == var_50_5 then
				var_50_0 = 4 + (var_50_3 - var_50_4) / var_50_10
			end

			var_50_0 = var_50_0 * 60

			if var_50_0 < 0 then
				var_50_0 = var_50_0 + 360
			end
		end

		return var_50_0, var_50_9, var_50_8
	end

	local function var_43_18(arg_51_0, arg_51_1, arg_51_2)
		local var_51_0 = {
			g = 0,
			b = 0,
			r = 0
		}

		if arg_51_1 == 0 then
			var_51_0.r = arg_51_2 * 255
			var_51_0.g = arg_51_2 * 255
			var_51_0.b = arg_51_2 * 255
		else
			local var_51_1 = arg_51_0 == 360 and 0 or arg_51_0
			local var_51_2 = math.floor(var_51_1 / 60)
			local var_51_3 = var_51_1 / 60 - var_51_2
			local var_51_4 = arg_51_2 * (1 - arg_51_1)
			local var_51_5 = arg_51_2 * (1 - arg_51_1 * var_51_3)
			local var_51_6 = arg_51_2 * (1 - arg_51_1 * (1 - var_51_3))

			if var_51_2 == 0 then
				var_51_0.r = arg_51_2 * 255
				var_51_0.g = var_51_6 * 255
				var_51_0.b = var_51_4 * 255
			elseif var_51_2 == 1 then
				var_51_0.r = var_51_5 * 255
				var_51_0.g = arg_51_2 * 255
				var_51_0.b = var_51_4 * 255
			elseif var_51_2 == 2 then
				var_51_0.r = var_51_4 * 255
				var_51_0.g = arg_51_2 * 255
				var_51_0.b = var_51_6 * 255
			elseif var_51_2 == 3 then
				var_51_0.r = var_51_4 * 255
				var_51_0.g = var_51_5 * 255
				var_51_0.b = arg_51_2 * 255
			elseif var_51_2 == 4 then
				var_51_0.r = var_51_6 * 255
				var_51_0.g = var_51_4 * 255
				var_51_0.b = arg_51_2 * 255
			elseif var_51_2 == 5 then
				var_51_0.r = arg_51_2 * 255
				var_51_0.g = var_51_4 * 255
				var_51_0.b = var_51_5 * 255
			end
		end

		return var_43_4.new(math.floor(var_51_0.r), math.floor(var_51_0.g), math.floor(var_51_0.b))
	end

	local function var_43_19(arg_52_0, arg_52_1)
		local var_52_0 = arg_52_1[1]
		local var_52_1 = arg_52_1[2]
		local var_52_2 = arg_52_1[3]
		local var_52_3 = arg_52_1[4]
		local var_52_4 = #arg_52_0.visibility_requirements + 1

		arg_52_0.visibility_requirements[var_52_4] = false

		local function var_52_5()
			local var_53_0 = var_52_0._type == var_43_13.multicombo and var_52_0:get(var_52_1) or var_52_0:get()

			if var_52_0._type == var_43_13.multicombo then
				arg_52_0.visibility_requirements[var_52_4] = var_53_0
			elseif var_52_2 == nil then
				arg_52_0.visibility_requirements[var_52_4] = var_53_0 == var_52_1
			else
				arg_52_0.visibility_requirements[var_52_4] = var_52_2 == "<=" and var_53_0 <= var_52_1 or var_52_2 == ">=" and var_53_0 >= var_52_1 or var_52_2 == "<" and var_53_0 < var_52_1 or var_52_2 == ">" and var_53_0 > var_52_1 or var_52_2 == "==" and var_53_0 == var_52_1 or var_52_2 == "~=" and var_53_0 ~= var_52_1
			end

			if var_52_3 then
				arg_52_0.visibility_requirements[var_52_4] = not arg_52_0.visibility_requirements[var_52_4]
			end

			local var_53_1 = arg_52_0.visibility_requirements[var_52_4] == true

			arg_52_0.visibility_requirements[var_52_4] = var_53_1

			for iter_53_0 = 1, #arg_52_0.visibility_requirements do
				if not arg_52_0.visibility_requirements[iter_53_0] then
					var_53_1 = false

					break
				end
			end

			arg_52_0:set_visible(var_53_1)
		end

		var_52_0:register_callback(var_52_5)
		table.insert(arg_52_0.visibility_callbacks, var_52_5)
		var_52_5()
	end

	local var_43_20 = {
		KEY_NONE = var_43_0.KEY_NONE,
		KEY_0 = var_43_0.KEY_0,
		KEY_1 = var_43_0.KEY_1,
		KEY_2 = var_43_0.KEY_2,
		KEY_3 = var_43_0.KEY_3,
		KEY_4 = var_43_0.KEY_4,
		KEY_5 = var_43_0.KEY_5,
		KEY_6 = var_43_0.KEY_6,
		KEY_7 = var_43_0.KEY_7,
		KEY_8 = var_43_0.KEY_8,
		KEY_9 = var_43_0.KEY_9,
		KEY_A = var_43_0.KEY_A,
		KEY_B = var_43_0.KEY_B,
		KEY_C = var_43_0.KEY_C,
		KEY_D = var_43_0.KEY_D,
		KEY_E = var_43_0.KEY_E,
		KEY_F = var_43_0.KEY_F,
		KEY_G = var_43_0.KEY_G,
		KEY_H = var_43_0.KEY_H,
		KEY_I = var_43_0.KEY_I,
		KEY_J = var_43_0.KEY_J,
		KEY_K = var_43_0.KEY_K,
		KEY_L = var_43_0.KEY_L,
		KEY_M = var_43_0.KEY_M,
		KEY_N = var_43_0.KEY_N,
		KEY_O = var_43_0.KEY_O,
		KEY_P = var_43_0.KEY_P,
		KEY_Q = var_43_0.KEY_Q,
		KEY_R = var_43_0.KEY_R,
		KEY_S = var_43_0.KEY_S,
		KEY_T = var_43_0.KEY_T,
		KEY_U = var_43_0.KEY_U,
		KEY_V = var_43_0.KEY_V,
		KEY_W = var_43_0.KEY_W,
		KEY_X = var_43_0.KEY_X,
		KEY_Y = var_43_0.KEY_Y,
		KEY_Z = var_43_0.KEY_Z,
		KEY_PAD_0 = var_43_0.KEY_PAD_0,
		KEY_PAD_1 = var_43_0.KEY_PAD_1,
		KEY_PAD_2 = var_43_0.KEY_PAD_2,
		KEY_PAD_3 = var_43_0.KEY_PAD_3,
		KEY_PAD_4 = var_43_0.KEY_PAD_4,
		KEY_PAD_5 = var_43_0.KEY_PAD_5,
		KEY_PAD_6 = var_43_0.KEY_PAD_6,
		KEY_PAD_7 = var_43_0.KEY_PAD_7,
		KEY_PAD_8 = var_43_0.KEY_PAD_8,
		KEY_PAD_9 = var_43_0.KEY_PAD_9,
		KEY_PAD_DIVIDE = var_43_0.KEY_PAD_DIVIDE,
		KEY_PAD_MULTIPLY = var_43_0.KEY_PAD_MULTIPLY,
		KEY_PAD_MINUS = var_43_0.KEY_PAD_MINUS,
		KEY_PAD_PLUS = var_43_0.KEY_PAD_PLUS,
		KEY_PAD_ENTER = var_43_0.KEY_PAD_ENTER,
		KEY_PAD_DECIMAL = var_43_0.KEY_PAD_DECIMAL,
		KEY_LBRACKET = var_43_0.KEY_LBRACKET,
		KEY_RBRACKET = var_43_0.KEY_RBRACKET,
		KEY_SEMICOLON = var_43_0.KEY_SEMICOLON,
		KEY_APOSTROPHE = var_43_0.KEY_APOSTROPHE,
		KEY_BACKQUOTE = var_43_0.KEY_BACKQUOTE,
		KEY_COMMA = var_43_0.KEY_COMMA,
		KEY_PERIOD = var_43_0.KEY_PERIOD,
		KEY_SLASH = var_43_0.KEY_SLASH,
		KEY_BACKSLASH = var_43_0.KEY_BACKSLASH,
		KEY_MINUS = var_43_0.KEY_MINUS,
		KEY_EQUAL = var_43_0.KEY_EQUAL,
		KEY_ENTER = var_43_0.KEY_ENTER,
		KEY_SPACE = var_43_0.KEY_SPACE,
		KEY_BACKSPACE = var_43_0.KEY_BACKSPACE,
		KEY_TAB = var_43_0.KEY_TAB,
		KEY_CAPSLOCK = var_43_0.KEY_CAPSLOCK,
		KEY_NUMLOCK = var_43_0.KEY_NUMLOCK,
		KEY_ESCAPE = var_43_0.KEY_ESCAPE,
		KEY_SCROLLLOCK = var_43_0.KEY_SCROLLLOCK,
		KEY_INSERT = var_43_0.KEY_INSERT,
		KEY_DELETE = var_43_0.KEY_DELETE,
		KEY_HOME = var_43_0.KEY_HOME,
		KEY_END = var_43_0.KEY_END,
		KEY_PAGEUP = var_43_0.KEY_PAGEUP,
		KEY_PAGEDOWN = var_43_0.KEY_PAGEDOWN,
		KEY_BREAK = var_43_0.KEY_BREAK,
		KEY_LSHIFT = var_43_0.KEY_LSHIFT,
		KEY_RSHIFT = var_43_0.KEY_RSHIFT,
		KEY_LALT = var_43_0.KEY_LALT,
		KEY_RALT = var_43_0.KEY_RALT,
		KEY_LCONTROL = var_43_0.KEY_LCONTROL,
		KEY_RCONTROL = var_43_0.KEY_RCONTROL,
		KEY_LWIN = var_43_0.KEY_LWIN,
		KEY_RWIN = var_43_0.KEY_RWIN,
		KEY_APP = var_43_0.KEY_APP,
		KEY_UP = var_43_0.KEY_UP,
		KEY_LEFT = var_43_0.KEY_LEFT,
		KEY_DOWN = var_43_0.KEY_DOWN,
		KEY_RIGHT = var_43_0.KEY_RIGHT,
		KEY_F1 = var_43_0.KEY_F1,
		KEY_F2 = var_43_0.KEY_F2,
		KEY_F3 = var_43_0.KEY_F3,
		KEY_F4 = var_43_0.KEY_F4,
		KEY_F5 = var_43_0.KEY_F5,
		KEY_F6 = var_43_0.KEY_F6,
		KEY_F7 = var_43_0.KEY_F7,
		KEY_F8 = var_43_0.KEY_F8,
		KEY_F9 = var_43_0.KEY_F9,
		KEY_F10 = var_43_0.KEY_F10,
		KEY_F11 = var_43_0.KEY_F11,
		KEY_F12 = var_43_0.KEY_F12,
		KEY_CAPSLOCKTOGGLE = var_43_0.KEY_CAPSLOCKTOGGLE,
		KEY_NUMLOCKTOGGLE = var_43_0.KEY_NUMLOCKTOGGLE,
		KEY_SCROLLLOCKTOGGLE = var_43_0.KEY_SCROLLLOCKTOGGLE,
		MOUSE_LEFT = var_43_0.MOUSE_LEFT,
		MOUSE_RIGHT = var_43_0.MOUSE_RIGHT,
		MOUSE_MIDDLE = var_43_0.MOUSE_MIDDLE,
		MOUSE_4 = var_43_0.MOUSE_4,
		MOUSE_5 = var_43_0.MOUSE_5,
		MOUSE_WHEEL_UP = var_43_0.MOUSE_WHEEL_UP,
		MOUSE_WHEEL_DOWN = var_43_0.MOUSE_WHEEL_DOWN
	}
	local var_43_21 = {
		KEY_S = "S",
		KEY_PAD_7 = "7",
		KEY_E = "E",
		KEY_X = "X",
		KEY_P = "P",
		KEY_0 = "0",
		KEY_K = "K",
		KEY_PERIOD = ".",
		KEY_PAD_6 = "6",
		KEY_Q = "Q",
		KEY_9 = "9",
		KEY_6 = "6",
		KEY_D = "D",
		KEY_W = "W",
		KEY_PAD_1 = "1",
		KEY_PAD_0 = "0",
		KEY_J = "J",
		KEY_PAD_PLUS = "+",
		KEY_PAD_9 = "9",
		KEY_5 = "5",
		KEY_R = "R",
		KEY_PAD_MULTIPLY = "*",
		KEY_C = "C",
		KEY_V = "V",
		KEY_O = "O",
		KEY_PAD_3 = "3",
		KEY_I = "I",
		KEY_LBRACKET = "(",
		KEY_PAD_8 = "8",
		KEY_4 = "4",
		KEY_RBRACKET = ")",
		KEY_SEMICOLON = ";",
		KEY_B = "B",
		KEY_U = "U",
		KEY_PAD_DIVIDE = "/",
		KEY_PAD_2 = "2",
		KEY_H = "H",
		KEY_COMMA = ",",
		KEY_PAD_MINUS = "-",
		KEY_N = "N",
		KEY_BACKQUOTE = "`",
		KEY_APOSTROPHE = "'",
		KEY_A = "A",
		KEY_T = "T",
		KEY_3 = "3",
		KEY_PAD_5 = "5",
		KEY_G = "G",
		KEY_Z = "Z",
		KEY_BACKSLASH = "\\",
		KEY_2 = "2",
		KEY_M = "M",
		KEY_MINUS = "-",
		KEY_SLASH = "/",
		KEY_8 = "8",
		KEY_EQUAL = "=",
		KEY_PAD_4 = "4",
		KEY_F = "F",
		KEY_Y = "Y",
		KEY_SPACE = " ",
		KEY_1 = "1",
		KEY_L = "L",
		KEY_PAD_DECIMAL = ".",
		KEY_7 = "7"
	}
	local var_43_22 = {
		MOUSE_MIDDLE = "Mouse3",
		KEY_UP = "Up",
		KEY_END = "End",
		MOUSE_RIGHT = "Mouse2",
		KEY_LEFT = "Left",
		KEY_SCROLLLOCK = "Scroll Lock",
		KEY_PAGEDOWN = "PG DN",
		MOUSE_5 = "Mouse5",
		KEY_SPACE = "Space",
		KEY_F11 = "F11",
		KEY_F10 = "F10",
		KEY_ESCAPE = "Esc",
		KEY_F6 = "F6",
		KEY_DOWN = "Down",
		KEY_RIGHT = "Right",
		KEY_F12 = "F12",
		MOUSE_WHEEL_DOWN = "MWheel down",
		KEY_LALT = "LALT",
		KEY_BREAK = "BREAK",
		KEY_F1 = "F1",
		KEY_RALT = "RALT",
		KEY_F2 = "F2",
		KEY_CAPSLOCK = "Caps",
		KEY_NUMLOCKTOGGLE = "Numlock",
		KEY_HOME = "Home",
		KEY_F8 = "F8",
		KEY_RCONTROL = "RCONTROL",
		MOUSE_4 = "Mouse4",
		KEY_NUMLOCK = "Numlock",
		MOUSE_WHEEL_UP = "MWheel up",
		KEY_CAPSLOCKTOGGLE = "Caps",
		KEY_F3 = "F3",
		KEY_LSHIFT = "LSHIFT",
		KEY_F4 = "F4",
		KEY_F9 = "F9",
		KEY_TAB = "Tab",
		KEY_LWIN = "LWIN",
		KEY_SCROLLLOCKTOGGLE = "Scroll Lock",
		KEY_RWIN = "RWIN",
		KEY_F5 = "F5",
		KEY_APP = "APP",
		MOUSE_LEFT = "Mouse1",
		KEY_NONE = "none",
		KEY_RSHIFT = "RSHIFT",
		KEY_F7 = "F7",
		KEY_DELETE = "Del",
		KEY_LCONTROL = "LCONTROL",
		KEY_PAGEUP = "PG UP",
		KEY_BACKSPACE = "Backspace",
		KEY_INSERT = "Ins"
	}

	local function var_43_23(arg_54_0)
		return unpack({
			arg_54_0
		})
	end

	function var_43_1.get_input_text()
		local var_55_0 = var_43_1.is_key_held(var_43_20.KEY_LSHIFT) or var_43_1.is_key_held(var_43_20.KEY_RSHIFT)

		for iter_55_0, iter_55_1 in pairs(var_43_21) do
			if var_43_1.is_key_pressed(var_43_20[iter_55_0]) then
				local var_55_1 = iter_55_1

				if not var_55_0 then
					var_55_1 = var_55_1:lower()
				end

				return var_55_1
			end
		end

		return ""
	end

	function var_43_1.get_new_keybind_key()
		for iter_56_0, iter_56_1 in pairs(var_43_21) do
			if var_43_1.is_key_pressed(var_43_20[iter_56_0]) then
				return var_43_20[iter_56_0]
			end
		end

		for iter_56_2, iter_56_3 in pairs(var_43_22) do
			if var_43_1.is_key_pressed(var_43_20[iter_56_2]) then
				return var_43_20[iter_56_2]
			end
		end

		return nil
	end

	function var_43_1.get_key_name(arg_57_0)
		for iter_57_0, iter_57_1 in pairs(var_43_21) do
			if arg_57_0 == var_43_20[iter_57_0] then
				return iter_57_1
			end
		end

		for iter_57_2, iter_57_3 in pairs(var_43_22) do
			if arg_57_0 == var_43_20[iter_57_2] then
				return iter_57_3
			end
		end

		return ""
	end

	local var_43_24 = {
		default = var_43_2.get_default_font(),
		element = var_43_2.get_default_font(),
		page = var_43_2.create_font("Arial", 24, 800, var_43_7.ANTIALIAS),
		page_title = var_43_2.create_font("Arial", 12, 800, var_43_7.ANTIALIAS)
	}
	local var_43_25 = {
		inactive_outline = var_43_4.new(40, 40, 40),
		inactive_text = var_43_4.new(123, 123, 123),
		hovering_text = var_43_4.new(181, 181, 181),
		active_text = var_43_4.new(200, 200, 200),
		hovering_outline = var_43_4.new(58, 58, 58),
		active_outline = var_43_4.new(58, 58, 58),
		dark_background = var_43_4.new(29, 29, 29),
		subtab_background = var_43_4.new(34, 34, 34),
		section_background = var_43_4.new(34, 34, 34),
		footer_background = var_43_4.new(41, 41, 41),
		black = var_43_4.new(0, 0, 0),
		white = var_43_4.new(255, 255, 255),
		accent = var_43_4.new(193, 154, 164),
		red = var_43_4.new(255, 0, 0),
		white10 = var_43_4.new(255, 255, 255, 10),
		white30 = var_43_4.new(255, 255, 255, 30),
		white100 = var_43_4.new(255, 255, 255, 50),
		black10 = var_43_4.new(0, 0, 0, 10),
		transparent = var_43_4.new(0, 0, 0, 0)
	}
	local var_43_26 = {}

	for iter_43_0, iter_43_1 in pairs(var_43_25) do
		var_43_26[iter_43_0] = iter_43_1
	end

	local var_43_27 = {}
	local var_43_28 = {
		hold = 2,
		toggle = 3,
		always = 1,
		none = 0
	}

	function var_43_27.create_tooltip(arg_58_0, arg_58_1)
		local var_58_0 = {
			parent = arg_58_0,
			gui = arg_58_0.gui,
			text = type(arg_58_1) == "table" and arg_58_1 or {
				arg_58_1
			}
		}

		var_58_0.cached_open = false
		var_58_0.cached_state_change = false
		var_58_0.start_counting = false
		var_58_0.pos = var_43_3.new(0, 0)
		var_58_0.size = var_43_3.new(14, 14)
		var_58_0.open = false
		var_58_0.hovering = false
		var_58_0.animations = {
			last_close_time = 0,
			o_c_time = 1.2,
			close_fade_time = 0.3,
			hover_start = 0,
			last_interaction = 0
		}
		var_58_0.can_render = true
		var_58_0.longest_text = 0

		for iter_58_0 = 1, #var_58_0.text do
			local var_58_1 = var_43_2.get_text_size(var_43_24.default, var_58_0.text[iter_58_0]).x

			if var_58_1 > var_58_0.longest_text then
				var_58_0.longest_text = var_58_1
			end
		end

		function var_58_0.set_pos(arg_59_0, arg_59_1)
			arg_59_0.pos = arg_59_1

			arg_59_0:render_base()
		end

		function var_58_0.set_render_state(arg_60_0, arg_60_1)
			arg_60_0.can_render = arg_60_1
		end

		function var_58_0.in_bounds(arg_61_0)
			return var_43_1.is_mouse_in_bounds(arg_61_0.pos, arg_61_0.size)
		end

		function var_58_0.render_base(arg_62_0)
			local var_62_0 = arg_62_0.pos + var_43_3.new(var_58_0.size.x / 2, var_58_0.size.y / 2)
			local var_62_1 = arg_62_0.gui.colors.inactive_outline

			var_43_2.circle_filled(var_62_0, var_58_0.size.x / 2, arg_62_0.gui.colors.dark_background)
			var_43_2.circle(var_62_0, var_58_0.size.x / 2, var_62_1)
			var_43_2.text(var_43_24.page_title, "?", var_62_0 + var_43_3.new(1, 0), var_62_1, true)
		end

		function var_58_0.render(arg_63_0)
			if not arg_63_0.can_render then
				return
			end

			local var_63_0 = var_58_0.size
			local var_63_1 = arg_63_0.pos + var_43_3.new(var_58_0.size.x / 2, var_58_0.size.y / 2)
			local var_63_2 = var_43_1.is_mouse_in_bounds(arg_63_0.pos, var_63_0)
			local var_63_3 = globals.real_time()
			local var_63_4 = var_43_1.is_key_pressed(var_43_20.MOUSE_LEFT)
			local var_63_5 = var_63_3 - arg_63_0.animations.last_interaction

			if var_63_2 and not arg_63_0.open and not (var_63_3 < arg_63_0.animations.last_close_time + arg_63_0.animations.close_fade_time) and var_58_0.hovering then
				arg_63_0.animations.hover_start = var_63_3
				var_58_0.hovering = true
			elseif not var_63_2 and not arg_63_0.open then
				arg_63_0.animations.hover_start = var_63_3
				var_58_0.hovering = false
			end

			if var_63_4 then
				if arg_63_0.open and not var_63_2 or not arg_63_0.open and var_63_2 then
					arg_63_0.animations.last_close_time = var_63_3
				end

				arg_63_0.open = var_63_2
				var_58_0.hovering = false
				arg_63_0.animations.hover_start = var_63_3
			end

			if var_63_3 > arg_63_0.animations.hover_start + arg_63_0.animations.o_c_time and not arg_63_0.open then
				arg_63_0.open = true
				arg_63_0.animations.last_close_time = var_63_3
			end

			if var_63_2 and arg_63_0.open then
				arg_63_0.animations.last_interaction = var_63_3
			end

			if not var_63_2 and var_63_5 > arg_63_0.animations.o_c_time and arg_63_0.cached_open ~= arg_63_0.open then
				arg_63_0.open = false
				arg_63_0.cached_open = arg_63_0.open
				arg_63_0.animations.last_close_time = var_63_3
			end

			local var_63_6 = arg_63_0.gui.colors.inactive_outline
			local var_63_7 = (var_63_3 - arg_63_0.animations.last_close_time) / arg_63_0.animations.close_fade_time

			if not arg_63_0.open then
				var_63_7 = 1 - var_63_7
			end

			if arg_63_0.open or var_63_3 < arg_63_0.animations.last_close_time + arg_63_0.animations.close_fade_time then
				local var_63_8 = math.clamp(math.floor(var_63_7 * 255), 0, 255)
				local var_63_9 = arg_63_0.text
				local var_63_10 = var_43_24.default.height * #var_63_9
				local var_63_11 = var_43_3.new(5, 2)
				local var_63_12 = var_63_10 + var_63_11.y * 2
				local var_63_13 = arg_63_0.pos.x + var_63_0.x / 2 - arg_63_0.longest_text / 2 - var_63_11.x
				local var_63_14 = arg_63_0.pos.y - 5 - var_63_12
				local var_63_15 = var_43_4.new(arg_63_0.gui.colors.dark_background.r, arg_63_0.gui.colors.dark_background.g, arg_63_0.gui.colors.dark_background.b, var_63_8)
				local var_63_16 = var_43_4.new(var_63_6.r, var_63_6.g, var_63_6.b, var_63_8)

				var_43_2.rect_filled(var_43_3.new(var_63_13, var_63_14), var_43_3.new(arg_63_0.longest_text + var_63_11.x * 2, var_63_12), var_63_15, 3)
				var_43_2.rect(var_43_3.new(var_63_13, var_63_14), var_43_3.new(arg_63_0.longest_text + var_63_11.x * 2, var_63_12), var_63_16, 3)

				local var_63_17 = var_43_3.new(var_63_1.x, var_63_14 + var_63_11.y + var_43_24.default.height / 2)

				for iter_63_0 = 1, #arg_63_0.text do
					local var_63_18 = arg_63_0.text[iter_63_0]

					var_43_2.text(var_43_24.default, var_63_18, var_43_3.new(var_63_17.x, var_63_17.y + var_43_24.default.height * (iter_63_0 - 1)), var_43_4.new(255, 255, 255, var_63_8), true)
				end
			end
		end

		function var_58_0.set(arg_64_0, arg_64_1)
			arg_64_0.text = type(arg_64_1) == "table" and arg_64_1 or {
				arg_64_1
			}
			arg_64_0.longest_text = 0

			for iter_64_0 = 1, #arg_64_0.text do
				local var_64_0 = var_43_2.get_text_size(var_43_24.default, arg_64_0.text[iter_64_0]).x

				if var_64_0 > arg_64_0.longest_text then
					arg_64_0.longest_text = var_64_0
				end
			end
		end

		return var_58_0
	end

	function var_43_27.create_keybind(arg_65_0, arg_65_1, arg_65_2, arg_65_3, arg_65_4)
		local var_65_0 = {
			_type = var_43_13.keybind,
			parent = arg_65_0,
			page = arg_65_0.page,
			tab = arg_65_0.tab,
			section = arg_65_0.section,
			name = arg_65_1,
			mode = arg_65_2 ~= nil and arg_65_2 or var_43_28.none
		}

		var_65_0.mode = math.clamp(var_65_0.mode, 0, 3)
		var_65_0.key = arg_65_3 or var_43_20.KEY_NONE
		var_65_0.locked = arg_65_4 or false
		var_65_0.defaults = {
			mode = var_43_23(var_65_0.mode),
			key = var_43_23(var_65_0.key)
		}
		var_65_0.state = false
		var_65_0.visible = true
		var_65_0.mode_menu_open = false
		var_65_0.binding_new_key = false
		var_65_0.render_topmost = false
		var_65_0.key_name = var_43_1.get_key_name(var_65_0.key)
		var_65_0.height = 16
		var_65_0.visibility_callbacks = {}
		var_65_0.visibility_requirements = {}
		var_65_0.callbacks = {}

		function var_65_0.register_callback(arg_66_0, arg_66_1)
			table.insert(arg_66_0.callbacks, arg_66_1)
		end

		function var_65_0.invoke_callbacks(arg_67_0)
			for iter_67_0 = 1, #arg_67_0.callbacks do
				arg_67_0.callbacks[iter_67_0]()
			end
		end

		function var_65_0.invoke_visibility_callbacks(arg_68_0)
			for iter_68_0 = 1, #arg_68_0.visibility_callbacks do
				arg_68_0.visibility_callbacks[iter_68_0]()
			end
		end

		function var_65_0.set_visibility_requirement(arg_69_0, ...)
			local var_69_0 = {
				...
			}

			var_43_19(arg_69_0, var_69_0)
		end

		function var_65_0.get(arg_70_0)
			return var_65_0.state
		end

		function var_65_0.update(arg_71_0)
			if arg_71_0.mode == var_43_28.none then
				arg_71_0.state = false
			elseif arg_71_0.mode == var_43_28.always then
				arg_71_0.state = true
			elseif arg_71_0.mode == var_43_28.hold then
				arg_71_0.state = var_43_1.is_key_held(arg_71_0.key)

				if arg_71_0.state then
					arg_71_0:invoke_callbacks()
				end
			elseif arg_71_0.mode == var_43_28.toggle then
				if var_43_1.is_key_pressed(arg_71_0.key) then
					arg_71_0.state = not arg_71_0.state
				end

				if arg_71_0.state then
					arg_71_0:invoke_callbacks()
				end
			end
		end

		function var_65_0.set_mode(arg_72_0, arg_72_1)
			var_65_0.mode = math.clamp(arg_72_1, 0, 3)
		end

		function var_65_0.set_defaults(arg_73_0)
			var_65_0.mode = var_43_23(var_65_0.defaults.mode)
			var_65_0.key = var_43_23(var_65_0.defaults.key)
		end

		function var_65_0.get_mode(arg_74_0)
			return var_65_0.mode
		end

		function var_65_0.lock_mode(arg_75_0)
			var_65_0.locked = true
		end

		function var_65_0.unlock_mode(arg_76_0)
			var_65_0.locked = false
		end

		function var_65_0.set_key(arg_77_0, arg_77_1)
			var_65_0.key = arg_77_1
			var_65_0.key_name = var_43_1.get_key_name(arg_77_1)
		end

		function var_65_0.get_key(arg_78_0)
			return var_65_0.key
		end

		function var_65_0.set_visible(arg_79_0, arg_79_1)
			var_65_0.visible = arg_79_1
		end

		function var_65_0.handle(arg_80_0, arg_80_1, arg_80_2, arg_80_3)
			if not arg_80_0.visible then
				return false
			end

			if arg_80_0.parent.gui.pos.y > arg_80_1.y then
				arg_80_0.mode_menu_open = false
				arg_80_0.binding_new_key = false

				return false
			end

			local var_80_0 = arg_80_0.mode == var_43_28.always and "Always on: " or arg_80_0.mode == var_43_28.hold and "Hold on: " or arg_80_0.mode == var_43_28.toggle and "Toggle: " or "Always off"
			local var_80_1 = not (arg_80_0.mode ~= var_43_28.none and arg_80_0.mode ~= var_43_28.always) and var_80_0 or var_80_0 .. (arg_80_0.binding_new_key and "..." or arg_80_0.key_name)
			local var_80_2 = var_43_2.get_text_size(var_43_24.default, var_80_1).x
			local var_80_3 = arg_80_1 + var_43_3.new(arg_80_2 - 20 - var_80_2, 0)
			local var_80_4 = var_43_3.new(var_80_2 + 10, var_65_0.height)
			local var_80_5 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)
			local var_80_6 = var_43_1.is_mouse_in_bounds(var_80_3, var_80_4)
			local var_80_7 = var_43_1.is_mouse_in_bounds(var_80_3 + var_43_3.new(0, var_65_0.height), var_43_3.new(var_80_4.x, var_65_0.height * 4))

			if var_80_6 and var_80_5 and not arg_80_0.binding_new_key and (arg_80_0.mode == var_43_28.hold or arg_80_0.mode == var_43_28.toggle) then
				arg_80_0.binding_new_key = true
			elseif arg_80_0.binding_new_key then
				local var_80_8 = var_43_1.get_new_keybind_key()

				if var_80_8 ~= nil then
					if var_80_8 == var_43_0.KEY_ESCAPE then
						var_80_8 = var_43_20.KEY_NONE
					end

					arg_80_0.key = var_80_8
					arg_80_0.key_name = var_43_1.get_key_name(arg_80_0.key)
					arg_80_0.binding_new_key = false
				end
			elseif not var_80_6 and arg_80_0.binding_new_key and var_80_5 then
				arg_80_0.binding_new_key = false
			end

			local var_80_9 = var_43_1.is_key_pressed(var_43_0.MOUSE_RIGHT)

			if var_80_6 and var_80_9 and not arg_80_0.locked and not arg_80_0.binding_new_key then
				arg_80_0.mode_menu_open = not arg_80_0.mode_menu_open
			elseif not var_80_6 and not var_80_7 and (var_80_5 or var_80_9) then
				arg_80_0.mode_menu_open = false
			end

			if arg_80_0.mode_menu_open then
				local var_80_10 = var_80_3 + var_43_3.new(0, var_65_0.height)

				if var_80_5 then
					local var_80_11 = var_43_1.get_mouse_pos().y
					local var_80_12 = math.floor((var_80_11 - var_80_10.y) / var_65_0.height) + 1

					if var_80_12 == 1 then
						arg_80_0.mode = var_43_28.none
					elseif var_80_12 == 2 then
						arg_80_0.mode = var_43_28.always
					elseif var_80_12 == 3 then
						arg_80_0.mode = var_43_28.hold
					elseif var_80_12 == 4 then
						arg_80_0.mode = var_43_28.toggle
					end

					arg_80_0.mode_menu_open = false
				end

				return true
			end

			return arg_80_0.binding_new_key or arg_80_0.mode_menu_open
		end

		function var_65_0.in_bounds(arg_81_0, arg_81_1, arg_81_2)
			if not arg_81_0.visible or not arg_81_0.parent.visible then
				return false, var_43_3.new(0, 0)
			end

			local var_81_0 = arg_81_0.mode == var_43_28.always and "Always on: " or arg_81_0.mode == var_43_28.hold and "Hold on: " or arg_81_0.mode == var_43_28.toggle and "Toggle: " or "Always off"
			local var_81_1 = arg_81_0.mode == var_43_28.none and var_81_0 or var_81_0 .. arg_81_0.key_name
			local var_81_2 = var_43_2.get_text_size(var_43_24.default, var_81_1).x
			local var_81_3 = arg_81_1 + var_43_3.new(arg_81_2 - 20 - var_81_2, 0)
			local var_81_4 = var_43_3.new(var_81_2 + 10, var_65_0.height) + var_43_3.new(3, 0)

			return var_43_1.is_mouse_in_bounds(var_81_3, var_81_4), var_81_4
		end

		function var_65_0.render(arg_82_0, arg_82_1, arg_82_2, arg_82_3)
			if not arg_82_0.visible or not arg_82_0.parent.visible then
				return
			end

			local var_82_0 = arg_82_0.mode == var_43_28.always and "Always on" or arg_82_0.mode == var_43_28.hold and "Hold on: " or arg_82_0.mode == var_43_28.toggle and "Toggle: " or "Always off"
			local var_82_1 = arg_82_0.parent.gui.pos.y
			local var_82_2 = not (arg_82_0.mode ~= var_43_28.none and arg_82_0.mode ~= var_43_28.always) and var_82_0 or var_82_0 .. (arg_82_0.binding_new_key and "..." or arg_82_0.key_name)
			local var_82_3 = var_43_2.get_text_size(var_43_24.default, var_82_2).x
			local var_82_4 = arg_82_1 + var_43_3.new(arg_82_2 - 10 - var_82_3 - 10, 0)
			local var_82_5 = var_43_3.new(var_82_3 + 10, var_65_0.height)

			if var_82_1 < var_82_4.y then
				local var_82_6 = var_43_1.is_mouse_in_bounds(var_82_4, var_82_5) and arg_82_0.parent.gui.colors.hovering_outline or arg_82_0.parent.gui.colors.inactive_outline
				local var_82_7 = arg_82_0.binding_new_key and arg_82_0.parent.gui.colors.hovering_text or arg_82_0.parent.gui.colors.inactive_text

				var_43_2.rect_filled(var_82_4, var_82_5, arg_82_0.parent.gui.colors.dark_background, 3)
				var_43_2.rect(var_82_4, var_82_5, var_82_6, 3)
				var_43_2.text(var_43_24.default, var_82_2, var_82_4 + var_43_3.new(5, 0), var_82_7)

				if arg_82_0.mode_menu_open then
					local var_82_8 = {
						"Always Off",
						"Always On",
						"On Hold",
						"Toggle"
					}
					local var_82_9 = var_65_0.height * #var_82_8
					local var_82_10 = var_82_4 + var_43_3.new(0, var_65_0.height)

					var_43_2.rect_filled(var_82_10, var_43_3.new(var_82_5.x, var_82_9), arg_82_0.parent.gui.colors.dark_background, 3)
					var_43_2.rect(var_82_10, var_43_3.new(var_82_5.x, var_82_9), arg_82_0.parent.gui.colors.inactive_outline, 3)

					for iter_82_0 = 1, #var_82_8 do
						local var_82_11 = var_82_8[iter_82_0]
						local var_82_12 = var_82_10 + var_43_3.new(5, var_65_0.height * (iter_82_0 - 1))
						local var_82_13 = var_43_1.is_mouse_in_bounds(var_82_12, var_43_3.new(var_82_5.x - 10, var_65_0.height))
						local var_82_14 = arg_82_0.mode == iter_82_0 - 1 and var_43_25.accent or var_82_13 and arg_82_0.parent.gui.colors.hovering_text or arg_82_0.parent.gui.colors.inactive_text

						var_43_2.text(var_43_24.default, var_82_11, var_82_12, var_82_14)
					end
				end
			end
		end

		function var_65_0.to_string(arg_83_0)
			return string.format("[ keybind ][ %s->%s->%s ] %s", arg_83_0.page, arg_83_0.tab, arg_83_0.section, arg_83_0.name, arg_83_0.key_name)
		end

		return var_65_0
	end

	function var_43_27.create_colorpicker(arg_84_0, arg_84_1, arg_84_2)
		local var_84_0 = {
			_type = var_43_13.colorpicker,
			parent = arg_84_0,
			page = arg_84_0.page,
			tab = arg_84_0.tab,
			section = arg_84_0.section,
			name = arg_84_1,
			color = arg_84_2 == nil and var_43_4.new(255, 255, 255) or arg_84_2,
			defaults = {
				color = var_43_23(var_84_0.color)
			}
		}

		var_84_0.visible = true
		var_84_0.render_topmost = false
		var_84_0.height = 16
		var_84_0.open = false
		var_84_0.visibility_callbacks = {}
		var_84_0.visibility_requirements = {}
		var_84_0.callbacks = {}

		function var_84_0.register_callback(arg_85_0, arg_85_1)
			table.insert(arg_85_0.callbacks, arg_85_1)
		end

		function var_84_0.invoke_callbacks(arg_86_0)
			for iter_86_0 = 1, #arg_86_0.callbacks do
				arg_86_0.callbacks[iter_86_0]()
			end
		end

		function var_84_0.invoke_visibility_callbacks(arg_87_0)
			for iter_87_0 = 1, #arg_87_0.visibility_callbacks do
				arg_87_0.visibility_callbacks[iter_87_0]()
			end
		end

		function var_84_0.set_visibility_requirement(arg_88_0, ...)
			local var_88_0 = {
				...
			}

			var_43_19(arg_88_0, var_88_0)
		end

		var_84_0.size = var_43_3.new(20, 13)
		var_84_0.picker_size = var_43_3.new(180, 200)
		var_84_0.picker_area = var_43_3.new(var_84_0.picker_size.x - 20, (var_84_0.picker_size.x - 20) * 0.8)
		var_84_0.hue, var_84_0.saturation, var_84_0.brightness = var_43_17(var_84_0.color)
		var_84_0.alpha = arg_84_2 == nil and 255 or var_84_0.color.a
		var_84_0.stored = {
			positions = {
				window = var_43_3.new(0, 0),
				picker = var_43_3.new(0, 0),
				hue_slider = var_43_3.new(0, 0),
				alpha_slider = var_43_3.new(0, 0),
				copy_button = var_43_3.new(0, 0),
				paste_button = var_43_3.new(0, 0)
			},
			sizes = {
				picker = var_43_3.new(0, 0),
				hue_slider = var_43_3.new(0, 0),
				alpha_slider = var_43_3.new(0, 0),
				copy_button = var_43_3.new(0, 0),
				paste_button = var_43_3.new(0, 0)
			}
		}
		var_84_0.changing = {
			alpha = false,
			hue = false,
			main = false
		}
		var_84_0.clicked_outside = false

		function var_84_0.get(arg_89_0)
			return var_84_0.color
		end

		function var_84_0.set(arg_90_0, arg_90_1)
			var_84_0.color = arg_90_1
			var_84_0.hue, var_84_0.saturation, var_84_0.brightness = var_43_17(var_84_0.color)
			var_84_0.alpha = var_84_0.color.a
		end

		function var_84_0.set_defaults(arg_91_0)
			arg_91_0:set(var_43_23(arg_91_0.defaults.color))
		end

		function var_84_0.set_visible(arg_92_0, arg_92_1)
			var_84_0.visible = arg_92_1
		end

		function var_84_0.in_bounds(arg_93_0, arg_93_1, arg_93_2)
			if not arg_93_0.visible or not arg_93_0.parent.visible then
				return false, var_43_3.new(0, 0)
			end

			local var_93_0 = arg_93_1 + var_43_3.new(arg_93_2 - 10 - arg_93_0.size.x, 0)

			return var_43_1.is_mouse_in_bounds(var_93_0, arg_93_0.size), arg_93_0.size + var_43_3.new(5, 0)
		end

		function var_84_0.handle(arg_94_0, arg_94_1, arg_94_2, arg_94_3)
			if not arg_94_0.visible or not arg_94_0.parent.visible then
				return false
			end

			if arg_94_0.parent.gui.pos.y > arg_94_1.y then
				arg_94_0.open = false
				arg_94_0.changing = {
					alpha = false,
					hue = false,
					main = false
				}

				return false
			end

			local var_94_0 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)
			local var_94_1 = arg_94_0:in_bounds(arg_94_1, arg_94_2)

			if var_94_1 and var_94_0 then
				arg_94_0.open = not arg_94_0.open

				return true
			end

			local var_94_2 = var_43_1.is_mouse_in_bounds(arg_94_0.stored.positions.window, arg_94_0.picker_size)

			if not var_94_1 and not var_94_2 and var_94_0 then
				arg_94_0.open = false
			end

			if arg_94_0.open then
				local var_94_3 = var_43_1.is_key_held(var_43_0.MOUSE_LEFT)
				local var_94_4 = arg_94_0.stored.positions.picker
				local var_94_5 = arg_94_0.stored.sizes.picker
				local var_94_6 = arg_94_0.stored.positions.hue_slider
				local var_94_7 = arg_94_0.stored.sizes.hue_slider
				local var_94_8 = arg_94_0.stored.positions.alpha_slider
				local var_94_9 = arg_94_0.stored.sizes.alpha_slider
				local var_94_10 = {
					main = var_43_1.is_mouse_in_bounds(var_94_4, var_94_5),
					hue = var_43_1.is_mouse_in_bounds(var_94_6, var_94_7),
					alpha = var_43_1.is_mouse_in_bounds(var_94_8, var_94_9)
				}

				if var_94_0 and not var_94_10.main and not var_94_10.hue and not var_94_10.alpha then
					arg_94_0.clicked_outside = true
				end

				local var_94_11 = var_43_1.get_mouse_pos()

				if not arg_94_0.clicked_outside then
					if arg_94_0.changing.main or var_94_3 and var_94_10.main and not arg_94_0.changing.alpha and not arg_94_0.changing.hue then
						arg_94_0.changing.main = true

						local var_94_12 = var_43_3.new((var_94_11.x - var_94_4.x) / var_94_5.x, (var_94_11.y - var_94_4.y) / var_94_5.y)

						arg_94_0.saturation = math.clamp(var_94_12.x, 0, 1)
						arg_94_0.brightness = 1 - math.clamp(var_94_12.y, 0, 1)
					elseif arg_94_0.changing.hue or var_94_3 and var_94_10.hue and not arg_94_0.changing.alpha then
						arg_94_0.changing.hue = true

						local var_94_13 = (var_94_11.x - var_94_6.x) / var_94_7.x

						arg_94_0.hue = math.clamp(var_94_13, 0, 1) * 360
						arg_94_0.color = var_43_18(arg_94_0.hue, arg_94_0.saturation, arg_94_0.brightness)
					elseif arg_94_0.changing.alpha or var_94_3 and var_94_10.alpha then
						arg_94_0.changing.alpha = true

						local var_94_14 = (var_94_11.x - var_94_8.x) / var_94_9.x

						arg_94_0.alpha = math.clamp(var_94_14, 0, 1) * 255
					end
				end

				if arg_94_0.changing.main or arg_94_0.changing.hue or arg_94_0.changing.alpha then
					arg_94_0:invoke_callbacks()
				end

				if not var_94_3 and not var_94_0 then
					arg_94_0.changing.main = false
					arg_94_0.changing.hue = false
					arg_94_0.changing.alpha = false
					var_84_0.clicked_outside = false
				end

				arg_94_0.color = var_43_18(arg_94_0.hue, arg_94_0.saturation, arg_94_0.brightness)
				arg_94_0.color.a = math.floor(arg_94_0.alpha + 0.5)

				local var_94_15 = {
					copy = var_43_1.is_mouse_in_bounds(arg_94_0.stored.positions.copy_button, arg_94_0.stored.sizes.copy_button),
					paste = var_43_1.is_mouse_in_bounds(arg_94_0.stored.positions.paste_button, arg_94_0.stored.sizes.paste_button)
				}

				if var_94_0 and var_94_15.copy then
					arg_94_0.hue, arg_94_0.saturation, arg_94_0.brightness = var_43_17(arg_94_0.color)

					local var_94_16 = var_43_4.new(arg_94_0.color.r, arg_94_0.color.g, arg_94_0.color.b, math.floor(arg_94_0.alpha))

					arg_94_0.parent.gui:set_stored_color(var_94_16)
					arg_94_0:invoke_callbacks()
				end

				if var_94_0 and var_94_15.paste then
					local var_94_17 = arg_94_0.parent.gui:get_stored_color()

					if var_94_17 ~= nil then
						arg_94_0.hue, arg_94_0.saturation, arg_94_0.brightness = var_43_17(var_94_17)
						arg_94_0.alpha = var_94_17.a

						arg_94_0:invoke_callbacks()
					end
				end
			end

			if arg_94_0.changing.main or arg_94_0.changing.hue or arg_94_0.changing.alpha then
				arg_94_0:invoke_callbacks()
			end

			return arg_94_0.open
		end

		function var_84_0.render(arg_95_0, arg_95_1, arg_95_2, arg_95_3)
			if not arg_95_0.visible or not arg_95_0.parent.visible then
				return
			end

			if arg_95_0.parent.gui.pos.y > arg_95_1.y then
				return
			end

			local var_95_0 = arg_95_1 + var_43_3.new(arg_95_2 - 10 - arg_95_0.size.x, 1)
			local var_95_1 = var_43_1.is_mouse_in_bounds(var_95_0, arg_95_0.size) and arg_95_0.parent.gui.colors.hovering_outline or arg_95_0.parent.gui.colors.inactive_outline

			var_43_2.rect_filled(var_95_0, arg_95_0.size, arg_95_0.color, 3)
			var_43_2.rect(var_95_0, arg_95_0.size, var_95_1, 3)

			if arg_95_0.open then
				arg_95_0.stored.positions.window = var_95_0 + var_43_3.new(arg_95_0.size.x + 5, 0)

				var_43_2.rect_filled(arg_95_0.stored.positions.window, arg_95_0.picker_size, arg_95_0.parent.gui.colors.subtab_background, 3)
				var_43_2.rect(arg_95_0.stored.positions.window, arg_95_0.picker_size, arg_95_0.parent.gui.colors.black, 3)

				local var_95_2 = arg_95_0.stored.positions.window + var_43_3.new((arg_95_0.picker_size.x - arg_95_0.picker_area.x) / 2, (arg_95_0.picker_size.x - arg_95_0.picker_area.x) / 2)

				var_84_0.stored.positions.picker = var_43_3.new(var_95_2.x, var_95_2.y)

				var_43_2.rect_fade(var_95_2, arg_95_0.picker_area, arg_95_0.parent.gui.colors.white, arg_95_0.parent.gui.colors.black, false)

				local var_95_3 = var_43_15(arg_95_0.hue)
				local var_95_4 = var_43_4.new(var_95_3.r, var_95_3.g, var_95_3.b, 0)

				var_43_2.rect_fade(var_95_2, arg_95_0.picker_area, var_95_4, var_95_3, true)
				var_43_2.rect_fade(var_95_2, arg_95_0.picker_area, arg_95_0.parent.gui.colors.black10, arg_95_0.parent.gui.colors.black, false)

				local var_95_5 = var_95_2 + var_43_3.new(math.floor(arg_95_0.saturation * arg_95_0.picker_area.x + 0.5), math.floor((1 - arg_95_0.brightness) * arg_95_0.picker_area.y + 0.5))

				var_43_2.circle_filled(var_95_5, 3, arg_95_0.parent.gui.colors.white)

				local var_95_6 = var_95_2 + var_43_3.new(0, arg_95_0.picker_area.y + 5)
				local var_95_7 = var_43_3.new(arg_95_0.picker_area.x, 10)

				var_84_0.stored.positions.hue_slider = var_43_3.new(var_95_6.x, var_95_6.y)

				var_43_2.rect_filled(var_95_6 + var_43_3.new(1, 1), var_95_7 - var_43_3.new(2, 2), var_43_4.new(255, 0, 0, 255))

				for iter_95_0 = 0, 300, 60 do
					local var_95_8 = var_43_15(iter_95_0)
					local var_95_9 = var_43_15(iter_95_0 + 60)

					var_43_2.rect_fade(var_95_6 + var_43_3.new(math.floor(iter_95_0 / 360 * var_95_7.x + 0.5) + 2, 0), var_43_3.new(var_95_7.x / 6 + (iter_95_0 == 300 and 1 or 5) - 4, var_95_7.y), var_95_8, var_95_9, true)
				end

				var_43_2.rect(var_95_6, var_95_7, arg_95_0.parent.gui.colors.black, 2)

				local var_95_10 = var_95_6 + var_43_3.new(math.floor(arg_95_0.hue / 360 * (var_95_7.x - 2) + 0.5), -2)
				local var_95_11 = var_43_3.new(3, var_95_7.y + 4)

				var_43_2.rect_filled(var_95_10, var_95_11, arg_95_0.parent.gui.colors.white)
				var_43_2.rect(var_95_10, var_95_11, arg_95_0.parent.gui.colors.black)

				local var_95_12 = var_95_6 + var_43_3.new(0, var_95_7.y + 5)
				local var_95_13 = var_43_3.new(arg_95_0.picker_area.x, 10)

				var_84_0.stored.positions.alpha_slider = var_43_3.new(var_95_12.x, var_95_12.y)

				var_43_2.rect_fade(var_95_12, var_95_13 - var_43_3.new(2, 0), var_43_4.new(arg_95_0.color.r, arg_95_0.color.g, arg_95_0.color.b, 0), var_43_4.new(arg_95_0.color.r, arg_95_0.color.g, arg_95_0.color.b, 255), true)
				var_43_2.rect_filled(var_95_12 + var_43_3.new(var_95_13.x - 2, 1), var_43_3.new(1, var_95_13.y - 2), var_43_4.new(arg_95_0.color.r, arg_95_0.color.g, arg_95_0.color.b, 255))
				var_43_2.rect(var_95_12, var_95_13, arg_95_0.parent.gui.colors.black, 2)

				local var_95_14 = var_95_12 + var_43_3.new(math.floor(arg_95_0.alpha / 255 * (var_95_13.x - 2) + 0.5), -2)
				local var_95_15 = var_43_3.new(3, var_95_13.y + 4)

				var_43_2.rect_filled(var_95_14, var_95_15, arg_95_0.parent.gui.colors.white)
				var_43_2.rect(var_95_14, var_95_15, arg_95_0.parent.gui.colors.black)

				local var_95_16 = var_95_12 + var_43_3.new(0, var_95_13.y + 5)
				local var_95_17 = var_43_3.new((arg_95_0.picker_area.x - 10) / 2, 19)
				local var_95_18 = var_43_16(arg_95_0.color)

				var_43_2.rect_filled(var_95_16, var_95_17, arg_95_0.parent.gui.colors.dark_background)
				var_43_2.rect(var_95_16, var_95_17, arg_95_0.parent.gui.colors.black, 2)
				var_43_2.text(var_43_24.default, var_95_18, var_95_16 + var_43_3.new(math.floor(var_95_17.x / 2), math.floor(var_95_17.y / 2) - 1), arg_95_0.parent.gui.colors.inactive_text, true)

				local var_95_19 = {
					"Copy",
					"Paste"
				}
				local var_95_20 = var_95_16 + var_43_3.new(var_95_17.x + 5, 0)
				local var_95_21 = var_43_3.new(var_95_17.x / 2, var_95_17.y)

				for iter_95_1 = 1, 2 do
					local var_95_22 = var_43_1.is_mouse_in_bounds(var_95_20, var_95_21) and arg_95_0.parent.gui.colors.hovering_outline or arg_95_0.parent.gui.colors.inactive_outline

					var_43_2.rect_filled(var_95_20, var_95_21, var_95_22, 2)
					var_43_2.rect(var_95_20, var_95_21, arg_95_0.parent.gui.colors.black, 2)
					var_43_2.text(var_43_24.default, var_95_19[iter_95_1], var_95_20 + var_43_3.new(math.floor(var_95_21.x / 2) + 1, math.floor(var_95_21.y / 2) - 1), arg_95_0.parent.gui.colors.inactive_text, true)

					if iter_95_1 == 1 then
						var_84_0.stored.positions.copy_button = var_43_3.new(var_95_20.x, var_95_20.y)
					else
						var_84_0.stored.positions.paste_button = var_43_3.new(var_95_20.x, var_95_20.y)
					end

					var_95_20.x = var_95_20.x + var_95_21.x + 5
				end

				var_84_0.stored.sizes.picker = arg_95_0.picker_area
				var_84_0.stored.sizes.hue_slider = var_95_7
				var_84_0.stored.sizes.alpha_slider = var_95_13
				var_84_0.stored.sizes.copy_button = var_95_21
				var_84_0.stored.sizes.paste_button = var_95_21
			end
		end

		function var_84_0.to_string(arg_96_0)
			return string.format("[ colorpicker ][ %s->%s->%s ] %s : %s", arg_96_0.page, arg_96_0.tab, arg_96_0.section, arg_96_0.name, arg_96_0.color)
		end

		return var_84_0
	end

	function var_43_27.create_checkbox(arg_97_0, arg_97_1, arg_97_2, arg_97_3, arg_97_4, arg_97_5)
		local var_97_0 = {
			_type = var_43_13.checkbox,
			gui = arg_97_0,
			page = arg_97_1,
			tab = arg_97_2,
			section = arg_97_3,
			name = arg_97_4,
			state = arg_97_5
		}

		if var_97_0.state == nil then
			var_97_0.state = false
		end

		var_97_0.defaults = {
			state = var_97_0.state
		}
		var_97_0.visible = true
		var_97_0.render_topmost = false
		var_97_0.check_size = var_43_3.new(13, 13)
		var_97_0.visibility_callbacks = {}
		var_97_0.visibility_requirements = {}
		var_97_0.callbacks = {}
		var_97_0.tooltip = nil

		function var_97_0.set_tooltip(arg_98_0, arg_98_1)
			arg_98_0.tooltip = var_97_0.tooltip == nil and var_43_27.create_tooltip(arg_98_0, arg_98_1) or arg_98_0.tooltip:set(arg_98_1)
		end

		function var_97_0.has_tooltip(arg_99_0)
			return arg_99_0.tooltip ~= nil
		end

		function var_97_0.register_callback(arg_100_0, arg_100_1)
			table.insert(arg_100_0.callbacks, arg_100_1)
		end

		function var_97_0.invoke_callbacks(arg_101_0)
			for iter_101_0 = 1, #arg_101_0.callbacks do
				arg_101_0.callbacks[iter_101_0]()
			end
		end

		function var_97_0.invoke_visibility_callbacks(arg_102_0)
			for iter_102_0 = 1, #arg_102_0.visibility_callbacks do
				arg_102_0.visibility_callbacks[iter_102_0]()
			end
		end

		function var_97_0.set_visibility_requirement(arg_103_0, ...)
			local var_103_0 = {
				...
			}

			var_43_19(arg_103_0, var_103_0)
		end

		var_97_0.extras = {}

		function var_97_0.add_keybind(arg_104_0, arg_104_1, arg_104_2, arg_104_3, arg_104_4)
			local var_104_0 = arg_104_0.gui:add_keybind(arg_104_0, arg_104_1, arg_104_2, arg_104_3, arg_104_4)

			table.insert(arg_104_0.extras, var_104_0)

			return var_104_0
		end

		function var_97_0.add_color_picker(arg_105_0, arg_105_1, arg_105_2)
			local var_105_0 = arg_105_0.gui:add_colorpicker(arg_105_0, arg_105_1, arg_105_2)

			table.insert(arg_105_0.extras, var_105_0)

			return var_105_0
		end

		function var_97_0.get_visual_height(arg_106_0)
			if not var_97_0.visible then
				return 0
			end

			return 20
		end

		function var_97_0.click(arg_107_0)
			arg_107_0.state = not arg_107_0.state

			arg_107_0:invoke_callbacks()
		end

		function var_97_0.set(arg_108_0, arg_108_1)
			arg_108_0.state = arg_108_1

			arg_108_0:invoke_callbacks()
		end

		function var_97_0.set_defaults(arg_109_0)
			arg_109_0:set(var_43_23(arg_109_0.defaults.state))
		end

		function var_97_0.set_visible(arg_110_0, arg_110_1)
			arg_110_0.visible = arg_110_1
		end

		function var_97_0.get(arg_111_0)
			return arg_111_0.state
		end

		function var_97_0.handle(arg_112_0, arg_112_1, arg_112_2)
			if not arg_112_0.visible then
				return false
			end

			if arg_112_1.y < arg_112_0.gui.pos.y then
				return false
			end

			local var_112_0 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)
			local var_112_1 = var_43_2.get_text_size(var_43_24.element, arg_112_0.name).x

			if var_43_1.is_mouse_in_bounds(arg_112_1, var_43_3.new(var_112_1 + 15 + arg_112_0.check_size.x, var_97_0:get_visual_height())) and var_112_0 then
				arg_112_0:click()

				return true
			end

			if arg_112_0:has_tooltip() and arg_112_0.tooltip:in_bounds() then
				return true
			end

			return false
		end

		function var_97_0.render(arg_113_0, arg_113_1, arg_113_2, arg_113_3)
			if not var_97_0.visible then
				return
			end

			local var_113_0 = var_43_2.get_text_size(var_43_24.element, arg_113_0.name).x
			local var_113_1 = var_43_1.is_mouse_in_bounds(arg_113_1, var_43_3.new(var_113_0 + 15 + arg_113_0.check_size.x, var_97_0:get_visual_height()))
			local var_113_2 = arg_113_1 + var_43_3.new(10, 0)
			local var_113_3 = arg_113_0.gui.pos.y

			if var_113_3 < var_113_2.y then
				local var_113_4 = var_97_0.state and arg_113_0.gui.colors.active_outline or var_113_1 and arg_113_0.gui.colors.hovering_outline or arg_113_0.gui.colors.inactive_outline

				var_43_2.rect(var_113_2, var_97_0.check_size, var_113_4, 2)
				var_43_2.rect_filled(var_113_2 + var_43_3.new(1, 1), var_97_0.check_size - var_43_3.new(2, 2), arg_113_0.gui.colors.dark_background)

				if var_97_0.state then
					var_43_2.rect_filled(var_113_2 + var_43_3.new(2, 2), var_97_0.check_size - var_43_3.new(4, 4), var_43_25.accent, 1)
				end

				var_43_2.push_clip(var_113_2, var_43_3.new(arg_113_2 - 10, 15))

				local var_113_5 = var_97_0.state and arg_113_0.gui.colors.active_text or var_113_1 and arg_113_0.gui.colors.hovering_text or arg_113_0.gui.colors.inactive_text
				local var_113_6 = var_113_2 + var_43_3.new(var_97_0.check_size.x + 5, 0)

				var_43_2.text(var_43_24.element, var_97_0.name, var_113_6, var_113_5)
				var_43_2.pop_clip()

				if arg_113_0.tooltip ~= nil then
					local var_113_7 = var_113_6 + var_43_3.new(var_43_2.get_text_size(var_43_24.element, var_97_0.name).x + 3, 0)

					arg_113_0.tooltip:set_pos(var_113_7)
				end
			end

			if arg_113_0.tooltip ~= nil then
				arg_113_0.tooltip:set_render_state(var_113_3 < var_113_2.y)
			end
		end

		function var_97_0.to_string(arg_114_0)
			return string.format("[ checkbox ][ %s->%s->%s ] %s : %s", arg_114_0.page, arg_114_0.tab, arg_114_0.section, arg_114_0.name, arg_114_0.state)
		end

		return var_97_0
	end

	function var_43_27.create_slider(arg_115_0, arg_115_1, arg_115_2, arg_115_3, arg_115_4, arg_115_5, arg_115_6, arg_115_7, arg_115_8)
		local var_115_0 = {
			_type = var_43_13.slider,
			gui = arg_115_0,
			page = arg_115_1,
			tab = arg_115_2,
			section = arg_115_3,
			name = arg_115_4,
			min = math.min(arg_115_5, arg_115_6),
			max = math.max(arg_115_5, arg_115_6)
		}

		var_115_0.value = math.min(math.max(arg_115_7, var_115_0.min), var_115_0.max)
		var_115_0.visual_value = var_115_0.value
		var_115_0.suffix = arg_115_8 == nil and "" or arg_115_8
		var_115_0.defaults = {
			value = var_115_0.value
		}
		var_115_0.render_topmost = false
		var_115_0.visible = true
		var_115_0.height = 13
		var_115_0.title_width = var_43_2.get_text_size(var_43_24.element, var_115_0.name).x
		var_115_0.delta = var_115_0.max - var_115_0.min
		var_115_0.heights = {
			text = 16,
			slider = 13
		}
		var_115_0.visibility_callbacks = {}
		var_115_0.visibility_requirements = {}
		var_115_0.callbacks = {}
		var_115_0.interacting_tooltip = false
		var_115_0.tooltip = nil

		function var_115_0.set_tooltip(arg_116_0, arg_116_1)
			arg_116_0.tooltip = arg_116_0.tooltip == nil and var_43_27.create_tooltip(arg_116_0, arg_116_1) or arg_116_0.tooltip:set(arg_116_1)
		end

		function var_115_0.has_tooltip(arg_117_0)
			return arg_117_0.tooltip ~= nil
		end

		function var_115_0.register_callback(arg_118_0, arg_118_1)
			table.insert(arg_118_0.callbacks, arg_118_1)
		end

		function var_115_0.invoke_callbacks(arg_119_0)
			for iter_119_0 = 1, #arg_119_0.callbacks do
				arg_119_0.callbacks[iter_119_0]()
			end
		end

		function var_115_0.invoke_visibility_callbacks(arg_120_0)
			for iter_120_0 = 1, #arg_120_0.visibility_callbacks do
				arg_120_0.visibility_callbacks[iter_120_0]()
			end
		end

		function var_115_0.set_visibility_requirement(arg_121_0, ...)
			local var_121_0 = {
				...
			}

			var_43_19(arg_121_0, var_121_0)
		end

		var_115_0.extras = {}

		function var_115_0.add_keybind(arg_122_0, arg_122_1, arg_122_2, arg_122_3, arg_122_4)
			local var_122_0 = arg_122_0.gui:add_keybind(arg_122_0, arg_122_1, arg_122_2, arg_122_3, arg_122_4)

			table.insert(arg_122_0.extras, var_122_0)

			return var_122_0
		end

		function var_115_0.add_color_picker(arg_123_0, arg_123_1, arg_123_2)
			local var_123_0 = arg_123_0.gui:add_colorpicker(arg_123_0, arg_123_1, arg_123_2)

			table.insert(arg_123_0.extras, var_123_0)

			return var_123_0
		end

		function var_115_0.get_visual_height(arg_124_0)
			if not var_115_0.visible then
				return 0
			end

			return var_115_0.heights.text + var_115_0.heights.slider + 3
		end

		function var_115_0.set(arg_125_0, arg_125_1)
			var_115_0.value = math.min(math.max(arg_125_1, var_115_0.min), var_115_0.max)
		end

		function var_115_0.set_defaults(arg_126_0)
			var_115_0:set(var_43_23(var_115_0.defaults.value))
		end

		function var_115_0.set_visible(arg_127_0, arg_127_1)
			var_115_0.visible = arg_127_1
		end

		function var_115_0.get(arg_128_0)
			return var_115_0.value
		end

		function var_115_0.handle(arg_129_0, arg_129_1, arg_129_2, arg_129_3)
			if not var_115_0.visible then
				return false
			end

			if arg_129_0.gui.pos.y > arg_129_1.y then
				return false
			end

			local var_129_0 = var_43_1.is_key_held(var_43_0.MOUSE_LEFT)

			if var_43_1.is_mouse_in_bounds(arg_129_1 + var_43_3(0, var_115_0.heights.text), var_43_3.new(arg_129_2 - 10, var_115_0.heights.slider)) and var_129_0 or arg_129_3 and not arg_129_0.interacting_tooltip then
				local var_129_1 = var_43_1.get_mouse_pos() - var_43_3(5, 0)

				if var_129_1.x < arg_129_1.x then
					var_115_0.value = var_115_0.min

					return
				end

				if var_129_1.x > arg_129_1.x + (arg_129_2 - 20) then
					var_115_0.value = var_115_0.max

					return
				end

				local var_129_2 = (var_129_1.x - arg_129_1.x) / (arg_129_2 - 20)

				var_115_0.value = math.floor(var_115_0.min + (var_115_0.max - var_115_0.min) * var_129_2 + 0.5)

				arg_129_0:invoke_callbacks()

				return true
			end

			if arg_129_0:has_tooltip() and arg_129_0.tooltip:in_bounds() then
				arg_129_0.interacting_tooltip = true

				return true
			end

			arg_129_0.interacting_tooltip = false

			return false
		end

		function var_115_0.render(arg_130_0, arg_130_1, arg_130_2, arg_130_3)
			if not var_115_0.visible then
				return
			end

			local var_130_0 = arg_130_0.gui.pos.y

			if var_130_0 < arg_130_1.y then
				var_43_2.text(var_43_24.element, var_115_0.name, arg_130_1 + var_43_3.new(10, 0), arg_130_0.gui.colors.hovering_text)
				var_43_2.text(var_43_24.element, " - " .. var_115_0.value .. var_115_0.suffix, arg_130_1 + var_43_3.new(10 + var_115_0.title_width, 0), arg_130_0.gui.colors.white100)

				if arg_130_0.tooltip ~= nil then
					local var_130_1 = var_43_2.get_text_size(var_43_24.element, " - " .. var_115_0.value .. var_115_0.suffix).x
					local var_130_2 = arg_130_1 + var_43_3.new(10 + var_115_0.title_width + var_130_1 + 3, 0)

					arg_130_0.tooltip:set_pos(var_130_2)
				end
			end

			if arg_130_0.tooltip ~= nil then
				arg_130_0.tooltip:set_render_state(var_130_0 < arg_130_1.y)
			end

			local var_130_3 = var_43_3.new(arg_130_2 - 20, var_115_0.heights.slider)
			local var_130_4 = arg_130_1 + var_43_3.new(10, var_115_0.heights.text)
			local var_130_5 = (var_43_1.is_mouse_in_bounds(var_130_4 - var_43_3(10, 0), var_130_3 + var_43_3.new(10, 0)) or arg_130_3) and not arg_130_0.interacting_tooltip and arg_130_0.gui.colors.hovering_outline or arg_130_0.gui.colors.inactive_outline

			if var_130_0 < var_130_4.y then
				var_43_2.rect_filled(var_130_4, var_130_3, arg_130_0.gui.colors.dark_background, 3)
				var_43_2.rect(var_130_4, var_130_3, var_130_5, 3)

				var_115_0.visual_value = var_115_0.visual_value + (var_115_0.value - var_115_0.visual_value) * 0.1

				local var_130_6 = (var_115_0.visual_value - var_115_0.min) / var_115_0.delta
				local var_130_7 = var_43_3.new(var_130_6 * (var_130_3.x - 4), var_115_0.heights.slider - 4)

				if var_130_7.x < 4 then
					var_130_7.x = 4
				end

				if var_115_0.min < 0 and var_115_0.max > 0 then
					local var_130_8 = math.abs(var_115_0.min) / var_115_0.delta
					local var_130_9 = var_130_4 + var_43_3.new(var_130_8 * var_130_3.x, 0)
					local var_130_10 = var_130_9
					local var_130_11 = var_43_3.new(var_115_0.visual_value / var_115_0.delta * var_130_3.x, var_130_7.y)

					if var_130_11.x < 0 then
						var_130_11.x = var_130_11.x - 1
						var_130_9 = var_130_9 + var_43_3.new(var_130_11.x, 0)
						var_130_9.x = var_130_9.x + 2
						var_130_11.x = math.abs(var_130_11.x)
					end

					if var_130_11.x ~= 0 then
						var_43_2.rect_filled(var_130_9 + var_43_3.new(1, 2), var_130_11 - var_43_3.new(2, 0), var_43_25.accent, 2)
						var_43_2.rect_filled(var_130_10, var_43_3.new(2, var_130_3.y), var_130_5)
					end
				else
					var_43_2.rect_filled(var_130_4 + var_43_3.new(2, 2), var_130_7, var_43_25.accent, 2)
				end
			end
		end

		function var_115_0.to_string(arg_131_0)
			return string.format("[ slider ][ %s->%s->%s ] %s : %s", arg_131_0.page, arg_131_0.tab, arg_131_0.section, arg_131_0.name, arg_131_0.value)
		end

		return var_115_0
	end

	function var_43_27.create_combo(arg_132_0, arg_132_1, arg_132_2, arg_132_3, arg_132_4, arg_132_5, arg_132_6)
		local var_132_0 = {
			_type = var_43_13.combo,
			gui = arg_132_0,
			page = arg_132_1,
			tab = arg_132_2,
			section = arg_132_3,
			name = arg_132_4
		}

		var_132_0.visible = true
		var_132_0.items = arg_132_5
		var_132_0.name_to_index = {}

		for iter_132_0 = 1, #arg_132_5 do
			local var_132_1 = arg_132_5[iter_132_0]

			var_132_0.name_to_index[var_132_1] = iter_132_0
		end

		var_132_0.value = arg_132_6 == nil and 1 or type(arg_132_6) == "string" and var_132_0.name_to_index[arg_132_6] or arg_132_6
		var_132_0.defaults = {
			value = var_132_0.value
		}
		var_132_0.open = false
		var_132_0.render_topmost = true
		var_132_0.last_interaction_time = 0
		var_132_0.open_time = 0.5
		var_132_0.heights = {
			combo = 18,
			text = 16,
			item = 18
		}
		var_132_0.visibility_callbacks = {}
		var_132_0.visibility_requirements = {}
		var_132_0.callbacks = {}
		var_132_0.tooltip = nil
		var_132_0.interacting_tooltip = false

		function var_132_0.set_tooltip(arg_133_0, arg_133_1)
			arg_133_0.tooltip = var_132_0.tooltip == nil and var_43_27.create_tooltip(arg_133_0, arg_133_1) or arg_133_0.tooltip:set(arg_133_1)
		end

		function var_132_0.has_tooltip(arg_134_0)
			return arg_134_0.tooltip ~= nil
		end

		function var_132_0.register_callback(arg_135_0, arg_135_1)
			table.insert(arg_135_0.callbacks, arg_135_1)
		end

		function var_132_0.invoke_callbacks(arg_136_0)
			for iter_136_0 = 1, #arg_136_0.callbacks do
				arg_136_0.callbacks[iter_136_0]()
			end
		end

		function var_132_0.invoke_visibility_callbacks(arg_137_0)
			for iter_137_0 = 1, #arg_137_0.visibility_callbacks do
				arg_137_0.visibility_callbacks[iter_137_0]()
			end
		end

		function var_132_0.set_visibility_requirement(arg_138_0, ...)
			local var_138_0 = {
				...
			}

			var_43_19(arg_138_0, var_138_0)
		end

		var_132_0.extras = {}

		function var_132_0.add_keybind(arg_139_0, arg_139_1, arg_139_2, arg_139_3, arg_139_4)
			local var_139_0 = arg_139_0.gui:add_keybind(arg_139_0, arg_139_1, arg_139_2, arg_139_3, arg_139_4)

			table.insert(arg_139_0.extras, var_139_0)

			return var_139_0
		end

		function var_132_0.add_color_picker(arg_140_0, arg_140_1, arg_140_2)
			local var_140_0 = arg_140_0.gui:add_colorpicker(arg_140_0, arg_140_1, arg_140_2)

			table.insert(arg_140_0.extras, var_140_0)

			return var_140_0
		end

		function var_132_0.get_visual_height(arg_141_0)
			if not arg_141_0.visible then
				return 0
			end

			return 40
		end

		function var_132_0.set_visible(arg_142_0, arg_142_1)
			arg_142_0.visible = arg_142_1
		end

		function var_132_0.set(arg_143_0, arg_143_1)
			if type(arg_143_1) == "string" then
				arg_143_0.value = arg_143_0.name_to_index[arg_143_1] or 1
			elseif type(arg_143_1) == "number" then
				arg_143_0.value = arg_143_1
			else
				arg_143_0.value = 1
			end

			arg_143_0:invoke_callbacks()
		end

		function var_132_0.set_defaults(arg_144_0)
			arg_144_0:set(var_43_23(arg_144_0.defaults.value))
		end

		function var_132_0.get(arg_145_0)
			return arg_145_0.value, arg_145_0.items[arg_145_0.value]
		end

		function var_132_0.update_items(arg_146_0, arg_146_1)
			arg_146_0.items = arg_146_1
			arg_146_0.name_to_index = {}

			for iter_146_0 = 1, #arg_146_1 do
				local var_146_0 = arg_146_1[iter_146_0]

				arg_146_0.name_to_index[var_146_0] = iter_146_0
			end

			arg_146_0.value = 1
		end

		function var_132_0.get_items(arg_147_0)
			return arg_147_0.items
		end

		function var_132_0.handle(arg_148_0, arg_148_1, arg_148_2, arg_148_3)
			if not arg_148_0.visible then
				return false
			end

			if arg_148_0.gui.pos.y > arg_148_1.y then
				arg_148_0.open = false

				return false
			end

			local var_148_0 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)
			local var_148_1 = var_43_1.is_mouse_in_bounds(arg_148_1 + var_43_3(0, var_132_0.heights.text), var_43_3.new(arg_148_2, arg_148_0.heights.combo))
			local var_148_2 = var_43_1.is_mouse_in_bounds(arg_148_1 + var_43_3(0, arg_148_0.heights.text + arg_148_0.heights.item), var_43_3.new(arg_148_2, arg_148_0.heights.item * #arg_148_0.items))
			local var_148_3 = (globals.real_time() - arg_148_0.last_interaction_time) / arg_148_0.open_time >= 0.5

			if var_148_1 and var_148_0 then
				arg_148_0.open = not arg_148_0.open
				arg_148_0.last_interaction_time = globals.real_time()

				return true
			elseif var_148_3 and var_148_2 and var_148_0 and arg_148_0.open then
				local var_148_4 = var_43_1.get_mouse_pos().y - arg_148_1.y - (arg_148_0.heights.text + arg_148_0.heights.item) - 1
				local var_148_5 = math.floor(var_148_4 / arg_148_0.heights.item) + 1

				arg_148_0:set(var_148_5)

				arg_148_0.open = false
				arg_148_0.last_interaction_time = globals.real_time()

				return true
			elseif var_148_0 and arg_148_0.open then
				arg_148_0.open = false
				arg_148_0.last_interaction_time = globals.real_time()
			end

			if arg_148_0:has_tooltip() and arg_148_0.tooltip:in_bounds() then
				arg_148_0.interacting_tooltip = true

				return true
			end

			arg_148_0.interacting_tooltip = false

			return not var_148_3
		end

		function var_132_0.render(arg_149_0, arg_149_1, arg_149_2, arg_149_3)
			if not arg_149_0.visible then
				return
			end

			local var_149_0 = arg_149_0.gui.pos.y

			if var_149_0 < arg_149_1.y then
				var_43_2.text(var_43_24.element, arg_149_0.name, arg_149_1 + var_43_3.new(10, 0), arg_149_0.gui.colors.hovering_text)

				if arg_149_0.tooltip ~= nil and arg_149_0.tooltip ~= "" then
					local var_149_1 = arg_149_1 + var_43_3.new(10 + var_43_2.get_text_size(var_43_24.element, arg_149_0.name).x + 3, 0)

					arg_149_0.tooltip:set_pos(var_149_1)
				end
			end

			if arg_149_0.tooltip ~= nil then
				arg_149_0.tooltip:set_render_state(var_149_0 < arg_149_1.y)
			end

			local var_149_2 = var_43_3.new(arg_149_2 - 20, arg_149_0.heights.combo)
			local var_149_3 = arg_149_1 + var_43_3.new(10, arg_149_0.heights.text)
			local var_149_4 = var_43_1.is_mouse_in_bounds(var_149_3 - var_43_3(10, 0), var_149_2 + var_43_3.new(10, 0)) or arg_149_3
			local var_149_5 = not (not (var_149_4 and not arg_149_0.interacting_tooltip) and not arg_149_0.open) and arg_149_0.gui.colors.hovering_outline or arg_149_0.gui.colors.inactive_outline
			local var_149_6 = (globals.real_time() - arg_149_0.last_interaction_time) / arg_149_0.open_time
			local var_149_7 = var_43_12.out_exponent(var_149_6)

			if not arg_149_0.open then
				var_149_7 = 1 - var_149_7
			end

			if arg_149_0.open or var_149_6 < 1 then
				var_149_2.y = var_149_2.y * (#arg_149_0.items + 1)
			end

			if var_149_6 < 1 or arg_149_0.open then
				var_149_2.y = var_149_2.y * var_149_7

				if var_149_2.y < 18 then
					var_149_2.y = 18
				end
			end

			local var_149_8 = math.max(var_149_3.y, var_149_0)

			var_43_2.push_clip(var_43_3.new(var_149_3.x, var_149_8), var_149_2 - var_43_3(1, 1))

			if var_149_0 < var_149_3.y + var_149_2.y then
				var_43_2.rect_filled(var_149_3, var_149_2, arg_149_0.gui.colors.dark_background, 3)
				var_43_2.rect(var_149_3, var_149_2 - var_43_3.new(1, 1), var_149_5, 3)

				local var_149_9 = var_149_4 and not arg_149_0.interacting_tooltip and arg_149_0.gui.colors.hovering_text or arg_149_0.gui.colors.inactive_text

				var_149_3.y = var_149_3.y + 1
				arg_149_0.value = math.clamp(arg_149_0.value, 1, #arg_149_0.items)

				var_43_2.text(var_43_24.element, arg_149_0.items[arg_149_0.value], var_149_3 + var_43_3.new(8, 0), var_149_9)
			end

			var_43_2.pop_clip()

			if var_149_6 < 1 or arg_149_0.open then
				var_43_2.push_clip(var_149_3, var_149_2 - var_43_3(1, 1))

				for iter_149_0 = 1, #arg_149_0.items do
					local var_149_10 = arg_149_0.items[iter_149_0]
					local var_149_11 = var_149_3 + var_43_3.new(0, arg_149_0.heights.item * iter_149_0)
					local var_149_12 = var_43_1.is_mouse_in_bounds(var_149_11, var_43_3.new(var_149_2.x, arg_149_0.heights.item))
					local var_149_13 = iter_149_0 == arg_149_0.value and var_43_25.accent or var_149_12 and arg_149_0.gui.colors.hovering_text or arg_149_0.gui.colors.inactive_text

					if var_149_0 < var_149_11.y then
						var_43_2.text(var_43_24.element, var_149_10, var_149_11 + var_43_3.new(8, 0), var_149_13)
					end
				end

				var_43_2.pop_clip()
			end

			if var_149_0 < var_149_3.y then
				var_43_2.rect_fade(var_149_3 + var_43_3.new(var_149_2.x - 60, 1), var_43_3.new(58, var_149_2.y - 4), var_43_4.new(arg_149_0.gui.colors.dark_background.r, arg_149_0.gui.colors.dark_background.g, arg_149_0.gui.colors.dark_background.b, 0), arg_149_0.gui.colors.dark_background, true)

				if var_149_6 < 1 or arg_149_0.open then
					local var_149_14 = var_43_4.new(math.floor(var_149_5.r), math.floor(var_149_5.g), math.floor(var_149_5.b), math.floor(math.clamp(255 * var_149_7, 0, 255)))

					var_43_2.line(var_149_3 + var_43_3.new(var_149_2.x / 2 * (1 - var_149_7), arg_149_0.heights.item), var_149_3 + var_43_3.new(var_149_2.x / 2 + var_149_7 * var_149_2.x / 2, arg_149_0.heights.item), var_149_14)
				end
			end

			local var_149_15 = var_149_4 and not arg_149_0.interacting_tooltip and arg_149_0.gui.colors.hovering_text or arg_149_0.gui.colors.inactive_text
			local var_149_16 = var_43_3.new(6, 3)
			local var_149_17 = var_149_3 + var_43_3.new(var_149_2.x - var_149_16.x * 2, 0) + var_43_3.new(0, 6)
			local var_149_18 = {
				var_43_3.new(var_149_17.x, var_149_17.y),
				var_43_3.new(var_149_17.x + var_149_16.x, var_149_17.y),
				var_43_3.new(var_149_17.x + var_149_16.x / 2, var_149_17.y + var_149_16.y)
			}
			local var_149_19 = {
				var_43_3.new(var_149_17.x + 1, var_149_17.y + var_149_16.y),
				var_43_3.new(var_149_17.x + var_149_16.x - 1, var_149_17.y + var_149_16.y),
				var_43_3.new(var_149_17.x + var_149_16.x / 2, var_149_17.y + 1)
			}

			if var_149_0 < var_149_17.y then
				var_43_2.polygon(arg_149_0.open and var_149_19 or var_149_18, var_149_15)
			end

			var_43_2.pop_clip()
		end

		function var_132_0.to_string(arg_150_0)
			return string.format("[ combo ][ %s->%s->%s ] %s : %s", arg_150_0.page, arg_150_0.tab, arg_150_0.section, arg_150_0.name, arg_150_0.items[arg_150_0.value])
		end

		return var_132_0
	end

	function var_43_27.create_multi_combo(arg_151_0, arg_151_1, arg_151_2, arg_151_3, arg_151_4, arg_151_5, arg_151_6)
		local var_151_0 = {
			_type = var_43_13.multicombo,
			gui = arg_151_0,
			page = arg_151_1,
			tab = arg_151_2,
			section = arg_151_3,
			name = arg_151_4
		}

		var_151_0.visible = true
		var_151_0.items = arg_151_5
		var_151_0.name_to_index = {}
		var_151_0.open = false
		var_151_0.render_topmost = true
		var_151_0.last_interaction_time = 0
		var_151_0.open_time = 0.5
		var_151_0.heights = {
			combo = 18,
			text = 16,
			item = 18,
			lower_pad = 3
		}
		var_151_0.visibility_callbacks = {}
		var_151_0.visibility_requirements = {}
		var_151_0.callbacks = {}
		var_151_0.tooltip = nil
		var_151_0.interacting_tooltip = false

		function var_151_0.set_tooltip(arg_152_0, arg_152_1)
			arg_152_0.tooltip = arg_152_0.tooltip == nil and var_43_27.create_tooltip(arg_152_0, arg_152_1) or arg_152_0.tooltip:set(arg_152_1)
		end

		function var_151_0.has_tooltip(arg_153_0)
			return arg_153_0.tooltip ~= nil
		end

		function var_151_0.register_callback(arg_154_0, arg_154_1)
			table.insert(arg_154_0.callbacks, arg_154_1)
		end

		function var_151_0.invoke_callbacks(arg_155_0)
			for iter_155_0 = 1, #arg_155_0.callbacks do
				arg_155_0.callbacks[iter_155_0]()
			end
		end

		function var_151_0.invoke_visibility_callbacks(arg_156_0)
			for iter_156_0 = 1, #arg_156_0.visibility_callbacks do
				arg_156_0.visibility_callbacks[iter_156_0]()
			end
		end

		function var_151_0.set_visibility_requirement(arg_157_0, ...)
			local var_157_0 = {
				...
			}

			var_43_19(arg_157_0, var_157_0)
		end

		var_151_0.extras = {}

		function var_151_0.add_keybind(arg_158_0, arg_158_1, arg_158_2, arg_158_3, arg_158_4)
			local var_158_0 = arg_158_0.gui:add_keybind(arg_158_0, arg_158_1, arg_158_2, arg_158_3, arg_158_4)

			table.insert(arg_158_0.extras, var_158_0)

			return var_158_0
		end

		function var_151_0.add_color_picker(arg_159_0, arg_159_1, arg_159_2)
			local var_159_0 = arg_159_0.gui:add_colorpicker(arg_159_0, arg_159_1, arg_159_2)

			table.insert(arg_159_0.extras, var_159_0)

			return var_159_0
		end

		var_151_0.values = {}

		for iter_151_0 = 1, #arg_151_5 do
			local var_151_1 = arg_151_5[iter_151_0]

			var_151_0.name_to_index[var_151_1] = iter_151_0
			var_151_0.values[iter_151_0] = false
		end

		if arg_151_6 == nil then
			-- block empty
		elseif type(arg_151_6) == "string" then
			local var_151_2 = var_151_0.name_to_index[arg_151_6]

			if var_151_2 ~= nil then
				var_151_0.values[var_151_2] = true
			end
		elseif type(arg_151_6) == "number" then
			var_151_0.values[arg_151_6] = true
		elseif type(arg_151_6) == "table" then
			for iter_151_1 = 1, #arg_151_6 do
				local var_151_3 = arg_151_6[iter_151_1]

				if type(var_151_3) == "number" then
					var_151_0.values[var_151_3] = true
				else
					local var_151_4 = var_151_0.name_to_index[arg_151_6]

					if var_151_4 ~= nil then
						var_151_0.values[var_151_4] = true
					end
				end
			end
		end

		var_151_0.defaults = {
			values = var_43_23(var_151_0.values)
		}

		function var_151_0.get_visual_height(arg_160_0)
			if not arg_160_0.visible then
				return 0
			end

			return arg_160_0.heights.text + arg_160_0.heights.combo + arg_160_0.heights.lower_pad
		end

		function var_151_0.set_visible(arg_161_0, arg_161_1)
			arg_161_0.visible = arg_161_1
		end

		function var_151_0.set(arg_162_0, arg_162_1, arg_162_2)
			if type(arg_162_1) == "string" then
				arg_162_1 = arg_162_0.name_to_index[arg_162_1]
			end

			arg_162_0.values[arg_162_1] = arg_162_2

			arg_162_0:invoke_callbacks()
		end

		function var_151_0.set_defaults(arg_163_0)
			arg_163_0.values = var_43_23(arg_163_0.defaults.values)
		end

		function var_151_0.toggle(arg_164_0, arg_164_1)
			if type(arg_164_1) == "string" then
				arg_164_1 = arg_164_0.name_to_index[arg_164_1]
			end

			arg_164_0.values[arg_164_1] = not arg_164_0.values[arg_164_1]

			arg_164_0:invoke_callbacks()
		end

		function var_151_0.get(arg_165_0, arg_165_1)
			if type(arg_165_1) == "string" then
				arg_165_1 = arg_165_0.name_to_index[arg_165_1]
			end

			return arg_165_0.values[arg_165_1]
		end

		function var_151_0.get_items(arg_166_0)
			return arg_166_0.items
		end

		function var_151_0.update_items(arg_167_0, arg_167_1)
			arg_167_0.items = arg_167_1
			arg_167_0.values = {}
			arg_167_0.name_to_index = {}

			for iter_167_0 = 1, #arg_167_1 do
				local var_167_0 = arg_167_1[iter_167_0]

				arg_167_0.name_to_index[var_167_0] = iter_167_0
				arg_167_0.values[iter_167_0] = false
			end
		end

		function var_151_0.handle(arg_168_0, arg_168_1, arg_168_2, arg_168_3)
			if not arg_168_0.visible then
				return false
			end

			local var_168_0 = arg_168_0.gui.pos.y
			local var_168_1 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)
			local var_168_2 = arg_168_1 + var_43_3(0, arg_168_0.heights.text)
			local var_168_3 = var_43_1.is_mouse_in_bounds(var_168_2, var_43_3.new(arg_168_2, arg_168_0.heights.combo))
			local var_168_4 = arg_168_1 + var_43_3(0, arg_168_0.heights.text + arg_168_0.heights.item)
			local var_168_5 = var_43_1.is_mouse_in_bounds(var_168_4, var_43_3.new(arg_168_2, arg_168_0.heights.item * #arg_168_0.items))
			local var_168_6 = (globals.real_time() - arg_168_0.last_interaction_time) / arg_168_0.open_time >= 0.5
			local var_168_7 = true

			for iter_168_0 = 1, #arg_168_0.values do
				if not arg_168_0.values[iter_168_0] then
					var_168_7 = false

					break
				end
			end

			local var_168_8 = var_43_2.get_text_size(var_43_24.element, var_168_7 and "deselect all" or "select all")
			local var_168_9 = arg_168_1 + var_43_3.new(arg_168_2, arg_168_0.heights.text) - var_43_3.new(var_168_8.x + 10 + 12 + 10, 0)
			local var_168_10 = var_43_3.new(var_168_8.x, arg_168_0.heights.combo)

			if var_43_1.is_mouse_in_bounds(var_168_9, var_168_10) and var_168_1 and var_168_6 and arg_168_0.open then
				for iter_168_1 = 1, #arg_168_0.items do
					arg_168_0:set(iter_168_1, not var_168_7)
				end

				arg_168_0.open = false
				arg_168_0.last_interaction_time = globals.real_time()

				return true
			end

			if var_168_0 > var_168_4.y then
				arg_168_0.open = false

				return false
			end

			if var_168_3 and var_168_1 and var_168_0 < var_168_2.y then
				arg_168_0.open = not arg_168_0.open
				arg_168_0.last_interaction_time = globals.real_time()

				return true
			elseif var_168_6 and var_168_5 and var_168_1 and arg_168_0.open and var_168_0 < var_168_4.y then
				local var_168_11 = var_43_1.get_mouse_pos().y - arg_168_1.y - (arg_168_0.heights.text + arg_168_0.heights.item) - 1
				local var_168_12 = math.floor(var_168_11 / arg_168_0.heights.item) + 1

				arg_168_0:toggle(var_168_12)

				return true
			elseif var_168_1 and arg_168_0.open then
				arg_168_0.open = false
				arg_168_0.last_interaction_time = globals.real_time()
			end

			if arg_168_0:has_tooltip() and arg_168_0.tooltip:in_bounds() then
				arg_168_0.interacting_tooltip = true

				return true
			end

			arg_168_0.interacting_tooltip = false

			return not var_168_6 or arg_168_0.open and var_168_5
		end

		function var_151_0.render(arg_169_0, arg_169_1, arg_169_2, arg_169_3)
			if not arg_169_0.visible then
				return
			end

			local var_169_0 = arg_169_0.gui.pos.y

			if var_169_0 < arg_169_1.y then
				var_43_2.text(var_43_24.element, arg_169_0.name, arg_169_1 + var_43_3.new(10, 0), arg_169_0.gui.colors.hovering_text)

				if arg_169_0.tooltip ~= nil and arg_169_0.tooltip ~= "" then
					local var_169_1 = arg_169_1 + var_43_3.new(10 + var_43_2.get_text_size(var_43_24.element, arg_169_0.name).x + 3, 0)

					arg_169_0.tooltip:set_pos(var_169_1)
				end
			end

			if arg_169_0.tooltip ~= nil then
				arg_169_0.tooltip:set_render_state(var_169_0 < arg_169_1.y)
			end

			local var_169_2 = var_43_3.new(arg_169_2 - 20, arg_169_0.heights.combo)
			local var_169_3 = arg_169_1 + var_43_3.new(10, arg_169_0.heights.text)

			if var_169_0 > var_169_3.y then
				return
			end

			local var_169_4 = var_43_1.is_mouse_in_bounds(var_169_3 - var_43_3(10, 0), var_169_2 + var_43_3.new(10, 0)) or arg_169_3
			local var_169_5 = not (not (var_169_4 and not arg_169_0.interacting_tooltip) and not arg_169_0.open) and arg_169_0.gui.colors.hovering_outline or arg_169_0.gui.colors.inactive_outline
			local var_169_6 = (globals.real_time() - arg_169_0.last_interaction_time) / arg_169_0.open_time
			local var_169_7 = var_43_12.out_exponent(var_169_6)

			if not arg_169_0.open then
				var_169_7 = 1 - var_169_7
			end

			if arg_169_0.open or var_169_6 < 1 then
				var_169_2.y = var_169_2.y * (#arg_169_0.items + 1)
			end

			if var_169_6 < 1 or arg_169_0.open then
				var_169_2.y = var_169_2.y * var_169_7

				if var_169_2.y < 18 then
					var_169_2.y = 18
				end
			end

			var_43_2.rect_filled(var_169_3, var_169_2, arg_169_0.gui.colors.dark_background, 3)
			var_43_2.rect(var_169_3, var_169_2, var_169_5, 3)
			var_43_2.push_clip(var_169_3, var_169_2 - var_43_3(1, 1))

			local var_169_8 = var_169_4 and not arg_169_0.interacting_tooltip and not arg_169_0.open and arg_169_0.gui.colors.hovering_text or arg_169_0.gui.colors.inactive_text

			var_169_3.y = var_169_3.y + 1

			local var_169_9 = {}

			for iter_169_0 = 1, #arg_169_0.items do
				if arg_169_0.values[iter_169_0] then
					table.insert(var_169_9, arg_169_0.items[iter_169_0])
				end
			end

			if #var_169_9 == 0 then
				table.insert(var_169_9, "-")
			end

			var_43_2.text(var_43_24.element, table.concat(var_169_9, ", "), var_169_3 + var_43_3.new(8, 0), var_169_8)

			if var_169_6 < 1 or arg_169_0.open then
				for iter_169_1 = 1, #arg_169_0.items do
					local var_169_10 = arg_169_0.items[iter_169_1]
					local var_169_11 = var_169_3 + var_43_3.new(0, arg_169_0.heights.item * iter_169_1)
					local var_169_12 = var_43_1.is_mouse_in_bounds(var_169_11, var_43_3.new(var_169_2.x, arg_169_0.heights.item))
					local var_169_13 = arg_169_0.values[iter_169_1] and var_43_25.accent or var_169_12 and arg_169_0.gui.colors.hovering_text or arg_169_0.gui.colors.inactive_text

					var_43_2.text(var_43_24.element, var_169_10, var_169_11 + var_43_3.new(8, 0), var_169_13)
				end
			end

			var_43_2.rect_fade(var_169_3 + var_43_3.new(var_169_2.x - 60, 2), var_43_3.new(59, var_169_2.y - 6), var_43_4.new(arg_169_0.gui.colors.dark_background.r, arg_169_0.gui.colors.dark_background.g, arg_169_0.gui.colors.dark_background.b, 0), arg_169_0.gui.colors.dark_background, true)

			local var_169_14 = var_169_4 and not arg_169_0.interacting_tooltip and arg_169_0.gui.colors.hovering_text or arg_169_0.gui.colors.inactive_text
			local var_169_15 = var_43_3.new(6, 3)
			local var_169_16 = var_169_3 + var_43_3.new(var_169_2.x - var_169_15.x * 2, 0)
			local var_169_17 = var_169_16 + var_43_3.new(0, 6)
			local var_169_18 = {
				var_43_3.new(var_169_17.x, var_169_17.y),
				var_43_3.new(var_169_17.x + var_169_15.x, var_169_17.y),
				var_43_3.new(var_169_17.x + var_169_15.x / 2, var_169_17.y + var_169_15.y)
			}
			local var_169_19 = {
				var_43_3.new(var_169_17.x + 1, var_169_17.y + var_169_15.y),
				var_43_3.new(var_169_17.x + var_169_15.x - 1, var_169_17.y + var_169_15.y),
				var_43_3.new(var_169_17.x + var_169_15.x / 2, var_169_17.y + 1)
			}

			if var_169_0 < var_169_17.y then
				var_43_2.polygon(arg_169_0.open and var_169_19 or var_169_18, var_169_14)
			end

			if var_169_6 < 1 or arg_169_0.open then
				local var_169_20 = math.floor(math.clamp(var_169_7 * 255, 0, 255))
				local var_169_21 = true

				for iter_169_2 = 1, #arg_169_0.values do
					if not arg_169_0.values[iter_169_2] then
						var_169_21 = false

						break
					end
				end

				local var_169_22 = var_169_21 and "deselect all" or "select all"
				local var_169_23 = var_43_2.get_text_size(var_43_24.element, var_169_22)
				local var_169_24 = var_169_16 - var_43_3.new(var_169_23.x + 8, -2)
				local var_169_25 = var_169_24 - var_43_3.new(6, 2)
				local var_169_26 = var_43_3.new(var_169_23.x + 8 + 6, arg_169_0.heights.combo)
				local var_169_27 = var_43_4.new(arg_169_0.gui.colors.dark_background.r, arg_169_0.gui.colors.dark_background.g, arg_169_0.gui.colors.dark_background.b, var_169_20)

				var_43_2.rect_filled(var_169_25, var_169_26, var_169_27, 2)

				local var_169_28 = var_43_4.new(arg_169_0.gui.colors.active_outline.r, arg_169_0.gui.colors.active_outline.g, arg_169_0.gui.colors.active_outline.b, var_169_20)

				var_43_2.line(var_169_25, var_169_25 + var_43_3.new(0, var_169_26.y), var_169_28)

				local var_169_29 = var_43_1.is_mouse_in_bounds(var_169_24, var_169_26) and arg_169_0.gui.colors.hovering_text or arg_169_0.gui.colors.inactive_text
				local var_169_30 = var_43_4.new(var_169_29.r, var_169_29.g, var_169_29.b, var_169_20)

				var_43_2.text(var_43_24.element, var_169_22, var_169_24, var_169_30)
			end

			if var_169_6 < 1 or arg_169_0.open then
				local var_169_31 = var_43_4.new(math.floor(var_169_5.r), math.floor(var_169_5.g), math.floor(var_169_5.b), math.floor(255 * var_169_7))

				var_43_2.line(var_169_3 + var_43_3.new(var_169_2.x / 2 * (1 - var_169_7), arg_169_0.heights.item), var_169_3 + var_43_3.new(var_169_2.x / 2 + var_169_7 * var_169_2.x / 2, arg_169_0.heights.item), var_169_31)
			end

			var_43_2.pop_clip()
		end

		function var_151_0.to_string(arg_170_0)
			return string.format("[ multicombo ][ %s->%s->%s ] %s : %s", arg_170_0.page, arg_170_0.tab, arg_170_0.section, arg_170_0.name, table.concat(arg_170_0.values, ", "))
		end

		return var_151_0
	end

	function var_43_27.create_text_input(arg_171_0, arg_171_1, arg_171_2, arg_171_3, arg_171_4, arg_171_5)
		local var_171_0 = {
			_type = var_43_13.text_input,
			gui = arg_171_0,
			page = arg_171_1,
			tab = arg_171_2,
			section = arg_171_3,
			name = arg_171_4
		}

		var_171_0.visible = true
		var_171_0.focusing = false
		var_171_0.heights = {
			text = 16,
			lower_pad = 3,
			input = 18
		}
		var_171_0.visibility_callbacks = {}
		var_171_0.visibility_requirements = {}
		var_171_0.callbacks = {}
		var_171_0.tooltip = nil
		var_171_0.interacting_tooltip = false

		function var_171_0.set_tooltip(arg_172_0, arg_172_1)
			arg_172_0.tooltip = arg_172_0.tooltip == nil and var_43_27.create_tooltip(arg_172_0, arg_172_1) or arg_172_0.tooltip:set(arg_172_1)
		end

		function var_171_0.has_tooltip(arg_173_0)
			return arg_173_0.tooltip ~= nil
		end

		function var_171_0.register_callback(arg_174_0, arg_174_1)
			table.insert(arg_174_0.callbacks, arg_174_1)
		end

		function var_171_0.invoke_callbacks(arg_175_0)
			for iter_175_0 = 1, #arg_175_0.callbacks do
				arg_175_0.callbacks[iter_175_0]()
			end
		end

		function var_171_0.invoke_visibility_callbacks(arg_176_0)
			for iter_176_0 = 1, #arg_176_0.visibility_callbacks do
				arg_176_0.visibility_callbacks[iter_176_0]()
			end
		end

		function var_171_0.set_visibility_requirement(arg_177_0, ...)
			local var_177_0 = {
				...
			}

			var_43_19(arg_177_0, var_177_0)
		end

		var_171_0.extras = {}

		function var_171_0.add_keybind(arg_178_0, arg_178_1, arg_178_2, arg_178_3, arg_178_4)
			local var_178_0 = arg_178_0.gui:add_keybind(arg_178_0, arg_178_1, arg_178_2, arg_178_3, arg_178_4)

			table.insert(arg_178_0.extras, var_178_0)

			return var_178_0
		end

		function var_171_0.add_color_picker(arg_179_0, arg_179_1, arg_179_2)
			local var_179_0 = arg_179_0.gui:add_colorpicker(arg_179_0, arg_179_1, arg_179_2)

			table.insert(arg_179_0.extras, var_179_0)

			return var_179_0
		end

		var_171_0.render_topmost = false
		var_171_0.last_backspace_input = 0
		var_171_0.value = arg_171_5 or ""
		var_171_0.defaults = {
			value = var_43_23(var_171_0.value)
		}

		function var_171_0.set(arg_180_0, arg_180_1)
			var_171_0.value = arg_180_1
		end

		function var_171_0.set_defaults(arg_181_0)
			var_171_0.value = var_43_23(var_171_0.defaults.value)
		end

		function var_171_0.get(arg_182_0)
			return var_171_0.value
		end

		function var_171_0.set_visible(arg_183_0, arg_183_1)
			var_171_0.visible = arg_183_1
		end

		function var_171_0.get_visual_height(arg_184_0)
			if not arg_184_0.visible then
				return 0
			end

			return arg_184_0.heights.text + arg_184_0.heights.input + arg_184_0.heights.lower_pad
		end

		function var_171_0.handle(arg_185_0, arg_185_1, arg_185_2, arg_185_3)
			if not arg_185_0.visible then
				return false
			end

			local var_185_0 = arg_185_0.gui.pos.y
			local var_185_1 = arg_185_1 + var_43_3(0, arg_185_0.heights.text)

			if var_185_0 > var_185_1.y then
				arg_185_0.focusing = false

				return false
			end

			local var_185_2 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)

			if var_43_1.is_mouse_in_bounds(var_185_1, var_43_3.new(arg_185_2, arg_185_0.heights.input)) and var_185_2 then
				arg_185_0.focusing = true
			elseif var_185_2 then
				arg_185_0:invoke_callbacks()

				arg_185_0.focusing = false
			end

			if arg_185_0.focusing then
				local var_185_3 = var_43_1.is_key_pressed(var_43_0.KEY_BACKSPACE)
				local var_185_4 = var_43_1.is_key_pressed(var_43_0.KEY_ENTER)

				if var_185_3 then
					arg_185_0.last_backspace_input = globals.real_time()
				end

				if var_185_3 then
					arg_185_0.value = arg_185_0.value:sub(1, #arg_185_0.value - 1)
				elseif var_185_4 then
					arg_185_0:invoke_callbacks()

					arg_185_0.focusing = false
				else
					local var_185_5 = var_43_1.get_input_text()

					if var_185_5 ~= "" then
						arg_185_0.value = arg_185_0.value .. var_185_5
					end
				end

				if var_43_1.is_key_held(var_43_0.KEY_BACKSPACE) and globals.real_time() - arg_185_0.last_backspace_input > 0.15 then
					arg_185_0.value = arg_185_0.value:sub(1, #arg_185_0.value - 1)
					arg_185_0.last_backspace_input = globals.real_time()
				end
			end

			if arg_185_0:has_tooltip() and arg_185_0.tooltip:in_bounds() then
				arg_185_0.interacting_tooltip = true

				return true
			end

			arg_185_0.interacting_tooltip = false

			return arg_185_0.focusing
		end

		function var_171_0.render(arg_186_0, arg_186_1, arg_186_2, arg_186_3)
			if not arg_186_0.visible then
				return
			end

			local var_186_0 = arg_186_0.gui.pos.y

			if var_186_0 < arg_186_1.y then
				var_43_2.text(var_43_24.element, arg_186_0.name, arg_186_1 + var_43_3.new(10, 0), arg_186_0.gui.colors.hovering_text)

				if arg_186_0.tooltip ~= nil and arg_186_0.tooltip ~= "" then
					local var_186_1 = arg_186_1 + var_43_3.new(10 + var_43_2.get_text_size(var_43_24.element, arg_186_0.name).x + 3, 0)

					arg_186_0.tooltip:set_pos(var_186_1)
				end
			end

			if arg_186_0.tooltip ~= nil then
				arg_186_0.tooltip:set_render_state(var_186_0 < arg_186_1.y)
			end

			local var_186_2 = var_43_3.new(arg_186_2 - 20, arg_186_0.heights.input)
			local var_186_3 = arg_186_1 + var_43_3.new(10, arg_186_0.heights.text)

			if var_186_0 < var_186_3.y then
				local var_186_4 = var_43_1.is_mouse_in_bounds(var_186_3 - var_43_3(10, 0), var_186_2 + var_43_3.new(10, 0)) or arg_186_3
				local var_186_5 = var_186_4 and not arg_186_0.interacting_tooltip and arg_186_0.gui.colors.hovering_outline or arg_186_0.gui.colors.inactive_outline

				var_43_2.rect_filled(var_186_3, var_186_2, arg_186_0.gui.colors.dark_background, 3)
				var_43_2.rect(var_186_3, var_186_2, var_186_5, 3)
				var_43_2.push_clip(var_186_3, var_186_2 - var_43_3(1, 1))

				local var_186_6 = arg_186_0.focusing and arg_186_0.value .. (globals.real_time() % 1 > 0.5 and "_" or "  ") or arg_186_0.value
				local var_186_7 = var_43_2.get_text_size(var_43_24.element, var_186_6).x

				if var_186_7 > arg_186_2 - 25 then
					local var_186_8 = var_186_7 - (arg_186_2 - 35)

					var_186_3.x = var_186_3.x - var_186_8
				end

				local var_186_9 = not (not (var_186_4 and not arg_186_0.interacting_tooltip) and not arg_186_0.focusing) and arg_186_0.gui.colors.hovering_text or arg_186_0.gui.colors.inactive_text

				var_43_2.text(var_43_24.element, var_186_6, var_186_3 + var_43_3.new(8, 1), var_186_9)
				var_43_2.pop_clip()
			end
		end

		function var_171_0.to_string(arg_187_0)
			return string.format("[ text_input ][ %s->%s->%s ] %s : %s", arg_187_0.page, arg_187_0.tab, arg_187_0.section, arg_187_0.name, arg_187_0.value)
		end

		return var_171_0
	end

	function var_43_27.create_text(arg_188_0, arg_188_1, arg_188_2, arg_188_3, arg_188_4)
		local var_188_0 = {
			_type = var_43_13.text,
			gui = arg_188_0,
			page = arg_188_1,
			tab = arg_188_2,
			section = arg_188_3,
			name = arg_188_4,
			defaults = {
				name = var_43_23(var_188_0.name)
			}
		}

		var_188_0.visible = true
		var_188_0.render_topmost = false
		var_188_0.visibility_callbacks = {}
		var_188_0.visibility_requirements = {}
		var_188_0.callbacks = {}
		var_188_0.tooltip = nil

		function var_188_0.set_tooltip(arg_189_0, arg_189_1)
			arg_189_0.tooltip = arg_189_0.tooltip == nil and var_43_27.create_tooltip(arg_189_0, arg_189_1) or arg_189_0.tooltip:set(arg_189_1)
		end

		function var_188_0.has_tooltip(arg_190_0)
			return arg_190_0.tooltip ~= nil
		end

		function var_188_0.register_callback(arg_191_0, arg_191_1)
			table.insert(arg_191_0.callbacks, arg_191_1)
		end

		function var_188_0.invoke_callbacks(arg_192_0)
			for iter_192_0 = 1, #arg_192_0.callbacks do
				arg_192_0.callbacks[iter_192_0]()
			end
		end

		function var_188_0.invoke_visibility_callbacks(arg_193_0)
			for iter_193_0 = 1, #arg_193_0.visibility_callbacks do
				arg_193_0.visibility_callbacks[iter_193_0]()
			end
		end

		function var_188_0.set_visibility_requirement(arg_194_0, ...)
			local var_194_0 = {
				...
			}

			var_43_19(arg_194_0, var_194_0)
		end

		var_188_0.extras = {}

		function var_188_0.add_keybind(arg_195_0, arg_195_1, arg_195_2, arg_195_3, arg_195_4)
			local var_195_0 = arg_195_0.gui:add_keybind(arg_195_0, arg_195_1, arg_195_2, arg_195_3, arg_195_4)

			table.insert(arg_195_0.extras, var_195_0)

			return var_195_0
		end

		function var_188_0.add_color_picker(arg_196_0, arg_196_1, arg_196_2)
			local var_196_0 = arg_196_0.gui:add_colorpicker(arg_196_0, arg_196_1, arg_196_2)

			table.insert(arg_196_0.extras, var_196_0)

			return var_196_0
		end

		function var_188_0.get_visual_height(arg_197_0)
			if not arg_197_0.visible then
				return 0
			end

			return 20
		end

		function var_188_0.set(arg_198_0, arg_198_1)
			arg_198_0.name = arg_198_1
		end

		function var_188_0.set_defaults(arg_199_0)
			arg_199_0.name = var_43_23(arg_199_0.defaults.name)
		end

		function var_188_0.set_visible(arg_200_0, arg_200_1)
			arg_200_0.visible = arg_200_1
		end

		function var_188_0.get(arg_201_0)
			return arg_201_0.name
		end

		function var_188_0.handle(arg_202_0, arg_202_1, arg_202_2)
			if arg_202_0:has_tooltip() and arg_202_0.tooltip:in_bounds() then
				return true
			end

			return false
		end

		function var_188_0.render(arg_203_0, arg_203_1, arg_203_2, arg_203_3)
			if not arg_203_0.visible then
				return
			end

			if arg_203_1.y > arg_203_0.gui.pos.y then
				var_43_2.push_clip(arg_203_1, var_43_3.new(arg_203_2, 20))
				var_43_2.text(var_43_24.element, arg_203_0.name, arg_203_1 + var_43_3.new(10, 0), arg_203_0.gui.colors.hovering_text)
				var_43_2.pop_clip()

				if arg_203_0.tooltip ~= nil and arg_203_0.tooltip ~= "" then
					local var_203_0 = arg_203_1 + var_43_3.new(10 + var_43_2.get_text_size(var_43_24.element, arg_203_0.name).x + 3, 0)

					arg_203_0.tooltip:set_pos(var_203_0)
				end
			end

			if arg_203_0.tooltip ~= nil then
				arg_203_0.tooltip:set_render_state(arg_203_1.y > arg_203_0.gui.pos.y)
			end
		end

		function var_188_0.to_string(arg_204_0)
			return string.format("[ text ][ %s->%s->%s ] %s", arg_204_0.page, arg_204_0.tab, arg_204_0.section, arg_204_0.name)
		end

		return var_188_0
	end

	function var_43_27.create_button(arg_205_0, arg_205_1, arg_205_2, arg_205_3, arg_205_4)
		local var_205_0 = {
			_type = var_43_13.button,
			gui = arg_205_0,
			page = arg_205_1,
			tab = arg_205_2,
			section = arg_205_3,
			name = arg_205_4
		}

		var_205_0.visible = true
		var_205_0.render_topmost = false
		var_205_0.visibility_callbacks = {}
		var_205_0.visibility_requirements = {}
		var_205_0.callbacks = {}
		var_205_0.tooltip = nil

		function var_205_0.set_tooltip(arg_206_0, arg_206_1)
			return
		end

		function var_205_0.has_tooltip(arg_207_0)
			return false
		end

		function var_205_0.register_callback(arg_208_0, arg_208_1)
			table.insert(arg_208_0.callbacks, arg_208_1)
		end

		function var_205_0.invoke_callbacks(arg_209_0)
			for iter_209_0 = 1, #arg_209_0.callbacks do
				arg_209_0.callbacks[iter_209_0]()
			end
		end

		function var_205_0.invoke_visibility_callbacks(arg_210_0)
			for iter_210_0 = 1, #arg_210_0.visibility_callbacks do
				arg_210_0.visibility_callbacks[iter_210_0]()
			end
		end

		function var_205_0.set_visibility_requirement(arg_211_0, ...)
			local var_211_0 = {
				...
			}

			var_43_19(arg_211_0, var_211_0)
		end

		function var_205_0.set_defaults(arg_212_0)
			return
		end

		var_205_0.extras = {}

		function var_205_0.add_keybind(arg_213_0, arg_213_1, arg_213_2, arg_213_3, arg_213_4)
			local var_213_0 = arg_213_0.gui:add_keybind(arg_213_0, arg_213_1, arg_213_2, arg_213_3, arg_213_4)

			table.insert(arg_213_0.extras, var_213_0)

			return var_213_0
		end

		function var_205_0.add_color_picker(arg_214_0, arg_214_1, arg_214_2)
			local var_214_0 = arg_214_0.gui:add_colorpicker(arg_214_0, arg_214_1, arg_214_2)

			table.insert(arg_214_0.extras, var_214_0)

			return var_214_0
		end

		function var_205_0.get_visual_height(arg_215_0)
			if not arg_215_0.visible then
				return 0
			end

			return 20
		end

		function var_205_0.set(arg_216_0, arg_216_1)
			arg_216_0.name = arg_216_1
		end

		function var_205_0.set_visible(arg_217_0, arg_217_1)
			arg_217_0.visible = arg_217_1
		end

		function var_205_0.get(arg_218_0)
			return arg_218_0.name
		end

		function var_205_0.handle(arg_219_0, arg_219_1, arg_219_2)
			if not arg_219_0.visible then
				return
			end

			if arg_219_1.y > arg_219_0.gui.pos.y then
				local var_219_0 = arg_219_1 + var_43_3.new(10, 0)
				local var_219_1 = var_43_3.new(arg_219_2 - 20, 18)
				local var_219_2 = var_43_1.is_mouse_in_bounds(var_219_0, var_219_1)
				local var_219_3 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)

				if var_219_2 and var_219_3 then
					arg_219_0:invoke_callbacks()

					return true
				end
			end

			return false
		end

		function var_205_0.render(arg_220_0, arg_220_1, arg_220_2, arg_220_3)
			if not arg_220_0.visible then
				return
			end

			if arg_220_1.y > arg_220_0.gui.pos.y then
				local var_220_0 = arg_220_1 + var_43_3.new(10, 0)
				local var_220_1 = var_43_3.new(arg_220_2 - 20, 18)
				local var_220_2 = var_43_1.is_mouse_in_bounds(var_220_0, var_220_1)
				local var_220_3 = var_220_2 and arg_220_0.gui.colors.hovering_outline or arg_220_0.gui.colors.inactive_outline
				local var_220_4 = var_220_2 and arg_220_0.gui.colors.hovering_text or arg_220_0.gui.colors.inactive_text

				var_43_2.rect_filled(var_220_0, var_220_1, arg_220_0.gui.colors.dark_background, 3)
				var_43_2.rect(var_220_0, var_220_1, var_220_3, 3)
				var_43_2.push_clip(var_220_0, var_220_1 - var_43_3(1, 1))
				var_43_2.text(var_43_24.element, arg_220_0.name, var_220_0 + var_43_3.new(var_220_1.x / 2, var_220_1.y / 2), var_220_4, true)
				var_43_2.pop_clip()
			end
		end

		function var_205_0.to_string(arg_221_0)
			return string.format("[ button ][ %s->%s->%s ] %s", arg_221_0.page, arg_221_0.tab, arg_221_0.section, arg_221_0.name)
		end

		return var_205_0
	end

	function var_43_27.create_separator(arg_222_0, arg_222_1, arg_222_2, arg_222_3)
		local var_222_0 = {
			_type = var_43_13.separator,
			gui = arg_222_0,
			page = arg_222_1,
			tab = arg_222_2,
			section = arg_222_3
		}

		var_222_0.visible = true
		var_222_0.render_topmost = false
		var_222_0.visibility_callbacks = {}
		var_222_0.visibility_requirements = {}
		var_222_0.callbacks = {}
		var_222_0.tooltip = nil

		function var_222_0.set_tooltip(arg_223_0, arg_223_1)
			return
		end

		function var_222_0.has_tooltip(arg_224_0)
			return false
		end

		function var_222_0.register_callback(arg_225_0, arg_225_1)
			table.insert(arg_225_0.callbacks, arg_225_1)
		end

		function var_222_0.invoke_callbacks(arg_226_0)
			for iter_226_0 = 1, #arg_226_0.callbacks do
				arg_226_0.callbacks[iter_226_0]()
			end
		end

		function var_222_0.invoke_visibility_callbacks(arg_227_0)
			for iter_227_0 = 1, #arg_227_0.visibility_callbacks do
				arg_227_0.visibility_callbacks[iter_227_0]()
			end
		end

		function var_222_0.set_visibility_requirement(arg_228_0, ...)
			local var_228_0 = {
				...
			}

			var_43_19(arg_228_0, var_228_0)
		end

		var_222_0.extras = {}

		function var_222_0.add_keybind(arg_229_0, arg_229_1, arg_229_2, arg_229_3, arg_229_4)
			local var_229_0 = arg_229_0.gui:add_keybind(arg_229_0, arg_229_1, arg_229_2, arg_229_3, arg_229_4)

			table.insert(arg_229_0.extras, var_229_0)

			return var_229_0
		end

		function var_222_0.add_color_picker(arg_230_0, arg_230_1, arg_230_2)
			local var_230_0 = arg_230_0.gui:add_colorpicker(arg_230_0, arg_230_1, arg_230_2)

			table.insert(arg_230_0.extras, var_230_0)

			return var_230_0
		end

		function var_222_0.get_visual_height(arg_231_0)
			if not arg_231_0.visible then
				return 0
			end

			return 10
		end

		function var_222_0.set(arg_232_0)
			return
		end

		function var_222_0.set_defaults(arg_233_0)
			return
		end

		function var_222_0.set_visible(arg_234_0, arg_234_1)
			arg_234_0.visible = arg_234_1
		end

		function var_222_0.get(arg_235_0)
			return
		end

		function var_222_0.handle(arg_236_0, arg_236_1, arg_236_2)
			return false
		end

		function var_222_0.render(arg_237_0, arg_237_1, arg_237_2, arg_237_3)
			if not arg_237_0.visible then
				return
			end

			if arg_237_1.y > arg_237_0.gui.pos.y then
				var_43_2.rect_filled(arg_237_1 + var_43_3.new(10, 2), var_43_3.new(arg_237_2 - 20, 2), arg_237_0.gui.colors.active_outline)
			end
		end

		function var_222_0.to_string(arg_238_0)
			return string.format("[ text ][ %s->%s->%s ] %s", arg_238_0.page, arg_238_0.tab, arg_238_0.section, arg_238_0.name)
		end

		return var_222_0
	end

	function var_43_27.create_list(arg_239_0, arg_239_1, arg_239_2, arg_239_3, arg_239_4)
		local var_239_0 = {
			_type = var_43_13.list,
			gui = arg_239_0,
			page = arg_239_1,
			tab = arg_239_2,
			section = arg_239_3,
			name = "list" .. tostring(#arg_239_0.pages[arg_239_1][arg_239_2][arg_239_3]),
			items = arg_239_4
		}

		if #arg_239_4 == 0 then
			-- block empty
		end

		var_239_0.selected = 1
		var_239_0.defaults = {
			items = var_43_23(var_239_0.items),
			selected = var_43_23(var_239_0.selected)
		}
		var_239_0.visible = true
		var_239_0.render_topmost = false
		var_239_0.visibility_callbacks = {}
		var_239_0.visibility_requirements = {}
		var_239_0.callbacks = {}
		var_239_0.scroll_offset = 0
		var_239_0.height = 130
		var_239_0.entry_height = 14
		var_239_0.tooltip = nil

		function var_239_0.set_tooltip(arg_240_0, arg_240_1)
			return
		end

		function var_239_0.has_tooltip(arg_241_0)
			return false
		end

		function var_239_0.register_callback(arg_242_0, arg_242_1)
			table.insert(arg_242_0.callbacks, arg_242_1)
		end

		function var_239_0.invoke_callbacks(arg_243_0)
			for iter_243_0 = 1, #arg_243_0.callbacks do
				arg_243_0.callbacks[iter_243_0]()
			end
		end

		function var_239_0.invoke_visibility_callbacks(arg_244_0)
			for iter_244_0 = 1, #arg_244_0.visibility_callbacks do
				arg_244_0.visibility_callbacks[iter_244_0]()
			end
		end

		function var_239_0.set_visibility_requirement(arg_245_0, ...)
			local var_245_0 = {
				...
			}

			var_43_19(arg_245_0, var_245_0)
		end

		var_239_0.extras = {}

		function var_239_0.add_keybind(arg_246_0, arg_246_1, arg_246_2, arg_246_3, arg_246_4)
			local var_246_0 = arg_246_0.gui:add_keybind(arg_246_0, arg_246_1, arg_246_2, arg_246_3, arg_246_4)

			table.insert(arg_246_0.extras, var_246_0)

			return var_246_0
		end

		function var_239_0.add_color_picker(arg_247_0, arg_247_1, arg_247_2)
			local var_247_0 = arg_247_0.gui:add_colorpicker(arg_247_0, arg_247_1, arg_247_2)

			table.insert(arg_247_0.extras, var_247_0)

			return var_247_0
		end

		function var_239_0.get_visual_height(arg_248_0)
			if not arg_248_0.visible then
				return 0
			end

			return arg_248_0.height + 10
		end

		function var_239_0.set(arg_249_0, arg_249_1)
			if type(arg_249_1) == "string" then
				for iter_249_0 = 1, #arg_249_0.items do
					if arg_249_0.items[iter_249_0] == arg_249_1 then
						arg_249_0.selected = iter_249_0

						break
					end
				end
			else
				arg_249_0.selected = arg_249_1
			end
		end

		function var_239_0.set_defaults(arg_250_0)
			arg_250_0.items = var_43_23(arg_250_0.defaults.items)
			arg_250_0.selected = var_43_23(arg_250_0.defaults.selected)
		end

		function var_239_0.set_visible(arg_251_0, arg_251_1)
			arg_251_0.visible = arg_251_1
		end

		function var_239_0.get(arg_252_0)
			local var_252_0 = var_239_0.selected

			if var_239_0.selected == nil then
				-- block empty
			end

			return var_252_0, var_239_0.items[var_239_0.selected]
		end

		function var_239_0.get_items(arg_253_0)
			return var_239_0.items
		end

		function var_239_0.update_items(arg_254_0, arg_254_1)
			var_239_0.items = arg_254_1

			if #arg_254_1 == 0 then
				arg_254_0.selected = nil
			else
				arg_254_0.selected = 1
			end
		end

		function var_239_0.handle(arg_255_0, arg_255_1, arg_255_2)
			if not arg_255_0.visible then
				return
			end

			if arg_255_1.y + arg_255_0.height < arg_255_0.gui.pos.y then
				return false, false
			end

			local var_255_0 = arg_255_0.gui.pos.y + arg_255_0.gui.size.y - arg_255_0.gui.footer_size.y - arg_255_1.y
			local var_255_1 = math.min(arg_255_0.height, var_255_0)
			local var_255_2 = var_43_3.new(arg_255_2 - 20, var_255_1)
			local var_255_3 = var_43_1.is_mouse_in_bounds(arg_255_1 + var_43_3.new(10, 0), var_255_2)
			local var_255_4 = var_43_1.is_key_pressed(var_43_0.MOUSE_LEFT)
			local var_255_5 = var_43_1.get_scroll_delta()
			local var_255_6 = arg_255_1 + var_43_3.new(10, 5)
			local var_255_7 = #arg_255_0.items > math.floor(arg_255_0.height / arg_255_0.entry_height)

			if var_255_3 and var_255_4 then
				local var_255_8 = var_43_1.get_mouse_pos()
				local var_255_9 = math.floor((var_255_8.y - var_255_6.y) / arg_255_0.entry_height) + 1

				if var_255_8.y < arg_255_0.gui.pos.y then
					return false, false
				end

				local var_255_10 = var_255_9 + arg_255_0.scroll_offset

				if var_255_10 > 0 and var_255_10 <= #arg_255_0.items then
					arg_255_0.selected = var_255_10

					arg_255_0:invoke_callbacks()
				end

				return true, false
			elseif var_255_3 and var_255_5 ~= 0 and var_255_7 then
				local var_255_11 = arg_255_0.scroll_offset - var_255_5

				if var_255_11 < 0 or var_255_11 > #arg_255_0.items - math.floor(arg_255_0.height / arg_255_0.entry_height) + 1 then
					var_255_11 = 0

					return false, false
				else
					arg_255_0.scroll_offset = var_255_11

					return true, true
				end
			end

			return false, false
		end

		function var_239_0.render(arg_256_0, arg_256_1, arg_256_2, arg_256_3)
			if not arg_256_0.visible then
				return
			end

			local var_256_0 = arg_256_0.gui.pos.y + arg_256_0.gui.size.y - arg_256_0.gui.footer_size.y - arg_256_1.y + 5
			local var_256_1 = math.min(arg_256_0.height, var_256_0)
			local var_256_2 = var_43_3.new(arg_256_2 - 20, var_256_1)
			local var_256_3 = arg_256_1 + var_43_3.new(10, 0)

			if var_256_3.y < arg_256_0.gui.pos.y and var_256_3.y + arg_256_0.height > arg_256_0.gui.pos.y then
				local var_256_4 = arg_256_0.gui.pos.y - var_256_3.y

				var_256_2.y = var_256_2.y - var_256_4
				var_256_3.y = arg_256_0.gui.pos.y
			end

			if var_256_2.y < 0 then
				return
			end

			var_43_2.rect_filled(var_256_3, var_256_2, arg_256_0.gui.colors.dark_background, 3)

			local var_256_5 = var_43_1.is_mouse_in_bounds(arg_256_1 + var_43_3.new(10, 0), var_256_2)
			local var_256_6 = var_256_5 and arg_256_0.gui.colors.hovering_outline or arg_256_0.gui.colors.inactive_outline

			var_43_2.rect(var_256_3, var_256_2, var_256_6, 3)
			var_43_2.push_clip(var_256_3 + var_43_3.new(0, 3), var_256_2)

			local var_256_7 = arg_256_1 + var_43_3.new(10, 5 - arg_256_0.scroll_offset * arg_256_0.entry_height)

			for iter_256_0 = 1, #arg_256_0.items do
				local var_256_8 = var_256_5 and var_43_1.is_mouse_in_bounds(var_256_7, var_43_3.new(var_256_2.x - 10, arg_256_0.entry_height))
				local var_256_9 = iter_256_0 == arg_256_0.selected and var_43_25.accent or var_256_8 and arg_256_0.gui.colors.hovering_text or arg_256_0.gui.colors.inactive_text

				var_43_2.text(var_43_24.element, arg_256_0.items[iter_256_0], var_256_7 + var_43_3.new(5, 0), var_256_9)

				var_256_7.y = var_256_7.y + arg_256_0.entry_height

				if var_256_7.y > arg_256_1.y + var_256_1 then
					break
				end
			end

			if #arg_256_0.items > math.floor(arg_256_0.height / arg_256_0.entry_height) then
				local var_256_10 = #arg_256_0.items
				local var_256_11 = math.floor(arg_256_0.height / arg_256_0.entry_height)
				local var_256_12 = arg_256_0.height - 8
				local var_256_13 = math.floor(var_256_12 / var_256_10 * var_256_11)
				local var_256_14 = 3
				local var_256_15 = math.floor(var_256_1 / var_256_10 * arg_256_0.scroll_offset)
				local var_256_16 = var_43_25.accent

				var_43_2.rect_filled(arg_256_1 + var_43_3.new(arg_256_2 - 10 - var_256_14 - 4, 10), var_43_3.new(3, var_256_1 - 10), arg_256_0.gui.self.gui.colors.inactive_outline)
				var_43_2.rect_filled(arg_256_1 + var_43_3.new(arg_256_2 - 10 - var_256_14 - 4, 10 + var_256_15), var_43_3.new(3, var_256_13 - 20), var_256_16)
			end

			var_43_2.pop_clip()
		end

		function var_239_0.to_string(arg_257_0)
			return string.format("[ list ][ %s->%s->%s ] %s", arg_257_0.page, arg_257_0.tab, arg_257_0.section, arg_257_0.name)
		end

		return var_239_0
	end

	local var_43_29 = {
		create = function()
			local var_258_0 = {
				colors = var_43_25,
				changed_colors = var_43_25,
				colors_backup = var_43_26,
				pos = var_43_3.new(100, 100),
				size = var_43_3.new(628, 513)
			}

			var_258_0.subtab_size = var_43_3(200, var_258_0.size.y)
			var_258_0.subtab_entry_size = var_43_3(var_258_0.subtab_size.x, 44)
			var_258_0.footer_size = var_43_3(var_258_0.size.x, 70)
			var_258_0.page_icon_size = var_43_3(70, 60)
			var_258_0.footer_icon_gap = 10
			var_258_0.title = "primordial.dev"
			var_258_0.section_width = 200
			var_258_0.min_size = var_43_3.new(628, 513)
			var_258_0.resizable = true
			var_258_0.is_resizing = false
			var_258_0.resize_mouse_difference = var_43_3.new(0, 0)
			var_258_0.mouse_difference = var_43_3.new(0, 0)
			var_258_0.dragging = false
			var_258_0.can_drag = true
			var_258_0.resizable = true
			var_258_0.current_page = nil
			var_258_0.current_subtab = nil
			var_258_0.keybinds = {}
			var_258_0.page_icons = {}
			var_258_0.pages = {}
			var_258_0.subtab_sections = {}
			var_258_0.page_order = {}
			var_258_0.stored_page_subtabs = {}
			var_258_0.subtab_order = {}
			var_258_0.stored_color = nil
			var_258_0.interacting_element = {
				interacting = false
			}
			var_258_0.scroll = {}
			var_258_0.can_scroll = true
			var_258_0.page_icon_animation_timers = {}
			var_258_0.page_icon_animation_time = 0.15
			var_258_0.page_icon_animations = false
			var_258_0.custom_logo_function = nil
			var_258_0.draw_call_tooltips = {}

			function var_258_0.set_min_size(arg_259_0, arg_259_1)
				arg_259_0.min_size = arg_259_1

				if arg_259_0.size.x < arg_259_0.min_size.x then
					arg_259_0.size.x = arg_259_0.min_size.x
				end

				if arg_259_0.size.y < arg_259_0.min_size.y then
					arg_259_0.size.y = arg_259_0.min_size.y
				end

				arg_259_0.subtab_size = var_43_3.new(200, arg_259_0.size.y)
				arg_259_0.footer_size = var_43_3.new(arg_259_0.size.x, 70)
				arg_259_0.section_width = (arg_259_0.size.x - arg_259_0.subtab_size.x - 10 - 10 - 10) / 2
			end

			function var_258_0.set_custom_logo(arg_260_0, arg_260_1)
				arg_260_0.custom_logo_function = arg_260_1
			end

			function var_258_0.reset_colors(arg_261_0)
				arg_261_0.colors = arg_261_0.colors_backup
			end

			function var_258_0.use_custom_colors(arg_262_0, arg_262_1)
				if arg_262_1 then
					arg_262_0.colors = arg_262_0.changed_colors
				else
					arg_262_0.colors = arg_262_0.colors_backup
				end
			end

			function var_258_0.set_page_icon_animation(arg_263_0, arg_263_1)
				arg_263_0.page_icon_animations = arg_263_1
			end

			function var_258_0.set_size(arg_264_0, arg_264_1)
				arg_264_0.size = arg_264_1

				if arg_264_0.size.x < arg_264_0.min_size.x then
					arg_264_0.size.x = arg_264_0.min_size.x
				end

				if arg_264_0.size.y < arg_264_0.min_size.y then
					arg_264_0.size.y = arg_264_0.min_size.y
				end

				arg_264_0.subtab_size = var_43_3.new(200, arg_264_0.size.y)
				arg_264_0.footer_size = var_43_3.new(arg_264_0.size.x, 70)
				arg_264_0.section_width = (arg_264_0.size.x - arg_264_0.subtab_size.x - 10 - 10 - 10) / 2
			end

			function var_258_0.get_accent_color(arg_265_0)
				return var_43_25.accent
			end

			function var_258_0.set_title(arg_266_0, arg_266_1)
				arg_266_0.title = arg_266_1
			end

			function var_258_0.set_page_icon(arg_267_0, arg_267_1, arg_267_2)
				arg_267_0.page_icons[arg_267_1] = arg_267_2
			end

			function var_258_0.set_stored_color(arg_268_0, arg_268_1)
				arg_268_0.stored_color = arg_268_1
			end

			function var_258_0.get_stored_color(arg_269_0)
				return arg_269_0.stored_color
			end

			function var_258_0.set_resizability(arg_270_0, arg_270_1)
				arg_270_0.resizable = arg_270_1
			end

			function var_258_0.setup_page(arg_271_0, arg_271_1, arg_271_2, arg_271_3)
				if var_258_0.pages[arg_271_1] == nil then
					var_258_0.pages[arg_271_1] = {}

					if var_258_0.current_page == nil then
						var_258_0.current_page = arg_271_1
					end

					if var_258_0.page_icon_animation_timers[arg_271_1] == nil then
						var_258_0.page_icon_animation_timers[arg_271_1] = global_vars.real_time()
					end

					if var_258_0.subtab_order[arg_271_1] == nil then
						var_258_0.subtab_order[arg_271_1] = {}
					end

					if var_258_0.subtab_sections[arg_271_1] == nil then
						var_258_0.subtab_sections[arg_271_1] = {}
					end

					if not table.shallow_has_value(var_258_0.page_order, arg_271_1) then
						table.insert(var_258_0.page_order, arg_271_1)
					end

					if var_258_0.scroll[arg_271_1] == nil then
						var_258_0.scroll[arg_271_1] = {}
					end
				end

				if var_258_0.pages[arg_271_1][arg_271_2] == nil then
					var_258_0.pages[arg_271_1][arg_271_2] = {}

					if var_258_0.current_subtab == nil then
						var_258_0.current_subtab = arg_271_2
					end

					if not table.shallow_has_value(var_258_0.subtab_order[arg_271_1], arg_271_2) then
						table.insert(var_258_0.subtab_order[arg_271_1], arg_271_2)
					end

					if var_258_0.subtab_sections[arg_271_1][arg_271_2] == nil then
						var_258_0.subtab_sections[arg_271_1][arg_271_2] = {}
					end

					if var_258_0.scroll[arg_271_1][arg_271_2] == nil then
						var_258_0.scroll[arg_271_1][arg_271_2] = 0
					end
				end

				if not table.shallow_has_value(var_258_0.subtab_sections[arg_271_1][arg_271_2], arg_271_3) then
					table.insert(var_258_0.subtab_sections[arg_271_1][arg_271_2], arg_271_3)
				end

				if var_258_0.stored_page_subtabs[arg_271_1] == nil then
					var_258_0.stored_page_subtabs[arg_271_1] = arg_271_2
				end

				if var_258_0.pages[arg_271_1][arg_271_2][arg_271_3] == nil then
					var_258_0.pages[arg_271_1][arg_271_2][arg_271_3] = {}
				end
			end

			function var_258_0.add_checkbox(arg_272_0, arg_272_1, arg_272_2, arg_272_3, arg_272_4, arg_272_5)
				var_258_0:setup_page(arg_272_1, arg_272_2, arg_272_3)

				local var_272_0 = var_43_27.create_checkbox(arg_272_0, arg_272_1, arg_272_2, arg_272_3, arg_272_4, arg_272_5)

				table.insert(var_258_0.pages[arg_272_1][arg_272_2][arg_272_3], var_272_0)

				return var_258_0.pages[arg_272_1][arg_272_2][arg_272_3][#var_258_0.pages[arg_272_1][arg_272_2][arg_272_3]]
			end

			function var_258_0.add_slider(arg_273_0, arg_273_1, arg_273_2, arg_273_3, arg_273_4, arg_273_5, arg_273_6, arg_273_7, arg_273_8)
				var_258_0:setup_page(arg_273_1, arg_273_2, arg_273_3)

				local var_273_0 = var_43_27.create_slider(arg_273_0, arg_273_1, arg_273_2, arg_273_3, arg_273_4, arg_273_5, arg_273_6, arg_273_7, arg_273_8)

				table.insert(var_258_0.pages[arg_273_1][arg_273_2][arg_273_3], var_273_0)

				return var_258_0.pages[arg_273_1][arg_273_2][arg_273_3][#var_258_0.pages[arg_273_1][arg_273_2][arg_273_3]]
			end

			function var_258_0.add_combo(arg_274_0, arg_274_1, arg_274_2, arg_274_3, arg_274_4, arg_274_5, arg_274_6)
				var_258_0:setup_page(arg_274_1, arg_274_2, arg_274_3)

				local var_274_0 = var_43_27.create_combo(arg_274_0, arg_274_1, arg_274_2, arg_274_3, arg_274_4, arg_274_5, arg_274_6)

				table.insert(var_258_0.pages[arg_274_1][arg_274_2][arg_274_3], var_274_0)

				return var_258_0.pages[arg_274_1][arg_274_2][arg_274_3][#var_258_0.pages[arg_274_1][arg_274_2][arg_274_3]]
			end

			function var_258_0.add_multicombo(arg_275_0, arg_275_1, arg_275_2, arg_275_3, arg_275_4, arg_275_5, arg_275_6)
				var_258_0:setup_page(arg_275_1, arg_275_2, arg_275_3)

				local var_275_0 = var_43_27.create_multi_combo(arg_275_0, arg_275_1, arg_275_2, arg_275_3, arg_275_4, arg_275_5, arg_275_6)

				table.insert(var_258_0.pages[arg_275_1][arg_275_2][arg_275_3], var_275_0)

				return var_258_0.pages[arg_275_1][arg_275_2][arg_275_3][#var_258_0.pages[arg_275_1][arg_275_2][arg_275_3]]
			end

			function var_258_0.add_text_input(arg_276_0, arg_276_1, arg_276_2, arg_276_3, arg_276_4, arg_276_5)
				var_258_0:setup_page(arg_276_1, arg_276_2, arg_276_3)

				local var_276_0 = var_43_27.create_text_input(arg_276_0, arg_276_1, arg_276_2, arg_276_3, arg_276_4, arg_276_5)

				table.insert(var_258_0.pages[arg_276_1][arg_276_2][arg_276_3], var_276_0)

				return var_258_0.pages[arg_276_1][arg_276_2][arg_276_3][#var_258_0.pages[arg_276_1][arg_276_2][arg_276_3]]
			end

			function var_258_0.add_text(arg_277_0, arg_277_1, arg_277_2, arg_277_3, arg_277_4)
				var_258_0:setup_page(arg_277_1, arg_277_2, arg_277_3)

				local var_277_0 = var_43_27.create_text(arg_277_0, arg_277_1, arg_277_2, arg_277_3, arg_277_4)

				table.insert(var_258_0.pages[arg_277_1][arg_277_2][arg_277_3], var_277_0)

				return var_258_0.pages[arg_277_1][arg_277_2][arg_277_3][#var_258_0.pages[arg_277_1][arg_277_2][arg_277_3]]
			end

			function var_258_0.add_button(arg_278_0, arg_278_1, arg_278_2, arg_278_3, arg_278_4)
				var_258_0:setup_page(arg_278_1, arg_278_2, arg_278_3)

				local var_278_0 = var_43_27.create_button(arg_278_0, arg_278_1, arg_278_2, arg_278_3, arg_278_4)

				table.insert(var_258_0.pages[arg_278_1][arg_278_2][arg_278_3], var_278_0)

				return var_258_0.pages[arg_278_1][arg_278_2][arg_278_3][#var_258_0.pages[arg_278_1][arg_278_2][arg_278_3]]
			end

			function var_258_0.add_separator(arg_279_0, arg_279_1, arg_279_2, arg_279_3)
				var_258_0:setup_page(arg_279_1, arg_279_2, arg_279_3)

				local var_279_0 = var_43_27.create_separator(arg_279_0, arg_279_1, arg_279_2, arg_279_3)

				table.insert(var_258_0.pages[arg_279_1][arg_279_2][arg_279_3], var_279_0)

				return var_258_0.pages[arg_279_1][arg_279_2][arg_279_3][#var_258_0.pages[arg_279_1][arg_279_2][arg_279_3]]
			end

			function var_258_0.add_list(arg_280_0, arg_280_1, arg_280_2, arg_280_3, arg_280_4)
				var_258_0:setup_page(arg_280_1, arg_280_2, arg_280_3)

				local var_280_0 = var_43_27.create_list(arg_280_0, arg_280_1, arg_280_2, arg_280_3, arg_280_4)

				table.insert(var_258_0.pages[arg_280_1][arg_280_2][arg_280_3], var_280_0)

				return var_258_0.pages[arg_280_1][arg_280_2][arg_280_3][#var_258_0.pages[arg_280_1][arg_280_2][arg_280_3]]
			end

			function var_258_0.add_keybind(arg_281_0, arg_281_1, arg_281_2, arg_281_3, arg_281_4, arg_281_5)
				local var_281_0 = var_43_27.create_keybind(arg_281_1, arg_281_2, arg_281_3, arg_281_4, arg_281_5)

				table.insert(var_258_0.pages[arg_281_1.page][arg_281_1.tab][arg_281_1.section], var_281_0)
				table.insert(var_258_0.keybinds, var_281_0)

				return var_258_0.pages[arg_281_1.page][arg_281_1.tab][arg_281_1.section][#var_258_0.pages[arg_281_1.page][arg_281_1.tab][arg_281_1.section]]
			end

			function var_258_0.add_colorpicker(arg_282_0, arg_282_1, arg_282_2, arg_282_3)
				local var_282_0 = var_43_27.create_colorpicker(arg_282_1, arg_282_2, arg_282_3)

				table.insert(var_258_0.pages[arg_282_1.page][arg_282_1.tab][arg_282_1.section], var_282_0)

				return var_258_0.pages[arg_282_1.page][arg_282_1.tab][arg_282_1.section][#var_258_0.pages[arg_282_1.page][arg_282_1.tab][arg_282_1.section]]
			end

			function var_258_0.get_config(arg_283_0)
				local var_283_0 = {}

				for iter_283_0, iter_283_1 in pairs(var_258_0.pages) do
					var_283_0[iter_283_0] = {}

					for iter_283_2, iter_283_3 in pairs(iter_283_1) do
						var_283_0[iter_283_0][iter_283_2] = {}

						for iter_283_4, iter_283_5 in pairs(iter_283_3) do
							var_283_0[iter_283_0][iter_283_2][iter_283_4] = {}

							for iter_283_6 = 1, #iter_283_5 do
								local var_283_1 = iter_283_5[iter_283_6]

								if var_283_1._type == var_43_13.checkbox then
									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = var_283_1:get()
								elseif var_283_1._type == var_43_13.slider then
									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = var_283_1:get()
								elseif var_283_1._type == var_43_13.combo then
									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = var_283_1:get()
								elseif var_283_1._type == var_43_13.multicombo then
									local var_283_2 = {}
									local var_283_3 = var_283_1:get_items()

									for iter_283_7 = 1, #var_283_3 do
										if var_283_1:get(iter_283_7) then
											table.insert(var_283_2, var_283_3[iter_283_7])
										end
									end

									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = var_283_2
								elseif var_283_1._type == var_43_13.text_input then
									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = var_283_1:get()
								elseif var_283_1._type == var_43_13.list then
									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = var_283_1:get()
								elseif var_283_1._type == var_43_13.colorpicker then
									local var_283_4 = var_283_1:get()

									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = {
										var_283_4.r,
										var_283_4.g,
										var_283_4.b,
										var_283_4.a
									}
								elseif var_283_1._type == var_43_13.keybind then
									local var_283_5 = {
										mode = var_283_1:get_mode(),
										key = var_283_1:get_key()
									}

									var_283_0[iter_283_0][iter_283_2][iter_283_4][var_283_1.name] = var_283_5
								elseif var_283_1._type == var_43_13.text then
									-- block empty
								elseif var_283_1._type == var_43_13.button then
									-- block empty
								elseif var_283_1._type == var_43_13.separator then
									-- block empty
								end
							end
						end
					end
				end

				return var_283_0
			end

			function var_258_0.load_config(arg_284_0, arg_284_1)
				for iter_284_0, iter_284_1 in pairs(var_258_0.pages) do
					if arg_284_1[iter_284_0] then
						for iter_284_2, iter_284_3 in pairs(iter_284_1) do
							if arg_284_1[iter_284_0][iter_284_2] then
								for iter_284_4, iter_284_5 in pairs(iter_284_3) do
									if arg_284_1[iter_284_0][iter_284_2][iter_284_4] then
										for iter_284_6 = 1, #iter_284_5 do
											local var_284_0 = iter_284_5[iter_284_6]
											local var_284_1 = arg_284_1[iter_284_0][iter_284_2][iter_284_4][var_284_0.name]

											if var_284_1 and var_284_0 then
												var_284_0:invoke_visibility_callbacks()

												if var_284_0._type == var_43_13.checkbox then
													var_284_0:set(var_284_1)
												elseif var_284_0._type == var_43_13.slider then
													var_284_0:set(var_284_1)
												elseif var_284_0._type == var_43_13.combo then
													var_284_0:set(var_284_1)
												elseif var_284_0._type == var_43_13.multicombo then
													local var_284_2 = var_284_0:get_items()

													for iter_284_7 = 1, #var_284_2 do
														var_284_0:set(iter_284_7, false)
													end

													for iter_284_8 = 1, #var_284_1 do
														var_284_0:set(var_284_1[iter_284_8], true)
													end
												elseif var_284_0._type == var_43_13.text_input then
													var_284_0:set(var_284_1)
												elseif var_284_0._type == var_43_13.list then
													var_284_0:set(var_284_1)
												elseif var_284_0._type == var_43_13.colorpicker then
													local var_284_3 = var_43_4.new(var_284_1[1], var_284_1[2], var_284_1[3], var_284_1[4])

													var_284_0:set(var_284_3)
												elseif var_284_0._type == var_43_13.keybind then
													local var_284_4 = var_284_1.mode
													local var_284_5 = var_284_1.key

													var_284_0:set_mode(var_284_4)
													var_284_0:set_key(var_284_5)
												end
											elseif var_284_0._type == var_43_13.checkbox then
												var_284_0:set(false)
											elseif var_284_0._type == var_43_13.combo then
												var_284_0:set(0)
											elseif var_284_0._type == var_43_13.multicombo then
												local var_284_6 = var_284_0:get_items()

												for iter_284_9 = 1, #var_284_6 do
													var_284_0:set(iter_284_9, false)
												end
											end
										end
									else
										print("couldnt load " .. iter_284_0 .. "->" .. iter_284_2 .. "->" .. iter_284_4)
									end
								end
							else
								print("couldnt load " .. iter_284_0 .. "->" .. iter_284_2)
							end
						end
					else
						print("couldnt load " .. iter_284_0)
					end
				end
			end

			function var_258_0.reset_config(arg_285_0)
				for iter_285_0, iter_285_1 in pairs(var_258_0.pages) do
					for iter_285_2, iter_285_3 in pairs(iter_285_1) do
						for iter_285_4, iter_285_5 in pairs(iter_285_3) do
							for iter_285_6 = 1, #iter_285_5 do
								iter_285_5[iter_285_6]:set_defaults()
							end
						end
					end
				end
			end

			function var_258_0.handle_pages(arg_286_0)
				local var_286_0 = var_258_0.page_order
				local var_286_1 = #var_286_0
				local var_286_2 = var_258_0.pos + var_43_3.new(math.floor(var_258_0.size.x / 2), var_258_0.size.y - var_258_0.footer_size.y)
				local var_286_3 = var_286_1 * var_258_0.page_icon_size.x + (var_286_1 - 1) * var_258_0.footer_icon_gap

				var_286_2.x = var_286_2.x - var_286_3 / 2

				local var_286_4 = var_43_3.new(var_286_2.x, var_286_2.y)
				local var_286_5 = global_vars.real_time()

				for iter_286_0 = 1, var_286_1 do
					local var_286_6 = var_286_0[iter_286_0]
					local var_286_7 = var_258_0.current_page == var_286_6
					local var_286_8 = var_286_5 - var_258_0.page_icon_animation_timers[var_286_6]
					local var_286_9 = math.clamp(var_286_8 / var_258_0.page_icon_animation_time, 0, 1)

					if not var_286_7 then
						var_286_9 = 1 - var_286_9
					end

					local var_286_10 = var_286_4 + var_43_3.new(0, (arg_286_0.footer_size.y - arg_286_0.page_icon_size.y) / 2)
					local var_286_11 = var_43_1.is_mouse_in_bounds(var_286_4, var_258_0.page_icon_size)
					local var_286_12 = var_43_1.is_key_pressed(var_43_20.MOUSE_LEFT)

					if var_286_11 and var_286_12 and not var_286_7 then
						var_258_0.stored_page_subtabs[var_258_0.current_page] = var_258_0.current_subtab
						var_258_0.page_icon_animation_timers[var_258_0.current_page] = var_286_5
						var_258_0.page_icon_animation_timers[var_286_6] = var_286_5
						var_258_0.current_page = var_286_6
						var_258_0.current_subtab = var_258_0.stored_page_subtabs[var_258_0.current_page]
					end

					local var_286_13 = var_286_9

					if var_286_11 and not var_286_7 then
						var_286_13 = 0.2
					elseif var_286_7 and var_286_9 < 0.2 then
						var_286_13 = 0.2
					end

					var_43_2.push_alpha_modifier(var_286_13)
					var_43_2.rect_filled(var_286_10, var_258_0.page_icon_size, arg_286_0.colors.white30, 10)

					local var_286_14 = 20

					var_43_2.rect_filled(var_286_10 + var_43_3.new(var_286_14, var_258_0.page_icon_size.y - 3 - 1), var_43_3.new(var_258_0.page_icon_size.x - var_286_14 * 2, 3), var_43_25.accent)
					var_43_2.pop_alpha_modifier()

					local var_286_15 = arg_286_0.page_icons[var_286_6]

					if var_286_15 == nil then
						var_43_2.text(var_43_24.page, var_286_6:sub(1, 1):upper(), var_286_10 + var_43_3.new(var_258_0.page_icon_size.x / 2, var_258_0.page_icon_size.y / 2), arg_286_0.colors.white, true)
					else
						local var_286_16 = var_286_10 + var_43_3.new(var_258_0.page_icon_size.x / 2, var_258_0.page_icon_size.y / 2)
						local var_286_17 = var_286_16 + var_43_3.new(0, var_258_0.page_icon_size.y / 2)
						local var_286_18 = var_286_7 and 14 or 12

						var_286_17.y = var_286_17.y - var_286_18

						local var_286_19 = var_43_3.new(35, 30)
						local var_286_20 = var_43_3.new(var_286_16.x - var_286_19.x / 2, var_286_16.y - var_286_19.y / 2 - 10)

						if var_286_9 > 0 and arg_286_0.page_icon_animations then
							local var_286_21 = 3 * var_286_9

							var_43_2.texture(var_286_15.id, var_286_20, var_286_19, arg_286_0.colors.black)
							var_43_2.text(var_43_24.page_title, var_286_6:sub(1, 1):upper() .. var_286_6:sub(2, #var_286_6), var_286_17, arg_286_0.colors.black, true)
							var_43_2.texture(var_286_15.id, var_286_20 - var_43_3.new(0, var_286_21), var_286_19, not var_286_7 and arg_286_0.colors.white100 or arg_286_0.colors.white)
							var_43_2.text(var_43_24.page_title, var_286_6:sub(1, 1):upper() .. var_286_6:sub(2, #var_286_6), var_286_17 - var_43_3.new(0, var_286_21), not var_286_7 and arg_286_0.colors.white100 or arg_286_0.colors.white, true)
						else
							var_43_2.texture(var_286_15.id, var_286_20, var_286_19, not var_286_7 and arg_286_0.colors.white100 or arg_286_0.colors.white)
							var_43_2.text(var_43_24.page_title, var_286_6:sub(1, 1):upper() .. var_286_6:sub(2, #var_286_6), var_286_17, not var_286_7 and arg_286_0.colors.white100 or arg_286_0.colors.white, true)
						end
					end

					var_286_4.x = var_286_4.x + var_258_0.page_icon_size.x + var_258_0.footer_icon_gap
				end

				if var_43_1.is_mouse_in_bounds(var_286_2, var_43_3.new(var_286_3, var_258_0.page_icon_size.y)) then
					var_258_0.can_drag = false
				end
			end

			function var_258_0.handle_subtabs(arg_287_0)
				if var_258_0.current_page == nil then
					print("gui:handle_subtabs | gui.current_page is nil")

					return
				end

				local var_287_0 = var_258_0.subtab_order[var_258_0.current_page]
				local var_287_1 = var_258_0.pos + var_43_3.new(0, 200)
				local var_287_2 = var_287_1.y

				for iter_287_0 = 1, #var_287_0 do
					local var_287_3 = var_287_0[iter_287_0]
					local var_287_4 = var_43_1.is_mouse_in_bounds(var_287_1, var_258_0.subtab_entry_size)
					local var_287_5 = var_43_1.is_key_pressed(var_43_20.MOUSE_LEFT)

					if var_287_4 and var_287_5 then
						var_258_0.current_subtab = var_287_3
					end

					local var_287_6 = var_258_0.current_subtab == var_287_3

					if var_287_4 or var_287_6 then
						if var_287_4 and not var_287_6 then
							var_43_2.push_alpha_modifier(0.2)
						end

						var_43_2.rect_fade(var_287_1, var_258_0.subtab_entry_size, arg_287_0.colors.white100, arg_287_0.colors.white30, true)
						var_43_2.rect_filled(var_287_1, var_43_3.new(3, var_258_0.subtab_entry_size.y), var_43_25.accent)
						var_43_2.pop_alpha_modifier()
					end

					local var_287_7 = var_258_0.current_subtab == var_287_3 and arg_287_0.colors.active_text or var_287_4 and arg_287_0.colors.hovering_text or arg_287_0.colors.inactive_text

					var_43_2.text(var_43_24.element, var_287_3, var_287_1 + var_43_3.new(10, var_258_0.subtab_entry_size.y / 2 - 8), var_287_7)

					var_287_1.y = var_287_1.y + var_258_0.subtab_entry_size.y
				end

				local var_287_8 = var_287_1.y - var_287_2

				if var_43_1.is_mouse_in_bounds(var_258_0.pos + var_43_3.new(0, 200), var_43_3.new(var_258_0.subtab_size.x, var_287_8)) then
					var_258_0.can_drag = false
				end
			end

			function var_258_0.handle_elements(arg_288_0)
				local var_288_0 = true

				if var_258_0.current_page == nil then
					print("gui:handle_elements | gui.current_page is nil")

					return var_288_0
				end

				if var_258_0.current_subtab == nil then
					print("gui:handle_elements | gui.current_subtab is nil")

					return var_288_0
				end

				local var_288_1 = var_258_0.subtab_sections[var_258_0.current_page][var_258_0.current_subtab]
				local var_288_2 = var_258_0.pages[var_258_0.current_page][var_258_0.current_subtab]
				local var_288_3 = arg_288_0.scroll[arg_288_0.current_page][arg_288_0.current_subtab]
				local var_288_4 = var_258_0.pos + var_43_3.new(var_258_0.subtab_size.x + 10, 40 + var_288_3)
				local var_288_5 = var_258_0.pos + var_43_3.new(var_258_0.subtab_size.x + 10 + var_258_0.section_width + 10, 40 + var_288_3)
				local var_288_6 = 0
				local var_288_7 = var_258_0.interacting_element
				local var_288_8 = false
				local var_288_9 = var_258_0.size.y - (var_258_0.footer_size.y + 20)

				var_258_0.can_scroll = true

				for iter_288_0 = 1, #var_288_1 do
					local var_288_10 = var_288_1[iter_288_0]
					local var_288_11 = var_288_2[var_288_10]
					local var_288_12 = var_288_6 % 2 == 0 and var_43_3.new(var_288_4.x, var_288_4.y + 10) or var_43_3.new(var_288_5.x, var_288_5.y + 10)

					for iter_288_1, iter_288_2 in pairs(var_288_11) do
						if iter_288_2._type == var_43_13.keybind or iter_288_2._type == var_43_13.colorpicker then
							-- block empty
						else
							local var_288_13 = 0
							local var_288_14 = var_288_12.y

							if var_288_14 + iter_288_2:get_visual_height() < var_258_0.pos.y + var_288_9 and iter_288_2._type ~= var_43_13.list or iter_288_2._type == var_43_13.list and var_288_14 < arg_288_0.pos.y + arg_288_0.size.y - arg_288_0.footer_size.y and var_288_14 - 1 > arg_288_0.pos.y - iter_288_2.height then
								for iter_288_3 = 1, #iter_288_2.extras do
									local var_288_15 = iter_288_2.extras[iter_288_3]
									local var_288_16 = var_288_7.interacting and var_288_7.element._type == var_288_15._type and var_288_7.page == var_288_15.parent.page and var_288_7.tab == var_288_15.parent.tab and var_288_7.section == var_288_15.parent.section
									local var_288_17 = var_288_12 - var_43_3.new(var_288_13, 0)
									local var_288_18 = var_258_0.section_width

									if var_288_15:handle(var_288_17, var_288_18, var_288_16) then
										var_258_0.interacting_element.page = var_288_15.page
										var_258_0.interacting_element.tab = var_288_15.tab
										var_258_0.interacting_element.section = var_288_15.section
										var_258_0.interacting_element.element = var_288_15
										var_258_0.interacting_element.interacting = true
										var_288_8 = true
									end

									local var_288_19, var_288_20 = var_288_15:in_bounds(var_288_17, var_288_18)

									var_288_13 = var_288_13 + var_288_20.x
								end

								local var_288_21 = var_288_7.interacting and var_288_7.page == iter_288_2.page and var_288_7.tab == iter_288_2.tab and var_288_7.section == iter_288_2.section and var_288_7.element.name == iter_288_2.name

								if not var_258_0.dragging and (not var_258_0.interacting_element.interacting or var_288_21) and not var_288_8 then
									local var_288_22, var_288_23 = iter_288_2:handle(var_288_12, var_258_0.section_width, var_288_21)

									if var_288_23 then
										var_258_0.can_scroll = false
									end

									if var_288_22 then
										var_258_0.interacting_element.page = iter_288_2.page
										var_258_0.interacting_element.tab = iter_288_2.tab
										var_258_0.interacting_element.section = iter_288_2.section
										var_258_0.interacting_element.element = iter_288_2
										var_258_0.interacting_element.interacting = true
									end
								end
							end

							var_288_12.y = var_288_12.y + iter_288_2:get_visual_height()
						end
					end

					local var_288_24 = var_288_6 % 2 == 0 and var_288_4 or var_288_5

					var_288_24.y = var_288_24.y - 10

					local var_288_25 = var_288_12.y - var_288_24.y

					if var_288_9 < var_288_25 and var_258_0.can_scroll and var_43_1.is_mouse_in_bounds(arg_288_0.pos, arg_288_0.size) then
						local var_288_26 = var_43_1.get_scroll_delta() * 20

						arg_288_0.scroll[arg_288_0.current_page][arg_288_0.current_subtab] = arg_288_0.scroll[arg_288_0.current_page][arg_288_0.current_subtab] + var_288_26

						local var_288_27 = -var_288_25 + var_288_9 - 50

						if arg_288_0.scroll[arg_288_0.current_page][arg_288_0.current_subtab] > 0 then
							arg_288_0.scroll[arg_288_0.current_page][arg_288_0.current_subtab] = 0
						elseif var_288_27 > arg_288_0.scroll[arg_288_0.current_page][arg_288_0.current_subtab] then
							arg_288_0.scroll[arg_288_0.current_page][arg_288_0.current_subtab] = var_288_27
						end
					end

					if var_288_25 > 20 then
						var_43_2.push_clip(arg_288_0.pos + var_43_3(0, 21), var_43_3.new(arg_288_0.size.x, arg_288_0.size.y - 20 - arg_288_0.footer_size.y))
						var_43_2.rect_filled(var_288_24, var_43_3.new(var_258_0.section_width, var_288_25), arg_288_0.colors.section_background, 10)
						var_43_2.pop_clip()

						if var_288_24.y > arg_288_0.pos.y then
							var_43_2.text(var_43_24.element, var_288_10, var_288_24 + var_43_3.new(10, 3), arg_288_0.colors.white)
						end

						if var_288_6 % 2 == 0 then
							var_288_4.y = var_288_4.y + var_288_25 + 20
						else
							var_288_5.y = var_288_5.y + var_288_25 + 20
						end
					end

					var_288_6 = var_288_6 + 1
				end

				local var_288_28 = not var_258_0.interacting_element.interacting

				if not var_43_1.is_key_held(var_43_20.MOUSE_LEFT) then
					var_258_0.interacting_element.interacting = false
					var_258_0.interacting_element.page = nil
					var_258_0.interacting_element.tab = nil
					var_258_0.interacting_element.section = nil
					var_258_0.interacting_element.element = nil
				end

				return var_258_0.dragging or var_288_28
			end

			function var_258_0.handle_keybinds(arg_289_0)
				for iter_289_0 = 1, #arg_289_0.keybinds do
					local var_289_0 = arg_289_0.keybinds[iter_289_0]

					if var_289_0.visible then
						var_289_0:update()
					end
				end
			end

			function var_258_0.handle_drag(arg_290_0)
				if not var_258_0.can_drag then
					return
				end

				local var_290_0 = var_43_1.get_mouse_pos()
				local var_290_1 = var_43_1.is_mouse_in_bounds(arg_290_0.pos, arg_290_0.size)
				local var_290_2 = var_43_1.is_key_held(var_43_20.MOUSE_LEFT)

				if var_258_0.dragging or var_290_2 and var_290_1 then
					arg_290_0.dragging = true
					arg_290_0.pos = var_290_0 - arg_290_0.mouse_difference
				else
					arg_290_0.mouse_difference = var_290_0 - arg_290_0.pos
				end

				if not var_290_2 then
					arg_290_0.dragging = false
				end
			end

			function var_258_0.render_header(arg_291_0)
				var_43_2.rect_filled(var_258_0.pos, var_43_3.new(var_258_0.size.x, 20), arg_291_0.colors.footer_background, 10)
				var_43_2.rect_filled(var_258_0.pos + var_43_3(0, 10), var_43_3.new(var_258_0.size.x, 10), arg_291_0.colors.footer_background)
				var_43_2.line(var_258_0.pos + var_43_3(0, 20), var_258_0.pos + var_43_3(var_258_0.size.x, 20), var_43_25.accent)
				var_43_2.text(var_43_24.default, arg_291_0.title, var_258_0.pos + var_43_3(arg_291_0.size.x / 2, 10), arg_291_0.colors.white, true)
			end

			function var_258_0.render_background(arg_292_0)
				var_43_2.rect_filled(arg_292_0.pos, arg_292_0.size, arg_292_0.colors.dark_background, 10)
				var_43_2.rect(arg_292_0.pos - var_43_3.new(1, 1), arg_292_0.size + var_43_3.new(2, 2), arg_292_0.colors.black, 10)
				var_43_2.rect_filled(arg_292_0.pos, arg_292_0.subtab_size, arg_292_0.colors.subtab_background, 10)
				var_43_2.rect_filled(arg_292_0.pos + var_43_3.new(arg_292_0.subtab_size.x - 10, 0), var_43_3.new(10, arg_292_0.size.y), arg_292_0.colors.subtab_background)

				if arg_292_0.custom_logo_function == nil then
					local var_292_0 = 25
					local var_292_1 = arg_292_0.pos + var_43_3.new(var_292_0, 20 + var_292_0)
					local var_292_2 = var_43_3.new(arg_292_0.subtab_size.x - var_292_0 * 2, arg_292_0.subtab_size.x - 20 - var_292_0 * 2)

					if var_43_10.primordial_outline then
						local var_292_3 = var_43_10.primordial_outline.size
						local var_292_4 = var_292_3.x / var_292_3.y
						local var_292_5 = var_292_2.y * var_292_4
						local var_292_6 = var_292_1 + var_43_3.new(var_292_2.x / 2 - var_292_5 / 2, 0)
						local var_292_7 = var_43_3.new(var_292_5, var_292_2.y)

						var_43_2.texture(var_43_10.primordial_outline.id, var_292_6, var_292_7, var_43_25.white)
					end

					if var_43_10.primordial_inside then
						local var_292_8 = var_43_10.primordial_inside.size
						local var_292_9 = var_292_8.x / var_292_8.y
						local var_292_10 = var_292_2.y * var_292_9
						local var_292_11 = var_292_1 + var_43_3.new(var_292_2.x / 2 - var_292_10 / 2, 0)
						local var_292_12 = var_43_3.new(var_292_10, var_292_2.y)

						var_43_2.texture(var_43_10.primordial_inside.id, var_292_11, var_292_12, var_43_25.accent)
					end
				else
					arg_292_0.custom_logo_function(var_258_0.pos + var_43_3.new(0, 20), var_43_3.new(arg_292_0.subtab_size.x, arg_292_0.subtab_size.x - 20))
				end

				var_43_2.line(var_258_0.pos + var_43_3.new(arg_292_0.subtab_size.x, 0), var_258_0.pos + var_43_3.new(arg_292_0.subtab_size.x, arg_292_0.size.y), arg_292_0.colors.black)
			end

			function var_258_0.render_footer(arg_293_0)
				local var_293_0 = {}
				local var_293_1 = arg_293_0.colors.dark_background

				if arg_293_0.resizable then
					local var_293_2 = var_43_1.is_mouse_in_bounds(arg_293_0.pos + arg_293_0.size - var_43_3.new(30, 30), var_43_3.new(30, 30))

					var_293_1 = var_293_2 and var_43_25.accent or arg_293_0.colors.dark_background

					if var_293_2 or var_258_0.is_resizing then
						arg_293_0.can_drag = false

						if var_258_0.is_resizing or var_43_1.is_key_held(var_43_20.MOUSE_LEFT) then
							arg_293_0.size = var_43_1.get_mouse_pos() - arg_293_0.pos - arg_293_0.resize_mouse_difference
							var_258_0.is_resizing = true
						else
							arg_293_0.resize_mouse_difference = var_43_1.get_mouse_pos() - (arg_293_0.pos + arg_293_0.size)
						end

						if arg_293_0.size.x < arg_293_0.min_size.x then
							arg_293_0.size.x = arg_293_0.min_size.x
						end

						if arg_293_0.size.y < arg_293_0.min_size.y then
							arg_293_0.size.y = arg_293_0.min_size.y
						end
					end

					if not var_43_1.is_key_held(var_43_20.MOUSE_LEFT) and var_258_0.is_resizing then
						var_258_0.is_resizing = false
						var_258_0.subtab_size = var_43_3.new(200, var_258_0.size.y)
						var_258_0.footer_size = var_43_3.new(var_258_0.size.x, 70)
						var_258_0.section_width = (arg_293_0.size.x - var_258_0.subtab_size.x - 10 - 10 - 10) / 2
					end

					if var_258_0.is_resizing then
						var_258_0.subtab_size = var_43_3.new(200, var_258_0.size.y)
						var_258_0.footer_size = var_43_3.new(var_258_0.size.x, 70)
						var_258_0.section_width = (arg_293_0.size.x - var_258_0.subtab_size.x - 10 - 10 - 10) / 2
					end

					local var_293_3 = arg_293_0.pos + arg_293_0.size

					var_293_0 = {
						var_43_3.new(var_293_3.x - 13, var_293_3.y),
						var_43_3.new(var_293_3.x, var_293_3.y - 13),
						var_43_3.new(var_293_3.x, var_293_3.y - 6),
						var_43_3.new(var_293_3.x - 6, var_293_3.y)
					}
				end

				var_43_2.rect_filled(var_258_0.pos + var_43_3.new(0, arg_293_0.size.y - arg_293_0.footer_size.y), arg_293_0.footer_size, arg_293_0.colors.footer_background, 10)
				var_43_2.rect_filled(var_258_0.pos + var_43_3.new(0, arg_293_0.size.y - arg_293_0.footer_size.y), var_43_3.new(arg_293_0.size.x, 10), arg_293_0.colors.footer_background)
				var_43_2.line(var_258_0.pos + var_43_3.new(0, arg_293_0.size.y - arg_293_0.footer_size.y), var_258_0.pos + var_43_3.new(arg_293_0.size.x, arg_293_0.size.y - arg_293_0.footer_size.y), var_43_25.accent)

				if #var_293_0 > 0 then
					var_43_2.polygon(var_293_0, var_293_1)
				end
			end

			function var_258_0.render_elements(arg_294_0)
				local var_294_0 = var_258_0.subtab_sections[var_258_0.current_page][var_258_0.current_subtab]
				local var_294_1 = var_258_0.pages[var_258_0.current_page][var_258_0.current_subtab]
				local var_294_2 = arg_294_0.scroll[arg_294_0.current_page][arg_294_0.current_subtab]
				local var_294_3 = var_258_0.pos + var_43_3.new(var_258_0.subtab_size.x + 10, 40 + var_294_2)
				local var_294_4 = var_258_0.pos + var_43_3.new(var_258_0.subtab_size.x + 10 + var_258_0.section_width + 10, 40 + var_294_2)
				local var_294_5 = {}

				arg_294_0.draw_call_tooltips = {}

				local var_294_6 = var_258_0.size.y - (var_258_0.footer_size.y - 40)
				local var_294_7 = 0
				local var_294_8 = var_258_0.interacting_element

				for iter_294_0 = 1, #var_294_0 do
					local var_294_9 = var_294_1[var_294_0[iter_294_0]]
					local var_294_10 = var_294_7 % 2 == 0 and var_43_3.new(var_294_3.x, var_294_3.y + 10) or var_43_3.new(var_294_4.x, var_294_4.y + 10)

					for iter_294_1, iter_294_2 in pairs(var_294_9) do
						if iter_294_2.has_tooltip ~= nil and iter_294_2:has_tooltip() then
							table.insert(arg_294_0.draw_call_tooltips, iter_294_2.tooltip)
						end

						if iter_294_2._type == var_43_13.keybind or iter_294_2._type == var_43_13.colorpicker then
							-- block empty
						else
							local var_294_11 = var_294_8.interacting and var_294_8.page == iter_294_2.page and var_294_8.tab == iter_294_2.tab and var_294_8.section == iter_294_2.section and var_294_8.element == iter_294_2
							local var_294_12 = var_294_10.y

							if var_294_12 + iter_294_2:get_visual_height() < var_258_0.pos.y + var_294_6 and iter_294_2._type ~= var_43_13.list or iter_294_2._type == var_43_13.list and var_294_12 < arg_294_0.pos.y + arg_294_0.size.y - arg_294_0.footer_size.y and var_294_12 - 1 > arg_294_0.pos.y - iter_294_2.height then
								if not iter_294_2.render_topmost then
									iter_294_2:render(var_294_10, var_258_0.section_width, var_294_11)
								else
									table.insert(var_294_5, {
										element = iter_294_2,
										pos = var_43_3.new(var_294_10.x, var_294_10.y),
										width = var_258_0.section_width,
										interacting = var_294_11
									})
								end

								local var_294_13 = 0
								local var_294_14 = {}

								for iter_294_3 = 1, #iter_294_2.extras do
									local var_294_15 = iter_294_2.extras[iter_294_3]
									local var_294_16 = var_43_3.new(var_294_10.x - var_294_13, var_294_10.y)

									table.insert(var_294_14, {
										element = var_294_15,
										pos = var_294_16,
										width = var_258_0.section_width,
										interacting = var_294_11
									})

									local var_294_17, var_294_18 = var_294_15:in_bounds(var_294_16, var_258_0.section_width)

									var_294_13 = var_294_13 + var_294_18.x
								end

								for iter_294_4 = #var_294_14, 1, -1 do
									table.insert(var_294_5, var_294_14[iter_294_4])
								end
							end

							var_294_10.y = var_294_10.y + iter_294_2:get_visual_height()
						end
					end

					local var_294_19 = var_294_7 % 2 == 0 and var_294_3 or var_294_4

					var_294_19.y = var_294_19.y - 10

					local var_294_20 = var_294_10.y - var_294_19.y

					if var_294_7 % 2 == 0 then
						var_294_3.y = var_294_3.y + var_294_20 + 20
					else
						var_294_4.y = var_294_4.y + var_294_20 + 20
					end

					var_294_7 = var_294_7 + 1
				end

				for iter_294_5 = #var_294_5, 1, -1 do
					local var_294_21 = var_294_5[iter_294_5].element
					local var_294_22 = var_294_5[iter_294_5].pos
					local var_294_23 = var_294_5[iter_294_5].width
					local var_294_24 = var_294_5[iter_294_5].interacting

					var_294_21:render(var_294_22, var_294_23, var_294_24)
				end
			end

			function var_258_0.render_tooltips(arg_295_0)
				for iter_295_0 = 1, #arg_295_0.draw_call_tooltips do
					arg_295_0.draw_call_tooltips[iter_295_0]:render()
				end
			end

			function var_258_0.render(arg_296_0)
				var_258_0:handle_keybinds()

				if not var_43_11() then
					return
				end

				var_258_0:render_background()
				var_258_0:handle_subtabs()

				local var_296_0 = var_258_0:handle_elements()

				if not var_296_0 then
					var_258_0.can_drag = false
				end

				if not var_43_1.is_key_held(var_43_20.MOUSE_LEFT) and var_296_0 then
					var_258_0.can_drag = true
				end

				var_258_0:render_elements()
				var_258_0:render_header()
				var_258_0:render_footer()
				var_258_0:handle_pages()
				var_258_0:render_tooltips()
				var_258_0:handle_drag()
			end

			var_43_5.add(var_43_6.SETUP_COMMAND, function(arg_297_0)
				if var_43_11() then
					arg_297_0.weaponselect = 0
				end
			end)

			return var_258_0
		end
	}

	var_43_5.add(var_43_6.PAINT, function()
		var_43_25.accent = var_43_9.accent:get()
	end)

	return var_43_29
end)()
local var_0_9 = var_0_1 and require("icons") or (function()
	return {
		rage = render.load_image_buffer("<svg width=\"45\" height=\"40\" viewBox=\"0 0 45 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n    <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M23 37C32.3888 37 40 29.3888 40 20C40 10.6112 32.3888 3 23 3C13.6112 3 6 10.6112 6 20C6 29.3888 13.6112 37 23 37ZM23 33C30.1797 33 36 27.1797 36 20C36 12.8203 30.1797 7 23 7C15.8203 7 10 12.8203 10 20C10 27.1797 15.8203 33 23 33Z\" fill=\"white\"/>\n    <rect x=\"4\" y=\"18\" width=\"8\" height=\"4\" fill=\"white\"/>\n    <rect x=\"34\" y=\"18\" width=\"8\" height=\"4\" fill=\"white\"/>\n    <rect x=\"21\" y=\"9\" width=\"8\" height=\"4\" transform=\"rotate(-90 21 9)\" fill=\"white\"/>\n    <rect x=\"21\" y=\"39\" width=\"8\" height=\"4\" transform=\"rotate(-90 21 39)\" fill=\"white\"/>\n    <circle cx=\"23\" cy=\"20\" r=\"4\" fill=\"white\"/>\n    </svg>\n\n    "),
		antiaim = render.load_image_buffer("<svg width=\"45\" height=\"40\" viewBox=\"0 0 45 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n    <g clip-path=\"url(#clip0_4_38)\">\n    <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M22.5 19C27.7467 19 32 14.9706 32 10C32 5.02944 27.7467 1 22.5 1C17.2533 1 13 5.02944 13 10C13 14.9706 17.2533 19 22.5 19ZM22.5 14C24.9853 14 27 12.2091 27 10C27 7.79086 24.9853 6 22.5 6C20.0147 6 18 7.79086 18 10C18 12.2091 20.0147 14 22.5 14Z\" fill=\"white\"/>\n    <rect x=\"9\" y=\"35\" width=\"26\" height=\"5\" fill=\"white\"/>\n    <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M16 23C10.4772 23 6 27.4772 6 33V49C6 54.5228 10.4772 59 16 59H29C34.5228 59 39 54.5228 39 49V33C39 27.4772 34.5228 23 29 23H16ZM15 28C12.7909 28 11 29.7909 11 32V50C11 52.2091 12.7909 54 15 54H30C32.2091 54 34 52.2091 34 50V32C34 29.7909 32.2091 28 30 28H15Z\" fill=\"white\"/>\n    </g>\n    <defs>\n    <clipPath id=\"clip0_4_38\">\n    <rect width=\"45\" height=\"40\" fill=\"white\"/>\n    </clipPath>\n    </defs>\n    </svg>\n\n    "),
		visuals = render.load_image_buffer("<svg width=\"45\" height=\"40\" viewBox=\"0 0 45 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n    <path d=\"M24 27C23.1286 23.6205 21.8867 22.4517 18.5 21.5C18.5 21.5 36.5 4.5 37 4C37.5 3.49999 40 1.5 42 3.5C44 5.5 42.5 8 42.5 8L24 27Z\" fill=\"white\"/>\n    <path d=\"M12 25C16.6419 22.7786 18.4899 23.2804 21 26C22.5194 29.3047 22.2871 31.0434 20.5 34C16.8626 36.9698 14.5526 37.5795 10 37C6.07061 36.114 4.78508 34.9486 3 32.5C5.36184 32.3382 6.46191 31.8082 8 30C9.22854 27.3933 10.1385 26.3667 12 25Z\" fill=\"white\"/>\n    <path d=\"M24 27C23.1286 23.6205 21.8867 22.4517 18.5 21.5C18.5 21.5 36.5 4.5 37 4C37.5 3.49999 40 1.5 42 3.5C44 5.5 42.5 8 42.5 8L24 27Z\" stroke=\"white\"/>\n    <path d=\"M12 25C16.6419 22.7786 18.4899 23.2804 21 26C22.5194 29.3047 22.2871 31.0434 20.5 34C16.8626 36.9698 14.5526 37.5795 10 37C6.07061 36.114 4.78508 34.9486 3 32.5C5.36184 32.3382 6.46191 31.8082 8 30C9.22854 27.3933 10.1385 26.3667 12 25Z\" stroke=\"white\"/>\n    </svg>\n\n    "),
		config = render.load_image_buffer("<svg width=\"45\" height=\"40\" viewBox=\"0 0 45 40\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\">\n    <g clip-path=\"url(#clip0_4_77)\">\n    <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M19.424 30.9756C21.653 36.2309 27.7203 38.6841 32.9756 36.4551C38.2309 34.226 40.6842 28.1587 38.4551 22.9034C36.226 17.6481 30.1587 15.1949 24.9034 17.4239C19.6481 19.653 17.1949 25.7203 19.424 30.9756ZM24.1818 28.9575C25.2963 31.5851 28.3299 32.8117 30.9576 31.6972C33.5852 30.5827 34.8119 27.549 33.6973 24.9214C32.5828 22.2937 29.5491 21.0671 26.9215 22.1816C24.2938 23.2962 23.0672 26.3298 24.1818 28.9575Z\" fill=\"white\"/>\n    <rect x=\"34.85\" y=\"34.2566\" width=\"3.87606\" height=\"5.16807\" transform=\"rotate(67.0155 34.85 34.2566)\" fill=\"white\"/>\n    <rect x=\"39.825\" y=\"19.5155\" width=\"5.16807\" height=\"3.87606\" transform=\"rotate(67.0155 39.825 19.5155)\" fill=\"white\"/>\n    <rect x=\"26.2733\" y=\"14.036\" width=\"3.87606\" height=\"5.16807\" transform=\"rotate(67.0155 26.2733 14.036)\" fill=\"white\"/>\n    <rect x=\"29.3842\" y=\"18.9465\" width=\"5\" height=\"5\" transform=\"rotate(-67.9845 29.3842 18.9465)\" fill=\"white\"/>\n    <rect x=\"22.0676\" y=\"37.0417\" width=\"5\" height=\"5\" transform=\"rotate(-67.9845 22.0676 37.0417)\" fill=\"white\"/>\n    <rect x=\"37.4454\" y=\"27.542\" width=\"5\" height=\"5\" transform=\"rotate(22.0155 37.4454 27.542)\" fill=\"white\"/>\n    <rect x=\"18.812\" y=\"20.0078\" width=\"5\" height=\"5\" transform=\"rotate(22.0155 18.812 20.0078)\" fill=\"white\"/>\n    <rect x=\"19.6044\" y=\"28.0922\" width=\"5.16807\" height=\"3.87606\" transform=\"rotate(67.0155 19.6044 28.0922)\" fill=\"white\"/>\n    <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14 20C18.4183 20 22 16.4183 22 12C22 7.58172 18.4183 4 14 4C9.58172 4 6 7.58172 6 12C6 16.4183 9.58172 20 14 20ZM14 16C16.2091 16 18 14.2091 18 12C18 9.79086 16.2091 8 14 8C11.7909 8 10 9.79086 10 12C10 14.2091 11.7909 16 14 16Z\" fill=\"white\"/>\n    <rect x=\"21\" y=\"10\" width=\"3\" height=\"4\" fill=\"white\"/>\n    <rect x=\"12\" y=\"2\" width=\"4\" height=\"3\" fill=\"white\"/>\n    <rect x=\"4\" y=\"10\" width=\"3\" height=\"4\" fill=\"white\"/>\n    <rect x=\"8.12134\" y=\"8.94974\" width=\"3\" height=\"4\" transform=\"rotate(-135 8.12134 8.94974)\" fill=\"white\"/>\n    <rect x=\"19.1213\" y=\"19.9497\" width=\"3\" height=\"4\" transform=\"rotate(-135 19.1213 19.9497)\" fill=\"white\"/>\n    <rect x=\"17\" y=\"6.12131\" width=\"3\" height=\"4\" transform=\"rotate(-45 17 6.12131)\" fill=\"white\"/>\n    <rect x=\"6\" y=\"17.1213\" width=\"3\" height=\"4\" transform=\"rotate(-45 6 17.1213)\" fill=\"white\"/>\n    <rect x=\"12\" y=\"19\" width=\"4\" height=\"3\" fill=\"white\"/>\n    </g>\n    <defs>\n    <clipPath id=\"clip0_4_77\">\n    <rect width=\"45\" height=\"40\" fill=\"white\"/>\n    </clipPath>\n    </defs>\n    </svg>\n    ")
	}
end)()
local var_0_10 = var_0_1 and require("antibf") or (function()
	local function var_300_0(arg_301_0, ...)
		local var_301_0 = {
			...
		}

		return function(...)
			arg_301_0(unpack(var_301_0))
		end
	end

	local var_300_1 = {
		last_tick_data = {},
		debug_lines = {},
		callbacks = {},
		backtrack = {},
		find_2d_intersect = function(arg_303_0, arg_303_1, arg_303_2, arg_303_3)
			local var_303_0 = arg_303_0.x
			local var_303_1 = arg_303_1.x
			local var_303_2 = arg_303_2.x
			local var_303_3 = arg_303_3.x
			local var_303_4 = arg_303_0.y
			local var_303_5 = arg_303_1.y
			local var_303_6 = arg_303_2.y
			local var_303_7 = arg_303_3.y
			local var_303_8 = {
				x = var_303_1 - var_303_0,
				y = var_303_5 - var_303_4
			}
			local var_303_9 = {
				x = var_303_3 - var_303_2,
				y = var_303_7 - var_303_6
			}
			local var_303_10 = 0
			local var_303_11 = 0

			if var_303_9.y * var_303_8.x - var_303_8.y * var_303_9.x == 0 then
				if var_303_9.y == 0 then
					var_303_11 = var_303_6
					var_303_10 = var_303_8.x * (var_303_11 - var_303_4) / var_303_8.y + var_303_0
				elseif var_303_9.x == 0 then
					var_303_10 = var_303_2
					var_303_11 = var_303_8.y * (var_303_10 - var_303_0) / var_303_8.x + var_303_4
				end

				return {
					intersect = false
				}
			else
				var_303_11 = (var_303_9.y * var_303_8.x * var_303_4 - var_303_8.y * var_303_9.x * var_303_6 + var_303_8.y * var_303_9.y * (var_303_2 - var_303_0)) / (var_303_9.y * var_303_8.x - var_303_8.y * var_303_9.x)
				var_303_10 = var_303_8.x * ((var_303_11 - var_303_4) / var_303_8.y) + var_303_0
			end

			if var_303_10 < math.min(arg_303_2.x, arg_303_3.x) or var_303_10 > math.max(arg_303_2.x, arg_303_3.x) or var_303_11 < math.min(arg_303_2.y, arg_303_3.y) or var_303_11 > math.max(arg_303_2.y, arg_303_3.y) or var_303_10 < math.min(arg_303_0.x, arg_303_1.x) or var_303_10 > math.max(arg_303_0.x, arg_303_1.x) or var_303_11 < math.min(arg_303_0.y, arg_303_1.y) or var_303_11 > math.max(arg_303_0.y, arg_303_1.y) then
				return {
					intersect = false,
					x = var_303_10,
					y = var_303_11
				}
			end

			return {
				intersect = true,
				x = var_303_10,
				y = var_303_11
			}
		end,
		find_intersect_z = function(arg_304_0, arg_304_1, arg_304_2, arg_304_3, arg_304_4)
			local var_304_0 = arg_304_1.z - arg_304_0.z
			local var_304_1 = arg_304_0.x
			local var_304_2 = arg_304_1.x - arg_304_0.x
			local var_304_3 = arg_304_0.z
			local var_304_4 = var_304_0 * (arg_304_2 - var_304_1) / var_304_2 + var_304_3

			if var_304_4 < arg_304_3 or arg_304_4 < var_304_4 then
				return nil
			end

			return var_304_4
		end
	}
	local var_300_2 = {}

	function var_300_1.on_weapon_fire(arg_305_0)
		local var_305_0 = var_300_1

		if arg_305_0.name ~= "bullet_impact" then
			return
		end

		local var_305_1 = entity_list.get_local_player()

		if not var_305_1 or not var_305_1:is_valid() or not var_305_1:is_alive() then
			return
		end

		local var_305_2 = arg_305_0.userid
		local var_305_3 = entity_list.get_player_from_userid(var_305_2)

		if var_305_3 == nil or not var_305_3:is_valid() or var_305_3:get_index() == var_305_1:get_index() then
			return
		end

		local var_305_4 = vec3_t.new(arg_305_0.x, arg_305_0.y, arg_305_0.z)
		local var_305_5 = var_305_3:get_eye_position()

		var_305_0.debug_lines[var_305_2] = {
			vec3_t.new(0, 0, 0),
			vec3_t.new(0, 0, 0)
		}

		for iter_305_0 = #var_305_0.backtrack, 1, -1 do
			local var_305_6 = var_305_0.backtrack[iter_305_0]
			local var_305_7, var_305_8 = var_305_1:get_bounds()
			local var_305_9, var_305_10 = var_305_6 + var_305_7, var_305_6 + var_305_8
			local var_305_11 = {
				{
					vec2_t.new(var_305_9.x, var_305_9.y),
					vec2_t.new(var_305_10.x + 0.01, var_305_9.y + 0.01)
				},
				{
					vec2_t.new(var_305_10.x, var_305_9.y),
					vec2_t.new(var_305_10.x + 0.01, var_305_10.y + 0.01)
				},
				{
					vec2_t.new(var_305_10.x, var_305_10.y),
					vec2_t.new(var_305_9.x + 0.01, var_305_10.y + 0.01)
				},
				{
					vec2_t.new(var_305_9.x, var_305_10.y),
					vec2_t.new(var_305_9.x + 0.01, var_305_9.y + 0.01)
				}
			}
			local var_305_12 = {}

			for iter_305_1 = 1, #var_305_11 do
				local var_305_13 = var_305_11[iter_305_1]
				local var_305_14 = var_305_0.find_2d_intersect(var_305_5, var_305_4, var_305_13[1], var_305_13[2])

				if var_305_14.intersect then
					table.insert(var_305_12, var_305_14)
				end
			end

			local var_305_15 = {}

			if #var_305_12 > 0 then
				for iter_305_2 = 1, #var_305_12 do
					local var_305_16 = var_305_12[iter_305_2]
					local var_305_17 = var_305_0.find_intersect_z(var_305_5, var_305_4, var_305_16.x, var_305_9.z, var_305_10.z)

					if var_305_17 ~= nil then
						var_305_16.z = var_305_17

						table.insert(var_305_15, var_305_16)
					end
				end
			end

			if #var_305_15 > 0 then
				if #var_305_15 == 1 then
					table.insert(var_305_15, var_305_4)
				end

				var_300_2 = {
					var_305_9,
					var_305_10
				}
				var_305_0.last_tick_data[var_305_2] = {
					hitbox = "generic",
					waiting_for_confirmation = true,
					hit = false,
					tick = globals.tick_count(),
					max_ticks_to_wait = client.time_to_ticks(engine.get_latency()) + 2,
					backtrack = #var_305_0.backtrack - iter_305_0
				}
				var_305_0.debug_lines[var_305_2] = {
					var_305_15[1],
					var_305_15[2],
					color_t.new(255, 0, 0)
				}

				return
			end
		end
	end

	function var_300_1.invoke_callbacks(arg_306_0, arg_306_1, arg_306_2, arg_306_3, arg_306_4)
		for iter_306_0 = 1, #arg_306_0.callbacks do
			arg_306_0.callbacks[iter_306_0](arg_306_1, arg_306_2, arg_306_3, arg_306_4)
		end
	end

	function var_300_1.on_player_hurt(arg_307_0)
		local var_307_0 = entity_list.get_local_player()

		if not var_307_0 or not var_307_0:is_valid() or not var_307_0:is_alive() then
			return
		end

		local var_307_1 = var_300_1
		local var_307_2 = arg_307_0.attacker
		local var_307_3 = entity_list.get_player_from_userid(var_307_2)

		if var_307_3 == nil or not var_307_3:is_valid() then
			return
		end

		local var_307_4 = arg_307_0.userid
		local var_307_5 = entity_list.get_player_from_userid(var_307_4)

		if var_307_5 == nil or not var_307_5:is_valid() then
			return
		end

		if var_307_5:get_index() ~= var_307_0:get_index() then
			return
		end

		local var_307_6 = var_307_1.last_tick_data[var_307_2]

		if var_307_6 ~= nil then
			var_307_6.hit = true
			var_307_6.waiting_for_confirmation = false
			var_307_6.hitbox = arg_307_0.hitgroup
		else
			var_307_1:invoke_callbacks(var_307_3, globals.tick_count(), true, 0)
		end
	end

	function var_300_1.on_player_death(arg_308_0)
		local var_308_0 = var_300_1
		local var_308_1 = arg_308_0.attacker
		local var_308_2 = entity_list.get_player_from_userid(var_308_1)

		if var_308_2 == nil or not var_308_2:is_valid() then
			return
		end

		local var_308_3 = entity_list.get_local_player()
		local var_308_4 = entity_list.get_player_from_userid(arg_308_0.userid)

		if var_308_3 == nil or not var_308_3:is_valid() then
			return
		end

		if var_308_4 == nil or not var_308_4:is_valid() then
			return
		end

		if var_308_4:get_index() ~= var_308_3:get_index() then
			return
		end

		local var_308_5 = var_308_0.last_tick_data[var_308_1]

		if var_308_5 ~= nil then
			var_308_5.hit = true
			var_308_5.waiting_for_confirmation = false
			var_308_5.hitbox = arg_308_0.hitgroup
		else
			var_308_0:invoke_callbacks(var_308_2, globals.tick_count(), true, 0)
		end
	end

	function var_300_1.clean_last_data()
		local var_309_0 = globals.tick_count()

		for iter_309_0, iter_309_1 in pairs(var_300_1.last_tick_data) do
			local var_309_1 = iter_309_1.tick

			if var_309_0 > var_309_1 + iter_309_1.max_ticks_to_wait or not iter_309_1.waiting_for_confirmation then
				local var_309_2 = entity_list.get_player_from_userid(iter_309_0)

				var_300_1.debug_lines[iter_309_0][3] = iter_309_1.hit and color_t.new(0, 255, 0) or color_t.new(255, 0, 0)

				var_300_1:invoke_callbacks(var_309_2, var_309_1, iter_309_1.hit, iter_309_1.backtrack)

				var_300_1.last_tick_data[iter_309_0] = nil
			end
		end
	end

	function var_300_1.handle_backtrack(arg_310_0)
		local var_310_0 = entity_list.get_local_player()

		if not var_310_0 or not var_310_0:is_valid() or not var_310_0:is_alive() then
			return
		end

		local var_310_1 = var_310_0:get_render_origin()

		table.insert(arg_310_0.backtrack, var_310_1)

		if #arg_310_0.backtrack > 30 then
			table.remove(arg_310_0.backtrack, 1)
		end
	end

	function var_300_1.add_callback(arg_311_0, arg_311_1)
		table.insert(arg_311_0.callbacks, arg_311_1)
	end

	callbacks.add(e_callbacks.EVENT, var_300_1.on_weapon_fire, "bullet_impact")
	callbacks.add(e_callbacks.EVENT, var_300_1.on_player_hurt, "player_hurt")
	callbacks.add(e_callbacks.EVENT, var_300_1.on_player_death, "player_death")
	callbacks.add(e_callbacks.RUN_COMMAND, var_300_1.clean_last_data)
	callbacks.add(e_callbacks.RUN_COMMAND, var_300_0(var_300_1.handle_backtrack, var_300_1))

	return var_300_1
end)()

local function var_0_11(arg_312_0, ...)
	local var_312_0 = {
		...
	}

	return function(...)
		return arg_312_0(unpack(var_312_0))
	end
end

local function var_0_12(...)
	local var_314_0 = {
		...
	}

	if #var_314_0 < 3 then
		return nil
	end

	return menu.find(unpack(var_314_0)) or error("failed to find " .. table.concat(var_314_0, " -> "))
end

local function var_0_13(arg_315_0, arg_315_1, arg_315_2)
	return arg_315_0 + (arg_315_1 - arg_315_0) * arg_315_2
end

local var_0_14 = pcall(function()
	return 4
end)

math.pow = var_0_14 and function(arg_317_0, arg_317_1)
	return arg_317_0^arg_317_1
end or math.pow

local function var_0_15(arg_318_0)
	return 1 - math.pow(1 - arg_318_0, 4)
end

local function var_0_16(arg_319_0, arg_319_1, arg_319_2)
	return math.min(math.max(arg_319_0, arg_319_1), arg_319_2)
end

local function var_0_17(arg_320_0, arg_320_1, arg_320_2)
	local var_320_0 = arg_320_2 / (arg_320_1 / (arg_320_1 < arg_320_0 and arg_320_1 or arg_320_0))
	local var_320_1 = var_320_0 >= 0 and math.floor(var_320_0 + 0.5) or math.ceil( - 0.5)

	return var_320_1
end

local function var_0_18(arg_321_0, arg_321_1)
	local var_321_0 = {
		{
			237,
			27,
			3
		},
		{
			235,
			63,
			6
		},
		{
			229,
			104,
			8
		},
		{
			228,
			126,
			10
		},
		{
			115,
			220,
			13
		}
	}
	local var_321_1 = var_0_17(arg_321_0, arg_321_1, #var_321_0)

	return color_t.new(var_321_0[var_321_1 <= 1 and 1 or var_321_1][1], var_321_0[var_321_1 <= 1 and 1 or var_321_1][2], var_321_0[var_321_1 <= 1 and 1 or var_321_1][3])
end

local var_0_19 = {}

local function var_0_20(arg_322_0)
	local var_322_0 = {
		[0] = "Auto",
		"Scout",
		"AWP",
		"Deagle",
		"Revolver",
		"Pistols",
		"Other"
	}

	if arg_322_0 == nil then
		arg_322_0 = 6
	end

	local var_322_1 = var_322_0[arg_322_0]

	if var_0_19[var_322_1] ~= nil then
		return var_0_19[var_322_1]
	end

	if var_322_1 == nil then
		return {}
	end

	local var_322_2 = var_0_12("aimbot", var_322_1, "target overrides", "min. damage")
	local var_322_3 = var_0_12("aimbot", var_322_1, "target overrides", "min. damage")

	var_0_19[var_322_1] = {
		min_dmg_override = var_322_2 and var_322_2[2] or var_322_2,
		min_dmg_value = var_322_3 and var_322_3[1] or var_322_3
	}

	return var_0_19[var_322_1]
end

for iter_0_0 = 0, 6 do
	var_0_20(iter_0_0)
end

local var_0_21 = {
	slowwalk = var_0_12("misc", "main", "movement", "slow walk"),
	aa = {
		pitch = var_0_12("antiaim", "main", "angles", "pitch"),
		yaw_base = var_0_12("antiaim", "main", "angles", "yaw base"),
		yaw_add = var_0_12("antiaim", "main", "angles", "yaw add"),
		rotate = var_0_12("antiaim", "main", "angles", "rotate"),
		rotate_range = var_0_12("antiaim", "main", "angles", "rotate range"),
		rotate_speed = var_0_12("antiaim", "main", "angles", "rotate speed"),
		jitter_mode = var_0_12("antiaim", "main", "angles", "jitter mode"),
		jitter_type = var_0_12("antiaim", "main", "angles", "jitter type"),
		jitter_add = var_0_12("antiaim", "main", "angles", "jitter add"),
		body_lean = var_0_12("antiaim", "main", "angles", "body lean"),
		body_lean_value = var_0_12("antiaim", "main", "angles", "body lean value"),
		body_lean_moving = var_0_12("antiaim", "main", "angles", "moving body lean"),
		desync_left = var_0_12("antiaim", "main", "desync", "left amount"),
		desync_right = var_0_12("antiaim", "main", "desync", "right amount"),
		desync_side = var_0_12("antiaim", "main", "desync", "side"),
		onshot = var_0_12("antiaim", "main", "desync", "on shot"),
		desync_override_stand_move = var_0_12("antiaim", "main", "desync", "override stand"),
		desync_override_stand_slowwalk = var_0_12("antiaim", "main", "desync", "override stand#slow walk"),
		manual_left = var_0_12("antiaim", "main", "manual", "left"),
		manual_right = var_0_12("antiaim", "main", "manual", "right")
	}
}
local var_0_22 = var_0_8.create()

var_0_22:set_title("eclipse - debug")

local var_0_23 = menu.get_pos()
local var_0_24 = menu.get_size()

var_0_22:set_min_size(vec2_t.new(750, var_0_22.min_size.y + 30))

local var_0_25 = var_0_23.y + var_0_24.y / 2 - var_0_22.size.y / 2

var_0_22.pos = vec2_t.new(var_0_23.x + var_0_24.x + 10, var_0_25)
var_0_22.globals = {
	version = var_0_0 and "debug" or "live",
	name = user.name,
	uid = user.uid,
	screen_size = render.get_screen_size()
}
var_0_22.fonts = {
	default = render.get_default_font(),
	defensive = render.create_font("Verdana", 12, 700, e_font_flags.ANTIALIAS, e_font_flags.DROPSHADOW),
	crosshair = render.create_font("Small Fonts", 10, 400, e_font_flags.ANTIALIAS, e_font_flags.OUTLINE),
	eclipse = render.create_font("Small Fonts", 13, 600, e_font_flags.DROPSHADOW, e_font_flags.OUTLINE),
	crosshair_mindmg = render.create_font("Small Fonts", 10, 400)
}

local var_0_26 = {
	dark_background = color_t.new(29, 29, 29),
	subtab_background = color_t.new(34, 34, 34)
}
local var_0_27 = {
	DROPDOWN = 1,
	CHECKBOX = 0
}
local var_0_28 = {
	SIDE = 1,
	DOWN = 0
}

local function var_0_29(arg_323_0, arg_323_1)
	local var_323_0 = {}

	var_323_0.size_y = 14

	local var_323_1 = arg_323_1 and 1 or 0

	var_323_0.name = type(arg_323_0) == "string" and arg_323_0 or error(string.format("Invalid name for option_checkbox_t. Got \"%s\", expected \"string\".", type(arg_323_0)))
	var_323_0.state = type(arg_323_1) == "boolean" and var_323_1 or error(string.format("Invalid default state for option_checkbox_t. Got \"%s\", expected \"boolean\".", type(arg_323_1)))
	var_323_0.type = var_0_27.CHECKBOX
	var_323_0.visible = true
	var_323_0.animation = {
		last_time = 0,
		time = 0.05
	}
	var_323_0.scrolling_offset = 0

	function var_323_0.click(arg_324_0)
		arg_324_0.state = arg_324_0.state ~= 1

		if #arg_324_0.callbacks > 0 then
			for iter_324_0, iter_324_1 in pairs(arg_324_0.callbacks) do
				iter_324_1()
			end
		end

		arg_324_0.animation.last_time = global_vars.real_time()
	end

	function var_323_0.get(arg_325_0)
		return arg_325_0.state == 1
	end

	function var_323_0.set(arg_326_0, arg_326_1)
		if not type(arg_326_1) == "boolean" then
			error(string.format("Invalid parameter for option_checkbox_t:set( boolean ). Got \"%s\", expected \"boolean\".", type(arg_326_1)))
		end

		arg_326_0.state = arg_326_1 and 1 or 0
		arg_326_0.animation.last_time = global_vars.real_time()
	end

	function var_323_0.set_visible(arg_327_0, arg_327_1)
		if not type(arg_327_1) == "boolean" then
			error(string.format("Invalid parameter for option_checkbox_t:set_visible( boolean ). Got \"%s\", expected \"boolean\".", type(arg_327_1)))
		end

		arg_327_0.visible = arg_327_1
	end

	var_323_0.callbacks = {}

	function var_323_0.register_callback(arg_328_0, arg_328_1)
		table.insert(arg_328_0.callbacks, arg_328_1)
	end

	function var_323_0.render(arg_329_0, arg_329_1, arg_329_2, arg_329_3, arg_329_4, arg_329_5)
		if arg_329_0.visible then
			local var_329_0 = not arg_329_0:get()
			local var_329_1 = (global_vars.real_time() - arg_329_0.animation.last_time) / arg_329_0.animation.time

			if var_329_0 then
				var_329_1 = 1 - var_329_1
			end

			local var_329_2 = math.clamp(var_329_1, 0, 1)
			local var_329_3 = math.floor(var_329_2 * 255)
			local var_329_4 = arg_329_1 + arg_329_2
			local var_329_5 = vec2_t.new(12, 12)

			render.rect_filled(var_329_4, var_329_5, color_t.new(50, 50, 50, 255), 2)
			render.rect_filled(var_329_4 + vec2_t.new(1, 1), var_329_5 - vec2_t.new(2, 2), color_t.new(0, 0, 0, 255), 2)

			local var_329_6 = color_t.new(arg_329_5.r, arg_329_5.g, arg_329_5.b, var_329_3)

			render.rect_filled(var_329_4 + vec2_t.new(2, 2), var_329_5 - vec2_t.new(4, 4), var_329_6, 3)

			local var_329_7 = arg_329_1 + vec2_t.new(arg_329_2.x + 14, arg_329_2.y)

			render.text(var_0_22.fonts.default, arg_329_0.name, var_329_7 - vec2_t.new(0, 1), color_t.new(255, 255, 255, 255))

			if arg_329_4 and input.is_mouse_in_bounds(arg_329_1 + vec2_t.new(0, arg_329_2.y - 1), vec2_t.new(arg_329_3, var_0_22.fonts.default.height)) and input.is_key_pressed(e_keys.MOUSE_LEFT) then
				arg_329_0:set(var_329_0)
			end
		end
	end

	return var_323_0
end

local var_0_30 = "1234567890qwertyuiopüõasdfghjklöäzxcvbnm,.-=!\"#¤%&/()"

local function var_0_31()
	local var_330_0 = math.randomseed(client.random_float(0, 1000) * 1000)
	local var_330_1 = ""

	for iter_330_0 = 0, 10 do
		local var_330_2 = client.random_int(1, #var_0_30 - 1)

		var_330_1 = var_330_1 .. string.sub(var_0_30, var_330_2, var_330_2 + 1)
	end

	return var_330_1
end

local function var_0_32(arg_331_0, arg_331_1, arg_331_2)
	local var_331_0 = {
		name = type(arg_331_0) == "string" and arg_331_0 or error(string.format("Invalid name for option_dropdown_t. Got \"%s\", expected \"string\".", type(arg_331_1))),
		values = type(arg_331_1) == "table" and arg_331_1 or error(string.format("Invalid default state for option_dropdown_t. Got \"%s\", expected \"table\".", type(arg_331_1))),
		items = {}
	}

	for iter_331_0, iter_331_1 in pairs(var_331_0.values) do
		local var_331_1 = arg_331_2 == iter_331_0

		var_331_0.items[iter_331_0] = {
			name = iter_331_1,
			selected = var_331_1
		}
	end

	var_331_0.id = var_0_31()
	var_331_0.type = var_0_27.DROPDOWN
	var_331_0.visible = true
	var_331_0.open = false
	var_331_0.animation = {
		name_offset = 0,
		last_time = 0,
		time = 0.05
	}
	var_331_0.enabled_offset = 0

	local function var_331_2(arg_332_0)
		if type(arg_332_0) ~= "number" then
			error(string.format("Invalid parameter for option_dropdown_t:get( index ). Got \"%s\", expected \"number\".", type(arg_332_0)))
		elseif arg_332_0 > #var_331_0.items then
			error(string.format("Invalid index for option_dropdown_t:get( index ). Got \"%s\", expected \"1 .. %s\".", arg_332_0, #var_331_0.items))
		end
	end

	var_331_0.scrolling_offset = 0

	function var_331_0.click(arg_333_0, arg_333_1)
		arg_333_0.open = not arg_333_0.open
		arg_333_0.animation.last_time = global_vars.real_time()
	end

	function var_331_0.get(arg_334_0, arg_334_1)
		var_331_2(arg_334_1)

		return arg_334_0.items[arg_334_1]
	end

	function var_331_0.set(arg_335_0, arg_335_1)
		var_331_2(arg_335_1)

		for iter_335_0, iter_335_1 in pairs(arg_335_0.items) do
			iter_335_1.selected = false
		end

		arg_335_0.items[arg_335_1].selected = true
	end

	function var_331_0.get_items(arg_336_0)
		return arg_336_0.items
	end

	function var_331_0.set_visible(arg_337_0, arg_337_1)
		if not type(arg_337_1) == "boolean" then
			error(string.format("Invalid parameter for option_dropdown_t:set_visible( boolean ). Got \"%s\", expected \"boolean\".", type(arg_337_1)))
		end

		arg_337_0.visible = arg_337_1
	end

	var_331_0.callbacks = {}

	function var_331_0.register_callback(arg_338_0, arg_338_1)
		table.insert(arg_338_0.callbacks, arg_338_1)
	end

	function var_331_0.render(arg_339_0, arg_339_1, arg_339_2, arg_339_3, arg_339_4, arg_339_5)
		if arg_339_0.visible then
			local var_339_0 = (globals.real_time() - arg_339_0.animation.last_time) / arg_339_0.animation.time
			local var_339_1 = math.clamp(var_339_0, 0, 1)

			var_339_1 = arg_339_0.open and var_339_1 or 1 - var_339_1

			local var_339_2 = math.floor(var_339_1 * 255)
			local var_339_3 = 0
			local var_339_4 = arg_339_1 + vec2_t.new(8, 4)
			local var_339_5 = var_339_4 + vec2_t.new(-3, 14)
			local var_339_6 = render.get_text_size(var_0_22.fonts.default, arg_339_0.name)

			if input.is_mouse_in_bounds(var_339_4, vec2_t.new(arg_339_3, var_339_6.x)) then
				if render.get_text_size(var_0_22.fonts.default, arg_339_0.name).x - arg_339_3 > arg_339_0.animation.name_offset - 8 then
					arg_339_0.animation.name_offset = arg_339_0.animation.name_offset + 1
				end
			else
				arg_339_0.animation.name_offset = math.max(arg_339_0.animation.name_offset - 1, 0)
			end

			local var_339_7 = var_339_4 - vec2_t.new(arg_339_0.animation.name_offset, 0)

			render.push_clip(arg_339_1 + vec2_t.new(0, -3), vec2_t.new(arg_339_3, 20))
			render.text(var_0_22.fonts.default, arg_339_0.name, var_339_7, color_t.new(255, 255, 255, 255))
			render.pop_clip()

			local var_339_8 = vec2_t.new(arg_339_3 - 10, 18)

			render.rect_filled(var_339_5, var_339_8, color_t.new(50, 50, 50, 255), 2)
			render.rect_filled(var_339_5 + vec2_t.new(1, 1), var_339_8 - vec2_t.new(2, 2), color_t.new(0, 0, 0, 255), 2)

			local var_339_9 = ""
			local var_339_10 = arg_339_0:get_items()

			for iter_339_0 = 1, #var_339_10 do
				local var_339_11 = var_339_10[iter_339_0]

				if var_339_11.selected then
					var_339_9 = var_339_9 .. var_339_11.name .. ", "
				end
			end

			local var_339_12 = var_339_9 == "" and "-" or :sub(1, -3)
			local var_339_13 = render.get_text_size(var_0_22.fonts.default, var_339_12).x

			if input.is_mouse_in_bounds(var_339_5 + vec2_t.new(5, 3), vec2_t.new(arg_339_3, 20)) and arg_339_3 - 20 - var_339_13 < 0 then
				arg_339_0.enabled_offset = math.min(arg_339_0.enabled_offset + 0.5, var_339_13 - arg_339_3 + 20)
			else
				arg_339_0.enabled_offset = math.max(arg_339_0.enabled_offset - 1, 0)
			end

			render.push_clip(var_339_5 + vec2_t.new(1, 3), vec2_t.new(arg_339_3 - 13, 20))
			render.text(var_0_22.fonts.default, var_339_12, var_339_5 + vec2_t.new(5 - arg_339_0.enabled_offset, 3), color_t.new(180, 180, 180, 255))
			render.pop_clip()

			if arg_339_4 and input.is_key_pressed(e_keys.MOUSE_LEFT) and input.is_mouse_in_bounds(var_339_5, var_339_8) then
				arg_339_0:click()
			end

			local var_339_14 = math.clamp(15 * #arg_339_0.items, 0, 100) * var_339_1

			render.push_clip(var_339_5 + vec2_t.new(0, 18), vec2_t.new(arg_339_3 - 10, var_339_14))
			render.rect_filled(var_339_5 + vec2_t.new(1, var_339_8.y), vec2_t.new(var_339_8.x - 2, var_339_14), color_t.new(0, 0, 0, var_339_2), 2)

			local var_339_15 = input.is_mouse_in_bounds(var_339_5, var_339_8 + vec2_t.new(0, var_339_14))

			if arg_339_0.open and input.is_key_pressed(e_keys.MOUSE_LEFT) and not var_339_15 then
				arg_339_0:click()
			end

			arg_339_0.scrolling_offset = math.clamp(arg_339_0.scrolling_offset + input.get_scroll_delta() * 4, -15 * #arg_339_0.items + 100, 0)

			local var_339_16 = var_339_15 and math.floor((input.get_mouse_pos().y - var_339_5.y - var_339_8.y - arg_339_0.scrolling_offset) / 15) + 1 or nil

			if arg_339_0.open and var_339_16 ~= nil and var_339_16 ~= 0 and arg_339_0.items[var_339_16] ~= nil then
				local var_339_17 = var_339_5 + vec2_t.new(1, var_339_8.y + 15 * (var_339_16 - 1) + arg_339_0.scrolling_offset)

				if input.is_key_pressed(e_keys.MOUSE_LEFT) and input.is_mouse_in_bounds(var_339_17, vec2_t.new(var_339_8.x, 15)) then
					arg_339_0:set(var_339_16)
				end
			end

			if arg_339_0.open then
				for iter_339_1 = 1, #arg_339_0.items do
					local var_339_18 = arg_339_0.items[iter_339_1]
					local var_339_19 = var_339_5 + vec2_t.new(1, var_339_8.y + 15 * (iter_339_1 - 1))
					local var_339_20 = var_339_18.selected and color_t.new(arg_339_5.r, arg_339_5.g, arg_339_5.b, var_339_2) or color_t.new(180, 180, 180, var_339_2)

					render.text(var_0_22.fonts.default, var_339_18.name, var_339_19 + vec2_t.new(5, arg_339_0.scrolling_offset), var_339_20)
				end
			end

			render.pop_clip()
		end
	end

	return var_331_0
end

local function var_0_33(arg_340_0)
	return {
		width = arg_340_0.width or error("Please specify size to menu_t."),
		menu_elements = {},
		options = arg_340_0.interaction_menu or error("No interaction menu specified for menu_t."),
		visible = arg_340_0.visible or false,
		animation = arg_340_0.animation or {
			last_time = 0,
			time = 1
		},
		add_checkbox = function(arg_341_0, arg_341_1, arg_341_2)
			arg_341_0.menu_elements[#arg_341_0.menu_elements + 1] = var_0_29(arg_341_1, arg_341_2)

			return arg_341_0.menu_elements[#arg_341_0.menu_elements]
		end,
		add_dropdown = function(arg_342_0, arg_342_1, arg_342_2, arg_342_3)
			arg_342_0.menu_elements[#arg_342_0.menu_elements + 1] = var_0_32(arg_342_1, arg_342_2, arg_342_3)

			return arg_342_0.menu_elements[#arg_342_0.menu_elements]
		end,
		show = function(arg_343_0)
			arg_343_0.visible = not arg_343_0.visible
			arg_343_0.animation.last_time = global_vars.real_time()
		end,
		render = function(arg_344_0)
			local var_344_0 = not arg_344_0.visible

			if var_344_0 and 1 - (global_vars.real_time() - arg_344_0.animation.last_time) / arg_344_0.animation.time < 0 then
				return
			end

			local var_344_1 = 17
			local var_344_2 = var_344_1 + var_0_22.fonts.default.height

			for iter_344_0 = 1, #arg_344_0.menu_elements do
				local var_344_3 = arg_344_0.menu_elements[iter_344_0]

				if var_344_3.visible then
					if var_344_3.type == var_0_27.CHECKBOX then
						var_344_2 = var_344_2 + 16
					elseif var_344_3.type == var_0_27.DROPDOWN then
						var_344_2 = var_344_2 + 34
					end
				end
			end

			local var_344_4 = arg_344_0.options.width
			local var_344_5 = arg_344_0.options.pos
			local var_344_6 = (global_vars.real_time() - arg_344_0.animation.last_time) / arg_344_0.animation.time
			local var_344_7 = math.clamp(var_344_6, 0, 1)

			render.push_alpha_modifier(var_0_13(0, 1, var_344_0 and 1 - var_344_7 or var_344_7))

			local var_344_8 = (global_vars.real_time() - arg_344_0.animation.last_time) / arg_344_0.animation.time * var_344_2
			local var_344_9 = math.clamp(var_344_8, 0, var_344_2)

			render.push_clip(var_344_5, vec2_t.new(var_344_4, var_344_2))
			render.rect_filled(var_344_5, vec2_t.new(var_344_4, var_344_2), color_t.new(0, 0, 0, 255), 8)
			render.rect_filled(var_344_5 + vec2_t.new(1, 1), vec2_t.new(var_344_4 - 2, var_344_2 - 2), var_0_26.dark_background, 8)
			render.rect_filled(var_344_5 + vec2_t.new(1, 1), vec2_t.new(var_344_4 - 2, var_344_1), var_0_26.subtab_background, 8)
			render.rect_filled(var_344_5 + vec2_t.new(1, 5), vec2_t.new(var_344_4 - 2, var_344_1 - 4), var_0_26.subtab_background, 0)

			local var_344_10 = var_0_22:get_accent_color()

			render.line(var_344_5 + vec2_t.new(1, var_344_1), var_344_5 + vec2_t.new(var_344_4 - 1, var_344_1), var_344_10)
			render.text(var_0_22.fonts.default, arg_344_0.options.title, var_344_5 + vec2_t.new(var_344_4 / 2, var_0_22.fonts.default.height / 2 + 3), color_t.new(255, 255, 255, 255), true)

			local var_344_11 = 18
			local var_344_12 = {}
			local var_344_13 = false

			for iter_344_1 = 1, #arg_344_0.menu_elements do
				local var_344_14 = arg_344_0.menu_elements[iter_344_1]

				if var_344_14.visible then
					if var_344_14.type ~= var_0_27.DROPDOWN then
						var_344_14:render(var_344_5 + vec2_t.new(0, var_344_11), vec2_t.new(5, 5), arg_344_0.width, not var_344_13, var_344_10)

						var_344_11 = var_344_11 + 16
					else
						var_344_13 = var_344_13 and true or var_344_14.open

						table.insert(var_344_12, {
							option = var_344_14,
							offset = var_344_11
						})

						var_344_11 = var_344_11 + 32
					end
				end
			end

			render.pop_clip()

			local var_344_15
			local var_344_16 = false

			for iter_344_2 = 1, #var_344_12 do
				local var_344_17 = var_344_12[iter_344_2].option

				var_344_16 = var_344_16 and true or var_344_17.open
				var_344_15 = var_344_15 and var_344_15 or var_344_16 and var_344_17.id or nil
			end

			for iter_344_3 = #var_344_12, 1, -1 do
				local var_344_18 = var_344_12[iter_344_3].option
				local var_344_19 = var_344_12[iter_344_3].offset
				local var_344_20 = not var_344_16 or var_344_15 == var_344_18.id or false

				var_344_18:render(var_344_5 + vec2_t.new(0, var_344_19), vec2_t.new(5, 5), arg_344_0.width, var_344_20, var_344_10)
			end

			if not var_344_16 and not input.is_mouse_in_bounds(var_344_5, vec2_t.new(var_344_4, var_344_2)) and input.is_key_pressed(e_keys.MOUSE_LEFT) then
				arg_344_0:show()
			end

			render.pop_alpha_modifier()
		end
	}
end

local function var_0_34(arg_345_0)
	local var_345_0 = {
		width = arg_345_0.width or 100,
		title = arg_345_0.title or "interaction menu",
		pos = vec2_t.new(0, 0),
		menu_t = var_0_33({
			visible = false,
			width = var_345_0.width,
			interaction_menu = var_345_0,
			animation = {
				last_time = 0,
				time = 0.2
			}
		}),
		add_checkbox = function(arg_346_0, arg_346_1, arg_346_2)
			return arg_346_0.menu_t:add_checkbox(arg_346_1, arg_346_2)
		end,
		add_dropdown = function(arg_347_0, arg_347_1, arg_347_2, arg_347_3)
			return arg_347_0.menu_t:add_dropdown(arg_347_1, arg_347_2, arg_347_3)
		end
	}

	return var_345_0
end

local function var_0_35(arg_348_0)
	local var_348_0 = {
		pos = arg_348_0.pos or vec2_t.new(100, 100),
		size = arg_348_0.size or vec2_t.new(100, 100),
		interaction_menu = arg_348_0.interaction_menu or var_0_34({
			pos = var_348_0.pos
		}),
		opens_to = arg_348_0.opens_to or var_0_28.DOWN
	}

	var_348_0.interaction_menu.width = var_348_0.size.x
	var_348_0.custom_render_hook = nil

	if not var_348_0.interaction_menu.animation then
		var_348_0.interaction_menu.animation = {}
	end

	var_348_0.title_texts = arg_348_0.texts or {
		"this",
		"is",
		"a",
		"draggable"
	}
	var_348_0.difference = vec2_t.new(0, 0)
	var_348_0.dragging = false

	function var_348_0.set_render_fn(arg_349_0, arg_349_1)
		arg_349_0.custom_render_hook = arg_349_1
	end

	var_348_0.handlers = {}

	function var_348_0.handle_dragging(arg_350_0)
		if not menu.is_open() then
			arg_350_0.dragging = false

			return
		end

		if arg_350_0.dragging or input.is_key_held(e_keys.MOUSE_LEFT) and input.is_mouse_in_bounds(arg_350_0.pos, arg_350_0.size) then
			arg_350_0.pos = input.get_mouse_pos() - arg_350_0.difference
			arg_350_0.dragging = true
		else
			arg_350_0.difference = input.get_mouse_pos() - arg_350_0.pos
		end

		if not input.is_key_held(e_keys.MOUSE_LEFT) then
			arg_350_0.dragging = false
		end
	end

	function var_348_0.set_render_hook(arg_351_0, arg_351_1)
		arg_351_0.custom_render_hook = arg_351_1
	end

	function var_348_0.get_items(arg_352_0)
		return arg_352_0.interaction_menu.entries
	end

	function var_348_0.get_option(arg_353_0, arg_353_1)
		local var_353_0 = arg_353_0:get_items()

		for iter_353_0 = 1, #var_353_0 do
			if var_353_0[iter_353_0].name == arg_353_1 then
				return var_353_0[iter_353_0]
			end
		end

		return nil
	end

	function var_348_0.handle_interaction_menu(arg_354_0)
		if arg_354_0.dragging and arg_354_0.interaction_menu.menu_t.visible then
			arg_354_0.interaction_menu.menu_t:show()

			return
		end

		if not arg_354_0.dragging and input.is_key_pressed(e_keys.MOUSE_RIGHT) and input.is_mouse_in_bounds(arg_354_0.pos, arg_354_0.size) then
			if not arg_354_0.interaction_menu.menu_t.visible then
				if arg_354_0.opens_to == var_0_28.DOWN then
					arg_354_0.interaction_menu.pos = vec2_t.new(input.get_mouse_pos().x - arg_354_0.interaction_menu.width / 2, arg_354_0.pos.y + arg_354_0.size.y + 5)

					local var_354_0 = arg_354_0.interaction_menu.pos.x - arg_354_0.pos.x

					if var_354_0 < 0 then
						arg_354_0.interaction_menu.pos.x = arg_354_0.interaction_menu.pos.x - var_354_0
					else
						local var_354_1 = arg_354_0.interaction_menu.pos.x + arg_354_0.interaction_menu.width - (arg_354_0.pos.x + arg_354_0.size.x)

						if var_354_1 > 0 then
							arg_354_0.interaction_menu.pos.x = arg_354_0.interaction_menu.pos.x - var_354_1
						end
					end

					if arg_354_0.interaction_menu.pos.x + arg_354_0.interaction_menu.width > render.get_screen_size().x then
						arg_354_0.interaction_menu.pos.x = render.get_screen_size().x - arg_354_0.interaction_menu.width - 10
					end
				elseif arg_354_0.opens_to == var_0_28.SIDE then
					arg_354_0.interaction_menu.pos = vec2_t.new(arg_354_0.pos.x + arg_354_0.interaction_menu.width + 5, arg_354_0.pos.y)

					if arg_354_0.interaction_menu.pos.x + arg_354_0.interaction_menu.width + 5 > render.get_screen_size().x then
						arg_354_0.interaction_menu.pos.x = arg_354_0.pos.x - arg_354_0.interaction_menu.menu_t.width - 5
					end
				end
			end

			arg_354_0.interaction_menu.menu_t:show()
		end
	end

	function var_348_0.handle_drawing(arg_355_0)
		arg_355_0:handle_interaction_menu()

		if arg_355_0.custom_render_hook then
			arg_355_0.custom_render_hook(arg_355_0)
		end

		arg_355_0.interaction_menu.menu_t:render()
	end

	return var_348_0
end

local var_0_36 = {
	"Standing / global",
	"Defensive",
	"Moving",
	"Air",
	"Air duck",
	"Ducking",
	"Slowwalking"
}

var_0_22.settings = {
	ragebot = {
		deagle_land_accuracy = var_0_22:add_checkbox("rage", "general", "general", "Deagle landing accuracy "),
		lethal_revolver_dmg = var_0_22:add_checkbox("rage", "general", "general", "Adaptive revolver damage "),
		force_safepoint_after_x_misses = var_0_22:add_checkbox("rage", "general", "general", "Force safepoint after x misses "),
		force_safepoint_after_x_misses_value = var_0_22:add_slider("rage", "general", "general", "Force safepoint after ", 1, 10, 1, " misses"),
		force_safepoint_after_x_misses_reset = var_0_22:add_slider("rage", "general", "general", "Reset after ", 1, 10, 1, " seconds"),
		ideal_tick_checkbox = var_0_22:add_text("rage", "general", "Tickbase exploits", "Ideal tick"):add_keybind("ideal tick keybind", 2)
	},
	antiaim = {
		master = var_0_22:add_checkbox("antiaim", "general", "general", "Enable anti-aim extras"),
		edge_yaw = var_0_22:add_checkbox("antiaim", "general", "general", "Edge yaw"),
		defensive_safety = var_0_22:add_combo("antiaim", "general", "general", "Defensive mode", {
			"Unsafe",
			"Semi-safe",
			"Safe"
		}, 3),
		override_left_right = var_0_22:add_checkbox("antiaim", "general", "directions", "Override manual"),
		manual_left = var_0_22:add_slider("antiaim", "general", "directions", "Manual left", 30, 150, 90, "°"),
		manual_right = var_0_22:add_slider("antiaim", "general", "directions", "Manual right", 30, 150, 90, "°"),
		conditional_active_state = var_0_22:add_combo("antiaim", "conditional", "general", "Active state", var_0_36),
		conditional_separator = var_0_22:add_separator("antiaim", "conditional", "general"),
		conditional_not_enabled = var_0_22:add_text("antiaim", "conditional", "general", "Anti-aim is not enabled")
	},
	conditional = {},
	visuals = {
		defensive = var_0_22:add_checkbox("visuals", "general", "crosshair", "Defensive indicator"),
		crosshair = var_0_22:add_checkbox("visuals", "general", "crosshair", "Crosshair indicators"),
		crosshair_scope_animation = var_0_22:add_checkbox("visuals", "general", "crosshair", "Scope animation"),
		crosshair_binds = var_0_22:add_multicombo("visuals", "general", "crosshair", "Crosshair binds", {
			"Freestand",
			"Ping spike",
			"Quick peek assist",
			"Roll Resolver",
			"Hide Shots",
			"Double Tap",
			"Fake Duck"
		}),
		crosshair_state = var_0_22:add_text("visuals", "general", "crosshair", "Crosshair state color"),
		crosshair_brand = var_0_22:add_text("visuals", "general", "crosshair", "Eclipse color"),
		hitlogs = var_0_22:add_checkbox("visuals", "general", "hitlogs", "Hitlogs"),
		hitlogs_offset = var_0_22:add_slider("visuals", "general", "hitlogs", "Hitlogs offset", 30, 500, 300, "px"),
		watermark = var_0_22:add_checkbox("visuals", "general", "information", "Watermark panel"),
		hint_text = var_0_22:add_text("visuals", "general", "information", "* You can right click on panels to open a new menu"),
		client_sided_animations = var_0_22:add_checkbox("visuals", "client-side", "animations", "Enable"),
		animations = var_0_22:add_multicombo("visuals", "client-side", "animations", "Animations", {
			"0-pitch on land",
			"static legs in air",
			"lean in air",
			"backwards slide"
		}),
		fake_media = var_0_22:add_multicombo("visuals", "client-side", "other", "Fake media", {
			"100% headshot",
			"Noscope",
			"Flash",
			"Wallbang",
			"Dominate",
			"Smoke"
		}),
		grim_reaper = var_0_22:add_checkbox("visuals", "client-side", "other", "Grim reaper"),
		branding = var_0_22:add_checkbox("visuals", "client-side", "other", "Branding"),
		page_icon_animations = var_0_22:add_checkbox("visuals", "menu", "general", "page icon animations"),
		override_menu_colors = var_0_22:add_checkbox("visuals", "menu", "general", "override menu colors"),
		text_colors = var_0_22:add_text("visuals", "menu", "colors", "Text colors"),
		inactive_text_t = var_0_22:add_text("visuals", "menu", "colors", "Inactive text"),
		hovering_text_t = var_0_22:add_text("visuals", "menu", "colors", "Hovering text"),
		active_text_t = var_0_22:add_text("visuals", "menu", "colors", "Active text"),
		outline_colors = var_0_22:add_text("visuals", "menu", "colors", "Outline colors"),
		inactive_outline_t = var_0_22:add_text("visuals", "menu", "colors", "Inactive outline"),
		hovering_outline_t = var_0_22:add_text("visuals", "menu", "colors", "Hovering outline"),
		active_outline_t = var_0_22:add_text("visuals", "menu", "colors", "Active outline"),
		background_colors = var_0_22:add_text("visuals", "menu", "colors", "Background colors"),
		dark_background_t = var_0_22:add_text("visuals", "menu", "colors", "Dark background"),
		subtab_background_t = var_0_22:add_text("visuals", "menu", "colors", "Subtab background"),
		section_background_t = var_0_22:add_text("visuals", "menu", "colors", "Section background"),
		footer_background_t = var_0_22:add_text("visuals", "menu", "colors", "Footer background"),
		reset_menu_colors = var_0_22:add_button("visuals", "menu", "colors", "Reset menu colors")
	},
	misc = {},
	config = {
		configs = var_0_22:add_list("config", "general", "general", {}),
		autoload = var_0_22:add_combo("config", "general", "general", "Autoload", {}),
		open_folder = var_0_22:add_button("config", "general", "general", "Open configs folder"),
		var_0_22:add_separator("config", "general", "general"),
		refresh = var_0_22:add_button("config", "general", "general", "Refresh configs"),
		save = var_0_22:add_button("config", "general", "general", "Save config"),
		load = var_0_22:add_button("config", "general", "general", "Load config"),
		delete = var_0_22:add_button("config", "general", "general", "Delete selected"),
		reset = var_0_22:add_button("config", "general", "general", "Reset config"),
		var_0_22:add_separator("config", "general", "general"),
		new = var_0_22:add_text_input("config", "general", "general", "New config name", "kuftiname"),
		create = var_0_22:add_button("config", "general", "general", "Create config"),
		user_hello = var_0_22:add_text("config", "general", "user info", "Hello, " .. user.name .. " (" .. tostring(user.uid) .. ")."),
		user_version = var_0_22:add_text("config", "general", "user info", "You are using Eclipse " .. (var_0_0 and "Debug (thx)" or "Release") .. "."),
		join_discord = var_0_22:add_button("config", "general", "user info", "Join our Discord")
	}
}

local var_0_37 = {
	override = {
		value = false,
		type = "checkbox",
		vis_conds = {}
	},
	settings = {
		type = "multicombo",
		value = {
			"Pitch",
			"Yaw base",
			"Yaw add",
			"Rotate",
			"Body lean"
		},
		vis_conds = {
			{
				"override",
				true
			}
		},
		tooltips = {
			"Select the antiaim settings you want to config.",
			"Settings will be set to default values when the items are not selected."
		}
	},
	pitch = {
		type = "combo",
		value = {
			"None",
			"Down",
			"Up",
			"Zero",
			"Jitter",
			"Custom"
		},
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				"Pitch"
			}
		}
	},
	custom_pitch = {
		step = 1,
		min = -89,
		type = "slider",
		value = 0,
		max = 89,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				"Pitch"
			},
			{
				"pitch",
				6
			}
		}
	},
	yaw_base = {
		type = "combo",
		value = {
			"None",
			"Viewangle",
			"At-target (crosshair)",
			"At-target (distance)",
			"Velocity"
		},
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				2
			}
		}
	},
	yaw_add = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				3
			}
		}
	},
	jitter_mode = {
		type = "combo",
		value = {
			"None",
			"Static",
			"Random"
		},
		vis_conds = {
			{
				"override",
				true
			}
		}
	},
	jitter_type = {
		type = "combo",
		value = {
			"Offset",
			"Center",
			"3-way",
			"5-way",
			"X-way"
		},
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			}
		}
	},
	jitter_add = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			}
		}
	},
	force_defensive = {
		value = false,
		type = "checkbox",
		vis_conds = {
			{
				"override",
				true
			}
		},
		tooltips = {
			"Allows you to constantly break lag compensation while using doubletap.",
			"The \"defensive\" condition will apply while you are breaking lagcompensation."
		}
	},
	rotate_range = {
		step = 1,
		min = 0,
		type = "slider",
		value = 0,
		max = 360,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				4
			}
		}
	},
	rotate_speed = {
		step = 1,
		min = 0,
		type = "slider",
		value = 0,
		max = 100,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				4
			}
		}
	},
	body_lean = {
		type = "combo",
		value = {
			"None",
			"Static",
			"Static Jitter",
			"Sway"
		},
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				"Body lean"
			}
		}
	},
	body_lean_amount = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				"Body lean"
			},
			{
				"body_lean",
				2,
				">="
			}
		}
	},
	body_lean_moving = {
		value = false,
		type = "checkbox",
		vis_conds = {
			{
				"override",
				true
			},
			{
				"settings",
				"Body lean"
			}
		}
	},
	desync_side = {
		section = "Desync",
		type = "combo",
		value = {
			"None",
			"Left",
			"Right",
			"Jitter",
			"Peek Fake",
			"Peek Real",
			"Body Sway"
		},
		vis_conds = {
			{
				"override",
				true
			}
		}
	},
	left_range = {
		step = 1,
		min = 0,
		type = "slider",
		value = 0,
		section = "Desync",
		suffix = "%",
		max = 100,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"desync_side",
				2,
				">="
			}
		}
	},
	right_range = {
		step = 1,
		min = 0,
		type = "slider",
		value = 0,
		section = "Desync",
		suffix = "%",
		max = 100,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"desync_side",
				2,
				">="
			}
		}
	},
	separator_desync = {
		section = "Desync",
		type = "separator",
		vis_conds = {
			{
				"override",
				true
			}
		}
	},
	on_shot = {
		section = "Desync",
		type = "combo",
		value = {
			"Off",
			"Opposite",
			"Same side",
			"Random"
		},
		vis_conds = {
			{
				"override",
				true
			}
		}
	},
	cool_text = {
		value = "blank_section",
		section = "blank_section",
		type = "text",
		vis_conds = {
			{
				"override",
				true
			},
			{
				"desync_side",
				69
			}
		}
	},
	x_way_ways = {
		step = 1,
		min = 3,
		type = "slider",
		value = 3,
		section = "X-way settings",
		suffix = "-way",
		max = 9,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			}
		}
	},
	x_way_configurer_1 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				3,
				">="
			}
		}
	},
	x_way_configurer_2 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				3,
				">="
			}
		}
	},
	x_way_configurer_3 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				3,
				">="
			}
		}
	},
	x_way_configurer_4 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				4,
				">="
			}
		}
	},
	x_way_configurer_5 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				5,
				">="
			}
		}
	},
	x_way_configurer_6 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				6,
				">="
			}
		}
	},
	x_way_configurer_7 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				7,
				">="
			}
		}
	},
	x_way_configurer_8 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				8,
				">="
			}
		}
	},
	x_way_configurer_9 = {
		step = 1,
		min = -180,
		type = "slider",
		value = 0,
		section = "X-way settings",
		max = 180,
		vis_conds = {
			{
				"override",
				true
			},
			{
				"jitter_mode",
				2
			},
			{
				"jitter_type",
				5
			},
			{
				"x_way_ways",
				9
			}
		}
	}
}
local var_0_38 = {
	"override",
	"settings",
	"pitch",
	"custom_pitch",
	"yaw_base",
	"yaw_add",
	"jitter_mode",
	"jitter_type",
	"jitter_add",
	"force_defensive",
	"rotate_range",
	"rotate_speed",
	"body_lean",
	"body_lean_amount",
	"body_lean_moving",
	"desync_side",
	"left_range",
	"right_range",
	"separator_desync",
	"on_shot",
	"cool_text",
	"x_way_ways",
	"x_way_configurer_1",
	"x_way_configurer_2",
	"x_way_configurer_3",
	"x_way_configurer_4",
	"x_way_configurer_5",
	"x_way_configurer_6",
	"x_way_configurer_7",
	"x_way_configurer_8",
	"x_way_configurer_9"
}

var_0_22.antiaim = {
	non_choked = 0,
	edge_yaw = false,
	defensive = false,
	state = var_0_36[1],
	visual_state = var_0_36[1]
}

for iter_0_1 = 1, #var_0_36 do
	local var_0_39 = var_0_36[iter_0_1]

	var_0_22.settings.conditional[var_0_39] = {}

	local var_0_40 = var_0_39 == var_0_36[1] and 2 or 1
	local var_0_41 = var_0_39 ~= var_0_36[2]

	for iter_0_2 = var_0_40, #var_0_38 do
		local var_0_42 = var_0_38[iter_0_2]
		local var_0_43 = var_0_37[var_0_42]

		if not var_0_41 and var_0_42 == "force_defensive" then
			-- block empty
		else
			local var_0_44 = var_0_43.section or "general"
			local var_0_45 = "[" .. var_0_39 .. "] "
			local var_0_46 = var_0_42:gsub("_", " ")
			local var_0_47 = var_0_46:sub(-1)

			if tonumber(var_0_47) then
				var_0_46 = var_0_46:sub(1, -2) .. " (" .. var_0_47 .. ")"
			end

			if var_0_43.type == "combo" then
				var_0_22.settings.conditional[var_0_39][var_0_42] = var_0_22:add_combo("antiaim", "conditional", var_0_44, var_0_45 .. var_0_46, var_0_43.value)
			elseif var_0_43.type == "slider" then
				var_0_22.settings.conditional[var_0_39][var_0_42] = var_0_22:add_slider("antiaim", "conditional", var_0_44, var_0_45 .. var_0_46, var_0_43.min, var_0_43.max, var_0_43.value, var_0_43.suffix or "")
			elseif var_0_43.type == "checkbox" then
				var_0_22.settings.conditional[var_0_39][var_0_42] = var_0_22:add_checkbox("antiaim", "conditional", var_0_44, var_0_45 .. var_0_46, var_0_43.value)
			elseif var_0_43.type == "multicombo" then
				var_0_22.settings.conditional[var_0_39][var_0_42] = var_0_22:add_multicombo("antiaim", "conditional", var_0_44, var_0_45 .. var_0_46, var_0_43.value)
			elseif var_0_43.type == "separator" then
				var_0_22.settings.conditional[var_0_39][var_0_42] = var_0_22:add_separator("antiaim", "conditional", var_0_44)
			elseif var_0_43.type == "text" then
				var_0_22.settings.conditional[var_0_39][var_0_42] = var_0_22:add_text("antiaim", "conditional", var_0_44, var_0_45 .. var_0_46)

				var_0_22.settings.conditional[var_0_39][var_0_42]:set_visible(false)
			end

			if var_0_43.tooltips ~= nil then
				var_0_22.settings.conditional[var_0_39][var_0_42]:set_tooltip(var_0_43.tooltips)
			end

			var_0_22.settings.conditional[var_0_39][var_0_42]:set_visibility_requirement(var_0_22.settings.antiaim.conditional_active_state, iter_0_1)

			for iter_0_3 = 1, var_0_43.vis_conds == nil and 0 or #var_0_43.vis_conds do
				local var_0_48 = var_0_43.vis_conds[iter_0_3]
				local var_0_49 = var_0_48[1]
				local var_0_50 = var_0_48[2]
				local var_0_51 = var_0_22.settings.conditional[var_0_39][var_0_49]

				if var_0_49 ~= nil and var_0_50 ~= nil and var_0_51 ~= nil then
					var_0_22.settings.conditional[var_0_39][var_0_42]:set_visibility_requirement(var_0_51, var_0_50, var_0_48[3])
				end
			end
		end
	end
end

local function var_0_52()
	local var_356_0, var_356_1 = var_0_22.settings.antiaim.conditional_active_state:get()

	for iter_356_0, iter_356_1 in pairs(var_0_22.settings.conditional[var_356_1]) do
		iter_356_1:invoke_visibility_callbacks()
	end
end

var_0_22.settings.antiaim.conditional_active_state:register_callback(var_0_52)
var_0_52()
;(function()
	var_0_22.settings.antiaim.edge_yaw_key = var_0_22.settings.antiaim.edge_yaw:add_keybind("edge_yaw", 0)
	var_0_22.settings.antiaim.manual_left_key = var_0_22.settings.antiaim.manual_left:add_keybind("manual_left_key", 3, e_keys.KEY_LEFT, true)
	var_0_22.settings.antiaim.manual_right_key = var_0_22.settings.antiaim.manual_right:add_keybind("manual_right_key", 3, e_keys.KEY_RIGHT, true)
	var_0_22.settings.visuals.crosshair_state_color = var_0_22.settings.visuals.crosshair_state:add_color_picker("antiaim_state", color_t.new(255, 255, 255, 150))
	var_0_22.settings.visuals.crosshair_brand_color = var_0_22.settings.visuals.crosshair_brand:add_color_picker("brand", var_0_22:get_accent_color())
	var_0_22.settings.visuals.inactive_text_color = var_0_22.settings.visuals.inactive_text_t:add_color_picker("inactive_text", var_0_22.colors.inactive_text)
	var_0_22.settings.visuals.hovering_text_color = var_0_22.settings.visuals.hovering_text_t:add_color_picker("hovering_text", var_0_22.colors.hovering_text)
	var_0_22.settings.visuals.active_text_color = var_0_22.settings.visuals.active_text_t:add_color_picker("active_text", var_0_22.colors.active_text)
	var_0_22.settings.visuals.inactive_outline_color = var_0_22.settings.visuals.inactive_outline_t:add_color_picker("inactive_outline", var_0_22.colors.inactive_outline)
	var_0_22.settings.visuals.hovering_outline_color = var_0_22.settings.visuals.hovering_outline_t:add_color_picker("hovering_outline", var_0_22.colors.hovering_outline)
	var_0_22.settings.visuals.active_outline_color = var_0_22.settings.visuals.active_outline_t:add_color_picker("active_outline", var_0_22.colors.active_outline)
	var_0_22.settings.visuals.dark_background_color = var_0_22.settings.visuals.dark_background_t:add_color_picker("dark_background", var_0_22.colors.dark_background)
	var_0_22.settings.visuals.subtab_background_color = var_0_22.settings.visuals.subtab_background_t:add_color_picker("subtab_background", var_0_22.colors.subtab_background)
	var_0_22.settings.visuals.section_background_color = var_0_22.settings.visuals.section_background_t:add_color_picker("section_background", var_0_22.colors.section_background)
	var_0_22.settings.visuals.footer_background_color = var_0_22.settings.visuals.footer_background_t:add_color_picker("footer_background", var_0_22.colors.footer_background)
end)()
;(function()
	var_0_22.settings.ragebot.deagle_land_accuracy:set_tooltip({
		"Allows you to be extremely accurate for a couple of ticks",
		"after landing with a deagle."
	})
	var_0_22.settings.antiaim.defensive_safety:set_tooltip({
		"Changes between different safety modes for the defensive detection.",
		"The unsafe mode might get hit under bad circumstances,",
		"but its also more likely that enemies miss it compared to the safe mode."
	})
	var_0_22.settings.visuals.grim_reaper:set_tooltip({
		"Throws killed enemies towards you."
	})
	var_0_22.settings.visuals.branding:set_tooltip({
		"Shows Eclipse text on round end banner."
	})
end)()
;(function()
	var_0_22.settings.ragebot.force_safepoint_after_x_misses_value:set_visibility_requirement(var_0_22.settings.ragebot.force_safepoint_after_x_misses, true)
	var_0_22.settings.ragebot.force_safepoint_after_x_misses_reset:set_visibility_requirement(var_0_22.settings.ragebot.force_safepoint_after_x_misses, true)
	var_0_22.settings.antiaim.edge_yaw:set_visibility_requirement(var_0_22.settings.antiaim.master, true)
	var_0_22.settings.antiaim.defensive_safety:set_visibility_requirement(var_0_22.settings.antiaim.master, true)
	var_0_22.settings.antiaim.manual_left:set_visibility_requirement(var_0_22.settings.antiaim.override_left_right, true)
	var_0_22.settings.antiaim.manual_right:set_visibility_requirement(var_0_22.settings.antiaim.override_left_right, true)
	var_0_22.settings.antiaim.conditional_active_state:set_visibility_requirement(var_0_22.settings.antiaim.master, true)
	var_0_22.settings.antiaim.conditional_separator:set_visibility_requirement(var_0_22.settings.antiaim.master, true)
	var_0_22.settings.antiaim.conditional_not_enabled:set_visibility_requirement(var_0_22.settings.antiaim.master, false)

	for iter_359_0 = 1, #var_0_36 do
		local var_359_0 = var_0_36[iter_359_0]

		for iter_359_1, iter_359_2 in pairs(var_0_22.settings.conditional[var_359_0]) do
			iter_359_2:set_visibility_requirement(var_0_22.settings.antiaim.master, true)
		end
	end

	var_0_22.settings.visuals.crosshair_scope_animation:set_visibility_requirement(var_0_22.settings.visuals.crosshair, true)
	var_0_22.settings.visuals.crosshair_binds:set_visibility_requirement(var_0_22.settings.visuals.crosshair, true)
	var_0_22.settings.visuals.crosshair_state:set_visibility_requirement(var_0_22.settings.visuals.crosshair, true)
	var_0_22.settings.visuals.crosshair_brand:set_visibility_requirement(var_0_22.settings.visuals.crosshair, true)
	var_0_22.settings.visuals.hitlogs_offset:set_visibility_requirement(var_0_22.settings.visuals.hitlogs, true)
	var_0_22.settings.visuals.animations:set_visibility_requirement(var_0_22.settings.visuals.client_sided_animations, true)

	local var_359_1 = {
		"text_colors",
		"outline_colors",
		"background_colors",
		"inactive_text_t",
		"hovering_text_t",
		"active_text_t",
		"inactive_outline_t",
		"hovering_outline_t",
		"active_outline_t",
		"dark_background_t",
		"subtab_background_t",
		"section_background_t",
		"footer_background_t",
		"reset_menu_colors"
	}

	for iter_359_3 = 1, #var_359_1 do
		local var_359_2 = var_359_1[iter_359_3]

		var_0_22.settings.visuals[var_359_2]:set_visibility_requirement(var_0_22.settings.visuals.override_menu_colors, true)
	end
end)()

local var_0_53 = {
	rage = false,
	visuals = false,
	config = false,
	antiaim = false
}

for iter_0_4, iter_0_5 in pairs(var_0_53) do
	if not iter_0_5 then
		local var_0_54 = var_0_9[iter_0_4]

		if var_0_54 ~= nil then
			var_0_22:set_page_icon(iter_0_4, var_0_54)
		end
	end
end

callbacks.add(e_callbacks.SETUP_COMMAND, function(arg_360_0)
	local var_360_0 = entity_list.get_local_player()

	if not var_360_0 or not var_360_0:is_valid() or not var_360_0:is_alive() then
		return
	end

	local var_360_1
	local var_360_2 = math.huge
	local var_360_3 = var_0_22.screen_size
	local var_360_4 = entity_list.get_players(true)

	for iter_360_0 = 1, #var_360_4 do
		local var_360_5 = var_360_4[iter_360_0]

		if var_360_5 and var_360_5:is_valid() and var_360_5:is_enemy() and var_360_5:is_alive() then
			local var_360_6 = var_360_5:get_eye_position()
			local var_360_7 = render.world_to_screen(var_360_6)

			if var_360_3 ~= nil and var_360_7 ~= nil and var_360_7.x ~= nil and var_360_7.y ~= nil then
				local var_360_8 = math.sqrt((var_360_3.x / 2 - var_360_7.x)^2 + (var_360_3.y / 2 - var_360_7.y)^2)

				if var_360_8 < var_360_2 then
					var_360_1 = var_360_5
					var_360_2 = var_360_8
				end
			end
		end
	end

	var_0_22.globals.closest_enm = var_360_1
end)

var_0_22.deagle_inaccuracy = {
	was_on_ground = false,
	set_hitchance = function(arg_361_0)
		return
	end
}

callbacks.add(e_callbacks.SETUP_COMMAND, function()
	local var_362_0 = entity_list.get_local_player()

	if not var_362_0 or not var_362_0:is_valid() or not var_362_0:is_alive() then
		return
	end

	var_0_22.deagle_inaccuracy.was_on_ground = var_362_0:has_player_flag(e_player_flags.ON_GROUND)
end)
callbacks.add(e_callbacks.RUN_COMMAND, function(arg_363_0)
	local var_363_0 = entity_list.get_local_player()

	if not var_363_0 or not var_363_0:is_valid() or not var_363_0:is_alive() then
		return
	end

	local var_363_1 = var_363_0:get_active_weapon()

	if not var_363_1 then
		return
	end

	if var_0_22.settings.ragebot.deagle_land_accuracy:get() and not var_0_22.deagle_inaccuracy.was_on_ground and var_363_0:has_player_flag(e_player_flags.ON_GROUND) and var_363_1:get_weapon_data().console_name == "weapon_deagle" then
		function var_0_22.deagle_inaccuracy.set_hitchance(arg_364_0)
			arg_364_0:set_hitchance(0)
		end
	else
		function var_0_22.deagle_inaccuracy.set_hitchance(arg_365_0)
			return
		end
	end
end)
callbacks.add(e_callbacks.HITSCAN, function(arg_366_0)
	var_0_22.deagle_inaccuracy.set_hitchance(arg_366_0)
end)
callbacks.add(e_callbacks.HITSCAN, function(arg_367_0)
	if not var_0_22.settings.ragebot.lethal_revolver_dmg:get() then
		return
	end

	local var_367_0 = entity_list.get_local_player()
	local var_367_1 = var_0_22.globals.closest_enm

	if not var_367_0 or not var_367_0:is_valid() or not var_367_0:is_alive() then
		return
	end

	if var_367_1 == nil then
		return
	end

	if not var_367_1:is_valid() then
		return
	end

	if not var_367_0:get_active_weapon() then
		return
	end

	local var_367_2 = var_367_1:get_eye_position()
	local var_367_3 = var_367_0:get_eye_position()
	local var_367_4 = var_367_3:dist(var_367_2)
	local var_367_5 = var_367_1:get_prop("m_ArmorValue")
	local var_367_6 = var_367_1:get_prop("m_iHealth")
	local var_367_7 = var_367_1:get_hitbox_pos(e_hitboxes.BODY)
	local var_367_8 = trace.bullet(var_367_3, var_367_7, var_367_0, var_367_1)
	local var_367_9 = var_367_6 <= var_367_8.damage

	if var_367_4 < 590 and var_367_5 == 0 or var_367_9 and var_367_8.valid then
		arg_367_0:set_min_dmg(100)
		arg_367_0:set_damage_accuracy(85)
	end
end)

;({}).fl = menu.find("Antiaim", "Fakelag", "Amount")

local var_0_55 = 0

callbacks.add(e_callbacks.AIMBOT_SHOOT, function()
	if exploits.get_charge() ~= 14 then
		return
	end

	var_0_55 = globals.tick_count() + 1
end)
callbacks.add(e_callbacks.ANTIAIM, function(arg_369_0)
	if var_0_22.settings.ragebot.ideal_tick_checkbox:get() and var_0_55 > globals.tick_count() then
		arg_369_0:set_fakelag(false)
		exploits.force_recharge()
		exploits.force_anti_exploit_shift()
	end
end)

var_0_22.force_safepoint_after_x_misses = {
	count = 0,
	last_miss = 0
}

callbacks.add(e_callbacks.AIMBOT_MISS, function(arg_370_0)
	if not var_0_22.settings.ragebot.force_safepoint_after_x_misses:get() then
		return
	end

	var_0_22.force_safepoint_after_x_misses.count = var_0_22.force_safepoint_after_x_misses.count + 1
	var_0_22.force_safepoint_after_x_misses.last_miss = globals.cur_time()
end)
callbacks.add(e_callbacks.HITSCAN, function(arg_371_0)
	if not var_0_22.settings.ragebot.force_safepoint_after_x_misses:get() then
		return
	end

	local var_371_0 = var_0_22.settings.ragebot.force_safepoint_after_x_misses_value:get()
	local var_371_1 = var_0_22.settings.ragebot.force_safepoint_after_x_misses_reset:get()
	local var_371_2 = globals.cur_time() - var_0_22.force_safepoint_after_x_misses.last_miss

	if var_371_0 <= var_0_22.force_safepoint_after_x_misses.count and var_371_2 <= var_371_1 then
		arg_371_0:set_safepoint_state(true)
	end

	if var_371_1 < var_371_2 then
		var_0_22.force_safepoint_after_x_misses.count = 0
	end
end)
callbacks.add(e_callbacks.ANTIAIM, function(arg_372_0, arg_372_1)
	var_0_22.antiaim.edge_yaw = false

	if not var_0_22.settings.antiaim.master:get() or not var_0_22.settings.antiaim.edge_yaw:get() or not var_0_22.settings.antiaim.edge_yaw_key:get() then
		return
	end

	local var_372_0 = entity_list.get_local_player()
	local var_372_1 = var_372_0:get_eye_position()
	local var_372_2 = {}

	for iter_372_0 = 20, 360, 20 do
		local var_372_3 = angle_t.new(0, iter_372_0, 0):to_vector()
		local var_372_4 = var_372_1 + vec3_t.new(var_372_3.x * 30, var_372_3.y * 30, var_372_3.z * 30)
		local var_372_5 = trace.line(var_372_1, var_372_4, var_372_0, 33570827)
		local var_372_6 = var_372_5.fraction
		local var_372_7 = var_372_5.entity

		if var_372_7 and var_372_7:get_class_name() == "CWorld" and var_372_6 < 0.9 then
			var_372_2[#var_372_2 + 1] = {
				vec_trace_end = var_372_4,
				yaw_deg = iter_372_0
			}
		end
	end

	table.sort(var_372_2, function(arg_373_0, arg_373_1)
		return arg_373_0.yaw_deg < arg_373_1.yaw_deg
	end)

	local var_372_8

	if #var_372_2 > 2 then
		local var_372_9 = var_372_2[1]
		local var_372_10 = var_372_2[#var_372_2]
		local var_372_11 = vec3_t.new(0.5, 0.5, 0.5)

		var_372_8 = var_372_9.vec_trace_end + (var_372_10.vec_trace_end - var_372_9.vec_trace_end) * var_372_11
		var_0_22.antiaim.edge_yaw = true
	else
		return
	end

	local var_372_12 = false

	for iter_372_1, iter_372_2 in pairs(entity_list.get_players(true)) do
		if not iter_372_2 or not iter_372_2:is_player() then
			-- block empty
		else
			local var_372_13 = iter_372_2:get_eye_position()
			local var_372_14 = trace.bullet(var_372_0:get_hitbox_pos(e_hitboxes.HEAD), var_372_13, iter_372_2, var_372_0)

			if var_372_14.valid and var_372_14.damage > 20 then
				var_372_12 = true

				break
			end
		end
	end

	if not var_0_22.antiaim.edge_yaw or var_372_12 or var_372_8 == nil then
		return
	end

	local var_372_15 = (var_372_8 - var_372_1):to_angle().y
	local var_372_16 = var_372_15
	local var_372_17 = arg_372_1.viewangles.y
	local var_372_18 = math.abs(var_372_15 - var_372_17)
	local var_372_19 = var_372_15 + var_372_18

	if var_372_18 > 90 then
		var_372_19 = var_372_15
	else
		local var_372_20 = angle_t.new(0, math.rad(var_372_17), 0):to_vector()
		local var_372_21 = angle_t.new(0, math.rad(var_372_17 + 90), 0):to_vector()
		local var_372_22 = vec3_t.new(var_372_21.x * 10, var_372_21.y * 10, var_372_21.z * 10)
		local var_372_23 = var_372_0:get_render_origin() + vec3_t.new(0, 0, 20) + var_372_22
		local var_372_24 = var_372_23 + vec3_t.new(var_372_20.x * 40, var_372_20.y * 40, var_372_20.z * 40)
		local var_372_25 = angle_t.new(0, math.rad(var_372_17 - 90), 0):to_vector()
		local var_372_26 = var_372_0:get_render_origin() + vec3_t(0, 0, 20) + vec3_t(var_372_25.x * 10, var_372_25.y * 10, var_372_25.z * 10)
		local var_372_27 = var_372_26 + vec3_t(var_372_20.x * 40, var_372_20.y * 40, var_372_20.z * 40)
		local var_372_28 = trace.line(var_372_23, var_372_24, var_372_0, 33570827).fraction
		local var_372_29 = trace.line(var_372_26, var_372_27, var_372_0, 33570827).fraction

		if var_372_28 < 0.9 and var_372_29 >= 0.95 then
			var_372_19 = var_372_19 + 35
		elseif var_372_29 < 0.9 and var_372_28 >= 0.95 then
			var_372_19 = var_372_19 - 35
		end
	end

	arg_372_0:set_yaw(var_372_19)
end)
var_0_22.settings.antiaim.manual_left_key:register_callback(function()
	if var_0_22.settings.antiaim.manual_left_key:get() then
		var_0_22.settings.antiaim.manual_right_key.state = false
	end
end)
var_0_22.settings.antiaim.manual_right_key:register_callback(function()
	if var_0_22.settings.antiaim.manual_right_key:get() then
		var_0_22.settings.antiaim.manual_left_key.state = false
	end
end)
callbacks.add(e_callbacks.ANTIAIM, function(arg_376_0, arg_376_1)
	if not var_0_22.settings.antiaim.override_left_right:get() then
		return
	end

	local var_376_0 = var_0_22.settings.antiaim.manual_left:get()
	local var_376_1 = var_0_22.settings.antiaim.manual_right:get()

	if var_0_22.settings.antiaim.manual_left_key:get() then
		arg_376_0:set_yaw(arg_376_1.viewangles.y + 180 - var_376_0)
	elseif var_0_22.settings.antiaim.manual_right_key:get() then
		arg_376_0:set_yaw(arg_376_1.viewangles.y + 180 + var_376_1)
	end
end)
callbacks.add(e_callbacks.SETUP_COMMAND, function(arg_377_0)
	local var_377_0 = entity_list.get_local_player()

	if not var_377_0 or not var_377_0:is_valid() or not var_377_0:is_alive() then
		return
	end

	local var_377_1 = var_377_0:get_prop("m_fFlags")
	local var_377_2 = var_377_0:get_prop("m_vecVelocity"):length2d()
	local var_377_3 = var_0_22.antiaim.defensive
	local var_377_4 = var_377_2 > 10
	local var_377_5 = var_0_21.slowwalk[2]:get()
	local var_377_6 = bit.band(var_377_1, 1) == 0 or arg_377_0:has_button(e_cmd_buttons.JUMP)
	local var_377_7 = bit.band(var_377_1, 2) ~= 0

	if var_377_3 then
		var_0_22.antiaim.state = var_0_36[2]
	elseif var_377_6 and var_377_7 then
		var_0_22.antiaim.state = var_0_36[5]
	elseif var_377_6 then
		var_0_22.antiaim.state = var_0_36[4]
	elseif var_377_7 then
		var_0_22.antiaim.state = var_0_36[6]
	elseif var_377_5 then
		var_0_22.antiaim.state = var_0_36[7]
	elseif var_377_4 then
		var_0_22.antiaim.state = var_0_36[3]
	else
		var_0_22.antiaim.state = var_0_36[1]
	end

	if var_377_6 and var_377_7 then
		var_0_22.antiaim.visual_state = var_0_36[5]
	elseif var_377_6 then
		var_0_22.antiaim.visual_state = var_0_36[4]
	elseif var_377_7 then
		var_0_22.antiaim.visual_state = var_0_36[6]
	elseif var_377_5 then
		var_0_22.antiaim.visual_state = var_0_36[7]
	elseif var_377_4 then
		var_0_22.antiaim.visual_state = var_0_36[3]
	else
		var_0_22.antiaim.visual_state = var_0_36[1]
	end
end)

var_0_22.defensive_detection = {
	shifted_amount = 0,
	active_until = 0,
	simtime_diff = 0,
	stored_simtime = 0,
	active_until_indicator = 0
}

callbacks.add(e_callbacks.NET_UPDATE, function()
	local var_378_0 = entity_list.get_local_player()

	if not var_378_0 then
		var_0_22.defensive_detection.simtime_diff = 0

		return
	end

	local var_378_1 = var_378_0:get_prop("m_flSimulationTime")
	local var_378_2 = var_378_1 - var_0_22.defensive_detection.stored_simtime

	if not engine.is_in_game() then
		var_378_2 = 0
	end

	if var_378_2 < 0 then
		local var_378_3 = client.time_to_ticks(engine.get_latency(e_latency_flows.OUTGOING))
		local var_378_4 = client.time_to_ticks(math.abs(var_378_2))
		local var_378_5 = var_378_4 - var_378_3
		local var_378_6, var_378_7 = var_0_22.settings.antiaim.defensive_safety:get()

		var_0_22.defensive_detection.simtime_diff = var_378_2
		var_0_22.defensive_detection.active_until = globals.tick_count() + var_378_5 - var_378_6
		var_0_22.defensive_detection.active_until_indicator = globals.tick_count() + var_378_4
		var_0_22.antiaim.defensive = true
	end

	if var_0_22.defensive_detection.active_until > globals.tick_count() then
		var_0_22.antiaim.defensive = true
		var_0_22.defensive_detection.shifted_amount = client.time_to_ticks(math.abs(var_378_2))
	else
		var_0_22.antiaim.defensive = false
		var_0_22.defensive_detection.shifted_amount = 0
	end

	var_0_22.defensive_detection.stored_simtime = var_378_1
	var_0_22.defensive_detection.simtime_diff = var_378_2
end)
callbacks.add(e_callbacks.ANTIAIM, function(arg_379_0, arg_379_1)
	if var_0_22.antiaim.edge_yaw then
		return
	end

	if not var_0_22.settings.antiaim.master:get() then
		return
	end

	local var_379_0 = var_0_22.antiaim.visual_state
	local var_379_1 = var_0_22.settings.conditional[var_379_0]

	if not (var_379_1.override and var_379_1.override:get()) then
		var_379_1 = var_0_22.settings.conditional[var_0_36[1]]
	end

	local var_379_2 = var_379_1.force_defensive and var_379_1.force_defensive:get()

	if var_379_2 and var_0_22.antiaim.defensive and var_0_22.settings.conditional.Defensive.override:get() then
		var_379_1 = var_0_22.settings.conditional[var_0_36[2]]

		exploits.force_anti_exploit_shift()
	elseif var_379_2 then
		exploits.force_anti_exploit_shift()
	end

	local var_379_3 = var_379_1.settings:get(1)
	local var_379_4 = var_379_1.settings:get(2)
	local var_379_5 = var_379_1.settings:get(3)
	local var_379_6 = var_379_1.settings:get(4)
	local var_379_7 = var_379_1.settings:get(5)

	if var_379_3 then
		local var_379_8 = var_379_1.pitch:get()

		if var_379_8 == 6 then
			arg_379_0:set_pitch(var_379_1.custom_pitch:get())
		else
			var_0_21.aa.pitch:set(var_379_8)
		end
	else
		var_0_21.aa.pitch:set(2)
	end

	if var_379_4 then
		local var_379_9 = var_379_1.yaw_base:get()

		var_0_21.aa.yaw_base:set(var_379_9)
	else
		var_0_21.aa.yaw_base:set(3)
	end

	if var_379_5 then
		local var_379_10 = var_379_1.yaw_add:get()

		var_0_21.aa.yaw_add:set(var_379_10)
	else
		var_0_21.aa.yaw_add:set(0)
	end

	var_0_21.aa.rotate:set(var_379_6)

	if var_379_6 then
		local var_379_11 = var_379_1.rotate_range:get()
		local var_379_12 = var_379_1.rotate_speed:get()

		var_0_21.aa.rotate_range:set(var_379_11)
		var_0_21.aa.rotate_speed:set(var_379_12)
	else
		var_0_21.aa.rotate_range:set(0)
		var_0_21.aa.rotate_speed:set(0)
	end

	if var_379_7 then
		local var_379_13 = var_379_1.body_lean:get()
		local var_379_14 = var_379_1.body_lean_amount:get()
		local var_379_15 = var_379_1.body_lean_moving:get()

		var_0_21.aa.body_lean:set(var_379_13)
		var_0_21.aa.body_lean_value:set(var_379_14)
		var_0_21.aa.body_lean_moving:set(var_379_15)
	else
		var_0_21.aa.body_lean:set(1)
		var_0_21.aa.body_lean_value:set(0)
		var_0_21.aa.body_lean_moving:set(false)
	end

	local var_379_16 = var_379_1.jitter_mode:get()
	local var_379_17 = var_379_1.jitter_type:get()
	local var_379_18 = var_379_1.jitter_add:get()

	var_0_21.aa.jitter_mode:set(var_379_16)
	var_0_21.aa.jitter_add:set(var_379_18)

	if var_379_17 ~= 5 then
		var_0_21.aa.jitter_type:set(var_379_17)
	else
		if var_379_16 == 1 then
			return
		end

		var_0_21.aa.jitter_mode:set(1)

		local var_379_19 = var_379_1.x_way_ways:get()

		if engine.get_choked_commands() == 0 then
			var_0_22.antiaim.non_choked = var_0_22.antiaim.non_choked + 1
		end

		if var_379_19 <= var_0_22.antiaim.non_choked then
			var_0_22.antiaim.non_choked = 0
		end

		local var_379_20 = var_0_22.antiaim.non_choked + 1
		local var_379_21 = var_379_1["x_way_configurer_" .. var_379_20]:get() + var_379_18

		if var_379_21 > 180 then
			var_379_21 = var_379_21 - 360
		elseif var_379_21 < -180 then
			var_379_21 = var_379_21 + 360
		end

		var_0_21.aa.yaw_add:set(var_379_21)
	end

	var_0_21.aa.desync_override_stand_move:set(false)
	var_0_21.aa.desync_override_stand_slowwalk:set(false)

	local var_379_22 = var_379_1.desync_side:get()
	local var_379_23 = var_379_1.left_range:get()
	local var_379_24 = var_379_1.right_range:get()
	local var_379_25 = var_379_1.on_shot:get()

	var_0_21.aa.desync_side:set(var_379_22)
	var_0_21.aa.desync_left:set(var_379_23)
	var_0_21.aa.desync_right:set(var_379_24)
	var_0_21.aa.onshot:set(var_379_25)
end)

var_0_22.crosshair_indicators = {
	last_anim = 0,
	offset = vec2_t.new(0, 20),
	keybinds = {},
	anims = {
		dt = 0,
		scope = 0
	},
	time = {
		bind = 0.1,
		dt = 0.15,
		scope = 0.5
	},
	cache = {
		dt = false,
		scope = false
	},
	bind_to_small = {
		["Hide Shots"] = "HS",
		["Quick peek assist"] = "QP",
		["Double Tap"] = "DT",
		["Fake Duck"] = "FD",
		["Roll Resolver"] = "ROLL",
		["Ping spike"] = "PS",
		Freestand = "FS"
	}
}

function var_0_22.crosshair_indicators.reset_keybinds(arg_380_0)
	local var_380_0 = var_0_22.settings.visuals.crosshair_binds:get_items()

	for iter_380_0 = 1, #var_380_0 do
		local var_380_1 = var_380_0[iter_380_0]

		arg_380_0.keybinds[var_380_1] = {
			anim_time = 0,
			cache = false,
			state = false
		}
	end

	arg_380_0.keybinds.Freestand.ref = var_0_12("antiaim", "main", "auto direction", "enable")[2]
	arg_380_0.keybinds["Ping spike"].ref = var_0_12("aimbot", "general", "fake ping", "enable")[2]
	arg_380_0.keybinds["Quick peek assist"].ref = var_0_12("aimbot", "general", "misc", "autopeek")[2]
	arg_380_0.keybinds["Roll Resolver"].ref = var_0_12("aimbot", "general", "aimbot", "body lean resolver")[2]
	arg_380_0.keybinds["Hide Shots"].ref = var_0_12("aimbot", "general", "exploits", "hideshots", "enable")[2]
	arg_380_0.keybinds["Double Tap"].ref = var_0_12("aimbot", "general", "exploits", "doubletap", "enable")[2]
	arg_380_0.keybinds["Fake Duck"].ref = var_0_12("antiaim", "general", "general", "fakeduck")[2]
end

var_0_22.crosshair_indicators:reset_keybinds()
callbacks.add(e_callbacks.PAINT, function()
	if not var_0_22.settings.visuals.crosshair:get() then
		return
	end

	local var_381_0 = var_0_22.crosshair_indicators
	local var_381_1 = entity_list.get_local_player()

	if not engine.is_connected() or not var_381_1 or not var_381_1:is_valid() or not var_381_1:is_alive() then
		var_0_22.crosshair_indicators:reset_keybinds()

		return
	end

	local var_381_2 = render.get_screen_size()
	local var_381_3 = globals.cur_time()
	local var_381_4 = var_0_22.settings.visuals.crosshair_binds
	local var_381_5 = vec2_t.new(var_381_2.x / 2, var_381_2.y / 2) + var_0_22.crosshair_indicators.offset
	local var_381_6 = "eclipse"
	local var_381_7 = (" [%s]"):format(var_0_22.globals.version)
	local var_381_8 = render.get_text_size(var_0_22.fonts.default, var_381_6)
	local var_381_9 = render.get_text_size(var_0_22.fonts.default, var_381_7)
	local var_381_10 = var_381_8 + vec2_t.new(var_381_9.x, 0)
	local var_381_11 = vec2_t.new(var_381_5.x - var_381_10.x / 2, var_381_5.y)
	local var_381_12 = var_0_22.antiaim.visual_state:lower():gsub(" / global", "")
	local var_381_13 = render.get_text_size(var_0_22.fonts.default, var_381_12)
	local var_381_14 = vec2_t.new(var_381_5.x - var_381_13.x / 2, var_381_5.y + 13)
	local var_381_15 = render.get_text_size(var_0_22.fonts.crosshair, "doubletap")
	local var_381_16 = render.get_text_size(var_0_22.fonts.crosshair, "hideshots")
	local var_381_17 = vec2_t.new(var_381_5.x - var_381_15.x / 2 + 1, var_381_5.y + 13)
	local var_381_18 = vec2_t.new(var_381_5.x - var_381_16.x / 2, var_381_5.y + 26)
	local var_381_19 = var_381_1:get_prop("m_bIsScoped") == 1
	local var_381_20 = var_0_22.settings.visuals.crosshair_scope_animation:get()

	if var_381_0.cache.scope ~= var_381_19 then
		var_381_0.cache.scope = var_381_19
		var_381_0.anims.scope = var_381_3
	end

	local var_381_21 = (var_381_3 - var_381_0.anims.scope) / var_381_0.time.scope
	local var_381_22 = var_0_16(var_381_21, 0, 1)

	if var_381_19 and var_381_20 then
		local var_381_23 = var_381_2.x / 2 + 10

		var_381_11.x = var_381_11.x + var_0_15(var_381_22) * (var_381_23 - var_381_11.x)
		var_381_14.x = var_381_14.x + var_0_15(var_381_22) * (var_381_23 - var_381_14.x)
		var_381_17.x = var_381_17.x + var_0_15(var_381_22) * (var_381_23 - var_381_17.x)
		var_381_18.x = var_381_18.x + var_0_15(var_381_22) * (var_381_23 - var_381_18.x)
	elseif var_381_20 then
		local var_381_24 = var_381_2.x / 2 + 10

		var_381_11.x = var_381_11.x + (1 - var_0_15(var_381_22)) * (var_381_24 - var_381_11.x)
		var_381_14.x = var_381_14.x + (1 - var_0_15(var_381_22)) * (var_381_24 - var_381_14.x)
		var_381_17.x = var_381_17.x + (1 - var_0_15(var_381_22)) * (var_381_24 - var_381_17.x)
		var_381_18.x = var_381_18.x + (1 - var_0_15(var_381_22)) * (var_381_24 - var_381_18.x)
	end

	local var_381_25 = var_0_22.settings.visuals.crosshair_brand_color:get()
	local var_381_26 = math.abs(math.floor(math.sin(var_381_3) * 255))
	local var_381_27 = var_381_4:get_items()

	for iter_381_0 = 1, #var_381_27 do
		local var_381_28 = var_381_27[iter_381_0]

		var_381_0.keybinds[var_381_28].state = var_381_0.keybinds[var_381_28].ref:get() and var_381_4:get(var_381_28)

		if var_381_0.keybinds[var_381_28].cache ~= var_381_0.keybinds[var_381_28].state then
			var_381_0.keybinds[var_381_28].cache = var_381_0.keybinds[var_381_28].state
			var_381_0.keybinds[var_381_28].anim_time = var_381_3
		end
	end

	var_381_0.keybinds["Fake Duck"].state = antiaim.is_fakeducking() and var_381_4:get("Fake Duck")

	local var_381_29 = var_0_22.settings.visuals.crosshair_state_color:get()

	render.text(var_0_22.fonts.default, var_381_12, var_381_14, var_381_29)

	local var_381_30 = var_0_20(ragebot.get_active_cfg())

	if var_381_30.min_dmg_override ~= nil and var_381_30.min_dmg_override:get() then
		render.text(var_0_22.fonts.crosshair_mindmg, tostring(var_381_30.min_dmg_value:get()), var_381_5 - var_381_0.offset + vec2_t.new(5, -5 - var_0_22.fonts.crosshair_mindmg.height), color_t.new(255, 255, 255, 255))
	end

	render.text(var_0_22.fonts.default, var_381_6, var_381_11, color_t.new(255, 255, 255, 255))
	render.text(var_0_22.fonts.default, var_381_7, var_381_11 + vec2_t.new(var_381_8.x, 0), color_t.new(var_381_25.r, var_381_25.g, var_381_25.b, math.floor(var_381_26)))

	local var_381_31 = exploits.get_charge()
	local var_381_32 = var_0_18(var_381_31, 14)
	local var_381_33 = var_381_31 / 14
	local var_381_34 = var_0_16(var_381_33, 0.1, 1)
	local var_381_35 = var_381_31 > 0 and (var_381_0.keybinds["Double Tap"].state and "doubletap" or var_381_0.keybinds["Hide Shots"].state and "hideshots") or nil
	local var_381_36 = var_381_18
	local var_381_37 = var_381_0.keybinds["Double Tap"].state and var_381_15 or var_381_0.keybinds["Hide Shots"].state and var_381_16 or nil
	local var_381_38 = vec2_t.new(var_381_5.x, var_381_17.y + 3)

	if var_381_35 ~= nil and var_381_37 ~= nil then
		var_381_38.y = var_381_38.y + var_381_37.y

		local var_381_39 = var_381_36.x + var_381_37.x / 2 * (1 - var_381_34)
		local var_381_40 = var_381_37.x * var_381_34

		render.push_clip(vec2_t.new(var_381_39, var_381_36.y), vec2_t.new(var_381_40, var_381_37.y))

		if var_381_0.cache.dt ~= var_381_0.keybinds["Double Tap"].state then
			var_381_0.cache.dt = var_381_0.keybinds["Double Tap"].state
			var_381_0.anims.dt = var_381_3
		end

		local var_381_41 = (var_381_3 - var_381_0.anims.dt) / var_381_0.time.dt
		local var_381_42 = var_0_16(var_381_41, 0, 1)
		local var_381_43 = var_381_0.keybinds["Double Tap"].state and var_381_42 or 1 - var_381_42
		local var_381_44 = var_0_15(var_381_43)

		render.text(var_0_22.fonts.crosshair, var_381_35, var_381_17 + vec2_t.new(0, 13 * var_381_44), color_t.new(var_381_32.r, var_381_32.g, var_381_32.b, 255))
		render.text(var_0_22.fonts.crosshair, var_381_35, var_381_18 + vec2_t.new(0, 13 * var_381_44), color_t.new(var_381_32.r, var_381_32.g, var_381_32.b, 255))
		render.pop_clip()
	end

	for iter_381_1 = 1, #var_381_27 do
		local var_381_45 = var_381_27[iter_381_1]

		if var_381_45 == "Double Tap" or var_381_45 == "Hide Shots" and not var_381_0.keybinds["Double Tap"].state then
			-- block empty
		else
			local var_381_46 = var_381_0.keybinds[var_381_45]

			var_381_45 = var_381_0.bind_to_small[var_381_45] or var_381_45

			local var_381_47 = var_381_45:lower()
			local var_381_48 = var_381_46.state
			local var_381_49 = (var_381_3 - var_381_46.anim_time) / var_381_0.time.bind
			local var_381_50 = var_0_16(var_381_49, 0, 1)
			local var_381_51 = var_381_48 and var_381_50 or 1 - var_381_50

			if var_381_46.state or var_381_51 > 0 then
				local var_381_52 = var_0_15(var_381_51)
				local var_381_53 = render.get_text_size(var_0_22.fonts.crosshair, var_381_47)
				local var_381_54 = vec2_t.new(var_381_38.x - var_381_53.x / 2, var_381_38.y + var_0_22.fonts.crosshair.height * var_381_52)

				if var_381_19 and var_381_20 then
					local var_381_55 = var_381_2.x / 2 + 10

					var_381_54.x = var_381_54.x + var_0_15(var_381_22) * (var_381_55 - var_381_54.x)
				elseif var_381_20 then
					local var_381_56 = var_381_2.x / 2 + 10

					var_381_54.x = var_381_54.x + (1 - var_0_15(var_381_22)) * (var_381_56 - var_381_54.x)
				end

				render.text(var_0_22.fonts.crosshair, var_381_47, var_381_54, color_t.new(255, 255, 255, math.floor(var_381_52 * 150)))

				var_381_38.y = var_381_38.y + var_0_22.fonts.crosshair.height
			end
		end
	end
end)
callbacks.add(e_callbacks.PAINT, function()
	if not engine.is_in_game() then
		return
	end

	local var_382_0 = globals.tick_count()
	local var_382_1 = var_0_22.defensive_detection.active_until_indicator

	if var_382_0 <= var_382_1 then
		local var_382_2 = render.get_screen_size()
		local var_382_3 = vec2_t.new(var_382_2.x / 2, var_382_2.y / 3)
		local var_382_4 = render.get_text_size(var_0_22.fonts.defensive, "DEFENSIVE")
		local var_382_5 = var_0_16(150 + (var_382_1 - var_382_0) * 7, 0, 255)
		local var_382_6 = (var_382_1 - var_382_0) * 5 - 1

		if var_382_6 / 2 > var_382_4.x then
			var_0_22.defensive_detection.active_until_indicator = 0

			local var_382_7 = 0
		end

		local var_382_8 = var_0_16(var_382_6, 0, var_382_4.x)

		render.text(var_0_22.fonts.defensive, "DEFENSIVE", var_382_3, color_t.new(190, 190, 190, var_382_5), true)
		render.rect_filled(vec2_t.new(var_382_3.x - var_382_4.x / 2, var_382_3.y + 6), vec2_t.new(var_382_4.x, 6), color_t.new(30, 30, 30, var_382_5))
		render.rect_filled(vec2_t.new(var_382_3.x - var_382_4.x / 2, var_382_3.y + 7), vec2_t.new(var_382_8, 4), color_t.new(190, 190, 190, var_382_5))
	end
end)

var_0_22.hit_logs = {
	height = 20,
	timings = {
		open = 0.2,
		see = 3,
		close = 0.2
	},
	render_logo = function(arg_383_0, arg_383_1, arg_383_2)
		local var_383_0 = (arg_383_1 - arg_383_2 * 2) / 2

		arg_383_0 = arg_383_0 - vec2_t.new(var_383_0 - arg_383_2 * 1.2, var_383_0 - arg_383_2 * 1)

		render.circle_filled(arg_383_0 + vec2_t.new(1.1 * var_383_0 + var_383_0, 1.14 * var_383_0 + var_383_0), var_383_0, color_t.new(255, 255, 255, 255))

		local var_383_1 = var_0_22:get_accent_color()

		var_383_1.a = 200

		render.circle_filled(arg_383_0 + vec2_t.new(0.84 * var_383_0 + 0.64 * var_383_0, 0.88 * var_383_0 + 0.64 * var_383_0), math.floor(var_383_0 * 0.7), var_383_1)
	end,
	texts = {},
	hg_to_name = {
		[e_hitgroups.GENERIC] = "GENERIC",
		[e_hitgroups.HEAD] = "HEAD",
		[e_hitgroups.CHEST] = "CHEST",
		[e_hitgroups.STOMACH] = "STOMACH",
		[e_hitgroups.LEFT_ARM] = "LEFT ARM",
		[e_hitgroups.RIGHT_ARM] = "RIGHT ARM",
		[e_hitgroups.LEFT_LEG] = "LEFT LEG",
		[e_hitgroups.RIGHT_LEG] = "RIGHT LEG",
		[e_hitgroups.NECK] = "NECK",
		[e_hitgroups.GEAR] = "GEAR"
	}
}

callbacks.add(e_callbacks.AIMBOT_HIT, function(arg_384_0)
	local var_384_0 = arg_384_0.player:get_name()
	local var_384_1 = arg_384_0.damage
	local var_384_2 = arg_384_0.aim_damage
	local var_384_3 = arg_384_0.hitgroup
	local var_384_4 = arg_384_0.aim_hitgroup
	local var_384_5 = var_384_1 == var_384_2
	local var_384_6 = var_384_3 == var_384_4
	local var_384_7 = var_0_22.hit_logs
	local var_384_8 = var_384_7.hg_to_name[var_384_3]:lower() or "unknown"
	local var_384_9 = var_384_7.hg_to_name[var_384_4]:lower() or "unknown"
	local var_384_10 = {}
	local var_384_11 = {}

	table.insert(var_384_10, {
		text = "hit ",
		color = color_t.new(255, 255, 255, 255)
	})
	table.insert(var_384_11, "hit")
	table.insert(var_384_10, {
		text = var_384_0,
		color = var_0_22:get_accent_color()
	})
	table.insert(var_384_11, var_384_0)
	table.insert(var_384_10, {
		text = " for ",
		color = color_t.new(255, 255, 255, 255)
	})
	table.insert(var_384_11, " for ")
	table.insert(var_384_10, {
		text = tostring(var_384_1),
		color = var_384_5 and var_0_22:get_accent_color() or color_t.new(255, 0, 0, 255)
	})
	table.insert(var_384_11, tostring(var_384_1))

	if not var_384_5 then
		table.insert(var_384_10, {
			text = " [",
			color = color_t.new(255, 255, 255, 255)
		})
		table.insert(var_384_11, " [")
		table.insert(var_384_10, {
			text = tostring(var_384_2),
			color = color_t.new(255, 0, 0, 255)
		})
		table.insert(var_384_11, tostring(var_384_2))
		table.insert(var_384_10, {
			text = "]",
			color = color_t.new(255, 255, 255, 255)
		})
		table.insert(var_384_11, "]")
	end

	table.insert(var_384_10, {
		text = " in ",
		color = color_t.new(255, 255, 255, 255)
	})
	table.insert(var_384_11, " in ")
	table.insert(var_384_10, {
		text = var_384_8,
		color = var_384_6 and var_0_22:get_accent_color() or color_t.new(255, 0, 0, 255)
	})
	table.insert(var_384_11, var_384_8)

	if not var_384_6 then
		table.insert(var_384_10, {
			text = " [",
			color = color_t.new(255, 255, 255, 255)
		})
		table.insert(var_384_11, " [")
		table.insert(var_384_10, {
			text = var_384_9,
			color = color_t.new(255, 0, 0, 255)
		})
		table.insert(var_384_11, var_384_9)
		table.insert(var_384_10, {
			text = "]",
			color = color_t.new(255, 255, 255, 255)
		})
		table.insert(var_384_11, "]")
	end

	local var_384_12 = table.concat(var_384_11, "")

	table.insert(var_384_7.texts, 1, {
		full_text = var_384_12,
		text_size = render.get_text_size(var_0_22.fonts.default, var_384_12),
		texts = var_384_10,
		sent_at = globals.cur_time()
	})
end)
callbacks.add(e_callbacks.AIMBOT_MISS, function(arg_385_0)
	local var_385_0 = arg_385_0.reason_string
	local var_385_1 = arg_385_0.player == nil and "unknown" or :get_name()
	local var_385_2 = arg_385_0.aim_damage
	local var_385_3 = arg_385_0.aim_hitgroup
	local var_385_4 = var_0_22.hit_logs
	local var_385_5 = var_385_4.hg_to_name[var_385_3]:lower() or "unknown"
	local var_385_6 = {}
	local var_385_7 = {}

	table.insert(var_385_6, {
		text = "missed (",
		color = color_t.new(255, 255, 255, 255)
	})
	table.insert(var_385_7, "missed (")
	table.insert(var_385_6, {
		text = var_385_0,
		color = color_t.new(255, 0, 0, 255)
	})
	table.insert(var_385_7, var_385_0)
	table.insert(var_385_6, {
		text = ") ",
		color = color_t.new(255, 255, 255, 255)
	})
	table.insert(var_385_7, ") ")
	table.insert(var_385_6, {
		text = var_385_1,
		color = var_0_22:get_accent_color()
	})
	table.insert(var_385_7, var_385_1)
	table.insert(var_385_6, {
		text = " for ",
		color = color_t.new(255, 255, 255, 255)
	})
	table.insert(var_385_7, " for ")
	table.insert(var_385_6, {
		text = tostring(var_385_2),
		color = color_t.new(255, 0, 0, 255)
	})
	table.insert(var_385_7, tostring(var_385_2))
	table.insert(var_385_6, {
		text = " in ",
		color = color_t.new(255, 255, 255, 255)
	})
	table.insert(var_385_7, " in ")
	table.insert(var_385_6, {
		text = var_385_5,
		color = color_t.new(255, 0, 0, 255)
	})
	table.insert(var_385_7, var_385_5)

	local var_385_8 = table.concat(var_385_7, "")

	table.insert(var_385_4.texts, 1, {
		full_text = var_385_8,
		text_size = render.get_text_size(var_0_22.fonts.default, var_385_8),
		texts = var_385_6,
		sent_at = globals.cur_time()
	})
end)
callbacks.add(e_callbacks.PAINT, function()
	if not var_0_22.settings.visuals.hitlogs:get() then
		return
	end

	local var_386_0 = 0
	local var_386_1 = 0
	local var_386_2 = var_0_22.hit_logs
	local var_386_3 = var_386_2.texts
	local var_386_4 = var_0_22.settings.visuals.hitlogs_offset:get()
	local var_386_5 = vec2_t.new(render.get_screen_size().x / 2, render.get_screen_size().y / 2 + var_386_4)

	for iter_386_0 = 1, #var_386_3 do
		local var_386_6 = var_386_3[iter_386_0]
		local var_386_7 = var_386_6.text_size + vec2_t.new(10, 0)
		local var_386_8 = globals.cur_time() - var_386_6.sent_at
		local var_386_9 = var_386_2.height + 4 + 5 + var_386_7.x + 4 + 2
		local var_386_10 = var_386_5 + vec2_t.new(-var_386_9 / 2, (var_386_2.height + 10) * (iter_386_0 - 1))
		local var_386_11 = vec2_t.new(var_386_10.x - 2, var_386_10.y - 2)
		local var_386_12 = vec2_t.new(var_386_2.height + 4, var_386_2.height + 4)
		local var_386_13 = var_386_9
		local var_386_14 = vec2_t.new(var_386_11.x - 2, var_386_11.y)

		if var_386_8 < var_386_2.timings.open then
			local var_386_15 = var_386_8 / var_386_2.timings.open

			render.push_alpha_modifier(var_386_15)

			var_386_14.x = var_386_14.x + var_386_13 / 2 * (1 - var_386_15)
			var_386_13 = var_386_13 * var_386_15
			var_386_1 = var_386_1 + (1 - var_386_15)
		elseif var_386_8 > var_386_2.timings.open + var_386_2.timings.see then
			local var_386_16 = 1 - (var_386_8 - var_386_2.timings.open - var_386_2.timings.see) / var_386_2.timings.close

			var_386_16 = var_386_16 < 0 and 0 or var_386_16 > 1 and 1 or var_386_16

			render.push_alpha_modifier(var_386_16)

			var_386_0 = var_386_0 + 1 * (1 - var_386_16)
		end

		if iter_386_0 ~= 1 then
			var_386_14.y = var_386_14.y - var_386_0 * (var_386_2.height + 10)
			var_386_11.y = var_386_14.y
			var_386_10.y = var_386_10.y - var_386_0 * (var_386_2.height + 10)
			var_386_14.y = var_386_14.y - var_386_1 * (var_386_2.height + 10)
			var_386_11.y = var_386_14.y
			var_386_10.y = var_386_10.y - var_386_1 * (var_386_2.height + 10)
		end

		render.push_clip(var_386_14, vec2_t.new(var_386_13, var_386_12.y))
		render.rect_filled(var_386_11 - vec2_t.new(2, 0), var_386_12 + vec2_t.new(2, 0), var_0_22:get_accent_color(), 5)
		render.rect_filled(var_386_11, var_386_12, color_t.new(0, 0, 0, 200), 5)
		var_386_2.render_logo(var_386_10, var_386_2.height, 3)

		var_386_10.x = var_386_10.x + var_386_2.height + 5
		var_386_10.y = var_386_10.y - 2

		render.rect_filled(var_386_10, vec2_t.new(var_386_7.x + 4 + 2, var_386_2.height + 4), var_0_22:get_accent_color(), 5)
		render.rect_filled(var_386_10, vec2_t.new(var_386_7.x + 4, var_386_2.height + 4), color_t.new(0, 0, 0, 200), 5)

		local var_386_17 = var_386_10 + vec2_t.new(7, var_386_2.height / 2 - var_0_22.fonts.default.height / 2 + 1)

		for iter_386_1 = 1, #var_386_6.texts do
			local var_386_18 = var_386_6.texts[iter_386_1]

			render.text(var_0_22.fonts.default, tostring(var_386_18.text), var_386_17, var_386_18.color)

			var_386_17.x = var_386_17.x + render.get_text_size(var_0_22.fonts.default, tostring(var_386_18.text)).x
		end

		render.pop_clip()
		render.pop_alpha_modifier()
	end

	for iter_386_2 = #var_386_3, 1, -1 do
		local var_386_19 = var_386_3[iter_386_2]

		if globals.cur_time() - var_386_19.sent_at > var_386_2.timings.open + var_386_2.timings.see + var_386_2.timings.close then
			table.remove(var_386_3, iter_386_2)
		end
	end
end)

var_0_22.watermark = {}
var_0_22.watermark.draggable = var_0_35({
	pos = vec2_t.new(100, 100),
	size = vec2_t.new(100, 100),
	interaction_menu = var_0_34({
		title = "watermark"
	})
})
var_0_22.watermark.menu_elems = {}
var_0_22.watermark.menu_elems.enable_name = var_0_22.watermark.draggable.interaction_menu:add_checkbox("name", false)
var_0_22.watermark.menu_elems.enable_uid = var_0_22.watermark.draggable.interaction_menu:add_checkbox("uid", false)
var_0_22.watermark.menu_elems.enable_time = var_0_22.watermark.draggable.interaction_menu:add_checkbox("time", false)
var_0_22.watermark.menu_elems.enable_timeout = var_0_22.watermark.draggable.interaction_menu:add_checkbox("timeout", false)
var_0_22.watermark.menu_elems.enable_beta_animation = var_0_22.watermark.draggable.interaction_menu:add_checkbox("debug animation", false)

function var_0_22.watermark.render_circle(arg_387_0, arg_387_1, arg_387_2, arg_387_3, arg_387_4, arg_387_5)
	local var_387_0 = {}

	if arg_387_3 < arg_387_2 then
		arg_387_3, arg_387_2 = arg_387_2, arg_387_3
	end

	for iter_387_0 = arg_387_2, arg_387_3 do
		local var_387_1 = math.rad(iter_387_0)
		local var_387_2 = arg_387_0.x + math.cos(var_387_1) * arg_387_1
		local var_387_3 = arg_387_0.y + math.sin(var_387_1) * arg_387_1

		var_387_0[#var_387_0 + 1] = vec2_t.new(var_387_2, var_387_3)
	end

	for iter_387_1 = arg_387_3, arg_387_2, -1 do
		local var_387_4 = math.rad(iter_387_1)
		local var_387_5 = arg_387_0.x + math.cos(var_387_4) * (arg_387_1 - arg_387_4)
		local var_387_6 = arg_387_0.y + math.sin(var_387_4) * (arg_387_1 - arg_387_4)

		var_387_0[#var_387_0 + 1] = vec2_t.new(var_387_5, var_387_6)
	end

	render.polygon(var_387_0, arg_387_5)
end

function var_0_22.watermark.watermark_render(arg_388_0)
	local var_388_0 = arg_388_0
	local var_388_1 = render.get_screen_size()
	local var_388_2 = vec2_t.new(var_388_1.x - 20, 20)
	local var_388_3 = {
		"eclipse.lua [",
		var_0_0 and "debug" or "live",
		"]",
		" "
	}
	local var_388_4 = var_0_22.watermark.menu_elems.enable_beta_animation

	if not var_0_0 and var_388_4.visible then
		var_388_4:set_visible(false)
	end

	local var_388_5 = var_0_22.watermark.menu_elems.enable_name
	local var_388_6 = var_0_22.watermark.menu_elems.enable_uid
	local var_388_7 = var_0_22.watermark.menu_elems.enable_time
	local var_388_8 = var_0_22.watermark.menu_elems.enable_timeout

	if var_388_5:get() then
		table.insert(var_388_3, " / name: ")
		table.insert(var_388_3, var_0_22.globals.name .. " ")
	end

	if var_388_6:get() then
		table.insert(var_388_3, " / uid: ")
		table.insert(var_388_3, tostring(var_0_22.globals.uid) .. " ")
	end

	if var_388_7:get() then
		table.insert(var_388_3, " / time: ")

		local var_388_9, var_388_10, var_388_11 = client.get_local_time()

		if var_388_9 < 10 then
			var_388_9 = "0" .. var_388_9
		end

		if var_388_10 < 10 then
			var_388_10 = "0" .. var_388_10
		end

		if var_388_11 < 10 then
			var_388_11 = "0" .. var_388_11
		end

		table.insert(var_388_3, string.format("%s:%s:%s ", var_388_9, var_388_10, var_388_11))
	end

	local var_388_12 = var_0_22:get_accent_color()
	local var_388_13 = table.concat(var_388_3)
	local var_388_14 = render.get_text_size(var_0_22.fonts.default, var_388_13)
	local var_388_15 = 30
	local var_388_16 = global_vars.real_time() - var_0_22.watermark.net_upd_last_update > 0.5 and engine.is_connected() and var_388_8:get()

	if var_388_16 then
		var_388_15 = var_388_15 + render.get_text_size(var_0_22.fonts.default, string.format("timeout: %.1f", global_vars.real_time() - var_0_22.watermark.net_upd_last_update)).x + 10
	end

	var_388_0.size.x = math.floor(var_0_13(var_388_0.size.x, var_388_14.x + var_388_15, 0.2))
	var_388_0.size.y = var_388_14.y + 10
	var_388_0.pos.x = var_388_2.x - var_388_0.size.x
	var_388_0.pos.y = var_388_2.y

	render.rect_filled(var_388_0.pos, var_388_0.size, color_t.new(0, 0, 0, 255), 7)
	render.rect_filled(var_388_0.pos + vec2_t.new(1, 1), var_388_0.size - vec2_t.new(2, 2), var_0_26.dark_background, 7)

	local var_388_17 = var_388_15 - 10

	if var_388_16 then
		local var_388_18 = math.sin(global_vars.real_time() * 2) * 360
		local var_388_19 = var_388_18 + 90

		var_0_22.watermark.render_circle(var_388_0.pos + vec2_t.new(12, 13), 7, var_388_18, var_388_19, 2, color_t.new(var_388_12.r, var_388_12.g, var_388_12.b, 200))
		var_0_22.watermark.render_circle(var_388_0.pos + vec2_t.new(12, 13), 7, var_388_18 + 180, var_388_19 + 180, 2, color_t.new(var_388_12.r, var_388_12.g, var_388_12.b, 200))

		local var_388_20 = "timeout: %.1f"
		local var_388_21 = string.format(var_388_20, global_vars.real_time() - var_0_22.watermark.net_upd_last_update)

		render.text(var_0_22.fonts.default, var_388_21, var_388_0.pos + vec2_t.new(25, 5), color_t.new(255, 40, 40, 255))

		var_388_3[1] = "| " .. var_388_3[1]
		var_388_17 = var_388_17 - 5
	else
		render.circle_filled(var_388_0.pos + vec2_t.new(13, 13), 6, color_t.new(255, 255, 255, 255))
		render.circle_filled(var_388_0.pos + vec2_t.new(9, 9), 5, color_t.new(var_388_12.r, var_388_12.g, var_388_12.b, 200))
	end

	render.push_clip(var_388_0.pos, var_388_0.size)

	local var_388_22 = var_0_0 and "debug" or "live"

	for iter_388_0 = 1, #var_388_3 do
		local var_388_23 = tostring(var_388_3[iter_388_0])
		local var_388_24 = iter_388_0 % 2 == 0 and var_388_12 or color_t.new(220, 220, 220, 255)
		local var_388_25 = render.get_text_size(var_0_22.fonts.default, var_388_23).x
		local var_388_26 = vec2_t.new(var_388_0.pos.x + 5 + var_388_17, var_388_0.pos.y + 5)

		if var_0_0 and var_388_23 == var_388_22 and var_388_4:get() then
			var_0_7.render("beta_watermark_text", var_0_22.fonts.default, var_388_23, var_388_26, var_388_24, -4)
		else
			render.text(var_0_22.fonts.default, var_388_23, var_388_26, var_388_24)
		end

		var_388_17 = var_388_17 + var_388_25
	end

	render.pop_clip()
end

var_0_22.watermark.draggable:set_render_fn(var_0_22.watermark.watermark_render)

var_0_22.watermark.net_upd_last_update = 0

callbacks.add(e_callbacks.NET_UPDATE, function()
	var_0_22.watermark.net_upd_last_update = global_vars.real_time()
end)
callbacks.add(e_callbacks.PAINT, function()
	if not var_0_22.settings.visuals.watermark:get() then
		return
	end

	var_0_22.watermark.draggable:handle_drawing()
end)

var_0_22.client_animations = {
	cached_ground = false,
	land_time = 0
}

callbacks.add(e_callbacks.ANTIAIM, function(arg_391_0, arg_391_1)
	if not var_0_22.settings.visuals.client_sided_animations:get() then
		return
	end

	local var_391_0 = var_0_22.settings.visuals.animations
	local var_391_1 = entity_list.get_local_player():has_player_flag(e_player_flags.ON_GROUND)
	local var_391_2 = arg_391_1:has_button(e_cmd_buttons.JUMP)
	local var_391_3 = global_vars.cur_time()

	if not var_391_1 then
		var_0_22.client_animations.land_time = var_391_3 + 0.65
	end

	if var_391_0:get("static legs in air") then
		arg_391_0:set_render_pose(e_poses.JUMP_FALL, 0.5, 0.5)
	end

	if var_391_0:get("0-pitch on land") and var_391_1 and var_391_3 < var_0_22.client_animations.land_time and var_0_22.antiaim.state ~= var_0_36[4] and var_0_22.antiaim.state ~= var_0_36[5] then
		arg_391_0:set_render_pose(e_poses.BODY_PITCH, 0.5)
	end

	if var_391_0:get("lean in air") and not var_391_1 then
		arg_391_0:set_render_animlayer(e_animlayers.LEAN, 0.75)
	end

	if var_391_0:get("backwards slide") and var_391_1 then
		arg_391_0:set_render_pose(e_poses.STRAFE_DIR, -1)
	end
end)
callbacks.add(e_callbacks.EVENT, function(arg_392_0)
	local var_392_0 = entity_list.get_local_player()

	if not var_392_0 or not var_392_0:is_valid() or not var_392_0:is_alive() then
		return
	end

	local var_392_1 = arg_392_0.attacker
	local var_392_2 = entity_list.get_player_from_userid(var_392_1)

	if not var_392_2 or not var_392_2:is_valid() or var_392_2:is_enemy() then
		return
	end

	if var_392_2:get_index() ~= var_392_0:get_index() then
		return
	end

	local var_392_3 = var_0_22.settings.visuals.fake_media:get(1)
	local var_392_4 = var_0_22.settings.visuals.fake_media:get(2)
	local var_392_5 = var_0_22.settings.visuals.fake_media:get(3)
	local var_392_6 = var_0_22.settings.visuals.fake_media:get(4)
	local var_392_7 = var_0_22.settings.visuals.fake_media:get(5)
	local var_392_8 = var_0_22.settings.visuals.fake_media:get(6)

	if var_392_3 then
		arg_392_0.headshot = true
	end

	if var_392_4 then
		arg_392_0.noscope = true
	end

	if var_392_5 then
		arg_392_0.attackerblind = true
	end

	if var_392_6 then
		arg_392_0.penetrated = true
	end

	if var_392_7 then
		arg_392_0.dominated = true
	end

	if var_392_8 then
		arg_392_0.thrusmoke = true
	end
end, "player_death")

var_0_22.branding_texts = {
	"winning since 2022",
	"winning is easy with eclipse.luashka...",
	"no one can stop us",
	"we are the best",
	"untouched.",
	"we are the best",
	"unstoppable momentum",
	"champions since day one",
	"redefining excellence",
	"elevating the winning standard",
	"pioneering victories",
	"trailblazing triumphs",
	"dominating the game",
	"consistent conquerors",
	"leading the winner's circle",
	"empowering success stories",
	"achieving greatness together",
	"fueling your winning streak",
	"where success takes root",
	"the art of winning",
	"creating winning legacies",
	"winning beyond boundaries",
	"perpetual victory parade",
	"crafting winning futures",
	"unveiling the champions within",
	"innovating for triumph"
}

callbacks.add(e_callbacks.EVENT, function(arg_393_0)
	if not var_0_22.settings.visuals.branding:get() then
		return
	end

	arg_393_0.funfact_token = string.format("eclipse [%s]\n", var_0_22.globals.version) .. var_0_22.branding_texts[client.random_int(1, #var_0_22.branding_texts)]
end, "cs_win_panel_round")
callbacks.add(e_callbacks.NET_UPDATE, function(arg_394_0)
	if not engine.is_connected() or not var_0_22.settings.visuals.grim_reaper:get() then
		return
	end

	local var_394_0 = entity_list.get_entities_by_name("CCSRagdoll")

	if var_394_0 == nil or #var_394_0 == 0 then
		return
	end

	local var_394_1 = engine.get_view_angles()
	local var_394_2 = var_394_1.x
	local var_394_3 = var_394_1.y
	local var_394_4 = var_394_1.z
	local var_394_5 = vec3_t.new(math.cos(math.rad(var_394_3)) * math.cos(math.rad(var_394_2)), math.sin(math.rad(var_394_3)) * math.cos(math.rad(var_394_2)), math.sin(math.rad(var_394_2)))
	local var_394_6 = entity_list.get_local_player():get_render_origin()

	for iter_394_0 = 1, #var_394_0 do
		local var_394_7 = var_394_0[iter_394_0]
		local var_394_8 = var_394_7:get_render_origin()
		local var_394_9 = var_394_6:dist(var_394_8) / 100
		local var_394_10 = -100000 * var_394_9 * var_394_9
		local var_394_11 = vec3_t.new(var_394_5.x * var_394_10, var_394_5.y * var_394_10, -var_394_10)
		local var_394_12 = vec3_t.new(var_394_5.x * var_394_10, var_394_5.y * var_394_10, -var_394_10)

		var_394_7:set_prop("m_vecForce", var_394_11)
		var_394_7:set_prop("m_vecRagdollVelocity", var_394_12)
	end
end)
var_0_22.settings.visuals.page_icon_animations:register_callback(function()
	var_0_22:set_page_icon_animation(var_0_22.settings.visuals.page_icon_animations:get())
end)
var_0_22.settings.visuals.override_menu_colors:register_callback(function()
	var_0_22.changed_colors.inactive_text = var_0_22.settings.visuals.inactive_text_color:get()
	var_0_22.changed_colors.hovering_text = var_0_22.settings.visuals.hovering_text_color:get()
	var_0_22.changed_colors.active_text = var_0_22.settings.visuals.active_text_color:get()
	var_0_22.changed_colors.inactive_outline = var_0_22.settings.visuals.inactive_outline_color:get()
	var_0_22.changed_colors.hovering_outline = var_0_22.settings.visuals.hovering_outline_color:get()
	var_0_22.changed_colors.active_outline = var_0_22.settings.visuals.active_outline_color:get()
	var_0_22.changed_colors.dark_background = var_0_22.settings.visuals.dark_background_color:get()
	var_0_22.changed_colors.subtab_background = var_0_22.settings.visuals.subtab_background_color:get()
	var_0_22.changed_colors.section_background = var_0_22.settings.visuals.section_background_color:get()
	var_0_22.changed_colors.footer_background = var_0_22.settings.visuals.footer_background_color:get()

	var_0_22:use_custom_colors(var_0_22.settings.visuals.override_menu_colors:get())
end)
var_0_22.settings.visuals.inactive_text_color:register_callback(function()
	var_0_22.changed_colors.inactive_text = var_0_22.settings.visuals.inactive_text_color:get()
end)
var_0_22.settings.visuals.hovering_text_color:register_callback(function()
	var_0_22.changed_colors.hovering_text = var_0_22.settings.visuals.hovering_text_color:get()
end)
var_0_22.settings.visuals.active_text_color:register_callback(function()
	var_0_22.changed_colors.active_text = var_0_22.settings.visuals.active_text_color:get()
end)
var_0_22.settings.visuals.inactive_outline_color:register_callback(function()
	var_0_22.changed_colors.inactive_outline = var_0_22.settings.visuals.inactive_outline_color:get()
end)
var_0_22.settings.visuals.hovering_outline_color:register_callback(function()
	var_0_22.changed_colors.hovering_outline = var_0_22.settings.visuals.hovering_outline_color:get()
end)
var_0_22.settings.visuals.active_outline_color:register_callback(function()
	var_0_22.changed_colors.active_outline = var_0_22.settings.visuals.active_outline_color:get()
end)
var_0_22.settings.visuals.dark_background_color:register_callback(function()
	var_0_22.changed_colors.dark_background = var_0_22.settings.visuals.dark_background_color:get()
end)
var_0_22.settings.visuals.subtab_background_color:register_callback(function()
	var_0_22.changed_colors.subtab_background = var_0_22.settings.visuals.subtab_background_color:get()
end)
var_0_22.settings.visuals.section_background_color:register_callback(function()
	var_0_22.changed_colors.section_background = var_0_22.settings.visuals.section_background_color:get()
end)
var_0_22.settings.visuals.footer_background_color:register_callback(function()
	var_0_22.changed_colors.footer_background = var_0_22.settings.visuals.footer_background_color:get()
end)
var_0_22.settings.visuals.reset_menu_colors:register_callback(function()
	var_0_22:reset_colors()
	var_0_22.settings.visuals.inactive_text_color:set(var_0_22.colors_backup.inactive_text)
	var_0_22.settings.visuals.hovering_text_color:set(var_0_22.colors_backup.hovering_text)
	var_0_22.settings.visuals.active_text_color:set(var_0_22.colors_backup.active_text)
	var_0_22.settings.visuals.inactive_outline_color:set(var_0_22.colors_backup.inactive_outline)
	var_0_22.settings.visuals.hovering_outline_color:set(var_0_22.colors_backup.hovering_outline)
	var_0_22.settings.visuals.active_outline_color:set(var_0_22.colors_backup.active_outline)
	var_0_22.settings.visuals.dark_background_color:set(var_0_22.colors_backup.dark_background)
	var_0_22.settings.visuals.subtab_background_color:set(var_0_22.colors_backup.subtab_background)
	var_0_22.settings.visuals.section_background_color:set(var_0_22.colors_backup.section_background)
	var_0_22.settings.visuals.footer_background_color:set(var_0_22.colors_backup.footer_background)
end)

var_0_22.config = {
	path = "./csgo/eclipse/"
}

var_0_3.cdef("    typedef void*(__thiscall* shell_execute_t)(void*, const char*, const char*);\n")

var_0_22.config.ffi = {}
var_0_22.config.ffi.class_ptr = var_0_3.typeof("void***")
var_0_22.config.ffi.rawvguisystem = memory.create_interface("vgui2.dll", "VGUI_System010") or error("VGUI_System010 wasn't found", 2)
var_0_22.config.ffi.ivguisystem = var_0_3.cast(var_0_22.config.ffi.class_ptr, var_0_22.config.ffi.rawvguisystem) or error("rawvguisystem is nil", 2)
var_0_22.config.ffi.shell_execute = var_0_3.cast("shell_execute_t", var_0_22.config.ffi.ivguisystem[0][3]) or error("shell_execute is nil", 2)

function var_0_22.config.ffi.__thiscall(arg_408_0, arg_408_1)
	return function(...)
		return arg_408_0(arg_408_1, ...)
	end
end

function var_0_22.config.ffi.vmt_bind(arg_410_0, arg_410_1, arg_410_2, arg_410_3)
	local var_410_0 = var_0_3.cast("void***", memory.create_interface(arg_410_0, arg_410_1)) or error(arg_410_1 .. " is nil.")

	return var_0_22.config.ffi.__thiscall(var_0_3.cast(arg_410_3, var_410_0[0][arg_410_2]), var_410_0)
end

var_0_22.config.ffi.native_GetCurrentDirectory = var_0_22.config.ffi.vmt_bind("filesystem_stdio.dll", "VFileSystem017", 40, "bool(__thiscall*)(void*, char*, int)")
var_0_22.config.ffi.char = var_0_3.new("char[256]")

var_0_22.config.ffi.native_GetCurrentDirectory(var_0_22.config.ffi.char, var_0_3.sizeof(var_0_22.config.ffi.char))

var_0_22.config.path = string.format("%s/csgo/eclipse/", var_0_3.string(var_0_22.config.ffi.char))

function var_0_22.config.refresh(arg_411_0)
	local var_411_0 = var_0_6.fn.list_files(var_0_22.config.path)

	var_0_22.settings.config.configs:update_items(var_411_0)
	var_0_22.settings.config.autoload:update_items({
		"-",
		unpack(var_411_0)
	})

	if arg_411_0 then
		client.log_screen("refreshed configs")
	end

	return var_411_0
end

var_0_22.config.refresh()

function var_0_22.config.save()
	local var_412_0, var_412_1 = var_0_22.settings.config.configs:get()

	if var_412_0 == nil then
		client.log_screen("no config selected")

		return
	end

	local var_412_2 = var_0_22:get_config()
	local var_412_3 = var_0_4.encode(var_412_2)
	local var_412_4 = var_0_5.fn.open("eclipse/" .. var_412_1, "w", "GAME")

	var_412_4:write(var_412_3)
	var_412_4:close()
	client.log_screen("saved config " .. var_412_1)
end

function var_0_22.config.load()
	local var_413_0, var_413_1 = var_0_22.settings.config.configs:get()

	if var_413_0 == nil then
		client.log_screen("no config selected")

		return
	end

	if var_413_1 == nil then
		return
	end

	if not var_0_5.fn.exists("eclipse/" .. var_413_1, "GAME") then
		client.log_screen("config " .. var_413_1 .. " does not exist")

		return
	end

	local var_413_2 = var_0_5.fn.open("eclipse/" .. var_413_1, "r", "GAME")
	local var_413_3 = var_413_2:read()

	var_413_2:close()

	local var_413_4 = var_0_4.json_parse(var_413_3)

	var_0_22:load_config(var_413_4)
	client.log_screen("loaded config " .. var_413_1)
end

function var_0_22.config.delete()
	local var_414_0, var_414_1 = var_0_22.settings.config.configs:get()

	if var_414_0 == nil then
		client.log_screen("no config selected")

		return
	end

	if not var_0_5.fn.exists("eclipse/" .. var_414_1, "GAME") then
		client.log_screen("config " .. var_414_1 .. " does not exist")

		return
	end

	var_0_5.fn.remove("eclipse/" .. var_414_1, "GAME")
	client.log_screen("deleted config " .. var_414_1)
	var_0_22.config.refresh()
end

function var_0_22.config.reset()
	local var_415_0 = var_0_22.settings.config.autoload:get()

	var_0_22:reset_config()
	var_0_22.config.refresh()
	var_0_22.settings.config.autoload:set(var_415_0)
end

function var_0_22.config.create()
	local var_416_0 = var_0_22.settings.config.new:get()

	if var_416_0 == "" then
		client.log_screen("config name cannot be empty")

		return
	end

	if var_416_0:sub(-4) ~= ".ecl" then
		var_416_0 = var_416_0 .. ".ecl"
	end

	if not var_0_5.fn.exists("eclipse/" .. var_416_0, "GAME") then
		var_0_5.fn.create_directory("eclipse", "GAME")
	else
		client.log_screen("config " .. var_416_0 .. " already exists")

		return
	end

	local var_416_1 = var_0_22.settings.config.configs:get_items()

	table.insert(var_416_1, var_416_0)
	var_0_22.settings.config.configs:update_items(var_416_1)
	var_0_22.settings.config.configs:set(#var_416_1)
	var_0_22.config.save()
	var_0_22.config.refresh()
end

function var_0_22.config.open_folder()
	var_0_22.config.ffi.shell_execute(var_0_22.config.ffi.ivguisystem, "open", var_0_22.config.path)
end

function var_0_22.config.autoload()
	local var_418_0 = "eclipse/autoload.cfg"
	local var_418_1 = var_0_5.fn.exists(var_418_0, "GAME")
	local var_418_2 = var_0_22.config.refresh()
	local var_418_3 = {
		"-",
		unpack(var_418_2)
	}

	var_0_22.settings.config.autoload:update_items(var_418_3)

	if not var_418_1 then
		var_0_5.fn.create_directory("eclipse", "GAME")

		local var_418_4 = var_0_22.settings.config.configs:get()

		if var_418_4 == nil then
			var_418_4 = "-"
		end

		local var_418_5 = var_0_5.fn.open(var_418_0, "w", "GAME")

		var_418_5:write(var_418_4)
		var_418_5:close()
		var_0_22.settings.config.autoload:set(var_418_4)
	else
		local var_418_6 = var_0_5.fn.open(var_418_0, "r", "GAME")
		local var_418_7 = var_418_6:read()

		var_418_6:close()

		if var_418_7 == "-" or table.shallow_find(var_418_3, var_418_7) == nil then
			var_0_22.settings.config.autoload:set("-")

			return
		end

		var_0_22.settings.config.configs:set(var_418_7)
		client.log_screen("autoloading config " .. var_418_7)
		var_0_22.config.load()
		var_0_22.settings.config.autoload:set(var_418_7)
	end
end

var_0_22.config.autoload()

function var_0_22.config.set_autoload()
	local var_419_0 = "eclipse/autoload.cfg"

	if not var_0_5.fn.exists(var_419_0, "GAME") then
		var_0_5.fn.create_directory("eclipse", "GAME")
	end

	local var_419_1, var_419_2 = var_0_22.settings.config.autoload:get()

	if var_419_1 == nil or var_419_2 == nil then
		return
	end

	client.log_screen("set autoload config to " .. var_419_2)

	local var_419_3 = var_0_5.fn.open(var_419_0, "w", "GAME")

	var_419_3:write(var_419_2)
	var_419_3:close()
end

var_0_22.settings.config.refresh:register_callback(var_0_11(var_0_22.config.refresh, true))
var_0_22.settings.config.autoload:register_callback(var_0_22.config.set_autoload)
var_0_22.settings.config.save:register_callback(var_0_22.config.save)
var_0_22.settings.config.load:register_callback(var_0_22.config.load)
var_0_22.settings.config.delete:register_callback(var_0_22.config.delete)
var_0_22.settings.config.reset:register_callback(var_0_22.config.reset)
var_0_22.settings.config.create:register_callback(var_0_22.config.create)
var_0_22.settings.config.open_folder:register_callback(var_0_22.config.open_folder)
var_0_22.settings.config.join_discord:register_callback(function()
	var_0_22.config.ffi.shell_execute(var_0_22.config.ffi.ivguisystem, "open", "https://discord.gg/TcCUBpmpCp")
end)

local function var_0_56(arg_421_0, arg_421_1, arg_421_2, arg_421_3)
	local var_421_0 = arg_421_0 == nil and "unknown" or arg_421_0:get_name()
	local var_421_1 = string.format("%i -> anti-bruteforce: %s %s (%i)", arg_421_1, var_421_0, arg_421_2 and "hit" or "missed", arg_421_3)

	client.log_screen(var_421_1)
end

var_0_10:add_callback(var_0_56)
callbacks.add(e_callbacks.PAINT, function()
	var_0_22:render()
end)
