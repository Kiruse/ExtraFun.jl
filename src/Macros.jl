######################################################################
# General purpose macros
# -----
# Licensed under MIT License

export @await
macro await(exprs...)
    esc(:(fetch(@sync @async begin; $(exprs...); end)))
end

export @sym_str
macro sym_str(str)
    esc(:(Symbol($str)))
end

# Like curry, but applies it to all first-level method calls in a block.
export @curry
"""`@curry exprs...`
 
 Injects `exprs` as the first arguments in every first-level method calls of the last argument. Like [`curry`](@ref),
 but does not generate an anonymous method instance that can be passed to other methods.
 
 # Example
 
 ```julia
 logid = 42
 @curry "Log " logid ": " begin
    println(420)
    println(69)
 end
 # prints "Log 42: 420"
 # prints "Log 42: 69"
 ```
 """
macro curry(curry...)
    if length(curry) < 2
        throw(ArgumentError("no curry-expressions"))
    end
    
    curry = collect(curry)
    exec = pop!(curry)
    
    posargs, kwargs = curry_splitargs(curry)
    
    if exec isa Expr
        if exec.head === :block
            for expr ∈ exec.args
                if expr isa Expr
                    if is_call_expr(expr)
                        curry_call!(expr, posargs, kwargs)
                    elseif is_call_assignment(expr)
                        curry_call!(expr.args[2], posargs, kwargs)
                    end
                end
            end
        elseif is_call_expr(exec)
            curry_call!(exec, posargs, kwargs)
        elseif is_call_assignment(exec)
            curry_call!(exec.args[2], posargs, kwargs)
        end
    end
    
    esc(exec)
end

function curry_splitargs(args)
    posargs = []
    kwargs  = []
    for arg ∈ args
        if curry_iskwarg(arg)
            push!(kwargs, arg)
        else
            push!(posargs, arg)
        end
    end
    posargs, kwargs
end
curry_iskwarg(_) = false
curry_iskwarg(arg::Expr) = (arg.head === :(=)) || (arg.head === :call && arg.args[1] === :(=>))

function curry_call!(call::Expr, pos, kw)
    @assert call.head === :call
    splice!(call.args, 2:1, pos)
    append!(call.args, curry_makekwarg.(kw))
    call
end
function curry_makekwarg(arg::Expr)
    if arg.head === :(=)
        Expr(:kw, arg.args[1], arg.args[2])
    elseif arg.head === :call && arg.args[1] === :(=>)
        Expr(:kw, arg.args[2], arg.args[3])
    else
        throw(ArgumentError("Unknown expression $arg"))
    end
end


export @with
"""`@with resources... block`
 Produces code like:
 ```
 let resources...
    try
        block
    finally
        close.(resources)
    end
 end
 ```
 
 This is useful for resources implementing `Base.close` but no callbacked resource opener.
 """
macro with(exprs::Union{Symbol, Expr}...)
    block = last(exprs)
    assignments = with_assignments(__source__, exprs[1:lastindex(exprs)-1])
    vars = extract_with_varname.(assignments)
    
    closers = Expr(:., :close, Expr(:tuple, Expr(:tuple, vars...)))
    wrap    = Expr(:try, block, false, false, closers)
    esc(Expr(:let, Expr(:block, assignments...), wrap))
end

with_assignments(__source__, exprs) = (with_assignment(__source__, expr, Ref{Int}(0)) for expr in exprs)
function with_assignment(__source__, expr::Expr, counter::Ref{<:Integer})
    if expr.head === :(=)
        expr
    else
        counter[] += 1
        Expr(:(=), Symbol("$(__source__.file):$(__source__.line):$(counter[])"), expr)
    end
end
with_assignment(_, var::Symbol, _) = Expr(:(=), var, var)

function extract_with_varname(expr::Expr)
    @assert expr.head === :(=) "Not an assignment"
    expr.args[1]
end


export @once
macro once(cond::Union{Bool, Expr}, expr)
    label = QuoteNode(Symbol("$(__source__.file):$(__source__.line)"))
    esc(quote
        if $label ∉ ExtraFun.ONCE_CONDITIONS && $cond
            push!(ExtraFun.ONCE_CONDITIONS, $label)
            $expr
        end
    end)
end

const ONCE_CONDITIONS = Set{Symbol}()
