using Serialization

using TodoGrabber
export get_filenames, find_todos, write_todos, save_dict, grab_dir


function get_filenames(fpath::String)
    files = String[]
    for f in readdir(abspath(fpath), join=true)
        push!(files, f)
    end
    return files
end


function find_todos(target_files::Vector{String})
    todo_dict = Dict{String,Vector{String}}()
    for filename in target_files
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
        if isempty(captures) # only push todos when they exist
            continue
        end
        todo_dict[filename] = captures
    end
    if isempty(todo_dict)
        return nothing
    end
    return todo_dict
end

function write_todos(targetfile::String,
                     tododict::Union{Dict{String,Vector{String}}, Nothing})
    if tododict == nothing
        printstyled(stderr, "No todos found", color = :red)
        return nothing
    end
    open(targetfile, "a") do tfile
        for (fname, todo_vec) in tododict
            write(tfile, string("* ", fname, "\n"))
            for (i,todo) in enumerate(todo_vec)
                write(tfile, string("** [[TODO]] ", i," ", todo, "\n"))
            end
        end
    end

    return nothing
end


function save_dict(targetfile::String, tododict::Dict{String,Vector{String}})
    serialize(targetfile, tododict)
end


function grab_dir(directory::String; target_file::String="")
    filenames = get_filenames(directory)
    todos = find_todos(filenames)
    if isempty(target_file)
        printstyled(stderr, "No output file given. Writing on temp_stack.org",
                    color = :yellow)
        write_todos("temp_stack.org", todos)
    else
        write_todos(target_file, todos)
    end
end
