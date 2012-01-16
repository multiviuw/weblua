module ('services.webs.tools.util', package.seeall)

---Clona uma tabela
--@param tb Tabela ser clonada
--@return Retorna a nova tabela
function cloneTable(tb)
  local result = {}
  for k, v in pairs(tb) do
    result[k] = v
  end
  return result
end

---Imprime uma tabela, de forma recursiva
--@param tb A tabela a ser impressa
--@param level Apenas usado internamente para
--imprimir espacos para representar os niveis
--dentro da tabela.
function printable(tb, level)
  level = level or 1
  local spaces = string.rep(' ', level*2)
  for k,v in pairs(tb) do
      if type(v) ~= "table" then
		print(type(v))
         print(spaces .. k..'='..v)
      else
         print(spaces .. k)
         level = level + 1
         printable(v, level)
      end
  end
end

---Quebra uma string para que a mesma tenha linhas
--com um comprimento maximo definido, nao quebrando
--a mesma no meio das palavras.
--@param Text String a ser quebrada
--@param maxLineSize Quantidade maxima de caracteres por linha
--@return Retorna uma tabela onde cada item e uma linha
--da string quebrada.
function breakString(text, maxLineSize)
  local t = {}
  local str = text
  local i, fim, countLns = 1, 0, 0

  if (str == nil) or (str == "") then
     return t
  end

  str = string.gsub(str, "\n", " ")
  str = string.gsub(str, "\r", " ")

  while i <= #str do
     countLns = countLns + 1
     if i > #str then
        t[countLns] = str
     else
        fim = i+maxLineSize-1
        if fim > #str then
           fim = #str
        else
	        if string.byte(str, fim) ~= 32 then
	           fim = string.find(str, ' ', fim)
	           if fim == nil then
	              fim = #str
	           end
	        end
        end
        t[countLns]=string.sub(str, i, fim)
        i=fim+1
     end
  end

  return t
end


---Imprime um texto na tela, quebrando o mesmo nos limites
--horizontais da area do canvas principal.
--@param areaWidth Largura da area disponivel para impressao
--@parma x Posica�o x onde o texto deve ser impresso
--@param initialY Posição y inicial a ser impresso o texto
--@param text Texto a ser impresso, sendo quebrado em
--linhas para caber horizontalmente na largura
--definida para impressao
--@param canv canvas onde sera desenhado o texto.
function paintBreakedString(areaWidth, x, initialY, text, canv)
	canv = canv or canvas;
     --Text Width e Text Height de um caractere minusculo
     local tw, th = canv:measureText("a")

     --Estima quantos caracteres cabem dentro da largura
     --definida para a exibição de uma mensagem do Twitter
     local charsByLine = tonumber(string.format("%d", areaWidth / tw))

     --Quebra o texto em diversas linhas,
     --gerando uma tabela onde cada item é uma linha que
     --foi quebrada. Isto é usado para que o texto seja
     --exibido sem sair da tela.
     local textTable = breakString(text, charsByLine)
     local y = initialY
     --Percorre a tabela gerada a partir da quebra do texto
     --em linhas, e imprime cada linha na tela
     for k,ln in pairs(textTable) do
         canv:drawText(x, y, ln)
         y = y + th
         --print("---------------------"..ln)
     end
end

---Desenha um texto na tela
--@param x Posição horizontal a ser impresso o texto
--@param y Posição vertical a ser impresso o texto
--@param text texto a ser desenhado
--@param fontName Nome da fonte a ser utilizada para imprimir o texto. Opcional
--@param fontSize Tamanho da fonte. Opcional
--@param fontColor Cor da fonte. Opcional
--@param canv canvas onde sera desenhado o texto.
function paintText(x, y, text, fontName, fontSize, fontColor, canv)
	canv = canv or canvas;
     if fontName and fontSize then
        canv:attrFont(fontName, fontSize)
     end
     if fontColor then
        canv:attrColor(fontColor)
     end

     --width e height do canvas
     local cw, ch = canvas:attrSize()
     canv:drawText(x, y, text)
end


