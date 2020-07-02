using TodoGrabber

function main()
    filenames = TodoGrabber.get_filenames("./tests")
    println("The filenames are:", filenames)

    todos = TodoGrabber.find_todos(filenames)
    TodoGrabber.write_todos("./tests/todostack.org", todos)
    TodoGrabber.save_dict("serial.bin", todos)
end

main()
