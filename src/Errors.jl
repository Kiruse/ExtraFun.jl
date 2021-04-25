######################################################################
# Additional errors used in the library.
# -----
# Licensed under MIT License

export CancellationError
struct CancellationError <: Exception
    what
end
CancellationError() = CancellationError(nothing)

function Base.showerror(io::IO, err::CancellationError)
    print(io, "Cancelled")
    if err.what !== nothing
        print(io, ": ")
        print(io, err.what)
    end
end

export TimeoutError
struct TimeoutError <: Exception
    message::String
end
TimeoutError() = TimeoutError("")

function Base.show(io::IO, err::TimeoutError)
    if isempty(err.message)
        print(io, "Timeout")
    else
        print(io, "Timeout: $(err.message)")
    end
end
