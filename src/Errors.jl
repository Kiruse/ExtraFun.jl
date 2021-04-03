######################################################################
# Additional errors used in the library.
# -----
# Licensed under MIT License

export TimeoutError
struct TimeoutError <: Exception
    message::String
end
TimeoutError() = TimeoutError("")

function Base.show(io::IO, err::TimeoutError)
    if isempty(err.message)
        print(io, "Timeout")
    else
        print(io, "Timeout: $(err.message))
    end
end
