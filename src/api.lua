API_STATUS = {
    NONE = 0,
    LOADING_MODELS_LIST = 1,
    READY = 2,
    ERROR = 3
};

---@class API.Model
---@field name string
---@field type string
---@field modality string
---@field paid boolean
---@field can-stream boolean
---@field status string

API_GENERATION_STATUS = {
    NONE = 0,
    SENT = 1
};

API = {
    ---@type table<string, API.Model>
    models = {},
    status = API_STATUS.NONE,
    error = nil,
    generation = {
        status = API_GENERATION_STATUS.NONE,
        error = nil,
        response = nil,
    },
    lastPrompt = ''
};

local PATH_MODELS = 'https://api.onlysq.ru/ai/models';
local PATH_GENERATE = 'http://api.onlysq.ru/ai/v2';

function API:loadModelsList()
    Utils.asyncHttpRequest(
        'GET',
        PATH_MODELS,
        nil,
        function(response)
            if (response.status_code ~= 200) then
                API.status = API_STATUS.ERROR;
                API.error = response.status_code;
                return;
            end
            local status, result = pcall(decodeJson, response.text);
            if (not status or not result.models) then
                API.status = API_STATUS.ERROR;
                API.error = 'JSON Parse failed!';
                return;
            end
            -- API.models = result.models;
            for modelIndex, model in pairs(result.models) do
                if (model.status == 'work' and model.paid == false and model.modality == 'text') then
                    API.models[modelIndex] = model;
                end
            end
            API.status = API_STATUS.READY;
        end,
        function(err)
            API.status = API_STATUS.ERROR;
            API.error = err;
        end
    );
end

function API:isGenerationInProcess()
    return API.generation.status ~= API_GENERATION_STATUS.NONE;
end

function API:generate(model, bio, prompt, resolve, reject)
    API.generation.status = API_GENERATION_STATUS.SENT;
    API.generation.lastPrompt = prompt;
    API.generation.error = nil;
    Utils.asyncHttpRequest(
        'POST',
        PATH_GENERATE,
        {
            data = encodeJson({
                model = model,
                request = {
                    messages = {
                        { role = 'user', content = bio },
                        { role = 'user', content = prompt },
                    },
                }
            })
        },
        function(response)
            for k, v in pairs(response) do print(k, type(v) == 'string' and u8:decode(v) or v) end
            API.generation = {
                response = response,
                status = API_GENERATION_STATUS.NONE,
                error = nil
            };
            if (response.status_code ~= 200) then
                API.generation.error = response.status_code .. ': ' .. response.text;
                reject(API.generation, nil, response.text);
                return;
            end

            local status, result = pcall(decodeJson, response.text);
            if (not status or not result.id) then
                reject(API.generation, nil, 'JSON Parse failed!');
                return;
            end
            math.randomseed(os.time() + os.clock());
            if (not result.choices or #result.choices == 0) then
                API.generation.error = response.status_code .. ': ' .. response.text;
                reject(API.generation, nil, 'No choices!');
                return;
            end
            
            local choiceIndex = math.randomseed(1, #result.choices);
            -- print(choiceIndex)
            -- for k, v in pairs(result.choices) do print('c', k, v) end
            
            local choice = result.choices[1].message.content;
            sampAddChatMessage('ch+' .. type(choice), -1)
            -- for k, v in pairs(choice) do print('c', k, v) end
            if (resolve) then
                resolve(API.generation, response, choice);
            end
            API.generation.status = API_GENERATION_STATUS.NONE;
        end,
        function(err)
            API.generation = {
                response = nil,
                status = API_GENERATION_STATUS.NONE,
                error = err
            };
            if (reject) then
                reject(API.generation, err, nil);
            end
            API.generation.status = API_GENERATION_STATUS.NONE;
        end
    );
end