######################################################################
# Functions that are less imperative and more functional. These
# functions do a bit of smart magic in order to accomplish a given task.
# -----
# Licensed under MIT License

export negate
negate(x) = (args...; kwargs...) -> !x(args...; kwargs...)

export isathing
const isathing = negate(isnothing)

export truthy, falsy
truthy(::Nothing) = false
truthy(b::Bool)   = b
truthy(n::Number) = n != 0
truthy(_) = true
const falsy = negate(truthy)

function Base.split(cond, arr::AbstractArray)
    atrue  = []
    afalse = []
    for item ∈ arr
        if cond(item)
            push!(atrue, item)
        else
            push!(afalse, item)
        end
    end
    atrue, afalse
end
Base.split(cond, tpl::Tuple) = filter(item->cond(item), tpl), filter(item->!cond(item), tpl)

"""`insert!(arr::Vector{T}, elem::T; before = nothing, after = nothing, strict::Bool = false)`
 
 Insert `elem` into `arr` either immediately before `before` or immediately after `after`. Specifying both keyword
 arguments `before` and `after` as well as neither is illegal - exactly one must be specified. The specified relative
 element must exist in the array.
 
 If `strict` is false, simple equality (==) is used, otherwise strict equality (===)."""
function Base.insert!(arr::Vector{T}, elem::T; before = nothing, after = nothing, by = identity, strict::Bool = false) where T
    if before === nothing && after === nothing
        throw(ArgumentError("Neither `before` nor `after` specified"))
    elseif before !== nothing && after !== nothing
        throw(ArgumentError("Both `before` and `after` specified"))
    end
    
    idx = if before !== nothing
        indexof(arr, before; by=by, strict=strict)
    else
        idx = indexof(arr, after; by=by, strict=strict)
        idx === nothing ? nothing : idx+1
    end
    
    if idx === nothing
        ArgumentError("Relative element not found")
    end
    insert!(arr, idx, elem)
end

export indexed
abstract type Indexability end
struct Indexed <: Indexability end
struct Collectible <: Indexability end
struct Singular <: Indexability end
@generated function indexability(x)
    if hassignature(getindex, x, Integer) && hassignature(length, x) && hassignature(firstindex, x) && hassignature(lastindex, x)
        :(Indexed())
    elseif hassignature(iterate, x)
        :(Collectible())
    else
        :(Singular())
    end
end
indexed(v) = indexed(indexability(v), v)
indexed(::Indexed, v) = v
indexed(::Collectible, v) = collect(v)
indexed(::Singular, x) = (x,)

export iterable
abstract type Iterability end
struct Iterable <: Iterability end
struct NonIterable <: Iterability end
@generated function iterability(x)
    if hassignature(iterate, x)
        :(Iterable())
    else
        :(NonIterable())
    end
end
"""`iterable(x)`
If `x` is iterable (i.e. `iterate(x)` exists), return `x`. Otherwise, return an iterable container around `x`, e.g.
`tuple(x)`. The result of this function will always be iterable."""
iterable(x) = iterable(iterability(x), x)
iterable(::Iterable, x) = x
iterable(::NonIterable, x) = (x,)
