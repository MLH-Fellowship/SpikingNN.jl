"""
    SRM0

A SRM0 neuron.

Fields:
- `voltage::VT`: membrane potential
- `current::VT`: injected (unprocessed) current
- `lastspike::VT`: last time this neuron spiked
- `η::F`: refractory response function
"""
mutable struct SRM0{VT<:Real, F<:Function} <: AbstractCell
    voltage::VT
    current::VT
    lastspike::VT
    η::F
end

Base.show(io::IO, ::MIME"text/plain", neuron::SRM0) =
    print(io, """SRM0:
                     voltage:   $(neuron.voltage)
                     current:   $(neuron.current)
                     lastspike: $(neuron.lastspike)
                     η:         $(neuron.η)""")
Base.show(io::IO, neuron::SRM0) =
    print(io, "SRM0(voltage: $(neuron.voltage))")

"""
    SRM0(η)

Create a SRM0 neuron with refractory response function `η`.
"""
SRM0{T}(η::F) where {T<:Real, F<:Function} = SRM0{T, F}(0, 0, -Inf, η)
SRM0(η::Function) = SRM0{Float32}(η)

"""
    SRM0(η₀, τᵣ, v_th)

Create a SRM0 neuron with refractory response function:

``-\\eta_0 \\exp\\left(-\\frac{\\Delta}{\\tau_r}\\right)``
"""
function SRM0{T}(η₀::Real, τᵣ::Real) where T<:Real
    η = Δ -> -η₀ * exp(-Δ / τᵣ)
    SRM0{T}(η)
end
SRM0(η₀::Real, τᵣ::Real) = SRM0{Float32}(η₀, τᵣ)

isactive(neuron::SRM0, t::Integer; dt::Real = 1.0) = (neuron.current > 0)

getvoltage(neuron::SRM0) = neuron.voltage
excite!(neuron::SRM0, current) = (neuron.current += current)
excite!(neurons::T, current) where T<:Union{SRM0, AbstractArray{<:SRM0}} = (neurons.current .+= current)
spike!(neuron::SRM0, t::Integer; dt::Real = 1.0) = (t > 0) && (neuron.lastspike = dt * t)
function spike!(neurons::T, spikes; dt::Real = 1.0) where T<:AbstractArray{<:SRM0}
    map!((x, s) -> (s > 0) ? dt * s : x, neurons.lastspike, neurons.lastspike, spikes)
end

"""
    (neuron::SRM0)(t::Integer; dt::Real = 1.0)
    evalcells(neurons::AbstractArray{<:SRM0}, t::Integer; dt::Real = 1.0)

Evaluate the neuron model at time `t`.
Return membrane potential.
"""
function (neuron::SRM0)(t::Integer; dt::Real = 1.0)
    neuron.voltage = SpikingNNFunctions.Neuron.srm0(t * dt, neuron.current, neuron.voltage; lastspike = neuron.lastspike, eta = neuron.η)
    neuron.current = 0

    return neuron.voltage
end
function evalcells(neurons::T, t::Integer; dt::Real = 1.0) where T<:AbstractArray{<:SRM0}
    SpikingNNFunctions.Neuron.srm0!(t * dt, neurons.current, neurons.voltage; lastspike = neurons.lastspike, eta = neurons.η)
    neurons.current .= 0

    return neurons.voltage
end

function reset!(neurons::SRM0)
    neurons.voltage = 0
    neurons.lastspike = -Inf
    neurons.current = 0
end
function reset!(neurons::T) where T<:Union{SRM0, AbstractArray{<:SRM0}}
    neurons.voltage .= 0
    neurons.lastspike .= -Inf
    neurons.current .= 0
end