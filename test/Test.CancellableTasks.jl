######################################################################
# CancellableTasks UTs
# -----
# Licensed under MIT License
module TestCancellableTasks
using Test
using ExtraFun.CancellableTasks
import ExtraFun: CancellationError, TimeoutError, cancel

function task_fails(cb, Error::Type{<:Exception})
    try
        cb()
        return false
    catch ex
        @assert ex isa TaskFailedException
        return ex.task.result isa Error
    end
end
function task_fails(cb, err)
    try
        cb()
        return false
    catch ex
        @assert ex isa TaskFailedException
        return ex.task.result === err
    end
end

@testset "Cancel Tasks" begin
    @testset "Cancellable" begin
        @test fetch(with_cancel(() -> 42)) == 42
        
        @test task_fails(CancellationError) do
            task = with_cancel(() -> sleep(1))
            cancel(task)
            wait(task)
        end
        
        @test task_fails("foobar") do
            wait(with_cancel() do
                throw("foobar")
            end)
        end
    end
    
    @testset "Timeouts" begin
        @test fetch(with_timeout(() -> 42, 1)) == 42
        
        @test task_fails(TimeoutError) do
            wait(with_timeout(.5) do; sleep(1) end)
        end
        
        @test task_fails("foobar") do
            wait(with_timeout(1) do
                throw("foobar")
            end)
        end
    end
end

end # module TestCancellableTasks
