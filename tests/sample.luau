-- Line comment
--[[ Block comment ]]
--[=[ Level one comment
    ]] does not close this comment
]=]
--[==[ Level two comment
    ]=] does not close this comment
]==]
--[= This is a line comment, not a long comment
local function greet(name: string): string
    local amount = 1.25e+2
    local andrew = 1..2
    local ratio = .5 + 0x1.fp2
    local after_comments = true
    return "hi, \"there\" " .. name
end
print(greet("Luau"))
