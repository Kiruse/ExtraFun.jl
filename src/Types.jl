######################################################################
# General purpose patterns realized through abstract types & structs
# -----
# Licensed under MIT License

export Ident
struct Ident{S} end

export Mutable
mutable struct Mutable{T}
    value::T
end

Base.getindex(mutable::Mutable) = mutable.value
Base.setindex!(mutable::Mutable{T}, value::T) where T = mutable.value = value
Base.:(==)(lhs::Mutable{T}, rhs::Mutable{T}) where T = lhs.value == rhs.value

export Unknown, unknown
struct Unknown end
const unknown = Unknown()

export Optional
mutable struct Optional{S, T}
    value::Union{T, Unknown}
    Optional{S, T}(value) where {S, T} = new(convert(T, value))
    Optional{S, T}(::Unknown) where {S, T} = new(unknown)
    Optional{S, T}(value::T) where {S, T} = new(value)
end
Optional{S, T}() where {S, T} = Optional{S, T}(unknown)
Optional{S}(value::T) where {S, T} = Optional{S, T}(value)
Optional{S}(::Unknown) where S = Optional{S, Any}(unknown)
Optional{S}() where S = Optional{S}(unknown)
Optional(S::Symbol, value::T) where T = Optional{S, T}(value)
Optional(value::T) where T = Optional{:generic, T}(value)
Optional(::Unknown) = Optional{:generic, Any}(unknown)
Optional() = Optional(unknown)

Base.getindex(opt::Optional) = opt.value
Base.setindex!(opt::Optional, value) = opt.value = value

Base.convert(::Type{Optional{S}}, value) where S = Optional{S}(value)
Base.convert(::Type{Optional{S}}, opt::Optional) where S = (println("convert $(opt.value)"); Optional{S}(opt.value))
Base.convert(::Type{Optional{S, T}}, value) where {S, T} = Optional{S, T}(value)
Base.convert(::Type{Optional{S, T}}, opt::Optional) where {S, T} = Optional{S, T}(opt.value)

Base.convert(::Type{Optional{S} where S}, value) = Optional{:generic}(value)
Base.convert(::Type{Optional{S, T} where S}, value) where T = Optional{:generic, T}(value)
Base.convert(::Type{Optional{S} where S}, opt::Optional) = opt
Base.convert(::Type{Optional{S1, T} where S1}, opt::Optional{S2, T} where S2) where T = opt
Base.convert(::Type{Optional{S1, T} where S1}, opt::Optional{S2}) where {S2, T} = Optional{S2, T}(opt.value)


export Dirty, markdirty!, isdirty
mutable struct Dirty{T}
    value::T
    dirty::Bool
end
Dirty(value) = Dirty(value, false)

Base.getindex(dirty::Dirty) = dirty.value
Base.setindex!(dirty::Dirty, value) = (markdirty!(dirty); dirty.value = value)
markdirty!(dirty::Dirty) = dirty.dirty = true
isdirty(dirty::Dirty) = dirty.dirty
clear(dirty::Dirty) = dirty.dirty = false
