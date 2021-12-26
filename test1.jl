using BenchmarkTools

struct A1
    val::Float64
end
res(a::A1) = sum([a.val*i for i in 1:100000])

struct A2
    val::Float64
    res::Float64
end
A2(val::Float64) = A2(val, sum([val*i for i in 1:100000]))
res(a::A2) = a.res

a = A1(0.3234)
@btime res(a)

b = A2(0.3234)
@btime res(b)