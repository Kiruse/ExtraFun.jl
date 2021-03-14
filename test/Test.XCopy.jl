######################################################################
# Unit Tests for ExtraFun's XCopy pattern
# -----
# Licensed under MIT License

struct XCopyTest1
    counter::Int
    flag::Bool
end

struct XCopyTest2
    counter::Int
    flag::Bool
end

@xcopy XCopyTest1

@xcopy XCopyTest2
@xcopy_override XCopyTest2 :counter tpl.counter + 1
@xcopy_override XCopyTest2 :flag true

@testset "ExtraFun XCopy" begin
    @testset "simple" begin
        let test = XCopyTest1(1, false)
            @test (test = xcopy(test)) == XCopyTest1(1, false)
            @test (test = xcopy(test)) == XCopyTest1(1, false)
        end
    end
    
    @testset "overridden" begin
        let test = XCopyTest2(1, false)
            @test (test = xcopy(test)) == XCopyTest2(2, true)
            @test (test = xcopy(test)) == XCopyTest2(3, true)
        end
    end
end
