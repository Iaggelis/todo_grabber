export get_filenames, find_todos, write_todos

function get_filenames(fpath::String)
    files = String[]
    for f in readdir(abspath(fpath), join=true)
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

function write_todos(filenames::Vector{String}, filename::String,
                     todo_array::Array{String,1})
    open(filename, "a") do file
        for fname in filenames
            write(file, string("* ", fname, "\n"))
            for todo in todo_array
                write(file, string("** [[TODO]] ", todo, "\n"))
            end
        end
    end

    return nothing
end


