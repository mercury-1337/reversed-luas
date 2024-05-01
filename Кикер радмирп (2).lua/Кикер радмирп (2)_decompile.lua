-- idk what i need crack here

local var_0_0 = false
local var_0_1 = -1

function main()
	repeat
		wait(0)
	until isSampAvailable()

	wait(2000)
	sampRegisterChatCommand("ebash", dgg)
	sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xC7\xE0\xE3\xF0\xF3\xE6\xE5\xED!", -1)
	sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xC0\xE2\xF2\xEE\xF0: {DAA520}\xCA\xD0\xC8\xCF\xD2\xCE\xCD {FFFFFF}\xCC\xEE\xE4\xE8\xF4\xE8\xEA\xE0\xF2\xEE\xF0: {DAA520}THEORBITAYT", -1)
	sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xC0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xFF: {DAA520}/ebash (id)", -1)

	while true do
		wait(0)

		if var_0_0 then
			local var_1_0, var_1_1 = sampGetCharHandleBySampPlayerId(var_0_1)

			if not var_1_0 then
				var_0_0 = false

				sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xC8\xE3\xF0\xEE\xEA \xF3\xEC\xE5\xF0, \xEA\xE8\xEA\xED\xF3\xF2 \xEB\xE8\xE1\xEE \xE2\xFB\xF8\xE5\xEB!", -1)
			elseif isCharOnFoot(PLAYER_PED) then
				var_0_0 = false

				sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xD2\xFB \xE2\xFB\xF8\xE5\xEB \xE8\xE7 \xE0\xE2\xF2\xEE, \xD1\xFF\xE4\xFC \xE2 \xE0\xE2\xF2\xEE, \xE5\xF1\xEB\xE8 \xED\xE5 \xEF\xE8\xE7\xE4\xFE\xEA!", -1)
			else
				local var_1_2 = getCarCharIsUsing(PLAYER_PED)
				local var_1_3, var_1_4 = sampGetVehicleIdByCarHandle(var_1_2)

				if var_1_3 then
					local var_1_5, var_1_6, var_1_7 = getCharCoordinates(PLAYER_PED)
					local var_1_8, var_1_9, var_1_10 = getCharCoordinates(var_1_1)

					if var_1_10 - var_1_7 < 5 then
						local var_1_11 = samp_create_sync_data("vehicle")
						local var_1_12

						var_1_12, var_1_11.vehicleId = sampGetVehicleIdByCarHandle(var_1_2)
						var_1_11.vehicleHealth = getCarHealth(var_1_2)
						var_1_11.playerHealth = getCharHealth(PLAYER_PED)
						var_1_11.armor = getCharArmour(PLAYER_PED)
						var_1_11.position.x, var_1_11.position.y, var_1_11.position.z = getCharCoordinates(var_1_1)
						var_1_11.position.z = var_1_11.position.z - 1

						var_1_11.send()
						wait(0)

						local var_1_13 = samp_create_sync_data("vehicle")
						local var_1_14

						var_1_14, var_1_13.vehicleId = sampGetVehicleIdByCarHandle(var_1_2)
						var_1_13.vehicleHealth = getCarHealth(var_1_2)
						var_1_13.playerHealth = getCharHealth(PLAYER_PED)
						var_1_13.armor = getCharArmour(PLAYER_PED)
						var_1_13.position.x, var_1_13.position.y, var_1_13.position.z = getCharCoordinates(PLAYER_PED)
						var_1_13.position.z = var_1_13.position.y - 15

						var_1_13.send()
						wait(0)
					end
				end
			end
		end
	end
end

