mutable struct Todo
    Prefix::String
    Suffix::String
    Filename::String
    Body::String
    Line::Int64
    ID::Int64

    Todo() = new("", "", "", "", -1, -1) # empty initializer
    Todo(pre, suf, fn, body, ln, id) = new(pre, suf, fn, body, ln, id)
    Todo(body) = new("", "", "", body, -1, -1) # initialize only body

end

function Base.:isempty(t::Todo)
    flag = false
    for i in 1:4
        if isempty(getfield(t, i)) && !flag
            flag = true
            break
        end
    end # for

    return flag
end