---Função para converter uma tabela para o formato URL-Encode,
--também chamado de Percent Encode, segundo RFC 3986.
--Fonte: http://www.lua.org/pil/20.3.html. Gerada a partir das funções
--escape e encode, gerando uma só.
--@param t Tabela contendo os pares param=value
--que representam os parâmetros a serem codificados para o formato URL-Encode,
--ou String contendo o texto a ser codificado.
--@return Retorna uma string codificada em URL-Encode
function urlEncode(t)
	  local function escape (s)
	    s = string.gsub(s, "([&=+%c])", function (c)
	          return string.format("%%%02X", string.byte(c))
	        end)
	    s = string.gsub(s, " ", "+")
 	    return s
 	  end

      if type(t) == "string" then
         return escape(t)
      else
	     local s = ""
	     for k,v in pairs(t) do
	       s = s .. "&" .. escape(k) .. "=" .. escape(v)
	     end
	     return string.sub(s, 2)     -- remove first `&'
      end
end

--Conta o total de elementos em uma tabela indexada com chaves string,
--pois o operador # não funciona para obter o total de elementos de tais tabelas.
--@param Tabela a ser contato o total de elementos
--@return Retorna o total de elementos da tabela
function count(tb)
   local i = 0
   for k, v in pairs(tb) do
      i = i + 1
   end
   return i
end

---Verifica se uma tabela contem apenas um elemento
--@param tb Tabela ser verificada
--@return Retorna true caso a tabela contenha apenas um elemento.
function hasSingleElement(tb)
   --Para tabelas mais complexas, geradas a partir de um XML este código não funciona,
   --congelando a aplicação.
   --local k=next(tb)
   --return k~=nil and next(tb,k)==nil

    local i = 0
    for k, v in pairs(tb) do
        i = i + 1
        if i > 1 then
           return false
        end
    end

    return i == 1
end

--Obtem o primeiro elemento de uma tabela
--@param Tabela de onde devera ser obtido o primeiro elemento
--@return Retorna o primeiro elemento da tabela
function getFirstElement(tb)
   if type(tb) == "table" then
       --O uso da função next não funciona para pegar o primeiro elemento. Trava aqui
      --k, v = next(tb)
      --return v
      for k, v in pairs(tb) do
          return v
      end
   else
     return tb
   end
end

--Obtem a primeira chave de uma tabela
--@param Tabela de onde devera ser obtido o primeiro elemento
--@return Retorna a primeira chave da tabela
function getFirstKey(tb)
   if type(tb) == "table" then
		--O uso da funcao next não funciona para pegar o primeiro elemento. Trava aqui
      --k, v = next(tb)
      --return k
      for k, v in pairs(tb) do
          return k
      end
      return nil
   else
     return tb
   end
end

---Percorre uma tabela recursivamente. Se ela contém apenas um elemento,
--a tabela a qual ele pertence (a externa) é eliminada, ficando apenas a tabela interna,
--passando esta a ser a tabela principal. Repete isto até chegar no item mais interno da tabela.
--Assim, uma tabela como nivel1 = { nivel2 = nivel3 = {desc = "mouse", valor = 99}}
--se transforma em {desc="mouse", valor = 99}
--Outra tabela como nivel1 = { nivel2 = nivel3 = {pais = "Brasil"}}
--se transforma em pais = "Brasil", sem nenhuma tabela.
--@param tb Table lua gerada a partir de código XML
--@return Retorna a nova tabela simplificada. Se dentro de toda a estrutura
--da tabela original só existia um campo com valor, tal valor é retornado
--como uma variável simples.
function simplifyTable(tb)
   local tmp = tb
   while type(tmp) == "table" and hasSingleElement(tmp) do
      tmp = getFirstElement(tmp)
   end
   return tmp
end

---Cria uma co-rotina para execução de uma determinada função.
--@param f Função body a ser executada pela co-rotina
--@param ... Parâmetros adicionais que serão passados à função
--body da co-rotina, passada no parâmetro f.
function coroutineCreate(f, ...)
    coroutine.resume(coroutine.create(f), ...)
end

---Obtem o nome de um arquivo a partir de sua URL,
--seja esta um endereço na web ou um caminho de diretório local
--@param string url URL de onde obter o nome do arquivo
--@return string Retorna somente o nome do arquivo obtido da URL.
function getFileName(url)
  url = string.reverse(url)
  local i = string.find(url, "/")
  if i then
    url = string.sub(url, 1, i-1)
    url = string.reverse(url)
    return url
  else
    return ""
  end
end

---Quebra uma string em uma tabela (vetor) de strings.
--http://lua-users.org/wiki/SplitJoin
--@param string s String a ser dividida
--@param string sep Separador contido na string s que será usado para quebrá-la
--em várias strings
--@return table Tabela (vetor) contendo as strings quebradas a partir de s
function split(s, sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    s:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end
