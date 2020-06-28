export get_filenames, find_todos, write_todos

function get_filenames()
    files = String[]
    for f in readdir(abspath("./tests/"), join=true)
        if f == "todo_grabber.jl"
            continue
        end
        push!(files, f)
    end
    return files
end


function find_todos(filename::String)
    captures = String[]
    open(filename) do file
        for line in eachline(file)
            m = match(r"^(.*)TODO: (.*)$", line)
            if m !== nothing
                cleaned_capture = strip(m.captures[2], ['-','*','>',' ', '/'])
                push!(captures, cleaned_capture)
            end
        end
    end
    return captures
end

function write_todos(filename::String, todo_array::Array{String,1})
    open("/tmp/todostack.org", "a") do file
        write(file, string("* ", filename, "\n"))
        for todo in todo_array
            write(file, string("** [[TODO]] ", todo, "\n"))
        end
    end

    return nothing
end



