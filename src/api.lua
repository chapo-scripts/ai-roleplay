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

API = {
    ---@type table<string, API.Model>
    models = {},
    status = API_STATUS.NONE,
    error = nil
};

local PATH_MODELS = 'https://api.onlysq.ru/ai/models';

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
            API.models = result.models;
            -- for modelIndex, model in ipairs(API.models) do
            --     if (model.status == 'work' and model.paid == false and model.modality == 'text') then
            --         local provider = model:match('(%w+)');
            --         if (not API.modelsFiltred[provider]) then
            --             API.modelsFiltred[provider] = {}
            --         end
            --         table.insert(API.modelsFiltred[provider], model);
            --     end
            -- end
            API.status = API_STATUS.READY;
        end,
        function(err)
            API.status = API_STATUS.ERROR;
            API.error = err;
        end
    );
end