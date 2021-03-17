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
