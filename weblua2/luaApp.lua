t = require 'services.twitter'

function prin(txt)
	print('________________________________________________')
	print('')
	print(txt)
	print('')
	print('________________________________________________')
end




prin(t.getTimeline('ricoII',1));