function dgg(arg_2_0)
	if var_0_0 then
		var_0_0 = false

		sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xD2\xFB \xE1\xEE\xEB\xFC\xF8\xE5 \xED\xE5 \xEA\xE8\xEA\xE0\xE5\xF8\xFC \xE8\xE3\xF0\xEE\xEA\xE0!", -1)
	elseif isCharOnFoot(PLAYER_PED) then
		sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xD1\xFF\xE4\xFC \xE2 \xE0\xE2\xF2\xEE, \xE5\xF1\xEB\xE8 \xED\xE5 \xEF\xE8\xE7\xE4\xFE\xEA!", -1)
	elseif not arg_2_0:match("%d+") then
		sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xC8\xF1\xEF\xEE\xEB\xFC\xE7\xF3\xE9\xF2\xE5: {DAA520}/ebash [PlayerID]", -1)
	else
		local var_2_0, var_2_1 = sampGetCharHandleBySampPlayerId(arg_2_0)

		if not var_2_0 then
			sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xC8\xE3\xF0\xEE\xEA\xE0 \xED\xE5\xF2 \xE2 \xE7\xEE\xED\xE5 \xF1\xF2\xF0\xE8\xEC\xE0!", -1)
		else
			var_0_1 = tonumber(arg_2_0)
			var_0_0 = true

			sampAddChatMessage("{DAA520}[Kicker Radmir]: {FFFFFF}\xCA\xE8\xEA\xE0\xE5\xEC \xE8\xE3\xF0\xEE\xEA\xE0 {DAA520}" .. sampGetPlayerNickname(var_0_1) .. "[" .. var_0_1 .. "]", -1)
		end
	end
end

function samp_create_sync_data(arg_3_0, arg_3_1)
	local var_3_0 = require("ffi")
	local var_3_1 = require("sampfuncs")
	local var_3_2 = require("samp.raknet")

	require("samp.synchronization")

	arg_3_1 = arg_3_1 or true

	local var_3_3 = ({
		player = {
			"PlayerSyncData",
			var_3_2.PACKET.PLAYER_SYNC,
			sampStorePlayerOnfootData
		},
		vehicle = {
			"VehicleSyncData",
			var_3_2.PACKET.VEHICLE_SYNC,
			sampStorePlayerIncarData
		},
		passenger = {
			"PassengerSyncData",
			var_3_2.PACKET.PASSENGER_SYNC,
			sampStorePlayerPassengerData
		},
		aim = {
			"AimSyncData",
			var_3_2.PACKET.AIM_SYNC,
			sampStorePlayerAimData
		},
		trailer = {
			"TrailerSyncData",
			var_3_2.PACKET.TRAILER_SYNC,
			sampStorePlayerTrailerData
		},
		unoccupied = {
			"UnoccupiedSyncData",
			var_3_2.PACKET.UNOCCUPIED_SYNC
		},
		bullet = {
			"BulletSyncData",
			var_3_2.PACKET.BULLET_SYNC
		},
		spectator = {
			"SpectatorSyncData",
			var_3_2.PACKET.SPECTATOR_SYNC
		}
	})[arg_3_0]
	local var_3_4 = "struct " .. var_3_3[1]
	local var_3_5 = var_3_0.new(var_3_4, {})
	local var_3_6 = tonumber(var_3_0.cast("uintptr_t", var_3_0.new(var_3_4 .. "*", var_3_5)))

	if arg_3_1 then
		local var_3_7 = var_3_3[3]

		if var_3_7 then
			local var_3_8
			local var_3_9

			if arg_3_1 == true then
				local var_3_10

				var_3_10, var_3_9 = sampGetPlayerIdByCharHandle(PLAYER_PED)
			else
				var_3_9 = tonumber(arg_3_1)
			end

			var_3_7(var_3_9, var_3_6)
		end
	end

	local function var_3_11()
		local var_4_0 = raknetNewBitStream()

		raknetBitStreamWriteInt8(var_4_0, var_3_3[2])
		raknetBitStreamWriteBuffer(var_4_0, var_3_6, var_3_0.sizeof(var_3_5))
		raknetSendBitStreamEx(var_4_0, var_3_1.HIGH_PRIORITY, var_3_1.UNRELIABLE_SEQUENCED, 1)
		raknetDeleteBitStream(var_4_0)
	end

	local var_3_12 = {
		__index = function(arg_5_0, arg_5_1)
			return var_3_5[arg_5_1]
		end,
		__newindex = function(arg_6_0, arg_6_1, arg_6_2)
			var_3_5[arg_6_1] = arg_6_2
		end
	}

	return setmetatable({
		send = var_3_11
	}, var_3_12)
end
