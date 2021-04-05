#-------------------------------------------------#  Min
"""
    Min(T::Type = Float64)
Track the overall min.
"""
mutable struct Min{T<:Number} <: OnlineAlgorithm{Number}
    min::T
    arg_min::Int
    n::Int
end
Min(T::Type) = Min(T(0), 0, 0)

function update!(o::Min{T}, x::Number) where {T<:Number}
    o.n += 1
    x = convert(T, x)
    if o.n == 1
        o.min = x
        o.arg_min = 1
    end

    if x < o.min
        o.min = x
        o.arg_min = o.n
    end

    return o
end


#-------------------------------------------------#  Max
"""
    Max(T::Type = Float64)
Track the overall max.
"""
mutable struct Max{T<:Number} <: OnlineAlgorithm{Number}
    max::T
    arg_max::Int
    n::Int
end
Max(T::Type) = Max(T(0), 0, 0)

function update!(o::Max{T}, x::Number) where {T<:Number}
    o.n += 1
    x = convert(T, x)
    if o.n == 1
        o.max = x
        o.arg_max = 1
    end

    if x > o.max
        o.max = x
        o.arg_max = o.n
    end

    return o
end


#-------------------------------------------------#  Sum
"""
    Sum(T::Type = Float6)
Track the overall sum.
"""
# mutable struct Sum{T<:Number}
mutable struct Sum{T<:Number} <: OnlineAlgorithm{Number}
    sum::T
    n::Int
end
Sum(T::Type) = Sum(T(0), 0)
Base.sum(o::Sum) = o.sum

function update!(o::Sum{T}, x::Number) where {T<:Number}
    o.n += 1
    x = convert(T, x)
    o.sum = o.sum + x
    return o
end


#-------------------------------------------------#  mean
"""
    Mean(T::Type = Float6)
Track the overall mean.
"""

mutable struct Mean{T<:Number} <: OnlineAlgorithm{Number}
    mean::T
    n::Int
end
Mean(T::Type = Float64) = Mean(T(0), 0)

function update!(o::Mean{T}, x::Number) where {T<:Number}
    o.n += 1
    x = convert(T, x)
    o.mean = o.mean + (x - o.mean) / o.n
    return o
end


#-------------------------------------------------#  variance
"""
    Variance(T::Type = Float6)
Track the overall variance.
"""

mutable struct Variance{T<:Number} <: OnlineAlgorithm{Number}
    variance::T
    mean::Mean{T}
    n::Int
end
Variance(T::Type = Float64) = Variance(T(0), Mean(T), 0)

function update!(o::Variance{T}, x::Number) where {T<:Number}
    o.n += 1
    x = convert(T, x)
    if o.n > 1
        o.variance = (o.n - 2) / (o.n - 1) * o.variance + (x - o.mean.mean)^2 / o.n
    else
        o.variance = 0.0
    end
    o.mean = update!(o.mean, x)
    return o
end


#-------------------------------------------------#  covariance
"""
    Covariance(T::Type = Float6)
Track the overall variance.
"""

mutable struct Covariance{T<:Number} <: OnlineAlgorithm{Number}
    covariance::T
    x_mean::Mean{T}
    y_mean::Mean{T}
    n::Int
end
Covariance(T::Type = Float64) = Covariance(T(0), Mean(T), Mean(T), 0)

function update!(o::Covariance{T}, x::Number, y::Number) where {T<:Number}
    o.n += 1
    x = convert(T, x)
    y = convert(T, y)
    if o.n > 1
        o.covariance = (
            (o.n - 2) / (o.n - 1) * o.covariance
            + (x - o.x_mean.mean) * (y - o.y_mean.mean) / o.n
        )
    else
        o.covariance = x * y
    end
    o.x_mean = update!(o.x_mean, x)
    o.y_mean = update!(o.y_mean, y)
    return o
end


#-------------------------------------------------#  confidence interval
"""
    ConfidenceInterval(T::Type = Float64, )
Track the overall variance.
"""

mutable struct ConfidenceInterval{T<:Number} <: OnlineAlgorithm{Number}
    interval::Dict{String, Float64}
    mean::Mean{T}
    variance::Variance{T}
    z::Float64
    n::Int
end
ConfidenceInterval(T::Type = Number; z::Float64) = (
    ConfidenceInterval(
        Dict("lower_bound"=>0.0, "upper_bound"=>0.0), Mean(T), Variance(T), z, 0
    )
)

function update!(o::ConfidenceInterval{T}, x::Number) where {T<:Number}
    o.n += 1
    if o.n > 1
        a = o.mean.mean + (x - o.mean.mean) / o.n
        b = o.z * (
            (o.n - 2) * o.variance.variance / (o.n - 1) / o.n
            + ((x - o.mean.mean) / o.n)^2
        )^0.5
    else
        a = x
        b = o.z * abs(x)
    end
    o.interval["lower_bound"] = a - b
    o.interval["upper_bound"] = a + b

    o.mean = update!(o.mean, x)
    o.variance = update!(o.variance, x)
    return o
end
