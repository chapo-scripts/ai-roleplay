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
        result = nil,
        lastPrompt = ''
    }
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
            for modelIndex, model in pairs(result.models) do
                if (model.status == 'work' and model.modality == 'text') then
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
    if (not API.models[model]) then
        reject('MODEL_NOT_CHOOSEN');
    end
    API.generation.status = API_GENERATION_STATUS.SENT;
    API.generation.lastPrompt = prompt;
    API.generation.error, API.generation.result = nil, nil;
    local body = encodeJson({
        model = model,
        request = {
            messages = {
                { role = 'user', content = TextFlags:replace(bio) },
                { role = 'user', content = prompt },
            },
        }
    });
    print('Sent:', body);
    Utils.asyncHttpRequest(
        'POST',
        PATH_GENERATE,
        {
            data = body
        },
        function(response)
            for k, v in pairs(response) do
                print('RESPONSE', k, v);
            end
            API.generation.status = API_GENERATION_STATUS.NONE;
            if (response.status_code ~= 200) then
                API.generation.error = ('HTTP_%d: %s'):format(response.status_code, response.text);
                return resolve();
            end
            local status, result = pcall(decodeJson, response.text);
            if (not status or not result.id) then
                API.generation.error = 'JSON_ERROR: ' .. response.text;
                return resolve();
            end
            math.randomseed(os.time() + os.clock());
            if (not result.choices or #result.choices == 0) then
                API.generation.error = 'NO_CHOICES: ' .. response.text;
                return resolve();
            end
            API.generation.result = result.choices[1].message.content;
            return resolve();
        end,
        function(err)
            API.generation.status = API_GENERATION_STATUS.NONE;
            API.generation.error = tostring(err);
            return resolve();
        end
    );
end
