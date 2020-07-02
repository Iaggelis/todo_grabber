using TodoGrabber

function main()
    filenames = TodoGrabber.get_filenames("./tests")
    println("The filenames are:", filenames)

    todos = TodoGrabber.find_todos(filenames)
    # println("-------------------")
    # println(todos)
    TodoGrabber.write_todos("./tests/todostack.org", todos)
end;

main()
