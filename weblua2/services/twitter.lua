module ('services.twitter', package.seeall)

rest = require 'services.webs.rest'

--Campos retornados:
function getTimeline(user,page)
	local paramstable = {
            screen_name = user,
        }

	rest.rest_request("http://api.twitter.com/1/statuses/user_timeline.json", nil,'get', paramstable, nil, nil, 'json')
end

function handler(evt)
	if evt.class ~= 'user' or evt.protocol~='rest' then return; end

	if evt.type == 'msg' and evt.data == 'errorC' then
		event.post('in',{ class='user', protocol='twitter', type='msg', data = 'sem conexao' });
	end

	if evt.type == 'msg' and evt.data == 'errorD' then
		event.post('in',{ class='user', protocol='twitter', type='msg', data = 'erro na comunicacao' });
	end

	if evt.type == 'data' then

		event.post('in',{ class='user', protocol='twitter', type='data', data = response_table });

	end
	--print (evt.data)
end
event.register(handler)
