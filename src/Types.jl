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