Utils = {};
local CPopulation__IsMale = ffi.cast('bool(__cdecl *)(int)', 0x611470);
function Utils.isModelMale(modelId)
   return CPopulation__IsMale(modelId);
end

local effil = require 'effil' -- В начало скрипта
function Utils.bringFloatTo(from, to, start_time, duration)
   local timer = os.clock() - start_time
   if timer >= 0.00 and timer <= duration then
       local count = timer / (duration / 100)
       return from + (count * (to - from) / 100), true
   end
   return (timer > duration) and to or from, false
end

function Utils.myid()
   return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED));
end

---@param path string directory
---@param ftype string|string[] file extension
---@return string[] files names
function Utils.getFilesInPath(path, ftype)
    assert(path, '"path" is required');
    assert(type(ftype) == 'table' or type(ftype) == 'string', '"ftype" must be a string or array of strings');
    local result = {};
    for _, thisType in ipairs(type(ftype) == 'table' and ftype or { ftype }) do
        local searchHandle, file = findFirstFile(path.."/"..thisType);
        table.insert(result, file)
        while file do file = findNextFile(searchHandle) table.insert(result, file) end
    end
    return result;
end

function Utils.asyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = effil.thread(function (method, url, args)
      local requests = require 'requests'
      local result, response = pcall(requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)
   -- Если запрос без функций обработки ответа и ошибок.
   if not resolve then resolve = function() end end
   if not reject then reject = function() end end
   -- Проверка выполнения потока
   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end