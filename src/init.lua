require('utils');
require('api');
require('ui');

function main()
    while not isSampAvailable() do wait(0) end
    API:loadModelsList();
    wait(-1);
end