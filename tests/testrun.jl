using TodoGrabber

function main()
    filenames = TodoGrabber.get_filenames("./tests")
    println("The filenames are:", filenames)
    todo_vec = String[]
    # TODO: hide this in find_todos return a dictionary
    for file in filenames
        todos = TodoGrabber.find_todos(file)
        for todo in todos
            push!(todo_vec,todo)
        end
    end
    println(filenames)
    TodoGrabber.write_todos(filenames, "./tests/todostack.org", todo_vec)
end

main()
