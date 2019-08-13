"""
    AbstractNeuron

Inherit from this type when creating specific neuron models.

# Expected Fields:
- `voltage::Real`: membrane potential (mV)
- `class::Symbol`: the class of the neuron (:input, :output, or :none)
- `spikes_in::Queue{Integer}`: a FIFO of input spike times
- `spikes_out::Queue{Integer}`: a FIFO of output spike times
"""
abstract type AbstractNeuron end

"""
    AbstractPopulation{NT<:AbstractNeuron}

Inherit from this type when creating a population of neurons.

# Parameterized Types:
- `NT<:AbstractNeuron`: the type of the neurons in the population

# Expected Fields:
- `graph::AbstractGraph`: the connectivity graph between neurons
- `neurons::Array{AbstractNeuron}`: an array of neurons in the population
- `events::Queue{Integer}`: a FIFO of neuron indices indicating spike events
"""
abstract type AbstractPopulation{NT<:AbstractNeuron} end

"""
    neurons(pop::AbstractPopulation)

Return an array of neurons within the population.
"""
neurons(pop::AbstractPopulation) = pop.neurons

"""
    synapses(pop::AbstractPopulation)

Return an array of edges representing the synapses within the population.
"""
synapses(pop::AbstractPopulation) = collect(edges(pop.graph))

"""
    inputs(pop::AbstractPopulation)

Return the indices of the input neurons in a population.
"""
inputs(pop::AbstractPopulation) = findall(x -> x.class == :input, pop.neurons)

"""
    outputs(pop::AbstractPopulation)

Return the indices of the output neurons in a population.
"""
outputs(pop::AbstractPopulation) = findall(x -> x.class == :output, pop.neurons)