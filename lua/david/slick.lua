-- A module to make working with vim.api a bit easier.
local slick = {}

function slick.error(msg)
    return vim.fn["david#error"](msg)
end

-- Run input normal command and also replace termcodes.
--
-- Goal: Always do what I expect. Replaces termcodes to simplify conversion
    -- from typing to scripting.
function slick.normal(cmd)
    -- TODO: In cases where we don't want < replaced, maybe we should be able to escape it with %
    local t = {
        args = {
            vim.api.nvim_replace_termcodes(cmd, true, true, true),
        },
        bang = true,
    }
    return vim.cmd.normal(t)
end

return slick
