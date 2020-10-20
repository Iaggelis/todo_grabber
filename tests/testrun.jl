using TodoGrabber

function main()
    filenames = TodoGrabber.get_filenames("./tests")
    println("The filenames are:", filenames)

    todos = TodoGrabber.find_todos(filenames)
    TodoGrabber.write_todos(todos, "./tests/todostack.org")
    TodoGrabber.save_dict(todos, "serial.bin")
end

function maindb()
    if isfile("todo_cache.db")
        rm("todo_cache.db")
    end
    filenames = TodoGrabber.get_filenames("./tests")
    todos = TodoGrabber.find_todos(filenames)
    storetodos(todos)
end
