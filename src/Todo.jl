export Todo

mutable struct Todo
    Prefix::String
    Suffix::String
    Filename::String
    Line::Int64
    Body::String
    ID::Int64

    # Todo(body) = new("", "", "", -1, body, -1) # initialize only body

end
