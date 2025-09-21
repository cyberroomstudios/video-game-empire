local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local superBaseEvent = ReplicatedStorage.BindableEvent.SuperBaseEvent

local SUPABASE_URL = "https://mkfcmktkogtblrkfhxym.supabase.co"
local SUPABASE_KEY =
	"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1rZmNta3Rrb2d0Ymxya2ZoeHltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg0Mjc3MDUsImV4cCI6MjA3NDAwMzcwNX0.QBoQAnx160PB2bkQlqLphaJBA7TWrY3m5DCDrIqdc24"

local sessionData = {}

-- Função auxiliar para converter timestamp
local function isoTimestamp()
	return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

-- Função para criar sessão no Supabase
local function createSession(userId, startTime, endTime)
	local payload = {
		user_id = userId,
		start_time = startTime,
		end_time = endTime,
	}

	-- Etapa 1: POST para inserir a sessão
	local postSuccess, postResponse = pcall(function()
		return HttpService:RequestAsync({
			Url = SUPABASE_URL .. "/rest/v1/sessions",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["apikey"] = SUPABASE_KEY,
				["Authorization"] = "Bearer " .. SUPABASE_KEY,
			},
			Body = HttpService:JSONEncode(payload),
		})
	end)

	if not postSuccess or not postResponse.Success then
		warn("Erro ao criar sessão:", postResponse and postResponse.StatusCode, postResponse and postResponse.Body)
		return nil
	end

	-- Etapa 2: GET para recuperar o ID
	local encodedStartTime = HttpService:UrlEncode(startTime)
	local url = string.format(
		"%s/rest/v1/sessions?user_id=eq.%s&start_time=eq.%s&select=id",
		SUPABASE_URL,
		tostring(userId),
		encodedStartTime
	)

	local getSuccess, getResponse = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = {
				["apikey"] = SUPABASE_KEY,
				["Authorization"] = "Bearer " .. SUPABASE_KEY,
			},
		})
	end)

	if getSuccess and getResponse.Success and getResponse.Body and getResponse.Body ~= "" then
		local decoded = HttpService:JSONDecode(getResponse.Body)
		if decoded[1] and decoded[1].id then
			return decoded[1].id
		end
	end

	warn("Não foi possível obter o ID da sessão.")
	return nil
end

-- Função para enviar eventos
local function sendEvents(sessionId, events)
	local payload = {}

	for _, e in pairs(events) do
		table.insert(payload, {
			session_id = sessionId,
			event_name = e.event,
			timestamp = e.timestamp,
			extra_info = e.extra,
		})
	end

	-- Etapa 1: POST para inserir a sessão
	local postSuccess, postResponse = pcall(function()
		return HttpService:RequestAsync({
			Url = SUPABASE_URL .. "/rest/v1/events",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["apikey"] = SUPABASE_KEY,
				["Authorization"] = "Bearer " .. SUPABASE_KEY,
			},
			Body = HttpService:JSONEncode(payload),
		})
	end)

	if not postSuccess or not postResponse.Success then
		warn("Erro ao criar sessão:", postResponse and postResponse.StatusCode, postResponse and postResponse.Body)
		return nil
	end
end

-- Registrar sessão e eventos
Players.PlayerAdded:Connect(function(player)
	local userId = player.UserId
	sessionData[userId] = {
		events = {},
		startTime = os.time(),
	}
end)

-- Função pública para registrar eventos
local function logEvent(player, eventName, extraInfo)
	local userId = player.UserId
	if not sessionData[userId] then
		return
	end

	table.insert(sessionData[userId].events, {
		event = eventName,
		timestamp = isoTimestamp(),
		extra = extraInfo or {},
	})
end

superBaseEvent.Event:Connect(function(player, eventName)
	logEvent(player, eventName, {})
end)

-- Ao sair do jogo, cria sessão e envia eventos
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	local data = sessionData[userId]
	if not data then
		return
	end

	local startTime = os.date("!%Y-%m-%dT%H:%M:%SZ", data.startTime)
	local endTime = isoTimestamp()

	local sessionId = createSession(userId, startTime, endTime)
	if sessionId then
		sendEvents(sessionId, data.events)
	end

	sessionData[userId] = nil
end)
