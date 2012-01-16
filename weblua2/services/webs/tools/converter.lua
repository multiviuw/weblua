module ('services.webs.tools.converter', package.seeall)
require "services.webs.tools.LuaXML.xml"
require "services.webs.tools.LuaXML.handler"
local json = require("services.webs.tools.json4lua.json")


function xml_to_table(data)
    local xmlhandler = simpleTreeHandler()
    local xmlparser = xmlParser(xmlhandler)
    xmlparser:parse(data)
    return xmlhandler
end

function soap_xml_to_table(data)
    local xmlhandler = simpleTreeHandler()
    local xmlparser = xmlParser(xmlhandler)
    xmlparser:parse(data, false)
    local xmlTable = {}

    nsPrefix = ""
    if xmlhandler and xmlhandler.root then
        if xmlhandler.root[nsPrefix.."Envelope"] == nil then
            local prefixes = {"soap:", "SOAP-ENV:", "soapenv:", "S:", "senv:"}
            for k, v in pairs(prefixes) do
                if xmlhandler.root[v.."Envelope"] ~= nil then
                    nsPrefix = v
                    break
                end
            end
        end
        print("\n\nResponse nsPrefix = "..nsPrefix.."\n\n")


        local envelope = nsPrefix.."Envelope"
        local bodytag = nsPrefix.."Body"

        --local operationResp = msgTable.operationName.."Response"
        xmlTable = xmlhandler.root[envelope][bodytag]

        for k, v in pairs(xmlTable) do
          xmlTable = v
          break
        end
    end


    xmlTable = removeSchema(xmlTable)
    return xmlTable
    --xmlTable = util.simplifyTable(xmlTable)
end

function json_to_table(data)
    return json.decode(data)
end

function table_to_json(table)
    return json.encode(table)
end

function table_to_rest_request(table, format)
    if format == 'xml' then
        return table_to_rest_xml_request(table)
    elseif format == 'json' then
        return table_to_rest_json_request(table)
    end
    return nil
end

---Remove qualquer elemento que represente informações
--de definições de tipo da tabela, pois somente
--os dados é que interessam.
--@param xmlTable Table lua gerada a partir de código XML
--@return Retorna a nova tabela sem as chaves de schema
function removeSchema(xmlTable)
     --Se xmlTable não for uma tabela, é porque
     --o resultado retornado pelo WS é simples
     --(como uma string que já foi extraída do XML de retorno).
     --Assim, não sendo uma tabela, não existem dados de XML Schema
     --anexados ao valor retornado (pois para isso a estrutura
     --precisaria ser composta, ou seja, ser uma tabela para
     --armazenar o valor retornado e o XML Schema).
     if type(xmlTable) ~= "table" then
        return xmlTable
     end

     local tmp = {}
     for k, v in pairs(xmlTable) do
        if type(v) == "table" then
           v = removeSchema(v)
        end

        if k ~= "xs:schema" then
           tmp[k] = v
        end
     end
     return tmp
end
