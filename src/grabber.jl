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

function write_todos(targetfile::String, tododict::Dict{String,Vector{String}})
    open(targetfile, "a") do tfile
        for (fname, todo_vec) in tododict
            write(tfile, string("* ", fname, "\n"))
            for todo in todo_vec
                write(tfile, string("** [[TODO]] ", todo, "\n"))
            end
        end
    end

    return nothing
end



