# ExtraFun
Extra general purpose functions, stubs, macros & meta types.

These functions, macros & types are either commonly used patterns, or mere stubs.

# Table of Contents
- [ExtraFun](#extrafun)
- [Table of Contents](#table-of-contents)
- [Stubs](#stubs)
  - [use](#use)
  - [clear](#clear)
  - [update!](#update)
- [Functionals](#functionals)
  - [`negate(callable)`](#negatecallable)
    - [Example](#example)
  - [`isathing(x)`](#isathingx)
  - [`truthy(x)` and `falsy(x)`](#truthyx-and-falsyx)
  - [`indexed(coll)`](#indexedcoll)
- [Functions](#functions)
  - [`curry(callable, args...; kwargs...)`](#currycallable-args-kwargs)
    - [Example](#example-1)
  - [`indexof(ary, elem; by, offset, strict) -> Int`](#indexofary-elem-by-offset-strict---int)
    - [Example](#example-2)
  - [`isiterable(::T)`](#isiterablet)
    - [Example](#example-3)
  - [`hassignature(callable, argtypes::Type...)`](#hassignaturecallable-argtypestype)
    - [Example](#example-4)
  - [`shift(ary::Iterable{T}) -> T`](#shiftaryiterablet---t)
    - [Example](#example-5)
  - [`unshift(ary, elem) -> ary`](#unshiftary-elem---ary)
    - [Example](#example-6)
  - [`Base.insert!(vec::Vector{T}, elem::T; before, after, by, strict)`](#baseinsertvecvectort-elemt-before-after-by-strict)
    - [Example](#example-7)
  - [`Base.split(condition, collection)`](#basesplitcondition-collection)
    - [Example](#example-8)
- [Macros](#macros)
  - [`@curry`](#curry)
    - [Example](#example-9)
  - [`@once`](#once)
    - [Example](#example-10)
  - [`@sym_str`](#sym_str)
  - [`@with`](#with)
    - [Usage](#usage)
- [Types](#types)
  - [`Mutable{T}`](#mutablet)
    - [Example](#example-11)
- [Meta Types](#meta-types)
  - [`Ident{S}`](#idents)
    - [Example](#example-12)
- [XCopy](#xcopy)
  - [`xcopy(tpl; kwargs...)`](#xcopytpl-kwargs)
    - [Example](#example-13)
  - [`@xcopy(T::Type)`](#xcopyttype)
  - [`xcopy_construct(tpl::T, args...; kwargs...)`](#xcopy_constructtplt-args-kwargs)
  - [`xcopy_override(tpl, ::FieldCopyOverride{F})`](#xcopy_overridetpl-fieldcopyoverridef)
  - [`@xcopy_override(T::Type, S::Symbol, expr::Expr)`](#xcopy_overridettype-ssymbol-exprexpr)
    - [Example](#example-14)

# Stubs
Function stubs are generically named functions without any actual body - they are, by default, noop. Every defined stub
takes no arguments and do absolutely nothing.

These stubs are meant to be complementary to the Julia standard library. Similar to overloading `Base.push!`, you would
overload `ExtraFun.use`. Then, users of your library may simply `using ExtraFun` and call `use(<your type>)` without
having to worry about absolutely addressing the appropriate module. ExtraFun allows for shorter function names and thus
ease of use.

Following is an enumeration of all function stubs exported by ExtraFun, along with their respective intention. In turn,
these intentions are merely intended to give you an idea what to use these stubs for.

## use
Intended to indicate a change of state, either globally or locally to a container object.

## clear
Intended to empty a collection or clear the state of an object.

## update!
Intended to update the (internal) state of an object. Useful to defer comparatively heavy computations to the end of a
cycle, for example.

# Functionals
Following are general purpose patterns packaged in functions (and possibly corresponding types) for convenience.

## `negate(callable)`
Simple functional negation of a callable. Useful to shorten down callbacks rather than using lambdas.

### Example
```julia
isdiv3(x) = x % 3 == 0
filter!(negate(isdiv3), [1, 2, 3, 4])
```

## `isathing(x)`
Simple negation of `Base.isnothing(x)`.

## `truthy(x)` and `falsy(x)`
`truthy` is a functional way of evaluating the "truth" of a value - as prominent in many other languages. In general, this means at least one bit is set. `falsy` is simply `negate(truthy)`.

## `indexed(coll)`
A functional alternative to `Base.collect(coll)` which only collects `coll` into a `Vector` if it isn't indexable, otherwise returns `coll` itself.

# Functions
Imperative general purpose functions.

## `curry(callable, args...; kwargs...)`
Curries the specified `callable` by prepending `args` in front of positional arguments and passing additional `kwargs`. Note that Julia enforces that keyword must be unique.

A macro to conveniently curry every single first-level function call also exists.

### Example
```julia
function foo(num, factor; dofloor)
    res = num * factor
    if dofloor
        res = floor(res)
    end
    return res
end

bar = curry(foo, 42; dofloor=true)
bar(0.5) # == 21
bar(2.1) # == 88
```

## `indexof(ary, elem; by, offset, strict) -> Int`
Finds the index of the given element in the array-like. If the element was not found, returns `nothing`.

`by` specifies a mapping callback on each element returning the mapped value to compare. The mapper is not called on `elem`.

`offset` specifies the 1-based offset from the start of the array-like to begin search.

`strict` specifies whether to use simple equality (`==`) or strict equality (`===`).

### Example
```julia
indexof([1, 2, 3], 5, by=(i)->i-2, strict=true) # == 3
indexof([1, 2, 3], 5) # == -1
indexof([1, 2, 3], 1, offset=2) # == -1
```

## `isiterable(::T)`
Generated function pattern to test if a signature for `Base.iterate(::T)` exists.

Beware as this pattern may malbehave if such a signature is loaded *after* the first call to this generated function.

### Example
```julia
isiterable([]) # == true
isiterable(:foobar) # == false
isiterable(42) # == true
```

## `hassignature(callable, argtypes::Type...)`
Function pattern to test if a specific signature of a function exists.

### Example
```julia
struct MyStruct end

hassignature(push!, Vector{Int}) # == true
hassignature(push!, MyStruct) # == false
```

## `shift(ary::Iterable{T}) -> T`
Retrieve and remove the first element from the array-like. The array-like must specialize `Base.getindex` and `Base.deleteat!` functions.

### Example
```julia
vec = [1, 2, 3]
shift(vec) # == 1
shift(vec) # == 2
vec # == [3]
```

## `unshift(ary, elem) -> ary`
Insert `elem` at index 1 of the array-like. The array-like must support the signature `Base.insert!(::typeof(ary), 1, ::typeof(elem))`.

### Example
```julia
unshift([2, 3, 4], 1) # == [1, 2, 3, 4]
```

## `Base.insert!(vec::Vector{T}, elem::T; before, after, by, strict)`
Inserts `elem` into `vec` either before or after the named element. Exclusively either `before` or `after` must be supplied. If none or both are supplied, an `ArgumentError` is raised.

`by` is a mapping callback transforming the elements of `vec`, but not `before`/`after` or `elem`. This is useful to, for example, insert `elem` before another which meets a specific condition.

`strict` can be used to specify whether to use strict equality (`===`) or simple equality (`==`).

### Example
```julia
struct Wrapper
    int::Int
end
insert!(Wrapper.([1, 2, 3, 4, 6]), 5, before=6, by=(w)->w.int)
insert!(Wrapper.([1, 2, 3, 4, 6]), 5, after=4, by=(w)->w.int)
```

## `Base.split(condition, collection)`
Split `collection` into two distinct ones where the first contains all elements for which `condition` returns true and the second all those for which `condition` returns false.

Currently supports standard vectors and tuples.

### Example
```julia
split(iseven, collect(1:10)) # == ([2, 4, 6, 8, 10], [1, 3, 5, 7, 9])
```

# Macros
ExtraFun provides a handful of useful yet simple macros. These include:

## `@curry`
A convenience macro which curries every single first-level function call in its block expression. This is useful to call multiple functions reusing various identical arguments.

### Example
```julia
@curry 0xFF42 file = stderr begin
    println("foobar") # prints "0xFF42 foobar" to stderr
    println(42) # prints "0xFF42 42" to stderr
end
```

## `@once`
A convenience macro which ensures the given code is only executed once per session.

### Example
```julia
function foo(n)
    @once n > 512 println("parameter exceeds safety threshold")
    n+1
end

foo(513)
# prints: parameter exceeds safety threshold
foo(514)
# does not print
```

## `@sym_str`
A simple string prefix to produce a symbol. Literally equivalent to `Symbol(str)`. The advantage of using the `sym""`
notation is that it allows using characters otherwise illegal in `:` notation whilst shortening syntax slightly.


## `@with`
Resource management inspired by other languages' `with` keyword. It generates Julia code in the following syntax:

```julia
@with resources... block
# is (almost) equivalent to
try
  let resources...
    block
  end
finally
  close.(resources)
end
```

### Usage
Usage is similar to other languages' `with` keyword:

```julia
res1 = SomeCloseableResource()
@with res1 res2 = SomeCloseableResource() SomeCloseableResource() begin
  println(res1)
  println(res2)
end
println(res1)
# res2 and last resource undefined here
```

Note: for `res1` above to work, `SomeCloseableResource()` should be or contain a reference to the closeable resource. If
it can be copied bitwise, `res1` may remain unchanged outside of `@with`.

# Types
General purpose and simple types.

## `Mutable{T}`
A simple mutable wrapper around a single field of type `T`. The `Mutable` type comes in handy either as a way to reference variables, or to mark a single field of an otherwise immutable struct as mutable.

### Example
```julia
mutable struct Mutable{T}
    value::T
end

struct Immutable
    immutable::Int
    mutable::Mutable{Bool}
end
Immutable(immutable, mutable::Bool) = Immutable(immutable, Mutable(mutable))

myvar = Immutable(42, false)
myvar.mutable[] # == false
myvar.mutable[] = true
myvar.mutable[] # == true
myvar.immutable += 1 # throws
```


# Meta Types
Meta Types are types (abstract or concrete) which either provide additional information on other types, or merely convey
additional information to the compiler. In the simplest instance, this allows adjusting the behavior of otherwise
identical functions, or, vice versa, customizing the behavior of an otherwise identical structure.

## `Ident{S}`
The `Ident` meta type does not contain any information. It is designed to enable the compiler to dispatch based on
actual `Symbol` values as opposed to the `Symbol` type.

### Example
```julia
struct Ident{S} end

extract(::Ident{:foo}) = 42
extract(::Ident{:bar}) = 69.69
```

# XCopy
A more complex pattern which ExtraFun provides is the `xcopy` function and macro family. These allow customizing by various degrees of depth how an object is copied.

## `xcopy(tpl; kwargs...)`
Copies `tpl`, overriding the copy's fields by keyword arguments.

### Example
```julia
struct MyStruct
    int::Int
    flag::Bool
end

@xcopy MyStruct
xcopy(MyStruct(0, false), int=42) # MyStruct(42, false)
```

## `@xcopy(T::Type)`
Makes type `T` `xcopy`able. Because `xcopy` is purposefully not defined generically.

## `xcopy_construct(tpl::T, args...; kwargs...)`
Creates a new instance of `T` with specified `args` and `kwargs`. Specializations may change the behavior entirely, or simply add further initialization based on `tpl`.

## `xcopy_override(tpl, ::FieldCopyOverride{F})`
Retrieves the copied value for the copied object. By default, retrieves `tpl`'s own field. If the field itself is `Base.copy`able, it is copied. Otherwise, it is returned directly (referenced).

Specializations may override this to further customize the behavior of copying individual fields of `tpl`.

See preferred `@xcopy_override` for an example usage.

## `@xcopy_override(T::Type, S::Symbol, expr::Expr)`
Convenience macro to specialize `xcopy_override(tpl::T, ::FieldCopyOverride{S}) = expr`.

### Example
```julia
struct MyStruct
    int::Int
    flag::Bool
end

@xcopy MyStruct
@xcopy_override MyStruct :int tpl.int + 1
xcopy(MyStruct(1, false)) == MyStruct(2, false) # == true
```
