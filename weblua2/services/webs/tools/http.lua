module ("services.webs.tools.http", package.seeall)

local net = require "services.webs.tools.tcp";
util = require "services.webs.tools.util";
base64 = require "services.webs.tools.base64";

version = "NCLuaHTTP/0.9.9"

---Separa o header do body do HTTP
--@param response String contendo a resposta a uma requisicao HTTP
--@return Retorna o header e o body da resposta da requisicao
function getHeaderAndContent(response)
    --Procura duas quebras de linha consecutivas, que separam o header do body da resposta
	local i = string.find(response, string.char(13,10,13,10))
	local header, body = "", ""
	if i then
	   header = string.sub(response, 1, i)
	   body = string.sub(response, i+4, #response)
	else
	   header = response
	end

	return header, body
end

---Envia uma requisicao HTTP para um determinado servidor
--@param url URL para a pagina que deseja-se acessar.
--@param method Metodo HTTP a ser usado: GET ou POST. Se omitido, e usado GET.
--@param params String com o conteudo a ser adicionado a requisicao,ou uma tabela, contendo pares de paramName=value,
--no caso de requisicoes post enviando campos de formulario.Deve estar no formato URL Encode.
--No caso de requisicoes GET, os parametros devem ser passados diretamente na URL.
--@param userAgent Nome da aplicacao/versao que esta enviando a requisicao. Opcional
--@param headers Headers HTTP adicionais a serem incluidos na requisicao. Opcional
--@param user Usuario para autenticacao basica. Opcional
--@param password Senha para autenticacao basica. Opcional
--@param port Porta a ser utilizada para a conexão. O padrao e 80, no caso do valor ser omitido.
function request(url, port, method, params, userAgent, headers, user, password)
    headers = headers or ""
    params = params or ""

	if method == nil or method == "" then
       method = "GET"
    end

	userAgent = userAgent or version
	port = port or 80
    method = string.upper(method)

	if method ~= "GET" and method ~= "POST" then
       error("Parametro method deve ser GET ou POST")
    end

    local protocol, host, port1, path = splitUrl(url)

    if port1 ~= "" and port1 ~= nil then
       port = port1
    end

    if protocol == "" then
       protocol = "http://"
       url = protocol .. url
    end

	function dataReceiver(s)
		event.post('in',{ class='user', protocol='http', type='data', data = s });
	end

	function dataManager(s2)
		if s2 == 'connected' then
			url = string.gsub(url, " ", "%%20")
			local request = {}
			local fullUrl = ""
			if port == 80 then
				fullUrl = url
			else
			   fullUrl = protocol .. host .. ":" ..port .. path
			end
			--TODO: O uso de HTTP/1.1 tava fazendo com que a app congelasse
			--ao tentar obter toda resposta de uma requisicao.
			--No entanto, pelo q sei, o cabecalho Host: usado abaixo
			--e especifico de HTTP 1.1, mas isto nao causou problema.
			table.insert(request, method .." "..fullUrl.." HTTP/1.0")

			if userAgent and userAgent ~= "" then
				table.insert(request, "User-Agent: " .. userAgent)
			end

			if params ~= "" then
				if (method=="POST") and (type(params) == "table") then
					if headers ~= "" then
						headers = headers .. "\n"
					end
					headers = headers.."Content-type: application/x-www-form-urlencoded"
				end
			end

			if headers ~= "" then
			   table.insert(request, headers)
			end

			table.insert(request, "Host: "..host)

			if user and password and user ~= "" and password ~= "" then
			   table.insert(request, "Authorization: Basic " ..
					 base64.enc(user..":"..password))
			end

			if params ~= "" then
			   if type(params) == "table" then
				  params = util.urlEncode(params)
			   end
			   table.insert(request, "Content-Length: " .. #params.."\n")
			   table.insert(request, params)
			end

			table.insert(request, "\n")

			local requestStr = table.concat(request, "\n")
			con:send(requestStr);
		end
		event.post('in',{ class='user', protocol='http', type='msg', data = s2 });

	end

	con = net.Net:new(host, port);
	con:registerData(dataReceiver);
	con:registerMng(dataManager);
	con:connect();
end

---Obtem o valor de um determinado campo de uma resposta HTTP
--@param header Conteudo do cabecalho da resposta HTTP de onde deseja-se extrair
--o valor de um campo do cabecalho
--@param fieldName Nome do campo no cabecalho HTTP
function getHttpHeader(header, fieldName)
  --Procura a posicao de inicio do campo
  local i = string.find(header, fieldName .. ":")
  --Se o campo existe
  if i then
     --procura onde o campo termina (pode terminar com \n ou espaco
     --a busca e feita a partir da posição onde o campo comeca
     local fim = string.find(header, "\n", i) or string.find(header, " ", i)
     return string.sub(header, i, fim)
  else
     return nil
  end
end

---Obtem uma URL e divide a mesma em protocolo, host, porta e path
--@param url URL a ser dividida
--@return Retorna o protocolo, host, porta e o path obtidas da URL.
--Caso algum destes valores nao exita na URL, e retornada uma string vazia no seu lugar.
function splitUrl(url)
  local protocolo = ""
  local separadorProtocolo = "://"

  local i = string.find(url, separadorProtocolo)
  if i then
		protocolo = string.sub(url, 1, i+2)
		i=i+#separadorProtocolo
  else
		i = 1
  end

  local host, porta, path = "", "", ""

  local j = string.find(url, "/", i)

  if j then
     host = string.sub(url, i, j-1)
     path  = string.sub(url, j, #url)
  else
     host = string.sub(url, i)
  end

  i = string.find(host, ":")
  if i then
    porta = string.sub(host, i+1, #host)
    host = string.sub(host, 1, i-1)
  end

  return protocolo, host, porta, path
end

