using SQLite, Tables, Printf


export storetodos


function storetodos(tododict::Union{Nothing, Dict{String, Vector{Todo}}};
                    filename::String="todo_cache.db")

    if tododict === nothing
        println(stdout, "No todos found.")
        exit()
    end
    # TODO: this writes again the previous todos
    db = SQLite.DB()
    db = DBInterface.connect(SQLite.DB, filename)
    for (fname, todo_vec) in tododict
        fname = replace(fname, "." => "_")
        last_separator = findlast("/", fname)
        temp_fname = chop(fname, head=last_separator[1], tail=0)
        execute_string = @sprintf "CREATE TABLE IF NOT EXISTS %s (
                             id INTEGER,
                             pre TEXT,
                             suf TEXT,
                             line INTEGER,
                             body TEXT)" temp_fname
        # println(execute_string)
        DBInterface.execute(db, execute_string)
        prepare_string = @sprintf "INSERT INTO %s VALUES(?,?,?,?,?)" temp_fname
        q = DBInterface.prepare(db, prepare_string)
        for todo in todo_vec
            SQLite.execute(q, (todo.ID, todo.Prefix, todo.Suffix, todo.Line,
                               todo.Body,))
        end
    end

    DBInterface.close!(db)

end
