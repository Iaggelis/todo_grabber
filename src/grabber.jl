using Serialization

using TodoGrabber

export get_filenames, find_todos, write_todos, save_dict, grab_dir

const cachefile = "./tests/serial_cache.bin"

function get_filenames(fpath::String)
    files = String[]
    for f in readdir(abspath(fpath), join=true)
        push!(files, f)
    end
    return files
end


function find_todos(target_files::Vector{String})
    if isfile(cachefile)
        todo_dict = deserialize(cachefile)
    else
        todo_dict = Dict{String,Vector{String}}()
    end
    for filename in target_files
        captures = String[]
        open(filename) do file
            for line in eachline(file)
                m = match(r"^(.*)TODO: (.*)$", line)
                if m !== nothing
                    cleaned_capture = strip(m.captures[2], ['-','*','>',' ', '/'])
                    if !haskey(todo_dict, filename) ||
                        isempty(findall(x->x==cleaned_capture,
                                        getindex(todo_dict, filename)))
                        push!(captures, cleaned_capture)
                    end
                end # regex if
            end # line loop
        end # file loop
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
    open(targetfile, "w") do tfile
        for (fname, todo_vec) in tododict
            write(tfile, string("* ", fname, "\n"))
            for (i,todo) in enumerate(todo_vec)
                write(tfile, string("** [[TODO]] ", i," ", todo, "\n"))
            end
        end
    end

    return nothing
end

function save_dict(tododict::Dict{String,Vector{String}}; targetfile::String="")
    if isempty(targetfile)
        serialize(cachefile, tododict)
    else
        serialize(targetfile, tododict)
    end
end


function grab_dir(directory::String; target_file::String="")
    filenames = get_filenames(directory)
    todos = find_todos(filenames)
    save_dict(todos)
    if isempty(target_file)
        printstyled(stderr, "No output file given. Writing on temp_stack.org",
                    color = :yellow)
        write_todos("./tests/temp_stack.org", todos)
    else
        println(stdout, "Writing on $target_file")
        write_todos(target_file, todos)
    end
end
