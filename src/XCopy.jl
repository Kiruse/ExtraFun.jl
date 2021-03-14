######################################################################
# Extended copying - customizable behavior of copying structures.
# -----
# Licensed under MIT License
export FieldCopyOverride, xcopy, @xcopy, xcopy_override, @xcopy_override

struct FieldCopyOverride{S} end
struct NoOverride end
const nooverride = NoOverride()


"""`xcopy(tpl, kwargs...)`
 
 Extended `Base.copy` method which allows setting a field directly rather than copying it from `tpl`.
 
 See also [`@xcopy`](@ref), [`xcopyargs`](@ref), [`xcopy_override`](@ref), [`xcopy_construct`](@ref).
 
 # Example
 
 ```julia
 struct Foo{A}
    a::A
 end
 
 xcopy(Foo{Int32}(24), a=42) # == Foo{Int32}(42)
 ```
 """
function xcopy(tpl::T; kwargs...) where T
    fnames  = fieldnames(T)
    fvalues = Dict{Symbol, Any}()
    
    for fname ∈ fnames
        fvalues[fname] = haskey(kwargs, fname) ? kwargs[fname] : xcopy_override(tpl, FieldCopyOverride{fname}())
    end
    
    unknown = setdiff(keys(kwargs), fnames)
    if !isempty(unknown)
        throw(DomainError(unknown, "Unknown fields"))
    end
    
    xcopy_construct(tpl, (fvalues[fname] for fname ∈ fnames)...)
end
"""`@xcopy(T)`

 Convenience macro to define `Base.copy(tpl::T; kwargs...) = xcopy(tpl, kwargs...)`
 
 See [`xcopy`](@ref), [`xcopyargs`](@ref), [`xcopy_override`](@ref)"""
macro xcopy(T)
    esc(:(Base.copy(tpl::$T; kwargs...) = ExtraFun.xcopy(tpl; kwargs...)))
end

"""`xcopyargs(ArgsT::Type, tpl; kwargs...)`
 
 Like `xcopy`, except `kwargs` must match fields of `ArgsT`. A copy of `tpl` will then be created like such: `typeof(tpl)(argsobj)`
 where `argsobj::ArgsT` is constructed through `tpl` and `kwargs`.
 
 By default, the algorithm will attempt to retrieve an equally named field from `tpl` to construct `argsobj` with. This
 behavior can be overridden with [`xcopy_override`](@ref).
 
 See also [`xcopy`](@ref), [`xcopy_override`](@ref), [`@xcopyoverride`](@ref), [`xcopy_construct`](@ref)"""
function xcopyargs(ArgsT::Type, tpl::T; kwargs...) where T
    fnames  = fieldnames(ArgsT)
    fvalues = Dict{Symbol, Any}((fname => xcopy_override(tpl, FieldCopyOverride{fname}()) for fname ∈ fnames))
    
    for (fname, fvalue) ∈ kwargs
        @assert fname ∈ fnames "Unknown field `$fname`"
        fvalues[fname] = fvalue
    end
    
    xcopy_construct(tpl, ArgsT((fvalues[fname] for fname ∈ fnames)...))
end
"""`@xcopyargs(T, A)`
 
 Convenience macro to define `Base.copy(tpl::T; kwargs...) = xcopyargs(A, tpl, kwargs...)`
 
 See [`xcopy`](@ref), [`xcopyargs`](@ref), [`xcopy_override`](@ref)"""
macro xcopyargs(T, A)
    esc(:(Base.copy(tpl::$T; kwargs...) = ExtraFun.xcopyargs(A, tpl; kwargs...)))
end

"""`xcopy_override(tpl, ::FieldCopyOverride{S}) where S`
 
 Defines the copied value of field `S` in `tpl`. Defaults to `Base.copy(getproperty(tpl, S))`.
 
 See also [`xcopy`](@ref).
 
 # Example
 
 ```julia
 struct Foo
    value::Int
 end
 
 struct Bar
    foo::Foo
 end
 
 xcopy_override(bar::Bar, ::FieldCopyOverride{:foo}) = Foo(bar.foo.value + 1)
 xcopy(Bar(Foo(24))) # == Bar(Foo(25))
 """
xcopy_override(tpl, ::FieldCopyOverride{S}) where S = (value = getproperty(tpl, S); hassignature(copy, typeof(value)) ? copy(value) : value)
"""`@xcopyoverride(T, S, expr)`
 
 Convenience macro to define `xcopy_override(tpl::T, ::FieldCopyOverride{S}) = expr`.
 
 See [`xcopy`](@ref), [`xcopy_override`](@ref)
 
 # Example
 
 ```julia
 struct Foo
    value::Int
 end
 
 @xcopy Foo
 @xcopyoverride Foo :value tpl.value / 2
 ```
 """
macro xcopy_override(T, S, expr)
    if !(S isa QuoteNode && S.value isa Symbol) && !(S isa Symbol)
        error("Invalid property: must be either a symbol or a quote node")
    end
    if S isa Symbol
        S = QuoteNode(S)
    end
    esc(:(ExtraFun.xcopy_override(tpl::$T, ::ExtraFun.FieldCopyOverride{$S}) = $expr))
end

"""`xcopy_construct(tpl, args...; kwargs...)`
 
 Constructs the actual copy. Useful for running additional initialization code or to add additional constructor arguments.
 
 # Example
 
 ```julia
 struct Foo{T<:Real}
    value::T
    deduced::Float64
 end
 Foo(value::Real) = Foo(value, value / 2)
 
 xcopy_construct(tpl::Foo, args...) = Foo(args[1], args[2]/2)
 xcopy(Foo(24)) # == Foo(24, 12.0)
 ```
 """
xcopy_construct(tpl::T, args...; kwargs...) where T = T(args...; kwargs...)