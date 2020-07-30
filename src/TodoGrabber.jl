module TodoGrabber

include("Todo.jl")
include("grabber.jl");
include("storingdb.jl")

function todo_db(directory::String)
    filenames = get_filenames("./tests")
    todos = find_todos(filenames)
    storetodos(todos)
end # todo_db

end # module
