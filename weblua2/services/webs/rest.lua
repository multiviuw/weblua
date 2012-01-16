module ('services.webs.rest', package.seeall)

http = require "services.webs.tools.http"
util = require "services.webs.tools.util"
converter = require "services.webs.tools.converter"

local data = ''														--Armazena os dados, ate ter um disconect
local data_format = ''
local status = 'off'

function rest_request(url, port, method, paramstable, user, password, format)

    data_format = format

    if method == 'get' then
        url = url .. '?' .. util.urlEncode(paramstable)
        http.request(url, port, method, paramstable, agent, headers, user, password)
    elseif method == 'post' then
        http.request(url, port, method, paramstable, agent, headers, user, password)
    end
end

--Vai lancar eventos tbm, so que separando o cabecalho do corpo, ja em formato de tabela. Manda cada um em um evento seeparado.
function handler(evt)
	if evt.class ~= 'user' or evt.protocol~='http' then return; end

	if evt.type == 'data'then
		data = data .. evt.data;
	end

	if evt.type == 'msg' and evt.data == 'errorC' then
		event.post('in',{ class='user', protocol='rest', type='msg', data = 'sem conexao' });
	end
	if evt.type == 'msg' and evt.data == 'errorD' then
		event.post('in',{ class='user', protocol='rest', type='msg', data = 'erro na comunicacao' });
	end
	if evt.type == 'msg' and evt.data == 'disconected' then
		header, body = http.getHeaderAndContent(data);

		local response_table = {}

		if data_format == 'xml' then
			response_table = converter.xml_to_table(body)
		elseif data_format == 'json' then
			response_table = converter.json_to_table(body)
		end
		event.post('in',{ class='user', protocol='rest', type='data', data = response_table });

	end
	print (evt.data)
end
event.register(handler)
