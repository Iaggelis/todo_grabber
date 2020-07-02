using TodoGrabber

function main()
    filenames = TodoGrabber.get_filenames("./tests")
    println("The filenames are:", filenames)

    println("-------------------")
    todos = TodoGrabber.find_todos(filenames);
    # TodoGrabber.write_todos(filenames, "./tests/todostack.org", todo_vec)
end

main();
