using Plots  
gr()

"""
    mk_persistence_diagram(bettis::Array)

Constructs persistence diagrams for an array of betti numbers  
"""
function mk_persistence_diagram(bettis::Array)
    num_homologies = length(bettis[1])
    pd = Dict{Int, Array}()
    for k = 1:num_homologies
        pd[k] = []
        for f = 1:length(bettis)
            push!(pd[k], bettis[f][k])
        end 
    end 
    return pd
end 


"""
    plot_persistence(pd)

Plots the persistence diagram for all the homology groups 
"""
function plot_persistence(pd::Dict{Int,Array}; filename="myplot")
    persistence = Dict()
    first = true 
    for k = collect(keys(pd))
        my_pd = pd[k]
        bd_pairs = []
        if my_pd[1] > 0
            append!(bd_pairs, [[1, length(my_pd)+1] for x=1:(my_pd[1])])
        end 
        for i = 2:length(my_pd)
            if (my_pd[i-1] < my_pd[i] )
                append!(bd_pairs, [[i, length(my_pd)+1] for x=1:(my_pd[i]-my_pd[i-1])])
            elseif (my_pd[i] < my_pd[i-1])
                for j = 1:(my_pd[i-1]-my_pd[i])
                    if bd_pairs[end-j+1][2] == length(my_pd)+1
                        bd_pairs[end-j+1][2] = i
                    end 
                end 
            else 
            end 
        end 
        birth_arr = [x[1] for x in bd_pairs]
        death_arr = [x[2] for x in bd_pairs]
        persistence[k] = [birth_arr, death_arr]
        if first
            plot(birth_arr, death_arr, lw=3, seriestype=:scatter, title="Persistence Diagram", lab="dim H" * string(k-1))
            first = false
        else 
            plot!(birth_arr, death_arr, lw=3, seriestype=:scatter, lab="dim H" * string(k-1))
        end 
    end 
    plot!(title="Persistence Diagram: " * filename)
    xlims!((0, length(pd[1])+2))
    ylims!((0, length(pd[1])+2))
    plot!(size=(500,500), legend=:bottomright)
    plot!([0;length(pd[1])+2], [0; length(pd[1])+2], seriestype=:line, color=:black, linestyle=:dot, lab="")
    plot!([0;length(pd[1])+2], [length(pd[1])+1; length(pd[1])+1], seriestype=:line, color=:black, linestyle=:dot, lab="")
    xlabel!("Birth")
    ylabel!("Death")
    savefig(joinpath(pwd(), "plots", filename * ".png"))
    return persistence 
end 

# bettis = [(1, 1, 1), (2, 2, 1), (1, 3, 4), (5, 6, 7)]
# bettis = [(74, 0, 0), (24, 0, 0), (3, 3, 0), (2, 3, 0), (1, 16, 0), (1, 24, 0), (1, 16, 0), (1, 2, 0)]
# pd = mk_persistence_diagram(bettis)
# persistence = plot_persistence(pd)





