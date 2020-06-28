using TodoGrabber

function main()
    filenames = TodoGrabber.get_filenames()
    println("The filenames are:", filenames)
    println("DBG: These are the whole lines that match the regex")
    for file in filenames
        todos = TodoGrabber.find_todos(file)
        TodoGrabber.write_todos(file, todos)
        for todo in todos
            println(todo)
        end
    end
end
